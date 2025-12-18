import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

/// ------------------------------------------------------------
/// Service : Communique avec ton API backend pour récupérer
///            les infos du profil utilisateur.
/// ------------------------------------------------------------
class UserApiService {
  final String baseUrl;

  UserApiService({required this.baseUrl});

  /// Récupère les infos du profil de l'utilisateur connecté.
  Future<UserModel> fetchUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erreur lors de la récupération du profil.");
    }
  }
}
