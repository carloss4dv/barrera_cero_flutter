import 'package:flutter/material.dart';
import '../domain/models/user.dart';
import '../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() => _isEditing = true);
              }
            },
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                enabled: _isEditing,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Este campo es requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: _isEditing,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Este campo es requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MobilityType>(
                value: _selectedMobilityType,
                decoration: const InputDecoration(labelText: 'Tipo de Movilidad'),
                items: MobilityType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
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
              const Text('Preferencias de Accesibilidad:'),
              ...AccessibilityPreference.values.map((preference) {
                return CheckboxListTile(
                  title: Text(preference.toString().split('.').last),
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
              const SizedBox(height: 16),
              Text('Puntos de contribución: ${_user!.contributionPoints}'),
              const SizedBox(height: 16),
              const Text('Insignias:'),
              Wrap(
                spacing: 8,
                children: _user!.badges.map((badge) {
                  return Chip(
                    label: Text(badge.name),
                    avatar: CircleAvatar(
                      backgroundImage: NetworkImage(badge.iconUrl),
                    ),
                  );
                }).toList(),
              ),
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