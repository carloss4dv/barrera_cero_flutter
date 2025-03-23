import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';
import '../../../accessibility/presentation/widgets/accessible_button.dart';

class ExamplePage extends StatelessWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ejemplo de texto con escalado automático
            Text(
              'Este texto se escalará según la configuración',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            
            const SizedBox(height: 20),
            
            // Ejemplo de campo de texto con semántica mejorada
            Semantics(
              label: accessibilityProvider.getSemanticLabel(
                'input', 
                'Campo de búsqueda'
              ),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Usar el botón accesible
            AccessibleButton(
              label: 'Continuar',
              icon: Icons.arrow_forward,
              onPressed: () {
                // Acción del botón
              },
            ),
          ],
        ),
      ),
    );
  }
} 