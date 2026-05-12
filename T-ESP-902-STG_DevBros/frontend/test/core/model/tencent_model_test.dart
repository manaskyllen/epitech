import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/tencent_model.dart'; // Ajuste l'import selon ton projet

void main() {
  group('TencentRequest Tests', () {
    test('should initialize with correct values', () {
      final file = File('path/to/image.png');
      
      final request = TencentRequest(
        imageFile: file,
        itemType: 'Top',
        itemSubtype: 'T-shirt',
      );

      expect(request.imageFile.path, 'path/to/image.png');
      expect(request.itemType, 'Top');
      expect(request.itemSubtype, 'T-shirt');
    });

    test('should maintain data integrity', () {
      final file = File('another/path/pic.jpg');
      
      final request = TencentRequest(
        imageFile: file,
        itemType: 'Shoes',
        itemSubtype: 'Sneakers',
      );

      expect(request.imageFile, isA<File>());
      expect(request.itemType, isNot('Top'));
    });
  });
}