# Documentación Sprint 1 - Barrera Cero

## Introducción

En este primer sprint de desarrollo de Barrera Cero, hemos implementado las funcionalidades fundamentales para crear un mapa de accesibilidad. El objetivo principal ha sido establecer la infraestructura básica y desarrollar las primeras características que permiten a los usuarios visualizar y reportar información sobre la accesibilidad de diferentes lugares.

## Funcionalidades Implementadas

### 1. Sistema de Mapa Interactivo
- Implementación de un mapa interactivo utilizando Flutter Map
- Visualización de la ubicación actual del usuario
- Navegación por el mapa (zoom, desplazamiento)
- Interfaz de usuario adaptable

### 2. Sistema de Marcadores de Accesibilidad
- Visualización de marcadores en el mapa que representan lugares evaluados
- Diferenciación visual de marcadores según el nivel de accesibilidad
- Modelo de datos para gestionar la información de los marcadores

### 3. Sistema de Reportes de Accesibilidad
- Modelo de datos para los reportes de accesibilidad
- Servicio para gestionar reportes (consulta y creación)
- Visualización del nivel predominante de accesibilidad por lugar
- Categorización en tres niveles: bueno, medio y malo

### 4. Detalles de Marcadores
- Vista detallada al seleccionar un marcador
- Visualización de información sobre el lugar
- Resumen de los reportes de accesibilidad existentes

## Arquitectura

La aplicación sigue una arquitectura limpia, organizada por características:

- **Domain**: Modelos de datos y definiciones de interfaces
- **Infrastructure**: Implementaciones concretas de servicios
- **Application**: Gestión del estado de la aplicación (usando Bloc/Cubit)
- **Presentation**: Componentes de UI y páginas

## Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo
- **flutter_map**: Para la implementación del mapa interactivo
- **flutter_bloc**: Para la gestión del estado
- **freezed**: Para modelos inmutables
- **get_it**: Para inyección de dependencias
- **result_dart**: Para manejo de resultados tipo Success/Failure