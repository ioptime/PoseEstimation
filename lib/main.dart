import 'dart:core' as prefix0;
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

import 'MyInheritedWidget.dart';
import 'RecognizeData.dart';

void main() => runApp(PoseEstimationApp());
// Constants
const String posenet = "PoseNet";

class PoseEstimationApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StateContainer(
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  List _recognitions;
  String _model = posenet;
  double _imageHeight;
  double _imageWidth;
  bool _busy = false;
  RecognizeData recognizeData;


  Future getImageFromGallery() async {
    print("getImageFromGallery()");
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _busy = true;
    });
    debugPrint('image path: $image');
    predictImage(image);
  }

  Future predictImage(File image) async {
    debugPrint('Present in predictImage(File image)');
    if (image == null) return;

    debugPrint('File image $image');
    debugPrint('_model:: $_model');
    await poseNet(image);

    new FileImage(image)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));
    setState(() {
      _image = image;
      _busy = false;
    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint("Present in initState()");

    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  Future loadModel() async {
    debugPrint('Present in Future loadModel() async');
    Tflite.close();
    /*try {*/
      String res;
      res = await Tflite.loadModel(
          model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
      print('res: $res');

    /*} on PlatformException {
      print('Failed to load model.');
    }*/
  }

  Future poseNet(File image) async {
    debugPrint('poseNet(File image)  ::  Present');
    var recognitions = await Tflite.runPoseNetOnImage(
      path: image.path,
      numResults: 2,
    );
    print('recognitions  $recognitions');

    //print(recognitions);

    setState(() {
      _recognitions = recognitions;
    });
    submitRecognizeDetail(image);
  }

  submitRecognizeDetail(File imagePath){
    debugPrint('Present in submitRecognizeDetail() method');
    final myInheritedWidget = StateContainer.of(context);
    myInheritedWidget.updateRecognitionInfo(
        imagePath: imagePath
    );
  }


  ///********************************    Build Method Start   ******************************************/
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    final myInheritedWidget= StateContainer.of(context);
    debugPrint('myInheritedWidget contain:   $myInheritedWidget');
    recognizeData = myInheritedWidget.recognizeData;

    /*List<CityCard> cityCards = [
      CityCard("assets/images/athens.jpg"*//*,"Feb 2019","45", "4299", "3299"*//*),
      //CityCard("assets/images/lasvegas.jpg","Feb 2018","65", "4299", "3299"),
      //CityCard("assets/images/sydney.jpeg","Feb 2017","30", "4299", "3299"),
    ];*/


    if(_model == posenet){
      debugPrint('Yes model is POSENET');

      /*stackChildren.add(
        Positioned(
          top: 10.0,
          left: 15.0,
          child: _image == null ? Text('No image selected.') : Image.file(_image),
        ),
      );*/
    }

    stackChildren.add(Positioned(
      top: 55.0,
      left: 0.0,
      width: size.width,
        child:  recognizeData != null
            ? Image.file(recognizeData.uploadedImagePath)
            : Image.asset("assets/images/demo.png", fit: BoxFit.cover,),
    ));

    stackChildren.addAll(renderKeypoints(size));
    /*stackChildren.add(
        Padding(
          padding: const EdgeInsets.only(top: 48.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 66.0,vertical: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: 355,
                            width: 280,
                            child:  recognizeData != null
                                ? Image.file(recognizeData.uploadedImagePath)
                                : Image.asset("assets/images/athens.jpg", fit: BoxFit.cover,),
                            //child: Image.asset(imagePath, fit: BoxFit.cover,),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );*/
    //stackChildren.add(Center(child: Text('Pose Estimation', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),),));


    return Scaffold(
      backgroundColor: Color(0xFF21BFBD),
              body: ListView(
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Column(
                        children: <Widget>[
                          Text('IOPTIME',
                            style: TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25.0,),
                          ),
                          Text('Every Customer Every Day', style: TextStyle(fontFamily: 'Montserrat',color: Colors.white, fontSize: 15.0),),
                          SizedBox(height: 10.0,),
                          GestureDetector(
                            onTap: (){
                              debugPrint('Upload Image button clicked');
                              getImageFromGallery();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(
                                    Icons.camera,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  Text(
                                    'Upload Image',
                                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0,),
                  /*Container(
                    child: Stack(
                      children: stackChildren,
                    ),
                  ),*/
                  Container(
                      height: MediaQuery.of(context).size.height - 185.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)/*,topRight: Radius.circular(75.0)*/),
                      ),
                        child: Stack(
                          children: stackChildren,
                        ),
                  ),
                ],
              ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          getImageFromGallery();
        },
        child: Icon(Icons.navigation),
        backgroundColor: Colors.green,
      ),*/
    );
  }
  ///********************************    Build Method End   ******************************************/

  List<Widget> showImageWidget(){
    var lists = <Widget>[];
    //lists..addAll();
    return lists;
  }
  List<Widget> renderKeypoints(Size screen) {
    debugPrint("Present in renderKeypoints");
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;

    var lists = <Widget>[];
    _recognitions.forEach((re) {
      var color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(1.0);
      var list = re["keypoints"].values.map<Widget>((k) {
        return Positioned(
          left: k["x"] * factorX - 6,
          top: k["y"] * factorY - 6,
          width: 100,
          height: 12,
          child: Container(
            child: Text(
              "● ${k["part"]}",
              style: TextStyle(
                color: color,
                fontSize: 12.0,
              ),
            ),
          ),
        );
      }).toList();
      lists..addAll(list);
    });
    return lists;
  }
}

class CityCard extends StatelessWidget {
  final String imagePathString/*,imagePathFile*//*,  monthYear, discount, oldPrice, newPrice*/;
  //RecognizeData recognizeData;
  //bool isImagePath;
  RecognizeData recognizeData;
  CityCard(this.imagePathString/*,this.imagePathFile,this.isImagePath*//*,this.monthYear, this.discount, this.oldPrice, this.newPrice*/);

  @override
  Widget build(BuildContext context) {
    debugPrint("Present in build method of CityCard");

    final myInheritedWidget= StateContainer.of(context);
    debugPrint('myInheritedWidget contain:   $myInheritedWidget');
    recognizeData = myInheritedWidget.recognizeData;


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 66.0,vertical: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            child: Stack(
              children: <Widget>[
                Container(
                    height: 250,
                    width: 220,
                    child:  recognizeData != null
                        ? Image.file(recognizeData.uploadedImagePath)
                        : Image.asset(imagePathString, fit: BoxFit.cover,),
                  //child: Image.asset(imagePath, fit: BoxFit.cover,),
                ),
                /*Positioned(
                  left: 0.0,
                  bottom: 0.0,
                  width: 280.0,
                  height: 90.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black, Colors.black.withOpacity(0.1)
                          ]
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10.0,
                  bottom: 10.0,
                  right: 5.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                         ],
                      ),
                    ],
                  ),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}

