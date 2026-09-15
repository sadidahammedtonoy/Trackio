import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:sadid/App/routes.dart';

enum MessageRole { user, model }

class AiSession {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;

  AiSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory AiSession.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AiSession(
      id: doc.id,
      title: data['title'] as String? ?? 'New Chat',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ChatMessage {
  String? id;
  final String text;
  final MessageRole role;
  final DateTime timestamp;
  bool isLoading;
  final String? actionPrompt;
  final String? actionRoute;
  final RxBool isActionHandled;

  ChatMessage({
    this.id,
    required this.text,
    required this.role,
    DateTime? timestamp,
    this.isLoading = false,
    this.actionPrompt,
    this.actionRoute,
    bool isActionHandled = false,
  }) : timestamp = timestamp ?? DateTime.now(),
       isActionHandled = isActionHandled.obs;

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'role': role == MessageRole.user ? 'user' : 'model',
      'timestamp': Timestamp.fromDate(timestamp),
      if (actionPrompt != null) 'actionPrompt': actionPrompt,
      if (actionRoute != null) 'actionRoute': actionRoute,
      'isActionHandled': isActionHandled.value,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatMessage(
      id: id,
      text: map['text'] as String? ?? '',
      role: (map['role'] == 'user') ? MessageRole.user : MessageRole.model,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      actionPrompt: map['actionPrompt'] as String?,
      actionRoute: map['actionRoute'] as String?,
      isActionHandled: map['isActionHandled'] as bool? ?? false,
    );
  }
}

class AiChatController extends GetxController {
  String _apiKey = '';

  // gemini-3.6-flash — confirmed available for this API key
  static const String _modelName = 'gemini-3.6-flash';

  GenerativeModel? _model;
  ChatSession? _chat;
  String _cachedFinancialContext = '';

  Future<String> _fetchApiKey() async {
    if (_apiKey.isNotEmpty) return _apiKey;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('API Key')
          .doc('Google Gemini')
          .get();
      if (doc.exists && doc.data() != null) {
        final key = doc.data()!['Key'] as String?;
        if (key != null && key.trim().isNotEmpty) {
          _apiKey = key.trim();
          return _apiKey;
        }
      }
    } catch (e) {
      debugPrint('Error fetching API key from Firestore: $e');
    }
    return '';
  }

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;
  final RxBool showSuggestions = true.obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // ─── Firebase Sessions State ────────────────────────────────────────────────
  StreamSubscription? _sessionsSub;
  final RxList<AiSession> sessions = <AiSession>[].obs;
  final Rx<AiSession?> currentSession = Rx<AiSession?>(null);
  final RxBool isCurrentSessionPersisted = false.obs;
  final RxBool isLoadingSessions = false.obs;
  final RxBool isLoadingMessages = false.obs;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

  CollectionReference<Map<String, dynamic>> get _sessionsRef =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('ai_chat_sessions');

  /// Quick suggestion chips shown before the first user message
  static const List<Map<String, String>> suggestions = [
    {
      'label': '💰 How does Budget work?',
      'displayText': 'How does Budget work?',
      'answer':
          'Here is a complete guide to setting up and managing your **Monthly Budget** in **Trackio**:\n\n'
          '### How to Access Budgets\n'
          '1. Open the **Trackio** app.\n'
          '2. Go to the **More** tab from the bottom navigation.\n'
          '3. Tap **Budgets** to open your budget dashboard.\n\n'
          '### How to Create a New Budget\n'
          '• Tap the **+ Add** button at the top-right corner of the page.\n'
          '• **Amount**: Enter your planned budget limit.\n'
          '• **Category**: Select an individual category, or select multiple categories to create a **Group Category** with a custom name.\n'
          '• **Month**: Choose any date within your desired target month.\n'
          '• Tap **Save Budget** to activate.\n\n'
          '### Quick Gesture Controls\n\n'
          '• **Swipe Right** on any budget card to **Edit** its limit or categories.\n'
          '• **Swipe Left** on any budget card to **Delete** it.\n\n'
          '💡 **Smart Tip**: Grouping related categories (e.g., Groceries + Dining = *Food*) gives you a single consolidated spending cap and keeps your monthly finances organized!',
      'actionPrompt': 'Do you want to add a budget now?',
      'actionRoute': routes.add_budget_screen,
    },
    {
      'label': '🏦 How to track Savings?',
      'displayText': 'How to track Savings?',
      'answer':
          'Here is how you can track and record your **Savings** in **Trackio**:\n\n'
          '### How to Access Savings\n'
          '1. Open the **Trackio** app.\n'
          '2. Go to the **More** tab from the bottom navigation.\n'
          '3. Select **Savings** to open your savings dashboard.\n\n'
          '### How to Add Savings\n'
          '• Tap the **+ (Add)** button located at the bottom-right corner.\n'
          '• **Amount**: Enter the amount you want to save.\n'
          '• **Date**: Select the savings date.\n'
          '• **Wallet / Account**: Choose the wallet or account where you are depositing the savings.\n'
          '• **Source**: Specify the source of the money (where the funds came from).\n'
          '• **Note**: Add an optional remark or note if you wish.\n'
          '• Tap **Save** to confirm!\n\n'
          '💡 **Smart Tip**: Regularly logging your monthly savings helps you reach your financial milestones and build a solid emergency fund!',
      'actionPrompt': 'Do you want to view or add savings?',
      'actionRoute': routes.saving_screen,
    },
    {
      'label': '📊 How to add Expenses?',
      'displayText': 'How to add Expenses?',
      'answer':
          'Here is how you can quickly record an **Expense** in **Trackio**:\n\n'
          '### How to Add an Expense\n'
          '1. Open the **Trackio** app and stay on your **Dashboard**.\n'
          '2. Tap the **+ (Add)** icon at the top-right corner of the page.\n'
          '3. Select **Expense** as the transaction type.\n\n'
          '### Fill in the Details\n'
          '• **Amount**: Enter the amount you spent.\n'
          '• **Category**: Select the expense category (e.g., Food, Shopping, Transport, Bills).\n'
          '• **Wallet**: Choose the wallet/account you paid from (e.g., Cash, Bank, Card).\n'
          '• **Date**: Select the date of the expense.\n'
          '• **Remark**: Add an optional note for future reference.\n'
          '• Tap **Save Transaction** to record it!\n\n'
          '💡 **Smart Tip**: Categorizing your expenses consistently gives you instant, visual charts of where your money goes each month!',
      'actionPrompt': 'Do you want to add an expense now?',
      'actionRoute': routes.addTranscations_screen,
    },
    {
      'label': '📈 How to manage Income?',
      'displayText': 'How to manage Income?',
      'answer':
          'Here is how you can add and track your **Income** in **Trackio**:\n\n'
          '### How to Add Income\n'
          '1. Open the **Trackio** app and navigate to your **Dashboard**.\n'
          '2. Tap the **+ (Add)** icon at the top-right corner of the screen.\n'
          '3. Make sure to select **Income** as the transaction type.\n\n'
          '### Fill in the Details\n'
          '• **Amount**: Enter the income amount you earned or received.\n'
          '• **Category**: Select your income category (e.g., Salary, Freelance, Business, Investment).\n'
          '• **Wallet**: Choose the destination wallet or bank account where the money was deposited.\n'
          '• **Date**: Pick the payment date.\n'
          '• **Remark**: Add an optional note or source remark.\n'
          '• Tap **Save Transaction** to finish!\n\n'
          '💡 **Smart Tip**: Keeping both income and expenses up to date gives you an accurate view of your monthly cash flow and actual savings!',
      'actionPrompt': 'Do you want to add income now?',
      'actionRoute': routes.addTranscations_screen,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _fetchApiKey().then((key) {
      if (key.isNotEmpty) {
        _initializeModel();
      }
    });
    _initSessions();
    _preloadFinancialContext();
  }

  void _preloadFinancialContext() {
    _fetchFinancialContext().then((ctx) {
      if (ctx.isNotEmpty) {
        _cachedFinancialContext = ctx;
        if (_apiKey.isNotEmpty) {
          _initializeModel(customContext: ctx);
        }
      }
    }).catchError((e) {
      debugPrint('Preload financial context error: $e');
    });
  }

  void _initializeModel({String? customContext}) {
    if (_apiKey.isEmpty) return;
    final contextToUse = (customContext != null && customContext.isNotEmpty)
        ? customContext
        : _cachedFinancialContext;
    final sysPrompt = _buildSystemInstruction(contextToUse);

    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 8192,
      ),
      systemInstruction: Content.system(sysPrompt),
    );
    _chat = _model?.startChat();
  }

  // ─── Firebase Sessions Management ──────────────────────────────────────────

  void _initSessions() {
    isLoadingSessions.value = true;
    _sessionsSub = _sessionsRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) async {
            final list = snapshot.docs
                .map((d) => AiSession.fromDoc(d))
                .toList();
            sessions.value = list;
            isLoadingSessions.value = false;

            // Clean up duplicate empty 'New Chat' sessions in Firestore in background
            final emptyChats = list
                .where((s) => s.title == 'New Chat')
                .toList();
            if (emptyChats.length > 1) {
              for (final extra in emptyChats.skip(1)) {
                _cleanUpEmptySessionIfUnused(extra.id);
              }
            }

            // If no active session selected yet:
            if (currentSession.value == null) {
              if (list.isNotEmpty) {
                await switchSession(list.first, force: true);
              } else {
                await createNewSession();
              }
            } else {
              // If current session was deleted in Firestore
              final stillExists = list.any(
                (s) => s.id == currentSession.value!.id,
              );
              if (!stillExists && isCurrentSessionPersisted.value) {
                if (list.isNotEmpty) {
                  await switchSession(list.first, force: true);
                } else {
                  await createNewSession();
                }
              } else if (stillExists) {
                // Keep currentSession in sync with any title / timestamp edits
                final updated = list.firstWhere(
                  (s) => s.id == currentSession.value!.id,
                );
                currentSession.value = updated;
              }
            }
          },
          onError: (e) {
            debugPrint('Error listening to AI sessions: $e');
            isLoadingSessions.value = false;
            if (currentSession.value == null) {
              _addWelcomeMessage();
            }
          },
        );
  }

  Future<void> createNewSession({String title = 'New Chat'}) async {
    // 1. Check if user is ALREADY on an empty new chat (no user messages sent yet)
    final hasUserMessageInCurrent = messages.any(
      (m) => m.role == MessageRole.user,
    );
    if (!hasUserMessageInCurrent &&
        currentSession.value != null &&
        (currentSession.value!.title == 'New Chat' ||
            !isCurrentSessionPersisted.value)) {
      // Already on an empty new chat! Nothing more needed.
      return;
    }

    // 2. Check if an existing empty "New Chat" session already exists in the sessions list:
    AiSession? existingEmpty;
    for (final s in sessions) {
      if (s.title == 'New Chat') {
        existingEmpty = s;
        break;
      }
    }

    if (existingEmpty != null) {
      // Switch to this existing empty session instead of creating a duplicate
      await switchSession(existingEmpty);
      return;
    }

    // 3. Otherwise, set up a local in-memory draft (DO NOT store in Firebase yet):
    final now = DateTime.now();
    currentSession.value = AiSession(
      id: '', // Empty until user sends first message
      title: title,
      createdAt: now,
      updatedAt: now,
    );
    isCurrentSessionPersisted.value = false;
    messages.clear();
    _chat = _model?.startChat();
    _addWelcomeMessage();
    _scrollToBottom();
  }

  Future<void> _cleanUpEmptySessionIfUnused(String sessionId) async {
    if (sessionId.isEmpty) return;
    try {
      final msgSnap = await _sessionsRef
          .doc(sessionId)
          .collection('messages')
          .get();
      final hasUserMsg = msgSnap.docs.any((d) => d.data()['role'] == 'user');
      if (!hasUserMsg) {
        for (final doc in msgSnap.docs) {
          await doc.reference.delete();
        }
        await _sessionsRef.doc(sessionId).delete();
      }
    } catch (e) {
      debugPrint('Error cleaning up empty session: $e');
    }
  }

  Future<void> switchSession(AiSession session, {bool force = false}) async {
    if (!force &&
        currentSession.value?.id == session.id &&
        session.id.isNotEmpty) {
      return;
    }

    currentSession.value = session;
    isCurrentSessionPersisted.value = session.id.isNotEmpty;
    isLoadingMessages.value = true;
    messages.clear();

    try {
      final msgSnap = await _sessionsRef
          .doc(session.id)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      if (msgSnap.docs.isEmpty) {
        _addWelcomeMessage();
      } else {
        final loaded = msgSnap.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), id: doc.id))
            .toList();

        // If a message with an actionPrompt is followed by any later message
        // (e.g. user replied 'Yes' / 'No' or sent another message), or if it was
        // marked handled, ensure isActionHandled is true and permanently updated in Firestore.
        for (int i = 0; i < loaded.length; i++) {
          final msg = loaded[i];
          if (msg.actionPrompt != null) {
            final hasLaterMessage = i < loaded.length - 1;
            if (hasLaterMessage || msg.isActionHandled.value) {
              msg.isActionHandled.value = true;
              if (msg.id != null &&
                  msgSnap.docs[i].data()['isActionHandled'] != true) {
                _sessionsRef
                    .doc(session.id)
                    .collection('messages')
                    .doc(msg.id)
                    .update({'isActionHandled': true})
                    .catchError((_) {});
              }
            }
          }
        }
        messages.value = loaded;
      }

      _chat = _model?.startChat();
    } catch (e) {
      debugPrint('Error loading session messages: $e');
      _addWelcomeMessage();
    } finally {
      isLoadingMessages.value = false;
      _scrollToBottom();
    }
  }

  Future<void> updateSessionTitle(String sessionId, String newTitle) async {
    final trimmed = newTitle.trim();
    if (trimmed.isEmpty) return;

    // 1. Immediate optimistic UI update
    final idx = sessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      sessions[idx].title = trimmed;
      sessions.refresh();
    }
    if (currentSession.value?.id == sessionId) {
      currentSession.value!.title = trimmed;
      currentSession.refresh();
    }

    // 2. Persist in Firestore
    try {
      await _sessionsRef.doc(sessionId).update({
        'title': trimmed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating session title: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    // 1. Immediate optimistic UI update: remove from list instantly (0ms)
    final removedIdx = sessions.indexWhere((s) => s.id == sessionId);
    AiSession? removedSession;
    if (removedIdx != -1) {
      removedSession = sessions.removeAt(removedIdx);
      sessions.refresh();
    }

    // 2. If the deleted session is currently active, switch immediately
    if (currentSession.value?.id == sessionId) {
      if (sessions.isNotEmpty) {
        await switchSession(sessions.first, force: true);
      } else {
        await createNewSession();
      }
    }

    // 3. Batch delete all messages and session document from Firestore
    try {
      final msgSnap = await _sessionsRef
          .doc(sessionId)
          .collection('messages')
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in msgSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_sessionsRef.doc(sessionId));
      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting session: $e');
      // Rollback if deletion fails
      if (removedSession != null && !sessions.any((s) => s.id == sessionId)) {
        sessions.insert(removedIdx.clamp(0, sessions.length), removedSession);
        sessions.refresh();
      }
    }
  }

  Future<void> _saveMessageToFirestore(
    String sessionId,
    ChatMessage msg,
  ) async {
    try {
      final docRef = await _sessionsRef
          .doc(sessionId)
          .collection('messages')
          .add(msg.toMap());
      msg.id = docRef.id;
      // If action was already handled while saving was in-flight, update Firestore immediately
      if (msg.isActionHandled.value) {
        await docRef.update({'isActionHandled': true});
      }
      await _sessionsRef.doc(sessionId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving message to Firestore: $e');
    }
  }

  void _addWelcomeMessage() {
    messages.add(
      ChatMessage(
        text:
            "Hi! I'm Trackio AI 👋\n\nI'm your personal finance assistant. Ask me anything about budgeting, saving, tracking expenses, or financial tips!",
        role: MessageRole.model,
      ),
    );
  }

  Future<void> sendMessage(
    String text, {
    String? displayText,
    String? predefinedAnswer,
    String? actionPrompt,
    String? actionRoute,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isTyping.value) return;

    final visibleText = (displayText != null && displayText.trim().isNotEmpty)
        ? displayText.trim()
        : trimmed;

    textController.clear();

    // Ensure session exists and is persisted to Firebase
    if (currentSession.value == null ||
        !isCurrentSessionPersisted.value ||
        currentSession.value!.id.isEmpty) {
      // First message in this new chat: create the session document in Firestore now!
      final autoTitle = visibleText.length > 26
          ? '${visibleText.substring(0, 26)}...'
          : visibleText;
      final docRef = _sessionsRef.doc();
      final now = DateTime.now();
      await docRef.set({
        'title': autoTitle,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final newSession = AiSession(
        id: docRef.id,
        title: autoTitle,
        createdAt: now,
        updatedAt: now,
      );
      currentSession.value = newSession;
      isCurrentSessionPersisted.value = true;
    } else {
      final activeSession = currentSession.value!;
      // Auto-update title if it's still 'New Chat'
      if (activeSession.title == 'New Chat') {
        final autoTitle = visibleText.length > 26
            ? '${visibleText.substring(0, 26)}...'
            : visibleText;
        updateSessionTitle(activeSession.id, autoTitle);
      }
    }

    final activeSession = currentSession.value!;

    // Mark any previous unhandled action prompts as handled so they don't linger
    for (final m in messages) {
      if (m.actionPrompt != null && !m.isActionHandled.value) {
        m.isActionHandled.value = true;
        if (m.id != null) {
          _sessionsRef
              .doc(activeSession.id)
              .collection('messages')
              .doc(m.id)
              .update({'isActionHandled': true})
              .catchError((_) {});
        }
      }
    }

    // Add user message to UI
    final userMsg = ChatMessage(text: visibleText, role: MessageRole.user);
    messages.add(userMsg);
    _scrollToBottom();

    // Persist user message to Firebase
    _saveMessageToFirestore(activeSession.id, userMsg);

    // Add typing/loading indicator
    isTyping.value = true;
    messages.add(
      ChatMessage(text: '', role: MessageRole.model, isLoading: true),
    );
    _scrollToBottom();

    // Check if there is a predefined fixed answer (do NOT call Gemini AI)
    String? directAnswer = predefinedAnswer;
    String? promptAction = actionPrompt;
    String? routeAction = actionRoute;

    if (directAnswer == null || directAnswer.trim().isEmpty) {
      final cleanQuery = trimmed
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .trim();
      for (final s in suggestions) {
        final ans = s['answer'];
        if (ans == null || ans.trim().isEmpty) continue;

        final display = (s['displayText'] ?? '')
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\s]'), '')
            .trim();
        final label = (s['label'] ?? '')
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\s]'), '')
            .trim();
        if (cleanQuery == display ||
            cleanQuery == label ||
            (display.isNotEmpty && cleanQuery.contains(display)) ||
            (cleanQuery.length > 4 && display.contains(cleanQuery))) {
          directAnswer = ans;
          promptAction = s['actionPrompt'];
          routeAction = s['actionRoute'];
          break;
        }
      }
    }

    if (directAnswer != null && directAnswer.trim().isNotEmpty) {
      // Natural brief typing delay so user sees typing animation, then display fixed answer
      await Future.delayed(const Duration(milliseconds: 400));
      if (messages.isNotEmpty && messages.last.isLoading) {
        messages.removeLast();
      }
      final modelMsg = ChatMessage(
        text: directAnswer.trim(),
        role: MessageRole.model,
        actionPrompt: promptAction,
        actionRoute: routeAction,
      );
      messages.add(modelMsg);
      isTyping.value = false;
      _scrollToBottom();

      // Persist model message to Firebase
      _saveMessageToFirestore(activeSession.id, modelMsg);
      return;
    }

    // Otherwise, query Gemini AI
    try {
      if (_apiKey.isEmpty) {
        await _fetchApiKey();
      }
      if (_apiKey.isEmpty) {
        throw Exception(
          'API Key could not be loaded from Firebase Firestore (API Key/Google Gemini).',
        );
      }

      final financialContext = await _getOrFetchFinancialContext();
      final sysPrompt = _buildSystemInstruction(financialContext);

      _model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 8192,
        ),
        systemInstruction: Content.system(sysPrompt),
      );

      final history = _buildHistoryForGemini();
      _chat = _model!.startChat(history: history);

      final response = await _chat!.sendMessage(Content.text(trimmed));
      final responseText =
          response.text ?? "Sorry, I couldn't generate a response.";

      messages.removeLast();
      final modelMsg = ChatMessage(text: responseText, role: MessageRole.model);
      messages.add(modelMsg);

      // Persist Gemini response to Firebase
      _saveMessageToFirestore(activeSession.id, modelMsg);
    } on GenerativeAIException catch (e) {
      debugPrint('GenerativeAIException: ${e.message}');
      messages.removeLast();
      final errorMsg = ChatMessage(
        text: _parseGeminiError(e.message),
        role: MessageRole.model,
      );
      messages.add(errorMsg);
      _saveMessageToFirestore(activeSession.id, errorMsg);
    } catch (e, st) {
      debugPrint('Chat error: $e\n$st');
      messages.removeLast();
      final errorMsg = ChatMessage(
        text: _parseError(e.toString()),
        role: MessageRole.model,
      );
      messages.add(errorMsg);
      _saveMessageToFirestore(activeSession.id, errorMsg);
    } finally {
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  /// Handle Yes/No response for action suggestion prompts
  void handleActionResponse(ChatMessage message, bool accepted) {
    message.isActionHandled.value = true;
    final activeSessionId = currentSession.value?.id;

    // Immediately persist handled status to Firestore
    if (activeSessionId != null && message.id != null) {
      _sessionsRef
          .doc(activeSessionId)
          .collection('messages')
          .doc(message.id)
          .update({'isActionHandled': true})
          .catchError((e) => debugPrint('Error updating action handled: $e'));
    }

    if (accepted) {
      final userMsg = ChatMessage(text: 'Yes', role: MessageRole.user);
      messages.add(userMsg);
      _scrollToBottom();

      if (activeSessionId != null) {
        _saveMessageToFirestore(activeSessionId, userMsg);
      }

      if (message.actionRoute != null && message.actionRoute!.isNotEmpty) {
        Get.toNamed(message.actionRoute!);
      }
    } else {
      final userMsg = ChatMessage(text: 'No', role: MessageRole.user);
      messages.add(userMsg);
      _scrollToBottom();

      final modelMsg = ChatMessage(
        text: "No problem! Let me know if you need any other help 😊",
        role: MessageRole.model,
      );
      messages.add(modelMsg);
      _scrollToBottom();

      if (activeSessionId != null) {
        final batch = FirebaseFirestore.instance.batch();
        final msgCol = _sessionsRef.doc(activeSessionId).collection('messages');
        batch.set(msgCol.doc(), userMsg.toMap());
        batch.set(msgCol.doc(), modelMsg.toMap());
        batch.commit().catchError((_) {});
      }
    }
  }

  String _parseGeminiError(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('api key') ||
        lower.contains('api_key') ||
        lower.contains('401') ||
        lower.contains('invalid') ||
        lower.contains('forbidden') ||
        lower.contains('403')) {
      return '🔑 API key is invalid or expired. Please check your configuration.';
    } else if (lower.contains('quota') ||
        lower.contains('429') ||
        lower.contains('rate')) {
      return '⏳ Rate limit reached. Please wait a moment and try again.';
    } else if (lower.contains('not found') || lower.contains('404')) {
      return '❌ Model not available. Please contact support.';
    } else if (lower.contains('safety') || lower.contains('block')) {
      return '⚠️ Your message was blocked by safety filters. Please rephrase.';
    }
    // Show raw error in debug builds for troubleshooting
    if (kDebugMode) {
      return '⚠️ Gemini Error: $msg';
    }
    return '❌ Gemini could not respond. Please try again.';
  }

  String _parseError(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('api key') || lower.contains('firestore')) {
      return '🔑 API key could not be loaded from Firebase. Please ensure collection "API Key", document "Google Gemini", and field "Key" are configured.';
    }
    if (lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('handshake')) {
      return '🌐 No internet connection. Please check your network and try again.';
    }
    if (kDebugMode) {
      return '⚠️ Error: $msg';
    }
    return '❌ Something went wrong. Please try again.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearChat() {
    if (currentSession.value != null) {
      deleteSession(currentSession.value!.id);
    } else {
      messages.clear();
      _chat = _model?.startChat();
      _addWelcomeMessage();
      showSuggestions.value = true;
    }
  }

  Future<String> _getOrFetchFinancialContext() async {
    try {
      final fresh = await _fetchFinancialContext().timeout(
        const Duration(seconds: 4),
        onTimeout: () => _cachedFinancialContext.isNotEmpty
            ? _cachedFinancialContext
            : 'User financial data is temporarily unavailable.',
      );
      if (fresh.isNotEmpty) {
        _cachedFinancialContext = fresh;
      }
      return _cachedFinancialContext.isNotEmpty
          ? _cachedFinancialContext
          : 'User financial data is temporarily unavailable.';
    } catch (e) {
      return _cachedFinancialContext.isNotEmpty
          ? _cachedFinancialContext
          : 'User financial data is temporarily unavailable.';
    }
  }

  Future<String> _fetchFinancialContext() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userName = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
          ? user.displayName!.trim()
          : (user?.email != null && user!.email!.contains('@')
              ? user.email!.split('@').first.trim()
              : 'Trackio User');
      final uid = user?.uid;
      if (uid == null || uid.isEmpty) {
        return 'User: $userName (Guest/Not logged in)';
      }

      final now = DateTime.now();
      final currentMonthKey = DateFormat('yyyy-MM').format(now);
      final currentMonthName = DateFormat('MMMM yyyy').format(now);
      final todayFormatted = DateFormat('d MMMM yyyy').format(now);
      final lastDay = DateTime(now.year, now.month + 1, 0).day;
      final daysRemaining = (lastDay - now.day) + 1;

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);

      // Fetch all required data concurrently for speed
      final results = await Future.wait([
        userDocRef
            .collection('monthly_transactions')
            .doc(currentMonthKey)
            .collection('items')
            .get(),
        userDocRef
            .collection('monthly_transactions')
            .doc(currentMonthKey)
            .collection('budgets')
            .get(),
        userDocRef
            .collection('savings')
            .doc('items')
            .collection('list')
            .orderBy('date', descending: true)
            .get(),
        userDocRef.collection('categories').get(),
        userDocRef.collection('stats').doc('summary').get(),
      ]);

      final currentItemsSnap = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final budgetsSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;
      final savingsListSnap = results[2] as QuerySnapshot<Map<String, dynamic>>;
      final categoriesSnap = results[3] as QuerySnapshot<Map<String, dynamic>>;
      final statsSnap = results[4] as DocumentSnapshot<Map<String, dynamic>>;

      double currentIncome = 0.0;
      double currentExpense = 0.0;
      double currentSavings = 0.0;
      final Map<String, double> categoryExpenseMap = {};
      final Map<String, double> categoryIncomeMap = {};
      final List<Map<String, dynamic>> expenseTransactions = [];

      for (final doc in currentItemsSnap.docs) {
        final data = doc.data();
        final type = (data['type'] as String? ?? '').trim();
        final rawAmt = data['amount'];
        final amt = (rawAmt is String)
            ? double.tryParse(rawAmt) ?? 0.0
            : (rawAmt as num?)?.toDouble() ?? 0.0;
        final cat = (data['category'] as String? ?? 'General').trim();
        final note = (data['note'] as String? ?? '').trim();

        final lowerType = type.toLowerCase();
        if (lowerType == 'income') {
          currentIncome += amt;
          categoryIncomeMap[cat] = (categoryIncomeMap[cat] ?? 0.0) + amt;
        } else if (lowerType == 'expense') {
          currentExpense += amt;
          categoryExpenseMap[cat] = (categoryExpenseMap[cat] ?? 0.0) + amt;
          expenseTransactions.add({
            'category': cat,
            'amount': amt,
            'note': note,
          });
        } else if (lowerType == 'saving') {
          currentSavings += amt;
        }
      }

      final netCashflow = currentIncome - currentExpense;

      double totalBudget = 0.0;
      double totalBudgetSpent = 0.0;
      final List<String> budgetLines = [];

      if (budgetsSnap.docs.isEmpty) {
        budgetLines.add('• No specific budgets created yet for this month.');
      } else {
        for (final doc in budgetsSnap.docs) {
          final data = doc.data();
          final rawBudget = data['amount'];
          final bAmt = (rawBudget is String)
              ? double.tryParse(rawBudget) ?? 0.0
              : (rawBudget as num?)?.toDouble() ?? 0.0;
          totalBudget += bAmt;

          final List<String> cats = [];
          if (data['categories'] is List) {
            for (final c in data['categories']) {
              if (c is String && c.trim().isNotEmpty) cats.add(c.trim());
            }
          } else if (data['category'] is String && (data['category'] as String).trim().isNotEmpty) {
            cats.add((data['category'] as String).trim());
          }

          final groupName = (data['groupName'] as String?)?.trim().isNotEmpty == true
              ? (data['groupName'] as String).trim()
              : (cats.isNotEmpty ? cats.join(', ') : 'Budget');

          // Calculate spending for this budget based on matching expense categories
          double bSpent = 0.0;
          for (final tx in expenseTransactions) {
            final txCat = tx['category'] as String;
            if (cats.contains(txCat)) {
              bSpent += (tx['amount'] as double);
            }
          }
          totalBudgetSpent += bSpent;
          final bRemaining = bAmt - bSpent;
          final percentUsed = bAmt > 0 ? (bSpent / bAmt) * 100 : 0.0;

          String status;
          if (bRemaining < 0) {
            status = 'EXCEEDED by ৳${(-bRemaining).toStringAsFixed(0)} (Over-budget!)';
          } else if (percentUsed >= 80) {
            status = 'WARNING: ${percentUsed.toStringAsFixed(0)}% used (Only ৳${bRemaining.toStringAsFixed(0)} remaining)';
          } else {
            status = 'ON TRACK: ${percentUsed.toStringAsFixed(0)}% used (৳${bRemaining.toStringAsFixed(0)} remaining)';
          }

          budgetLines.add(
            '• $groupName: Budget ৳${bAmt.toStringAsFixed(0)} | Spent ৳${bSpent.toStringAsFixed(0)} | Remaining ৳${bRemaining.toStringAsFixed(0)} -> Status: $status',
          );
        }
      }

      final totalBudgetRemaining = totalBudget - totalBudgetSpent;
      final totalBudgetPercent = totalBudget > 0 ? (totalBudgetSpent / totalBudget) * 100 : 0.0;
      final safeDailySpend = (totalBudgetRemaining > 0 && daysRemaining > 0)
          ? (totalBudgetRemaining / daysRemaining)
          : 0.0;

      // 3. Top Spending Categories (Where user spent the most)
      final List<String> topCategoryLines = [];
      if (categoryExpenseMap.isEmpty) {
        topCategoryLines.add('• No expenses recorded yet for this month.');
      } else {
        final sortedCats = categoryExpenseMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        for (int i = 0; i < sortedCats.length && i < 5; i++) {
          final entry = sortedCats[i];
          final pct = currentExpense > 0 ? (entry.value / currentExpense) * 100 : 0.0;
          topCategoryLines.add(
            '${i + 1}. ${entry.key}: ৳${entry.value.toStringAsFixed(0)} (${pct.toStringAsFixed(1)}% of total monthly expenses)',
          );
        }
      }

      // 4. Past 3 Months Data (Income vs Expense)
      final List<String> pastMonthLines = [];
      for (int i = 1; i <= 3; i++) {
        final prevDate = DateTime(now.year, now.month - i, 1);
        final prevMonthKey = DateFormat('yyyy-MM').format(prevDate);
        final prevMonthName = DateFormat('MMMM yyyy').format(prevDate);

        try {
          final prevSnap = await userDocRef
              .collection('monthly_transactions')
              .doc(prevMonthKey)
              .collection('items')
              .get();

          if (prevSnap.docs.isEmpty) {
            pastMonthLines.add('• $prevMonthName ($prevMonthKey): No records found');
          } else {
            double pIncome = 0.0;
            double pExpense = 0.0;
            for (final d in prevSnap.docs) {
              final t = (d.data()['type'] as String? ?? '').trim().toLowerCase();
              final raw = d.data()['amount'];
              final a = (raw is String)
                  ? double.tryParse(raw) ?? 0.0
                  : (raw as num?)?.toDouble() ?? 0.0;
              if (t == 'income') pIncome += a;
              if (t == 'expense') pExpense += a;
            }
            final pNet = pIncome - pExpense;
            pastMonthLines.add(
              '• $prevMonthName ($prevMonthKey): Income ৳${pIncome.toStringAsFixed(0)} | Expense ৳${pExpense.toStringAsFixed(0)} | Net Savings ৳${pNet.toStringAsFixed(0)}',
            );
          }
        } catch (e) {
          pastMonthLines.add('• $prevMonthName: Data unavailable');
        }
      }

      // Process Savings
      double totalDedicatedSavings = 0.0;
      final List<String> recentSavingsLines = [];
      for (final doc in savingsListSnap.docs) {
        final data = doc.data();
        final raw = data['amount'];
        final amt = (raw is num)
            ? raw.toDouble()
            : (raw is String
                ? double.tryParse(raw.replaceAll(',', '')) ?? 0.0
                : 0.0);
        totalDedicatedSavings += amt;

        if (recentSavingsLines.length < 5 && amt > 0) {
          DateTime d = DateTime.now();
          if (data['date'] is Timestamp) {
            d = (data['date'] as Timestamp).toDate();
          } else if (data['date'] is DateTime) {
            d = data['date'];
          }
          final dStr = DateFormat('d MMM yyyy').format(d);
          final src = (data['source'] as String? ?? '').trim();
          final wallet = (data['wallet'] as String? ?? '').trim();
          final note = (data['note'] as String? ?? '').trim();

          final srcPart = src.isNotEmpty ? ' from $src' : '';
          final walletPart = wallet.isNotEmpty ? ' in $wallet' : '';
          final notePart = note.isNotEmpty ? ' ("$note")' : '';
          recentSavingsLines.add(
            '• ৳${amt.toStringAsFixed(0)}$srcPart$walletPart on $dStr$notePart',
          );
        }
      }

      double overallSavedFromStats = 0.0;
      if (statsSnap.exists && statsSnap.data() != null) {
        final raw = statsSnap.data()!['overallSaving'];
        overallSavedFromStats = (raw is String)
            ? double.tryParse(raw) ?? 0.0
            : (raw as num?)?.toDouble() ?? 0.0;
      }
      final grandTotalSavings =
          totalDedicatedSavings + overallSavedFromStats + currentSavings;
      final savingsRate = currentIncome > 0
          ? ((netCashflow > 0 ? netCashflow : 0) / currentIncome) * 100
          : 0.0;

      // Process Configured Categories
      final List<String> userCategories = [];
      for (final doc in categoriesSnap.docs) {
        final name = (doc.data()['name'] as String? ?? '').trim();
        if (name.isNotEmpty && !userCategories.contains(name)) {
          userCategories.add(name);
        }
      }

      // Collect all budgeted category names
      final List<String> allBudgetedCategories = [];
      for (final doc in budgetsSnap.docs) {
        final data = doc.data();
        if (data['categories'] is List) {
          for (final c in data['categories']) {
            if (c is String && c.trim().isNotEmpty) {
              allBudgetedCategories.add(c.trim());
            }
          }
        } else if (data['category'] is String &&
            (data['category'] as String).trim().isNotEmpty) {
          allBudgetedCategories.add((data['category'] as String).trim());
        }
      }

      // Identify unbudgeted categories where spending occurred
      final List<String> unbudgetedSpendLines = [];
      categoryExpenseMap.forEach((cat, spent) {
        if (!allBudgetedCategories.contains(cat) && spent > 0) {
          final pct =
              currentExpense > 0 ? (spent / currentExpense) * 100 : 0.0;
          unbudgetedSpendLines.add(
            '• $cat: ৳${spent.toStringAsFixed(0)} (${pct.toStringAsFixed(1)}% of expenses) - NO BUDGET SET',
          );
        }
      });

      final buffer = StringBuffer();
      buffer.writeln('=== USER PROFILE ===');
      buffer.writeln('• User Name: $userName');
      buffer.writeln("• Today's Date: $todayFormatted (Current Month: $currentMonthName)");
      buffer.writeln('• Days remaining in this month: $daysRemaining days');
      buffer.writeln();
      buffer.writeln('=== CURRENT MONTH FINANCIAL OVERVIEW ($currentMonthName) ===');
      buffer.writeln('• Total Income: ৳${currentIncome.toStringAsFixed(0)}');
      buffer.writeln('• Total Expense: ৳${currentExpense.toStringAsFixed(0)}');
      buffer.writeln('• Net Balance (Income - Expense): ৳${netCashflow.toStringAsFixed(0)}');
      if (currentSavings > 0) {
        buffer.writeln('• Recorded Monthly Savings: ৳${currentSavings.toStringAsFixed(0)}');
      }
      buffer.writeln();
      buffer.writeln('=== SAVINGS PORTFOLIO & TRACKIO SAVINGS ===');
      buffer.writeln('• Total Accumulated Dedicated Savings: ৳${grandTotalSavings.toStringAsFixed(0)}');
      buffer.writeln('• Total Deposited in Trackio Savings List: ৳${totalDedicatedSavings.toStringAsFixed(0)}');
      buffer.writeln('• This Month Net Savings: ৳${netCashflow.toStringAsFixed(0)}');
      buffer.writeln('• Current Month Savings Rate: ${savingsRate.toStringAsFixed(1)}% of monthly income saved');
      if (recentSavingsLines.isNotEmpty) {
        buffer.writeln('• Recent Savings Deposits:');
        for (final line in recentSavingsLines) {
          buffer.writeln('  $line');
        }
      } else {
        buffer.writeln('• Recent Savings Deposits: None recorded yet.');
      }
      buffer.writeln();
      buffer.writeln('=== CATEGORIES & FULL BREAKDOWN ===');
      buffer.writeln('• User Configured Categories in App: ${userCategories.isEmpty ? 'Default categories (Food, Shopping, Transport, Bills, etc.)' : userCategories.join(', ')}');
      buffer.writeln('• Expense Breakdown by Category (This Month):');
      if (categoryExpenseMap.isEmpty) {
        buffer.writeln('  - No expenses recorded yet.');
      } else {
        categoryExpenseMap.forEach((cat, spent) {
          final pct = currentExpense > 0 ? (spent / currentExpense) * 100 : 0.0;
          final isBudgeted = allBudgetedCategories.contains(cat);
          buffer.writeln('  - $cat: ৳${spent.toStringAsFixed(0)} (${pct.toStringAsFixed(1)}%) ${isBudgeted ? '[Budgeted]' : '[NO BUDGET CAP]'}');
        });
      }
      if (categoryIncomeMap.isNotEmpty) {
        buffer.writeln('• Income Breakdown by Category (This Month):');
        categoryIncomeMap.forEach((cat, earned) {
          buffer.writeln('  - $cat: ৳${earned.toStringAsFixed(0)}');
        });
      }
      if (unbudgetedSpendLines.isNotEmpty) {
        buffer.writeln('• Unbudgeted Spending Categories (User spent money without a budget limit):');
        for (final line in unbudgetedSpendLines) {
          buffer.writeln('  $line');
        }
      }
      buffer.writeln();
      buffer.writeln('=== ACTIVE BUDGETS FOR THIS MONTH ===');
      for (final line in budgetLines) {
        buffer.writeln(line);
      }
      buffer.writeln('--- Overall Budget Summary ---');
      buffer.writeln('• Total Allocated Budget: ৳${totalBudget.toStringAsFixed(0)}');
      buffer.writeln('• Total Budget Spent: ৳${totalBudgetSpent.toStringAsFixed(0)} (${totalBudgetPercent.toStringAsFixed(1)}% used)');
      if (totalBudgetRemaining >= 0) {
        buffer.writeln('• Total Budget Remaining: ৳${totalBudgetRemaining.toStringAsFixed(0)} (User can still spend ৳${totalBudgetRemaining.toStringAsFixed(0)} within overall budget)');
        buffer.writeln('• Safe Daily Spending Allowance: ৳${safeDailySpend.toStringAsFixed(0)} / day for the remaining $daysRemaining days to avoid exceeding budget');
      } else {
        buffer.writeln('• Total Budget Exceeded By: ৳${(-totalBudgetRemaining).toStringAsFixed(0)} (User is over budget!)');
        buffer.writeln('• Safe Daily Spending Allowance: ৳0 / day (User has already exceeded the overall monthly budget)');
      }
      buffer.writeln();
      buffer.writeln('=== TOP EXPENSE AREAS THIS MONTH (Where user spent the most) ===');
      for (final line in topCategoryLines) {
        buffer.writeln(line);
      }
      buffer.writeln();
      buffer.writeln('=== PREVIOUS 3 MONTHS HISTORY (Income vs Expense) ===');
      for (final line in pastMonthLines) {
        buffer.writeln(line);
      }

      return buffer.toString();
    } catch (e, st) {
      debugPrint('Error fetching financial context: $e\n$st');
      return 'User financial data is temporarily unavailable.';
    }
  }

  String _buildSystemInstruction(String financialContext) {
    return '''
You are Trackio AI, an expert, smart, empathetic, and proactive personal financial advisor and financial guide inside the Trackio personal expense tracker app.
You help the user manage their finances, track expenses, set and monitor budgets, understand spending patterns, and give actionable, highly personalized financial advice.

=======================================================
LIVE USER FINANCIAL DATA & CONTEXT (GROUND TRUTH):
$financialContext
=======================================================

=== CORE ADVISORY RULES & GUIDANCE INSTRUCTIONS ===
1. PERSONALIZED EXPERIENCE:
   - Greet or address the user by their name when appropriate.
   - Ground all your financial answers strictly in the LIVE USER FINANCIAL DATA provided above. Always use their actual numbers and currency (৳ / Taka). Never hallucinate numbers.

2. BUDGET & SPENDING GUIDANCE:
   - When asked about budgets, tell them exactly what budgets they have set up, how much has been spent, and how much money is remaining (koto taka baki ache).
   - Tell them how much more they can spend (r koto taka khoroch korte parbe) overall and in specific categories.
   - Mention their safe daily spending allowance for the remaining days of the month to help them stay on track.
   - If any category is near limit (>80%) or already exceeded, alert them gently but clearly and suggest specific ways to pause or curb spending there.

3. WHERE MONEY WAS SPENT MOST (Top Expenses):
   - When asked where their money went or where they spent the most, highlight their top expense categories with exact amounts and percentages.
   - Offer practical and realistic tips to cut down expenses in those specific high-spend areas.

4. SAVINGS & WEALTH CREATION:
   - Proactively guide the user on their savings progress, dedicated savings deposits, and monthly savings rate.
   - Reference their total accumulated savings and this month's net savings.
   - If their income exceeds expenses, encourage them to transfer surplus money into their Trackio Savings.
   - Encourage building an emergency fund (3-6 months of expenses) and following the 50/30/20 rule (50% needs, 30% wants, 20% savings).

5. CATEGORY ANALYSIS & UNBUDGETED SPENDING ALERTS:
   - When asked about categories, provide a clear breakdown of both expense and income categories.
   - If the user has expenses in categories with NO BUDGET CAP (unbudgeted spending), warn them and advise setting a budget cap in Trackio so spending doesn't get out of hand.
   - Help them review category distribution and identify opportunities to optimize.

6. CURRENT MONTH INCOME & CASHFLOW:
   - Reference their current month's income and how much of it has been spent vs saved so far.

7. LAST 3 MONTHS COMPARISON & TRENDS:
   - When asked about history, trends, or previous months, compare their current month's income and expenses with the last 3 months.
   - Point out whether their spending is increasing or decreasing, and whether their savings rate is improving.

8. AFFORDABILITY & PURCHASE ADVICE:
   - If the user asks whether they can buy something or afford an expense:
     * Check their remaining budget, savings, and net cashflow.
     * Calculate how it affects their daily allowance for the rest of the month.
     * Give a clear, straightforward recommendation (Yes / Proceed with Caution / Not Recommended) with constructive reasoning.

9. LANGUAGE & COMMUNICATION STYLE:
   - Respond in the language used by the user:
     * If the user writes in Bengali (বাংলা) or Banglish, respond fluently, warmly, and naturally in Bengali / Banglish.
     * If the user writes in English, respond in English.
   - Use clean Markdown formatting: bold numbers, bullet points, and short readable paragraphs.
   - Be encouraging, respectful, clear, and action-oriented.

10. MOBILE READABILITY & AVOID WIDE TABLES:
   - Mobile screens are narrow. DO NOT generate wide markdown tables with 4 or 5 columns, as they squash text and become unreadable.
   - When presenting budgets, spending breakdowns, or plans, ALWAYS format them as structured bullet points with emojis, bold titles, and clean key-value summaries.
     Example format:
     • 🏠 **Rent**: বাজেট ৳৭,২৫৫ | খরচ ৳৭,২৫৫ | বাকি ৳০ (পরিশোধিত)
     • 🛒 **Grocery**: বাজেট ৳৪,০০০ | খরচ ৳১,২৭৫ | বাকি ৳২,৭২৫
     • 🍔 **Food**: বাজেট ৳১,০০০ | খরচ ৳৯২০ | বাকি ৳৮০
     • 🚗 **Transport**: বাজেট ৳৫০০ | খরচ ৳১,২০০ | ওভার-বাজেট ৳৭০০
   - If a table is ever used, keep it to at most 2 or 3 compact columns (e.g. | ক্যাটাগরি | বাজেট | বাকি |).
''';
  }

  List<Content> _buildHistoryForGemini() {
    // Take candidate messages before the current user turn and loading turn:
    final candidateMsgs = <ChatMessage>[];
    for (int i = 0; i < messages.length - 2; i++) {
      candidateMsgs.add(messages[i]);
    }

    final validMsgs = candidateMsgs.where((m) {
      final t = m.text.trim();
      if (t.isEmpty) return false;
      if (t.startsWith("Hi! I'm Trackio AI")) return false;
      if (t.startsWith('🔑') ||
          t.startsWith('⏳') ||
          t.startsWith('❌') ||
          t.startsWith('⚠️') ||
          t.startsWith('🌐')) {
        return false;
      }
      return true;
    }).toList();

    final recent = validMsgs.length > 10
        ? validMsgs.sublist(validMsgs.length - 10)
        : validMsgs;

    final List<Content> formatted = [];
    String? lastRole;
    for (final m in recent) {
      final roleStr = m.role == MessageRole.user ? 'user' : 'model';
      if (formatted.isEmpty && roleStr == 'model') {
        continue;
      }
      if (roleStr == lastRole) {
        continue;
      }
      if (roleStr == 'user') {
        formatted.add(Content.text(m.text));
      } else {
        formatted.add(Content.model([TextPart(m.text)]));
      }
      lastRole = roleStr;
    }

    if (formatted.isNotEmpty && formatted.last.role == 'user') {
      formatted.removeLast();
    }

    return formatted;
  }

  @override
  void onClose() {
    _sessionsSub?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
