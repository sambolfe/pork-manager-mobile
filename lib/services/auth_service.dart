import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _apiUrl = 'http://10.0.2.2:8080/porkManagerApi/auth';

  // Chave usada no SharedPreferences
  final String _tokenKey = 'auth_token';

  Future<String?> login(String cpf, String senha) async {
    final Map<String, String> requestData = {
      'cpf': cpf,
      'senha': senha,
    };

    final response = await http.post(
      Uri.parse(_apiUrl),
      body: json.encode(requestData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final token = json.decode(response.body)['token'];
      await _saveToken(token);
      return token;
    } else {
      throw Exception('CPF ou senha inválidos');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
