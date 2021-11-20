## Clan Meeting - Flutter Integration



Please make sure that the [permissions](https://clanmeeting.com/docs/mobile-apps/permissions/) required for mobile apps are added to your app. We use [Flutter InAppWebView](https://pub.dev/packages/flutter_inappwebview) for this integration.



#### Flutter Specific Permissions

<div style="callout:info">Flutter Downloader related code is optional and only needed if you want the the shared files to be downloaded within the app. If you do not include Flutter Downloader, then the files will be downloaded using the default mobile browser.</div>



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
<!-- Flutter downloader -->
<provider
    android:name="vn.hunghd.flutterdownloader.DownloadedFileProvider"
    android:authorities="${applicationId}.flutter_downloader.provider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths"/>
</provider>
</application>
```



#### Additional packages

Add the following to your *pubspec.yaml* file.

```yaml
flutter_inappwebview: ^5.3.2
permission_handler: ^8.3.0
url_launcher: ^6.0.13
wakelock: ^0.5.6
path_provider: ^2.0.7
flutter_downloader: ^1.7.1
```



#### Create / Join Meeting

Edit the following in *main.dart*. There is no difference between creating and joining a meeting. A meeting gets created as soon as the first participant joins and is destroyed when the last participant leaves.

```dart
void _joinMeeting() async {
  const String domain = 'try.clanmeeting.com';
  const String consumerId = 'colacoca';
  String roomName = Utility.randomString(10);
  const String displayName = 'John Doe';
```



#### Remember to request for camera and microphone permissions

Already included in example *main.dart*

```dart
// Request for camera and microphone permissions
await Permission.camera.request();
await Permission.microphone.request();
```



#### WebView options

Already included in example *clanmeeting.dart*

```dart
InAppWebViewGroupOptions(
  crossPlatform: InAppWebViewOptions(
    allowUniversalAccessFromFileURLs: true,
    clearCache: true,
    javaScriptCanOpenWindowsAutomatically: true,
    mediaPlaybackRequiresUserGesture: false, // important
    transparentBackground: true,
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
