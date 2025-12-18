import '../domain/alert_model.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;

  AlertService._internal();

  final List<AlertModel> _alerts = [];

  // Ajouter une alerte
  void addAlert(AlertModel alert) {
    _alerts.add(alert);
  }

  // Récupérer toutes les alertes
  List<AlertModel> getAlerts() {
    return _alerts;
  }
}
