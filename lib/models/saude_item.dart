import 'package:flutter/material.dart';

class SaudeItem {
  final int id;
  final String tipoTratamento;
  final String observacoes;
  final DateTime dataInicioTratamento;
  final double peso;
  final DateTime? dataEntradaCio;
  final String identificadorOrelha;
  final String? foto;

  SaudeItem({
    required this.id,
    required this.tipoTratamento,
    required this.observacoes,
    required this.dataInicioTratamento,
    required this.peso,
    this.dataEntradaCio,
    required this.identificadorOrelha,
    this.foto,
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
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipoTratamento': tipoTratamento,
      'observacoes': observacoes,
      'dataInicioTratamento': dataInicioTratamento.toIso8601String(),
      'peso': peso,
      'dataEntradaCio': dataEntradaCio?.toIso8601String(),
      'identificadorOrelha': identificadorOrelha,
      'foto': foto,
    };
  }
}
