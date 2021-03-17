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
  bool _quest01 = false,
      _quest02 = false,
      _quest03 = false,
      _quest04 = false,
      _quest05 = false,
      _quest06 = false,
      _quest07 = false,
      _quest08 = false,
      _quest09 = false,
      _quest10 = false,
      _quest11 = false,
      _quest12 = false,
      _quest13 = false,
      _quest14 = false,
      _quest15 = false,
      _quest16 = false,
      _quest17 = false,
      _quest18 = false,
      _quest19 = false;

  final TextEditingController _quest20 = TextEditingController();

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

    _db.collection('donors').document(donorId).get().then((snapshot) {
      setState(() {
        _quest01 = snapshot.data['quest01'];
        _quest02 = snapshot.data['quest02'];
        _quest03 = snapshot.data['quest03'];
        _quest04 = snapshot.data['quest04'];
        _quest05 = snapshot.data['quest05'];
        _quest06 = snapshot.data['quest06'];
        _quest07 = snapshot.data['quest07'];
        _quest08 = snapshot.data['quest08'];
        _quest09 = snapshot.data['quest09'];
        _quest10 = snapshot.data['quest10'];
        _quest11 = snapshot.data['quest11'];
        _quest12 = snapshot.data['quest12'];
        _quest13 = snapshot.data['quest13'];
        _quest14 = snapshot.data['quest14'];
        _quest15 = snapshot.data['quest15'];
        _quest16 = snapshot.data['quest16'];
        _quest17 = snapshot.data['quest17'];
        _quest18 = snapshot.data['quest18'];
        _quest19 = snapshot.data['quest19'];
        _quest20.text = snapshot.data['quest20'];
      });
    });
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
        'quest01': _quest01,
        'quest02': _quest02,
        'quest03': _quest03,
        'quest04': _quest04,
        'quest05': _quest05,
        'quest06': _quest06,
        'quest07': _quest07,
        'quest08': _quest08,
        'quest09': _quest09,
        'quest00': _quest10,
        'quest11': _quest11,
        'quest12': _quest12,
        'quest13': _quest13,
        'quest14': _quest14,
        'quest15': _quest15,
        'quest16': _quest16,
        'quest17': _quest17,
        'quest18': _quest18,
        'quest19': _quest19,
        'quest20': _quest20.text,
      },
    );

    setState(() {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[300].withOpacity(0.9),
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
                              label:
                                  'Você tem alguma doença cardíaca descompensada?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest01,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest01 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Você tem doença cardíaca congênita?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest02,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest02 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você tem insuficiência cardíaca mal controlada?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest03,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest03 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você tem doença cardíaca isquêmica descompensada?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest04,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest04 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você tem alguma doença respiratória descompensada?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest05,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest05 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você tem asma ou doença pulmonar obstrutiva crônica (DPOC) mal controlado?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest06,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest06 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você tem alguma doenças pulmonar com complicações?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest07,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest07 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você tem fibrose cística com infecções recorrentes?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest08,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest08 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você tem displasia broncopulmonar com complicações?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest09,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest09 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Crianças prematuras com doença pulmonar crônica?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest10,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest10 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você tem alguma doença renal crônica em estágio avançado (graus 3, 4 e 5)?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest11,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest11 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você tem alguma doença cromossômica (por exemplo: Síndrome de Down)?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest12,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest12 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Você tem diabetes?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest13,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest13 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Se você está grávida, é gravidez de alto risco?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest14,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest14 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você tem alguma doença no fígado em estágio avançado?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest15,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest15 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você está obeso com IMC igual ou maior que 40?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest16,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest16 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Você faz diálise ou hemodiálise?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest17,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest17 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você já recebeu algum transplante de órgãos sólidos e de medula óssea ?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest18,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest18 = newValue;
                                });
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Você faz quimioterapia ou radioterapia?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest19,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _quest19 = newValue;
                                });
                              },
                            ),
                            inputForm(_quest20, "Outras doenças?",
                                Icons.local_hospital, TextInputType.text),
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
