import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorController extends GetxController {
  final expr = ''.obs;
  final result = '0'.obs;

  void clearAll() {
    expr.value = '';
    result.value = '0';
  }

  void backspace() {
    if (expr.value.isNotEmpty) {
      expr.value = expr.value.substring(0, expr.value.length - 1);
    }
  }

  void input(String v) {
    // prevent double operators like ++, ** etc (simple guard)
    if (expr.value.isEmpty) {
      if (_isOperator(v) && v != '-') return; // allow starting with minus
      if (v == ')') return;
    }

    // avoid ".."
    if (v == '.' && expr.value.endsWith('.')) return;

    // avoid "++" or "*/" etc
    if (_isOperator(v) &&
        expr.value.isNotEmpty &&
        _isOperator(expr.value.characters.last)) {
      // replace last operator with new operator
      expr.value = expr.value.substring(0, expr.value.length - 1) + v;
      return;
    }

    expr.value += v;
  }

  void toggleSign() {
    // Toggle sign of the last number chunk
    if (expr.value.isEmpty) {
      expr.value = '-';
      return;
    }

    final s = expr.value;

    // find last operator position
    int i = s.length - 1;
    while (i >= 0 && !_isOperator(s[i]) && s[i] != '(' && s[i] != ')') {
      i--;
    }

    final start = i + 1;
    if (start >= s.length) return;

    final lastChunk = s.substring(start);

    // if chunk already starts with '-', remove it; else add '-'
    if (start > 0 &&
        s[start - 1] == '-' &&
        (start - 2 < 0 || _isOperator(s[start - 2]) || s[start - 2] == '(')) {
      // remove the unary minus before number
      expr.value = s.substring(0, start - 1) + lastChunk;
    } else {
      expr.value = '${s.substring(0, start)}-$lastChunk';
    }
  }

  void percent() {
    // Convert last number to (number/100)
    if (expr.value.isEmpty) return;

    final s = expr.value;

    int i = s.length - 1;
    while (i >= 0 && !_isOperator(s[i]) && s[i] != '(' && s[i] != ')') {
      i--;
    }

    final start = i + 1;
    if (start >= s.length) return;

    final numStr = s.substring(start);
    final value = double.tryParse(numStr);
    if (value == null) return;

    final pct = value / 100.0;
    expr.value = s.substring(0, start) + _pretty(pct);
  }

  void evaluate() {
    if (expr.value.trim().isEmpty) return;

    try {
      // Convert UI operators to parser operators
      String e = expr.value.replaceAll('×', '*').replaceAll('÷', '/');

      // Replace any trailing operator
      if (e.isNotEmpty && _isOperator(e[e.length - 1])) {
        e = e.substring(0, e.length - 1);
      }

      final parser = Parser();
      final exp = parser.parse(e);
      final ctx = ContextModel();

      final val = exp.evaluate(EvaluationType.REAL, ctx);
      result.value = _pretty(val);
    } catch (_) {
      result.value = 'Error';
    }
  }

  bool _isOperator(String c) =>
      c == '+' || c == '-' || c == '×' || c == '÷' || c == '*' || c == '/';

  String _pretty(num v) {
    // remove .0
    final s = v.toString();
    if (s.contains('.') && s.endsWith('0')) {
      final d = double.tryParse(s);
      if (d != null) {
        final fixed = d.toStringAsFixed(10);
        return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
      }
    }
    return s;
  }
}
