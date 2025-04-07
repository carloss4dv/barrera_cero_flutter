import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';
import '../../../auth/service/auth_service.dart';
import '../../infrastructure/providers/map_filters_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccessibilityFilter extends StatefulWidget {
  const AccessibilityFilter({Key? key}) : super(key: key);

  @override
  State<AccessibilityFilter> createState() => _AccessibilityFilterState();
}

class _AccessibilityFilterState extends State<AccessibilityFilter> {
  final Map<String, bool> _metadataFilters = {
    'hasRamp': false,
    'hasElevator': false,
    'hasAccessibleBathroom': false,
    'hasBrailleSignage': false,
    'hasAudioGuidance': false,
    'hasTactilePavement': false,
  };
  bool _isMetadataExpanded = false;
  int _selectedLevel = 0;

  @override
  void initState() {
    super.initState();
    authService.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    authService.removeListener(() {
      if (mounted) setState(() {});
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final currentUser = authService.currentUser;
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    final theme = Theme.of(context);
    
    // Colores adaptados para alto contraste
    final Color backgroundColor = isHighContrastMode 
        ? theme.colorScheme.surface
        : Colors.white;
    final Color textColor = isHighContrastMode 
        ? theme.colorScheme.onSurface
        : Colors.black87;
    final Color accentColor = isHighContrastMode 
        ? AccessibilityProvider.kAccentColor
        : Colors.blue;
    final Color shadowColor = isHighContrastMode 
        ? Colors.black.withOpacity(0.5)
        : Colors.black.withOpacity(0.1);
    final Color borderColor = isHighContrastMode 
        ? Colors.white.withOpacity(0.5)
        : Colors.grey.withOpacity(0.3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de búsqueda y usuario
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: isHighContrastMode 
                ? Border.all(color: AccessibilityProvider.kButtonColor, width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 20, color: textColor),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Buscar',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.7)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                ),
                child: _buildUserButton(currentUser, accentColor, textColor),
              ),
            ],
          ),
        ),

        // Filtro de nivel de accesibilidad
        Container(
          margin: const EdgeInsets.only(left: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: isHighContrastMode 
                ? Border.all(color: AccessibilityProvider.kButtonColor, width: 1.5)
                : null,
          ),
          child: DropdownButton<int>(
            value: _selectedLevel,
            underline: const SizedBox(),
            isDense: true,
            dropdownColor: backgroundColor,
            style: TextStyle(color: textColor),
            icon: Icon(Icons.keyboard_arrow_down, color: textColor),
            items: [
              DropdownMenuItem(
                value: 0,
                child: Text('Nivel de accesibilidad', style: TextStyle(color: textColor)),
              ),
              DropdownMenuItem(
                value: 1,
                child: Text('Alta accesibilidad', style: TextStyle(color: textColor)),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text('Media accesibilidad', style: TextStyle(color: textColor)),
              ),
              DropdownMenuItem(
                value: 3,
                child: Text('Baja accesibilidad', style: TextStyle(color: textColor)),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLevel = value;
                });
                context.read<MapFiltersProvider>().updateAccessibilityLevel(value);
              }
            },
          ),
        ),

        // Filtros de metadatos
        Container(
          margin: const EdgeInsets.only(left: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: isHighContrastMode 
                ? Border.all(color: AccessibilityProvider.kButtonColor, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isMetadataExpanded = !_isMetadataExpanded;
                  });
                },
                icon: Icon(
                  _isMetadataExpanded ? Icons.expand_less : Icons.expand_more,
                  color: textColor,
                ),
                label: Text(
                  'Filtros de Accesibilidad',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_isMetadataExpanded)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip(
                            label: 'Rampa',
                            value: 'hasRamp',
                            icon: Icons.accessible,
                            isHighContrastMode: isHighContrastMode,
                            textColor: textColor,
                          ),
                          _buildFilterChip(
                            label: 'Ascensor',
                            value: 'hasElevator',
                            icon: Icons.elevator,
                            isHighContrastMode: isHighContrastMode,
                            textColor: textColor,
                          ),
                          _buildFilterChip(
                            label: 'Baño Accesible',
                            value: 'hasAccessibleBathroom',
                            icon: Icons.wc,
                            isHighContrastMode: isHighContrastMode,
                            textColor: textColor,
                          ),
                          _buildFilterChip(
                            label: 'Señalización Braille',
                            value: 'hasBrailleSignage',
                            icon: Icons.format_size,
                            isHighContrastMode: isHighContrastMode,
                            textColor: textColor,
                          ),
                          _buildFilterChip(
                            label: 'Guía de Audio',
                            value: 'hasAudioGuidance',
                            icon: Icons.hearing,
                            isHighContrastMode: isHighContrastMode,
                            textColor: textColor,
                          ),
                          _buildFilterChip(
                            label: 'Pavimento Táctil',
                            value: 'hasTactilePavement',
                            icon: Icons.texture,
                            isHighContrastMode: isHighContrastMode,
                            textColor: textColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                for (var key in _metadataFilters.keys) {
                                  _metadataFilters[key] = false;
                                }
                              });
                              context.read<MapFiltersProvider>().updateFilters(_metadataFilters);
                            },
                            child: Text(
                              'Limpiar Filtros',
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserButton(User? currentUser, Color accentColor, Color textColor) {
    if (currentUser != null) {
      final displayName = currentUser.displayName ?? currentUser.email ?? 'Usuario';
      return TextButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/profile', arguments: currentUser.uid);
        },
        child: Row(
          children: [
            Icon(
              Icons.person,
              color: accentColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              displayName,
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return TextButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/login');
        },
        child: Text(
          'Iniciar sesión',
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    required bool isHighContrastMode,
    required Color textColor,
  }) {
    final Color backgroundColor = isHighContrastMode 
        ? Colors.white
        : Colors.grey.shade200;
    final Color selectedColor = isHighContrastMode 
        ? AccessibilityProvider.kAccentColor
        : Colors.blue;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: textColor)),
        ],
      ),
      selected: _metadataFilters[value] ?? false,
      backgroundColor: backgroundColor,
      selectedColor: selectedColor,
      onSelected: (bool selected) {
        setState(() {
          _metadataFilters[value] = selected;
        });
        context.read<MapFiltersProvider>().updateFilters(_metadataFilters);
      },
    );
  }
} 