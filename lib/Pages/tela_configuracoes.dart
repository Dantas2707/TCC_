import 'package:flutter/material.dart';
import 'tela_informacoes_pessoais.dart';

class SettingsMenuScreen extends StatelessWidget {
  const SettingsMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Informações Pessoais'),
            onTap: () {
              // Navega para a tela de informações pessoais
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PersonalInfoScreen(),
                ),
              );
            },
          ),
          // Adicione outros itens de menu se necessário
        ],
      ),
    );
  }
}
