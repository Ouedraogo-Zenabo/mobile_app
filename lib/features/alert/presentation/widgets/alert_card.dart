/*import 'package:flutter/material.dart';
import '../../domain/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;

  const AlertCard({super.key, required this.alert});

  Color getStatusColor() {
    switch (alert.status) {
      case "Urgent": return Colors.red;
      case "Soumise": return Colors.blue;
      case "Transmise": return Colors.orange;
      case "Évaluée": return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData getIcon() {
    switch (alert.icon) {
      case "flood": return Icons.water;
      case "sun": return Icons.wb_sunny;
      case "warning": return Icons.warning;
      default: return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Icône de gauche
            CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              radius: 22,
              child: Icon(getIcon(), color: Colors.blue, size: 26),
            ),

            const SizedBox(width: 12),

            /// Infos texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Ligne du haut : type + badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        alert.type,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor().withOpacity(.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          alert.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "${alert.date.day} ${_monthName(alert.date.month)} ${alert.date.year}",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// Localisation
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          alert.region,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// Personnes affectées
                  Row(
                    children: [
                      const Icon(Icons.people_alt_outlined, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "${alert.affectedPeople} personnes affectées",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Petite fonction pour transformer le mois en texte
  String _monthName(int m) {
    const months = [
      "Jan", "Fév", "Mar", "Avr", "Mai", "Juin",
      "Juil", "Aoû", "Sep", "Oct", "Nov", "Déc"
    ];
    return months[m - 1];
  }
}*/
