# Guía de Pruebas - Barrera Cero

Este documento proporciona instrucciones detalladas para probar las funcionalidades implementadas en el primer sprint de Barrera Cero.

## Preparación del Entorno

1. Asegúrate de tener instalado Flutter y todas las dependencias requeridas:
   ```
   flutter doctor
   ```

2. Clona el repositorio y navega al directorio del proyecto:
   ```
   git clone https://github.com/tu-usuario/barrera-cero.git
   cd barrera-cero
   ```

3. Instala las dependencias:
   ```
   flutter pub get
   ```

4. Conecta un dispositivo físico o inicia un emulador/simulador.

5. Ejecuta la aplicación:
   ```
   flutter run
   ```

## Pruebas Funcionales

### 1. Visualización del Mapa

- **Objetivo**: Verificar que el mapa se cargue correctamente y sea interactivo.
- **Pasos**:
  1. Inicia la aplicación
  2. Verifica que se muestre el mapa centrado en Zaragoza (por defecto)
  3. Prueba hacer zoom (pellizcar con los dedos)
  4. Prueba desplazarte por el mapa (arrastrar)
- **Resultado esperado**: El mapa debe responder a las interacciones de manera fluida.

### 2. Localización del Usuario

- **Objetivo**: Verificar que la aplicación pueda obtener y mostrar la ubicación actual del usuario.
- **Pasos**:
  1. En la pantalla principal, presiona el botón de ubicación (icono de "mi ubicación")
  2. Acepta los permisos de ubicación si se solicitan
- **Resultado esperado**: El mapa debe centrarse en la ubicación actual del usuario.

### 3. Marcadores de Accesibilidad

- **Objetivo**: Verificar que los marcadores de accesibilidad se muestren correctamente en el mapa.
- **Pasos**:
  1. Explora el mapa de Zaragoza
  2. Identifica los diferentes marcadores (lugares con información de accesibilidad)
  3. Observa que los marcadores tienen diferentes colores según su nivel de accesibilidad:
     - Verde: Buena accesibilidad
     - Amarillo: Accesibilidad media
     - Rojo: Mala accesibilidad
- **Resultado esperado**: Deben mostrarse varios marcadores con diferentes colores en el mapa.

### 4. Detalles de Marcadores

- **Objetivo**: Verificar que se pueda acceder a la información detallada de un marcador.
- **Pasos**:
  1. Toca cualquier marcador en el mapa
  2. Observa la tarjeta de información que aparece en la parte inferior
- **Resultado esperado**: Debe mostrarse una tarjeta con:
   - Nombre del lugar
   - Nivel de accesibilidad
   - Resumen de reportes
   - Opción para cerrar la tarjeta

### 5. Exploración de Reportes

- **Objetivo**: Verificar que se puedan visualizar los reportes de accesibilidad de un lugar.
- **Pasos**:
  1. Toca un marcador para ver su tarjeta de información
  2. Observa la sección de reportes con comentarios de usuarios
- **Resultado esperado**: Debes poder ver comentarios específicos sobre la accesibilidad del lugar.

### 6. Filtros de Accesibilidad

- **Objetivo**: Verificar que se puedan filtrar marcadores por nivel de accesibilidad.
- **Pasos**:
  1. Localiza la barra de filtros en la parte superior de la pantalla
  2. Prueba seleccionar diferentes niveles de accesibilidad (todos, bueno, medio, malo)
- **Resultado esperado**: Los marcadores deben filtrarse según el nivel de accesibilidad seleccionado.

### 7. Reinicio de Vista

- **Objetivo**: Verificar que se pueda reiniciar la vista del mapa.
- **Pasos**:
  1. Desplázate por el mapa a cualquier ubicación
  2. Presiona el botón de reinicio (icono de reinicio)
- **Resultado esperado**: El mapa debe volver a la vista predeterminada centrada en Zaragoza.

## Reporte de Problemas

Si encuentras algún problema durante las pruebas, por favor documéntalo con:

1. Descripción detallada del problema
2. Pasos para reproducirlo
3. Capturas de pantalla (si es posible)
4. Información del dispositivo (modelo, versión de Android/iOS)
5. Versión de Flutter utilizada

Puedes reportar los problemas creando un nuevo issue en el repositorio de GitHub. 