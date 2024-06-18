import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'editar_saude_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'cadastrar_saude_screen.dart';
import 'package:pork_manager_mobile/services/saude_item.dart';

class SaudeScreen extends StatefulWidget {
  final String token;

  SaudeScreen({required this.token});

  @override
  _SaudeScreenState createState() => _SaudeScreenState();
}

String decodeString(String input) {
  return utf8.decode(input.runes.toList());
}

class _SaudeScreenState extends State<SaudeScreen> {
  late Future<List<SaudeItem>> futureSaudeItems;
  bool isLoading = true;
  String? errorMessage;
  String? successMessage;

  @override
  void initState() {
    super.initState();
    futureSaudeItems = fetchSaudeItems();
  }

  Future<List<SaudeItem>> fetchSaudeItems() async {
    final url = 'http://10.0.2.2:8080/porkManagerApi/saude/getAllSaudes';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => SaudeItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load items: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Erro ao carregar itens. Por favor, tente novamente mais tarde.';
      });
      print('Error: $error');
      throw error;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteSaudeItem(int id) async {
    final url = 'http://10.0.2.2:8080/porkManagerApi/saude/deleteSaude/$id';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          futureSaudeItems = fetchSaudeItems();
          successMessage = 'Item deletado com sucesso!';
        });
      } else {
        throw Exception('Failed to delete item: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Erro ao deletar item. Por favor, tente novamente mais tarde.';
      });
      print('Error: $error');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Saúde'),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(token: widget.token),
                  ),
                );
              },
            ),
            Spacer(),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : errorMessage != null
            ? Text(errorMessage!)
            : FutureBuilder<List<SaudeItem>>(
          future: futureSaudeItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Erro: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('Nenhum item encontrado.');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];

                  final imageUrl = item.foto != null && item.foto!.isNotEmpty
                      ? 'http://10.0.2.2:8080/porkManagerApi/saude/foto/${item.foto}'
                      : null;

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(

                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tipo de Tratamento: ${decodeString(item.tipoTratamento)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text('Data de Início do Tratamento: ${DateFormat('yyyy-MM-dd').format(item.dataInicioTratamento)}'),
                          SizedBox(height: 4),
                          Text('Peso: ${item.peso} kg'),
                          SizedBox(height: 4),
                          Text('Observações: ${decodeString(item.observacoes)}'),
                          SizedBox(height: 4),
                          Text('Identificador de Orelha: ${item.identificadorOrelha}'),
                        ],
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (imageUrl != null) // exibir ícone de olho apenas se houver imagem
                            IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () {
                                showImageDialog(item.foto!);
                              },
                            ),

                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditarSaudeScreen(
                                    saudeId: item.id,
                                    token: widget.token,
                                    tipoTratamento: item.tipoTratamento,
                                    observacoes: item.observacoes,
                                    dataInicioTratamento: item.dataInicioTratamento,
                                    peso: item.peso,
                                    dataEntradaCio: item.dataEntradaCio,
                                    identificadorOrelha: item.identificadorOrelha,
                                    foto: item.foto,
                                  ),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  setState(() {
                                    futureSaudeItems = fetchSaudeItems();
                                  });
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              if (await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirmar'),
                                  content: Text('Tem certeza que deseja excluir este item?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancelar'),
                                      onPressed: () => Navigator.of(context).pop(false),
                                    ),
                                    TextButton(
                                      child: Text('Excluir'),
                                      onPressed: () => Navigator.of(context).pop(true),
                                    ),
                                  ],
                                ),
                              ) ??
                                  false) {
                                deleteSaudeItem(item.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: successMessage != null
          ? Container(
        color: Colors.green,
        child: ListTile(
          title: Text(successMessage!, style: TextStyle(color: Colors.white)),
          trailing: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                successMessage = null;
              });
            },
          ),
        ),
      )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CadastrarSaudeScreen(token: widget.token),
            ),
          ).then((result) {
            if (result == true) {
              setState(() {
                futureSaudeItems = fetchSaudeItems();
              });
            }
          });
        },
        tooltip: 'Adicionar novo registro de saúde',
        child: Icon(Icons.add),
      ),
    );
  }
}
