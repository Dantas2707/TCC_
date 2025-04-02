import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crud/services/firestore.dart';

class TelaUsuario extends StatefulWidget {
  const TelaUsuario({Key? key}) : super(key: key);

  @override
  State<TelaUsuario> createState() => _TelaUsuarioState();
}

class _TelaUsuarioState extends State<TelaUsuario> {
  final FirestoreService firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final cpfController = TextEditingController();
  final telefoneController = TextEditingController();
  final dataNascController = TextEditingController();
  final senhaController = TextEditingController(); // Campo de senha adicionado

  String? _sexoSelecionado;

  bool validarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) return false;
    List<int> numeros = cpf.split('').map(int.parse).toList();
    for (int j = 9; j < 11; j++) {
      int soma = 0;
      for (int i = 0; i < j; i++) {
        soma += numeros[i] * ((j + 1) - i);
      }
      int resto = (soma * 10) % 11;
      if (resto == 10) resto = 0;
      if (resto != numeros[j]) return false;
    }
    return true;
  }

  bool validarEmail(String email) {
    RegExp regex = RegExp(
        r'^.+@[a-zA-Z]+\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?$');
    return regex.hasMatch(email);
  }

  Future<void> selecionarDataNascimento(BuildContext context) async {
    DateTime hoje = DateTime.now();
    DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime(hoje.year - 20),
      firstDate: DateTime(hoje.year - 120),
      lastDate: DateTime(hoje.year - 13),
    );
    if (dataEscolhida != null) {
      setState(() {
        dataNascController.text =
            dataEscolhida.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Cria o usuário no Firebase Authentication
        UserCredential authResult = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: senhaController.text.trim(),
        );
        String uid = authResult.user!.uid;

        // Prepara os dados do usuário
        Map<String, dynamic> dadosUsuario = {
          'nome': nomeController.text.trim(),
          'email': emailController.text.trim(),
          'cpf': cpfController.text.trim(),
          'numerotelefone': telefoneController.text.trim(),
          'dataNasc': DateTime.parse(dataNascController.text),
          'sexo': _sexoSelecionado,
          'inativar': false,
          'timestamp': DateTime.now(),
        };

        // Salva os dados no Firestore utilizando o UID do usuário
        await firestoreService.addUsuario(uid, dadosUsuario);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário registrado com sucesso!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _sexoSelecionado = null;
          dataNascController.clear();
          senhaController.clear();
        });
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Usuário")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo Nome
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório.';
                  }
                  String nome = value.trim();
                  if (!RegExp(r'^[A-Za-zÀ-ÿ\s]+$').hasMatch(nome)) {
                    return 'Nome deve conter apenas letras e espaços.';
                  }
                  if (nome.length < 5 || nome.length > 100) {
                    return 'Nome deve ter entre 5 e 100 caracteres.';
                  }
                  return null;
                },
              ),
              // Campo E-mail
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (value) => value == null || !validarEmail(value)
                    ? 'E-mail inválido.'
                    : null,
              ),
              // Campo de Senha
              TextFormField(
                controller: senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Senha é obrigatória.';
                  }
                  if (value.trim().length < 6) {
                    return 'Senha deve ter no mínimo 6 caracteres.';
                  }
                  return null;
                },
              ),
              // Campo CPF
              TextFormField(
                controller: cpfController,
                decoration: const InputDecoration(labelText: 'CPF'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || !validarCPF(value)
                    ? 'CPF inválido.'
                    : null,
              ),
              // Campo Telefone
              TextFormField(
                controller: telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null ||
                        value.length < 8 ||
                        value.length > 20
                    ? 'Telefone deve ter entre 8 e 20 caracteres.'
                    : null,
              ),
              // Campo Data de Nascimento
              TextFormField(
                controller: dataNascController,
                decoration:
                    const InputDecoration(labelText: 'Data Nascimento'),
                readOnly: true,
                onTap: () => selecionarDataNascimento(context),
                validator: (value) => value == null || value.isEmpty
                    ? 'Selecione uma data válida.'
                    : null,
              ),
              // Dropdown para Sexo
              DropdownButtonFormField<String>(
                value: _sexoSelecionado,
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: const [
                  DropdownMenuItem(
                      value: 'Masculino', child: Text('Masculino')),
                  DropdownMenuItem(
                      value: 'Feminino', child: Text('Feminino')),
                ],
                onChanged: (valor) {
                  setState(() {
                    _sexoSelecionado = valor;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione o sexo.' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registrarUsuario,
                child: const Text("Registrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
