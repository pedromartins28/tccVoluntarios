import 'dart:io';

import 'package:voluntario/ui/widgets/loading.dart';
import 'package:voluntario/util/state_widget.dart';
import 'package:voluntario/util/validator.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voluntario/util/auth.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPass = TextEditingController();
  final TextEditingController _newPass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _newPassFocus = FocusNode();

  bool _loadingVisible = false;
  bool _autoValidate = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "ALTERAR SENHA",
          ),
          centerTitle: true,
        ),
        body: Container(
          child: LoadingPage(
            child: Form(
              autovalidate: _autoValidate,
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Essa ação não poderá ser revertida',
                          textAlign: TextAlign.center),
                      SizedBox(height: 24.0),
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide:
                                BorderSide(color: Colors.black54, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide:
                                BorderSide(color: Colors.black54, width: 1.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                                color: Colors.red.withAlpha(175), width: 1.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide:
                                BorderSide(color: Colors.red, width: 1.0),
                          ),
                          labelText: 'Senha Antiga',
                        ),
                        onFieldSubmitted: (term) {
                          FocusScope.of(context).requestFocus(_newPassFocus);
                        },
                        textInputAction: TextInputAction.done,
                        validator: Validator.validatePass,
                        controller: _oldPass,
                        obscureText: true,
                      ),
                      SizedBox(height: 24.0),
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide:
                                BorderSide(color: Colors.black54, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide:
                                BorderSide(color: Colors.black54, width: 1.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                                color: Colors.red.withAlpha(175), width: 1.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide:
                                BorderSide(color: Colors.red, width: 1.0),
                          ),
                          labelText: 'Senha Nova',
                        ),
                        onFieldSubmitted: (context) {
                          _newPassFocus.unfocus();
                        },
                        textInputAction: TextInputAction.done,
                        validator: Validator.validatePass,
                        focusNode: _newPassFocus,
                        controller: _newPass,
                        obscureText: true,
                      ),
                      SizedBox(height: 24.0),
                      RaisedButton(
                        child: Text('ALTERAR',
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.white)),
                        padding: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          if (await _verifyConnection()) {
                            _changePassProcedure(
                                oldPass: _oldPass.text,
                                newPass: _newPass.text,
                                context: context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            inAsyncCall: _loadingVisible,
          ),
        ),
      ),
    );
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  Future<bool> _verifyConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {}
      return true;
    } on SocketException catch (_) {
      Flushbar(
        message: "Falha de Conexão",
        duration: Duration(seconds: 3),
        isDismissible: false,
      )..show(context);
      return false;
    }
  }

  void _changePassProcedure(
      {String oldPass, String newPass, BuildContext context}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();
        String result =
            await StateWidget.of(context).changeUserPassword(oldPass, newPass);
        await _changeLoadingVisible();
        if (result != "Senha antiga incorreta!") Navigator.pop(context, true);
        Flushbar(
          message: result,
          duration: Duration(seconds: 5),
          isDismissible: false,
        )..show(context);
      } catch (e) {
        _changeLoadingVisible();
        String exception = Auth.getExceptionText(e);
        Flushbar(
          title: "ERRO AO VERIFICAR",
          message: exception,
          duration: Duration(seconds: 5),
          isDismissible: false,
        )..show(context);
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }
}
