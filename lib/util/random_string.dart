import "dart:math";

String generateFileName({int length = 10, String extension = 'png'}) {
  // Generate random alphanumeric string
  final random = Random();
  const String chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
  final fileName = String.fromCharCodes(List.generate(
      length, (index) => chars.codeUnitAt(random.nextInt(chars.length))));

  return '$fileName.$extension';
}
