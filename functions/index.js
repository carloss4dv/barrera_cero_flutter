const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Función que se activa cuando se actualiza un marcador
exports.onMarkerUpdate = functions.firestore
  .document("markers/{markerId}")
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const previousData = change.before.data();
    const markerId = context.params.markerId;

    // Verificar si los metadatos han cambiado
    if (JSON.stringify(newData.metadata) !==
        JSON.stringify(previousData.metadata)) {
      try {
        // Obtener el título y descripción del marcador
        const title = newData.title || "Marcador Actualizado";
        const description = newData.description ||
            "Se ha actualizado la información de un marcador";

        // Crear el mensaje de notificación
        const message = {
          notification: {
            title: title,
            body: description,
          },
          data: {
            markerId: markerId,
            type: "marker_update",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          topic: "marker_updates",
        };

        // Enviar la notificación
        const response = await admin.messaging().send(message);
        console.log("Notificación enviada:", response);
        return response;
      } catch (error) {
        console.error("Error al enviar la notificación:", error);
        throw error;
      }
    }
    return null;
  });

// Función para suscribir usuarios a notificaciones
exports.subscribeToTopic = functions.https.onCall(async (data, context) => {
  // Verificar autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "El usuario debe estar autenticado",
    );
  }

  const {topic} = data;
  if (!topic) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "El tema es requerido",
    );
  }

  try {
    await admin.messaging().subscribeToTopic([context.auth.uid], topic);
    return {success: true};
  } catch (error) {
    console.error("Error al suscribir al tema:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error al suscribir al tema",
    );
  }
});
