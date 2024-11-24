import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Usuario {
  final String id;
  final String nome;
  final String sobrenome;
  final String genero;
  final int idade;
  final String email;

  Usuario({
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.genero,
    required this.idade,
    required this.email,
  });

  factory Usuario.fromJson(Map<String, dynamic> json, String id) {
    return Usuario(
      id: id,
      nome: json["nome"],
      sobrenome: json["sobrenome"],
      genero: json["genero"],
      idade: json["idade"],
      email: json["email"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nome": nome,
      "sobrenome": sobrenome,
      "genero": genero,
      "idade": idade,
      "email": email,
    };
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CRUD'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Usuario>> usuariosFuture;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String nome = '';
  String sobrenome = '';
  String genero = '';
  int idade = 0;
  String email = '';
  String? userId;

  @override
  void initState() {
    super.initState();
    usuariosFuture = _lerUsuarios();
  }

  Future<List<Usuario>> _lerUsuarios() async {
    final url = Uri.parse(
        'https://crudcrud.com/api/7adba664a1324d398354a95914031a05/users');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Usuario.fromJson(json, json["_id"])).toList();
    } else {
      throw Exception('Falha ao carregar usuários');
    }
  }

  Future<void> _adicionarUsuario() async {
    final url = Uri.parse(
        'https://crudcrud.com/api/7adba664a1324d398354a95914031a05/users');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'sobrenome': sobrenome,
        'genero': genero,
        'idade': idade,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        usuariosFuture = _lerUsuarios();
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário adicionado com sucesso!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao adicionar usuário')));
    }
  }

  Future<void> _atualizarUsuario(String id) async {
    if (userId == null) return;

    final url = Uri.parse(
        'https://crudcrud.com/api/7adba664a1324d398354a95914031a05/users/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'sobrenome': sobrenome,
        'genero': genero,
        'idade': idade,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        usuariosFuture = _lerUsuarios();
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário atualizado com sucesso!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar usuário')));
    }
  }

  Future<void> _excluirUsuario(String id) async {
    final url = Uri.parse(
        'https://crudcrud.com/api/7adba664a1324d398354a95914031a05/users/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      setState(() {
        usuariosFuture = _lerUsuarios();
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário excluído com sucesso!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir usuário')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Usuario>>(
        future: usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado.'));
          }

          final usuarios = snapshot.data!;

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    '${usuarios[index].nome} ${usuarios[index].sobrenome}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _editarUsuario(usuarios[index]);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _excluirUsuario(usuarios[index].id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioAdicionar,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editarUsuario(Usuario usuario) {
    setState(() {
      userId = usuario.id;
      nome = usuario.nome;
      sobrenome = usuario.sobrenome;
      genero = usuario.genero;
      idade = usuario.idade;
      email = usuario.email;
    });
    _mostrarFormularioEditar();
  }

  void _mostrarFormularioAdicionar() {
    nome = '';
    sobrenome = '';
    genero = '';
    idade = 0;
    email = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(userId == null ? 'Adicionar Usuário' : 'Editar Usuário'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nome,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      value!.isEmpty ? 'Nome obrigatório' : null,
                  onSaved: (value) => nome = value!,
                ),
                TextFormField(
                  initialValue: sobrenome,
                  decoration: const InputDecoration(labelText: 'Sobrenome'),
                  validator: (value) =>
                      value!.isEmpty ? 'Sobrenome obrigatório' : null,
                  onSaved: (value) => sobrenome = value!,
                ),
                TextFormField(
                  initialValue: genero,
                  decoration: const InputDecoration(labelText: 'Gênero'),
                  validator: (value) =>
                      value!.isEmpty ? 'Gênero obrigatório' : null,
                  onSaved: (value) => genero = value!,
                ),
                TextFormField(
                  initialValue: idade.toString(),
                  decoration: const InputDecoration(labelText: 'Idade'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Idade obrigatória' : null,
                  onSaved: (value) => idade = int.parse(value!),
                ),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value!.isEmpty ? 'Email obrigatório' : null,
                  onSaved: (value) => email = value!,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _salvarUsuario,
                  child: Text(userId == null ? 'Adicionar' : 'Salvar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarFormularioEditar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(userId == null ? 'Adicionar Usuário' : 'Editar Usuário'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nome,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      value!.isEmpty ? 'Nome obrigatório' : null,
                  onSaved: (value) => nome = value!,
                ),
                TextFormField(
                  initialValue: sobrenome,
                  decoration: const InputDecoration(labelText: 'Sobrenome'),
                  validator: (value) =>
                      value!.isEmpty ? 'Sobrenome obrigatório' : null,
                  onSaved: (value) => sobrenome = value!,
                ),
                TextFormField(
                  initialValue: genero,
                  decoration: const InputDecoration(labelText: 'Gênero'),
                  validator: (value) =>
                      value!.isEmpty ? 'Gênero obrigatório' : null,
                  onSaved: (value) => genero = value!,
                ),
                TextFormField(
                  initialValue: idade.toString(),
                  decoration: const InputDecoration(labelText: 'Idade'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Idade obrigatória' : null,
                  onSaved: (value) => idade = int.parse(value!),
                ),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value!.isEmpty ? 'Email obrigatório' : null,
                  onSaved: (value) => email = value!,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _salvarUsuario,
                  child: Text(userId == null ? 'Adicionar' : 'Salvar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _salvarUsuario() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (userId == null) {
        _adicionarUsuario();
      } else {
        _atualizarUsuario(userId!);
      }
      Navigator.of(context).pop();
    }
  }
}
