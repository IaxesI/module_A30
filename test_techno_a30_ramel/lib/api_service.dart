import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String _baseUrl = 'https://api.jsonbin.io/v3/b';
  final String _apiKey = r'$2a$10$dVRy5Cv.0ZaEzl5ubMZ2dejqSfAc2NwiIMi/WR4hZFjK.AA/tGWay';

  Future<String?> create(
    Map<String, dynamic> data, {
    String? binName,
    bool isPrivate = true,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'X-Master-Key': _apiKey,
      if (binName != null) 'X-Bin-Name': binName,
      'X-Bin-Private': isPrivate.toString(),
    };

    final body = jsonEncode(data);

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['metadata']['id'];
      } else {
        return 'Erreur : ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Exception : $e';
    }
  }

  Future<String> read(String binId) async {
    final url = '$_baseUrl/$binId/latest';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'X-Master-Key': _apiKey},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return jsonEncode(responseData['record']);
      } else {
        return 'Erreur : ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Exception : $e';
    }
  }

  Future<String> update(String binId, Map<String, dynamic> data) async {
    final url = '$_baseUrl/$binId';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Master-Key': _apiKey,
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return 'Bin mis à jour avec succès';
      } else {
        return 'Erreur : ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Exception : $e';
    }
  }

  Future<String> delete(String binId) async {
    final url = '$_baseUrl/$binId';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'X-Master-Key': _apiKey},
      );

      if (response.statusCode == 200) {
        return 'Bin supprimé avec succès';
      } else {
        return 'Erreur : ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Exception : $e';
    }
  }
}
