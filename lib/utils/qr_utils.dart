/// Temporary function to extract qr token from given qr
/// Returns null if format is invalid
/// NOTE: Replace this with QrValidator.validate once responsibilities are decoupled
String? extractQrToken(String qr) {
  final parts = qr.split(':');
  if (parts.length != 4 || parts[0] != 'PROJE' || parts[1] != 'MEM') return null;
  return parts[3];
}