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
  //final bool isEditMode;
  final Map<String, dynamic>? existingAlert;

  const CreateAlertPage({
    super.key,
    //this.isEditMode = false,
    this.existingAlert,
  });


  @override
  State<CreateAlertPage> createState() => _CreateAlertPageState();
  
}

class _CreateAlertPageState extends State<CreateAlertPage> {
  bool loading = false;
  bool zonesLoading = false;
  String? errorMessage;
  String? selectedRegionId;
  String? selectedProvinceId;
  String? selectedCommuneId;

  List<Map<String, dynamic>> regions = [];
 
  List<Map<String, dynamic>> filteredProvinces = [];
  List<Map<String, dynamic>> filteredCommunes = [];

  


  
  List zones = [];
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _otherTypeController = TextEditingController();
  final TextEditingController _audioDescriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

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
  String? _audioDescriptionError;

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

  // Gestion des localisations multiples
List<Map<String, dynamic>> localisations = [
  {
    "region": null,
    "province": null,
    "commune": null,
    "provinces": [],
    "communes": []
  }
];

// Liste pour stocker les régions depuis l'API
List<Map<String, dynamic>> regionsApi = [];


 @override
void initState() {
  super.initState();

  // =================== Chargements initiaux ===================
  _loadZones();
  _loadRegions();

  // =================== AUDIO ===================
  if (!kIsWeb) {
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

 final alert = widget.existingAlert;

if (alert != null) {
  form["title"] = alert["title"] ?? "";
  form["message"] = alert["message"] ?? "";
  form["instructions"] = alert["instructions"] ?? "";
  form["type"] = alert["type"];
  form["severity"] = alert["severity"];
  form["zoneId"] = alert["zone"]?["id"] ?? alert["zoneId"];
  form["actionRequired"] = alert["actionRequired"] ?? false;
  _titleController.text = form["title"] as String;
  _messageController.text = form["message"] as String;
  _instructionsController.text = form["instructions"] as String;

  if (alert["startDate"] != null) {
    final start = DateTime.tryParse(alert["startDate"]);
    if (start != null) {
      form["startDate"] = start.toIso8601String().split("T")[0];
      _startDateController.text = form["startDate"]?.toString() ?? "";
    }
  }

  if (alert["endDate"] != null) {
    final end = DateTime.tryParse(alert["endDate"]);
    if (end != null) {
      form["endDate"] = end.toIso8601String().split("T")[0];
      _endDateController.text = form["endDate"]?.toString() ?? "";
    }
  }

  // 🔥 LIGNE CRUCIALE 🔥
  WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {});
  });
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


Future<void> _loadRegions() async {
  try {
    final token = await _getAccessTokenFromProfile();

    final url = Uri.parse(
      "http://197.239.116.77:3000/api/v1/zones?type=REGION",
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("Regions status: ${response.statusCode}");
    print("Regions body: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List zones = decoded["data"]["zones"];

      setState(() {
        regions = zones
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });
    }
  } catch (e) {
    print("❌ Erreur chargement régions: $e");
  }
}


Future<void> _loadProvincesForLoc(
  Map<String, dynamic> loc,
  String regionId,
) async {
  final token = await _getAccessTokenFromProfile();

  final url = Uri.parse(
    "http://197.239.116.77:3000/api/v1/zones?type=PROVINCE",
  );

  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final List allProvinces = decoded["data"]["zones"];

    setState(() {
      loc["provinces"] = allProvinces
          .where((p) => p["parentId"] == regionId)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    });
  }
}


Future<void> _loadCommunesForLoc(
  Map<String, dynamic> loc,
  String provinceId,
) async {
  final token = await _getAccessTokenFromProfile();

  final url = Uri.parse(
    "http://197.239.116.77:3000/api/v1/zones?type=COMMUNE",
  );

  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final List allCommunes = decoded["data"]["zones"];

    setState(() {
      loc["communes"] = allCommunes
          .where((c) => c["parentId"] == provinceId)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
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

                    Future<void> _saveDraft() async {
  debugPrint("=== SAVE DRAFT ===");
  debugPrint("Form: $form");

  // 🔴 RÈGLE : description obligatoire si audio existe
  if (_audioPath != null &&
      _audioDescriptionController.text.trim().isEmpty) {
    setState(() {
      _audioDescriptionError =
          "Veuillez décrire le contenu de l'enregistrement audio.";
    });
    return; // ⛔ STOP ici, pas d'appel API
  } else {
    _audioDescriptionError = null;
  }

  setState(() {
    loading = true;
    errorMessage = null;
  });

  // 🔁 Dates combinées (si présentes)
  final startDateTime =
      _combineDateTime(form["startDate"] as String?, form["startTime"] as String?);

  final endDateTime =
      (form["endDate"] ?? "").toString().isNotEmpty
          ? _combineDateTime(form["endDate"] as String?, form["endTime"] as String?)
          : null;

  // 📦 DONNÉES À ENVOYER
  final data = {
    "title": form["title"] ?? "",
    "message": form["message"] ?? "",
    "type": form["type"],
    "severity": form["severity"],
    "zoneId": form["zoneId"],
    "startDate": startDateTime,
    "endDate": endDateTime,
    "instructions": form["instructions"],
    "actionRequired": form["actionRequired"],
    "status": "DRAFT",

    // 🎧 Audio (si présent)
    "audioDescription": _audioDescriptionController.text.trim(),
  };

  debugPrint("Draft payload: $data");

  final url = Uri.parse("http://197.239.116.77:3000/api/v1/alerts");

  try {
    final token = await _getAccessTokenFromProfile();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    debugPrint("Draft response ${response.statusCode}");
    debugPrint(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Brouillon enregistré avec succès"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      setState(() {
        errorMessage =
            "Erreur serveur (${response.statusCode}) : ${response.body}";
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = "Erreur réseau : $e";
    });
  } finally {
    if (mounted) {
      setState(() => loading = false);
    }
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
                        controller: _titleController,
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


                    ...List.generate(localisations.length, (index) {
                          final loc = localisations[index];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [

                              // REGION
                              DropdownButtonFormField<Map<String, dynamic>>(
                                decoration: const InputDecoration(
                                  labelText: "Région *",
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                value: loc["region"],
                                isExpanded: true,
                                items: regions.map((r) {
                                  return DropdownMenuItem(
                                    value: r,
                                    child: Text(r["name"]),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    loc["region"] = val;
                                    loc["province"] = null;
                                    loc["commune"] = null;
                                    loc["provinces"] = [];
                                    loc["communes"] = [];

                                    if (val != null) {
                                      _loadProvincesForLoc(loc, val["id"]);
                                    }
                                  });
                                },
                              ),

                              const SizedBox(height: 16),

                              // PROVINCE
                              DropdownButtonFormField<Map<String, dynamic>>(
                                decoration: const InputDecoration(
                                  labelText: "Province *",
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                value: loc["province"],
                                isExpanded: true,
                                items: (loc["provinces"] as List)
                                    .map<DropdownMenuItem<Map<String, dynamic>>>((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(p["name"]),
                                  );
                                }).toList(),
                                onChanged: loc["region"] == null
                                    ? null
                                    : (val) {
                                        setState(() {
                                          loc["province"] = val;
                                          loc["commune"] = null;
                                          loc["communes"] = [];

                                          if (val != null) {
                                            _loadCommunesForLoc(loc, val["id"]);
                                          }
                                        });
                                      },
                              ),

                              const SizedBox(height: 16),

                              // COMMUNE
                              DropdownButtonFormField<Map<String, dynamic>>(
                                decoration: const InputDecoration(
                                  labelText: "Commune *",
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                value: loc["commune"],
                                isExpanded: true,
                                items: (loc["communes"] as List)
                                    .map<DropdownMenuItem<Map<String, dynamic>>>((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(c["name"]),
                                  );
                                }).toList(),
                                onChanged: loc["province"] == null
                                    ? null
                                    : (val) {
                                        setState(() {
                                          loc["commune"] = val;
                                          form["zoneId"] = val?["id"] ?? "";
                                        });
                                      },
                              ),

                              const SizedBox(height: 24),

                              if (localisations.length > 1)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => setState(() => localisations.removeAt(index)),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    label: const Text("Supprimer",
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ),

                              const Divider(height: 32),
                            ],
                          );
                        }),


                        // Ajouter un autre groupe
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Ajouter une autre localisation"),
                            onPressed: () => setState(() => localisations.add({
                              "region": null,
                              "province": null,
                              "commune": null,
                              "provinces": [],
                              "communes": []
                            })),
                          ),
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
                        controller: _messageController,
                        decoration: const InputDecoration(labelText: "Message *", border: OutlineInputBorder()),
                        maxLines: 5,
                        onChanged: (v) => setState(() => form["message"] = v),
                      ),
                      const SizedBox(height: 16),
                      // Instructions
                      TextField(
                        controller: _instructionsController,
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

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Caméra"),
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.photo),
                              label: const Text("Galerie"),
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),

                      if (selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Image.file(selectedImage!, height: 150),
                        ),
                    const SizedBox(height: 24),

                    // ================= AUDIO (OPTIONNEL) =================
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Enregistrement audio (optionnel)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          // Bouton enregistrer / arrêter
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                              label: Text(_isRecording ? "Arrêter l'enregistrement" : "Enregistrer un audio"),
                              onPressed: _isRecording ? _stopRecording : _startRecording,
                            ),
                          ),

                          const SizedBox(height: 8),

                        // Lecture / suppression si audio existe
                        if (_audioPath != null)
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                                onPressed: _playAudio,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: _deleteAudio,
                              ),
                              const Text("Audio enregistré"),
                            ],
                          ),

                        const SizedBox(height: 12),

                        // Description audio (OBLIGATOIRE SI AUDIO)
                        TextField(
                          controller: _audioDescriptionController,
                          maxLines: 2,
                          onChanged: (_) {
                            if (_audioDescriptionError != null) {
                              setState(() => _audioDescriptionError = null);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: "Description de l'enregistrement audio",
                            hintText: "Décrivez le contenu de l'audio",
                            border: const OutlineInputBorder(),
                            errorText: _audioDescriptionError,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
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

