import 'package:flutter/material.dart';
import 'upload_mock_data.dart';

void runUploadMockData() {
  final uploader = MockDataUploader();
  uploader.uploadMockData().then((_) {
    print('Proceso de subida completado');
  }).catchError((error) {
    print('Error durante la subida: $error');
  });
} 