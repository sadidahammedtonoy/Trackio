import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/CalculatorController.dart';

class CalculatorDialog extends StatelessWidget {
  CalculatorDialog({super.key});

  final c = Get.put(CalculatorController());

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row
              Row(
                children: [
                  const Text(
                    "Calculator",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              // Display
              Obx(() => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      c.expr.value.isEmpty ? "0" : c.expr.value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.result.value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: c.result.value == 'Error' ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 12),

              // Buttons grid
              _grid(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _grid() {
    final buttons = <_CalcBtn>[
      _CalcBtn("AC", onTap: c.clearAll, isTop: true),
      _CalcBtn("⌫", onTap: c.backspace, isTop: true),
      _CalcBtn("( ", onTap: () => c.input("("), isTop: true),
      _CalcBtn(" )", onTap: () => c.input(")"), isTop: true),

      _CalcBtn("7", onTap: () => c.input("7")),
      _CalcBtn("8", onTap: () => c.input("8")),
      _CalcBtn("9", onTap: () => c.input("9")),
      _CalcBtn("÷", onTap: () => c.input("÷"), isOp: true),

      _CalcBtn("4", onTap: () => c.input("4")),
      _CalcBtn("5", onTap: () => c.input("5")),
      _CalcBtn("6", onTap: () => c.input("6")),
      _CalcBtn("×", onTap: () => c.input("×"), isOp: true),

      _CalcBtn("1", onTap: () => c.input("1")),
      _CalcBtn("2", onTap: () => c.input("2")),
      _CalcBtn("3", onTap: () => c.input("3")),
      _CalcBtn("-", onTap: () => c.input("-"), isOp: true),

      _CalcBtn("±", onTap: c.toggleSign),
      _CalcBtn("0", onTap: () => c.input("0")),
      _CalcBtn(".", onTap: () => c.input(".")),
      _CalcBtn("+", onTap: () => c.input("+"), isOp: true),

      _CalcBtn("%", onTap: c.percent),
      _CalcBtn("=", onTap: c.evaluate, isEqual: true, span: 3),
    ];

    // Manual layout: 4 columns, last row has "=" spanning 3 cells
    return Column(
      children: [
        _row(buttons.sublist(0, 4)),
        _row(buttons.sublist(4, 8)),
        _row(buttons.sublist(8, 12)),
        _row(buttons.sublist(12, 16)),
        _row(buttons.sublist(16, 20)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _btn(buttons[20])),
            const SizedBox(width: 8),
            Expanded(flex: 3, child: _btn(buttons[21], equalWide: true)),
          ],
        ),
      ],
    );
  }

  Widget _row(List<_CalcBtn> rowBtns) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          for (int i = 0; i < rowBtns.length; i++) ...[
            Expanded(child: _btn(rowBtns[i])),
            if (i != rowBtns.length - 1) const SizedBox(width: 8),
          ]
        ],
      ),
    );
  }

  Widget _btn(_CalcBtn b, {bool equalWide = false}) {
    final bg = b.isEqual
        ? Colors.black
        : b.isOp
        ? Colors.black.withOpacity(0.08)
        : b.isTop
        ? Colors.black.withOpacity(0.06)
        : Colors.white;

    final fg = b.isEqual ? Colors.white : Colors.black;

    return SizedBox(
      height: equalWide ? 52 : 48,
      child: InkWell(
        onTap: b.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
          ),
          child: Text(
            b.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: b.isEqual ? FontWeight.w800 : FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _CalcBtn {
  final String label;
  final VoidCallback onTap;
  final bool isOp;
  final bool isEqual;
  final bool isTop;
  final int span;

  _CalcBtn(
      this.label, {
        required this.onTap,
        this.isOp = false,
        this.isEqual = false,
        this.isTop = false,
        this.span = 1,
      });
}
