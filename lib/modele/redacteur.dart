class Redacteur {
  final int? id;
  final String nom;
  final String prenom;
  final String email;

  Redacteur({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  Redacteur copyWith({int? id, String? nom, String? prenom, String? email}) {
    return Redacteur(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
    );
  }

  factory Redacteur.fromMap(Map<String, dynamic> m) => Redacteur(
    id: m['id'] as int?,
    nom: m['nom'] as String,
    prenom: m['prenom'] as String,
    email: m['email'] as String,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'email': email,
  };
}
