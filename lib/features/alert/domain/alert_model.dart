

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
library;


class AlertModel {
  // ============================
  // Étape 1 : Localisation
  // ============================
  String? region;
  String? province;
  String? commune;
  String? zone;
  String? coordonnees;
  String? village;
  String? date;
  String? time;
/////////////
  String? event;
  String? eventType;
  String? urgentNeeds;
  String? localisatione1;
  int? zoneId;


  // ============================
  // Étape 2 : Événement
  // ============================
  String? typeEvenement;
  List<String>? facteursDeclencheurs;
  double? ampleur;
  String? periode;
  String? dureeEstimee;
  String? description;

  // ============================
  // Étape 3 : Conséquences
  // ============================
  List<String>? consequencesObservees;
  int? nbPersonnesAffectees;
  int? nbPersonnesDeplacees;
  int? nbDeces;
  int? nbBlesses;
  String? infrastructuresTouchees;
  String? besoinsUrgents;
  double? impactEconomique; 
  // ✅ Nouvel attribut pour stocker les chemins des photos
  List<String>? photos;

  // ============================
  // Étape 4 : Rapporteur
  // ============================
  String? rapporteurNom;
  String? rapporteurPrenom;
  String? rapporteurTelephone;
  String? rapporteurEmail;
  String? fonction;
  String? structure;
  String? languePreferee;

  // ============================
  // Étape 5 : Destinataires
  // ============================

  // Groupes sélectionnés (checkbox)
  Map<String, bool>? groupesDestinataires = {
    "Structures partenaires": false,
    "Autorités locales": false,
    "Équipes d’intervention": false,
  };

  // Canaux de communication (SMS / Email / Push)
  bool sendSMS = false;
  bool sendEmail = false;
  bool sendPush = false;
  int? nbStructures;
  int? nbAutorites;
  int? nbEquipes;
  // Destinataire personnalisé
  String? contactNom;
  String? contactTelephone;
  String? contactEmail;

  // Messages personnalisés
  String? smsMessage;
  String? emailMessage;
  final String? evenement; // Type d’événement (inondation, attaque, accident, etc.)
  final String? localisation;
  int? totalDestinataires;


  

  // ============================
  // Métadonnées système
  // ============================
  String? id;
  DateTime? dateCreation;
  String? statut;
  String? source;

  AlertModel({
    // Étape 1
    this.region,
    this.province,
    this.commune,
    this.zone,
    this.coordonnees,
    this.date,
    this.time,
    this.village,
    ////////
    this.event,
    this.eventType,
    this.urgentNeeds,
    this.localisatione1,
    this.zoneId,

    // Étape 2
    this.typeEvenement,
    this.facteursDeclencheurs,
    this.ampleur,
    this.periode,
    this.dureeEstimee,
    this.description,

    // Étape 3
    this.consequencesObservees,
    this.nbPersonnesAffectees,
    this.nbPersonnesDeplacees,
    this.nbDeces,
    this.nbBlesses,
    this.infrastructuresTouchees,
    this.besoinsUrgents,
    this.impactEconomique, 
    this.photos,

    // Étape 4
    this.rapporteurNom,
    this.rapporteurPrenom,
    this.rapporteurTelephone,
    this.rapporteurEmail,
    this.fonction,
    this.structure,
    this.languePreferee,

    // Étape 5
    

    this.groupesDestinataires,
    this.sendSMS = false,
    this.sendEmail = false,
    this.sendPush = false,
    this.contactNom,
    this.contactTelephone,
    this.contactEmail,
    this.smsMessage,
    this.emailMessage,
    this.evenement,
    this.localisation,
    this.nbAutorites,
    this.nbEquipes,
    this.nbStructures,

    


    // Métadonnées
    this.id,
    this.dateCreation,
    this.statut,
    this.source,
  });
  
  // Add the toJson method
  Map<String, dynamic> toJson() {
    return {
      // Replace with your actual properties
      'region': region,
      'province': province,
      'commune': commune,
      'zone': zone,
      'coordonnees': coordonnees,
      'village': village,
      'date': date,
      'time': time,
      'typeEvenement': typeEvenement,
      'facteursDeclencheurs': facteursDeclencheurs,
      'ampleur': ampleur,
      'periode': periode,
      'dureeEstimee': dureeEstimee,
      'description': description,
      'consequencesObservees': consequencesObservees,
      'nbPersonnesAffectees': nbPersonnesAffectees,
      'nbPersonnesDeplacees': nbPersonnesDeplacees,
      'nbDeces': nbDeces,
      'nbBlesses': nbBlesses,
      'infrastructuresTouchees': infrastructuresTouchees,
      'besoinsUrgents': besoinsUrgents,
      'impactEconomique': impactEconomique,
      'photos': photos,
      'rapporteurNom': rapporteurNom,
      'rapporteurPrenom': rapporteurPrenom,
      'rapporteurTelephone': rapporteurTelephone,
      'rapporteurEmail': rapporteurEmail,
      'fonction': fonction,
      'structure': structure,
      'languePreferee': languePreferee,
      'groupesDestinataires': groupesDestinataires,
      'sendSMS': sendSMS,
      'sendEmail': sendEmail,
      'sendPush': sendPush,
      'contactNom': contactNom,
      'contactTelephone': contactTelephone,
      'contactEmail': contactEmail,
      'smsMessage': smsMessage,
      'emailMessage': emailMessage,
      'evenement': evenement,
      'localisation': localisation,
      'totalDestinataires': totalDestinataires,
      'id': id,
      'dateCreation': dateCreation?.toIso8601String(),
      'statut': statut,
      'source': source,


      ///////etape1
      "event": event,
      "eventType": eventType,
      "urgentNeeds": urgentNeeds,
      "localisatione1": localisatione1,
      "zoneId": zoneId,
    };
  }
  
  // ============================
  // Méthodes utilitaires
  // ============================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'region': region,
      'province': province,
      'commune': commune,
      'zone': zone,
      'coordonnees': coordonnees,
      'typeEvenement': typeEvenement,
      'facteursDeclencheurs': facteursDeclencheurs,
      'ampleur': ampleur,
      'periode': periode,
      'dureeEstimee': dureeEstimee,
      'description': description,
      'consequencesObservees': consequencesObservees,
      'nbPersonnesAffectees': nbPersonnesAffectees,
      'nbPersonnesDeplacees': nbPersonnesDeplacees,
      'nbDeces': nbDeces,
      'nbBlesses': nbBlesses,
      'infrastructuresTouchees': infrastructuresTouchees,
      'besoinsUrgents': besoinsUrgents,
      'impactEconomique': impactEconomique, // ⚠ ajouté ici
      'rapporteurNom': rapporteurNom,  
      'rapporteurPrenom': rapporteurPrenom,
      'rapporteurTelephone': rapporteurTelephone,
      'rapporteurEmail': rapporteurEmail,
      'fonction': fonction,
      'structure': structure,
      'languePreferee': languePreferee,
      'groupesDestinataires': groupesDestinataires,
      'sendSMS': sendSMS,
      'sendEmail': sendEmail,
      'sendPush': sendPush,
      'contactNom': contactNom,
      'contactTelephone': contactTelephone,
      'contactEmail': contactEmail,
      'smsMessage': smsMessage,
      'emailMessage': emailMessage,
      'dateCreation': dateCreation?.toIso8601String(),
      'statut': statut,
      'source': source,
      'evenement': evenement,
      'localisation': localisation,

    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      id: map['id'],
      region: map['region'],
      province: map['province'],
      commune: map['commune'],
      zone: map['zone'],
      coordonnees: map['coordonnees'],
      typeEvenement: map['typeEvenement'],
      facteursDeclencheurs: List<String>.from(map['facteursDeclencheurs'] ?? []),
      ampleur: (map['ampleur'] ?? 0).toDouble(),
      periode: map['periode'],
      dureeEstimee: map['dureeEstimee'],
      description: map['description'],
      consequencesObservees: List<String>.from(map['consequencesObservees'] ?? []),
      nbPersonnesAffectees: map['nbPersonnesAffectees'],
      nbPersonnesDeplacees: map['nbPersonnesDeplacees'],
      nbDeces: map['nbDeces'],
      nbBlesses: map['nbBlesses'],
      infrastructuresTouchees: map['infrastructuresTouchees'],
      besoinsUrgents: map['besoinsUrgents'],
      impactEconomique: (map['impactEconomique'] ?? 0).toDouble(), // ⚠ ajouté ici
      rapporteurNom: map['rapporteurNom'],
      rapporteurPrenom: map['rapporteurPrenom'],
      rapporteurTelephone: map['rapporteurTelephone'],
      rapporteurEmail: map['rapporteurEmail'],
      fonction: map['fonction'],
      structure: map['structure'],
      languePreferee: map['languePreferee'],
     groupesDestinataires: Map<String, bool>.from(map['groupesDestinataires'] ?? {}),
      sendSMS: map['sendSMS'] ?? false,
      sendEmail: map['sendEmail'] ?? false,
      sendPush: map['sendPush'] ?? false,
      contactNom: map['contactNom'],
      contactTelephone: map['contactTelephone'],
      contactEmail: map['contactEmail'],
      smsMessage: map['smsMessage'],
      emailMessage: map['emailMessage'],
      localisation: map['localisation'],

      
      dateCreation: map['dateCreation'] != null
          ? DateTime.parse(map['dateCreation'])
          : null,
      statut: map['statut'],
      source: map['source'],
    );
  }
}

