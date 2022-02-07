import 'dart:io';

import 'package:dynamic_assets/dynamic_assets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late File? downloadedFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadedFile = null;
  }

  void downloadFile() async {
    await DynamicAssets().downloadAssets(
        "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-zip-file.zip", //"https://github.com/sabine33/flutter_dynamic_assets/blob/master/assets.zip?raw=true",
        null,
        'assets.zip', onReceiveProgress: (downloaded, total) {
      print(downloaded);
      setState(() {
        _counter += downloaded;
      });
    });
    print("Download complete");

    await DynamicAssets().extractZip(null, 'assets.zip');
  }

  void getPermission() async {
    // await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            downloadedFile != null
                ? Image.file(downloadedFile!)
                : CircularProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: downloadFile,
        tooltip: 'Download',
        child: const Icon(Icons.download),
      ),
    );
  }
}
