List<String>? splitQr(String qr) {
  final parts = qr.split(':');
  return parts.length == 4 ? parts : null;
}