class SaudeItem {
  final int id;
  final double peso;
  final String dataEntradaCio;
  final String tipoTratamento;
  final String dataInicioTratamento;
  final String observacoes;
  final String criadoEm;
  final String atualizadoEm;
  final String? foto; // Adicionando "?" para indicar que foto pode ser nula

  SaudeItem({
    required this.id,
    required this.peso,
    required this.dataEntradaCio,
    required this.tipoTratamento,
    required this.dataInicioTratamento,
    required this.observacoes,
    required this.criadoEm,
    required this.atualizadoEm,
    this.foto,
  });

  // Construtor de fábrica para criar a partir de um mapa JSON
  factory SaudeItem.fromJson(Map<String, dynamic> json) {
    return SaudeItem(
      id: json['id'],
      peso: json['peso'],
      dataEntradaCio: json['dataEntradaCio'],
      tipoTratamento: json['tipoTratamento'],
      dataInicioTratamento: json['dataInicioTratamento'],
      observacoes: json['observacoes'],
      criadoEm: json['criadoEm'],
      atualizadoEm: json['atualizadoEm'],
      foto: json['foto'],
    );
  }
}
