## Clan Meeting - Flutter Integration
Please make sure that the [permissions](https://clanmeeting.com/docs/mobile-apps/permissions/) required for mobile apps are added to your app. We use [Flutter InAppWebView](https://pub.dev/packages/flutter_inappwebview) for this integration.
<br />
<br />

### Flutter Specific Permissions
Add the following to your *AndroidManifest.xml* file.
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
<br />

### Add the permissions required by the below packages
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
Edit the following in *main.dart*. There is no difference between creating and joining a meeting. A meeting gets created as soon as the first participant joins and is destroyed when the last participant leaves.
```dart
void _joinMeeting() async {
  const String domain = 'try.clanmeeting.com';
  const String consumerId = 'colacoca';
  String roomName = Utility.randomString(10);
  const String displayName = 'John Doe';
```
<br />

### Remember to request for camera and microphone permissions
Already included in example *main.dart*
```dart
// Request for camera and microphone permissions
await Permission.camera.request();
await Permission.microphone.request();
```
<br />

### WebView options
Already included in example *clanmeeting.dart*
```dart
InAppWebViewGroupOptions(
  crossPlatform: InAppWebViewOptions(
    clearCache: true,
    javaScriptCanOpenWindowsAutomatically: true,
    mediaPlaybackRequiresUserGesture: false, // important
  ),
  android: AndroidInAppWebViewOptions(
    supportMultipleWindows: true,
    useHybridComposition: true, // important
  ),
  ios: IOSInAppWebViewOptions(
    allowsInlineMediaPlayback: true, // important
  )
);
```
<br />
