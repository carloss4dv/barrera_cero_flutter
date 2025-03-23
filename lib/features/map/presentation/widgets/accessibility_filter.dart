import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../pages/login_page.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';

class AccessibilityFilter extends StatefulWidget {
  final Function(int) onFilterChanged;
  final int selectedLevel;

  const AccessibilityFilter({
    Key? key, 
    required this.onFilterChanged,
    this.selectedLevel = 0,
  }) : super(key: key);

  @override
  State<AccessibilityFilter> createState() => _AccessibilityFilterState();
}

class _AccessibilityFilterState extends State<AccessibilityFilter> {
  late int _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.selectedLevel;
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
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
        
    // Estilos de texto
    final TextStyle hintStyle = TextStyle(
      color: isHighContrastMode ? textColor.withOpacity(0.7) : Colors.grey,
    );
    final TextStyle buttonStyle = TextStyle(
      color: accentColor,
      fontWeight: FontWeight.bold,
    );
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    hintStyle: hintStyle,
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
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) {
                          return const LoginPage();
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Iniciar sesión',
                    style: buttonStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
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
                widget.onFilterChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
} 