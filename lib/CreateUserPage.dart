// ignore_for_file: file_names, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class CreateUserpage extends StatefulWidget {
  const CreateUserpage({super.key});


  @override
  State<StatefulWidget> createState() {
    return _CreateUserpageState();
  }
}

class _CreateUserpageState extends State<CreateUserpage> {
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  String error='';



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISTVL'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
        padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset('assets/images/logo.png', height: 250),
              const SizedBox(height: 20),
              const Text('Crear Usuario', style: TextStyle(
              color: Colors.black, 
              fontSize: 20,
              fontWeight: FontWeight.bold
            )),
          ],
        ),
      ),
          Offstage(
            offstage:error == '' ,
            child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(error, style: TextStyle(color: Colors.red, fontSize: 16),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: formulario()
            ),
            butonCrearUsuario(),
        ],
      ),
    );
  }

  Widget formulario(){
      return Form(
        key: _formKey,
        child:  Column(children: [
          buildEmail(),
          const Padding(padding: EdgeInsets.only(top: 12)),
          buildPassword(),
      ],));
  }

  Widget buildEmail() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Correo",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.black)
        )
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String? value) {
        email = value!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
      }
      return null;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.black)
        )
      ),
      obscureText: true,
      validator: (value){
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
      }
      return null;

      },
      onSaved: (String? value) { 
        password = value!;
      },
    );
  }

  Widget butonCrearUsuario(){
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
      onPressed: () async{

        if(_formKey.currentState!.validate()){
          _formKey.currentState!.save();
          UserCredential? credenciales = await crear(email, password);
          if(credenciales !=null){
            if(credenciales.user != null){
              await credenciales.user!.sendEmailVerification();
              Navigator.of(context).pop();
          }
        }
      }

    }, 
      child: Text("Registrarse")
      ),   
    );
  }

  Future<UserCredential?> crear(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email,
        password: password);

      return userCredential;
  } on FirebaseAuthException catch(e){
    if (e.code == 'emai-already-in-use'){
      //todo usuario no encontrado
      setState(() {
        error = "usuario no encntrado";
      });
    }
    if (e.code == 'weak-password'){
      //toda contraseña muy debil
      setState(() {
        error = "contraseña incorrecta";
      });
    }
  }
    return null;
 }
}