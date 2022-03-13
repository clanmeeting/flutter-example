import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock/wakelock.dart';

import 'utils.dart';

class ClanMeetingScreen extends StatefulWidget {
  const ClanMeetingScreen({Key? key}) : super(key: key);

  @override
  _ClanMeetingScreenState createState() => _ClanMeetingScreenState();
}

class _ClanMeetingScreenState extends State<ClanMeetingScreen> {
  InAppLocalhostServer localhostServer = InAppLocalhostServer();
  final GlobalKey _webViewKey = GlobalKey();
  bool isLoading = true;

  // disable navigation pop while meeting is in progress
  bool canGoBack = false;

  // webview options
  final InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: Platform.isIOS
          ? InAppWebViewOptions(
              allowUniversalAccessFromFileURLs: true,
              clearCache: true,
              javaScriptCanOpenWindowsAutomatically: true,
              mediaPlaybackRequiresUserGesture: false,
              transparentBackground: true,
              userAgent:
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 15_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.2 Mobile/15E148 Safari/604.1',
            )
          : InAppWebViewOptions(
              allowUniversalAccessFromFileURLs: true,
              clearCache: true,
              javaScriptCanOpenWindowsAutomatically: true,
              mediaPlaybackRequiresUserGesture: false,
              transparentBackground: true,
            ),
      android: AndroidInAppWebViewOptions(
        supportMultipleWindows: true,
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  void initState() {
    super.initState();
    _startLocalServer();
    // The following line will enable the Android and iOS wakelock.
    Wakelock.enable();
    _initializeFlutterDownloader();
  }

  _startLocalServer() async {
    await localhostServer.start();
  }

  _initializeFlutterDownloader() async {
    if (Platform.isAndroid) {
      // enable for debugging if needed
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(false);
    }

    // Initialize Flutter Downloader
    await FlutterDownloader.initialize(debug: false);
    FlutterDownloader.registerCallback(Utility.downloadCallback);
  }

  @override
  void dispose() {
    localhostServer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // get arguments from join meeting screen
    final Map _args = ModalRoute.of(context)?.settings.arguments as Map;

    // convert the arguments into query parameters to be passed into URL
    final String _queryString = Uri(
        queryParameters:
            _args.map((key, value) => MapEntry(key, value?.toString()))).query;

    // You can also host this file on a remote server
    final clanMeetingURL = URLRequest(
        url: Uri.parse(
            'http://localhost:8080/assets/clanmeeting.html?$_queryString'));

    return SafeArea(
      child: Scaffold(
        // required so that keyboard does not hide the visible screen
        resizeToAvoidBottomInset: true,
        body: WillPopScope(
          onWillPop: () async => canGoBack,
          child: Column(children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    key: _webViewKey,
                    initialUrlRequest: clanMeetingURL,
                    initialOptions: options,
                    onConsoleMessage: (controller, consoleMessage) {
                      debugPrint(consoleMessage.toString());
                    },
                    onWebViewCreated: (controller) {
                      setState(() {
                        isLoading = false;
                      });
                      // register a JavaScript handler and search for this handler name
                      // in the clanmeeting-flutter.html file to understand how you can call
                      // a flutter handler in response to a JavaScript meeting event.
                      // This one triggers when a local participant leaves the call.
                      controller.addJavaScriptHandler(
                          handlerName: 'flutterEndCallHandler',
                          callback: (data) async {
                            // data has arguments coming from the JavaScript side!
                            setState(() {
                              canGoBack = true;
                              Wakelock.disable();
                            });
                            debugPrint(
                                'Data coming from Javascript side: $data');
                            // ADD YOUR CUSTOM LOGIC HERE
                            Navigator.pop(context);
                          });
                    },
                    androidOnPermissionRequest:
                        (controller, origin, resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },
                    onLoadError: (controller, url, code, message) {
                      debugPrint('Load error');
                    },
                    onCreateWindow: (controller, onCreateWindowRequest) =>
                        _onCreateWindow(onCreateWindowRequest),
                  ),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<bool> _onCreateWindow(CreateWindowAction onCreateWindowRequest) async {
    try {
      final uri = onCreateWindowRequest.request.url;

      if (uri != null && !uri.toString().contains('files.clanmeeting.com')) {
        await Utility.launchURL(uri.toString());
        return false;
      }

      // open javascript and file sharing links within app in a second webview
      final InAppWebViewGroupOptions options2 = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useOnDownloadStart: true,
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
      );

      // we need to wait for the URL to load first
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(0.0),
            content: SizedBox(
              width: 0,
              height: 0,
              child: Column(children: <Widget>[
                Expanded(
                  child: InAppWebView(
                    windowId: onCreateWindowRequest.windowId,
                    initialOptions: options2,
                    onConsoleMessage: (controller, consoleMessage) {
                      debugPrint(consoleMessage.toString());
                    },
                    onLoadStop: (controller, uri) {},
                    onDownloadStart: (controller, url) {
                      _onFileDownload(url, dialogContext);
                    },
                  ),
                ),
              ]),
            ),
          );
        },
      );
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  // customize what happens when shared file download starts
  void _onFileDownload(Uri uri, BuildContext dialogContext) async {
    final savedDir = await getExternalStorageDirectory();
    if (savedDir != null) {
      await FlutterDownloader.enqueue(
        url: uri.toString(),
        savedDir: savedDir.path,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );
      Navigator.pop(dialogContext);
      Utility.showAlertBox(
          title: 'File Downloaded!',
          context: context,
          onPressedFunction: () => {Navigator.pop(context)});
    }
  }
}
