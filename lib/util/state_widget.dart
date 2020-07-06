import 'package:firebase_auth/firebase_auth.dart';
import 'package:voluntario/models/state.dart';
import 'package:flutter/foundation.dart';
import 'package:voluntario/models/user.dart';
import 'package:voluntario/util/auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class StateWidget extends StatefulWidget {
  final StateModel state;
  final Widget child;

  StateWidget({@required this.child, this.state});

  static _StateWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StateDataWidget)
            as _StateDataWidget)
        .data;
  }

  @override
  _StateWidgetState createState() => _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {
  StateModel state;

  @override
  void initState() {
    super.initState();
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = StateModel(isLoading: true);
      initUser();
    }
  }

  Future<Null> initUser() async {
    FirebaseUser authUser = await Auth.getCurrentAuthUser();
    User user = await Auth.getLocalUser();
    setState(() {
      state.isLoading = false;
      state.authUser = authUser;
      state.user = user;
    });
  }

  Future<void> signOutUser() async {
    await Auth.signOut();
    setState(() {
      state.user = null;
      state.authUser = null;
    });
  }

  Future<void> signInUser(email, password) async {
    String userId = await Auth.signIn(email, password);
    User user = await Auth.getDbUser(userId);
    await Auth.storeUserLocal(user);
    await initUser();
  }

  Future<String> changeUserPassword(oldPass, newPass) async {
    String res = await Auth.checkPassword(oldPass);
    if (res ==
        "NoSuchMethodError: The method '[]' was called on null." +
            '\nReceiver: null\nTried calling: []("user")') {
      Auth.changePassword(newPass);
      return "Senha trocada com sucesso";
    } else if (res ==
        "PlatformException(ERROR_WRONG_PASSWORD, The password is invalid or the user does not have a password., null)") {
      setState(() {
        state.isLoading = false;
      });
      return "Senha antiga incorreta!";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _StateDataWidget(
      data: this,
      child: widget.child,
    );
  }
}

class _StateDataWidget extends InheritedWidget {
  final _StateWidgetState data;

  _StateDataWidget({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_StateDataWidget old) => true;
}
