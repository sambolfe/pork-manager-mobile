import 'package:flutter/material.dart';

class SaudeItem {
  final int id;
  final String tipoTratamento;
  final String observacoes;
  final DateTime dataInicioTratamento;
  final double peso;
  final DateTime? dataEntradaCio;
  final String identificadorOrelha;
  final String? foto; // Adição do campo de foto

  SaudeItem({
    required this.id,
    required this.tipoTratamento,
    required this.observacoes,
    required this.dataInicioTratamento,
    required this.peso,
    this.dataEntradaCio,
    required this.identificadorOrelha,
    this.foto, // Atualização do construtor para aceitar foto
  });

  factory SaudeItem.fromJson(Map<String, dynamic> json) {
    return SaudeItem(
      id: json['id'],
      tipoTratamento: json['tipoTratamento'],
      observacoes: json['observacoes'],
      dataInicioTratamento: DateTime.parse(json['dataInicioTratamento']),
      peso: json['peso'].toDouble(),
      dataEntradaCio: json['dataEntradaCio'] != null ? DateTime.parse(json['dataEntradaCio']) : null,
      identificadorOrelha: json['identificadorOrelha'],
      foto: json['foto'], // Obtenção da foto do JSON
    );
  }
}
