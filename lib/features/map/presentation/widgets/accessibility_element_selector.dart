import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../accessibility/domain/accessibility_element.dart';
import '../../../accessibility/domain/community_validation_model.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';

class AccessibilityElementSelector extends StatefulWidget {
  final String markerId;
  final Function(List<ValidationQuestionType>) onElementsSelected;

  const AccessibilityElementSelector({
    Key? key,
    required this.markerId,
    required this.onElementsSelected,
  }) : super(key: key);

  @override
  State<AccessibilityElementSelector> createState() => _AccessibilityElementSelectorState();
}

class _AccessibilityElementSelectorState extends State<AccessibilityElementSelector> {
  final Set<String> _selectedElements = {};
  final List<AccessibilityElement> _allElements = AccessibilityElement.getAllElements();

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final theme = Theme.of(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    
    final backgroundColor = isHighContrastMode 
        ? theme.colorScheme.surface
        : Colors.white;
    final textColor = isHighContrastMode 
        ? theme.colorScheme.onSurface
        : Colors.black87;
    final cardColor = isHighContrastMode 
        ? theme.colorScheme.surfaceVariant
        : Colors.grey.shade50;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: isHighContrastMode 
            ? Border.all(color: theme.colorScheme.outline)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Selecciona los elementos a validar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Marca los elementos de accesibilidad que quieres evaluar en este lugar',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Elements grid
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _allElements.length,
                itemBuilder: (context, index) {
                  final element = _allElements[index];
                  final isSelected = _selectedElements.contains(element.id);
                  
                  return _buildElementCard(
                    element: element,
                    isSelected: isSelected,
                    cardColor: cardColor,
                    textColor: textColor,
                    isHighContrastMode: isHighContrastMode,
                    theme: theme,
                  );
                },
              ),
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: textColor.withOpacity(0.3)),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedElements.isEmpty 
                        ? null 
                        : () => _onContinuePressed(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHighContrastMode 
                          ? theme.colorScheme.primary
                          : Colors.blue,
                      foregroundColor: isHighContrastMode 
                          ? theme.colorScheme.onPrimary
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continuar (${_selectedElements.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementCard({
    required AccessibilityElement element,
    required bool isSelected,
    required Color cardColor,
    required Color textColor,
    required bool isHighContrastMode,
    required ThemeData theme,
  }) {
    final borderColor = isSelected 
        ? (isHighContrastMode ? theme.colorScheme.primary : element.color)
        : (isHighContrastMode ? theme.colorScheme.outline : Colors.grey.shade300);
    
    final backgroundColor = isSelected 
        ? (isHighContrastMode ? theme.colorScheme.primaryContainer : element.color.withOpacity(0.1))
        : cardColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleElement(element.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (isHighContrastMode ? theme.colorScheme.primary : element.color)
                      : (isHighContrastMode ? textColor.withOpacity(0.1) : element.color.withOpacity(0.2)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  element.icon,
                  color: isSelected 
                      ? (isHighContrastMode ? theme.colorScheme.onPrimary : Colors.white)
                      : (isHighContrastMode ? textColor : element.color),
                  size: 24,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  element.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Question count
              Text(
                '${element.questions.length} preguntas',
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              
              // Selected indicator
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: isHighContrastMode 
                        ? theme.colorScheme.primary 
                        : element.color,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleElement(String elementId) {
    setState(() {
      if (_selectedElements.contains(elementId)) {
        _selectedElements.remove(elementId);
      } else {
        _selectedElements.add(elementId);
      }
    });
  }

  void _onContinuePressed() {
    // Collect all questions from selected elements
    final selectedQuestions = <ValidationQuestionType>[];
    
    for (final elementId in _selectedElements) {
      final element = AccessibilityElement.getElementById(elementId);
      if (element != null) {
        selectedQuestions.addAll(element.questions);
      }
    }
    
    // Return the selected questions
    widget.onElementsSelected(selectedQuestions);
    Navigator.pop(context);
  }
}

/// Función auxiliar para mostrar el selector de elementos
Future<void> showAccessibilityElementSelector({
  required BuildContext context,
  required String markerId,
  required Function(List<ValidationQuestionType>) onElementsSelected,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: AccessibilityElementSelector(
          markerId: markerId,
          onElementsSelected: onElementsSelected,
        ),
      ),
    ),
  );
}
