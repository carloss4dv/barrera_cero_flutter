import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';

class AccessibilityWrapper extends StatelessWidget {
  final Widget child;
  
  const AccessibilityWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    
    // Aplicar el escalado de texto
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(accessibilityProvider.textScaleFactor),
      ),
      child: child,
    );
  }
} 