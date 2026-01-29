import 'package:flutter/material.dart';

class StatusHelper {
  static StatusStyle getStyle(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
      case 'brouillon':
        return StatusStyle(
          label: 'Brouillon',
          backgroundColor: const Color(0xFFFCE8E6),
          textColor: const Color(0xFFC7C7C7),
        );
      case 'validé':
      case 'valide':
        return StatusStyle(
          label: 'Validé',
          backgroundColor: const Color(0xFFDAF5E0),
          textColor: const Color(0xFF1E8E3E),
        );

      case 'validated':
      case 'unloaded':
        return StatusStyle(
          label: 'Déchargé',
          backgroundColor: const Color(0xFFDAF5E0),
          textColor: const Color(0xFF1E8E3E),
        );

      case 'synchronisé':
        return StatusStyle(
          label: 'Synchronisé',
          backgroundColor: const Color(0xFFDAF5E0),
          textColor: const Color(0xFF1E8E3E),
        );

      case 'ok_for_control':
      case 'ok_pour_controle':
        return StatusStyle(
          label: 'OK pour contrôle',
          backgroundColor: const Color(0xFFDAF5E0),
          textColor: const Color(0xFF1E8E3E),
        );

      case 'rejeté':
      case 'rejete':
        return StatusStyle(
          label: 'Rejeté',
          backgroundColor: const Color(0xFFFCE8E6),
          textColor: const Color(0xFFD93025),
        );

      case 'echec':
      case 'échec':
        return StatusStyle(
          label: 'Echec',
          backgroundColor: const Color(0xFFFCE8E6),
          textColor: const Color(0xFFD93025),
        );

      case 'rejected':
        return StatusStyle(
          label: 'Rejeté',
          backgroundColor: const Color(0xFFFCE8E6),
          textColor: const Color(0xFFD93025),
        );

      case 'returned':
        return StatusStyle(
          label: 'Retourné',
          backgroundColor: const Color.fromARGB(255, 249, 247, 227),
          textColor: const Color.fromARGB(255, 231, 204, 3),
        );

      case 'en attente':
      case 'pending':
      case 'en_attente':
        return StatusStyle(
          label: 'En attente',
          backgroundColor: const Color(0xFFFFF4CC),
          textColor: const Color(0xFFB78700),
        );
      default:
        return StatusStyle(
          label: status,
          backgroundColor: const Color(0xFFFFF4CC),
          textColor: const Color(0xFFB78700),
        );
    }
  }
}

class StatusStyle {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusStyle({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}
