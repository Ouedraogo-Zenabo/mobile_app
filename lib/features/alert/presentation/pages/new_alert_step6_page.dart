









///////////////////////////////////////////////////////////////////////////
library;

/*import 'package:flutter/material.dart';
import 'package:mobile_app/features/alert/presentation/pages/confirmation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/alert_model.dart';
import 'dart:convert';


class NewAlertStep6Page extends StatelessWidget {
  final AlertModel alert;
  
  static const List<String> steps = [
    "Évènement",
    "Localisation",
    "Rapporteur",
    "Destinataires",
    "Récapitulatif",
    "Soumission",
  ];

  final VoidCallback onEditEvent;
  final VoidCallback onEditConsequences;
  final VoidCallback onEditDestinataires;
  final VoidCallback onEditRapporteur;
  final VoidCallback onEditLocalisation;

  const NewAlertStep6Page({
    Key? key,
    required this.alert,
    required this.onEditEvent,
    required this.onEditConsequences,
    required this.onEditDestinataires,
    required this.onEditRapporteur,
    required this.onEditLocalisation,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Taille et breakpoint simple pour responsive (mobile vs tablette)
    final width = MediaQuery.of(context).size.width;
    final bool isTablet = width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvelle Alerte - Étape 6 (Soumission)"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Indicateur des 6 étapes (petits cercles + label) ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: steps.asMap().entries.map((entry) {
                  int stepNumber = entry.key + 1;
                  String label = entry.value;

                  Color circleColor;
                  if (stepNumber < 6) {
                    circleColor = Colors.green;
                  } else if (stepNumber == 6) {
                    circleColor = AppColors.primary;
                  } else {
                    circleColor = Colors.white;
                  }

                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: circleColor,
                        child: Text(
                          "$stepNumber",
                          style: TextStyle(
                            color: stepNumber == 6 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 70,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // Localisation
            _buildSectionLocalisation(isTablet),
            const SizedBox(height: 20),

            // Récap Événement
            _buildEventCard(isTablet),
            const SizedBox(height: 20),

            // Conséquences
            _buildConsequencesCard(isTablet),
            const SizedBox(height: 20),

            // Rapporteur
            _buildSectionRapporteur(isTablet),
            const SizedBox(height: 20),

            // Destinataires
            _buildDestinatairesCard(isTablet),
            const SizedBox(height: 30),

            // Zone SMS récap + avertissement + boutons
            _buildSmsPreviewSection(context, isTablet),

            const SizedBox(height: 20),

            // Boutons (Soumettre / Précédent / Sauvegarder brouillon)
            _buildBoutons(context),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // SECTION : LOCALISATION
  // ---------------------------
  Widget _buildSectionLocalisation(bool isTablet) {
    return _sectionCard(
      icon: Icons.location_on,
      color: Colors.blue,
      title: "Localisation",
      children: [
        _item("Date & heure", "${alert.date ?? ''} ${alert.time ?? ''}"),
        _item("Région", alert.region),
        _item("Province", alert.province),
        _item("Commune", alert.commune),
        _item("Village", alert.village),
        const SizedBox(height: 12),
        _modifier(() {
          onEditEvent(); // Call the provided callback to handle the "Modifier" action
        }), // bouton 'Modifier' (fonctionnel depuis l'appelant)
      ],
    );
  }

  // ---------------------------
  // SECTION : ÉVÉNEMENT
  // ---------------------------
  Widget _buildEventCard(bool isTablet) {
    // Barre d'ampleur arrondie : on encapsule LinearProgressIndicator dans ClipRRect
    final progress = ((alert.ampleur ?? 0) / 100).clamp(0.0, 1.0);

    return _buildSectionCard(
      title: "Événement",
      icon: Icons.warning_amber_rounded,
      color: Colors.orange,
      onEdit: onEditEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.blue),
              const SizedBox(width: 8),
              Text("Catégorie", style: AppTextStyles.subtitle),
            ],
          ),
          const SizedBox(height: 4),
          Text(alert.typeEvenement ?? "Non précisé", style: AppTextStyles.body),
          const SizedBox(height: 16),
          Text("Ampleur", style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _getAmplitudeLabel(alert.ampleur?.toInt()),
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ],
      ),
    );
  }

  String _getAmplitudeLabel(int? v) {
    if (v == null) return "Non défini";
    if (v < 30) return "Faible";
    if (v < 70) return "Moyenne";
    return "Élevée";
  }

  // ---------------------------
  // SECTION : CONSÉQUENCES
  // ---------------------------
  Widget _buildConsequencesCard(bool isTablet) {
    return _buildSectionCard(
      title: "Conséquences",
      icon: Icons.groups_rounded,
      color: Colors.redAccent,
      onEdit: onEditConsequences,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _coloredBox("Affectées", alert.nbPersonnesAffectees, Colors.red.shade100),
              const SizedBox(width: 12),
              _coloredBox("Déplacées", alert.nbPersonnesDeplacees, Colors.orange.shade100),
            ],
          ),
          const SizedBox(height: 20),
          Text("Infrastructures touchées", style: AppTextStyles.subtitle),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              alert.infrastructuresTouchees ?? "Aucune information",
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _coloredBox(String label, int? value, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text("${value ?? 0}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // SECTION : RAPPORTEUR
  // ---------------------------
  Widget _buildSectionRapporteur(bool isTablet) {
    return _sectionCard(
      icon: Icons.person,
      color: Colors.green,
      title: "Rapporteur",
      children: [
        _item("Nom complet", alert.rapporteurNom),
        _item("Téléphone", alert.rapporteurTelephone),
        _item("Fonction", alert.fonction),
        _item("Langue", alert.languePreferee),
        const SizedBox(height: 12),
        _modifier(() {
          // Add your logic here for the "Modifier" action
        }),
      ],
    );
  }

  // ---------------------------
  // SECTION : DESTINATAIRES
  // ---------------------------
  Widget _buildDestinatairesCard(bool isTablet) {
    return _buildSectionCard(
      title: "Destinataires",
      icon: Icons.person_rounded,
      color: Colors.purple,
      onEdit: onEditDestinataires,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            children: [
              if (alert.sendSMS == true) _chip("SMS", Colors.green),
              if (alert.sendEmail == true) _chip("Email", Colors.blue),
              if (alert.sendPush == true) _chip("Push", Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          _rowInfo("Structures", alert.nbStructures),
          _rowInfo("Autorités", alert.nbAutorites),
          _rowInfo("Équipes", alert.nbEquipes),
          const SizedBox(height: 10),
          Text(
            "Total : ${alert.totalDestinataires ?? 0} destinataires",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _chip(String txt, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(txt, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _rowInfo(String label, int? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text("${value ?? 0}"),
        ],
      ),
    );
  }

  // ---------------------------
  // SECTION : SMS Preview + Avertissement
  // ---------------------------
  Widget _buildSmsPreviewSection(BuildContext context, bool isTablet) {
    // Génération automatique du message SMS à partir du AlertModel
    final String localisationText = alert.localisation ?? alert.commune ?? 'localisation non précisée';
    final int nbAffectes = alert.nbPersonnesAffectees ?? 0;
    final String sms =
        "[ALERTE SAP] ${alert.typeEvenement ?? 'Évènement'} à $localisationText. $nbAffectes personnes affectées. Intervention urgente requise.";

    // Compte de caractères
    final int charCount = sms.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête (Message SMS)
        Row(
          children: const [
            Icon(Icons.message, color: Colors.green),
            SizedBox(width: 8),
            Text("Message SMS", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),

        // Carte blanche contenant le message
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: const [BoxShadow(color: Colors.transparent)],
          ),
          child: Text(
            sms,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        const SizedBox(height: 6),
        Text("$charCount caractères", style: TextStyle(color: Colors.grey.shade600)),

        const SizedBox(height: 12),

        // Avertissement orange
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Vérifiez toutes les informations", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              Text("L'alerte sera transmise immédiatement"),
              SizedBox(height: 4),
              Text("Vous recevrez une confirmation SMS"),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------
  // BOUTONS : Précédent / Sauvegarder brouillon / Soumettre
  // ---------------------------
  Widget _buildBoutons(BuildContext context) {
    return Row(
      children: [
        // Précédent
        Expanded(
          child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Précédent"),
          ),
        ),
        const SizedBox(width: 12),

        // Sauvegarder brouillon
        Expanded(
          child: OutlinedButton(
        onPressed: () {
          // Implémentation de la sauvegarde du brouillon
          _saveDraft(alert);
        },
        child: const Text("Sauvegarder brouillon"),
          ),
        ),

        const SizedBox(width: 12),

        // Soumettre (bouton principal)
        Expanded(
          child: ElevatedButton.icon(
          onPressed: () async {
          await showConfirmationDialog(context, alert, alert.totalDestinataires ?? 0);
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text("Soumettre l'alerte"),
          ),
        ),
      ],
      
    );
  }

  // ---------------------------
  // Reusable section card USED by event/consequences/destinataires
  // ---------------------------
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onEdit,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
            const SizedBox(height: 12),
            child,
            const SizedBox(height: 15),
            Divider(color: Colors.grey.shade300),
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text("Modifier"),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // Reusable small section (used for localisation & rapporteur)
  // ---------------------------
  Widget _sectionCard({
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // Petit widget pour afficher une ligne label / valeur
  // ---------------------------
  Widget _item(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.subtitle)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(value ?? "-", style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // Bouton 'Modifier' générique (pour sections localisations/rapporteur)
  // NOTE: pour les sections qui doivent appeler des pages particulières,
  //       préférez passer un callback depuis le parent.
  // ---------------------------

  // ---------------------------
  // Méthode pour sauvegarder le brouillon
  // ---------------------------
  Future<void> _saveDraft(AlertModel alert) async {
    // Implémentation de la logique pour sauvegarder le brouillon
    // Par exemple, en utilisant le package shared_preferences pour un stockage local simple.
    final prefs = await SharedPreferences.getInstance();
    final draftData = alert.toJson(); // Assurez-vous que AlertModel a une méthode toJson()
    await prefs.setString('alert_draft', jsonEncode(draftData));
    print("Brouillon sauvegardé localement.");
    // Par exemple, vous pouvez enregistrer les données localement ou appeler une API.
    print("Brouillon sauvegardé : ${alert.toString()}");
  }
  Widget _modifier(VoidCallback onEdit) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onEdit,
        icon: const Icon(Icons.edit_outlined),
        label: const Text("Modifier"),
      ),
    );
  }
}*/


///////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:mobile_app/features/alert/presentation/pages/confirmation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/alert_model.dart';
import 'dart:convert';

class NewAlertStep6Page extends StatelessWidget {
  final AlertModel alert;

  static const List<String> steps = [
    "Évènement",
    "Localisation",
    "Rapporteur",
    "Destinataires",
    "Récapitulatif",
    "Soumission",
  ];

  final VoidCallback onEditEvent;
  final VoidCallback onEditConsequences;
  final VoidCallback onEditDestinataires;
  final VoidCallback onEditRapporteur;
  final VoidCallback onEditLocalisation;

  const NewAlertStep6Page({
    super.key,
    required this.alert,
    required this.onEditEvent,
    required this.onEditConsequences,
    required this.onEditDestinataires,
    required this.onEditRapporteur,
    required this.onEditLocalisation,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isTablet = width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvelle Alerte - Étape 6"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepsIndicator(width),
            const SizedBox(height: 16),
            _buildSectionLocalisation(),
            const SizedBox(height: 16),
            _buildEventCard(),
            const SizedBox(height: 16),
            _buildConsequencesCard(),
            const SizedBox(height: 16),
            _buildSectionRapporteur(),
            const SizedBox(height: 16),
            _buildDestinatairesCard(),
            const SizedBox(height: 16),
            _buildSmsPreviewSection(context),
            const SizedBox(height: 24),
            _buildBoutons(context),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // Responsive Step Indicator
  // ---------------------------
  Widget _buildStepsIndicator(double width) {
    double circleRadius = width > 600 ? 22 : 18;
    double textWidth = width > 600 ? 80 : 70;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: steps.asMap().entries.map((entry) {
          int stepNumber = entry.key + 1;
          String label = entry.value;
          Color circleColor = stepNumber == 6 ? AppColors.primary : Colors.green;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                CircleAvatar(
                  radius: circleRadius,
                  backgroundColor: circleColor,
                  child: Text(
                    "$stepNumber",
                    style: TextStyle(
                      color: stepNumber == 6 ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: textWidth,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------
  // Sections (adaptées au responsive)
  // ---------------------------
  Widget _buildSectionLocalisation() {
    return _sectionCard(
      icon: Icons.location_on,
      color: Colors.blue,
      title: "Localisation",
      children: [
        _item("Date & heure", "${alert.date ?? ''} ${alert.time ?? ''}"),
        _item("Région", alert.region),
        _item("Province", alert.province),
        _item("Commune", alert.commune),
        _item("Village", alert.village),
        const SizedBox(height: 8),
        _modifier(() => onEditLocalisation()),
      ],
    );
  }

  Widget _buildEventCard() {
    final progress = ((alert.ampleur ?? 0) / 100).clamp(0.0, 1.0);

    return _buildSectionCard(
      title: "Événement",
      icon: Icons.warning_amber_rounded,
      color: Colors.orange,
      onEdit: onEditEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.blue),
              const SizedBox(width: 8),
              Text("Catégorie", style: AppTextStyles.subtitle),
            ],
          ),
          const SizedBox(height: 4),
          Text(alert.typeEvenement ?? "Non précisé", style: AppTextStyles.body),
          const SizedBox(height: 16),
          Text("Ampleur", style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _getAmplitudeLabel(alert.ampleur?.toInt()),
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ],
      ),
    );
  }

  String _getAmplitudeLabel(int? v) {
    if (v == null) return "Non défini";
    if (v < 30) return "Faible";
    if (v < 70) return "Moyenne";
    return "Élevée";
  }

  Widget _buildConsequencesCard() {
    return _buildSectionCard(
      title: "Conséquences",
      icon: Icons.groups_rounded,
      color: Colors.redAccent,
      onEdit: onEditConsequences,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _coloredBox("Affectées", alert.nbPersonnesAffectees, Colors.red.shade100),
              _coloredBox("Déplacées", alert.nbPersonnesDeplacees, Colors.orange.shade100),
            ],
          ),
          const SizedBox(height: 12),
          Text("Infrastructures touchées", style: AppTextStyles.subtitle),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(alert.infrastructuresTouchees ?? "Aucune information", style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  Widget _coloredBox(String label, int? value, Color c) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text("${value ?? 0}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSectionRapporteur() {
    return _sectionCard(
      icon: Icons.person,
      color: Colors.green,
      title: "Rapporteur",
      children: [
        _item("Nom complet", alert.rapporteurNom),
        _item("Téléphone", alert.rapporteurTelephone),
        _item("Fonction", alert.fonction),
        _item("Langue", alert.languePreferee),
        const SizedBox(height: 8),
        _modifier(() => onEditRapporteur()),
      ],
    );
  }

  Widget _buildDestinatairesCard() {
    return _buildSectionCard(
      title: "Destinataires",
      icon: Icons.person_rounded,
      color: Colors.purple,
      onEdit: onEditDestinataires,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (alert.sendSMS == true) _chip("SMS", Colors.green),
              if (alert.sendEmail == true) _chip("Email", Colors.blue),
              if (alert.sendPush == true) _chip("Push", Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          _rowInfo("Structures", alert.nbStructures),
          _rowInfo("Autorités", alert.nbAutorites),
          _rowInfo("Équipes", alert.nbEquipes),
          const SizedBox(height: 6),
          Text("Total : ${alert.totalDestinataires ?? 0} destinataires", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _chip(String txt, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(txt, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _rowInfo(String label, int? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text("${value ?? 0}"),
      ],
    );
  }

  Widget _buildSmsPreviewSection(BuildContext context) {
    final String localisationText = alert.localisation ?? alert.commune ?? 'localisation non précisée';
    final int nbAffectes = alert.nbPersonnesAffectees ?? 0;
    final String sms =
        "[ALERTE SAP] ${alert.typeEvenement ?? 'Évènement'} à $localisationText. $nbAffectes personnes affectées. Intervention urgente requise.";
    final int charCount = sms.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.message, color: Colors.green),
            SizedBox(width: 8),
            Text("Message SMS", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(sms, style: const TextStyle(fontFamily: 'monospace')),
        ),
        const SizedBox(height: 6),
        Text("$charCount caractères", style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Vérifiez toutes les informations", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              Text("L'alerte sera transmise immédiatement"),
              SizedBox(height: 4),
              Text("Vous recevrez une confirmation SMS"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBoutons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Précédent")),
            ),
            const SizedBox(width: 8, height: 8),
            Expanded(
              child: OutlinedButton(
                  onPressed: () => _saveDraft(alert),
                  child: const Text("Sauvegarder brouillon")),
            ),
            const SizedBox(width: 8, height: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await showConfirmationDialog(context, alert, alert.totalDestinataires ?? 0);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Soumettre l'alerte"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onEdit,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
            const SizedBox(height: 12),
            child,
            const SizedBox(height: 15),
            Divider(color: Colors.grey.shade300),
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text("Modifier"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _item(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.subtitle)),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Text(value ?? "-", style: AppTextStyles.body)),
        ],
      ),
    );
  }

  Widget _modifier(VoidCallback onEdit) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onEdit,
        icon: const Icon(Icons.edit_outlined),
        label: const Text("Modifier"),
      ),
    );
  }

  Future<void> _saveDraft(AlertModel alert) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alert_draft', jsonEncode(alert.toJson()));
    print("Brouillon sauvegardé localement : ${alert.toString()}");
  }
}
