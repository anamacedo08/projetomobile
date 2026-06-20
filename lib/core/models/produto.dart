class Produto {
  final String id;
  final String nome;
  final String descricao;
  final String imagemUrl;
  final double preco;

  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.imagemUrl,
    required this.preco,
  });

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      imagemUrl: map['imagem_url'],
      preco: (map['preco'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'imagem_url': imagemUrl,
      'preco': preco,
    };
  }
}
