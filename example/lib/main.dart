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
  double _counter = 0;
  List<String> filelist = [];
  late File? downloadedFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadedFile = null;
  }

  void downloadFile() async {
    final dynamicAssets = DynamicAssets();
    if (await dynamicAssets.checkIfFileExists(null, 'alphabets.zip') == false) {
      await DynamicAssets().downloadAssets(
          "https://raw.githubusercontent.com/sabine33/flutter_dynamic_assets/master/alphabets.zip",
          null,
          'alphabets.zip', onReceiveProgress: (downloaded, total) {
        // print(downloaded);
        setState(() {
          _counter += (downloaded / total) * 100;
        });
      });
      await dynamicAssets.extractZip(null, 'alphabets.zip');
      var filename = await dynamicAssets.getDownloadedContentPath(
          null, 'alphabets/1_kalama.png');
      downloadedFile = File(filename);
    } else {
      print("File already exists");
    }
    filelist = (await dynamicAssets.getAllFiles(null, '', false))
        .map((e) => e.path)
        .toList();
    print(filelist);
    filelist.sort((a, b) => b.compareTo(a));
    setState(() {});

    // print("Download complete");
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
            LinearProgressIndicator(
              value: _counter,
            ),
            downloadedFile != null
                ? Image.file(downloadedFile!)
                : CircularProgressIndicator(),
            Expanded(
              child: filelist.length > 0
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              childAspectRatio: 3 / 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20),
                      itemCount: filelist.length,
                      itemBuilder: (context, index) {
                        return Image.file(File(filelist[index]));
                      })
                  : Container(),
            )
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
