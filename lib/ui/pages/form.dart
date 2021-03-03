import 'package:shared_preferences/shared_preferences.dart';
import 'package:voluntario/models/chechLabel.dart';
import 'package:voluntario/ui/widgets/forms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voluntario/models/user.dart';
import 'package:flutter/material.dart';
import 'package:voluntario/util/validator.dart';

class FormPage extends StatefulWidget {
  final Map request;
  FormPage({@required this.request});

  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final ScrollController listScrollController = ScrollController();
  final Firestore _db = Firestore.instance;
  bool _visible = false;
  String donorName;
  String requestId;
  String pickerId;
  String donorId;
  Map request;
  bool _quest01 = false;
  bool _quest02 = false;
  bool _quest03 = false;
  bool _quest04 = false;
  SharedPreferences prefs;

  final TextEditingController _unidadeBasicaSaudeController =
      TextEditingController();

  @override
  void initState() {
    initializeIds();
    super.initState();
  }

  initializeIds() {
    request = widget.request;
    requestId = request['requestId'];
    pickerId = request['pickerId'];
    donorId = request['donorId'];
  }

  Widget inputForm(TextEditingController _controller, String text,
      IconData icon, TextInputType teclado) {
    final FocusNode _nameFocus = FocusNode();
    String _texto = text;
    IconData _icone = icon;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
      child: CustomField(
        enable: true,
        prefixIcon: _icone,
        iconColor: Colors.white,
        labelText: _texto,
        onFieldSubmitted: (term) {
          FocusScope.of(context).requestFocus(_nameFocus);
        },
        validator: Validator.validateForm,
        textCap: TextCapitalization.words,
        inputType: teclado,
        action: TextInputAction.next,
        controller: _controller,
        textColor: Colors.white,
        labelColor: Colors.white,
      ),
    );
  }

  Widget botao(String texto, Function funcaoSend) {
    String _texto2 = texto;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        child: RaisedButton(
          child: Text(
            _texto2,
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
          padding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          color: Colors.white,
          onPressed: funcaoSend,
        ),
      ),
    );
  }

  void finishForm() async {
    Firestore.instance.collection('donors').document(donorId).updateData(
      {
        'APAGARRRRRR': _unidadeBasicaSaudeController.text,
        'quest01': _quest01,
        'quest02': _quest02,
        'quest03': _quest03,
      },
    );

    setState(() {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[400].withOpacity(0.7),
      appBar: AppBar(
        title: Text(
          "Formulário",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            StreamBuilder(
              stream: Firestore.instance
                  .collection('pickers')
                  .where('userId', isEqualTo: pickerId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  User user = User.fromDocument(snapshot.data.documents[0]);
                  return Column(
                    children: <Widget>[
                      SizedBox(height: 8.0),
                      Container(
                        child: Column(
                          children: <Widget>[
                            LabeledCheckbox(
                              label: 'Mama olhando?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest01,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest01 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Cuzin largo?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest02,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest02 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Perereca fedendo?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest03,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest03 = newValue;
                                });
                              },
                            ),
                            inputForm(
                                _unidadeBasicaSaudeController,
                                "Unidade Básica de Saúde",
                                Icons.local_hospital,
                                TextInputType.text),
                            botao("Salvar", finishForm),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        endIndent: 8.0,
                        indent: 8.0,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(48.0, 8.0, 48.0, 16.0),
                        child: Text(
                          "Para a alterar seus dados entre em contato com a ${user.institutionName}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w200, fontSize: 12),
                          //textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: Container(
                      child: CircularProgressIndicator(
                        strokeWidth: 5.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor),
                      ),
                      height: 30,
                      width: 30,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget dataUnit(String text1, String text2) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 8, 0, 15),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 6.0),
                child: Text(
                  "$text1 :",
                  style: TextStyle(fontWeight: FontWeight.w200, fontSize: 16),
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                child: Expanded(
                  child: Text(
                    text2,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
                    overflow: TextOverflow.clip,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
