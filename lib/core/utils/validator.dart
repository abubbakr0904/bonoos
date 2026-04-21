
class Validator {
  static String? fieldChecker({required String value, required message}) {
    if (value.toString().trim().isEmpty) {
      return "$message bo'sh bolmasin";
    }
    return null;
  }

  static String? phoneChecker({required String value, required message}) {
    if (value.toString().trim().isEmpty) {
      return "$message bo'sh bolmasin";
    } else if (value.length != 14) {
      return "To'g'ri kiriting iltimos";
    }
    return null;
  }
}
