import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference tipoOcorrencia =
      FirebaseFirestore.instance.collection('tipoOcorrencia');

  final CollectionReference usuario =
      FirebaseFirestore.instance.collection("usuario");

  final CollectionReference gravidade =
      FirebaseFirestore.instance.collection('gravidade');

  /////////////////////////////////////////////////////////////////////
  // CRUD de Tipo de Ocorrência
  /////////////////////////////////////////////////////////////////////

  Future<void> addTipoOcorrencia(String tipoOcorrenciaText) async {
    String tipoOcorrenciaFormatado = tipoOcorrenciaText.trim().toLowerCase();

    if (tipoOcorrenciaFormatado.length < 3 ||
        tipoOcorrenciaFormatado.length > 100) {
      throw Exception(
          "O tipo de ocorrência deve ter entre 3 e 100 caracteres.");
    }

    QuerySnapshot duplicado = await tipoOcorrencia
        .where('tipoOcorrencia', isEqualTo: tipoOcorrenciaFormatado)
        .get();

    if (duplicado.docs.isNotEmpty) {
      throw Exception("Este tipo de ocorrência já existe.");
    }

    await tipoOcorrencia.add({
      'tipoOcorrencia': tipoOcorrenciaFormatado,
      'timestamp': Timestamp.now(),
      'inativar': false,
    });
  }

  Stream<QuerySnapshot> gettipoOcorrenciaStream() {
    return tipoOcorrencia
        .where('inativar', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> atualizarTipoOcorrencia(String docID, String novoTipo) async {
    String tipoFormatado = novoTipo.trim().toLowerCase();

    if (tipoFormatado.isEmpty || tipoFormatado.length < 3) {
      throw Exception("O tipo de ocorrência deve ter no mínimo 3 caracteres.");
    }

    await tipoOcorrencia.doc(docID).update({
      'tipoOcorrencia': tipoFormatado,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> inativarTipoOcorrencia(String docID) {
    return tipoOcorrencia.doc(docID).update({
      'timestamp': Timestamp.now(),
      'inativar': true,
    });
  }

  /////////////////////////////////////////////////////////////////////
  // CRUD de Gravidade
  /////////////////////////////////////////////////////////////////////

  Future<void> addgravidade(String gravidadeText) async {
    String gravidadeFormatado = gravidadeText.trim().toLowerCase();

    if (gravidadeFormatado.length < 3 || gravidadeFormatado.length > 100) {
      throw Exception("A gravidade deve ter entre 3 e 100 caracteres.");
    }

    QuerySnapshot duplicado = await gravidade
        .where('gravidade', isEqualTo: gravidadeFormatado)
        .get();

    if (duplicado.docs.isNotEmpty) {
      throw Exception("Esta gravidade já existe.");
    }

    await gravidade.add({
      'gravidade': gravidadeFormatado,
      'timestamp': Timestamp.now(),
      'inativar': false,
    });
  }

  Stream<QuerySnapshot> getgravidadeStream() {
    return gravidade
        .where('inativar', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> atualizargravidade(String docID, String novagravidade) async {
    String gravidadeFormatado = novagravidade.trim().toLowerCase();

    if (gravidadeFormatado.length < 3 || gravidadeFormatado.length > 100) {
      throw Exception(
          "A gravidade deve ter no mínimo 3 e no máximo 100 caracteres.");
    }

    await gravidade.doc(docID).update({
      'gravidade': gravidadeFormatado,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> inativargravidade(String docID) {
    return gravidade.doc(docID).update({
      'timestamp': Timestamp.now(),
      'inativar': true,
    });
  }

  /////////////////////////////////////////////////////////////////////
  // CRUD de Usuário (Integração com Firebase Authentication)
  /////////////////////////////////////////////////////////////////////

  // CREATE: Cria ou atualiza os dados do usuário usando o UID gerado pelo Firebase Auth
  Future<void> addUsuario(String uid, Map<String, dynamic> dadosUsuario) async {
    await usuario.doc(uid).set({
      'nome': dadosUsuario['nome'],
      'email': dadosUsuario['email'],
      'cpf': dadosUsuario['cpf'],
      'numerotelefone': dadosUsuario['numerotelefone'],
      'dataNasc': dadosUsuario['dataNasc'],
      'sexo': dadosUsuario['sexo'],
      'inativar': false,
      'timestamp': Timestamp.now(),
    });
  }

  // READ: Retorna um stream dos usuários ativos
  Stream<QuerySnapshot> getUsuarioStream() {
    return usuario
        .where('inativar', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // UPDATE: Atualiza os dados do usuário
  Future<void> atualizarUsuario(
      String uid, Map<String, dynamic> dadosUsuario) async {
    dadosUsuario['timestamp'] = Timestamp.now();
    return await usuario.doc(uid).update(dadosUsuario);
  }

  // INATIVAR: Inativa o usuário (ao invés de deletar)
  Future<void> inativarUsuario(String uid) {
    return usuario.doc(uid).update({
      'timestamp': Timestamp.now(),
      'inativar': true,
    });
  }
}
