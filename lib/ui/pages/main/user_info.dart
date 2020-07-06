import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:voluntario/util/image_picker_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voluntario/models/user.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:smooth_star_rating/smooth_star_rating.dart';

class UserInfoPage extends StatefulWidget {
  UserInfoPage({Key key}) : super(key: key);

  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage>
    with TickerProviderStateMixin, ImageHandlerListener {
  SharedPreferences prefs;
  String photoUrl = '';
  String userId = '';
  User user;
  bool isLoading = false;
  ImageHandler imagePicker;

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    user = userFromJson(prefs.getString('user'));
    photoUrl = user.photoUrl;
    userId = user.userId;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    readLocal();

    imagePicker = ImageHandler(this, this.context);
  }

  @override
  userImage(File _image) {
    if (_image != null) uploadFile(_image);
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

  Future uploadFile(File file) async {
    String fileName = userId;
    setState(() {
      isLoading = true;
    });
    if (await _verifyConnection()) {
      try {
        StorageReference reference =
            FirebaseStorage.instance.ref().child(fileName);
        StorageUploadTask uploadTask = reference.putFile(file);
        StorageTaskSnapshot storageTaskSnapshot;
        uploadTask.onComplete.then((value) {
          if (value.error == null) {
            storageTaskSnapshot = value;
            storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
              photoUrl = downloadUrl;
              print("Download Url: " + photoUrl);
              print("userId before download: " + userId);
              Firestore.instance
                  .collection('pickers')
                  .document(userId)
                  .updateData({'photoUrl': photoUrl}).then((data) async {
                Flushbar(
                  message: "Foto Atualizada com sucesso",
                  duration: Duration(seconds: 3),
                  isDismissible: false,
                )..show(context);
                setState(() {
                  isLoading = false;
                });
              }).catchError((err) {
                Flushbar(
                  title: "Erro na gravacao do banco.",
                  message: err.toString(),
                  duration: Duration(seconds: 3),
                  isDismissible: false,
                )..show(context);
                setState(() {
                  isLoading = false;
                });
              });
            }, onError: (err) {
              Flushbar(
                message: "Erro no link de Download do Firebase Storage.",
                duration: Duration(seconds: 3),
                isDismissible: false,
              )..show(context);
              setState(() {
                isLoading = false;
              });
            });
          } else {
            Flushbar(
              title: "Erro ao gravar o imagem na nuvem",
              message: "O arquivo pode não ser uma Imagem.",
              duration: Duration(seconds: 3),
              isDismissible: false,
            )..show(context);
            setState(() {
              isLoading = false;
            });
          }
        });
      } catch (e) {
        Flushbar(
          title: "Problema na Conexao",
          message: "Sua foto pode não ter sido atualizada.",
          duration: Duration(seconds: 3),
          isDismissible: false,
        )..show(context);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user != null)
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Perfil do Usuário",
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.vpn_key),
              onPressed: () async {
                Navigator.pushNamed(context, '/change_pass');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              StreamBuilder(
                stream: Firestore.instance
                    .collection('pickers')
                    .where('userId', isEqualTo: userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    User user = User.fromDocument(snapshot.data.documents[0]);
                    photoUrl = user.photoUrl;
                    return Column(
                      children: <Widget>[
                        SizedBox(height: 8.0),
                        Container(
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: photoUrl != null
                                    ? !isLoading
                                        ? Material(
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 5.0,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Theme.of(context)
                                                              .primaryColor),
                                                ),
                                                width: 120.0,
                                                height: 120.0,
                                              ),
                                              imageUrl: photoUrl,
                                              width: 120.0,
                                              height: 120.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(60.0)),
                                            clipBehavior: Clip.hardEdge,
                                          )
                                        : Container(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 5.0,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Theme.of(context)
                                                          .primaryColor),
                                            ),
                                            height: 120,
                                            width: 120,
                                          )
                                    : !isLoading
                                        ? Icon(
                                            Icons.account_circle,
                                            size: 138.0,
                                            color: Colors.grey,
                                          )
                                        : Container(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 5.0,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).primaryColor,
                                              ),
                                            ),
                                            height: 120,
                                            width: 120,
                                          ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: 48.0,
                                  height: 48.0,
                                  margin: EdgeInsets.only(right: 112.0),
                                  child: FloatingActionButton(
                                    heroTag: null,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () async {
                                      showModalBottomSheet(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(15.0)),
                                        ),
                                        context: context,
                                        builder: (context) => Container(
                                          child: Wrap(
                                            children: <Widget>[
                                              ListTile(
                                                  leading: Icon(
                                                    Icons.photo,
                                                  ),
                                                  title: Text('Galeria'),
                                                  onTap: () {
                                                    imagePicker.openGallery();
                                                    Navigator.of(context).pop();
                                                  }),
                                              ListTile(
                                                leading: Icon(
                                                  Icons.camera_alt,
                                                ),
                                                title: Text('Câmera'),
                                                onTap: () {
                                                  imagePicker.openCamera();
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(
                                                  Icons.close,
                                                ),
                                                title: Text('Cancelar'),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          height: 124.0,
                          width: double.infinity,
                          margin: EdgeInsets.all(18.0),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                snapshot.data.documents[0]['rating']
                                    .toDouble()
                                    .toStringAsFixed(2),
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 18.0),
                              ),
                              Icon(
                                Icons.star,
                                color: Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            user.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 22.0,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            user.institutionName,
                            style: TextStyle(
                              fontWeight: FontWeight.w200,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          endIndent: 8.0,
                          indent: 8.0,
                        ),
                        dataUnit("E-mail", user.email),
                        dataUnit(
                            "Coletas Finalizadas",
                            snapshot.data.documents[0]['finishedRequests']
                                .toString()),
                        dataUnit("CPF", user.cpf),
                        dataUnit("RG", user.rg),
                        dataUnit("Telefone", user.phone),
                        dataUnit("Telefone Alternativo", user.alternativePhone),
                        dataUnit("CEP", user.cep),
                        dataUnit("Número da casa", user.addressNum),
                        dataUnit("Data de Nascimento", user.birthday),
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
    else
      return Center(
        child: Container(
          child: CircularProgressIndicator(
            strokeWidth: 5.0,
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          width: 120.0,
          height: 120.0,
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
