/*port 'package:flutter/material.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'package:mobile_app/features/alert/domain/alert_model.dart';
import 'features/alert/presentation/pages/new_alert_step1_page.dart'; //  Import de la route vers l’alerte

void main() {
  runApp(const MyApp());
}

/// Initialisation de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Système d’Alerte Précoce',

      //  Gestion des routes
      routes: {
        "/": (context) => const LoginPage(),
        "/new-alert-step1": (context) => NewAlertStep1Page(alert: AlertModel()),
      },

      //  Définit la page par défaut
      initialRoute: "/",
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:mobile_app/features/alert/presentation/pages/create_alert.dart';
import 'features/auth/presentation/pages/login_page.dart';

// IMPORTS POUR LE USER
import 'package:mobile_app/features/user/data/sources/user_api_service.dart';
import 'package:mobile_app/features/user/data/sources/user_local_service.dart';
import 'package:mobile_app/features/user/domain/user_repository.dart';
  

void main() {
  // Initialisation des services User
  final apiService = UserApiService(
    baseUrl: "http://197.239.116.77:3000/api", // 🔥 MET TON URL ICI
  );

  final localService = UserLocalService();

  final userRepository = UserRepository(
    api: apiService,
    local: localService,
  );

  runApp(MyApp(userRepository: userRepository));
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;

  const MyApp({super.key, required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Système d’Alerte Précoce',

      routes: {
        // LoginPage reçoit userRepository et un token vide pour commencer
        "/": (context) => LoginPage(
              userRepository: userRepository,
              token: "",
            ),
        "/create-alert": (context) => CreateAlertPage(),
      },

      initialRoute: "/",
    );
  }
}
