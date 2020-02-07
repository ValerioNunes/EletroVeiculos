import 'package:intl/intl.dart';
class Usuario{
  String nome = "";
  String sobrenome = "";
  String matricula = "";
  String telefonePessoal = "";
  String cpf = "";
  String uid = "";
  String email = "";
  String senha = "";
  int nivel = 0;

  Usuario();
  Usuario.fromSnapshot(snapshot):
        nome = snapshot["nome"],
        cpf = snapshot["cpf"],
        matricula = snapshot["matricula"],
        sobrenome = snapshot["sobrenome"],
        telefonePessoal = snapshot["telefonePessoal"],
        email = snapshot["email"],
        nivel = snapshot["nivel"],
        uid = snapshot["uid"];

  toJson() {
    return {
      "nome":nome,
      "cpf":cpf,
      "uid":uid,
      "matricula":matricula,
      "nivel" : nivel,
      "sobrenome":sobrenome,
      "telefonePessoal":telefonePessoal,
      "email":email,
    };
  }
}