import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

User userFromJson(String str) {
  final jsonData = json.decode(str);
  return User.fromJson(jsonData);
}

String userToJson(User data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class User {
  String alternativePhone;
  String institutionName;
  String addressNum;
  String birthday;
  String photoUrl;
  String userId;
  String email;
  String phone;
  String name;
  String cep;
  String cpf;
  String rg;

  User({
    this.alternativePhone,
    this.institutionName,
    this.addressNum,
    this.birthday,
    this.photoUrl,
    this.userId,
    this.email,
    this.phone,
    this.name,
    this.cep,
    this.cpf,
    this.rg,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        alternativePhone: json["alternativePhone"],
        institutionName: json["institutionName"],
        addressNum: json["addressNum"],
        birthday: json["birthday"],
        photoUrl: json["photoUrl"],
        userId: json["userId"],
        email: json["email"],
        phone: json["phone"],
        name: json["name"],
        cep: json["cep"],
        cpf: json["cpf"],
        rg: json["rg"],
      );

  Map<String, dynamic> toJson() => {
        "alternativePhone": alternativePhone,
        "institutionName": institutionName,
        "addressNum": addressNum,
        "birthday": birthday,
        "photoUrl": photoUrl,
        "userId": userId,
        "email": email,
        "phone": phone,
        "name": name,
        "cep": cep,
        "cpf": cpf,
        "rg": rg,
      };

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }
}
