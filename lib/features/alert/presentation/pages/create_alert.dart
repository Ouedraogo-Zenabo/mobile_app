import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mobile_app/features/user/data/sources/user_local_service.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
const bool isWeb = kIsWeb;

class CreateAlertPage extends StatefulWidget {
  const CreateAlertPage({super.key});

  @override
  _CreateAlertPageState createState() => _CreateAlertPageState();
}

class _CreateAlertPageState extends State<CreateAlertPage> {
  bool loading = false;
  bool zonesLoading = false;
  String? errorMessage;

  List zones = [];
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _otherTypeController = TextEditingController();
  final TextEditingController _audioDescriptionController = TextEditingController();

  // Image (optionnelle)
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  // Audio recording
  AudioRecorder? _audioRecorder;
  AudioPlayer? _audioPlayer;

  String? _audioPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _recordDuration = Duration.zero;

  // Image (optional)
  Uint8List? selectedImageBytes;
  String? selectedImageName;
  

  // FORM DATA
  final form = {
    "title": "",
    "message": "",
    "type": "FLOOD",
    "severity": "MODERATE",
    "zoneId": "",
    "startDate": "",
    "startTime": "",
    "endDate": "",
    "endTime": "",
    "instructions": "",
    "actionRequired": false
  };

  final alertTypes = [
    {"value": "FLOOD", "label": "Inondation"},
    {"value": "DROUGHT", "label": "Sécheresse"},
    {"value": "EPIDEMIC", "label": "Épidémie"},
    {"value": "FIRE", "label": "Incendie"},
    {"value": "STORM", "label": "Tempête"},
    {"value": "EARTHQUAKE", "label": "Tremblement de terre"},
    {"value": "SECURITY", "label": "Sécurité/Conflit"},
    {"value": "FAMINE", "label": "Famine"},
    {"value": "LOCUST", "label": "Invasion acridienne"},
    {"value": "OTHER", "label": "Autre"}
  ];

  final severityLevels = [
    {"value": "INFO", "label": "Information"},
    {"value": "LOW", "label": "Faible"},
    {"value": "MODERATE", "label": "Modéré"},
    {"value": "HIGH", "label": "Élevé"},
    {"value": "CRITICAL", "label": "Critique"},
    {"value": "EXTREME", "label": "Extrême"}
  ];

  @override
  void initState() {
    super.initState();
    _loadZones();
    form["startDate"] = DateTime.now().toIso8601String().split("T")[0];// Date du jour par défaut (format YYYY-MM-DD)
    _startDateController.text = form["startDate"]?.toString() ?? "";
    _setupAudioPlayer();
    if (!kIsWeb) {
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }
  }

  void _setupAudioPlayer() {
  if (_audioPlayer == null) return;

  _audioPlayer!.onPlayerStateChanged.listen((state) {
    if (mounted) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    }
  });
}


  @override
  void dispose() {
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    _otherTypeController.dispose();
    _audioDescriptionController.dispose();
    super.dispose();
  }

  Future<String?> _getAccessTokenFromProfile() async {
    try {
      return await UserLocalService().getAccessToken();
    } catch (e) {
      print("Erreur lecture token : $e");
      return null;
    }
  }

    // GET ZONES
  Future<void> _loadZones() async {
    setState(() => zonesLoading = true);

    try {
      final token = await _getAccessTokenFromProfile();

      if (token == null || token.isEmpty) {
        print("❌ Token vide - impossible de charger les zones");
        setState(() {
          errorMessage = "Token d'authentification manquant";
          zonesLoading = false;
        });
        return;
      }

      final url = Uri.parse("http://197.239.116.77:3000/api/v1/zones?type=COMMUNE&limit=200");
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print("📡 GET zones avec Authorization header...");
      final response = await http.get(url, headers: headers);

      print("✅ Zones Response Status: ${response.statusCode}");
      print("📦 Zones Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print("✅ Decoded response type: ${decoded.runtimeType}");
        print("✅ Decoded response: $decoded");
        
        // 🔥 CORRECTION : Gestion de plusieurs formats de réponse
        List zonesData = [];
        
        if (decoded is List) {
          // Format: [{"id": "...", "name": "..."}, ...]
          zonesData = decoded;
        } else if (decoded is Map) {
          // Format: {"zones": [...]} ou {"data": [...]} ou {"data": {"zones": [...]}}
          if (decoded["zones"] is List) {
            zonesData = decoded["zones"];
          } else if (decoded["data"] is List) {
            zonesData = decoded["data"];
          } else if (decoded["data"] is Map && decoded["data"]["zones"] is List) {
            zonesData = decoded["data"]["zones"];
          } else if (decoded["success"] == true && decoded["data"] is Map) {
            // Format: {"success": true, "data": {"zones": [...], "total": 10}}
            zonesData = decoded["data"]["zones"] ?? [];
          }
        }

        print("✅ Zones extraites: ${zonesData.length} zones");

        setState(() {
          zones = zonesData;
          
          if (zones.isNotEmpty && (form["zoneId"] == null || form["zoneId"].toString().isEmpty)) {
            form["zoneId"] = zones[0]["id"];
            print("✅ Zone par défaut définie: ${zones[0]["id"]}");
          }
          zonesLoading = false;
          errorMessage = null;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = "Non autorisé (401) - Reconnecte-toi";
          zonesLoading = false;
        });
        print("❌ 401 - Token invalide ou expiré");
      } else {
        setState(() {
          errorMessage = "Erreur serveur (${response.statusCode}): ${response.body}";
          zonesLoading = false;
        });
        print("❌ Erreur ${response.statusCode}: ${response.body}");
      }
    } catch (e, stackTrace) {
      print("❌ Exception: $e");
      print("❌ StackTrace: $stackTrace");
      setState(() {
        errorMessage = "Erreur réseau: $e";
        zonesLoading = false;
      });
    }
  }

    // Audio recording functions
  Future<void> _startRecording() async {
          if (kIsWeb) {
        setState(() => errorMessage = "L'enregistrement audio n'est pas disponible sur le Web");
        return;
      }

    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        setState(() => errorMessage = "Permission microphone refusée");
        return;
      }

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder!.start(const RecordConfig(), path: path);
      setState(() {
        _isRecording = true;
        _recordDuration = Duration.zero;
      });

      // Update duration
      Stream.periodic(const Duration(seconds: 1)).listen((_) {
        if (_isRecording && mounted) {
          setState(() => _recordDuration += const Duration(seconds: 1));
        }
      });
    } catch (e) {
      debugPrint("Error starting recording: $e");
      setState(() => errorMessage = "Erreur lors du démarrage de l'enregistrement: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder!.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
      debugPrint("Recording saved at: $path");
    } catch (e) {
      debugPrint("Error stopping recording: $e");
      setState(() => errorMessage = "Erreur lors de l'arrêt de l'enregistrement: $e");
    }
  }

  Future<void> _playAudio() async {
    if (_audioPath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer!.pause();
      } else {
        await _audioPlayer!.play(DeviceFileSource(_audioPath!));
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
      setState(() => errorMessage = "Erreur lors de la lecture audio: $e");
    }
  }

  void _deleteAudio() {
    setState(() {
      _audioPath = null;
      _recordDuration = Duration.zero;
      _audioDescriptionController.clear();
      form["audioDescription"] = "";
    });
  }


  // 📅 Sélection de date
Future<void> _pickDate({required bool isStart}) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    final formatted = picked.toIso8601String().split("T")[0];
    setState(() {
      if (isStart) {
        form["startDate"] = formatted;
        _startDateController.text = formatted;
      } else {
        form["endDate"] = formatted;
      }
    });
  }
}

// ⏰ Sélection de l’heure
Future<void> _pickTime({required bool isStart}) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (picked != null) {
    final formatted =
        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    setState(() {
      if (isStart) {
        form["startTime"] = formatted;
      } else {
        form["endTime"] = formatted;
      }
    });
  }
}

// 📷 Caméra / Galerie
Future<void> _pickImage(ImageSource source) async {
  final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
  if (image != null) {
    setState(() => selectedImage = File(image.path));
  }
}




  // POST alert
  Future<void> _submitAlert(String status) async {
    print("=== DEBUG: _submitAlert appelé avec status=$status ===");
    print("Form data: $form");
    print("canSubmit value: $canSubmit");

    if (!canSubmit) {
      final titleLen = form["title"].toString().trim().length;
      final messageLen = form["message"].toString().trim().length;
      final zoneId = (form["zoneId"] ?? "").toString();
      final startDate = (form["startDate"] ?? "").toString();

      setState(() => errorMessage = "Veuillez remplir tous les champs obligatoires.\n"
          "Titre (min 5 chars): $titleLen/5\n"
          "Message (min 10 chars): $messageLen/10\n"
          "Zone: ${zoneId.isEmpty ? 'vide' : 'OK'}\n"
          "Date début: ${startDate.isEmpty ? 'vide' : 'OK'}");
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
    });

    final startDateTime = _combineDateTime(form["startDate"] as String?, form["startTime"] as String?);
    final endDateTime = (form["endDate"] ?? "").toString().isNotEmpty
        ? _combineDateTime(form["endDate"] as String?, form["endTime"] as String?)
        : null;

    final data = {
      "title": form["title"],
      "message": form["message"],
      "type": form["type"],
      "severity": form["severity"],
      "zoneId": form["zoneId"],
      "startDate": startDateTime,
      "endDate": endDateTime,
      "instructions": form["instructions"],
      "actionRequired": form["actionRequired"],
      "status": status,
    };

    print("Sending alert with data: $data");

    final url = Uri.parse("http://197.239.116.77:3000/api/v1/alerts");
    try {
      final token = await _getAccessTokenFromProfile();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      print("API Response status: ${response.statusCode}");
      print("API Response body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() => errorMessage = "Erreur serveur (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("ERROR: Erreur réseau - $e");
      setState(() => errorMessage = "Erreur réseau : $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // SAVE draft
  Future<void> _saveDraft() async {
    print("=== DEBUG: _saveDraft appelé ===");
    print("Form data: $form");

    setState(() {
      loading = true;
      errorMessage = null;
    });

    final startDateTime = _combineDateTime(form["startDate"] as String?, form["startTime"] as String?);
    final endDateTime = (form["endDate"] ?? "").toString().isNotEmpty
        ? _combineDateTime(form["endDate"] as String?, form["endTime"] as String?)
        : null;

    final data = {
      "title": form["title"],
      "message": form["message"],
      "type": form["type"],
      "severity": form["severity"],
      "zoneId": form["zoneId"],
      "startDate": startDateTime,
      "endDate": endDateTime,
      "instructions": form["instructions"],
      "actionRequired": form["actionRequired"],
      "status": "DRAFT",
    };

    print("Saving draft with data: $data");

    final url = Uri.parse("http://197.239.116.77:3000/api/v1/alerts");
    try {
      final token = await _getAccessTokenFromProfile();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      print("API Response status: ${response.statusCode}");
      print("API Response body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() => errorMessage = "Erreur serveur (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("ERROR: Erreur réseau - $e");
      setState(() => errorMessage = "Erreur réseau : $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  bool get canSubmit {
    return form["title"].toString().trim().length >= 5 &&
        form["message"].toString().trim().length >= 10 &&
        (form["zoneId"] ?? "").toString().isNotEmpty &&
        (form["startDate"] ?? "").toString().isNotEmpty;
  }

  String? _combineDateTime(String? date, String? time) {
    if ((date ?? "").isEmpty) return null;
    int hour = 0;
    int minute = 0;
    if ((time ?? "").isNotEmpty) {
      final parts = (time ?? "").split(":");
      if (parts.length >= 2) {
        hour = int.tryParse(parts[0]) ?? 0;
        minute = int.tryParse(parts[1]) ?? 0;
      }
    }
    try {
      final parts = date!.split("-");
      if (parts.length >= 3) {
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2]);
        final dt = DateTime(y, m, d, hour, minute);
        return dt.toIso8601String();
      } else {
        final parsed = DateTime.tryParse(date);
        if (parsed != null) {
          final dt = DateTime(parsed.year, parsed.month, parsed.day, hour, minute);
          return dt.toIso8601String();
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final padding = isMobile ? 16.0 : 32.0;
    final maxWidth = 600.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer une alerte"),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      // Error Message
                      if (errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.red[100],
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("❌ Erreur", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              Text(errorMessage!, style: TextStyle(color: Colors.red[900])),
                            ],
                          ),
                        ),
                      // Debug status
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.blue[50],
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          zonesLoading ? "⏳ Chargement des zones..." : "✅ Zones: ${zones.length} chargée(s)",
                          style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                        ),
                      ),
                      // Title
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Titre *",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() => form["title"] = v),
                      ),
                      const SizedBox(height: 16),
                      
                      

                      // Type & Severity
                      isMobile
                          ? Column(
                              children: [
                                DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    labelText: "Type d'alerte",
                                    border: OutlineInputBorder(),
                                  ),
                                  initialValue: form["type"],
                                  items: alertTypes
                                      .map((e) => DropdownMenuItem(
                                          value: e["value"], child: Text(e["label"]!)))
                                      .toList(),
                                  onChanged: (v) => setState(() => form["type"] = v ?? ""),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    labelText: "Sévérité",
                                    border: OutlineInputBorder(),
                                  ),
                                  initialValue: form["severity"],
                                  items: severityLevels
                                      .map((e) => DropdownMenuItem(
                                          value: e["value"], child: Text(e["label"]!)))
                                      .toList(),
                                  onChanged: (v) => setState(() => form["severity"] = v ?? ""),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      labelText: "Type d'alerte",
                                      border: OutlineInputBorder(),
                                    ),
                                    initialValue: form["type"],
                                    items: alertTypes
                                        .map((e) => DropdownMenuItem(
                                            value: e["value"], child: Text(e["label"]!)))
                                        .toList(),
                                    onChanged: (v) => setState(() => form["type"] = v ?? ""),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      labelText: "Sévérité",
                                      border: OutlineInputBorder(),
                                    ),
                                    initialValue: form["severity"],
                                    items: severityLevels
                                        .map((e) => DropdownMenuItem(
                                            value: e["value"], child: Text(e["label"]!)))
                                        .toList(),
                                    onChanged: (v) => setState(() => form["severity"] = v ?? ""),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 16),
                      // Conditional "Other" type field
                      if (form["type"] == "OTHER") ...[
                        const SizedBox(height: 28),
                        _buildLabel("Spécifiez le type d'alerte *", Icons.edit),
                        const SizedBox(height: 12),
                        _buildTextField(
                          hintText: "Ex: Pollution, Accident routier, etc.",
                          controller: _otherTypeController,
                          onChanged: (v) => setState(() => form["customType"] = v),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Zone dropdown
                      if (zonesLoading)
                        const CircularProgressIndicator()
                      else if (zones.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.orange[50],
                          child: const Text("Aucune zone disponible - Vérifiez votre token"),
                        )
                      else
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            labelText: "Zone géographique *",
                            border: OutlineInputBorder(),
                          ),
                          isExpanded: true,
                          initialValue: form["zoneId"],
                          items: zones
                              .map((z) => DropdownMenuItem(
                                    value: z["id"],
                                    child: Text("${z["name"] ?? 'N/A'} (${z["type"] ?? 'N/A'})"),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => form["zoneId"] = v ?? ""),
                        ),
                      const SizedBox(height: 16),
                      // Period
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Période de l'événement", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          isMobile
                              ? Column(
                                  children: [
                                   TextField(
                                    controller: _startDateController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: "Date début",
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    onTap: () async {
                                      final DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );

                                      if (picked != null) {
                                        final formatted =
                                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                        _startDateController.text = formatted;  // ✅ Met à jour le champ affiché
                                        setState(() {
                                          form["startDate"] = formatted;         // ✅ Met à jour la donnée pour la base
                                        });
                                      }
                                    },
                                  ),


                                    const SizedBox(height: 12),
                                   TextField(
                                          controller: _startTimeController,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            labelText: "Heure début",
                                            border: OutlineInputBorder(),
                                            suffixIcon: Icon(Icons.access_time),
                                          ),
                                          onTap: () async {
                                            final TimeOfDay? picked = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );

                                            if (picked != null) {
                                              final formatted =
                                                  "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                                              _startTimeController.text = formatted;   // ✅ Met à jour le champ affiché
                                              setState(() {
                                                form["startTime"] = formatted;         // ✅ Met à jour la donnée pour la base
                                              });
                                            }
                                          },
                                        ),


                                    const SizedBox(height: 16),
                                    TextField(
                                  controller: _endDateController,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: "Date fin",
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );

                                    if (picked != null) {
                                      final formatted =
                                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                      _endDateController.text = formatted;    // Affiche la date choisie dans le champ
                                      setState(() {
                                        form["endDate"] = formatted;          // Stocke la date dans ton formulaire
                                      });
                                    }
                                  },
                                ),


                                    const SizedBox(height: 12),
                                    TextField(
                                    controller: _endTimeController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: "Heure fin",
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.access_time),
                                    ),
                                    onTap: () async {
                                      final TimeOfDay? picked = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );

                                      if (picked != null) {
                                        final formatted =
                                            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                                        _endTimeController.text = formatted;    // Affiche l'heure choisie dans le champ
                                        setState(() {
                                          form["endTime"] = formatted;          // Stocke l'heure dans ton formulaire
                                        });
                                      }
                                    },
                                  ),

                                  ],
                                )
                              : Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _startDateController,
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                              labelText: "Date début",
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(Icons.calendar_today),
                                            ),
                                            onTap: () async {
                                              final DateTime? picked = await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100),
                                              );

                                              if (picked != null) {
                                                final formatted =
                                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                                _startDateController.text = formatted;  // ✅ Met à jour le champ affiché
                                                setState(() {
                                                  form["startDate"] = formatted;         // ✅ Met à jour la donnée pour la base
                                                });
                                              }
                                            },
                                          ),

                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child:TextField(
                                            controller: _startTimeController,
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                              labelText: "Heure début",
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(Icons.access_time),
                                            ),
                                            onTap: () async {
                                              final TimeOfDay? picked = await showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now(),
                                              );

                                              if (picked != null) {
                                                final formatted =
                                                    "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                                                _startTimeController.text = formatted;   // ✅ Met à jour le champ affiché
                                                setState(() {
                                                  form["startTime"] = formatted;         // ✅ Met à jour la donnée pour la base
                                                });
                                              }
                                            },
                                          ),


                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child:TextField(
                                            controller: _endDateController,
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                              labelText: "Date fin",
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(Icons.calendar_today),
                                            ),
                                            onTap: () async {
                                              final DateTime? picked = await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100),
                                              );

                                              if (picked != null) {
                                                final formatted =
                                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                                _endDateController.text = formatted;    // Affiche la date choisie dans le champ
                                                setState(() {
                                                  form["endDate"] = formatted;          // Stocke la date dans ton formulaire
                                                });
                                              }
                                            },
                                          ),


                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextField(
                                          controller: _endTimeController,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            labelText: "Heure fin",
                                            border: OutlineInputBorder(),
                                            suffixIcon: Icon(Icons.access_time),
                                          ),
                                          onTap: () async {
                                            final TimeOfDay? picked = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );

                                            if (picked != null) {
                                              final formatted =
                                                  "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                                              _endTimeController.text = formatted;    // Affiche l'heure choisie dans le champ
                                              setState(() {
                                                form["endTime"] = formatted;          // Stocke l'heure dans ton formulaire
                                              });
                                            }
                                          },
                                        ),

                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Message
                      TextField(
                        decoration: const InputDecoration(labelText: "Message *", border: OutlineInputBorder()),
                        maxLines: 5,
                        onChanged: (v) => setState(() => form["message"] = v),
                      ),
                      const SizedBox(height: 16),
                      // Instructions
                      TextField(
                        decoration: const InputDecoration(labelText: "Instructions", border: OutlineInputBorder()),
                        maxLines: 3,
                        onChanged: (v) => setState(() => form["instructions"] = v),
                      ),
                      // Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: (form["actionRequired"] as bool?) ?? false,
                            onChanged: (val) => setState(() => form["actionRequired"] = val ?? false),
                          ),
                          const Text("Action immédiate requise")
                        ],
                      ),
                      const SizedBox(height: 20),

                      //const SizedBox(height: 16),
                      //const Text("Image (optionnelle)", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Caméra"),
                            onPressed: () => _pickImage(ImageSource.camera),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.photo),
                            label: const Text("Galerie"),
                            onPressed: () => _pickImage(ImageSource.gallery),
                          ),
                        ],
                      ),

                      if (selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Image.file(selectedImage!, height: 150),
                        ),
                    const SizedBox(height: 24),

                      // Buttons
                      isMobile
                          ? Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: loading ? null : () => _saveDraft(),
                                    child: const Text("Enregistrer brouillon"),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: loading ? null : () => _submitAlert("SUBMITTED"),
                                    child: const Text("Créer & soumettre"),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: loading ? null : () => _saveDraft(),
                                    child: const Text("Enregistrer brouillon"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: loading ? null : () => _submitAlert("SUBMITTED"),
                                    child: const Text("Créer & soumettre"),
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

Widget _buildLabel(String text, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 18),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}

Widget _buildTextField({
  required String hintText,
  required TextEditingController controller,
  required Function(String) onChanged,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hintText,
      border: const OutlineInputBorder(),
    ),
    onChanged: onChanged,
  );
}

