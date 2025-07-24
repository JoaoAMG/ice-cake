
class EnderecoModel {
  final int? id;
  final int usuario_id;
  final String rua;
  final String numero;
  final String bairro;
  final String cidade;
  final String cep;
  final String estado;        
  final String? complemento;  

  EnderecoModel({
    this.id,
    required this.usuario_id,
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.cep,
    required this.estado,      
    this.complemento,     
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'usuario_id': usuario_id, 'rua': rua, 'numero': numero,
      'bairro': bairro, 'cidade': cidade, 'cep': cep,
      'estado': estado,              
      'complemento': complemento,  
    };
  }

  factory EnderecoModel.fromMap(Map<String, dynamic> map) {
    return EnderecoModel(
      id: map['id'], usuario_id: map['usuario_id'], rua: map['rua'],
      numero: map['numero'], bairro: map['bairro'], cidade: map['cidade'],
      cep: map['cep'],
      estado: map['estado'],            
      complemento: map['complemento'],  
    );
  }
}