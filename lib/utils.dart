import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:url_launcher/url_launcher.dart';

/// Define global constants here
class Constants {
  static const double height = 20.0;
  static const double padding = 20.0;
}

/// Set of tiny functions useful throughout the app
class Utility {
  /// From url_launcher package
  static Future<void> launchURL(String url) async {
    await canLaunch(url);
    await launch(url);
  }

  /// Shows a snackbar usually to display error messages
  static void showSnackBar(String message, BuildContext context) {
    if (message.isNotEmpty) {
      final snackBar = SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  /// Simple alert dialog to display important messages
  static void showAlertBox({
    required String title,
    String buttonText = 'OK',
    required BuildContext context,
    required void Function() onPressedFunction,
    TextStyle? titleTextStyle,
    bool scrollable = false,
  }) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        Widget alertDialog() {
          return AlertDialog(
              title: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: Constants.height),
                  child: Center(
                    child: Text(title,
                        style: titleTextStyle ??
                            Theme.of(context).textTheme.bodyText2),
                  )),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Constants.padding * 2,
                vertical: Constants.height * 2,
              ),
              content: ButtonTheme(
                buttonColor: Colors.purple,
                height: Constants.height * 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: ElevatedButton(
                  child: Text(buttonText,
                      style: const TextStyle(color: Colors.white)),
                  onPressed: onPressedFunction,
                ),
              ));
        }

        if (scrollable) {
          return SingleChildScrollView(
            child: alertDialog(),
          );
        } else {
          return alertDialog();
        }
      },
    );
  }

  /// Generates a random alphanumeric string
  static String randomString(int strlen) {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for (var i = 0; i < strlen; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result;
  }

  /// Download callback
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {}
}
