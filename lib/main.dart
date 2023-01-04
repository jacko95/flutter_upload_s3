import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/src/media_type.dart';

final ImagePicker _imagePicker = ImagePicker();

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String image;

  Future<XFile> selectImage() async {
    final XFile selected = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (selected.path.isEmpty) {
      print(selected.path.toString());
      // _imageList.add(selected);
    }
    // setState(() {
    //   // _image = File(pickedImage.path);
    //   _imageList.add(selected);
    // });
    return selected;
  }

  Future uploadImage(/*XFile _image*/) async {
    XFile _image = await selectImage();

    String imageName = _image.path.split('/').last;
    // List<int> imageBytes = File(filePath.path).readAsBytesSync();

    var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://192.168.1.225:4500/upload")
    );

    String imageMimeType = lookupMimeType(_image.path);
    print('imageMimeType');
    print(imageMimeType);

    request.files.add(
        await http.MultipartFile.fromPath(
            'image',
            // imageFilePath,
            _image.path,
            filename: '${imageName.split('image_picker').last}',
            // contentType: new MediaType('image', 'jpeg')
            // contentType: new MediaType('image', 'png')
            contentType: MediaType(
                imageMimeType.split('/').first,
                imageMimeType.split('/').last
            )
        )
    );
    // request.files.add(
    //   http.MultipartFile.fromBytes(
    //     'image',
    //     _imageFile.readAsBytesSync(),
    //     filename: '$imageName',
    //     // contentType: new MediaType('image', 'jpeg')
    //     contentType: new MediaType('image', 'png')
    //     // contentType: new MediaType('image', 'jpg')
    //   )
    // );

    // http.MultipartFile.fromString(
    //   'image',
    //   _imageFile.path,
    //   filename: '$imageName',
    // );

    request.headers.addAll({
      'Accept': '*/*',
      'Content-Type': 'multipart/form-data',
      'Accept-encoding': 'gzip',
    });
    // request.headers['Content-Type'] = 'multipart/form-data';
    // request.headers['Accept'] = '*/*';
    // request.headers['Accept-encoding'] = 'gzip';
    // request.fields['file'] = name;


    request.fields['user_id'] = '11';
    var res = await request.send();
    if(res.statusCode == 200){

    }
    var g = await res.stream.bytesToString();
    print('res.statusCode');
    print(res.statusCode);
    print('res.stream.bytesToString()');
    // print(await res.stream.bytesToString());
    print(json.decode(g)['Location']);

    setState(() {
      image = json.decode(g)['Location'];
    });
    // return res.statusCode;
    return json.decode(g)['Location'];
  }

  Future<void> _incrementCounter() async {
    await uploadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Image.network(
              image ?? '',
              height: MediaQuery.of(context).size.height * 0.7,
              errorBuilder: (context, a, b) => Container(
                color: Colors.grey[300],
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.7,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Carica',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
