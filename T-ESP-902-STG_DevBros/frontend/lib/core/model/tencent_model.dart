import 'dart:io';

class TencentRequest {

  TencentRequest({
    required this.imageFile,
    required this.itemType,
    required this.itemSubtype,
  });
  final File imageFile;
  final String itemType;
  final String itemSubtype;
}