import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/alert/domain/alert_model.dart';
import 'package:mobile_app/features/alert/presentation/pages/create_alert.dart';

class NewAlertStep1PageFixed extends StatefulWidget {
  final AlertModel alert;
  const NewAlertStep1PageFixed({super.key, required this.alert});
  @override
  State<NewAlertStep1PageFixed> createState() => _NewAlertStep1PageFixedState();
}

class _NewAlertStep1PageFixedState extends State<NewAlertStep1PageFixed> {
  List<Map<String, dynamic>> zones = [];
  Map<String, dynamic>? selectedZone;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchZones();
  }

  Future<void> fetchZones() async {
    try {
      final url = Uri.parse('http://197.239.116.77:3000/api/v1/zones');
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        setState(() {
          zones = List<Map<String, dynamic>>.from(body['data'] ?? []);
          if (zones.isNotEmpty) selectedZone ??= zones[0];
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void _onNext() {
    if (selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une zone')));
      return;
    }
    widget.alert.zoneId = int.tryParse(selectedZone!['id']?.toString() ?? '');
    Navigator.push(context, MaterialPageRoute(builder: (c) => CreateAlertPage()));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(title: const Text('Localisation de l’évènement')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: isMobile ? 180 : 240,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                  child: const Center(child: Icon(Icons.map, size: 56, color: Colors.blue)),
                ),
                const SizedBox(height: 20),
                const Text('Sélectionnez une zone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                if (isLoading) const Center(child: CircularProgressIndicator())
                else if (hasError) const Text('Erreur lors du chargement des zones.', style: TextStyle(color: Colors.red))
                else
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12)),
                    items: zones.map((z) => DropdownMenuItem(value: z, child: Text('${z['name']} (${z['code'] ?? ''})'))).toList(),
                    initialValue: selectedZone,
                    onChanged: (v) => setState(() => selectedZone = v),
                  ),
                const SizedBox(height: 20),
                if (selectedZone != null) ...[
                  _detailRow('Nom', selectedZone!['name']?.toString() ?? ''),
                  _detailRow('Type', selectedZone!['type']?.toString() ?? ''),
                  _detailRow('ID', selectedZone!['id']?.toString() ?? ''),
                  const SizedBox(height: 16),
                ],
                const Spacer(),
                isMobile
                    ? Column(children: [
                        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler'))),
                        const SizedBox(height: 8),
                        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _onNext, child: const Text('Suivant'))),
                      ])
                    : Row(children: [
                        OutlinedButton(onPressed: () => Navigator.pop(context), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14), child: Text('Annuler'))),
                        const SizedBox(width: 12),
                        ElevatedButton(onPressed: _onNext, child: const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14), child: Text('Suivant'))),
                      ])
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), Flexible(child: Text(value))]));
  }
}
