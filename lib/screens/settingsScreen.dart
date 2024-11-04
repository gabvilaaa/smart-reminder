import 'package:flutter/material.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '/database/database_helper.dart'; // Certifique-se de importar seu helper de banco de dados

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = 'Lionel';
  String userEmail = 'lionel@gmail.com';
  String sobrenome = 'Messi';
  String password = 'null';
  File? userProfileImage;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        userProfileImage = File(image.path);
      });
    }
  }

  Future<bool> _userExists(String email) async {
    // Verifica se o usuário já existe no banco de dados
    return await DatabaseHelper().userExists(email);
  }

  Future<void> _insertUser() async {
    // Primeiro, verifica se o usuário já existe
    bool exists = await _userExists(userEmail);
    if (exists) {
      // Exibir um diálogo informando que o usuário já está cadastrado
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text('Um usuário com este e-mail já está cadastrado.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Insere o novo usuário no banco de dados
      Map<String, String> user = {
        'name': userName,
        'surname': sobrenome,
        'email': userEmail,
        'password': password, // Corrigido para usar a senha correta
        'profile_image': userProfileImage?.path ?? '',
      };

      await DatabaseHelper().insertUser(0, user); // O ID será gerado automaticamente
      Navigator.pop(context); // Fechar o pop-up após o login
      setState(() {}); // Atualizar a tela para mostrar as novas informações
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // User Account Section
          const Text(
            'User Account',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildUserProfile(context),
          const SizedBox(height: 20),

          // Settings Options
          const Text(
            'Settings Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: true,
            activeColor: Color.fromRGBO(0, 220, 0, 1),
            onChanged: (value) {
              // Update notification settings
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: false,
            inactiveThumbColor: Color.fromRGBO(255, 0, 0, 1),
            inactiveTrackColor: Color.fromRGBO(255, 0, 0, 0.4),
            onChanged: (value) {
              // Update theme settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Card(
      color: Color.fromRGBO(
        Random().nextInt(255),
        Random().nextInt(255),
        Random().nextInt(255),
        1,
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: userProfileImage != null
              ? FileImage(userProfileImage!)
              : NetworkImage('https://img.olympics.com/images/image/private/t_1-1_300/f_auto/v1687307644/primary/cqxzrctscdr8x47rly1g') as ImageProvider,
        ),
        title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(userEmail),
        trailing: const Icon(Icons.edit),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        ),
                        onChanged: (value) {
                          userName = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Sobrenome',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        ),
                        onChanged: (value) {
                          sobrenome = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          userEmail = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        ),
                        onChanged: (value) {
                          password = value; // Corrigido para usar a senha correta
                        },
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _pickImage(); // Permitir ao usuário escolher uma foto
                        },
                        child: const Text('Escolher Foto de Perfil'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Fechar o pop-up ao cancelar
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                            ),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await _insertUser(); // Inserir o usuário no banco de dados
                            },
                            child: const Text('Entrar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
