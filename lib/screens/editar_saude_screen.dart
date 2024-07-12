import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pork_manager_mobile/services/saude_service.dart';
import 'package:pork_manager_mobile/services/auth_service.dart';

class EditarSaudeScreen extends StatefulWidget {
  final int saudeId;
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

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _removeImage = false;

  late SaudeService _saudeService;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tipoTratamentoController = TextEditingController(text: widget.tipoTratamento);
    _observacoesController = TextEditingController(text: widget.observacoes);
    _dataInicioTratamentoController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.dataInicioTratamento));
    _pesoController = TextEditingController(text: widget.peso.toString());
    _dataEntradaCioController = TextEditingController(
      text: widget.dataEntradaCio != null ? DateFormat('yyyy-MM-dd').format(widget.dataEntradaCio!) : '',
    );

    _initServices();
  }

  Future<void> _initServices() async {
    final token = await _authService.getToken();
    if (token != null) {
      _saudeService = SaudeService();
      await fetchIdentificadoresOrelha();
    } else {
      // Redirecionar para tela de login se o token não estiver disponível
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> fetchIdentificadoresOrelha() async {
    try {
      final data = await _saudeService.fetchIdentificadoresOrelha();
      setState(() {
        identificadoresOrelha = data;

        final matched = identificadoresOrelha.firstWhere(
              (item) => item['identificadorOrelha'] == widget.identificadorOrelha,
          orElse: () => {},
        );
        selectedIdSuino = matched.isNotEmpty ? matched['idSuino'] : null;
      });
    } catch (error) {
      print('Erro ao buscar identificadores de orelha: $error');
    }
  }

  Future<void> _submitForm() async {
    try {
      await _saudeService.updateSaude(
        saudeId: widget.saudeId,
        tipoTratamento: _tipoTratamentoController.text,
        observacoes: _observacoesController.text,
        dataInicioTratamento: _dataInicioTratamentoController.text,
        peso: double.parse(_pesoController.text),
        idSuino: selectedIdSuino!,
        removerFoto: _removeImage,
        novaFotoBytes: _selectedImage != null ? await _selectedImage!.readAsBytes() : null,
        dataEntradaCio: _dataEntradaCioController.text,
      );

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saúde atualizada com sucesso')),
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
      _removeImage = false;
    });
  }

  Future<void> showImageDialog(String fotoUrl) async {
    try {
      await _saudeService.showImageDialog(context, fotoUrl);
    } catch (error) {
      print('Error loading image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar imagem. Por favor, tente novamente.'),
        ),
      );
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

  String? getFileNameFromUrl(String? url) {
    if (url == null) return null;
    RegExp regex = RegExp(r'[^\\\/]+$');
    return regex.stringMatch(url);
  }

  @override
  Widget build(BuildContext context) {
    String? nomeArquivo = getFileNameFromUrl(widget.foto);
    String? fotoUrl = nomeArquivo != null ? 'http://10.0.2.2:8080/porkManagerApi/saude/foto/$nomeArquivo' : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Saúde'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
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
            SizedBox(height: 16),
            if (_selectedImage != null)
              Column(
                children: [
                  Image.file(File(_selectedImage!.path), height: 200, width: 200),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _removeImage = true;
                      });
                    },
                    child: Text('Remover Imagem'),
                  ),
                ],
              ),
            if (_selectedImage == null && fotoUrl != null)
              Column(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.image),
                    label: Text('Visualizar Imagem'),
                    onPressed: () {
                      showImageDialog(fotoUrl);
                    },
                  ),
                ],
              ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Tirar Foto'),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text('Escolher Imagem'),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            SizedBox(height: 16),
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
