import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/services/firestore.dart';// Ajuste o caminho para seu arquivo de serviço

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _dataNascController = TextEditingController();
  String? _sexoSelecionado;

  bool _isLoading = true;
  User? user;

  @override
  void initState() {
    super.initState();
    // Obtém o usuário atual do FirebaseAuth
    user = FirebaseAuth.instance.currentUser;
    // Carrega os dados se o usuário estiver logado
    if (user != null) {
      _loadUserData();
    }
  }

  // Carrega dados do Firestore usando o UID do usuário logado
  Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuario')
          .doc(user!.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _nomeController.text = data['nome'] ?? '';
        _emailController.text = data['email'] ?? '';
        _cpfController.text = data['cpf'] ?? '';
        _telefoneController.text = data['numerotelefone'] ?? '';
        if (data['dataNasc'] != null) {
          // Se dataNasc for um Timestamp do Firestore
          if (data['dataNasc'] is Timestamp) {
            final Timestamp timestamp = data['dataNasc'];
            final DateTime dateTime = timestamp.toDate();
            _dataNascController.text = dateTime.toIso8601String().split('T').first;
          }
          // Caso seja DateTime armazenado como string, ajuste conforme necessário
          else if (data['dataNasc'] is String) {
            _dataNascController.text = data['dataNasc'];
          }
        }
        _sexoSelecionado = data['sexo'] ?? null;
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Atualiza dados do usuário no Firestore
  Future<void> _updateUserInfo() async {
    if (_formKey.currentState!.validate() && user != null) {
      final dadosAtualizados = {
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'numerotelefone': _telefoneController.text.trim(),
        // Se armazenado como DateTime ou Timestamp
        'dataNasc': DateTime.tryParse(_dataNascController.text) ?? DateTime.now(),
        'sexo': _sexoSelecionado,
      };

      try {
        await _firestoreService.atualizarUsuario(user!.uid, dadosAtualizados);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados atualizados com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e')),
        );
      }
    }
  }

  // Seleciona data de nascimento
  Future<void> _selecionarDataNascimento() async {
    final hoje = DateTime.now();
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime(hoje.year - 20),
      firstDate: DateTime(hoje.year - 120),
      lastDate: DateTime(hoje.year - 13),
    );
    if (dataEscolhida != null) {
      setState(() {
        _dataNascController.text = dataEscolhida.toIso8601String().split('T').first;
      });
    }
  }

  @override
  void dispose() {
    // Liberar recursos
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _dataNascController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações Pessoais'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nome
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o nome';
                        }
                        return null;
                      },
                    ),
                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o email';
                        }
                        return null;
                      },
                    ),
                    // CPF
                    TextFormField(
                      controller: _cpfController,
                      decoration: const InputDecoration(labelText: 'CPF'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o CPF';
                        }
                        return null;
                      },
                    ),
                    // Telefone
                    TextFormField(
                      controller: _telefoneController,
                      decoration: const InputDecoration(labelText: 'Telefone'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o telefone';
                        }
                        return null;
                      },
                    ),
                    // Data de Nascimento
                    TextFormField(
                      controller: _dataNascController,
                      decoration:
                          const InputDecoration(labelText: 'Data Nascimento'),
                      readOnly: true,
                      onTap: _selecionarDataNascimento,
                    ),
                    // Sexo
                    DropdownButtonFormField<String>(
                      value: _sexoSelecionado,
                      decoration: const InputDecoration(labelText: 'Sexo'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Masculino',
                          child: Text('Masculino'),
                        ),
                        DropdownMenuItem(
                          value: 'Feminino',
                          child: Text('Feminino'),
                        ),
                      ],
                      onChanged: (valor) {
                        setState(() {
                          _sexoSelecionado = valor;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateUserInfo,
                      child: const Text('Atualizar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
