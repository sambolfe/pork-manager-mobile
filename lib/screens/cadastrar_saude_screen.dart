import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pork_manager_mobile/services/saude_service.dart';

class CadastrarSaudeScreen extends StatefulWidget {
  final String token;

  CadastrarSaudeScreen({required this.token});

  @override
  _CadastrarSaudeScreenState createState() => _CadastrarSaudeScreenState();
}

class _CadastrarSaudeScreenState extends State<CadastrarSaudeScreen> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _tipoTratamentoController = TextEditingController();
  final TextEditingController _dataInicioTratamentoController = TextEditingController();
  final TextEditingController _dataEntradaCioController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  List<Map<String, dynamic>> identificadoresOrelha = [];
  int? selectedIdSuino;

  late final SaudeService _saudeService;

  @override
  void initState() {
    super.initState();
    _saudeService = SaudeService(token: widget.token); // Inicializando _saudeService
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
        });
      } else {
        throw Exception('Failed to load identificadores de orelha');
      }
    } catch (error) {
      print('Erro ao buscar identificadores de orelha: $error');
    }
  }

  Future<void> _submitForm() async {
    try {
      // Construir o objeto saudeDto como um mapa
      Map<String, dynamic> fields = {
        'tipoTratamento': _tipoTratamentoController.text,
        'observacoes': _observacoesController.text,
        'dataInicioTratamento': _dataInicioTratamentoController.text,
        'peso': _pesoController.text,
        'idSuino': selectedIdSuino.toString(),
      };

      // Enviar a requisição usando o serviço SaudeService
      await _saudeService.cadastrarSaude(fields, _selectedImage);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadastro de saúde realizado com sucesso')),
      );
    } catch (e) {
      print('Erro ao enviar os dados: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar os dados')),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    setState(() {
      _selectedImage = pickedFile as XFile?;
    });
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _tipoTratamentoController.dispose();
    _dataInicioTratamentoController.dispose();
    _dataEntradaCioController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Saúde'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _pesoController,
              decoration: InputDecoration(labelText: 'Peso'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _tipoTratamentoController,
              decoration: InputDecoration(labelText: 'Tipo de Tratamento'),
            ),
            TextFormField(
              controller: _dataInicioTratamentoController,
              decoration: InputDecoration(labelText: 'Data de Início do Tratamento'),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _dataInicioTratamentoController.text = DateFormat('yyyy-MM-dd').format(date);
                }
              },
            ),
            TextFormField(
              controller: _dataEntradaCioController,
              decoration: InputDecoration(labelText: 'Data de Entrada em Cio'),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _dataEntradaCioController.text = DateFormat('yyyy-MM-dd').format(date);
                }
              },
            ),
            TextFormField(
              controller: _observacoesController,
              decoration: InputDecoration(labelText: 'Observações'),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _pickImage(ImageSource.camera);
                  },
                  child: Text('Tirar Foto'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _pickImage(ImageSource.gallery);
                  },
                  child: Text('Selecionar Foto da Galeria'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            _selectedImage != null
                ? Image.file(
              File(_selectedImage!.path),
              height: 200.0,
              fit: BoxFit.cover,
            )
                : Container(),
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
              onPressed: _submitForm,
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
