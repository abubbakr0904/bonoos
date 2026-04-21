import 'package:flutter/services.dart';
import 'dart:math' as math;

class PriceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove non-digits from the input
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // If empty, return empty
    if (newText.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Convert to integer and format with thousand separators
    int value = int.parse(newText);
    String formattedText = _formatNumber(value);

    // Calculate cursor position
    int cursorOffset = newValue.selection.baseOffset;
    int oldLength = oldValue.text.replaceAll(',', '').length;
    int newLength = newText.length;
    int commasBeforeCursor = _countCommasBeforeCursor(
        formattedText, cursorOffset, oldLength, newLength);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: math.min(formattedText.length,
            cursorOffset + commasBeforeCursor),
      ),
    );
  }

  String _formatNumber(int number) {
    String digits = number.toString();
    StringBuffer buffer = StringBuffer();
    int length = digits.length;

    for (int i = 0; i < length; i++) {
      buffer.write(digits[i]);
      if (i < length - 1 && (length - i - 1) % 3 == 0) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  int _countCommasBeforeCursor(
      String formattedText, int cursorPosition, int oldLength, int newLength) {
    // Adjust cursor based on added/removed commas
    int commasInNewText =
        formattedText.substring(0, math.min(formattedText.length, cursorPosition)).split(',').length - 1;
    int commasInOldText =
    oldLength > 0 ? (oldLength - 1) ~/ 3 : 0;
    return commasInNewText - commasInOldText;
  }
}