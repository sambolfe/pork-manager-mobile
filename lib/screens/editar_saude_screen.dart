import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarSaudeScreen extends StatefulWidget {
  final int saudeId;
  final String token;
  final String tipoTratamento;
  final String observacoes;
  final DateTime dataInicioTratamento;
  final double peso;
  final DateTime? dataEntradaCio;
  final String identificadorOrelha;
  final String? foto;

  const EditarSaudeScreen({
    Key? key,
    required this.saudeId,
    required this.token,
    required this.tipoTratamento,
    required this.observacoes,
    required this.dataInicioTratamento,
    required this.peso,
    this.dataEntradaCio,
    required this.identificadorOrelha,
    this.foto,
  }) : super(key: key);

  @override
  _EditarSaudeScreenState createState() => _EditarSaudeScreenState();
}

class _EditarSaudeScreenState extends State<EditarSaudeScreen> {
  late TextEditingController _tipoTratamentoController;
  late TextEditingController _observacoesController;
  late TextEditingController _dataInicioTratamentoController;
  late TextEditingController _pesoController;
  late TextEditingController _dataEntradaCioController;

  List<Map<String, dynamic>> identificadoresOrelha = [];
  int? selectedIdSuino;

  @override
  void initState() {
    super.initState();
    _tipoTratamentoController = TextEditingController(text: widget.tipoTratamento);
    _observacoesController = TextEditingController(text: decodeString(widget.observacoes));
    _dataInicioTratamentoController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.dataInicioTratamento));
    _pesoController = TextEditingController(text: widget.peso.toString());
    _dataEntradaCioController = TextEditingController(
      text: widget.dataEntradaCio != null ? DateFormat('yyyy-MM-dd').format(widget.dataEntradaCio!) : '',
    );

    fetchIdentificadoresOrelha();
  }

  Future<void> fetchIdentificadoresOrelha() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/porkManagerApi/suino/getAllIdentificadoresOrelha'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          identificadoresOrelha = data.map<Map<String, dynamic>>((item) => {
            'idSuino': item['idSuino'],
            'identificadorOrelha': item['identificadorOrelha'],
          }).toList();

          // Set selectedIdSuino based on identificadorOrelha from the widget
          final matched = identificadoresOrelha.firstWhere(
                (item) => item['identificadorOrelha'] == widget.identificadorOrelha,
            orElse: () => {},
          );
          selectedIdSuino = matched.isNotEmpty ? matched['idSuino'] : null;
        });
      } else {
        throw Exception('Failed to load identificadores de orelha');
      }
    } catch (error) {
      print('Erro ao buscar identificadores de orelha: $error');
    }
  }

  @override
  void dispose() {
    _tipoTratamentoController.dispose();
    _observacoesController.dispose();
    _dataInicioTratamentoController.dispose();
    _pesoController.dispose();
    _dataEntradaCioController.dispose();
    super.dispose();
  }

  Future<void> updateSaude() async {
    final url = 'http://10.0.2.2:8080/porkManagerApi/saude/updateSaude/${widget.saudeId}';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode({
          'tipoTratamento': _tipoTratamentoController.text,
          'observacoes': _observacoesController.text,
          'dataInicioTratamento': _dataInicioTratamentoController.text,
          'peso': double.tryParse(_pesoController.text) ?? 0.0,
          'dataEntradaCio': _dataEntradaCioController.text.isNotEmpty
              ? _dataEntradaCioController.text
              : null,
          'idSuino': selectedIdSuino,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saúde atualizada com sucesso!')));
      } else {
        throw Exception('Failed to update saúde');
      }
    } catch (error) {
      print('Erro ao atualizar saúde: $error');
    }
  }

  String decodeString(String input) {
    return utf8.decode(input.runes.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Saúde'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tipoTratamentoController,
              decoration: InputDecoration(labelText: 'Tipo de Tratamento'),
            ),
            TextField(
              controller: _observacoesController,
              decoration: InputDecoration(labelText: 'Observações'),
            ),
            TextField(
              controller: _dataInicioTratamentoController,
              decoration: InputDecoration(labelText: 'Data de Início do Tratamento'),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: widget.dataInicioTratamento,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _dataInicioTratamentoController.text = DateFormat('yyyy-MM-dd').format(date);
                }
              },
            ),
            TextField(
              controller: _pesoController,
              decoration: InputDecoration(labelText: 'Peso (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _dataEntradaCioController,
              decoration: InputDecoration(labelText: 'Data de Entrada no Cio'),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: widget.dataEntradaCio ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _dataEntradaCioController.text = DateFormat('yyyy-MM-dd').format(date);
                }
              },
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<int>(
              value: selectedIdSuino,
              decoration: InputDecoration(labelText: 'Identificador de Orelha'),
              items: identificadoresOrelha.map((item) {
                return DropdownMenuItem<int>(
                  value: item['idSuino'],
                  child: Text(item['identificadorOrelha']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedIdSuino = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: updateSaude,
              child: Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
