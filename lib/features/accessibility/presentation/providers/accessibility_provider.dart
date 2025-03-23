import 'package:flutter/material.dart';

class AccessibilityProvider extends ChangeNotifier {
  bool _highContrastMode = false;
  double _textScaleFactor = 1.0;
  bool _screenReaderInstructions = false;

  // Getters
  bool get highContrastMode => _highContrastMode;
  double get textScaleFactor => _textScaleFactor;
  bool get screenReaderInstructions => _screenReaderInstructions;

  // Setters
  void setHighContrastMode(bool value) {
    _highContrastMode = value;
    notifyListeners();
  }

  void setTextScaleFactor(double value) {
    _textScaleFactor = value;
    notifyListeners();
  }

  void setScreenReaderInstructions(bool value) {
    _screenReaderInstructions = value;
    notifyListeners();
  }

  // Colores para uso en modo alto contraste
  static const Color kBackgroundColor = Colors.black;
  static const Color kTextColor = Colors.white;
  static const Color kAccentColor = Color(0xFF00FFFF); // Cian brillante
  static const Color kButtonColor = Color(0xFFFFFF00); // Amarillo brillante
  
  // Colores mejorados para los diferentes tipos de marcadores en el mapa
  Color getEnhancedColor(Color originalColor) {
    if (!_highContrastMode) return originalColor;
    
    // Versiones de alto contraste para colores comunes
    if (originalColor == Colors.red || originalColor.value == Colors.red.value) {
      return const Color(0xFFFF5252); // Rojo brillante
    } else if (originalColor == Colors.green || originalColor.value == Colors.green.value) {
      return const Color(0xFF4CAF50); // Verde brillante
    } else if (originalColor == Colors.blue || originalColor.value == Colors.blue.value) {
      return const Color(0xFF448AFF); // Azul brillante
    } else if (originalColor == Colors.orange || originalColor.value == Colors.orange.value) {
      return const Color(0xFFFF9800); // Naranja brillante
    } else if (originalColor == Colors.amber || originalColor.value == Colors.amber.value) {
      return const Color(0xFFFFD600); // Ámbar brillante
    } else if (originalColor == Colors.purple || originalColor.value == Colors.purple.value) {
      return const Color(0xFFAB47BC); // Púrpura brillante
    }
    
    // Para otros colores, aumentar su saturación y brillo
    final HSLColor hsl = HSLColor.fromColor(originalColor);
    return hsl.withSaturation(0.9).withLightness(0.7).toColor();
  }
  
  // Método para obtener el color para iconos en modo de alto contraste
  Color getIconColor(Color backgroundColor) {
    if (!_highContrastMode) return Colors.white;
    
    // Para calcular si usar texto negro o blanco según el color de fondo
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Métodos para obtener los temas según la configuración
  ThemeData getTheme(ThemeData baseTheme) {
    if (!_highContrastMode) {
      return baseTheme;
    }
    
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: kAccentColor,
      scaffoldBackgroundColor: kBackgroundColor,
      cardColor: kBackgroundColor,
      dialogBackgroundColor: kBackgroundColor,
      colorScheme: ColorScheme.dark(
        primary: kAccentColor,
        secondary: kButtonColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        surface: kBackgroundColor,
        onSurface: kTextColor,
        background: kBackgroundColor,
        onBackground: kTextColor,
        error: Colors.red.shade300,
        onError: kBackgroundColor,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: kTextColor,
        displayColor: kTextColor,
      ),
      iconTheme: const IconThemeData(
        color: kTextColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonColor,
          foregroundColor: Colors.black,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected) ? kButtonColor : kTextColor;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected) ? kAccentColor.withOpacity(0.5) : Colors.grey.shade600;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: kAccentColor,
        thumbColor: kButtonColor,
        inactiveTrackColor: Colors.grey.shade600,
      ),
      // Asegurar que todos los componentes importantes tengan buen contraste
      appBarTheme: const AppBarTheme(
        backgroundColor: kBackgroundColor,
        foregroundColor: kTextColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kButtonColor,
        foregroundColor: Colors.black,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: kBackgroundColor,
        selectedItemColor: kAccentColor,
        unselectedItemColor: kTextColor.withOpacity(0.7),
      ),
    );
  }

  // Método para proporcionar semántica adicional para lectores de pantalla
  String? getSemanticLabel(String widgetType, String defaultLabel) {
    if (!_screenReaderInstructions) {
      return null;
    }
    
    // Proporcionar instrucciones adicionales según el tipo de widget
    switch (widgetType) {
      case 'button':
        return '$defaultLabel. Toca dos veces para activar.';
      case 'input':
        return '$defaultLabel. Toca dos veces para editar.';
      case 'slider':
        return '$defaultLabel. Desliza hacia los lados para ajustar.';
      default:
        return defaultLabel;
    }
  }
} 