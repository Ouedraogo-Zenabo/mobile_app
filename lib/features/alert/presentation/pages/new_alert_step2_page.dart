/*
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/alert_model.dart';
import 'new_alert_step3_page.dart';

class NewAlertStep2Page extends StatefulWidget {
  final AlertModel alert;

  const NewAlertStep2Page({super.key, required this.alert});

  @override
  State<NewAlertStep2Page> createState() => _NewAlertStep2PageState();
}

class _NewAlertStep2PageState extends State<NewAlertStep2Page> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _facteurs = [
    "Pluie",
    "Sécheresse",
    "Inondation",
    "Feu de brousse",
    "Mouvement de population",
    "Conflit",
  ];

  final List<String> _periodes = ["En cours", "Terminée", "À venir"];

  List<String> _facteursSelectionnes = [];
  double _ampleur = 0.3;
  String? _periode;
  String? _duree;
  String? _description;

   // Liste des 6 étapes du processus
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
    _facteursSelectionnes = widget.alert.facteursDeclencheurs ?? [];
    _ampleur = widget.alert.ampleur ?? 0.3;
    _periode = widget.alert.periode;
    _duree = widget.alert.dureeEstimee;
    _description = widget.alert.description;
  }

  void _onSuivant() {
    if (_facteursSelectionnes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner au moins un facteur déclencheur.")),
      );
      return;
    }

    if (_periode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une période.")),
      );
      return;
    }

    _formKey.currentState!.save();

    widget.alert.facteursDeclencheurs = _facteursSelectionnes;
    widget.alert.ampleur = _ampleur;
    widget.alert.periode = _periode;
    widget.alert.dureeEstimee = _duree;
    widget.alert.description = _description;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewAlertStep3Page(alert: widget.alert),
      ),
    );
  }

  String _labelAmpleur() {
    if (_ampleur == 0) return "Faible";
    if (_ampleur == 0.5) return "Modérée";
    return "Élevée";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvelle Alert"),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
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
                if (stepNumber < 2) {
                  circleColor = Colors.green;
                } else if (stepNumber == 2) {
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
                          color: stepNumber == 2 ? Colors.white : Colors.black,
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
            const SizedBox(height: 20),

            // --- Titre de l'étape ---
            Text(
              "Étape 2 : Événement",
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 12),

                Text("Facteurs déclencheurs", style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),

                Column(
                children: _facteurs.map((facteur) {
                  final bool isSelected = _facteursSelectionnes.contains(facteur);

                  IconData icon;
                  switch (facteur.toLowerCase()) {
                    case 'pluie':
                      icon = Icons.water_drop;
                      break;
                    case 'sécheresse':
                      icon = Icons.terrain;
                      break;
                    case 'inondation':
                      icon = Icons.waves;
                      break;
                    case 'feu de brousse':
                      icon = Icons.local_fire_department;
                      break;
                    case 'mouvement de population':
                      icon = Icons.groups;
                      break;
                    case 'conflit':
                      icon = Icons.warning_amber_rounded;
                      break;
                    default:
                      icon = Icons.check_circle;
                  }

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _facteursSelectionnes.add(facteur);
                        } else {
                          _facteursSelectionnes.remove(facteur);
                        }
                      });
                    },
                    title: Text(facteur),
                    secondary: Icon(icon, color: AppColors.primary),
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                }).toList(),
              ),


                const SizedBox(height: 24),
                Text("Ampleur de l'événement", style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Slider(
                  value: _ampleur,
                  min: 0,
                  max: 1,
                  divisions: 2,
                  label: _labelAmpleur(),
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _ampleur = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Faible"),
                    Text("Modérée"),
                    Text("Élevée"),
                  ],
                ),
                const SizedBox(height: 24),
                Text("Période de l'événement", style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _periode,
                  hint: const Text("Sélectionnez une période"),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _periodes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (value) => setState(() => _periode = value),
                ),
                const SizedBox(height: 24),
                Text("Durée estimée", style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _duree,
                  decoration: const InputDecoration(
                    hintText: "Ex: 2 jours, 1 semaine...",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _duree = value,
                ),
                const SizedBox(height: 24),
                Text("Description détaillée", style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _description,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Décrivez l’événement en détail...",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _description = value,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Précédent")),
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
        ),
      ),
    );
  }
}
*/









/////////////////////////////////////////////////////////////////////////
library;


import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/alert_model.dart';
import 'new_alert_step3_page.dart';

class NewAlertStep2Page extends StatefulWidget {
  final AlertModel alert;

  const NewAlertStep2Page({super.key, required this.alert});

  @override
  State<NewAlertStep2Page> createState() => _NewAlertStep2PageState();
}

class _NewAlertStep2PageState extends State<NewAlertStep2Page> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _facteurs = [
    "Pluie",
    "Sécheresse",
    "Inondation",
    "Feu de brousse",
    "Mouvement de population",
    "Conflit",
  ];
  final List<String> _periodes = ["En cours", "Terminée", "À venir"];
  List<String> _facteursSelectionnes = [];
  double _ampleur = 0.3;
  String? _periode;
  String? _duree;
  String? _description;

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
    _facteursSelectionnes = widget.alert.facteursDeclencheurs ?? [];
    _ampleur = widget.alert.ampleur ?? 0.3;
    _periode = widget.alert.periode;
    _duree = widget.alert.dureeEstimee;
    _description = widget.alert.description;
  }

  void _onSuivant() {
    if (_facteursSelectionnes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner au moins un facteur déclencheur.")),
      );
      return;
    }
    if (_periode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une période.")),
      );
      return;
    }
    _formKey.currentState!.save();
    widget.alert.facteursDeclencheurs = _facteursSelectionnes;
    widget.alert.ampleur = _ampleur;
    widget.alert.periode = _periode;
    widget.alert.dureeEstimee = _duree;
    widget.alert.description = _description;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewAlertStep3Page(alert: widget.alert),
      ),
    );
  }

  String _labelAmpleur() {
    if (_ampleur == 0) return "Faible";
    if (_ampleur == 0.5) return "Modérée";
    return "Élevée";
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600; // Détection tablette/large écran

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvelle Alert"),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? constraints.maxWidth * 0.2 : 16,
              vertical: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Indicateur des étapes (responsive Wrap) ---
                  Wrap(
                    alignment: WrapAlignment.spaceAround,
                    spacing: 12,
                    runSpacing: 12,
                    children: steps.asMap().entries.map((entry) {
                      int stepNumber = entry.key + 1;
                      String label = entry.value;

                      Color circleColor;
                      if (stepNumber < 2) {
                        circleColor = Colors.green;
                      } else if (stepNumber == 2) {
                        circleColor = AppColors.primary;
                      } else {
                        circleColor = Colors.white;
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: isWide ? 24 : 20,
                            backgroundColor: circleColor,
                            child: Text(
                              "$stepNumber",
                              style: TextStyle(
                                color: stepNumber == 2 ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 70,
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // --- Titre de l'étape ---
                  Text("Étape 2 : Événement", style: AppTextStyles.titleLarge),
                  const SizedBox(height: 12),

                  // --- Facteurs déclencheurs ---
                  Text("Facteurs déclencheurs", style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Column(
                    children: _facteurs.map((facteur) {
                      final bool isSelected = _facteursSelectionnes.contains(facteur);
                      IconData icon;
                      switch (facteur.toLowerCase()) {
                        case 'pluie':
                          icon = Icons.water_drop;
                          break;
                        case 'sécheresse':
                          icon = Icons.terrain;
                          break;
                        case 'inondation':
                          icon = Icons.waves;
                          break;
                        case 'feu de brousse':
                          icon = Icons.local_fire_department;
                          break;
                        case 'mouvement de population':
                          icon = Icons.groups;
                          break;
                        case 'conflit':
                          icon = Icons.warning_amber_rounded;
                          break;
                        default:
                          icon = Icons.check_circle;
                      }
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _facteursSelectionnes.add(facteur);
                            } else {
                              _facteursSelectionnes.remove(facteur);
                            }
                          });
                        },
                        title: Text(facteur),
                        secondary: Icon(icon, color: AppColors.primary),
                        controlAffinity: ListTileControlAffinity.trailing,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  Text("Ampleur de l'événement", style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Slider(
                    value: _ampleur,
                    min: 0,
                    max: 1,
                    divisions: 2,
                    label: _labelAmpleur(),
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _ampleur = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Faible"),
                      Text("Modérée"),
                      Text("Élevée"),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text("Période de l'événement", style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _periode,
                    hint: const Text("Sélectionnez une période"),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _periodes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (value) => setState(() => _periode = value),
                  ),

                  const SizedBox(height: 24),
                  Text("Durée estimée", style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _duree,
                    decoration: const InputDecoration(
                      hintText: "Ex: 2 jours, 1 semaine...",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _duree = value,
                  ),

                  const SizedBox(height: 24),
                  Text("Description détaillée", style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _description,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Décrivez l’événement en détail...",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _description = value,
                  ),

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
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 48 : 32,
                            vertical: isWide ? 16 : 12,
                          ),
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
        }),
      ),
    );
  }
}
