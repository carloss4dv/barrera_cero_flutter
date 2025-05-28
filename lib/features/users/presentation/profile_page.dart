import 'package:flutter/material.dart';
import '../domain/models/user.dart';
import '../services/user_service.dart';
import '../../auth/service/auth_service.dart';
import 'widgets/badges_widget.dart';
import '../../../widgets/loading_card.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final AuthService authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  late User? _user;
  bool _isLoading = true;
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  MobilityType _selectedMobilityType = MobilityType.noAssistance;
  final List<AccessibilityPreference> _selectedPreferences = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
        print(widget.userId);
      _user = await _userService.getUserById(widget.userId);

      if (_user != null) {
        _nameController.text = _user!.name;
        _emailController.text = _user!.email;
        _selectedMobilityType = _user!.mobilityType;
        _selectedPreferences.clear();
        _selectedPreferences.addAll(_user!.accessibilityPreferences);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los datos del usuario')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final updatedUser = User(
        id: _user!.id,
        email: _emailController.text,
        name: _nameController.text,
        mobilityType: _selectedMobilityType,
        accessibilityPreferences: _selectedPreferences,
        contributionPoints: _user!.contributionPoints,
        badges: _user!.badges,
        isVerified: _user!.isVerified,
        createdAt: _user!.createdAt,
        updatedAt: DateTime.now(),
      );

      await _userService.updateUser(updatedUser);
      setState(() {
        _user = updatedUser;
        _isEditing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el perfil')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }  Future<void> _handleLogout() async {
    try {
      print('🔄 Iniciando logout desde ProfilePage...');
      
      // Mostrar indicador de carga
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Cerrando sesión...'),
              ],
            ),
          ),
        );
      }
      
      // Realizar logout completo usando AuthService
      await authService.signOut();
      print('✅ Logout completo realizado desde ProfilePage');
      
      if (mounted) {
        // Cerrar el diálogo de carga
        Navigator.of(context).pop();
        
        // Navegar al mapa después de cerrar sesión en lugar de al login
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        
        // Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error durante logout desde ProfilePage: $e');
      
      if (mounted) {
        // Cerrar el diálogo de carga si está abierto
        Navigator.of(context).pop();
        
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: LoadingCard(
            message: 'Cargando perfil...',
          ),
        ),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de información personal
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información Personal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                        ),
                        enabled: _isEditing,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Este campo es requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        enabled: _isEditing,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Este campo es requerido' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),              // Sección de puntos y badges
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.amber, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [                                Text(
                                  '${_user!.contributionPoints} B-points',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const Text(
                                  'Puntos de contribución',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Información sobre cómo ganar puntos
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '¿Cómo ganar B-points?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.how_to_vote, color: Colors.green.shade600, size: 18),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Votar en validaciones de accesibilidad: +20 puntos',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.rate_review, color: Colors.blue.shade600, size: 18),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Reportar problemas de accesibilidad',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.group, color: Colors.purple.shade600, size: 18),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Participar en la comunidad',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                        const SizedBox(height: 16),
                      
                      // Sistema de insignias nuevo
                      BadgesWidget(
                        bPoints: _user!.contributionPoints,
                        showProgress: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sección de preferencias de accesibilidad
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configuración de Accesibilidad',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),                      DropdownButtonFormField<MobilityType>(
                        value: _selectedMobilityType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Movilidad',
                          border: OutlineInputBorder(),
                        ),
                        items: MobilityType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }).toList(),
                        onChanged: _isEditing
                            ? (value) {
                                if (value != null) {
                                  setState(() => _selectedMobilityType = value);
                                }
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Preferencias de Accesibilidad:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),                      ...AccessibilityPreference.values.map((preference) {
                        return CheckboxListTile(
                          title: Text(preference.displayName),
                          value: _selectedPreferences.contains(preference),
                          onChanged: _isEditing
                              ? (bool? value) {
                                  setState(() {
                                    if (value ?? false) {
                                      _selectedPreferences.add(preference);
                                    } else {
                                      _selectedPreferences.remove(preference);
                                    }
                                  });
                                }
                              : null,
                        );
                      }),
                    ],
                  ),
                ),              ),
              const SizedBox(height: 16),

              // Sección de herramientas de desarrollo
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,                      children: [
                      const Text(
                        'Herramientas de Desarrollo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Las herramientas de desarrollo han sido deshabilitadas.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}