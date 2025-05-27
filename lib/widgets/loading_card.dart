import 'package:flutter/material.dart';
import '../features/accessibility/presentation/providers/accessibility_provider.dart';
import 'package:provider/provider.dart';

/// Widget reutilizable para mostrar un indicador de carga con diseño consistente
/// Se adapta automáticamente al modo de alto contraste
class LoadingCard extends StatelessWidget {
  final String message;
  final bool showProgress;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? progressColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const LoadingCard({
    Key? key,
    this.message = 'Cargando...',
    this.showProgress = true,
    this.backgroundColor,
    this.textColor,
    this.progressColor,
    this.width,
    this.height,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    final theme = Theme.of(context);

    // Colores adaptados para alto contraste
    final Color cardColor = backgroundColor ??
        (isHighContrastMode ? theme.colorScheme.surface : Colors.white);
    final Color messageColor = textColor ??
        (isHighContrastMode ? theme.colorScheme.onSurface : Colors.black87);
    final Color spinnerColor = progressColor ??
        (isHighContrastMode ? AccessibilityProvider.kAccentColor : Colors.blue);

    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(16),
      child: Card(
        color: cardColor,
        elevation: isHighContrastMode ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isHighContrastMode
              ? BorderSide(color: AccessibilityProvider.kAccentColor, width: 2)
              : BorderSide.none,
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showProgress) ...[
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: messageColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget compacto para indicadores de carga en línea
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool showMessage;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.size = 20,
    this.color,
    this.showMessage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    final theme = Theme.of(context);

    final Color spinnerColor = color ??
        (isHighContrastMode ? AccessibilityProvider.kAccentColor : Colors.blue);
    final Color messageColor = isHighContrastMode
        ? theme.colorScheme.onSurface
        : Colors.black87;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: size < 25 ? 2 : 3,
            valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
          ),
        ),
        if (showMessage && message != null) ...[
          const SizedBox(width: 12),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14,
              color: messageColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget para overlay de carga que cubre toda la pantalla
class LoadingOverlay extends StatelessWidget {
  final String message;
  final bool isVisible;
  final Widget child;
  final Color? overlayColor;

  const LoadingOverlay({
    Key? key,
    required this.child,
    this.message = 'Cargando...',
    this.isVisible = false,
    this.overlayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          Container(
            color: overlayColor ?? Colors.black54,
            child: Center(
              child: LoadingCard(message: message),
            ),
          ),
      ],
    );
  }
}
