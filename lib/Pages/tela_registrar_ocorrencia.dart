import 'package:crud/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OcorrenciaPage extends StatefulWidget {
  @override
  _OcorrenciaPageState createState() => _OcorrenciaPageState();
}

class _OcorrenciaPageState extends State<OcorrenciaPage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _relatoController = TextEditingController();
  final TextEditingController _textoSocorroController = TextEditingController();
  bool _enviarParaGuardiao = false;
  String? _tipoOcorrenciaSelecionado;
  String? _gravidadeSelecionada;

  // Função para registrar a ocorrência
  void _registrarOcorrencia() async {
    if (_tipoOcorrenciaSelecionado == null || _gravidadeSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecione um tipo de ocorrência e gravidade')));
      return;
    }

    String relato = _relatoController.text.trim();
    String textoSocorro = _textoSocorroController.text.trim();

    if (relato.isEmpty || textoSocorro.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    try {
      await firestoreService.addOcorrencia(
        _tipoOcorrenciaSelecionado!,
        _gravidadeSelecionada!,
        relato,
        textoSocorro,
        _enviarParaGuardiao,
      );

      // Limpar campos após sucesso
      _relatoController.clear();
      _textoSocorroController.clear();
      setState(() {
        _tipoOcorrenciaSelecionado = null;
        _gravidadeSelecionada = null;
        _enviarParaGuardiao = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ocorrência registrada com sucesso')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao registrar ocorrência: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar ocorrência'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown para selecionar o tipo de ocorrência
            StreamBuilder<QuerySnapshot>(
              stream: firestoreService.gettipoOcorrenciaStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('Nenhum tipo de ocorrência encontrado.');
                }

                List<String> tiposOcorrencia = snapshot.data!.docs.map((doc) {
                  return doc['tipoOcorrencia'] as String;
                }).toList();

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Selecione o tipo de ocorrência',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _tipoOcorrenciaSelecionado = value;
                    });
                  },
                  value: _tipoOcorrenciaSelecionado,
                  items: tiposOcorrencia.map((tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 16),
            // Dropdown para selecionar a gravidade
            StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getgravidadeStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('Nenhuma gravidade encontrada.');
                }

                // Filtrando gravidade gravissíma no lado do cliente
                List<String> gravidades = snapshot.data!.docs.map((doc) {
                  return doc['gravidade'] as String;
                }).toList();

                // Filtrando 'gravissíma'
                gravidades.removeWhere((gravidade) => gravidade == 'gravissíma');

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Selecione a gravidade',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _gravidadeSelecionada = value;
                    });
                  },
                  value: _gravidadeSelecionada,
                  items: gravidades.map((gravidade) {
                    return DropdownMenuItem<String>(
                      value: gravidade,
                      child: Text(gravidade),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _relatoController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Relato',
                hintText: 'Digite o seu relato aqui',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.red[50],
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _textoSocorroController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Texto Socorro',
                hintText: 'Digite a mensagem de socorro aqui',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.red[50],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _enviarParaGuardiao,
                  onChanged: (bool? value) {
                    setState(() {
                      _enviarParaGuardiao = value!;
                    });
                  },
                ),
                Text('Mandar texto socorro para guardião'),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _registrarOcorrencia,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: Text('Registrar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Lógica para enviar S.O.S
                    print('S.O.S Enviado');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: Text('S.O.S'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
