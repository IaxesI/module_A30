import 'package:http/http.dart' as http;
import 'dart:convert';

class AgendaService {
  final String _baseUrl = 'https://api.jsonbin.io/v3/b';
  final String _apiKey =
      r'$2a$10$dVRy5Cv.0ZaEzl5ubMZ2dejqSfAc2NwiIMi/WR4hZFjK.AA/tGWay';
  final String _binIDRamelA = '6822f4288561e97a5012e188';
  final String _binIDAdmin = '682c309c8a456b7966a1b2af';

  Future<List<dynamic>> read(String expectedUser) async {
    String url = "";
    if (expectedUser == 'RamelA') {
      url = '$_baseUrl/$_binIDRamelA/latest';
    } else if (expectedUser == "Admin") {
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
          return record['evenements'] as List<dynamic>;
        } else {
          throw Exception('Utilisateur incorrect : ${record['utilisateur']}');
        }
      } else {
        throw Exception(
          'Erreur : ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Exception : $e');
    }
  }

  Future<String> delete(
    String username,
    Map<String, dynamic> eventToDelete,
  ) async {
    var uri = Uri.parse('');
    if (username == 'RamelA') {
      uri = Uri.parse('$_baseUrl/$_binIDRamelA');
    } else if (username == "Admin") {
      uri = Uri.parse('$_baseUrl/$_binIDAdmin');
    }
    final headers = {
      'Content-Type': 'application/json',
      'X-Master-Key': _apiKey,
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['record'];
      final events = data['evenements'];

      // Filtrer tous les événements sauf celui à supprimer
      final updatedEvents =
          events
              .where(
                (event) =>
                    event['title'] != eventToDelete['title'] ||
                    event['description'] != eventToDelete['description'] ||
                    event['date'] != eventToDelete['date'] ||
                    event['startTime'] != eventToDelete['startTime'] ||
                    event['endTime'] != eventToDelete['endTime'],
              )
              .toList();

      final updatedData = {
        'utilisateur': username,
        'evenements': updatedEvents,
      };

      final putResponse = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(updatedData),
      );

      if (putResponse.statusCode == 200) {
        return 'OK';
      } else {
        return 'Erreur lors de la mise à jour';
      }
    } else {
      return 'Erreur lors de la récupération des données';
    }
  }

  Future<String> addEvent(
    String username,
    Map<String, dynamic> newEvent,
  ) async {
    Uri uri;
    if (username == 'RamelA') {
      uri = Uri.parse('$_baseUrl/$_binIDRamelA');
    } else if (username == "Admin") {
      uri = Uri.parse('$_baseUrl/$_binIDAdmin');
    } else {
      return 'Utilisateur inconnu';
    }

    final headers = {
      'Content-Type': 'application/json',
      'X-Master-Key': _apiKey,
    };

    try {
      // 1. Récupérer la liste actuelle des événements
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) {
        return 'Erreur lors de la récupération des données';
      }

      final data = jsonDecode(response.body)['record'];
      final List<dynamic> events = data['evenements'] ?? [];

      // 2. Ajouter le nouvel événement
      events.add(newEvent);

      // 3. Construire la nouvelle structure JSON complète
      final updatedData = {'utilisateur': username, 'evenements': events};

      // 4. Envoyer la mise à jour (PUT)
      final putResponse = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(updatedData),
      );

      if (putResponse.statusCode == 200) {
        return 'OK';
      } else {
        return 'Erreur lors de la mise à jour';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }

  Future<String> updateEvent(String username, Map<String, dynamic> oldEvent, Map<String, dynamic> updatedEvent) async {
  var uri = Uri.parse('');
  if (username == 'RamelA') {
    uri = Uri.parse('$_baseUrl/$_binIDRamelA');
  } else if (username == "Admin") {
    uri = Uri.parse('$_baseUrl/$_binIDAdmin');
  }

  final headers = {
    'Content-Type': 'application/json',
    'X-Master-Key': _apiKey,
  };

  // Récupérer les données actuelles
  final response = await http.get(uri, headers: headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['record'];
    final events = List<Map<String, dynamic>>.from(data['evenements']);

    // Remplacer l'événement à modifier par le nouvel événement
    final updatedEvents = events.map((event) {
      // Comparaison simple par titre + date + startTime (adapter selon ton modèle)
      if (event['title'] == oldEvent['title'] &&
          event['date'] == oldEvent['date'] &&
          event['startTime'] == oldEvent['startTime']) {
        return updatedEvent;
      }
      return event;
    }).toList();

    final updatedData = {
      'utilisateur': username,
      'evenements': updatedEvents,
    };

    // Envoyer la mise à jour
    final putResponse = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(updatedData),
    );

    if (putResponse.statusCode == 200) {
      return 'OK';
    } else {
      return 'Erreur lors de la mise à jour';
    }
  } else {
    return 'Erreur lors de la récupération des données';
  }
}

}
