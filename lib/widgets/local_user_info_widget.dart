import 'package:flutter/material.dart';
import '../../services/local_user_storage_service.dart';

/// Widget que muestra información del usuario desde el almacenamiento local
/// Demuestra cómo acceder a los datos guardados como "localhost" en Flutter
class LocalUserInfoWidget extends StatefulWidget {
  final bool showDetailed;

  const LocalUserInfoWidget({
    Key? key,
    this.showDetailed = false,
  }) : super(key: key);

  @override
  State<LocalUserInfoWidget> createState() => _LocalUserInfoWidgetState();
}

class _LocalUserInfoWidgetState extends State<LocalUserInfoWidget> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final userData = await localUserStorage.getUserData();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos locales: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_userData == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                'No hay datos de usuario guardados localmente',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Recargar'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userData!['name'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _userData!['email'] ?? 'Sin email',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadUserData,
                  tooltip: 'Recargar datos',
                ),
              ],
            ),

            if (widget.showDetailed) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              // Información detallada
              _buildInfoRow('ID', _userData!['uid'] ?? 'N/A'),
              _buildInfoRow('Display Name', _userData!['displayName'] ?? 'N/A'),
              _buildInfoRow('Tipo de Movilidad', _userData!['mobilityType'] ?? 'N/A'),
              _buildInfoRow('B-points', '${_userData!['contributionPoints'] ?? 0}'),
              
              if (_userData!['accessibilityPreferences'] != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Preferencias de Accesibilidad:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: (_userData!['accessibilityPreferences'] as List<dynamic>)
                      .map((pref) => Chip(
                        label: Text(pref.toString()),
                        backgroundColor: Colors.blue.shade50,
                      ))
                      .toList(),
                ),
              ],
              
              const SizedBox(height: 8),
              Text(
                'Última actualización: ${_formatDate(_userData!['lastUpdated'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],

            // Botones de acción
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: _showDebugInfo,
                  icon: const Icon(Icons.bug_report, size: 16),
                  label: const Text('Debug'),
                ),
                TextButton.icon(
                  onPressed: _clearData,
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Limpiar'),
                ),
                TextButton.icon(
                  onPressed: _testAddPoints,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+10 pts'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString.toString());
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString.toString();
    }
  }

  Future<void> _showDebugInfo() async {
    await localUserStorage.printDebugInfo();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Información de debug mostrada en consola'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de que quieres limpiar todos los datos locales del usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await localUserStorage.clearUserData();
      _loadUserData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos locales eliminados'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _testAddPoints() async {
    await localUserStorage.addContributionPoints(10);
    _loadUserData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('+10 B-points añadidos (solo localmente)'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

/// Widget simple que solo muestra el nombre del usuario
class SimpleUserDisplayWidget extends StatefulWidget {
  const SimpleUserDisplayWidget({Key? key}) : super(key: key);

  @override
  State<SimpleUserDisplayWidget> createState() => _SimpleUserDisplayWidgetState();
}

class _SimpleUserDisplayWidgetState extends State<SimpleUserDisplayWidget> {
  String _userDisplayInfo = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadUserDisplayInfo();
  }

  Future<void> _loadUserDisplayInfo() async {
    final displayInfo = await localUserStorage.getUserDisplayInfo();
    if (mounted) {
      setState(() {
        _userDisplayInfo = displayInfo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person,
            size: 16,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            _userDisplayInfo,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
