import 'dart:convert';
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
}