import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voluntario/models/user.dart';
import 'package:flutter/services.dart';
import 'dart:async';

enum authErrors { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class Auth {
  static Future<String> signIn(String email, String password) async {
    AuthResult result = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    FirebaseUser user = result.user;
    Firestore.instance
        .collection('pickers')
        .document(user.uid)
        .updateData({'isActive': true});
    return user.uid;
  }

  static Future<void> signOut() async {
    User user = await getLocalUser();
    await Firestore.instance
        .collection('pickers')
        .document(user.userId)
        .updateData({'isActive': false});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    FirebaseAuth.instance.signOut();
  }

  static Future<bool> alreadySignedEmail(String email) async {
    var result = await Firestore.instance
        .collection('emails')
        .getDocuments()
        .then((QuerySnapshot snapshots) {
      List<DocumentSnapshot> documents = snapshots.documents;
      if (documents.isNotEmpty) {
        for (int i = 0; i < documents.length; i++) {
          if (documents[i]['email'] == email) return true;
        }
        return false;
      } else
        return false;
    });
    return result;
  }

  static Future<void> forgotPasswordEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future checkPassword(String pass) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    try {
      if (user != null) {
        AuthResult result = await user.reauthenticateWithCredential(
            EmailAuthProvider.getCredential(email: user.email, password: pass));
        user = result.user;
        return "aprovado";
      }
    } catch (err) {
      return err.toString();
    }
  }

  static Future changePassword(String pass) async {
    FirebaseUser user = await getCurrentAuthUser();
    user.updatePassword(pass);
  }

  static Future<String> storeUserLocal(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeUser = userToJson(user);
    await prefs.setString('user', storeUser);
    return user.userId;
  }

  static Future<User> getLocalUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null) {
      User user = userFromJson(prefs.getString('user'));
      return user;
    } else {
      return null;
    }
  }

  static Future<FirebaseUser> getCurrentAuthUser() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    return currentUser;
  }

  static Future<User> getDbUser(String userId) async {
    if (userId != null) {
      return Firestore.instance
          .collection('pickers')
          .document(userId)
          .get()
          .then((documentSnapshot) => User.fromDocument(documentSnapshot));
    } else {
      return null;
    }
  }

  static String getExceptionText(Exception e) {
    if (e is PlatformException) {
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          return 'Esse e-mail não está cadastrado.';
          break;
        case 'The password is invalid or the user does not have a password.':
          return 'E-mail ou senha incorretos.';
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          return 'Sem conexão com a internet.';
          break;
        case 'The email address is already in use by another account.':
          return 'Esse e-mail ja está cadastrado';
          break;
        default:
          return 'Erro desconhecido.';
      }
    } else {
      return 'Erro desconhecido.';
    }
  }
}
