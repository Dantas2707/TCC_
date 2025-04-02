import 'package:flutter/material.dart';

class OcorrenciaPage extends StatefulWidget {
  @override
  _OcorrenciaPageState createState() => _OcorrenciaPageState();
}

class _OcorrenciaPageState extends State<OcorrenciaPage> {
  final TextEditingController _relatoController = TextEditingController();
  final TextEditingController _textoSocorroController = TextEditingController();
  bool _enviarParaGuardiao = false;

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
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Selecione o tipo de ocorrência',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {},
              items: ['Assédio', 'Violência', 'Outro'].map((e) {
                return DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
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
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: Text('Registrar'),
                ),
                ElevatedButton(
                  onPressed: () {},
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
