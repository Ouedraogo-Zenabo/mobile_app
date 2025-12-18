/*class AlertRepository {
  Future<List<AlertModel>> fetchAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300)); // simulation API

    return [
      AlertModel(
        id: "1",
        type: "Inondation",
        date: DateTime(2025, 10, 28),
        region: "Boucle du Mouhoun, Balé, Sibi",
        affectedPeople: 250,
        status: "Urgent",
        icon: "flood",
      ),
      AlertModel(
        id: "2",
        type: "Sécheresse",
        date: DateTime(2025, 10, 25),
        region: "Centre-Nord, Sanmatenga, Korsimoro",
        affectedPeople: 1200,
        status: "Évaluée",
        icon: "sun",
      ),
      AlertModel(
        id: "3",
        type: "Attaque terroriste",
        date: DateTime(2025, 10, 27),
        region: "Nord, Yatenga, Ouahigouya",
        affectedPeople: 95,
        status: "Transmise",
        icon: "warning",
      ),
    ];
  }
}
*/