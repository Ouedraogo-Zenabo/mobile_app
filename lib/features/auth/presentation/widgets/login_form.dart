


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/user/domain/user_repository.dart';
import 'package:mobile_app/features/user/data/models/user_model.dart';
import '../../domain/auth_repository.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

/// Formulaire Login totalement RESPONSIVE
class LoginForm extends StatefulWidget {
  final UserRepository userRepository;
  final String token;

  const LoginForm({
    super.key,
    required this.userRepository,
    required this.token,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final authRepository = AuthRepository();

  bool _loading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      try {
        // Appel API pour la connexion
        final url = Uri.parse('http://197.239.116.77:3000/api/v1/auth/login');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        print("Login Response Status: ${response.statusCode}");
        print("Login Response Body: ${response.body}");

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final data = decoded['data'];

          final accessToken = data['accessToken'] as String?;
          final refreshToken = data['refreshToken'] as String?;
          final user = data['user'];

          // 🔥 SAUVEGARDER LES TOKENS
          if (accessToken != null && accessToken.isNotEmpty) {
            await widget.userRepository.local.saveTokens(accessToken, refreshToken ?? '');
            print("✅ Tokens sauvegardés");
          }

          // Sauvegarder le profil utilisateur
          final userModel = UserModel.fromJson(user);
          await widget.userRepository.local.saveUser(userModel);
          print("✅ Profil utilisateur sauvegardé");

          // Navigation vers le Dashboard
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardPage(
                  userRepository: widget.userRepository,
                  token: accessToken ?? widget.token,
                ),
              ),
            );
          }
        } else {
          final decoded = jsonDecode(response.body);
          setState(() {
            _errorMessage =
                decoded['error']?['message'] ?? "Erreur de connexion (${response.statusCode})";
          });
        }
      } catch (e) {
        print("ERROR: $e");
        setState(() => _errorMessage = "Erreur réseau : $e");
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 400;
    final isTablet = size.width > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth > 500
            ? 400
            : constraints.maxWidth * 0.9;

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: contentWidth.toDouble(),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// Logo responsive
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Image.network(
                        'data:image/jpeg;base64,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',
                        width: isTablet ? 150 : 110,
                        height: isTablet ? 150 : 110,
                        fit: BoxFit.contain,
                      ),
                    ),

                    /// Message d'erreur
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        color: Colors.red[100],
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[900]),
                        ),
                      ),

                    /// Champ Email
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: "Adresse mail",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Champ obligatoire" : null,
                    ),

                    const SizedBox(height: 16),

                    /// Champ Mot de passe
                    TextFormField(
                    controller: _passwordCtrl,
                    obscureText: !_isPasswordVisible,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Champ obligatoire" : null,
                  ),


                    const SizedBox(height: 24),

                    /// Bouton Connexion Responsive
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Se connecter",
                                style: TextStyle(
                                  fontSize: isSmall ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}