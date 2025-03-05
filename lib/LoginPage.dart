// ignore_for_file: unused_local_variable, non_constant_identifier_names, use_build_context_synchronously, file_names

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:login_v2/CreateUserPage.dart';
import 'package:login_v2/MyHomePage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});


  @override
  State<StatefulWidget> createState() {
    return _LoginpageState();
  }
}

class _LoginpageState extends State<Loginpage> {
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
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/logo.png', height: 250),
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
            butonLogin(),
            nuevoAqui(),
            buildOrLine(),
            BotonesGoogleApple(),
        ],
      ),
    );
  }

  Widget BotonesGoogleApple(){
    return Column(
      children: [
        SignInButton(Buttons.Google, onPressed: () async{
          await entrarConGoogle();
          if(FirebaseAuth.instance.currentUser !=null){
            Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (context)=>MyHomePage()), 
                (Route<dynamic> route)=> false);
          }
        }),
        SignInButton(Buttons.Facebook, onPressed: () async{
          await entrarConFacebook();
          if(FirebaseAuth.instance.currentUser !=null){
            Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (context)=>MyHomePage()), 
                (Route<dynamic> route)=> false);
          }
        }),
        Offstage(
          offstage: !Platform.isIOS,
          child: SignInButton(Buttons.Apple, onPressed: () async{
            await entrarConApple();
              if(FirebaseAuth.instance.currentUser !=null){
                Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (context)=>MyHomePage()), 
                    (Route<dynamic> route)=> false);
              }
          },),
        )
      ],
    );
  }

  Future<UserCredential> entrarConGoogle()async{
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? authentication = await googleUser?.authentication;
    final credentials = GoogleAuthProvider.credential(
      accessToken: authentication?.accessToken,
      idToken: authentication?.idToken
    );
    return await FirebaseAuth.instance.signInWithCredential(credentials);
   
  }

  Future<UserCredential> entrarConFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
    final OAuthCredential credential = 
      FacebookAuthProvider.credential(result.accessToken!.tokenString);
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
      throw FirebaseAuthException(
      code: 'ERROR_MISSING_ACCESS_TOKEN',
      message: 'No se pudo obtener el token de acceso de Facebook',
    );
  }

  Future<UserCredential> entrarConApple()async{

    final rawNonce = generateNonce();
    final nonce = sha256toString(rawNonce);

     final appleCredentials = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
    ],
    nonce:nonce);

    final authCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredentials.identityToken,
      rawNonce : rawNonce
    );

    return await FirebaseAuth.instance.signInWithCredential(authCredential);
  }

  String sha256toString(String imput){
    final bytes = utf8.encode(imput);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Widget buildOrLine(){
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Divider()),
        Text("o"),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget nuevoAqui(){
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Nuevo aquí'),
        TextButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) =>CreateUserpage()));

        }, child: Text('Registrese')),
      ],
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

  Widget butonLogin(){
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
      onPressed: () async{

        if(_formKey.currentState!.validate()){
          _formKey.currentState!.save();
          UserCredential? credenciales = await login(email, password);
          if(credenciales !=null){
            if(credenciales.user != null){
              if(credenciales.user!.emailVerified){
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage()),
                  (Route<dynamic> route) => false);
              }
              else{
                //todo Mostrar al ususario que debe veruficar su email
                setState(() {
                  error = "Debes verificar tu correo antes de acceder";
                });
            }
          }
        }
      }

    }, 
      child: Text("Login")
      ),   
    );
  }

  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email,
        password: password);

      return userCredential;
  } on FirebaseAuthException catch(e){
    if (e.code == 'user-not-found'){
      //todo usuario no encontrado
      setState(() {
        error = "usuario no encntrado";
      });
    }
    if (e.code == 'wrong-password'){
      //toda contraseña incorrecta
      setState(() {
        error = "contraseña incorrecta";
      });
    }
  }
    return null;
 }
}