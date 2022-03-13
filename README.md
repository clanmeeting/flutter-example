## Clan Meeting - Flutter Integration
<br />

### App Permissions

Please make sure that the [permissions](https://clanmeeting.com/docs/mobile-apps/permissions/) required for mobile apps are added to your app.
<br />

<br />

### Flutter Specific Permissions
Add the following to your *./android/app/src/main/AndroidManifest.xml* file.
```xml
<!-- Webview -->
<provider
    android:name="com.pichillilorenzo.flutter_inappwebview.InAppWebViewFileProvider"
    android:authorities="${applicationId}.flutter_inappwebview.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths" />
</provider>
```
```xml
<application
    ...
    android:usesCleartextTraffic="true">
```

<br />

Add the following to your *./ios/Runner/info.plist* file.

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Package Permissions
Flutter Downloader related code is optional and only needed if you want the the shared files to be downloaded within the app. If you do not include Flutter Downloader, then the files will be downloaded using the default mobile browser. Required permissions listed on the package page are needed for downloading shared files within your app.

https://pub.dev/packages/flutter_downloader
<br />
<br />

URL Launcher is used for opening URLs pasted in chat.

https://pub.dev/packages/url_launcher
<br />
<br />

### Include packages
Add the following to your *pubspec.yaml* file.
```yaml
flutter_inappwebview: ^5.3.2
permission_handler: ^8.3.0
url_launcher: ^6.0.13
wakelock: ^0.5.6
path_provider: ^2.0.7
flutter_downloader: ^1.7.1
```
<br />

### Create / Join Meeting
Edit the following in *main.dart*. There is no difference between creating and joining a meeting. A meeting gets created as soon as the first host joins the meeting.<br />

You will need to fetch the `roomName`, `displayName` and `jwt` from your backend API.<br />

For a full list of these properties that you can pass, please visit [ClanMeeting properties page.](https://clanmeeting.com/docs/customization-and-controls/properties)

```dart
void _joinMeeting() async {
  const String domain = 'clanmeeting-domain';
  const String consumerId = 'your-consumer-id';
  const String roomName = 'meeting-room-name';
  const String displayName = 'participant-display-name';
  // if this participant is the host, not required if common participant
  const String jwt = 'the-jwt-from-backend-api';
```
<br />

### Remember to request for the camera and microphone permissions

Already included in example *main.dart*
```dart
// Request for camera and microphone permissions
await Permission.camera.request();
await Permission.microphone.request();
```

<br />

### Adding further events and methods (Optional)

All JavaScript [Events](https://clanmeeting.com/docs/customization-and-controls/events) and [Methods](https://clanmeeting.com/docs/customization-and-controls/methods) can be used within the app by editing the *assets/clanmeeting.html*.  The example shows how to trigger a custom logic on Flutter side when the user leaves the meeting on app.<br />

*clanmeeting.html*

```javascript
// Events
const meetingLeftLsnr = function (data) {
  // Sends this data over to flutterEndCallHandler defined in clanmeeting.dart
  window.flutter_inappwebview.callHandler('flutterEndCallHandler', data);
};

meeting.once('meetingLeft', meetingLeftLsnr);
```

*clanmeeting.dart*

```dart
controller.addJavaScriptHandler(
    handlerName: 'flutterEndCallHandler',
    callback: (data) async {
        // data has arguments coming from the JavaScript side!
        debugPrint(
            'Data coming from Javascript side: $data');
        // ADD YOUR CUSTOM LOGIC HERE
        Navigator.pop(context);
    }
);
```

