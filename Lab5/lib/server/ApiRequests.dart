import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';

class ApiRequests {
  static final String baseUrl = 'http://127.0.0.1:5000'; // Replace with your local IP address and Flask port

  static Future<bool> isInternetConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<void> postRequest(String endpoint, Map<String, dynamic> data) async {
    await _sendRequest('POST', endpoint, data);
  }

  static Future<void> putRequest(String endpoint, Map<String, dynamic> data) async {
    await _sendRequest('PUT', endpoint, data);
  }

  static Future<Map<String, dynamic>> getRequest(String endpoint) async {
    return await _sendRequest('GET', endpoint);
  }

  static Future<void> deleteRequest(String endpoint) async {
    await _sendRequest('DELETE', endpoint);
  }

  static Future<List<Map<String, dynamic>>> getTodos() async {
    final String endpoint = '/todos';
    final bool isConnected = await isInternetConnected();

    if (isConnected) {
      try {
        final http.Response response = await http.get(Uri.parse('$baseUrl$endpoint'));

        if (response.statusCode == 200) {
          final dynamic decodedResponse = jsonDecode(response.body);

          if (decodedResponse == null) {
            // If the response is null, return an empty list
            return [];
          } else if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey("todos")) {
            // If the response has a "todos" key, return its value (a list of todos)
            final List<dynamic> todos = decodedResponse["todos"];
            return todos.cast<Map<String, dynamic>>();
          } else {
            // Unexpected response type, handle accordingly
            print('Unexpected response type when fetching todos');
          }
        } else {
          // Request failed, handle error
          print('Failed to fetch todos. Status code: ${response.statusCode}');
        }
      } catch (e) {
        // Handle exception
        print('Error when trying to fetch todos: $e');
      }
    } else {
      // Handle case where there is no internet connection
      print('No internet connection');
    }

    return [];
  }

  static Future<dynamic> _sendRequest(String method, String endpoint, [Map<String, dynamic>? data]) async {
    final String url = '$baseUrl$endpoint';
    final bool isConnected = await isInternetConnected();

    if (isConnected) {
      try {
        late http.Response response;

        switch (method) {
          case 'POST':
            response = await http.post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(data),
            );
            break;
          case 'PUT':
            response = await http.put(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(data),
            );
            break;
          case 'GET':
            response = await http.get(Uri.parse(url));
            break;
          case 'DELETE':
            response = await http.delete(Uri.parse(url));
            break;
          default:
            throw Exception('Invalid HTTP method');
        }

        if (response.statusCode == 200) {
          if (method == 'GET') {
            return jsonDecode(response.body);
          }
          // Request successful, handle response if needed
        } else {
          // Request failed, handle error
        }
      } catch (e) {
        // Handle exception
      }
    } else {
      // Handle case where there is no internet connection
    }
  }
}
