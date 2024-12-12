import 'dart:convert' as convert;
import '../api_session_client_services/Http.dart';

class LoginApiService {
  final Http http = Http();

  //USER LOGIN
  Future<Map<String, dynamic>> login(dynamic data) async {
    final response = await http.login('/api/users/login', data);
    final responseData = convert.json.decode(response.body);

    responseData['status'] = response.statusCode;

    return responseData;
  }
}
