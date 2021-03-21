import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voluntario/ui/widgets/dot_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voluntario/models/state.dart';
import 'package:voluntario/util/state_widget.dart';
import 'dart:async';

class ChatPage extends StatefulWidget {
  final Map request;

  ChatPage({@required this.request});

  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController listScrollController = ScrollController();
  final Firestore _db = Firestore.instance;
  bool _visible = false;
  String donorName;
  String requestId;
  String pickerId;
  String donorId;
  String occupation;
  Map request;
  StateModel appState;

  @override
  void initState() {
    initializeIds();
    getDonorName();
    super.initState();
  }

  initializeIds() {
    request = widget.request;
    requestId = request['requestId'];
    pickerId = request['pickerId'];
    donorId = request['donorId'];
  }

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  _disconnectedDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          content: Container(
            padding: EdgeInsets.all(8.0),
            width: 318.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.grey,
                    size: 64.0,
                  ),
                  margin: EdgeInsets.only(bottom: 8.0),
                ),
                Text(
                  "SEM CONEXÃO",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.0),
                Text(
                  "Não foi possível enviar a mensagem",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> callback() async {
    if (await _verifyConnection(context)) {
      if (messageController.text.length > 0) {
        _db
            .collection(occupation)
            .document(requestId)
            .collection('messages')
            .document()
            .setData({
          'text': messageController.text,
          'from': pickerId,
          'to': donorId,
          'date': Timestamp.fromMillisecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch),
          'sentBydonor': false,
          'requestId': requestId
        }).then((onValue) {
          _db
              .collection('donors')
              .document(donorId)
              .updateData({'chatNotification': FieldValue.increment(1)});
        }).catchError((error) {});
        messageController.clear();
        listScrollController.animateTo(0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      _disconnectedDialog();
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    }
  }

  Future<bool> _verifyConnection(BuildContext context) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {}
      return true;
    } on SocketException catch (_) {
      return false;
    }
  }

  getDonorName() {
    _db.collection('donors').document(donorId).get().then((snapshot) {
      setState(() {
        donorName = snapshot.data['name'];
      });
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          _visible = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    occupation = appState.user.occupation;
    _db
        .collection(occupation)
        .document(requestId)
        .updateData({'pickerChatNotification': 0});

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  await SystemChannels.textInput.invokeMethod('TextInput.hide');
                  Navigator.of(context).pop();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          title: donorName == null
              ? FadingText(
                  '. . . .',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : AnimatedOpacity(
                  child: Text(donorName),
                  opacity: _visible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                ),
          centerTitle: true,
        ),
        body: StreamBuilder(
            stream: _db
                .collection(occupation)
                .where('donorId', isEqualTo: donorId)
                .where('state', isEqualTo: 2)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return JumpingText(
                  ". . .",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).primaryColor,
                  ),
                );
              } else {
                if (snapshot.data.documents.isEmpty) {
                  return Center(
                    child: Text(
                      "Essa solicitação não está disponível.",
                    ),
                  );
                } else {
                  return Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Expanded(
                            child: StreamBuilder(
                                stream: Firestore.instance
                                    .collection(occupation)
                                    .document(requestId)
                                    .collection('messages')
                                    .orderBy('date', descending: true)
                                    .limit(20)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return JumpingText(
                                      ". . .",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    );
                                  else {
                                    return ListView.builder(
                                      reverse: true,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: snapshot.data.documents.length,
                                      itemBuilder: (context, index) => Message(
                                        when: snapshot.data.documents[index]
                                            ['date'],
                                        text: snapshot.data.documents[index]
                                            ['text'],
                                        me: pickerId ==
                                            snapshot.data.documents[index]
                                                ['from'],
                                      ),
                                      controller: listScrollController,
                                    );
                                  }
                                }),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 6.0),
                            color: Colors.grey.shade200,
                            width: double.infinity,
                            height: 54,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    onSubmitted: (value) => callback(),
                                    controller: messageController,
                                    decoration: InputDecoration.collapsed(
                                      hintText: 'Digite aqui...',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                  ),
                                ),
                                IconButton(
                                  onPressed: callback,
                                  icon: Icon(
                                    Icons.send,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              }
            }));
  }
}

class Message extends StatelessWidget {
  final String text;
  final Timestamp when;
  final bool me;

  const Message({Key key, this.when, this.text, this.me}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.fromLTRB(me ? 72.0 : 12.0, 4.0, me ? 12.0 : 72.0, 4.0),
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: me
                  ? Theme.of(context).primaryColor.withAlpha(150)
                  : Colors.grey.withAlpha(50),
            ),
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
            child: Text(
              text,
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            _getDateInString(when),
            style: TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  String _getDateInString(Timestamp when) {
    String weekDay;
    String hour;
    switch (when.toDate().weekday) {
      case 1:
        weekDay = "Seg";
        break;
      case 2:
        weekDay = "Ter";
        break;
      case 3:
        weekDay = "Qua";
        break;
      case 4:
        weekDay = "Qui";
        break;
      case 5:
        weekDay = "Sex";
        break;
      case 6:
        weekDay = "Sab";
        break;
      case 7:
        weekDay = "Dom";
        break;
    }
    hour = when.toDate().toString().substring(11, 16);

    return weekDay + " - " + hour;
  }
}
