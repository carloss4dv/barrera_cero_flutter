import 'package:flutter/material.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: DropdownButton<int>(
              value: _selectedLevel,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: const [
                DropdownMenuItem(
                  value: 0,
                  child: Text('Nivel de accesibilidad'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('Alta accesibilidad'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('Media accesibilidad'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('Baja accesibilidad'),
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
      ),
    );
  }
} 