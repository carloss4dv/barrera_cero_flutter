# Guía de Pruebas Sprint 3 - Accesibilidad

Este documento proporciona instrucciones detalladas para probar las funcionalidades de accesibilidad implementadas en el tercer sprint de Barrera Cero.

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
   > **Nota**: Para pruebas de accesibilidad, es preferible usar un dispositivo físico.

5. Ejecuta la aplicación:
   ```
   flutter run
   ```

## Pruebas de Accesibilidad

### 1. Modo de Alto Contraste

#### Test 1A: Activación y aplicación global
- **Objetivo**: Verificar que el modo de alto contraste se activa correctamente y se aplica a toda la aplicación.
- **Pasos**:
  1. Inicia la aplicación en modo normal.
  2. Toca el botón de accesibilidad (icono de accesibilidad en la parte inferior derecha).
  3. En la pantalla de configuración de accesibilidad, activa el interruptor "Modo de alto contraste".
  4. Vuelve a la pantalla principal.
- **Resultado esperado**: 
  - Toda la interfaz debe cambiar a un tema de alto contraste (fondo negro, texto blanco, acentos en amarillo/cian).
  - Los botones, controles y el mapa deben tener un aspecto de alto contraste.

#### Test 1B: Marcadores del mapa en alto contraste
- **Objetivo**: Verificar que los marcadores en el mapa se muestran correctamente en modo de alto contraste.
- **Pasos**:
  1. Con el modo de alto contraste activado, navega por el mapa.
  2. Observa los diferentes tipos de marcadores.
- **Resultado esperado**: 
  - Los marcadores deben tener colores de alto contraste pero manteniendo su distinción por tipo.
  - Debe aparecer texto descriptivo debajo de cada marcador para identificar su tipo.
  - Los bordes de los marcadores deben ser más pronunciados.

#### Test 1C: Filtros y barra de búsqueda
- **Objetivo**: Verificar que los filtros y la barra de búsqueda respetan el modo de alto contraste.
- **Pasos**:
  1. Con el modo de alto contraste activado, observa la barra de búsqueda y los filtros en la parte superior.
  2. Interactúa con el menú desplegable de filtros.
- **Resultado esperado**: 
  - La barra de búsqueda y los filtros deben tener colores de alto contraste.
  - El texto debe ser claramente legible.
  - El menú desplegable debe mantener el alto contraste al expandirse.

### 2. Texto Ampliable

#### Test 2A: Ajuste del tamaño del texto
- **Objetivo**: Verificar que el tamaño del texto se puede ajustar correctamente.
- **Pasos**:
  1. Ve a la pantalla de configuración de accesibilidad.
  2. Ajusta el control deslizante de "Tamaño del texto" a diferentes niveles.
  3. Observa la vista previa y confirma los cambios.
- **Resultado esperado**: 
  - El texto de la vista previa debe cambiar de tamaño en tiempo real.
  - Al volver a la aplicación, todo el texto debe tener el tamaño seleccionado.

#### Test 2B: Compatibilidad con diferentes tamaños de texto
- **Objetivo**: Verificar que la interfaz se adapta correctamente a diferentes tamaños de texto.
- **Pasos**:
  1. Establece el tamaño del texto al máximo (2.0x).
  2. Navega por diferentes partes de la aplicación.
- **Resultado esperado**: 
  - La interfaz debe adaptarse al tamaño de texto grande sin cortes ni superposiciones.
  - Todos los elementos deben seguir siendo utilizables.

### 3. Instrucciones por Voz (TalkBack/VoiceOver)

#### Test 3A: Compatibilidad con TalkBack/VoiceOver
- **Objetivo**: Verificar que la aplicación funciona correctamente con los lectores de pantalla.
- **Pasos**:
  1. Activa TalkBack (Android) o VoiceOver (iOS) en la configuración del dispositivo.
  2. Ve a la pantalla de configuración de accesibilidad.
  3. Activa "Instrucciones por voz".
  4. Navega por la aplicación usando gestos de TalkBack/VoiceOver.
- **Resultado esperado**: 
  - El lector de pantalla debe leer correctamente todos los elementos de la interfaz.
  - Las instrucciones adicionales deben ser claras y útiles.

#### Test 3B: Accesibilidad de los marcadores
- **Objetivo**: Verificar que los marcadores en el mapa son accesibles con lectores de pantalla.
- **Pasos**:
  1. Con TalkBack/VoiceOver activado, navega hasta un marcador en el mapa.
  2. Selecciona el marcador.
- **Resultado esperado**: 
  - El lector de pantalla debe anunciar el tipo de marcador y su nivel de accesibilidad.
  - Al seleccionar un marcador, debe leer la información detallada.

### 4. Pruebas Combinadas

#### Test 4A: Alto contraste con texto ampliado
- **Objetivo**: Verificar que el modo de alto contraste funciona bien con texto ampliado.
- **Pasos**:
  1. Activa el modo de alto contraste.
  2. Establece el tamaño del texto a 1.5x.
  3. Navega por diferentes partes de la aplicación.
- **Resultado esperado**: 
  - La combinación de alto contraste y texto ampliado debe crear una experiencia coherente.
  - No debe haber problemas de superposición o recorte.

#### Test 4B: Accesibilidad completa
- **Objetivo**: Verificar el funcionamiento con todas las funciones de accesibilidad activadas.
- **Pasos**:
  1. Activa el modo de alto contraste.
  2. Establece el tamaño del texto a 1.5x.
  3. Activa las instrucciones por voz.
  4. Activa TalkBack/VoiceOver.
  5. Intenta navegar por toda la aplicación.
- **Resultado esperado**: 
  - La aplicación debe ser completamente usable con todas las funciones de accesibilidad activadas.
  - La experiencia debe ser coherente y útil para usuarios con discapacidad visual.

## Pruebas de Regresión

### Test R1: Funcionalidad básica del mapa
- **Objetivo**: Verificar que las funciones básicas del mapa siguen funcionando con las opciones de accesibilidad.
- **Pasos**:
  1. Activa todas las opciones de accesibilidad.
  2. Prueba hacer zoom y desplazarte por el mapa.
  3. Selecciona marcadores y verifica la información.
- **Resultado esperado**: 
  - Todas las funciones básicas del mapa deben seguir funcionando correctamente.

### Test R2: Filtrado de marcadores
- **Objetivo**: Verificar que el filtrado de marcadores funciona con las opciones de accesibilidad.
- **Pasos**:
  1. Activa todas las opciones de accesibilidad.
  2. Utiliza los filtros para mostrar diferentes tipos de marcadores.
- **Resultado esperado**: 
  - Los filtros deben seguir funcionando correctamente.
  - Los marcadores deben mostrarse correctamente según los filtros.

## Compatibilidad con Dispositivos

Probar la accesibilidad en:
- Al menos un dispositivo Android reciente (preferiblemente con Android 11+)
- Al menos un dispositivo iOS reciente (preferiblemente con iOS 14+)
- Diferentes tamaños de pantalla (teléfono y tableta)

## Reporte de Problemas

Si encuentras algún problema durante las pruebas, por favor documéntalo con:

1. Descripción detallada del problema
2. Pasos para reproducirlo
3. Capturas de pantalla (si es posible)
4. Información del dispositivo (modelo, versión de Android/iOS)
5. Configuración de accesibilidad utilizada
6. Versión de Flutter utilizada

Puedes reportar los problemas creando un nuevo issue en el repositorio de GitHub con la etiqueta "accesibilidad". 