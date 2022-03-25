import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final picker = ImagePicker();
  late File _image;
  bool _loading = false;
  late List _output;

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      // TODO: add some interactivity
    });
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  pickImage() async {
    // ignore: deprecated_member_use
    var image = await picker.getImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  pickGalleryImage() async {
    // ignore: deprecated_member_use
    var image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _loading = false;
      _output = output!;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clean OR Messy"),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _GroupText('Choose source:'),
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    buttonMinWidth: 150,
                    layoutBehavior: ButtonBarLayoutBehavior.padded,
                    buttonPadding: EdgeInsets.symmetric(vertical: 10),
                    children: <Widget>[
                      RaisedButton(
                        onPressed: pickImage,
                        child: Text('Cam'),
                      ),
                      SizedBox(width: 20),
                      RaisedButton(
                        onPressed: pickGalleryImage,
                        child: Text('Gallery'),
                      ),
                    ],
                  )
                ],
              ),
              _SpaceLine(),
              // Image
              Center(
                child: _loading
                    ? Container(
                        width: 300,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 50),
                            Image.asset('assets/room.png'),
                          ],
                        ),
                      )
                    : Container(
                        child: Column(
                        children: <Widget>[
                          _output != null
                              ? Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text('${_output[0]['label']}',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 20.0)),
                                )
                              : Container(),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 250,
                            child: Image.file(_image),
                          ),
                        ],
                      )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupText extends StatelessWidget {
  final String text;
  const _GroupText(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Text(
        text,
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _SpaceLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5,
      child: Container(
        color: Colors.grey,
      ),
    );
  }
}
