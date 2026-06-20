class Usuario {
  final String id;
  final String nome;
  final String email;
  final String senhaHash;
  final String perfil;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senhaHash,
    required this.perfil,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      senhaHash: map['senha_hash'],
      perfil: map['perfil'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha_hash': senhaHash,
      'perfil': perfil,
    };
  }

  // Helper method to match the pseudocode "Usuario.mapearDeObjeto"
  static Usuario mapearDeObjeto(Map<String, dynamic> objeto) {
    return Usuario.fromMap(objeto);
  }
}
