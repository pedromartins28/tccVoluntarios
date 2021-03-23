import 'package:voluntario/models/chechLabel.dart';
import 'package:voluntario/ui/widgets/forms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voluntario/models/user.dart';
import 'package:flutter/material.dart';
import 'package:voluntario/util/validator.dart';

class InfosPage extends StatefulWidget {
  final Map request;
  InfosPage({@required this.request});

  _InfosPageState createState() => _InfosPageState();
}

class _InfosPageState extends State<InfosPage> {
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
      _quest13 = false;

  final TextEditingController _allergyText = TextEditingController();
  final TextEditingController _medicText = TextEditingController();

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

    _db.collection('requestsMedic').document(requestId).get().then((snapshot) {
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
        _allergyText.text = snapshot.data['allergyText'];
        _medicText.text = snapshot.data['medicText'];
        if (_allergyText.text == 'Possui Alergia? Qual?') {
          _allergyText.text = 'Sem alergias.';
        }
        if (_medicText.text == 'Está usando algum medicamento? Qual?') {
          _medicText.text = 'Sem medicamentos.';
        }
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
        read: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[300].withOpacity(0.9),
      appBar: AppBar(
        title: Text(
          "Informações Médicas",
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
                              label: 'Você está com febre acima de 37,8°C?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest01,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Você está tossindo?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest02,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você está espirrando, com o nariz escorrendo ou com nariz entupido?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest03,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você está com dificuldade para respirar, ou a respiração está\n ofegante?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest04,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Você está com dor de garganta?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest05,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você está com dor ou sentindo pressão no peito?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest06,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Você está com arrepios ou com calafrios?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest07,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Você está com dor muscular?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest08,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Em crianças: batimento da asa do nariz?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest09,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você está com dificuldade em sentir cheiros?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest10,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Você está com diarreia?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest11,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            LabeledCheckbox(
                              label:
                                  'Você está com os lábios ou a face arroxeados?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest12,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            LabeledCheckbox(
                              label: 'Você acha que está com confusão mental?',
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                              value: _quest13,
                              onChanged: (bool newValue) {
                                setState(() {});
                              },
                            ),
                            inputForm(_medicText, "Usando algum medicamento?",
                                Icons.local_hospital, TextInputType.text),
                            inputForm(_allergyText, "Alguma alergia?",
                                Icons.local_hospital, TextInputType.text),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        endIndent: 8.0,
                        indent: 8.0,
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
