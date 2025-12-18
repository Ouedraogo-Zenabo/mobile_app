/*import 'package:flutter/material.dart';
import '../../data/alert_repository.dart';
import '../../domain/alert_model.dart';
import '../widgets/alert_card.dart';

class AlertsListPage extends StatefulWidget {
  const AlertsListPage({super.key});

  @override
  State<AlertsListPage> createState() => _AlertsListPageState();
}

class _AlertsListPageState extends State<AlertsListPage> {
  final repo = AlertRepository();

  List<AlertModel> alerts = [];
  List<AlertModel> filtered = [];

  String selectedFilter = "Toutes";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    alerts = await repo.fetchAlerts();
    filtered = alerts;
    setState(() {});
  }

  void applyFilters() {
    filtered = alerts.where((a) {
      final matchSearch =
          a.type.toLowerCase().contains(searchQuery.toLowerCase()) ||
          a.region.toLowerCase().contains(searchQuery.toLowerCase());

      final matchFilter =
          selectedFilter == "Toutes" || a.status == selectedFilter;

      return matchSearch && matchFilter;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Alertes"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => print("Créer nouvelle alerte"),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, size: 28),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// 🔍 Barre de recherche
            TextField(
              decoration: InputDecoration(
                hintText: "Rechercher...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) {
                searchQuery = v;
                applyFilters();
              },
            ),

            const SizedBox(height: 12),

            /// 🔘 Filtres
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterButton("Toutes"),
                  _filterButton("Soumise"),
                  _filterButton("Transmise"),
                  _filterButton("Évaluée"),
                  _filterButton("Urgent"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// 📌 Liste des alertes
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text("Aucune alerte trouvée"))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => AlertCard(alert: filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bouton de filtre
  Widget _filterButton(String label) {
    final isSelected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          selectedFilter = label;
          applyFilters();
        },
      ),
    );
  }
}
*/