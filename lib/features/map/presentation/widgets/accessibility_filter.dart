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
        // Barra de usuario y niveles de accesibilidad
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [                      _buildAccessibilityLevelChip(
                        label: 'Todos',
                        value: 0,
                        color: Colors.grey.shade700,
                        isSelected: _selectedLevel == 0,
                        onTap: () => _updateSelectedLevel(0),
                      ),
                      const SizedBox(width: 8),                      
                      _buildAccessibilityLevelChip(
                        label: 'Alta',
                        value: 1,
                        color: Colors.green.shade600,
                        isSelected: _selectedLevel == 1,
                        onTap: () => _updateSelectedLevel(1),
                      ),
                      const SizedBox(width: 8),
                      _buildAccessibilityLevelChip(
                        label: 'Media',
                        value: 2,
                        color: Colors.amber.shade600,
                        isSelected: _selectedLevel == 2,
                        onTap: () => _updateSelectedLevel(2),
                      ),
                      const SizedBox(width: 8),
                      _buildAccessibilityLevelChip(
                        label: 'Baja',
                        value: 3,
                        color: Colors.red.shade600,
                        isSelected: _selectedLevel == 3,
                        onTap: () => _updateSelectedLevel(3),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 24,
                width: 1,
                color: borderColor,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _buildUserButton(currentUser, accentColor, textColor),
            ],
          ),
        ),

        // Filtros de accesibilidad
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botón de filtros
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isMetadataExpanded = !_isMetadataExpanded;
                    });
                  },
                  icon: Icon(
                    _isMetadataExpanded ? Icons.expand_less : Icons.expand_more,
                    color: textColor,
                    size: 18,
                  ),
                  label: Text(
                    'Filtros de accesibilidad',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              
              // Panel de filtros
              if (_isMetadataExpanded)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  // Sin fondo ni borde, solo los botones
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVerticalFilterButton(
                        label: 'Rampa',
                        value: 'hasRamp',
                        icon: Icons.accessible,
                        isSelected: _metadataFilters['hasRamp'] ?? false,
                        onTap: () => _toggleFilter('hasRamp'),
                      ),
                      const SizedBox(height: 8),
                      _buildVerticalFilterButton(
                        label: 'Ascensor',
                        value: 'hasElevator',
                        icon: Icons.elevator,
                        isSelected: _metadataFilters['hasElevator'] ?? false,
                        onTap: () => _toggleFilter('hasElevator'),
                      ),
                      const SizedBox(height: 8),
                      _buildVerticalFilterButton(
                        label: 'Baño Accesible',
                        value: 'hasAccessibleBathroom',
                        icon: Icons.wc,
                        isSelected: _metadataFilters['hasAccessibleBathroom'] ?? false,
                        onTap: () => _toggleFilter('hasAccessibleBathroom'),
                      ),
                      const SizedBox(height: 8),
                      _buildVerticalFilterButton(
                        label: 'Señalización Braille',
                        value: 'hasBrailleSignage',
                        icon: Icons.format_size,
                        isSelected: _metadataFilters['hasBrailleSignage'] ?? false,
                        onTap: () => _toggleFilter('hasBrailleSignage'),
                      ),
                      const SizedBox(height: 8),
                      _buildVerticalFilterButton(
                        label: 'Guía de Audio',
                        value: 'hasAudioGuidance',
                        icon: Icons.hearing,
                        isSelected: _metadataFilters['hasAudioGuidance'] ?? false,
                        onTap: () => _toggleFilter('hasAudioGuidance'),
                      ),
                      const SizedBox(height: 8),
                      _buildVerticalFilterButton(
                        label: 'Pavimento Táctil',
                        value: 'hasTactilePavement',
                        icon: Icons.texture,
                        isSelected: _metadataFilters['hasTactilePavement'] ?? false,
                        onTap: () => _toggleFilter('hasTactilePavement'),
                      ),
                      const SizedBox(height: 16),
                      _buildVerticalClearButton(
                        label: 'Limpiar Filtros',
                        onTap: () {
                          setState(() {
                            for (var key in _metadataFilters.keys) {
                              _metadataFilters[key] = false;
                            }
                          });
                          context.read<MapFiltersProvider>().updateFilters(_metadataFilters);
                        },
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

  void _updateSelectedLevel(int level) {
    setState(() {
      _selectedLevel = level;
    });
    context.read<MapFiltersProvider>().updateAccessibilityLevel(level);
  }

  Widget _buildAccessibilityLevelChip({
    required String label,
    required int value,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserButton(User? currentUser, Color accentColor, Color textColor) {
    if (currentUser != null) {
      final displayName = currentUser.displayName ?? currentUser.email ?? 'Usuario';
      return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/profile', arguments: currentUser.uid);
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: accentColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                displayName,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pushNamed('/login');
        },
        icon: const Icon(Icons.login, size: 18),
        label: const Text(
          'Iniciar sesión',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
  }

  void _toggleFilter(String key) {
    setState(() {
      _metadataFilters[key] = !(_metadataFilters[key] ?? false);
    });
    context.read<MapFiltersProvider>().updateFilters(_metadataFilters);
  }

  Widget _buildVerticalFilterButton({
    required String label,
    required String value,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final Color backgroundColor = isSelected 
        ? Colors.black
        : Colors.white;
    final Color textColor = isSelected 
        ? Colors.white
        : Colors.black;
    final Color iconColor = isSelected 
        ? Colors.white
        : Colors.black;
    final Color borderColor = isSelected
        ? Colors.black
        : Colors.grey.withOpacity(0.3);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalClearButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear, color: Colors.black, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}