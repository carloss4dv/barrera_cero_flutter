# Barrera Cero

Aplicación móvil para mapear y compartir información sobre accesibilidad en espacios públicos. Esta herramienta permite a los usuarios reportar, consultar y navegar por un mapa interactivo que muestra el nivel de accesibilidad de diferentes lugares, facilitando la movilidad de personas con discapacidad.

## Características Principales

- Mapa interactivo de accesibilidad con datos en tiempo real
- Sistema de reportes colaborativos sobre la accesibilidad de lugares
- Clasificación de ubicaciones según su nivel de accesibilidad (bueno, medio, malo)
- Detalles y comentarios específicos sobre las barreras o facilidades de cada lugar
- Funciones de accesibilidad: modo de alto contraste, texto ampliable e instrucciones para lectores de pantalla

## Requisitos de Instalación

- Flutter 3.19.0 o superior
- Dart 3.3.0 o superior
- Dispositivo Android (5.0+) o iOS (11.0+)

## Configuración del Entorno de Desarrollo

1. Clonar el repositorio
   ```
   git clone https://github.com/tu-usuario/barrera-cero.git
   cd barrera-cero
   ```

2. Instalar dependencias
   ```
   flutter pub get
   ```

3. Ejecutar la aplicación
   ```
   flutter run
   ```

## Documentación

Para más información sobre el desarrollo del proyecto, consulta nuestra [documentación completa](docs/indice.md), que incluye:

- **Documentación de Desarrollo**
  - [Sprint 1: Funcionalidades Básicas](docs/sprints/sprint1-funcionalidades_basicas.md)
  - [Sprint 3: Accesibilidad](docs/sprints/sprint3-accesibilidad.md)

- **Guías de Pruebas**
  - [Guía de Pruebas Funcionales](docs/guias/guia_pruebas_funcionales.md)
  - [Guía de Pruebas de Accesibilidad](docs/guias/guia_pruebas_accesibilidad.md)

## Funcionalidades de Accesibilidad

Barrera Cero ha sido desarrollada con un enfoque en la accesibilidad, incluyendo:

- **Modo de Alto Contraste**: Mejora la visibilidad para personas con discapacidad visual mediante un esquema de colores optimizado.
- **Texto Ampliable**: Permite ajustar el tamaño del texto en toda la aplicación según las necesidades del usuario.
- **Instrucciones por Voz**: Compatibilidad mejorada con TalkBack (Android) y VoiceOver (iOS) para usuarios con discapacidad visual.

Estas funcionalidades permiten que la aplicación sea usable por un mayor número de personas, independientemente de sus capacidades visuales.

### Capturas de Pantalla

<div align="center">
  <img src="docs/imagenes/configuracion_accesibilidad.jpg" alt="Configuración de Accesibilidad" width="250"/>
  <img src="docs/imagenes/mapa_alto_contraste.jpg" alt="Mapa con Alto Contraste" width="250"/>
  <img src="docs/imagenes/marcadores_accesibles.jpg" alt="Marcadores Accesibles" width="250"/>
</div>

## Contribución

Si deseas contribuir al proyecto, puedes revisar los issues abiertos o proponer nuevas características. Toda contribución es bienvenida.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo LICENSE para más detalles.
