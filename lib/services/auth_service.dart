import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<User?> currentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> iniciarSesionConGoogle() async {
    final cuenta = await GoogleSignIn.instance.authenticate();
    final credencial = GoogleAuthProvider.credential(
      idToken: cuenta.authentication.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credencial);
  }

  Future<void> cerrarSesion() async {
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
  }
}