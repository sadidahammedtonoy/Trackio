import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../Controller/ai_chat_controller.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class AiChatPage extends StatelessWidget {
  AiChatPage({super.key});

  final AiChatController controller = Get.put(AiChatController());

  @override
  Widget build(BuildContext context) {
    final isTab = _isTablet(context);

    return background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(isTab),
        endDrawer: _ChatHistoryDrawer(controller: controller, isTab: isTab),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(child: _ChatList(controller: controller, isTab: isTab)),
              _SuggestionChips(controller: controller, isTab: isTab),
              _InputBar(controller: controller, isTab: isTab),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isTab) {
    final double avatarSize = isTab ? 36.0 : 36.r;
    final double iconSize = isTab ? 18.0 : 18.sp;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: -12,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowLeft01,
          color: Colors.black,
          size: isTab ? 22.0 : 22.sp,
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cyan avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(80),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          SizedBox(width: isTab ? 10.0 : 10.w),
          // Title + online status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Trackio AI',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: isTab ? 16.0 : 16.sp,
                  fontFamily: 'Montserrat',
                  height: 1.2,
                ),
              ),
              Text(
                'Your personal finance assistant',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: isTab ? 10.0 : 10.sp,
                  fontFamily: 'Montserrat',
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedMenu02,
              color: Colors.black87,
              size: isTab ? 22.0 : 22.sp,
            ),
            tooltip: 'Chat Sessions',
          ),
        ),
      ],
    );
  }
}

// ─── Chat List ────────────────────────────────────────────────────────────────

class _ChatList extends StatelessWidget {
  final AiChatController controller;
  final bool isTab;

  const _ChatList({required this.controller, required this.isTab});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msgs = controller.messages;
      return ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: isTab ? 24.0 : 16.w,
          vertical: isTab ? 16.0 : 12.h,
        ),
        itemCount: msgs.length,
        itemBuilder: (_, i) {
          final msg = msgs[i];
          return _MessageBubble(
            message: msg,
            controller: controller,
            isTab: isTab,
          );
        },
      );
    });
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final AiChatController controller;
  final bool isTab;

  const _MessageBubble({
    required this.message,
    required this.controller,
    required this.isTab,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: EdgeInsets.only(bottom: isTab ? 12.0 : 12.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _AiAvatar(isTab: isTab),
            SizedBox(width: isTab ? 8.0 : 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _BubbleContent(
                  message: message,
                  isUser: isUser,
                  isTab: isTab,
                ),
                if (!isUser && message.actionPrompt != null)
                  _MessageActionPrompt(
                    message: message,
                    controller: controller,
                    isTab: isTab,
                  ),
                SizedBox(height: isTab ? 4.0 : 4.h),
                if (!message.isLoading)
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: isTab ? 9.0 : 9.sp,
                      fontFamily: 'Montserrat',
                    ),
                  ),
              ],
            ),
          ),
          if (isUser) SizedBox(width: isTab ? 8.0 : 8.w),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── Message Action Suggestion Prompt (Yes / No) ──────────────────────────────

class _MessageActionPrompt extends StatelessWidget {
  final ChatMessage message;
  final AiChatController controller;
  final bool isTab;

  const _MessageActionPrompt({
    required this.message,
    required this.controller,
    required this.isTab,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (message.isActionHandled.value) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.only(top: isTab ? 8.0 : 8.h),
        padding: EdgeInsets.symmetric(
          horizontal: isTab ? 14.0 : 12.w,
          vertical: isTab ? 10.0 : 10.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withAlpha(60),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isTab ? 4.0 : 4.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                    size: isTab ? 14.0 : 13.sp,
                  ),
                ),
                SizedBox(width: isTab ? 8.0 : 8.w),
                Flexible(
                  child: Text(
                    message.actionPrompt ?? 'Do you want to add budgets?',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: isTab ? 13.0 : 12.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTab ? 10.0 : 8.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Yes button (routes to target page)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.handleActionResponse(message, true),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTab ? 18.0 : 16.w,
                        vertical: isTab ? 8.0 : 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: isTab ? 15.0 : 14.sp,
                          ),
                          SizedBox(width: isTab ? 5.0 : 4.w),
                          Text(
                            'Yes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTab ? 12.0 : 11.5.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isTab ? 10.0 : 8.w),
                // No button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        controller.handleActionResponse(message, false),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTab ? 18.0 : 16.w,
                        vertical: isTab ? 8.0 : 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            color: Colors.black54,
                            size: isTab ? 15.0 : 14.sp,
                          ),
                          SizedBox(width: isTab ? 5.0 : 4.w),
                          Text(
                            'No',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: isTab ? 12.0 : 11.5.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _AiAvatar extends StatelessWidget {
  final bool isTab;

  const _AiAvatar({required this.isTab});

  @override
  Widget build(BuildContext context) {
    final size = isTab ? 28.0 : 28.r;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  final bool isTab;

  const _BubbleContent({
    required this.message,
    required this.isUser,
    required this.isTab,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width *
        (isUser
            ? (isTab ? 0.65 : 0.75)
            : (isTab ? 0.74 : 0.80));

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: isUser
              ? const Radius.circular(20)
              : const Radius.circular(4),
          bottomRight: isUser
              ? const Radius.circular(4)
              : const Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isTab ? 16.0 : 14.w,
        vertical: isTab ? 12.0 : 10.h,
      ),
      child: message.isLoading
          ? _TypingIndicator()
          : isUser
              ? Text(
                  message.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTab ? 14.0 : 13.sp,
                    fontFamily: 'Montserrat',
                    height: 1.5,
                  ),
                )
              : Theme(
                  // Override platform to android so Flutter's Scrollbar uses Material scrollbar,
                  // allowing ScrollbarTheme with thickness 0.0 to completely suppress the thumb on iOS
                  data: Theme.of(context).copyWith(platform: TargetPlatform.android),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: ScrollbarTheme(
                      data: const ScrollbarThemeData(
                        thickness: WidgetStatePropertyAll(0.0),
                        thumbVisibility: WidgetStatePropertyAll(false),
                        trackVisibility: WidgetStatePropertyAll(false),
                        interactive: false,
                      ),
                      child: MarkdownBody(
                        data: message.text,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: Colors.black87,
                            fontSize: isTab ? 14.0 : 13.sp,
                            fontFamily: 'Montserrat',
                            height: 1.5,
                          ),
                          strong: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: isTab ? 14.0 : 13.sp,
                            fontFamily: 'Montserrat',
                          ),
                          em: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                            fontFamily: 'Montserrat',
                          ),
                          code: TextStyle(
                            backgroundColor: Colors.grey.shade100,
                            fontFamily: 'monospace',
                            fontSize: isTab ? 12.0 : 11.sp,
                          ),
                          h1: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: isTab ? 18.0 : 17.sp,
                            fontFamily: 'Montserrat',
                          ),
                          h2: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: isTab ? 16.0 : 15.sp,
                            fontFamily: 'Montserrat',
                          ),
                          h3: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: isTab ? 14.0 : 13.5.sp,
                            fontFamily: 'Montserrat',
                          ),
                          listBullet: TextStyle(
                            color: Colors.black87,
                            fontSize: isTab ? 14.0 : 13.sp,
                            fontFamily: 'Montserrat',
                          ),
                          tableColumnWidth: const IntrinsicColumnWidth(),
                          tablePadding: EdgeInsets.only(
                            top: isTab ? 6.0 : 4.h,
                            bottom: isTab ? 10.0 : 8.h,
                          ),
                          tableCellsPadding: EdgeInsets.symmetric(
                            horizontal: isTab ? 8.0 : 6.w,
                            vertical: isTab ? 6.0 : 5.h,
                          ),
                          tableBorder: TableBorder.all(
                            color: Colors.grey.shade300,
                            width: 1,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          tableHead: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: isTab ? 11.5 : 10.5.sp,
                            fontFamily: 'Montserrat',
                          ),
                          tableBody: TextStyle(
                            color: Colors.black87,
                            fontSize: isTab ? 11.0 : 10.0.sp,
                            fontFamily: 'Montserrat',
                          ),
                          tableScrollbarThumbVisibility: false,
                          horizontalRuleDecoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                            ),
                          ),
                          blockSpacing: isTab ? 10.0 : 8.h,
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

// ─── Typing Indicator ─────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    _animations = List.generate(3, (i) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(
          parent: _controllers[i],
          curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
        ),
      );
    });

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (ctx, child) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            transform:
                Matrix4.translationValues(0, _animations[i].value, 0),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.cyan.withAlpha(200),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Suggestion Chips ────────────────────────────────────────────────────────

class _SuggestionChips extends StatelessWidget {
  final AiChatController controller;
  final bool isTab;

  const _SuggestionChips({required this.controller, required this.isTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isTab ? 20.0 : 16.w,
            top: isTab ? 4.0 : 2.h,
            bottom: isTab ? 4.0 : 3.h,
          ),
          child: Text(
            'Quick questions 👇',
            style: TextStyle(
              color: Colors.black54,
              fontSize: isTab ? 12.0 : 11.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: isTab ? 38.0 : 36.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isTab ? 16.0 : 14.w),
            itemCount: AiChatController.suggestions.length,
            separatorBuilder: (_, idx) => SizedBox(width: isTab ? 8.0 : 8.w),
            itemBuilder: (context, i) {
              final s = AiChatController.suggestions[i];
              return _SuggestionChip(
                label: s['label']!,
                onTap: () => controller.sendMessage(
                  s['displayText'] ?? s['label']!,
                  displayText: s['displayText'],
                  predefinedAnswer: s['answer'],
                  actionPrompt: s['actionPrompt'],
                  actionRoute: s['actionRoute'],
                ),
                isTab: isTab,
              );
            },
          ),
        ),
        SizedBox(height: isTab ? 4.0 : 2.h),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isTab;

  const _SuggestionChip({
    required this.label,
    required this.onTap,
    required this.isTab,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTab ? 14.0 : 12.w,
          vertical: isTab ? 7.0 : 6.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTab ? 18.0 : 18.r),
          border: Border.all(
            color: Colors.cyan.withAlpha(80),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: isTab ? 12.0 : 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Input Bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final AiChatController controller;
  final bool isTab;

  const _InputBar({required this.controller, required this.isTab});

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Close keyboard pill button above input bar
          if (isKeyboardOpen)
            Padding(
              padding: EdgeInsets.only(
                right: isTab ? 20.0 : 16.w,
                bottom: isTab ? 6.0 : 4.h,
              ),
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTab ? 12.0 : 10.w,
                    vertical: isTab ? 5.0 : 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.keyboard_hide_rounded,
                        size: isTab ? 16.0 : 15.sp,
                        color: Colors.black54,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Close Keyboard',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: isTab ? 11.5 : 10.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Container(
            padding: EdgeInsets.fromLTRB(
              isTab ? 20.0 : 16.w,
              isTab ? 4.0 : 2.h,
              isTab ? 20.0 : 16.w,
              isTab ? 10.0 : 8.h,
            ),
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F6),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: Colors.black.withAlpha(20)),
                    ),
                    child: TextField(
                      controller: controller.textController,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: isTab ? 14.0 : 13.sp,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask me anything about Trackio...',
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: isTab ? 13.0 : 12.sp,
                          fontFamily: 'Montserrat',
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTab ? 18.0 : 16.w,
                          vertical: isTab ? 12.0 : 12.h,
                        ),
                        suffixIcon: isKeyboardOpen
                            ? IconButton(
                                icon: Icon(
                                  Icons.keyboard_hide_rounded,
                                  color: Colors.black45,
                                  size: isTab ? 20.0 : 18.sp,
                                ),
                                tooltip: 'Close keyboard',
                                onPressed: () => FocusScope.of(context).unfocus(),
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onSubmitted: (val) => controller.sendMessage(val),
                    ),
                  ),
                ),
                SizedBox(width: isTab ? 10.0 : 10.w),
                // Send button
                Obx(() {
                  final isTyping = controller.isTyping.value;
                  return GestureDetector(
                    onTap: isTyping
                        ? null
                        : () => controller
                            .sendMessage(controller.textController.text),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isTab ? 46.0 : 46.r,
                      height: isTab ? 46.0 : 46.r,
                      decoration: BoxDecoration(
                        color:
                            isTyping ? Colors.grey.shade300 : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: isTyping
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(80),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Icon(
                        isTyping
                            ? Icons.hourglass_empty_rounded
                            : Icons.send_rounded,
                        color: isTyping ? Colors.black38 : Colors.white,
                        size: isTab ? 20.0 : 20.sp,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat History Drawer ──────────────────────────────────────────────────────

class _ChatHistoryDrawer extends StatefulWidget {
  final AiChatController controller;
  final bool isTab;

  const _ChatHistoryDrawer({required this.controller, required this.isTab});

  @override
  State<_ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends State<_ChatHistoryDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxString _selectedFilter = 'All'.obs;
  final RxBool _isNewestFirst = true.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AiSession> _getFilteredSessions() {
    var list = widget.controller.sessions.toList();

    // Search query filter
    final q = _searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((s) => s.title.toLowerCase().contains(q)).toList();
    }

    // Time filter
    final now = DateTime.now();
    if (_selectedFilter.value == 'Today') {
      list = list.where((s) {
        final d = s.updatedAt;
        return d.year == now.year && d.month == now.month && d.day == now.day;
      }).toList();
    } else if (_selectedFilter.value == 'This Week') {
      final weekAgo = now.subtract(const Duration(days: 7));
      list = list.where((s) => s.updatedAt.isAfter(weekAgo)).toList();
    } else if (_selectedFilter.value == 'This Month') {
      list = list.where((s) {
        final d = s.updatedAt;
        return d.year == now.year && d.month == now.month;
      }).toList();
    }

    // Sorting
    list.sort((a, b) {
      return _isNewestFirst.value
          ? b.updatedAt.compareTo(a.updatedAt)
          : a.updatedAt.compareTo(b.updatedAt);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isTab = widget.isTab;
    final width = isTab ? 420.0 : MediaQuery.of(context).size.width * 0.88;

    return Drawer(
      width: width,
      backgroundColor: const Color(0xFFF9FAFB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top pull handle pill
            Center(
              child: Container(
                width: isTab ? 44.0 : 38.w,
                height: 4.5,
                margin: EdgeInsets.only(top: 8.h, bottom: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(30),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTab ? 20.0 : 16.w,
                vertical: isTab ? 8.0 : 6.h,
              ),
              child: Row(
                children: [
                  Container(
                    width: isTab ? 44.0 : 42.r,
                    height: isTab ? 44.0 : 42.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(70),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSparkles,
                        color: Colors.white,
                        size: isTab ? 22.0 : 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: isTab ? 12.0 : 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Chat Sessions',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w800,
                            fontSize: isTab ? 18.0 : 17.sp,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Your conversations, anytime',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: isTab ? 12.0 : 11.5.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: isTab ? 36.0 : 34.r,
                      height: isTab ? 36.0 : 34.r,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          color: Colors.black54,
                          size: isTab ? 18.0 : 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // "+ New Chat" Button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTab ? 20.0 : 16.w,
                vertical: isTab ? 8.0 : 6.h,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.controller.createNewSession();
                  },
                  borderRadius: BorderRadius.circular(26),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(26),

                    ),
                    child: Container(
                      height: isTab ? 50.0 : 48.h,
                      padding:
                          EdgeInsets.symmetric(horizontal: isTab ? 20.0 : 18.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedAdd01,
                            color: Colors.white,
                            size: isTab ? 20.0 : 19.sp,
                          ),
                          SizedBox(width: isTab ? 8.0 : 7.w),
                          Text(
                            'New Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTab ? 15.0 : 14.5.sp,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTab ? 20.0 : 16.w,
                vertical: isTab ? 6.0 : 5.h,
              ),
              child: Container(
                height: isTab ? 44.0 : 42.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch02,
                      color: Colors.black38,
                      size: isTab ? 18.0 : 17.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => _searchQuery.value = val,
                        cursorColor: AppColors.primary,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(
                          fontSize: isTab ? 13.0 : 12.5.sp,
                          fontFamily: 'Montserrat',
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search chat sessions...',
                          hintStyle: TextStyle(
                            color: Colors.black38,
                            fontSize: isTab ? 13.0 : 12.5.sp,
                            fontFamily: 'Montserrat',
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Obx(() {
                      if (_searchQuery.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _searchQuery.value = '';
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 16.sp,
                          color: Colors.black38,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Filter Chips (All, Today, This Week, This Month)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTab ? 20.0 : 16.w,
                vertical: isTab ? 6.0 : 5.h,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() {
                  final filters = ['All', 'Today', 'This Week', 'This Month'];
                  return Row(
                    children: filters.map((f) {
                      final isSelected = _selectedFilter.value == f;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: GestureDetector(
                          onTap: () => _selectedFilter.value = f,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.symmetric(
                              horizontal: isTab ? 16.0 : 14.w,
                              vertical: isTab ? 7.0 : 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withAlpha(28)
                                  : const Color(0xFFF1F3F5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary.withAlpha(90)
                                    : Colors.transparent,
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.black54,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: isTab ? 12.0 : 11.5.sp,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
            ),

            // Subheader: RECENT SESSIONS & Sort Dropdown
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTab ? 20.0 : 16.w,
                vertical: isTab ? 8.0 : 6.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT SESSIONS',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: isTab ? 11.0 : 10.5.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _isNewestFirst.toggle(),
                    child: Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedSorting05,
                            color: Colors.black45,
                            size: isTab ? 14.0 : 13.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _isNewestFirst.value
                                ? 'Newest first'
                                : 'Oldest first',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: isTab ? 11.0 : 10.5.sp,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: isTab ? 16.0 : 15.sp,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sessions List
            Expanded(
              child: Obx(() {
                if (widget.controller.isLoadingSessions.value &&
                    widget.controller.sessions.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final displayed = _getFilteredSessions();

                if (displayed.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedBubbleChat,
                          size: isTab ? 40.0 : 36.sp,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'No sessions found',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: isTab ? 13.0 : 12.sp,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTab ? 20.0 : 16.w,
                    vertical: 4.h,
                  ),
                  itemCount: displayed.length,
                  separatorBuilder: (_, idx) =>
                      SizedBox(height: isTab ? 10.0 : 8.h),
                  itemBuilder: (context, index) {
                    final session = displayed[index];
                    final isSelected =
                        widget.controller.currentSession.value?.id ==
                            session.id;

                    return _SessionTile(
                      session: session,
                      index: index,
                      isSelected: isSelected,
                      isTab: isTab,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.controller.switchSession(session);
                      },
                      onRename: () => _showRenameDialog(
                        context,
                        widget.controller,
                        session,
                      ),
                      onDelete: () => _showDeleteDialog(
                        context,
                        widget.controller,
                        session,
                      ),
                    );
                  },
                );
              }),
            ),

            // Bottom Info Card (Keep your ideas...)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTab ? 20.0 : 16.w,
                vertical: isTab ? 10.0 : 8.h,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isTab ? 14.0 : 12.h,
                  horizontal: isTab ? 16.0 : 14.w,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0F2FE)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Illustration chat bubbles
                    SizedBox(
                      width: 48,
                      height: 32,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 4,
                            top: 2,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: Color(0xFF60A5FA),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.more_horiz_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 6,
                            bottom: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(120),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedSparkles,
                              color: const Color(0xFF60A5FA),
                              size: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Keep your ideas, questions\nand conversations organized.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: isTab ? 12.5 : 12.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Start a new chat to get going!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: isTab ? 11.0 : 10.5.sp,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    AiChatController controller,
    AiSession session,
  ) {
    final textEditController = TextEditingController(text: session.title);

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Rename Chat',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: textEditController,
          autofocus: true,
          style: const TextStyle(fontFamily: 'Montserrat'),
          decoration: InputDecoration(
            hintText: 'Enter chat title',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontFamily: 'Montserrat',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 1.8),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    final newTitle = textEditController.text.trim();
                    if (newTitle.isNotEmpty) {
                      controller.updateSessionTitle(session.id, newTitle);
                    }
                    Get.back();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AiChatController controller,
    AiSession session,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Chat',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${session.title}"? This cannot be undone.',
          style: const TextStyle(fontFamily: 'Montserrat'),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    controller.deleteSession(session.id);
                    Get.back();
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Session Tile ─────────────────────────────────────────────────────────────

class _SessionIconTheme {
  final Color bg;
  final Color color;
  final List<List<dynamic>> icon;

  const _SessionIconTheme({
    required this.bg,
    required this.color,
    required this.icon,
  });
}

class _SessionTile extends StatelessWidget {
  final AiSession session;
  final int index;
  final bool isSelected;
  final bool isTab;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _SessionTile({
    required this.session,
    required this.index,
    required this.isSelected,
    required this.isTab,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  static const List<_SessionIconTheme> _themes = [
    _SessionIconTheme(
      bg: Color(0xFFE0F7FA),
      color: Colors.cyan,
      icon: HugeIcons.strokeRoundedBubbleChat,
    ),
    _SessionIconTheme(
      bg: Color(0xFFF3E8FF),
      color: Color(0xFF9333EA),
      icon: HugeIcons.strokeRoundedBulb,
    ),
    _SessionIconTheme(
      bg: Color(0xFFE0F2FE),
      color: Color(0xFF0284C7),
      icon: HugeIcons.strokeRoundedUserGroup,
    ),
    _SessionIconTheme(
      bg: Color(0xFFDCFCE7),
      color: Color(0xFF16A34A),
      icon: HugeIcons.strokeRoundedStickyNote01,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = _themes[index % _themes.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTab ? 14.0 : 12.w,
            vertical: isTab ? 12.0 : 11.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : const Color(0xFFF1F3F5),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon container with pastel background
              Container(
                width: isTab ? 42.0 : 40.r,
                height: isTab ? 42.0 : 40.r,
                decoration: BoxDecoration(
                  color: theme.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: theme.icon,
                    color: theme.color,
                    size: isTab ? 20.0 : 19.sp,
                  ),
                ),
              ),
              SizedBox(width: isTab ? 12.0 : 10.w),

              // Title and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: isTab ? 13.5 : 13.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      DateFormat('dd MMM, hh:mm a').format(session.updatedAt),
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: isTab ? 11.0 : 10.5.sp,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),

              // Rename action button
              GestureDetector(
                onTap: onRename,
                child: Container(
                  width: isTab ? 34.0 : 32.r,
                  height: isTab ? 34.0 : 32.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedEdit02,
                      color: Colors.black54,
                      size: isTab ? 16.0 : 15.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTab ? 8.0 : 8.w),

              // Delete action button
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: isTab ? 34.0 : 32.r,
                  height: isTab ? 34.0 : 32.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedDelete04,
                      color: const Color(0xFFEF4444),
                      size: isTab ? 16.0 : 15.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
