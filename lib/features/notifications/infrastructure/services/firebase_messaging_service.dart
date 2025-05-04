import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Solicitar permisos para iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obtener el token FCM
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Configurar el manejo de mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Mensaje recibido en primer plano: ${message.notification?.title}');
      // Aquí puedes manejar la notificación en primer plano
    });

    // Configurar el manejo de mensajes cuando la app está en segundo plano
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

// Esta función debe estar fuera de la clase y ser top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Mensaje recibido en segundo plano: ${message.notification?.title}');
  // Aquí puedes manejar la notificación en segundo plano
} 