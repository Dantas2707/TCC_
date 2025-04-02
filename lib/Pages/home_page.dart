import 'package:crud/Pages/tela_usuario.dart';
import 'package:flutter/material.dart';
import 'tela_tipo_ocorrencia.dart';
import 'tela_gravidade.dart';
import 'tela_configuracoes.dart';
import 'tela_registrar_ocorrencia.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaUsuario()),
                );
              },
              child: const Text('Cadastrar usuário'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TipoOcorrencia()),
                );
              },
              child: const Text('Ir para Tela Tipo Ocorrência'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Gravidade()),
                );
              },
              child: const Text('Ir para Tela de gravidade'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsMenuScreen()),
                );
              },
              child: const Text('Ir para configurações'),
            ),
            const SizedBox(height: 20),
            // Adicionando o botão para a nova tela
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OcorrenciaPage()), // Navega para a tela de ocorrência
                );
              },
              child: const Text('Registrar Ocorrência'),
            ),
          ],
        ),
      ),
    );
  }
}
