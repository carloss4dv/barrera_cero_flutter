import 'package:flutter/material.dart';
import 'community_validation_model.dart';

/// Modelo que representa un elemento de accesibilidad que se puede validar
class AccessibilityElement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<ValidationQuestionType> questions;
  final Color color;

  const AccessibilityElement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.questions,
    required this.color,
  });

  /// Lista de todos los elementos de accesibilidad disponibles
  static List<AccessibilityElement> getAllElements() {
    return [      AccessibilityElement(
        id: 'ramps',
        name: 'Rampas',
        description: '¿Existen rampas de acceso?',
        icon: Icons.accessible,
        color: Colors.blue,
        questions: [
          ValidationQuestionType.rampExists,
        ],
      ),
      AccessibilityElement(
        id: 'elevators',
        name: 'Ascensores',
        description: '¿Existe un ascensor?',
        icon: Icons.elevator,
        color: Colors.green,
        questions: [
          ValidationQuestionType.elevatorExists,
        ],
      ),
      AccessibilityElement(
        id: 'bathrooms',
        name: 'Baños Accesibles',
        description: '¿Existe un baño accesible?',
        icon: Icons.wc,
        color: Colors.purple,
        questions: [
          ValidationQuestionType.accessibleBathroomExists,
        ],
      ),
      AccessibilityElement(
        id: 'braille',
        name: 'Señalización Braille',
        description: '¿Existe señalización en Braille?',
        icon: Icons.format_size,
        color: Colors.orange,
        questions: [
          ValidationQuestionType.brailleSignageExists,
        ],
      ),
      AccessibilityElement(
        id: 'audio',
        name: 'Guía de Audio',
        description: '¿Existe guía de audio?',
        icon: Icons.hearing,
        color: Colors.teal,
        questions: [
          ValidationQuestionType.audioGuidanceExists,
        ],
      ),      AccessibilityElement(
        id: 'tactile',
        name: 'Pavimento Táctil',
        description: '¿Existe pavimento táctil?',
        icon: Icons.texture,
        color: Colors.brown,
        questions: [
          ValidationQuestionType.tactilePavementExists,
        ],
      ),
    ];
  }

  /// Obtiene un elemento por su ID
  static AccessibilityElement? getElementById(String id) {
    try {
      return getAllElements().firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el elemento que contiene una pregunta específica
  static AccessibilityElement? getElementByQuestion(ValidationQuestionType question) {
    try {
      return getAllElements().firstWhere((element) => element.questions.contains(question));
    } catch (e) {
      return null;
    }
  }
}
