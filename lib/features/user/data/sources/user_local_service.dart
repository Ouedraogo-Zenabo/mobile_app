import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Stockage local : Sauvegarde du profil + tokens pour utilisation hors-ligne.
class UserLocalService {
  static const String userKey = "user_profile";
  static const String accessTokenKey = "access_token";
  static const String refreshTokenKey = "refresh_token";

  /// Sauvegarde le profil utilisateur en cache
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, user.toRawJson());
  }

  /// Sauvegarde les tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, accessToken);
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  /// Récupère l'access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  /// Récupère le refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  /// Chargement du profil local
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(userKey);
    if (jsonString == null) return null;
    return UserModel.fromRawJson(jsonString);
  }

  /// Efface tout (déconnexion)
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
  }
/*     Future<void> clearTokens() async {
    // Logic to clear tokens, e.g., remove from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  } */
}

