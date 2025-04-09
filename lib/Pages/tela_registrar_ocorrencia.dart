import 'package:crud/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// Importar 'dart:io' se precisar trabalhar com o File em alguma parte do código
// import 'dart:io';

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

  // Lista para armazenar os anexos selecionados
  List<PlatformFile> _anexos = [];

  // Tamanho máximo dos arquivos em bytes (ex: 5 MB)
  static const int maxFileSize = 5 * 1024 * 1024;

  // Função para selecionar arquivos (vídeo, foto e áudio)
  Future<void> _pickAnexos() async {
    // Permite selecionar múltiplos arquivos dos tipos especificados.
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi', 'mp3', 'wav'],
    );

    if (result != null) {
      // Se houver arquivos, valida o tamanho de cada um e adiciona à lista.
      List<PlatformFile> arquivosValidados = [];
      for (var file in result.files) {
        if (file.size > maxFileSize) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('O arquivo ${file.name} excede o tamanho permitido (5 MB).'),
            ),
          );
        } else {
          arquivosValidados.add(file);
        }
      }
      setState(() {
        _anexos = arquivosValidados;
      });
    }
  }

  // Função para registrar a ocorrência
  void _registrarOcorrencia() async {
    // Validação dos dropdowns
    if (_tipoOcorrenciaSelecionado == null || _gravidadeSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selecione um tipo de ocorrência e gravidade')));
      return;
    }

    // Recuperar e validar os textos de relato e socorro
    String relato = _relatoController.text.trim();
    String textoSocorro = _textoSocorroController.text.trim();

    if (relato.isEmpty || textoSocorro.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    // Validação do comprimento do relato
    if (relato.length < 6 || relato.length > 255) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('O relato deve conter entre 6 e 255 caracteres')),
      );
      return;
    }

    // Converter o relato para letras minúsculas
    relato = relato.toLowerCase();

    // Se desejar, você pode também validar os anexos aqui (embora a validação já ocorra no pick)
    for (var file in _anexos) {
      if (file.size > maxFileSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('O arquivo ${file.name} excede o tamanho permitido')),
        );
        return;
      }
    }

    try {
      // Ajuste a função addOcorrencia no seu FirestoreService para receber os anexos
      await firestoreService.addOcorrencia(
        _tipoOcorrenciaSelecionado!,
        _gravidadeSelecionada!,
        relato,
        textoSocorro,
        _enviarParaGuardiao,
        anexos: _anexos, // novo parâmetro para anexos
      );

      // Limpar campos e anexos após sucesso
      _relatoController.clear();
      _textoSocorroController.clear();
      setState(() {
        _tipoOcorrenciaSelecionado = null;
        _gravidadeSelecionada = null;
        _enviarParaGuardiao = false;
        _anexos = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorrência registrada com sucesso')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar ocorrência: $e')));
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
        child: SingleChildScrollView( // Adicionado para evitar overflow caso haja muitos anexos
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
                    return Text(
                      'Nenhum tipo de ocorrência encontrado. Por favor, entre em contato com o administrador do sistema para informar este problema.',
                      style: TextStyle(color: Colors.red),
                    );
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
              // Campo de texto para o relato
              TextFormField(
                controller: _relatoController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Relato',
                  hintText: 'Digite o seu relato aqui (6 a 255 caracteres)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.red[50],
                  suffixIcon: IconButton(icon: Icon(Icons.attach_file),
                  onPressed: _pickAnexos,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Campo de texto para a mensagem de socorro
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
              // Botão para anexar arquivos
              SizedBox(height: 8),
              // Exibir os anexos selecionados
              _anexos.isNotEmpty
                  ? Wrap(
                      spacing: 8.0,
                      children: _anexos.map((file) => Chip(label: Text(file.name))).toList(),
                    )
                  : Container(),
              SizedBox(height: 16),
              // Botões de ação
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
      ),
    );
  }
}
