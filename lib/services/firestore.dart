import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final CollectionReference tipoOcorrencia =
      FirebaseFirestore.instance.collection('tipoOcorrencia');

  final CollectionReference usuario =
      FirebaseFirestore.instance.collection("usuario");

  final CollectionReference gravidade =
      FirebaseFirestore.instance.collection('gravidade');

  final CollectionReference ocorrencias =
      FirebaseFirestore.instance.collection('ocorrencias'); // Coleção para as ocorrências

  final CollectionReference guardioes =
      FirebaseFirestore.instance.collection("guardiões"); // Coleção de guardiões

  // Função para enviar convite para o guardião por e-mail
  Future<void> convidarGuardiaoPorEmail(String email, String idUsuario) async {
    try {
      // Verifica se o e-mail corresponde a um usuário registrado
      QuerySnapshot userSnapshot = await usuario
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // O usuário com esse e-mail existe
        String idGuardiao = userSnapshot.docs.first.id;

        // Verifica se já existe a relação de guardião
        QuerySnapshot duplicado = await guardioes
            .where('id_usuario', isEqualTo: idUsuario)
            .where('id_guardiao', isEqualTo: idGuardiao)
            .get();

        if (duplicado.docs.isNotEmpty) {
          throw Exception("Esta relação de guardião já existe.");
        }

        // Cria um convite para o guardião aceitar
        await guardioes.add({
          'id_usuario': idUsuario,  // ID do usuário que está sendo guardiado
          'id_guardiao': idGuardiao,  // ID do guardião
          'invitado': true,  // Marca o guardião como convidado
          'timestamp': Timestamp.now(),
          'status': 'pendente',  // Status do convite: pendente
        });

        // Enviar um e-mail de convite para o guardião (aqui você pode enviar um e-mail via seu backend ou Firebase Functions)
        // Exemplo:
        // await sendEmailToGuardiao(email, idUsuario);
        print("Convite enviado para o e-mail: $email");

        // Exibe uma mensagem de sucesso
        print("Convite enviado com sucesso!");
      } else {
        // O e-mail não está registrado
        print("Usuário não encontrado. Enviando convite para baixar o app.");

        // Aqui você pode enviar um e-mail com o convite para baixar o app
        // Exemplo: enviar um e-mail para o guardião com um link de download
        // await sendInvitationToDownloadApp(email);
      }
    } catch (e) {
      print("Erro ao convidar guardião: $e");
    }
  }

  // Função para adicionar um guardião à relação
  Future<void> adicionarGuardiao(String idUsuario, String idGuardiao) async {
    try {
      // Verifica se já existe a relação de guardião
      QuerySnapshot duplicado = await guardioes
          .where('id_usuario', isEqualTo: idUsuario)
          .where('id_guardiao', isEqualTo: idGuardiao)
          .get();

      if (duplicado.docs.isNotEmpty) {
        throw Exception("Esta relação de guardião já existe.");
      }

      // Cria um novo documento na coleção guardiões
      await guardioes.add({
        'id_usuario': idUsuario,  // ID do usuário que está sendo guardiado
        'id_guardiao': idGuardiao,  // ID do guardião
        'inativado': false,  // Relacionamento ativo inicialmente
        'timestamp': Timestamp.now(),
      });

      // Atualiza o usuário para marcar que ele é um guardião
      await usuario.doc(idGuardiao).update({
        'guardiao': true,  // Marca o usuário como guardião
      });

      // Atualiza o usuário para adicionar o guardião à lista de guardiões
      await usuario.doc(idUsuario).update({
        'guardioes': FieldValue.arrayUnion([idGuardiao]),  // Adiciona o guardião à lista de guardiões
      });
    } catch (e) {
      throw Exception("Erro ao adicionar guardião: $e");
    }
  }

  // Método para inativar um guardião (alterando a flag 'inativado' para true)
  Future<void> inativarGuardiao(String idUsuario, String idGuardiao) async {
    try {
      // Busca a relação de guardião para o usuário especificado
      QuerySnapshot querySnapshot = await guardioes
          .where('id_usuario', isEqualTo: idUsuario)
          .where('id_guardiao', isEqualTo: idGuardiao)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Relação de guardião não encontrada.");
      }

      // Atualiza o documento para marcar a relação como inativada
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          'inativado': true,
          'timestamp': Timestamp.now(),
        });
      }

      // Atualiza o usuário para remover o guardião da lista de guardiões
      await usuario.doc(idUsuario).update({
        'guardioes': FieldValue.arrayRemove([idGuardiao]),
      });

      // Atualiza o guardião para desmarcar como guardião
      await usuario.doc(idGuardiao).update({
        'guardiao': false,
      });
    } catch (e) {
      throw Exception("Erro ao inativar guardião: $e");
    }
  }

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
        .where('inativar', isEqualTo: false) // Filtrando as gravidades ativas
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

  Stream<QuerySnapshot> getUsuarioStream() {
    return usuario
        .where('inativar', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> atualizarUsuario(
      String uid, Map<String, dynamic> dadosUsuario) async {
    dadosUsuario['timestamp'] = Timestamp.now();
    return await usuario.doc(uid).update(dadosUsuario);
  }

  Future<void> inativarUsuario(String uid) {
    return usuario.doc(uid).update({
      'timestamp': Timestamp.now(),
      'inativar': true,
    });
  }

  /////////////////////////////////////////////////////////////////////
  // CRUD de Ocorrências
  /////////////////////////////////////////////////////////////////////

  Future<void> addOcorrencia(
      String tipoOcorrencia,
      String gravidade,
      String relato,
      String textoSocorro,
      bool enviarParaGuardiao) async {
    await ocorrencias.add({
      'tipoOcorrencia': tipoOcorrencia,
      'gravidade': gravidade,  // Incluído o campo gravidade
      'relato': relato,
      'textoSocorro': textoSocorro,
      'enviarParaGuardiao': enviarParaGuardiao,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getOcorrenciasStream() {
    return ocorrencias
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
