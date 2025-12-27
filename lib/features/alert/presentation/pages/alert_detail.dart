/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/user/data/sources/user_local_service.dart';

class AlertDetailsPage extends StatefulWidget {
  final String alertId;
  const AlertDetailsPage({super.key, required this.alertId});

  @override
  State<AlertDetailsPage> createState() => _AlertDetailsPageState();
}

class _AlertDetailsPageState extends State<AlertDetailsPage> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? alertData;

  @override
  void initState() {
    super.initState();
    _loadAlert();
  }

  Future<String?> _getToken() async {
    try {
      return await UserLocalService().getAccessToken();
    } catch (_) {
      return null;
    }
  }

  Future<String?> _refreshAccessToken() async {
    try {
      final refresh = await UserLocalService().getRefreshToken();
      if (refresh == null || refresh.isEmpty) return null;
      final url = Uri.parse("http://197.239.116.77:3000/api/v1/auth/refresh");
      final resp = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refresh}));
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        final data = decoded['data'] ?? decoded;
        final newAccess = (data is Map) ? (data['accessToken'] ?? data['access_token']) : null;
        final newRefresh = (data is Map) ? (data['refreshToken'] ?? data['refresh_token']) : null;
        if (newAccess is String && newAccess.isNotEmpty) {
          await UserLocalService().saveTokens(newAccess, newRefresh is String ? newRefresh : refresh);
          return newAccess;
        }
      }
    } catch (e) {
      debugPrint('refresh token error: $e');
    }
    return null;
  }

  Future<void> _loadAlert() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      String? token = await _getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          error = "Token manquant - reconnecte toi";
          loading = false;
        });
        return;
      }

      final url = Uri.parse("http://197.239.116.77:3000/api/v1/alerts/${widget.alertId}");
      Map<String, String> headers() => {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
      var resp = await http.get(url, headers: headers());

      if (resp.statusCode == 401) {
        final newToken = await _refreshAccessToken();
        if (newToken != null && newToken.isNotEmpty) {
          token = newToken;
          resp = await http.get(url, headers: headers());
        }
      }

      if (resp.statusCode != 200) {
        setState(() {
          error = "Erreur serveur (${resp.statusCode})";
          loading = false;
        });
        return;
      }

      final decoded = jsonDecode(resp.body);
      Map<String, dynamic>? obj;
      if (decoded is Map) {
        if (decoded['data'] is Map) {
          obj = Map<String, dynamic>.from(decoded['data']);
        } else {
          obj = Map<String, dynamic>.from(decoded);
        }
      }

      setState(() {
        alertData = obj;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = "Erreur réseau: $e";
        loading = false;
      });
    }
  }

  String _formatDate(String? d) {
    if (d == null || d.isEmpty) return '-';
    try {
      final dt = DateTime.tryParse(d);
      if (dt == null) return d;
      return "${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
    } catch (_) {
      return d;
    }
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de l'alerte"),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(error!, style: const TextStyle(color: Colors.red)),
                ))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header card
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFE53935)]),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.warning_amber_rounded, size: 28, color: Colors.white),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                alertData?['title'] ?? 'Alerte SAP',
                                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text("ID: ${alertData?['id'] ?? alertData?['_id'] ?? ''}", style: const TextStyle(color: Color(0xFFFFEBEE), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _badge(
                                        (alertData?['status'] ?? '').toString(),
                                        Colors.white.withOpacity(0.18),
                                        Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      _badge(
                                        (alertData?['severity'] ?? '').toString(),
                                        Colors.white.withOpacity(0.18),
                                        Colors.white,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _infoTile("Type", (alertData?['type'] ?? '').toString()),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _infoTile("Zone", (alertData?['zoneName'] ?? (alertData?['zone'] is Map ? alertData!['zone']['name'] : 'Zone non spécifiée')).toString()),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(child: _infoTile("Début", _formatDate(alertData?['startDate']?.toString()))),
                                      const SizedBox(width: 12),
                                      Expanded(child: _infoTile("Fin", _formatDate(alertData?['endDate']?.toString()))),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(child: _infoTile("Action requise", (alertData?['actionRequired'] == true) ? "Oui" : "Non")),
                                      const SizedBox(width: 12),
                                      Expanded(child: _infoTile("Créée par", ((alertData?['createdBy'] is Map) ? "${alertData!['createdBy']['firstName'] ?? ''} ${alertData!['createdBy']['lastName'] ?? ''}" : (alertData?['createdByName'] ?? '—')).toString())),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text("Message", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(alertData?['message'] ?? 'Aucun message', style: const TextStyle(fontSize: 14)),
                        ]),
                      ),

                      const SizedBox(height: 12),

                      // Instructions
                      if ((alertData?['instructions'] ?? '').toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: const [Icon(Icons.info_outline, color: Colors.orange), SizedBox(width: 8), Text("Instructions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
                            const SizedBox(height: 8),
                            Text(alertData?['instructions'] ?? '', style: const TextStyle(fontSize: 14)),
                          ]),
                        ),

                      const SizedBox(height: 12),

                      // System info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text("Informations système", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(child: Text("Créée: ${_formatDate(alertData?['createdAt']?.toString())}")),
                            Expanded(child: Text("Dernière modif: ${_formatDate(alertData?['updatedAt']?.toString())}")),
                          ]),
                        ]),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 6),
      Text(value.isNotEmpty ? value : '—', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    ]);
  }
}*/


///////////////////////////////////////////////////////////////////


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/alert/presentation/pages/create_alert.dart';


import 'package:mobile_app/features/alert/presentation/widgets/alert_media_tab.dart';
import 'package:mobile_app/features/user/data/sources/user_local_service.dart';

class AlertDetailsPage extends StatefulWidget {
  final String alertId;
  const AlertDetailsPage({super.key, required this.alertId});

  @override
  State<AlertDetailsPage> createState() => _AlertDetailsPageState();
}

class _AlertDetailsPageState extends State<AlertDetailsPage> with SingleTickerProviderStateMixin {
  bool loading = true;
  String? error;
  Map<String, dynamic>? alertData;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAlert();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Vérifie si l'alerte est encore modifiable
  /// Règle métier : seule une alerte PENDING peut être modifiée
  bool get _isEditable {
    final status = (alertData?['status'] ?? '').toString().toUpperCase();
    return status == 'PENDING';
  }


  /// Navigation vers la page de création en mode édition
  /// Toutes les données existantes sont transmises
  void _goToEditAlert() {
    if (!_isEditable) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateAlertPage(
          //isEditMode: true,
          existingAlert: alertData!, // données complètes de l’alerte
        ),
      ),
    );
  }



  // ========================== TOKEN / API ==========================
  Future<String?> _getToken() async {
    try {
      return await UserLocalService().getAccessToken();
    } catch (_) {
      return null;
    }
  }

  Future<String?> _refreshAccessToken() async {
    try {
      final refresh = await UserLocalService().getRefreshToken();
      if (refresh == null || refresh.isEmpty) return null;
      final url = Uri.parse("http://197.239.116.77:3000/api/v1/auth/refresh");
      final resp = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refresh}));
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        final data = decoded['data'] ?? decoded;
        final newAccess = (data is Map) ? (data['accessToken'] ?? data['access_token']) : null;
        final newRefresh = (data is Map) ? (data['refreshToken'] ?? data['refresh_token']) : null;
        if (newAccess is String && newAccess.isNotEmpty) {
          await UserLocalService().saveTokens(newAccess, newRefresh is String ? newRefresh : refresh);
          return newAccess;
        }
      }
    } catch (e) {
      debugPrint('refresh token error: $e');
    }
    return null;
  }

  Future<void> _loadAlert() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      String? token = await _getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          error = "Token manquant - reconnecte toi";
          loading = false;
        });
        return;
      }

      final url = Uri.parse("http://197.239.116.77:3000/api/v1/alerts/${widget.alertId}");
      Map<String, String> headers() => {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
      var resp = await http.get(url, headers: headers());

      if (resp.statusCode == 401) {
        final newToken = await _refreshAccessToken();
        if (newToken != null && newToken.isNotEmpty) {
          token = newToken;
          resp = await http.get(url, headers: headers());
        }
      }

      if (resp.statusCode != 200) {
        setState(() {
          error = "Erreur serveur (${resp.statusCode})";
          loading = false;
        });
        return;
      }

      final decoded = jsonDecode(resp.body);
      Map<String, dynamic>? obj;
      if (decoded is Map) {
        if (decoded['data'] is Map) {
          obj = Map<String, dynamic>.from(decoded['data']);
        } else {
          obj = Map<String, dynamic>.from(decoded);
        }
      }

      setState(() {
        alertData = obj;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = "Erreur réseau: $e";
        loading = false;
      });
    }
  }

  String _formatDate(String? d) {
    if (d == null || d.isEmpty) return '-';
    try {
      final dt = DateTime.tryParse(d);
      if (dt == null) return d;
      return "${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
    } catch (_) {
      return d;
    }
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 6),
      Text(value.isNotEmpty ? value : '—', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de l'alerte"),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.orange,
          tabs: const [
            Tab(text: "Détails complets"),
            Tab(text: "Médias"),
            Tab(text: "Commentaires"),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(error!, style: const TextStyle(color: Colors.red)),
                ))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // =================== Onglet Détails complets ===================
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== Header card =====
                          Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFE53935)]),
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.warning_amber_rounded, size: 28, color: Colors.white),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    alertData?['title'] ?? 'Alerte SAP',
                                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text("ID: ${alertData?['id'] ?? alertData?['_id'] ?? ''}", style: const TextStyle(color: Color(0xFFFFEBEE), fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          _badge((alertData?['status'] ?? '').toString(), Colors.white.withOpacity(0.18), Colors.white),
                                          const SizedBox(height: 8),
                                          _badge((alertData?['severity'] ?? '').toString(), Colors.white.withOpacity(0.18), Colors.white),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: _infoTile("Type", (alertData?['type'] ?? '').toString())),
                                          const SizedBox(width: 12),
                                          Expanded(child: _infoTile("Zone", (alertData?['zoneName'] ?? (alertData?['zone'] is Map ? alertData!['zone']['name'] : 'Zone non spécifiée')).toString())),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(child: _infoTile("Début", _formatDate(alertData?['startDate']?.toString()))),
                                          const SizedBox(width: 12),
                                          Expanded(child: _infoTile("Fin", _formatDate(alertData?['endDate']?.toString()))),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(child: _infoTile("Action requise", (alertData?['actionRequired'] == true) ? "Oui" : "Non")),
                                          const SizedBox(width: 12),
                                          Expanded(child: _infoTile("Créée par", ((alertData?['createdBy'] is Map) ? "${alertData!['createdBy']['firstName'] ?? ''} ${alertData!['createdBy']['lastName'] ?? ''}" : (alertData?['createdByName'] ?? '—')).toString())),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // ===== Message =====
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text("Message", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text(alertData?['message'] ?? 'Aucun message', style: const TextStyle(fontSize: 14)),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          // ===== Instructions =====
                          if ((alertData?['instructions'] ?? '').toString().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: const [Icon(Icons.info_outline, color: Colors.orange), SizedBox(width: 8), Text("Instructions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
                                const SizedBox(height: 8),
                                Text(alertData?['instructions'] ?? '', style: const TextStyle(fontSize: 14)),
                              ]),
                            ),
                          const SizedBox(height: 12),
                          // ===== System info =====
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text("Informations système", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Row(children: [
                                Expanded(child: Text("Créée: ${_formatDate(alertData?['createdAt']?.toString())}")),
                                Expanded(child: Text("Dernière modif: ${_formatDate(alertData?['updatedAt']?.toString())}")),
                              ]),
                            ]),
                          ),
                          const SizedBox(height: 16),

                          // =================== BOUTONS ACTIONS (Modifier / Annuler) ===================
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmallScreen = constraints.maxWidth < 500;

                              return Row(
                                children: [
                                  // ===== Bouton Modifier =====
                                  if (_isEditable)
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text("Modifier"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: _goToEditAlert,
                                      ),
                                    ),

                                  if (_isEditable) const SizedBox(width: 12),

                                  // ===== Bouton Annuler =====
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.close),
                                      label: const Text("Annuler"),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          

                        ],
                      ),
                    ),

     // =================== Onglet Médias ===================
             
          const AlertMediaTab(),



              // =================== Onglet Commentaires ===================
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Commentaires", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),

                    // Liste des commentaires existants
                    if (alertData?['comments'] != null && (alertData!['comments'] as List).isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (alertData!['comments'] as List).length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final comment = alertData!['comments'][index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment['author'] ?? 'Anonyme',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(comment['message'] ?? ''),
                                const SizedBox(height: 4),
                                Text(
                                  comment['createdAt'] != null ? _formatDate(comment['createdAt']) : '',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      const Text("Aucun commentaire."),

                    const SizedBox(height: 16),
                    // Ajouter un commentaire
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: "Ajouter un commentaire...",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _postComment,
                          child: const Text("Envoyer"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

// =================== CONTROLLER ET FONCTIONS ===================
final TextEditingController _commentController = TextEditingController();

Future<void> _postComment() async {
  final message = _commentController.text.trim();
  if (message.isEmpty) return;

  try {
    final token = await _getToken();
    if (token == null) return;

    final url = Uri.parse("http://197.239.116.77:3000/api/v1/alerts/${widget.alertId}/comments");
    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'message': message}));

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      // Ajouter localement pour refresh immédiat
      setState(() {
        if (alertData?['comments'] == null) alertData!['comments'] = [];
        alertData!['comments'].add({
          'author': 'Moi', // remplacer par l'utilisateur réel si dispo
          'message': message,
          'createdAt': DateTime.now().toIso8601String(),
        });
        _commentController.clear();
      });
    } else {
      debugPrint("Erreur envoi commentaire: ${resp.statusCode}");
    }
  } catch (e) {
    debugPrint("Erreur envoi commentaire: $e");
  }     
} 
} 