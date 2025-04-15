import 'upload_validation_mock_data.dart';

void runUploadValidationMockData() {
  final uploader = ValidationMockDataUploader();
  uploader.uploadMockData().then((_) {
    print('Proceso de subida de validaciones completado');
  }).catchError((error) {
    print('Error durante la subida de validaciones: $error');
  });
} 