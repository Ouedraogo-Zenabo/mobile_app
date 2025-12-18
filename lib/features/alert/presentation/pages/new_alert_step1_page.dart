import 'package:flutter/material.dart';
import 'package:mobile_app/features/alert/domain/alert_model.dart';
import 'new_alert_step1_page_fixed.dart';

/// Wrapper to preserve original export `NewAlertStep1Page`.
class NewAlertStep1Page extends StatelessWidget {
  final AlertModel alert;
  const NewAlertStep1Page({super.key, required this.alert});


  @override
  Widget build(BuildContext context) => NewAlertStep1PageFixed(alert: alert);
}

