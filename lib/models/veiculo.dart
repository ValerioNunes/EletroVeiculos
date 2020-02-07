import 'package:intl/intl.dart';
import 'local.dart';
import 'nota.dart';

class Veiculo{
  String uid = "";
  String placa  = "";

  String sede_titular  = "";

  Local local_atual  =  Local();

  String tipo  = "";
  String modelo  = "";
  String ano  = "";
  String patrimonio   = "";
  String renavan  = "";
  String chassi  = "";
  String codigo_sap   = "";
  String capacidade_carga  = "";
  String contagem  = "";

  String venc_licenciamento  = "";
  String validade_bengala  = "";

  String km_atual  = "";
  String km_ultima_revisao  = "";
  String km_proxima_revisao  = "";
  String data_ultima_revisao  = "";

  String ultimo_teste_fumaca  = "";
  String validade_teste_fumaca  = "";
  String ultima_afericao  = "";
  String validade_afericao  = "";
  String imagem = "https://firebasestorage.googleapis.com/v0/b/eletroinovacao-c2e33.appspot.com/o/tipo_veiculo%2FHILUX%20SOCAGE.png?alt=media&token=2311a3ce-d3ca-4218-a5c2-cd1b24dd2b9d";

  List<dynamic> notas = [];

  Veiculo();

  String getImage(){
    if(tipo.toUpperCase() == "HILUX SOCAGE")
      return "https://firebasestorage.googleapis.com/v0/b/eletroinovacao-c2e33.appspot.com/o/tipo_veiculo%2FHILUX%20SOCAGE.png?alt=media&token=2311a3ce-d3ca-4218-a5c2-cd1b24dd2b9d";
    if(tipo.toUpperCase()  == "MUNCK")
      return "https://firebasestorage.googleapis.com/v0/b/eletroinovacao-c2e33.appspot.com/o/tipo_veiculo%2FMUNCK.png?alt=media&token=f1ced049-e4ea-4653-8c0d-9518964859d3";
    if(tipo.toUpperCase()  == "MUNCK")
      return "https://firebasestorage.googleapis.com/v0/b/eletroinovacao-c2e33.appspot.com/o/tipo_veiculo%2FSKY%20MUNCK.png?alt=media&token=d519bf5d-c329-4e7d-9609-b5555974d1ef";
  }

  String getImageLocal(){
      return "img/"+tipo+".png";
  }

  DateTime get_validade_bengala(){
   return  stringToDatetime(validade_bengala);
  }
  DateTime get_validade_teste_fumaca(){
    return  stringToDatetime(validade_teste_fumaca);
  }
  DateTime get_validade_afericao(){
    return  stringToDatetime(validade_afericao);
  }
  DateTime get_venc_licenciamento(){
    return  stringToDatetime(venc_licenciamento);
  }
  bool get_revisao(){
    int lv_km_atual , lv_km_proxima_revisao;
    try {
      lv_km_atual = int.parse(km_atual);
      lv_km_proxima_revisao = int.parse(km_proxima_revisao.replaceAll(".",""));
      return (lv_km_atual < lv_km_proxima_revisao);
    }catch(e){
      print(e);
    }
    return false;
  }
  bool statusValidade(DateTime d){
    return d.isAfter(DateTime.now());
  }


  String getPendencia(){
    List<String> pendencia =  statusVeiculo();
    String msg = "";
    pendencia.forEach((f){
      msg = msg + "\n" + f;
    });
    return msg;
  }

  List<String>  statusVeiculo(){

    List<String> status =  new List<String>();

    if(!get_revisao())
      status.add('Revisão');

    if(get_validade_bengala() != null){
      if(!statusValidade(get_validade_bengala()))
        status.add('Validade Bengala');
      }

    if(get_validade_teste_fumaca() != null){
      if(!statusValidade(get_validade_teste_fumaca()))
    status.add('Validade Teste Fumaça');
    }

    if(get_validade_afericao() != null){
      if(!statusValidade(get_validade_afericao()))
    status.add('Validade Aferição');
    }

    if(get_venc_licenciamento() != null){
      if(!statusValidade(get_venc_licenciamento()))
    status.add('Vencimento do Licenciamento');
    }

    return status;
  }


  DateTime stringToDatetime(String d){
    try {
      return DateTime.parse(d);
    }catch(e){
      print(e);
      return null;
    }
  }

  static Local getLocalizacao(snapshot){
    try{
      return Local.fromSnapshot(snapshot);
    }catch (e){
      return new Local();
    }
  }

  Veiculo.fromSnapshot(snapshot):
        uid = snapshot.documentID,
        placa = snapshot["placa"],
        sede_titular = snapshot["sede_titular"],
        local_atual = getLocalizacao(snapshot["local_atual"]),
        tipo = snapshot["tipo"],
        modelo = snapshot["modelo"],
        ano = snapshot["ano"].toString() ?? "xxxx",
        patrimonio  = snapshot["patrimonio"],
        renavan = snapshot["renavan"].toString() ?? "xxxx",
        chassi = snapshot["chassi"].toString() ?? "xxxx",
        codigo_sap  = snapshot["codigo_sap"].toString() ?? "xxxx",
        capacidade_carga = snapshot["capacidade_carga"].toString() ?? "xxxx",
        contagem = snapshot["contagem"].toString() ?? "xxxx",
        venc_licenciamento = snapshot["venc_licenciamento"],
        validade_bengala = snapshot["validade_bengala"],
        km_atual = snapshot["km_atual"].toString() ?? "xxxx",
        km_ultima_revisao = snapshot["km_ultima_revisao"].toString() ?? "xxxx",
        data_ultima_revisao = snapshot["data_ultima_revisao"],
        km_proxima_revisao = snapshot["km_proxima_revisao"].toString() ?? "xxxx",
        ultimo_teste_fumaca = snapshot["ultimo_teste_fumaca"],
        validade_teste_fumaca = snapshot["validade_teste_fumaca"],
        ultima_afericao = snapshot["ultima_afericao"],
        notas = snapshot["notas"] ?? [],
        validade_afericao = snapshot["validade_afericao"];

  Veiculo.fromSnapshot2(snapshot):
        uid = snapshot.documentID,
        placa = snapshot.data["placa"],
        sede_titular = snapshot.data["sede_titular"],
        local_atual = getLocalizacao(snapshot.data["local_atual"]),
        tipo = snapshot.data["tipo"],
        modelo = snapshot.data["modelo"],
        ano = snapshot.data["ano"].toString() ?? "xxxx",
        patrimonio  = snapshot.data["patrimonio"] ?? "xxxx",
        renavan = snapshot.data["renavan"].toString() ?? "xxxx",
        chassi = snapshot.data["chassi"].toString() ?? "xxxx",
        codigo_sap  = snapshot.data["codigo_sap"].toString() ?? "xxxx",
        capacidade_carga = snapshot.data["capacidade_carga"].toString() ?? "xxxx",
        contagem = snapshot.data["contagem"].toString() ?? "xxxx",
        venc_licenciamento = snapshot.data["venc_licenciamento"],
        validade_bengala = snapshot.data["validade_bengala"],
        km_atual = snapshot.data["km_atual"].toString() ?? "xxxx",
        km_ultima_revisao = snapshot.data["km_ultima_revisao"].toString() ?? "xxxx",
        data_ultima_revisao = snapshot.data["data_ultima_revisao"],
        km_proxima_revisao = snapshot.data["km_proxima_revisao"].toString() ?? "xxxx",
        ultimo_teste_fumaca = snapshot.data["ultimo_teste_fumaca"],
        validade_teste_fumaca = snapshot.data["validade_teste_fumaca"],
        ultima_afericao = snapshot.data["ultima_afericao"],
        notas = snapshot.data["notas"] ?? [],
        validade_afericao = snapshot.data["validade_afericao"];

   toJson() {
    return {
      "notas" : notas,
      "placa" : placa,
      "sede_titular" : sede_titular,
      "local_atual" : local_atual.toJson(),
      "tipo" : tipo,
      "modelo" : modelo,
      "ano" : ano,
      "patrimonio" : patrimonio ,
      "renavan" : renavan,
      "chassi" : chassi,
      "codigo_sap" : codigo_sap ,
      "capacidade_carga" : capacidade_carga,
      "contagem" : contagem,
      "venc_licenciamento" : venc_licenciamento,
      "validade_bengala" : validade_bengala,
      "km_atual" : km_atual,
      "km_ultima_revisao" : km_ultima_revisao,
      "data_ultima_revisao" : data_ultima_revisao,
      "km_proxima_revisao" : km_proxima_revisao,
      "ultimo_teste_fumaca" : ultimo_teste_fumaca,
      "validade_teste_fumaca" : validade_teste_fumaca,
      "ultima_afericao" : ultima_afericao,
      "validade_afericao" : validade_afericao,

    };
  }
}