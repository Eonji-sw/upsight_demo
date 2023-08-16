import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';

import 'login_secure.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  File? imageFile;
  late List<Map<String, dynamic>> yoloResults;
  late FlutterVision vision;
  int imageHeight = 1;
  int imageWidth = 1;
  bool isLoaded = false;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    vision = FlutterVision();
      loadYoloModel().then((value) {
        setState(() {
          isLoaded = true;
          isDetecting = false;
          yoloResults = [];
        });
      });
  }

  @override
  void dispose() async {
    super.dispose();
    await vision.closeYoloModel();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
      yoloOnImage();

    }
  }

  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
        labels: 'assets/label/label_crack.txt',
        modelPath: 'assets/best_float16.tflite',
        modelVersion: "yolov8",
        numThreads: 2,
        useGpu: false);
    setState(() {
      isLoaded = true;
    });
  }

/*  Future <void> getImage() async {
    final picker = ImagePicker();
    final List<File> _images = [];
    final List<XFile> images = await picker.pickMultiImage();
    if (images != null) {
      images.forEach((e) {
        _images.add(File(e.path));
      });
      logger.d("getImage: $_images");
    }
    setState(() {
      _selectedImage = File(images[0].path);
    });
    getResult();
  }*/

/*  getResult() async {
    FlutterVision vision = FlutterVision();
    await vision.loadYoloModel(
        labels: 'assets/labels.txt',
        modelPath: 'assets/yolov5n.tflite',
        modelVersion: "yolov5",
        numThreads: 1,
        useGpu: false).then((value){
          yoloResults=[];
    });
    logger.d(vision);
  }*/

  yoloOnImage() async {
    yoloResults.clear();
    Stopwatch stopwatch = Stopwatch()..start();
    Uint8List byte = await imageFile!.readAsBytes();
    final image = await decodeImageFromList(byte);
    imageHeight = image.height;
    imageWidth = image.width;
    final result = await vision.yoloOnImage(
        bytesList: byte,
        imageHeight: image.height,
        imageWidth: image.width,
        iouThreshold: 0.8,
        confThreshold: 0.4,
        classThreshold: 0.5);
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
      logger.d(yoloResults);
      stopwatch.stop();
      logger.d('time elapsed ${stopwatch.elapsed}');
    }
  }

  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
    });
    (isDetecting) {
        yoloOnImage();
      };
  }
  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];

    double factorX = screen.width / (imageWidth);
    double imgRatio = imageWidth / imageHeight;
    double newWidth = imageWidth * factorX;
    double newHeight = newWidth / imgRatio;
    double factorY = newHeight / (imageHeight);

    double pady = (screen.height - newHeight) / 2;

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);
    logger.d("$factorX $factorY");
    return yoloResults.map((result) {
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY + pady,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }
/*
  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    double? factorX;
    double? factorY;
    if (yoloResults.isEmpty) return [];
    decodeImageFromList(imageFile!.readAsBytesSync())
    .then((decodedImage){
      factorX = screen.width / (decodedImage.width ?? 1);
      factorY = screen.height / (decodedImage.height ?? 1);
    });
    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return yoloResults.map((result) {
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }
}*/



  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        imageFile != null ? Image.file(imageFile!) : const SizedBox(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _pickImage,
                child: const Text("Pick image"),
              ),
              ElevatedButton(
                onPressed: yoloOnImage,
                child: const Text("Detect"),
              )
            ],
          ),
        ),
        ...displayBoxesAroundRecognizedObjects(size),
      ],
    );
  }
/*  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageFile == null
                ? Text('No Image Selected')
                : Image.file(imageFile!), //load image if uploaded
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
            ),
            ...displayBoxesAroundRecognizedObjects(size),
          ],
        ),
      ),
    );
  }*/
}

