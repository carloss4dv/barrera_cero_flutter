import 'package:flutter/material.dart';
import '../widgets/local_user_info_widget.dart';
import '../services/local_user_storage_service.dart';
import '../features/auth/service/auth_service.dart';

/// Página de demostración del almacenamiento local de usuario
/// Muestra cómo funciona el "localhost" de Flutter para datos del usuario
class LocalStorageDemoPage extends StatefulWidget {
  const LocalStorageDemoPage({Key? key}) : super(key: key);

  @override
  State<LocalStorageDemoPage> createState() => _LocalStorageDemoPageState();
}

class _LocalStorageDemoPageState extends State<LocalStorageDemoPage> {
  final AuthService _authService = AuthService();
  bool _hasLocalData = false;
  String _currentUserEmail = '';
  String _currentUserName = '';
  int _currentPoints = 0;

  @override
  void initState() {
    super.initState();
    _checkLocalData();
  }

  Future<void> _checkLocalData() async {
    final hasData = await localUserStorage.hasUserData();
    final email = await localUserStorage.getUserEmail();
    final name = await localUserStorage.getUserName();
    final points = await localUserStorage.getContributionPoints();
    
    setState(() {
      _hasLocalData = hasData;
      _currentUserEmail = email ?? 'No disponible';
      _currentUserName = name ?? 'No disponible';
      _currentPoints = points;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Almacenamiento Local - Demo'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkLocalData,
            tooltip: 'Actualizar datos',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado explicativo
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Almacenamiento Local de Usuario',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Esta página demuestra cómo funciona el almacenamiento local de información del usuario en Flutter, similar al "localhost" pero para datos del usuario. La información se guarda usando SharedPreferences.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Estado actual
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado Actual',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusRow(
                      'Usuario autenticado', 
                      _authService.currentUser != null ? 'Sí' : 'No',
                      _authService.currentUser != null ? Colors.green : Colors.red,
                    ),
                    _buildStatusRow(
                      'Datos locales disponibles', 
                      _hasLocalData ? 'Sí' : 'No',
                      _hasLocalData ? Colors.green : Colors.orange,
                    ),
                    if (_hasLocalData) ...[
                      const SizedBox(height: 8),
                      _buildStatusRow('Email guardado', _currentUserEmail, Colors.blue),
                      _buildStatusRow('Nombre guardado', _currentUserName, Colors.blue),
                      _buildStatusRow('B-points guardados', '$_currentPoints', Colors.amber),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Widget de información del usuario (simple)
            const Text(
              'Widget Simple de Usuario:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const SimpleUserDisplayWidget(),

            const SizedBox(height: 24),

            // Widget de información del usuario (detallado)
            const Text(
              'Widget Detallado de Usuario:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const LocalUserInfoWidget(showDetailed: true),

            const SizedBox(height: 24),

            // Acciones de prueba
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acciones de Prueba',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _testSaveUserData,
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar Datos de Prueba'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _testAddPoints,
                          icon: const Icon(Icons.add),
                          label: const Text('Añadir 50 Puntos'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _testUpdateName,
                          icon: const Icon(Icons.edit),
                          label: const Text('Cambiar Nombre'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showAllData,
                          icon: const Icon(Icons.visibility),
                          label: const Text('Ver Todos los Datos'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _clearAllData,
                          icon: const Icon(Icons.delete),
                          label: const Text('Limpiar Todo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade100,
                            foregroundColor: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información técnica
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información Técnica',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Los datos se guardan usando SharedPreferences\n'
                      '• Se sincronizan automáticamente con Firestore\n'
                      '• Persisten entre sesiones de la aplicación\n'
                      '• Se limpian automáticamente al cerrar sesión\n'
                      '• Incluyen: ID, email, nombre, tipo de movilidad, preferencias y puntos',
                      style: TextStyle(fontSize: 14),
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

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testSaveUserData() async {
    final success = await localUserStorage.saveUserData(
      uid: 'test_uid_123',
      email: 'test@ejemplo.com',
      name: 'Usuario de Prueba',
      displayName: 'Test User',
      mobilityType: 'wheelchair',
      accessibilityPreferences: ['ramps', 'elevators'],
      contributionPoints: 150,
    );

    _showSnackBar(
      success ? '✅ Datos de prueba guardados' : '❌ Error guardando datos',
      success ? Colors.green : Colors.red,
    );
    
    if (success) _checkLocalData();
  }

  Future<void> _testAddPoints() async {
    final success = await localUserStorage.addContributionPoints(50);
    _showSnackBar(
      success ? '✅ 50 puntos añadidos' : '❌ Error añadiendo puntos',
      success ? Colors.green : Colors.red,
    );
    
    if (success) _checkLocalData();
  }

  Future<void> _testUpdateName() async {
    final success = await localUserStorage.updateUserField('name', 'Nombre Actualizado ${DateTime.now().second}');
    _showSnackBar(
      success ? '✅ Nombre actualizado' : '❌ Error actualizando nombre',
      success ? Colors.green : Colors.red,
    );
    
    if (success) _checkLocalData();
  }

  Future<void> _showAllData() async {
    final userData = await localUserStorage.getUserData();
    if (userData != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Todos los Datos Locales'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: userData.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: '${entry.key}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: entry.value.toString()),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } else {
      _showSnackBar('No hay datos locales disponibles', Colors.orange);
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de que quieres eliminar todos los datos locales?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await localUserStorage.clearUserData();
      _showSnackBar(
        success ? '✅ Datos eliminados' : '❌ Error eliminando datos',
        success ? Colors.green : Colors.red,
      );
      
      if (success) _checkLocalData();
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
