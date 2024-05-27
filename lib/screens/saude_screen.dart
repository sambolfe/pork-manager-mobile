import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pork_manager_mobile/services/saude_item.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'cadastrar_saude_screen.dart';
import 'editar_saude_screen.dart';

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
    return ListTile(
    title: Text(decodeString(item.tipoTratamento)),
    subtitle: Text('Início: ${item.dataInicioTratamento}\nPeso: ${item.peso} kg\nObservações: ${decodeString(item.observacoes)}'),
    trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditarSaudeScreen(saudeId: item.id, token: widget.token),
            ),
          );
        },
      ),
    IconButton(
    icon: Icon(Icons.delete, color: Colors.red),
    onPressed: () async {
    if (await showDialog<bool>(
    context: context,                              builder: (context) => AlertDialog(
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CadastrarSaudeScreen(token: widget.token),
                ),
              );
            },
            tooltip: 'Adicionar novo registro de saúde',
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
