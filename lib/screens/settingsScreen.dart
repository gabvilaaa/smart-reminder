import 'package:flutter/material.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '/database/database_helper.dart';

/*
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = 'Faça login ou cadastre-se aqui';
  String userEmail = 'seu-email@gmail.com';
  String userSurname = 'Seu nome';
  String password = '';
  File? userProfileImage;

  Future<File> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
      });
        return File(image.path);

    }
    return File("");
  }

  Future<void> _insertUser() async {
    bool exists = await DatabaseHelper().userExists(userEmail);
    if (exists) {
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
      Map<String, String> user = {
        'name': userName,
        'surname': userSurname,
        'email': userEmail,
        'password': password,
        'profile_image': userProfileImage?.path ?? '',
      };

      await DatabaseHelper().insertUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
      );
      Navigator.pop(context); // Fechar o pop-up após o cadastro
      setState(() {}); // Atualizar a tela
    }
    print("Adicionou");
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

          const Text(
            'User Account',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildUserProfile(context),
          const SizedBox(height: 20),

          const Text(
            'Settings Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: true,
            activeColor: Colors.green,
            onChanged: (value) {
              // Update notification settings
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: false,
            inactiveThumbColor: Colors.red,
            inactiveTrackColor: Colors.red.withOpacity(0.4),
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
              : NetworkImage(
                      'https://img.olympics.com/images/image/private/t_1-1_300/f_auto/v1687307644/primary/cqxzrctscdr8x47rly1g')
                  as ImageProvider,
        ),
        title:
            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(userEmail),
        trailing: const Icon(Icons.edit),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String newName="", newEmail="", newSurname="", newPass="";
              File? newFile;
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
                        'Login/Cadastro',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          newName = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Sobrenome',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          newSurname = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          newEmail = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          newPass = value;
                        },
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: (){
                          _pickImage().asStream().listen((r){
                            newFile = r;
                          });
                        },
                        child: const Text('Escolher Foto de Perfil'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
                                  context); // Fechar o pop-up ao cancelar
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                            ),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: (){
                              setState(() {
                                userName = newName;
                                userEmail = newEmail;
                                userSurname = newSurname;
                                password = newPass;
                                userProfileImage = newFile;
                                _insertUser();
                              });
                            },
                            // Chama a função para cadastrar o usuário
                            child: const Text('Cadastrar'),
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

*/
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '/database/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = 'Faça login ou cadastre-se aqui';
  String userEmail = 'seu-email@gmail.com';
  String userSurname = 'Seu nome';
  String password = '';
  File? userProfileImage;

  Future<File> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {});
      return File(image.path);
    }
    return File("");
  }

  Future<void> _insertUser() async {
    bool exists = await DatabaseHelper().userExists(userEmail);
    if (exists) {
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
      Map<String, String> user = {
        'name': userName,
        'surname': userSurname,
        'email': userEmail,
        'password': password,
        'profile_image': userProfileImage?.path ?? '',
      };

      await DatabaseHelper().insertUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
      );
      Navigator.pop(context); // Fechar o pop-up após o cadastro
      setState(() {}); // Atualizar a tela
    }
    print("Adicionou");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurações',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
          ),
          const SizedBox(height: 20),

          const Text(
            'Conta do Usuário',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildUserProfile(context),
          const SizedBox(height: 20),

          const Text(
            'Opções de Configuração',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Ativar Notificações'),
            value: true,
            activeColor: Colors.green,
            onChanged: (value) {
              // Atualizar configurações de notificações
            },
          ),
          SwitchListTile(
            title: const Text('Modo Escuro'),
            value: false,
            inactiveThumbColor: Colors.red,
            inactiveTrackColor: Colors.red.withOpacity(0.4),
            onChanged: (value) {
              // Atualizar configurações de tema
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: userProfileImage != null
              ? FileImage(userProfileImage!)
              : NetworkImage(
                      'https://img.olympics.com/images/image/private/t_1-1_300/f_auto/v1687307644/primary/cqxzrctscdr8x47rly1g')
                  as ImageProvider,
        ),
        title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(userEmail, style: TextStyle(color: Colors.grey[600])),
        trailing: const Icon(Icons.edit, color: Color.fromARGB(255, 17, 146, 0)),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String newName = "", newEmail = "", newSurname = "", newPass = "";
              File? newFile;
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
                        'Login/Cadastro',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 17, 146, 0)),
                          ),
                        ),
                        onChanged: (value) {
                          newName = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Sobrenome',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 17, 146, 0)),
                          ),
                        ),
                        onChanged: (value) {
                          newSurname = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 17, 146, 0)),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          newEmail = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color:Color.fromARGB(255, 17, 146, 0)),
                          ),
                        ),
                        onChanged: (value) {
                          newPass = value;
                        },
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _pickImage().asStream().listen((r) {
                            newFile = r;
                          });
                        },
                        child: const Text('Escolher Foto de Perfil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 17, 146, 0), // Replaced `primary` with `backgroundColor`
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                userName = newName;
                                userEmail = newEmail;
                                userSurname = newSurname;
                                password = newPass;
                                userProfileImage = newFile;
                                _insertUser();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 17, 146, 0), // Replaced `primary` with `backgroundColor`
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Cadastrar', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255),),)
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
