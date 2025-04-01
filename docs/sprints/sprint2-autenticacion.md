# Documentación Sprint 2 - Barrera Cero

## Introducción

Durante el segundo sprint de desarrollo de Barrera Cero, nos enfocamos en diseñar e implementar el sistema de creación y autenticación de usuarios. Para ello, utilizamos tecnologías consolidadas como Firebase, específicamente sus servicios de Authentication para la gestión de credenciales y Firestore para el almacenamiento de datos de los usuarios. El objetivo principal de este sprint fue establecer una base sólida para la gestión de cuentas, asegurando un inicio de sesión seguro lo que permitirá a los usuarios acceder a la plataforma sin inconvenientes.

## Funcionalidades Implementadas

### 1. Sistema de autenticacion
- Pantalla de inicio de sesión con validación de credenciales
- Registro de usuarios (formulario con campos básicos y validaciones)
- Gestión de sesión persistente (autenticación local)
- Interfaz de perfil de usuario con opciones de edición y cierre de sesión

### 2. Base de datps con los usuarios
-Modelo de datos para usuarios (email, contraseña, nombre, etc.)
-Almacenamiento seguro de información sensible
-Conexión con servicio backend/Firebase para sincronización de datos

### 3. Mejoreas en la interfaz existente
-Mapa interactivo rediseñado con mejor rendimiento y fluidez
-Menús contextuales optimizados para accesibilidad visual
-Feedback visual mejorado en interacciones (ej: animaciones al guardar)


## Arquitectura

La aplicación sigue una arquitectura limpia, organizada por características:

- **Domain**: Modelos de datos y definiciones de interfaces
- **Infrastructure**: Implementaciones concretas de servicios
- **Application**: Gestión del estado de la aplicación (usando Bloc/Cubit)
- **Presentation**: Componentes de UI y páginas

## Tecnologías Utilizadas

- **Firebase**: Plataforma de desarrollo web
- **firebase_auth**: Sistema de autenticacion de Firebase
- **cloud_firestone**: Base de datos NoSQL orientada a documentos de Firebase
- **freezed**: Para modelos inmutables
- **get_it**: Para inyección de dependencias
- **result_dart**: Para manejo de resultados tipo Success/Failure
- **shared_preferes**: Permite el guardado en "localstore" en flutter.