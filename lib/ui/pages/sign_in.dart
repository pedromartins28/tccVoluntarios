import 'package:flutter/gestures.dart';
import 'package:voluntario/ui/widgets/loading.dart';
import 'package:voluntario/util/state_widget.dart';
import 'package:voluntario/ui/widgets/forms.dart';
import 'package:voluntario/util/validator.dart';
import 'package:voluntario/util/auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Duration _timeOut = const Duration(minutes: 1);
  final FocusNode _passFocus = FocusNode();
  bool _loadingVisible = false;
  bool _autoValidate = false;
  bool _codeTimedOut = true;
  bool _isSignIn = true;
  Timer _codeTimer;
  String sentEmail;
  bool policiesChecked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.red[500],
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.15),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: LoadingPage(
          child: Form(
            autovalidate: _autoValidate,
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 75.0,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: _isSignIn ? 28.0 : 48.0),
                      _isSignIn ? Container() : _buildInstructionText(),
                      _isSignIn ? Container() : SizedBox(height: 8.0),
                      _buildEmailField(),
                      _isSignIn
                          ? Container()
                          : _codeTimer == null
                              ? Container()
                              : _codeTimer.isActive
                                  ? SizedBox(height: 8.0)
                                  : Container(),
                      _isSignIn
                          ? Container()
                          : _codeTimer == null
                              ? Container()
                              : _codeTimer.isActive
                                  ? _buildTimerText()
                                  : Container(),
                      SizedBox(height: 16.0),
                      _isSignIn ? _buildPassField() : Container(),
                      _isSignIn ? _buildForgotPassButton() : Container(),
                      _isSignIn ? _buildPoliciesCheckbox() : Container(),
                      SizedBox(
                        height: _isSignIn
                            ? MediaQuery.of(context).size.height * 0.05
                            : MediaQuery.of(context).size.height * 0.07,
                      ),
                      _isSignIn
                          ? _buildSignInButton()
                          : _buildSendEmailButton(),
                      _isSignIn ? Container() : SizedBox(height: 12.0),
                      _isSignIn ? Container() : _buildBackButton(),
                      SizedBox(height: 18.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          inAsyncCall: _loadingVisible,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return CustomField(
      icon: Icons.email,
      labelText: 'E-mail',
      onFieldSubmitted: (term) {
        FocusScope.of(context).requestFocus(_passFocus);
      },
      inputType: TextInputType.emailAddress,
      validator: Validator.validateEmail,
      textCap: TextCapitalization.none,
      action: TextInputAction.next,
      labelColor: Colors.white,
      textColor: Colors.white,
      iconColor: Colors.white,
      controller: _email,
    );
  }

  Widget _buildPassField() {
    return CustomField(
      labelText: 'Senha',
      icon: Icons.vpn_key,
      onFieldSubmitted: (context) {
        _passFocus.unfocus();
      },
      validator: Validator.validatePass,
      textCap: TextCapitalization.none,
      action: TextInputAction.done,
      labelColor: Colors.white,
      textColor: Colors.white,
      iconColor: Colors.white,
      controller: _pass,
      obscureText: true,
      node: _passFocus,
    );
  }

  Widget _buildPoliciesCheckbox() {
    return Row(
      children: <Widget>[
        Checkbox(
          value: policiesChecked,
          onChanged: (value) {
            setState(() {
              policiesChecked = value;
            });
          },
          checkColor: Theme.of(context).primaryColor,
          activeColor: Colors.white,
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Eu li e Concordo com a ",
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: "Política de Privacidade.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchURL();
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        child: Text(
          'Esqueceu sua senha?',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          setState(() {
            _isSignIn = false;
          });
        },
      ),
    );
  }

  Widget _buildSignInButton() {
    return RaisedButton(
      child: Text(
        'ENTRAR',
        style: TextStyle(fontSize: 18.0),
      ),
      padding: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: Colors.white,
      onPressed: () {
        _signInProcedure(
          email: _email.text,
          password: _pass.text,
          context: context,
        );
      },
    );
  }

  Widget _buildSendEmailButton() {
    return RaisedButton(
      child: Text(
        'ENVIAR',
        style: TextStyle(fontSize: 18.0),
      ),
      padding: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: Colors.white,
      onPressed: () {
        _changePasswordProcedure(_email.text);
      },
    );
  }

  Widget _buildBackButton() {
    return FlatButton(
      child: Text(
        'ACESSAR CONTA',
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      ),
      onPressed: () {
        setState(() {
          _isSignIn = true;
        });
      },
    );
  }

  Widget _buildInstructionText() {
    return Text(
      "Um email de recuperação será enviado para:",
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTimerText() {
    return Text(
      "Você ainda não pode enviar outro email",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  void showFlushBar(String message) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
      isDismissible: false,
    )..show(context);
  }

  _launchURL() async {
    const url = 'https://recicle.web.app/download/picker_policy.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool _policiesValidator() {
    if (policiesChecked)
      return true;
    else {
      showFlushBar("É preciso aceitar a Política de Privacidade para entrar.");
      return false;
    }
  }

  Future<bool> _verifyEmail(String email) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    await _changeLoadingVisible();
    var _isAlreadySigned = await Auth.alreadySignedEmail(email);
    if (_isAlreadySigned != null) {
      if (_isAlreadySigned) {
        return true;
      } else {
        await _changeLoadingVisible();
        Flushbar(
          isDismissible: false,
          title: "FALHA AO ENTRAR",
          message: "Esse email não foi cadastrado",
          duration: Duration(seconds: 3),
        )..show(context);
        return false;
      }
    } else {
      await _changeLoadingVisible();
      Flushbar(
        isDismissible: false,
        title: "FALHA AO ENTRAR",
        message: "Não foi possível verificar o email",
        duration: Duration(seconds: 3),
      )..show(context);
      return false;
    }
  }

  void _signInProcedure(
      {String email, String password, BuildContext context}) async {
    if (_formKey.currentState.validate() && _policiesValidator()) {
      bool emailVerified = await _verifyEmail(email);
      if (emailVerified) {
        try {
          await StateWidget.of(context).signInUser(email, password);
          _codeTimer.cancel();
        } catch (e) {
          await _changeLoadingVisible();
          String exception = Auth.getExceptionText(e);
          Flushbar(
            isDismissible: false,
            title: "FALHA AO ENTRAR",
            message: exception,
            duration: Duration(seconds: 3),
          )..show(context);
        }
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }

  _emailSent() {
    setState(() {
      _codeTimedOut = false;
    });
    _codeTimer = Timer(_timeOut, () {
      setState(() {
        _codeTimedOut = true;
      });
    });
  }

  _changePasswordProcedure(String email) async {
    if (_formKey.currentState.validate()) {
      if (_codeTimedOut) {
        try {
          await _changeLoadingVisible();
          await Auth.forgotPasswordEmail(email);
          _emailSent();
          await _changeLoadingVisible();
          Flushbar(
            isDismissible: false,
            message: "O email de alteração foi enviado para $email",
            duration: Duration(seconds: 5),
          )..show(context);
        } catch (e) {
          await _changeLoadingVisible();
          String exception = Auth.getExceptionText(e);
          Flushbar(
            isDismissible: false,
            title: "FALHA AO ENVIAR EMAIL",
            message: exception,
            duration: Duration(seconds: 5),
          )..show(context);
        }
      } else {
        Flushbar(
          isDismissible: false,
          title: 'TENTE NOVAMENTE MAIS TARDE',
          message: "Aguarde um período antes de enviar outro email",
          duration: Duration(seconds: 5),
        )..show(context);
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }
}
