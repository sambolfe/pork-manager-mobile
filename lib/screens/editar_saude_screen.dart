import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'saude_screen.dart';

class EditarSaudeScreen extends StatefulWidget {
  final int saudeId;
  final String token;

  EditarSaudeScreen({required this.saudeId, required this.token});

  @override
  _EditarSaudeScreenState createState() => _EditarSaudeScreenState();
}

class _EditarSaudeScreenState extends State<EditarSaudeScreen> {
  // Simulação de dados pré-definidos
  String _peso = '50.50';
  String _tipoTratamento = 'Vermifugação';
  String _dataInicioTratamento = '2024-01-05';
  String _dataEntradaCio = '2024-01-05';
  String _observacoes = 'Sem observações';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Saúde'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(token: widget.token),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Gerenciar Saúde'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SaudeScreen(token: widget.token),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Peso: $_peso'),
            Text('Tipo de Tratamento: $_tipoTratamento'),
            Text('Data de Início do Tratamento: $_dataInicioTratamento'),
            Text('Data de Entrada em Cio: $_dataEntradaCio'),
            Text('Observações: $_observacoes'),
            ElevatedButton(
              onPressed: () {
                // Adicione o código para editar os dados no servidor
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
