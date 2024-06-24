import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pork_manager_mobile/models/saude_item.dart';

class SaudeService {
  final String token;

  SaudeService({required this.token});

  Future<List<SaudeItem>> fetchSaudeItems() async {
    final url = 'http://10.0.2.2:8080/porkManagerApi/saude/getAllSaudes';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => SaudeItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load items: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
      throw error;
    }
  }

  Future<void> deleteSaudeItem(int id) async {
    final url = 'http://10.0.2.2:8080/porkManagerApi/saude/deleteSaude/$id';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete item: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
      throw error;
    }
  }

  Future<void> showImageDialog(BuildContext context, String fotoUrl) async {
    RegExp regex = RegExp(r'[^\\\/]+$');
    String? nomeArquivo = regex.stringMatch(fotoUrl);

    if (nomeArquivo != null) {
      final baseUrl = 'http://10.0.2.2:8080/porkManagerApi/saude/foto/';
      final url = baseUrl + Uri.encodeComponent(nomeArquivo);
      print('URL da imagem: $url');

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          Uint8List bytes = response.bodyBytes;
          Image image = Image.memory(bytes);

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

  Future<void> cadastrarSaude(Map<String, dynamic> fields, XFile? selectedImage) async {
    final url = Uri.parse('http://10.0.2.2:8080/porkManagerApi/saude/saveSaude');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Adicionar campos de texto ao corpo da requisição
      fields.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Adicionar a imagem ao corpo da requisição se houver uma nova selecionada
      if (selectedImage != null) {
        String fileName = selectedImage.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto',
            selectedImage.path,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var response = await http.Response.fromStream(await request.send());

      // Verificar o status da resposta
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to save saúde: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Erro ao enviar os dados: $e');
      throw e;
    }
  }

  Future<void> updateSaudeItem(int id, Map<String, dynamic> fields, File? imageFile, bool removeImage) async {
    final url = Uri.parse('http://10.0.2.2:8080/porkManagerApi/saude/updateSaude/$id');

    try {
      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Adicionar campos de texto ao corpo da requisição
      fields.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Adicionar a imagem ao corpo da requisição se houver uma nova selecionada
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto',
            imageFile.path,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // Adicionar flag para remover imagem
      if (removeImage) {
        request.fields['removerFoto'] = 'true';
      }

      var response = await http.Response.fromStream(await request.send());

      // Verificar o status da resposta
      if (response.statusCode == 200) {
        print('Saúde atualizada com sucesso');
      } else {
        throw Exception('Failed to update saúde');
      }
    } catch (e) {
      print('Erro ao enviar os dados: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> fetchIdentificadoresOrelha() async {
    final url = Uri.parse('http://10.0.2.2:8080/porkManagerApi/suino/getAllIdentificadoresOrelha');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((item) => {
          'idSuino': item['idSuino'],
          'identificadorOrelha': item['identificadorOrelha'],
        }).toList();
      } else {
        throw Exception('Failed to load identificadores de orelha');
      }
    } catch (error) {
      print('Erro ao buscar identificadores de orelha: $error');
      throw error;
    }
  }


  Future<void> updateSaude({
    required int saudeId,
    required String tipoTratamento,
    required String observacoes,
    required String dataInicioTratamento,
    required double peso,
    required int idSuino,
    required bool removerFoto,
    Uint8List? novaFotoBytes,
  }) async {
    final url = Uri.parse('http://10.0.2.2:8080/porkManagerApi/saude/updateSaude/$saudeId');

    try {
      var request = http.MultipartRequest('PUT', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      Map<String, String> fields = {
        'tipoTratamento': tipoTratamento,
        'observacoes': observacoes,
        'dataInicioTratamento': dataInicioTratamento,
        'peso': peso.toString(),
        'idSuino': idSuino.toString(),
        'removerFoto': removerFoto.toString(),
      };

      request.fields.addAll(fields);

      if (novaFotoBytes != null) {
        String fileName = 'nova_imagem.jpeg';
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
            novaFotoBytes,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode != 200) {
        throw Exception('Failed to update saúde: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Erro ao enviar os dados: $e');
      throw e;
    }
  }
}