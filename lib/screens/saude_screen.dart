import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'editar_saude_screen.dart';
import 'cadastrar_saude_screen.dart';
import 'package:pork_manager_mobile/models/saude_item.dart';
import 'package:pork_manager_mobile/services/saude_service.dart';
import 'package:pork_manager_mobile/services/auth_service.dart';

class SaudeScreen extends StatefulWidget {
  const SaudeScreen({Key? key}) : super(key: key);

  @override
  _SaudeScreenState createState() => _SaudeScreenState();
}

String decodeString(String input) {
  return utf8.decode(input.runes.toList());
}

class _SaudeScreenState extends State<SaudeScreen> {
  late Future<List<SaudeItem>> futureSaudeItems = Future.value([]); // inicializa com uma lista vazia
  String? errorMessage;
  String? successMessage;
  SaudeService? _saudeService;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final token = await _authService.getToken();
    if (token != null) {
      setState(() {
        _saudeService = SaudeService(token: token);
        refreshSaudeItems();
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> refreshSaudeItems() async {
    if (_saudeService != null) {
      setState(() {
        futureSaudeItems = _saudeService!.fetchSaudeItems();
      });
    }
  }

  Future<void> deleteSaudeItem(int id) async {
    if (_saudeService != null) {
      try {
        await _saudeService!.deleteSaudeItem(id);
        setState(() {
          refreshSaudeItems();
          successMessage = 'Item deletado com sucesso!';
        });
      } catch (error) {
        setState(() {
          errorMessage = 'Erro ao deletar item. Por favor, tente novamente mais tarde.';
        });
        print('Error: $error');
      }
    }
  }

  Future<void> showImageDialog(String fotoUrl) async {
    if (_saudeService != null) {
      try {
        await _saudeService!.showImageDialog(context, fotoUrl);
      } catch (error) {
        print('Error loading image: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar imagem. Por favor, tente novamente.'),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Saúde'),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/imagens/logo.png',
                    height: 80,
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Página Inicial'),
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/home',
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () async {
                await _authService.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshSaudeItems,
        child: FutureBuilder<List<SaudeItem>>(
          future: futureSaudeItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhum item encontrado.'));
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
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tipo de Tratamento: ${decodeString(item.tipoTratamento)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Data de Início do Tratamento: ${DateFormat('yyyy-MM-dd').format(item.dataInicioTratamento)}'),
                          const SizedBox(height: 4),
                          Text('Peso: ${item.peso} kg'),
                          const SizedBox(height: 4),
                          Text('Observações: ${decodeString(item.observacoes)}'),
                          const SizedBox(height: 4),
                          Text('Identificador de Orelha: ${item.identificadorOrelha}'),
                          const SizedBox(height: 4),
                          Text('Data de Entrada no Cio: ${item.dataEntradaCio != null ? DateFormat('yyyy-MM-dd').format(item.dataEntradaCio!) : 'Não especificada'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (imageUrl != null)
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                showImageDialog(item.foto!);
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/editar_saude',
                                arguments: {
                                  'saudeId': item.id,
                                  'tipoTratamento': item.tipoTratamento,
                                  'observacoes': item.observacoes,
                                  'dataInicioTratamento': item.dataInicioTratamento,
                                  'peso': item.peso,
                                  'dataEntradaCio': item.dataEntradaCio,
                                  'identificadorOrelha': item.identificadorOrelha,
                                  'foto': item.foto,
                                },
                              ).then((result) {
                                if (result == true) {
                                  refreshSaudeItems();
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              if (await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmar'),
                                  content: const Text('Tem certeza que deseja excluir este item?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancelar'),
                                      onPressed: () => Navigator.of(context).pop(false),
                                    ),
                                    TextButton(
                                      child: const Text('Excluir'),
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
          title: Text(successMessage!, style: const TextStyle(color: Colors.white)),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
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
          Navigator.pushNamed(
            context,
            '/cadastrar_saude',
          ).then((result) {
            if (result == true) {
              refreshSaudeItems();
            }
          });
        },
        tooltip: 'Adicionar novo registro de saúde',
        child: const Icon(Icons.add),
      ),
    );
  }
}
