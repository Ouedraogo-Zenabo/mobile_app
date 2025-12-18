


//////////////////////////////////////////////////////////////////////
library;


/*
import 'package:flutter/material.dart';
import 'package:mobile_app/features/alert/presentation/pages/new_alert_step1_page_fixed.dart';
import 'package:mobile_app/features/alert/presentation/pages/new_alert_step2_page.dart';
import 'package:mobile_app/features/alert/presentation/pages/new_alert_step3_page.dart';
import 'package:mobile_app/features/alert/presentation/pages/new_alert_step4_page.dart';
//import 'package:mobile_app/features/alert/presentation/pages/new_alert_step1_page.dart';
//import 'package:mobile_app/features/alert/presentation/pages/new_alert_step3_page.dart';
import 'package:mobile_app/features/alert/presentation/pages/new_alert_step6_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
//import 'package:mobile_app/features/alert/presentation/pages/new_alert_step6_page.dart'
import '../../domain/alert_model.dart';

class NewAlertStep5Page extends StatefulWidget {
  final AlertModel alert;

  const NewAlertStep5Page({super.key, required this.alert});

  @override
  State<NewAlertStep5Page> createState() => _NewAlertStep5PageState();
}

class _NewAlertStep5PageState extends State<NewAlertStep5Page> {

  // --- Sélection des canaux ---
  bool sendSMS = true;
  bool sendEmail = false;
  bool sendPush = true;

  // --- Groupes de destinataires cochés ---
  Map<String, bool> groupsSelected = {
    "Structures partenaires": true,
    "Autorités locales": true,
    "Équipes d’intervention": true,
  };

  final Map<String, int> recipientsCount = {
    "Structures partenaires": 5,
    "Autorités locales": 4,
    "Équipes d’intervention": 3,
  };
  int getTotalSelectedRecipients() {
  int total = 0;
  groupsSelected.forEach((group, isSelected) {
    if (isSelected) {
      total += recipientsCount[group]!;
    }
  });
    return total;
  }


  // --- Destinataire personnalisé ---
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  // --- Messages personnalisés ---
  final TextEditingController smsMessageCtrl = TextEditingController();
  final TextEditingController emailMessageCtrl = TextEditingController();
 // Liste des 6 étapes
  final List<String> steps = [
    "Localisation",
    "Événement",
    "Conséquences",
    "Rapporteur",
    "Destinataires",
    "Révision",
  ];

  @override
  void initState() {
    super.initState();

    // Exemple de message pré-rempli (tu peux remplacer)
    smsMessageCtrl.text =
        "[ALERTE SAP] ${widget.alert.evenement} à ${widget.alert.localisation}";
    emailMessageCtrl.text =
        "Alerte SAP : ${widget.alert.evenement}\nLocalisation : ${widget.alert.localisation}";
  }

void _onSuivant() {
  // --- Vérifier les canaux ---
  if (!sendSMS && !sendEmail && !sendPush) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez sélectionner au moins un canal (SMS, Email ou Push).")),
    );
    return;
  }

  // --- Vérifier les groupes de destinataires ---
  bool hasGroup = groupsSelected.values.any((v) => v == true);
  if (!hasGroup) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez sélectionner au moins un groupe de destinataires.")),
    );
    return;
  }

  // --- Vérifier contact personnalisé ---
  if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vous devez entrer un numéro si vous ajoutez un contact personnalisé.")),
    );
    return;
  }

  if (phoneCtrl.text.isNotEmpty && nameCtrl.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vous devez entrer un nom si vous ajoutez un numéro de contact.")),
    );
    return;
  }

  // --- Vérifier messages ---
  if (sendSMS && smsMessageCtrl.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Le message SMS ne peut pas être vide.")),
    );
    return;
  }

  if (sendEmail && emailMessageCtrl.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Le message Email ne peut pas être vide.")),
    );
    return;
  }

  // --- Sauvegarde dans le modèle ---
  widget.alert.groupesDestinataires = Map.from(groupsSelected);
  widget.alert.sendSMS = sendSMS;
  widget.alert.sendEmail = sendEmail;
  widget.alert.sendPush = sendPush;

  widget.alert.contactNom = nameCtrl.text.isEmpty ? null : nameCtrl.text;
  widget.alert.contactTelephone = phoneCtrl.text.isEmpty ? null : phoneCtrl.text;
  widget.alert.contactEmail = emailCtrl.text.isEmpty ? null : emailCtrl.text;

  widget.alert.smsMessage = smsMessageCtrl.text;
  widget.alert.emailMessage = emailMessageCtrl.text;


    //int total = getTotalSelectedRecipients();
  AlertModel alert = widget.alert;
  // Calcul du nombre de destinataires
  // --------------------------
  alert.nbStructures = groupsSelected["Structures partenaires"]! 
      ? recipientsCount["Structures partenaires"] 
      : 0;
  alert.nbAutorites = groupsSelected["Autorités locales"]! 
      ? recipientsCount["Autorités locales"] 
      : 0;
  alert.nbEquipes = groupsSelected["Équipes d’intervention"]! 
      ? recipientsCount["Équipes d’intervention"] 
      : 0;

  // Total
  alert.totalDestinataires = alert.nbStructures! + alert.nbAutorites! + alert.nbEquipes!;
  // --- Aller à l’étape suivante ---
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => NewAlertStep6Page(
        alert: widget.alert,
        

        // ---- Modifier Localisation → Étape 1 ----
        onEditLocalisation: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => NewAlertStep1PageFixed(alert: widget.alert)));
        },

        // ---- Modifier Événement → Étape 2 ----
        onEditEvent: () {
          Navigator.pop(context);
          Navigator.push(context,
            MaterialPageRoute(builder: (_) => NewAlertStep2Page(alert: widget.alert)));
        },

        // ---- Modifier Conséquences → Étape 3 ----
        onEditConsequences: () {
          Navigator.pop(context);
          Navigator.push(context,
            MaterialPageRoute(builder: (_) => NewAlertStep3Page(alert: widget.alert)));
        },

        // ---- Modifier Rapporteur → Étape 4 ----
        onEditRapporteur: () {
          Navigator.pop(context);
          Navigator.push(context,
            MaterialPageRoute(builder: (_) => NewAlertStep4Page(alert: widget.alert)));
        },

        // ---- Modifier Destinataires → Étape 5 ----
        onEditDestinataires: () {
          Navigator.pop(context);
          Navigator.push(context,
            MaterialPageRoute(builder: (_) => NewAlertStep5Page(alert: widget.alert)));
        },
      ),
    ),
  );



}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Destinataires"),
        backgroundColor: AppColors.primary,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Indicateur des 6 étapes ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: steps.asMap().entries.map((entry) {
                  int stepNumber = entry.key + 1;
                  String label = entry.value;

                  Color circleColor;
                  if (stepNumber < 5) {
                    circleColor = Colors.green;
                  } else if (stepNumber == 5) {
                    circleColor = AppColors.primary;
                  } else {
                    circleColor = Colors.white;
                  }

                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: circleColor,
                        child: Text(
                          "$stepNumber",
                          style: TextStyle(
                            color: stepNumber == 5 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  );
                }).toList(),
              ),

            // -------------------------------------------------------------------
            // 1️⃣ CANAUX DE NOTIFICATION  — correspond à la DEUXIÈME image
            // -------------------------------------------------------------------
            Text("Canaux de notification",
                style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text("Sélectionnez les canaux à utiliser",
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),

            _buildChannelTile(
              label: "SMS",
              icon: Icons.sms,
              value: sendSMS,
              onChanged: (v) => setState(() => sendSMS = v),
            ),
            const SizedBox(height: 10),

            _buildChannelTile(
              label: "Email",
              icon: Icons.email_outlined,
              value: sendEmail,
              onChanged: (v) => setState(() => sendEmail = v),
            ),
            const SizedBox(height: 10),

            _buildChannelTile(
              label: "Push",
              icon: Icons.notifications_active_outlined,
              value: sendPush,
              onChanged: (v) => setState(() => sendPush = v),
            ),

            const SizedBox(height: 25),

            // -------------------------------------------------------------------
            // 2️⃣ GROUPES DE DESTINATAIRES — correspond à la PREMIÈRE image
            // -------------------------------------------------------------------
            Text("Sélection des destinataires",
                style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text("Choisissez les groupes à alerter",
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),

            _buildRecipientGroup(
              label: "Structures partenaires",
              sublabel: "${recipientsCount["Structures partenaires"]} destinataires",
              icon: Icons.apartment,
              selected: groupsSelected["Structures partenaires"]!,
              onChanged: (v) =>
                  setState(() => groupsSelected["Structures partenaires"] = v),
            ),

            const SizedBox(height: 12),

            _buildRecipientGroup(
              label: "Autorités locales",
              sublabel: "${recipientsCount["Autorités locales"]} destinataires",
              icon: Icons.location_pin,
              selected: groupsSelected["Autorités locales"]!,
              onChanged: (v) =>
                  setState(() => groupsSelected["Autorités locales"] = v),
            ),

            const SizedBox(height: 12),

            _buildRecipientGroup(
              label: "Équipes d’intervention",
              sublabel: "${recipientsCount["Équipes d’intervention"]} destinataires",
              icon: Icons.group,
              selected: groupsSelected["Équipes d’intervention"]!,
              onChanged: (v) =>
                  setState(() => groupsSelected["Équipes d’intervention"] = v),
            ),
            
            

            const SizedBox(height: 25),

            // -------------------------------------------------------------------
            // 3️⃣ DESTINATAIRE PERSONNALISÉ — correspond à la TROISIÈME image
            // -------------------------------------------------------------------
            Text("Destinataire personnalisé",
                style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text("Ajoutez un contact supplémentaire",
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),

            _buildInput(nameCtrl, "Nom complet"),
            const SizedBox(height: 12),

            _buildInput(phoneCtrl, "Numéro de téléphone"),
            const SizedBox(height: 12),

            _buildInput(emailCtrl, "Adresse email (optionnel)"),



            const SizedBox(height: 24),

            // ---------------- Message SMS ----------------
            Row(
              children: [
                Icon(Icons.sms, color: AppColors.primary),
                const SizedBox(width: 8),
                Text("Message SMS", style: AppTextStyles.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            _buildMessageBox(smsMessageCtrl),

            const SizedBox(height: 24),

            // ---------------- Message Email ----------------
            Row(
              children: [
                Icon(Icons.email_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Text("Message Email", style: AppTextStyles.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            _buildMessageBox(emailMessageCtrl),

            const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Précédent"),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: _onSuivant,
                child: const Text("Suivant"),
              ),
            ],
          ),

          ],
        ),
      ),
    );
  }

  // =====================================================================
  // ----------------------------- WIDGETS -------------------------------
  // =====================================================================

  Widget _buildChannelTile({
    required String label,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          color: value ? AppColors.primary.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v!),
              activeColor: AppColors.primary,
            ),
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientGroup({
    required String label,
    required String sublabel,
    required IconData icon,
    required bool selected,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!selected),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              activeColor: AppColors.primary,
              onChanged: (v) => onChanged(v!),
            ),
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyLarge),
                  Text(sublabel, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildMessageBox(TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      maxLines: 5,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: "Message...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }


}*/



///////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:mobile_app/features/alert/presentation/pages/new_alert_step6_page.dart';
import 'package:mobile_app/features/alert/presentation/pages/new_alert_step1_page_fixed.dart';
import 'package:mobile_app/features/alert/presentation/pages/new_alert_step2_page.dart';
import 'package:mobile_app/features/alert/presentation/pages/new_alert_step3_page.dart';
import 'package:mobile_app/features/alert/presentation/pages/new_alert_step4_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/alert_model.dart';

class NewAlertStep5Page extends StatefulWidget {
  final AlertModel alert;

  const NewAlertStep5Page({super.key, required this.alert});

  @override
  State<NewAlertStep5Page> createState() => _NewAlertStep5PageState();
}

class _NewAlertStep5PageState extends State<NewAlertStep5Page> {
  bool sendSMS = true;
  bool sendEmail = false;
  bool sendPush = true;

  Map<String, bool> groupsSelected = {
    "Structures partenaires": true,
    "Autorités locales": true,
    "Équipes d’intervention": true,
  };

  final Map<String, int> recipientsCount = {
    "Structures partenaires": 5,
    "Autorités locales": 4,
    "Équipes d’intervention": 3,
  };

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController smsMessageCtrl = TextEditingController();
  final TextEditingController emailMessageCtrl = TextEditingController();

  final List<String> steps = [
    "Localisation",
    "Événement",
    "Conséquences",
    "Rapporteur",
    "Destinataires",
    "Révision",
  ];

  @override
  void initState() {
    super.initState();
    smsMessageCtrl.text =
        "[ALERTE SAP] ${widget.alert.evenement} à ${widget.alert.localisation}";
    emailMessageCtrl.text =
        "Alerte SAP : ${widget.alert.evenement}\nLocalisation : ${widget.alert.localisation}";
  }

  int getTotalSelectedRecipients() {
    int total = 0;
    groupsSelected.forEach((group, isSelected) {
      if (isSelected) total += recipientsCount[group]!;
    });
    return total;
  }

  void _onSuivant() {
    if (!sendSMS && !sendEmail && !sendPush) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner au moins un canal (SMS, Email ou Push).")));
      return;
    }
    if (!groupsSelected.values.any((v) => v)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner au moins un groupe de destinataires.")));
      return;
    }
    if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vous devez entrer un numéro si vous ajoutez un contact personnalisé.")));
      return;
    }
    if (phoneCtrl.text.isNotEmpty && nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vous devez entrer un nom si vous ajoutez un numéro de contact.")));
      return;
    }
    if (sendSMS && smsMessageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Le message SMS ne peut pas être vide.")));
      return;
    }
    if (sendEmail && emailMessageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Le message Email ne peut pas être vide.")));
      return;
    }

    // Enregistrer les valeurs dans le modèle
    widget.alert.groupesDestinataires = Map.from(groupsSelected);
    widget.alert.sendSMS = sendSMS;
    widget.alert.sendEmail = sendEmail;
    widget.alert.sendPush = sendPush;

    widget.alert.contactNom = nameCtrl.text.isEmpty ? null : nameCtrl.text;
    widget.alert.contactTelephone = phoneCtrl.text.isEmpty ? null : phoneCtrl.text;
    widget.alert.contactEmail = emailCtrl.text.isEmpty ? null : emailCtrl.text;

    widget.alert.smsMessage = smsMessageCtrl.text;
    widget.alert.emailMessage = emailMessageCtrl.text;

    widget.alert.nbStructures = groupsSelected["Structures partenaires"]! ? recipientsCount["Structures partenaires"] : 0;
    widget.alert.nbAutorites = groupsSelected["Autorités locales"]! ? recipientsCount["Autorités locales"] : 0;
    widget.alert.nbEquipes = groupsSelected["Équipes d’intervention"]! ? recipientsCount["Équipes d’intervention"] : 0;
    widget.alert.totalDestinataires = widget.alert.nbStructures! + widget.alert.nbAutorites! + widget.alert.nbEquipes!;

    // Navigation vers l'étape 6
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewAlertStep6Page(
          alert: widget.alert,
          onEditLocalisation: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => NewAlertStep1PageFixed(alert: AlertModel())));
          },
          onEditEvent: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => NewAlertStep2Page(alert: widget.alert)));
          },
          onEditConsequences: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => NewAlertStep3Page(alert: widget.alert)));
          },
          onEditRapporteur: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => NewAlertStep4Page(alert: widget.alert)));
          },
          onEditDestinataires: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => NewAlertStep5Page(alert: widget.alert)));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width * 0.04;
    final circleRadius = width * 0.05;
    final fontSize = width * 0.035;
    final buttonPaddingH = width * 0.08;
    final buttonPaddingV = width * 0.03;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Destinataires"), backgroundColor: AppColors.primary),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Etapes ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: steps.asMap().entries.map((entry) {
                  int stepNumber = entry.key + 1;
                  String label = entry.value;
                  Color circleColor;
                  if (stepNumber < 5) {
                    circleColor = Colors.green;
                  } else if (stepNumber == 5) circleColor = AppColors.primary;
                  else circleColor = Colors.white;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding / 2),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: circleRadius,
                          backgroundColor: circleColor,
                          child: Text(
                            "$stepNumber",
                            style: TextStyle(
                              color: stepNumber == 5 ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                        SizedBox(height: padding / 4),
                        SizedBox(
                          width: width * 0.2,
                          child: Text(label,
                              style: TextStyle(fontSize: fontSize * 0.8),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: padding),

            // --- Canaux ---
            Text("Canaux de notification", style: AppTextStyles.titleMedium.copyWith(fontSize: fontSize)),
            SizedBox(height: 8),
            _buildChannelTile("SMS", Icons.sms, sendSMS, (v) => setState(() => sendSMS = v), fontSize),
            SizedBox(height: 8),
            _buildChannelTile("Email", Icons.email_outlined, sendEmail, (v) => setState(() => sendEmail = v), fontSize),
            SizedBox(height: 8),
            _buildChannelTile("Push", Icons.notifications_active_outlined, sendPush, (v) => setState(() => sendPush = v), fontSize),

            SizedBox(height: 20),

            // --- Groupes destinataires ---
            Text("Sélection des destinataires", style: AppTextStyles.titleMedium.copyWith(fontSize: fontSize)),
            SizedBox(height: 8),
            _buildRecipientGroup("Structures partenaires", "${recipientsCount["Structures partenaires"]} destinataires",
                Icons.apartment, groupsSelected["Structures partenaires"]!, (v) => setState(() => groupsSelected["Structures partenaires"] = v), fontSize),
            SizedBox(height: 8),
            _buildRecipientGroup("Autorités locales", "${recipientsCount["Autorités locales"]} destinataires",
                Icons.location_pin, groupsSelected["Autorités locales"]!, (v) => setState(() => groupsSelected["Autorités locales"] = v), fontSize),
            SizedBox(height: 8),
            _buildRecipientGroup("Équipes d’intervention", "${recipientsCount["Équipes d’intervention"]} destinataires",
                Icons.group, groupsSelected["Équipes d’intervention"]!, (v) => setState(() => groupsSelected["Équipes d’intervention"] = v), fontSize),

            SizedBox(height: 20),

            // --- Destinataire personnalisé ---
            Text("Destinataire personnalisé", style: AppTextStyles.titleMedium.copyWith(fontSize: fontSize)),
            SizedBox(height: 8),
            _buildInput(nameCtrl, "Nom complet"),
            SizedBox(height: 8),
            _buildInput(phoneCtrl, "Numéro de téléphone"),
            SizedBox(height: 8),
            _buildInput(emailCtrl, "Adresse email (optionnel)"),

            SizedBox(height: 20),

            // --- Message SMS ---
            _buildMessageLabel("Message SMS", Icons.sms, fontSize),
            SizedBox(height: 8),
            _buildMessageBox(smsMessageCtrl),

            SizedBox(height: 20),

            // --- Message Email ---
            _buildMessageLabel("Message Email", Icons.email_outlined, fontSize),
            SizedBox(height: 8),
            _buildMessageBox(emailMessageCtrl),

            SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Précédent", style: TextStyle(fontSize: fontSize)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: buttonPaddingH, vertical: buttonPaddingV),
                  ),
                  onPressed: _onSuivant,
                  child: Text("Suivant", style: TextStyle(fontSize: fontSize)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelTile(String label, IconData icon, bool value, Function(bool) onChanged, double fontSize) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value ? AppColors.primary : Colors.grey.shade300, width: 2),
          color: value ? AppColors.primary.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Checkbox(value: value, onChanged: (v) => onChanged(v!), activeColor: AppColors.primary),
            Icon(icon, color: AppColors.primary),
            SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: fontSize)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientGroup(String label, String sublabel, IconData icon, bool selected, Function(bool) onChanged, double fontSize) {
    return InkWell(
      onTap: () => onChanged(!selected),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300, width: 2),
        ),
        child: Row(
          children: [
            Checkbox(value: selected, onChanged: (v) => onChanged(v!), activeColor: AppColors.primary),
            Icon(icon, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: fontSize)),
                  Text(sublabel, style: TextStyle(fontSize: fontSize * 0.8, color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildMessageBox(TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      maxLines: 5,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: "Message...",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildMessageLabel(String label, IconData icon, double fontSize) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600)),
      ],
    );
  }
}







