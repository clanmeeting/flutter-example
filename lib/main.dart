import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'clanmeeting.dart';
import 'utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clan Meeting Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (BuildContext context) => const MyHomePage(),
        '/clanmeeting': (BuildContext context) => const ClanMeetingScreen(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _joinMeeting() async {
      const String domain = 'try.clanmeeting.com';
      const String consumerId = 'colacoca';
      String roomName = Utility.randomString(10);
      const String displayName = 'John Doe';

      final Map args = {
        'domain': domain,
        'consumerId': consumerId,
        'roomName': roomName,
        'displayName': displayName,
      };

      try {
        if (Platform.isAndroid) {
          await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(
              true);
        }
        // Initialize Flutter Downloader
        await FlutterDownloader.initialize(debug: false);
        FlutterDownloader.registerCallback(Utility.downloadCallback);

        // Request for camera and microphone permissions
        await Permission.camera.request();
        await Permission.microphone.request();

        // Navigate to meeting page
        Navigator.of(context).pushNamed('/clanmeeting', arguments: args);
      } catch (e) {
        Utility.showSnackBar(
            'There was a problem starting the meeting', context);
        debugPrint("error: $e");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Meeting Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // background
                onPrimary: Colors.white, // foreground
              ),
              onPressed: _joinMeeting,
              child: const Text('Join Meeting'),
            )
          ],
        ),
      ),
    );
  }
}
