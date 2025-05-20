import 'package:http/http.dart' as http;
import 'dart:convert';

class AgendaService {

  final String _baseUrl = 'https://api.jsonbin.io/v3/b';
  final String _apiKey = r'$2a$10$dVRy5Cv.0ZaEzl5ubMZ2dejqSfAc2NwiIMi/WR4hZFjK.AA/tGWay';
  final String _binIDRamelA = '6822f4288561e97a5012e188';
  final String _binIDAdmin = '682c309c8a456b7966a1b2af ';

  Future<String> read(String expectedUser) async {
    String url = "";
    if(expectedUser == 'RamelA'){
      url = '$_baseUrl/$_binIDRamelA/latest';
    } else if(expectedUser == "Admin"){
      url = '$_baseUrl/$_binIDAdmin/latest';
    }
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'X-Master-Key': _apiKey},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final record = responseData['record'];

      if (record['utilisateur'] == expectedUser) {
        // On retourne les événements sous forme de chaîne JSON formatée
        final evenements = record['evenements'];
        return jsonEncode(evenements);
      } else {
        return 'Utilisateur incorrect : ${record['utilisateur']}';
      }
    } else {
      return 'Erreur : ${response.statusCode} - ${response.reasonPhrase}';
    }
  } catch (e) {
    return 'Exception : $e';
  }
}

}