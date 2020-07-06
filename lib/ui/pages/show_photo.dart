import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ShowPhotoPage extends StatefulWidget {
  final Map data;

  ShowPhotoPage(@required this.data); 

  @override
  _ShowPhotoPageState createState() => _ShowPhotoPageState(data);
}

class _ShowPhotoPageState extends State<ShowPhotoPage> {

  final Map data;
  String userName = '';
  String photoUrl = '';

  _ShowPhotoPageState(
    this.data,
  );

  @override
  void initState() {
    super.initState();
    userName = data['name'];
    photoUrl = data['photoUrl'];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(userName),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            child:  Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 5.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                      ),
                      imageUrl: photoUrl,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                    clipBehavior: Clip.hardEdge,
                  )
        ),
      ),
    ));
  }
}