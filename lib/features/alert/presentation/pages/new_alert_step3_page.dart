


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
library;

/*import 'package:flutter/material.dart';
import 'package:mobile_app/features/alert/presentation/pages/new_alert_step4_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/alert_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Étape 3 : Conséquences observées
/// Permet de saisir les impacts humains, matériels et les besoins identifiés.
class NewAlertStep3Page extends StatefulWidget {
  final AlertModel alert;

  const NewAlertStep3Page({super.key, required this.alert});

  @override
  State<NewAlertStep3Page> createState() => _NewAlertStep3PageState();
}

class _NewAlertStep3PageState extends State<NewAlertStep3Page> {
  final _formKey = GlobalKey<FormState>();

  // Liste des types de conséquences observées avec icône
  final List<Map<String, dynamic>> _consequences = [
    {"label": "Pertes agricoles", "icon": Icons.agriculture},
    {"label": "Destructions d’habitations", "icon": Icons.house},
    {"label": "Pertes en bétail", "icon": Icons.pets},
    {"label": "Mouvements de population", "icon": Icons.people},
    {"label": "Dommages aux infrastructures", "icon": Icons.apartment},
  ];

  // Variables locales pour le formulaire
  List<String> _consequencesSelectionnees = [];
  String? _nbAffectees;
  String? _nbDeplaces;
  String? _nbDeces;
  String? _nbBlesses;
  String? _infrastructures;
  String? _besoinsUrgents;

  // Pour gérer les images
  final ImagePicker _picker = ImagePicker();
  List<XFile> _photos = [];

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
    _consequencesSelectionnees = widget.alert.consequencesObservees ?? [];
    _nbAffectees = widget.alert.nbPersonnesAffectees?.toString();
    _nbDeplaces = widget.alert.nbPersonnesDeplacees?.toString();
    _nbDeces = widget.alert.nbDeces?.toString();
    _nbBlesses = widget.alert.nbBlesses?.toString();
    _infrastructures = widget.alert.infrastructuresTouchees;
    _besoinsUrgents = widget.alert.besoinsUrgents;
  }

      /// Fonction pour prendre une photo avec la caméra 
    Future<void> _prendrePhoto() async {
      try {
        final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

        if (!mounted) return; // <-- évite les erreurs après navigation

        if (photo != null) {
          setState(() {
            _photos.add(photo);
          });
        }
      } catch (e) {
        debugPrint("Erreur lors de la prise de photo : $e");
      }
    }

    /// Fonction pour sélectionner des images depuis la galerie
    Future<void> _selectionGalerie() async {
      try {
        final List<XFile> images = await _picker.pickMultiImage();

        if (!mounted) return;

        if (images.isNotEmpty) {
          setState(() {
            _photos.addAll(images);
          });
        }
      } catch (e) {
        debugPrint("Erreur lors de la sélection des images : $e");
      }
    }

  /// Vérifie que tous les champs obligatoires sont remplis
  bool _verifierChamps() {
    if (_consequencesSelectionnees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez cocher au moins une conséquence.")),
      );
      return false;
    }
    if ((_nbAffectees == null || _nbAffectees!.isEmpty) ||
        (_nbDeplaces == null || _nbDeplaces!.isEmpty) ||
        (_nbDeces == null || _nbDeces!.isEmpty) ||
        (_nbBlesses == null || _nbBlesses!.isEmpty) ||
        (_infrastructures == null || _infrastructures!.isEmpty) ||
        (_besoinsUrgents == null || _besoinsUrgents!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires.")),
      );
      return false;
    }
    return true;
  }

  /// Fonction appelée au clic sur le bouton "Suivant"
  void _onSuivant() {
  // On enregistre les valeurs des TextFormField
  _formKey.currentState!.save();

  // Vérification des champs obligatoires
  if (_verifierChamps()) {
    // Mise à jour du modèle
    widget.alert.consequencesObservees = _consequencesSelectionnees;
    widget.alert.nbPersonnesAffectees = int.tryParse(_nbAffectees ?? '0');
    widget.alert.nbPersonnesDeplacees = int.tryParse(_nbDeplaces ?? '0');
    widget.alert.nbDeces = int.tryParse(_nbDeces ?? '0');
    widget.alert.nbBlesses = int.tryParse(_nbBlesses ?? '0');
    widget.alert.infrastructuresTouchees = _infrastructures;
    widget.alert.besoinsUrgents = _besoinsUrgents;
    widget.alert.photos = _photos.map((p) => p.path).toList();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Étape 3 enregistrée avec succès ✅")),
    );

    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NewAlertStep4Page(alert: widget.alert),
  ),
);


  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvelle Alerte"),
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
                    if (stepNumber < 3) {
                      circleColor = Colors.green;
                    } else if (stepNumber == 3) {
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
                              color: stepNumber == 3 ? Colors.white : Colors.black,
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

                // --- Types de conséquences observées ---
                Text("Types de conséquences observées", style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Column(
                  children: _consequences.map((item) {
                    final bool selected = _consequencesSelectionnees.contains(item['label']);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _consequencesSelectionnees.add(item['label']);
                          } else {
                            _consequencesSelectionnees.remove(item['label']);
                          }
                        });
                      },
                      title: Text(item['label']),
                      secondary: Icon(item['icon'], color: AppColors.primary),
                      controlAffinity: ListTileControlAffinity.trailing,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // --- Données chiffrées ---
                _buildNumberField("Nombre de personnes affectées", _nbAffectees, (v) => _nbAffectees = v, "Ex: 250"),
                _buildNumberField("Personnes déplacées", _nbDeplaces, (v) => _nbDeplaces = v, "Ex: 100"),
                _buildNumberField("Nombre de décès", _nbDeces, (v) => _nbDeces = v, "Ex: 0"),
                _buildNumberField("Nombre de blessés", _nbBlesses, (v) => _nbBlesses = v, "Ex: 15"),
                const SizedBox(height: 24),

                // --- Infrastructures touchées ---
                _buildTextField("Infrastructures touchées", _infrastructures, (v) => _infrastructures = v,
                    "Ex: Maisons endommagées, routes coupées, ponts détruits..."),
                const SizedBox(height: 24),

                // --- Besoins urgents identifiés ---
                _buildTextField("Besoins urgents identifiés", _besoinsUrgents, (v) => _besoinsUrgents = v,
                    "Ex: Abris d'urgence, eau potable, kits alimentaires..."),
                const SizedBox(height: 24),

                // --- Photos et documents ---
                Text("Photos et documents", style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                const Text("Ajoutez des photos pour documenter la situation", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),

                // Boutons photo/galerie
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _prendrePhoto,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text("Prendre une photo"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectionGalerie,
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text("Galerie"),
                      ),
                    ),
                  ],
                ),

                // Affichage des photos sélectionnées
                if (_photos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _photos.map((file) {
                        return Image.file(
                          File(file.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 32),

                // --- Navigation ---
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

  /// Widget réutilisable pour les champs numériques
  Widget _buildNumberField(String label, String? initialValue, Function(String?) onSaved, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: TextInputType.number,
          initialValue: initialValue,
          decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
          onSaved: onSaved,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Widget réutilisable pour les champs texte
  Widget _buildTextField(String label, String? initialValue, Function(String?) onSaved, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: 2,
          decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
          onSaved: onSaved,
        ),
      ],
    );
  }
}
*/



//////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:mobile_app/features/alert/presentation/pages/new_alert_step4_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/alert_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewAlertStep3Page extends StatefulWidget {
  final AlertModel alert;

  const NewAlertStep3Page({super.key, required this.alert});

  @override
  State<NewAlertStep3Page> createState() => _NewAlertStep3PageState();
}

class _NewAlertStep3PageState extends State<NewAlertStep3Page> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _photos = [];

  final List<Map<String, dynamic>> _consequences = [
    {"label": "Pertes agricoles", "icon": Icons.agriculture},
    {"label": "Destructions d’habitations", "icon": Icons.house},
    {"label": "Pertes en bétail", "icon": Icons.pets},
    {"label": "Mouvements de population", "icon": Icons.people},
    {"label": "Dommages aux infrastructures", "icon": Icons.apartment},
  ];

  List<String> _consequencesSelectionnees = [];
  String? _nbAffectees;
  String? _nbDeplaces;
  String? _nbDeces;
  String? _nbBlesses;
  String? _infrastructures;
  String? _besoinsUrgents;

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
    _consequencesSelectionnees = widget.alert.consequencesObservees ?? [];
    _nbAffectees = widget.alert.nbPersonnesAffectees?.toString();
    _nbDeplaces = widget.alert.nbPersonnesDeplacees?.toString();
    _nbDeces = widget.alert.nbDeces?.toString();
    _nbBlesses = widget.alert.nbBlesses?.toString();
    _infrastructures = widget.alert.infrastructuresTouchees;
    _besoinsUrgents = widget.alert.besoinsUrgents;
  }

  Future<void> _prendrePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (!mounted) return;
    if (photo != null) setState(() => _photos.add(photo));
  }

  Future<void> _selectionGalerie() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (!mounted) return;
    if (images.isNotEmpty) setState(() => _photos.addAll(images));
  }

  bool _verifierChamps() {
    if (_consequencesSelectionnees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez cocher au moins une conséquence.")),
      );
      return false;
    }
    if ((_nbAffectees == null || _nbAffectees!.isEmpty) ||
        (_nbDeplaces == null || _nbDeplaces!.isEmpty) ||
        (_nbDeces == null || _nbDeces!.isEmpty) ||
        (_nbBlesses == null || _nbBlesses!.isEmpty) ||
        (_infrastructures == null || _infrastructures!.isEmpty) ||
        (_besoinsUrgents == null || _besoinsUrgents!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires.")),
      );
      return false;
    }
    return true;
  }

  void _onSuivant() {
    _formKey.currentState!.save();
    if (_verifierChamps()) {
      widget.alert.consequencesObservees = _consequencesSelectionnees;
      widget.alert.nbPersonnesAffectees = int.tryParse(_nbAffectees ?? '0');
      widget.alert.nbPersonnesDeplacees = int.tryParse(_nbDeplaces ?? '0');
      widget.alert.nbDeces = int.tryParse(_nbDeces ?? '0');
      widget.alert.nbBlesses = int.tryParse(_nbBlesses ?? '0');
      widget.alert.infrastructuresTouchees = _infrastructures;
      widget.alert.besoinsUrgents = _besoinsUrgents;
      widget.alert.photos = _photos.map((p) => p.path).toList();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Étape 3 enregistrée avec succès ✅")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewAlertStep4Page(alert: widget.alert),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width * 0.04; // 4% padding responsive
    final photoSize = width * 0.2; // photo adaptative
    final fontSize = width * 0.035; // font adaptative

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvelle Alerte"),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Indicateur des étapes ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: steps.asMap().entries.map((entry) {
                      int stepNumber = entry.key + 1;
                      String label = entry.value;

                      Color circleColor;
                      if (stepNumber < 3) {
                        circleColor = Colors.green;
                      } else if (stepNumber == 3) {
                        circleColor = AppColors.primary;
                      } else {
                        circleColor = Colors.white;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: width * 0.05,
                              backgroundColor: circleColor,
                              child: Text(
                                "$stepNumber",
                                style: TextStyle(
                                  color: stepNumber == 3 ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: width * 0.18,
                              child: Text(
                                label,
                                style: TextStyle(fontSize: fontSize * 0.8),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: padding),

                // --- Conséquences ---
                Text("Types de conséquences observées", style: AppTextStyles.titleMedium),
                SizedBox(height: padding / 2),
                Column(
                  children: _consequences.map((item) {
                    final bool selected = _consequencesSelectionnees.contains(item['label']);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _consequencesSelectionnees.add(item['label']);
                          } else {
                            _consequencesSelectionnees.remove(item['label']);
                          }
                        });
                      },
                      title: Text(item['label'], style: TextStyle(fontSize: fontSize)),
                      secondary: Icon(item['icon'], color: AppColors.primary, size: fontSize + 4),
                      controlAffinity: ListTileControlAffinity.trailing,
                    );
                  }).toList(),
                ),
                SizedBox(height: padding),

                // --- Champs numériques ---
                _buildNumberField("Nombre de personnes affectées", _nbAffectees, (v) => _nbAffectees = v, "Ex: 250", fontSize),
                _buildNumberField("Personnes déplacées", _nbDeplaces, (v) => _nbDeplaces = v, "Ex: 100", fontSize),
                _buildNumberField("Nombre de décès", _nbDeces, (v) => _nbDeces = v, "Ex: 0", fontSize),
                _buildNumberField("Nombre de blessés", _nbBlesses, (v) => _nbBlesses = v, "Ex: 15", fontSize),
                SizedBox(height: padding),

                // --- Infrastructures et besoins ---
                _buildTextField("Infrastructures touchées", _infrastructures, (v) => _infrastructures = v,
                    "Ex: Maisons endommagées, routes coupées, ponts détruits...", fontSize),
                SizedBox(height: padding),
                _buildTextField("Besoins urgents identifiés", _besoinsUrgents, (v) => _besoinsUrgents = v,
                    "Ex: Abris d'urgence, eau potable, kits alimentaires...", fontSize),
                SizedBox(height: padding),

                // --- Photos ---
                Text("Photos et documents", style: AppTextStyles.titleMedium),
                SizedBox(height: 8),
                const Text("Ajoutez des photos pour documenter la situation", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _prendrePhoto,
                        icon: Icon(Icons.camera_alt_outlined, size: fontSize + 2),
                        label: Text("Prendre une photo", style: TextStyle(fontSize: fontSize)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectionGalerie,
                        icon: Icon(Icons.upload_file_outlined, size: fontSize + 2),
                        label: Text("Galerie", style: TextStyle(fontSize: fontSize)),
                      ),
                    ),
                  ],
                ),

                if (_photos.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: padding / 2),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _photos.map((file) {
                        return Image.file(
                          File(file.path),
                          width: photoSize,
                          height: photoSize,
                          fit: BoxFit.cover,
                        );
                      }).toList(),
                    ),
                  ),
                SizedBox(height: padding * 2),

                // --- Navigation ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Précédent", style: TextStyle(fontSize: fontSize))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: padding * 2, vertical: padding / 1.5),
                      ),
                      onPressed: _onSuivant,
                      child: Text("Suivant", style: TextStyle(fontSize: fontSize)),
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

  Widget _buildNumberField(String label, String? initialValue, Function(String?) onSaved, String hint, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleMedium.copyWith(fontSize: fontSize)),
        SizedBox(height: 8),
        TextFormField(
          keyboardType: TextInputType.number,
          initialValue: initialValue,
          decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
          onSaved: onSaved,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(String label, String? initialValue, Function(String?) onSaved, String hint, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleMedium.copyWith(fontSize: fontSize)),
        SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: 2,
          decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
          onSaved: onSaved,
        ),
      ],
    );
  }
}






