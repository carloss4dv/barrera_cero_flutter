import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';

class AccessibilitySettingsPage extends StatelessWidget {
  const AccessibilitySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Accesibilidad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alto contraste
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Modo de alto contraste'),
                      subtitle: const Text('Mejora la visibilidad con colores contrastantes'),
                      value: accessibilityProvider.highContrastMode,
                      onChanged: (value) => accessibilityProvider.setHighContrastMode(value),
                    ),
                    if (accessibilityProvider.highContrastMode) ...[
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Vista previa del alto contraste:'),
                      ),
                      // Ejemplos de elementos de UI con alto contraste
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Botón'),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            child: Text(
                              'Texto',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.accessibility_new,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tamaño de texto
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tamaño del texto', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Slider(
                      value: accessibilityProvider.textScaleFactor,
                      min: 0.8,
                      max: 2.0,
                      divisions: 6,
                      label: '${(accessibilityProvider.textScaleFactor * 100).round()}%',
                      onChanged: (value) => accessibilityProvider.setTextScaleFactor(value),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Vista previa de tamaño de texto',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Este es un ejemplo de cómo se verá el texto en la aplicación.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Lector de pantalla
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SwitchListTile(
                  title: const Text('Instrucciones por voz'),
                  subtitle: const Text('Activa instrucciones adicionales para TalkBack/VoiceOver'),
                  value: accessibilityProvider.screenReaderInstructions,
                  onChanged: (value) => accessibilityProvider.setScreenReaderInstructions(value),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Instrucciones adicionales
            if (accessibilityProvider.screenReaderInstructions)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instrucciones por voz activadas',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Las instrucciones por voz añaden información adicional '
                        'para cada elemento de la interfaz cuando usas TalkBack o VoiceOver.',
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        label: accessibilityProvider.getSemanticLabel(
                          'button', 
                          'Ejemplo de botón con instrucciones'
                        ),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Prueba TalkBack aquí'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 