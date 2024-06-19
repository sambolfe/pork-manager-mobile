import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';


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

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _removeImage = false;

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

          // Set selectedIdSuino baseado no identificadorOrelha
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

  Future<void> _submitForm() async {
    final url = Uri.parse('http://10.0.2.2:8080/porkManagerApi/saude/updateSaude/${widget.saudeId}');

    try {
      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({
        'Authorization': 'Bearer ${widget.token}',
      });

      // Construir o objeto saudeDto como um mapa
      Map<String, dynamic> fields = {
        'tipoTratamento': _tipoTratamentoController.text,
        'observacoes': _observacoesController.text,
        'dataInicioTratamento': _dataInicioTratamentoController.text,
        'peso': _pesoController.text,
        'idSuino': selectedIdSuino.toString(),
        'removerFoto': _removeImage.toString(),
      };

      // adicionar campos de texto ao corpo da requisição
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // adicionar a imagem ao corpo da requisição se houver uma nova selecionada
      if (_selectedImage != null) {
        String fileName = _selectedImage!.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto',
            _selectedImage!.path,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var response = await http.Response.fromStream(await request.send());

      // Verificar o status da resposta
      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saúde atualizada com sucesso')),
        );
      } else {
        throw Exception('Failed to update saúde');
      }
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
      _removeImage = false; // Desmarca a remoção da imagem existente se uma nova imagem for selecionada
    });
  }

  Future<void> showImageDialog(String fotoUrl) async {
    // extrair apenas o nome do arquivo da variável fotoUrl usando expressão regular
    RegExp regex = RegExp(r'[^\\\/]+$');
    String? nomeArquivo = regex.stringMatch(fotoUrl);

    // verificar se nomeArquivo não é nulo antes de construir a URL
    if (nomeArquivo != null) {
      final baseUrl = 'http://10.0.2.2:8080/porkManagerApi/saude/foto/';
      final url = baseUrl + Uri.encodeComponent(nomeArquivo);
      print('URL da imagem: $url');

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        );
        print('Response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          // Converter os bytes da imagem em um widget de imagem
          Uint8List bytes = response.bodyBytes;
          Image image = Image.memory(bytes);

          // Exibir a imagem em um dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 500, maxHeight: 500),
                  child: image,
                ),
              );
            },
          );
        } else {
          throw Exception('Failed to load image: ${response.statusCode}');
        }
      } catch (error) {
        print('Error loading image: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar imagem. Por favor, tente novamente.'),
          ),
        );
      }
    } else {
      print('Nome do arquivo não encontrado.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: Nome do arquivo da imagem não encontrado.'),
        ),
      );
    }
  }

  String decodeString(String input) {
    return utf8.decode(input.runes.toList());
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
    // Construa a URL da foto com o nome do arquivo extraído
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
            SizedBox(height: 16),
            if (_selectedImage != null)
              Column(
                children: [
                  Image.file(File(_selectedImage!.path), height: 200, width: 200),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _removeImage = true; // Marca a remoção da imagem existente
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
