import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:location/location.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final Completer<WebViewController> _controller =
  //     Completer<WebViewController>();

  final Location location = new Location();
  PermissionStatus _permissionGranted;

  // num _stackToView = 1;

  // void _handleLoad(String value) {
  //   setState(() {
  //     _stackToView = 0;
  //   });
  // }

  _checkPermissions() async {
    PermissionStatus permissionGrantedResult = await location.hasPermission();
    setState(() {
      _permissionGranted = permissionGrantedResult;
    });
  }

  _requestPermission() async {
    if (_permissionGranted != PermissionStatus.GRANTED) {
      PermissionStatus permissionRequestedResult =
          await location.requestPermission();
      setState(() {
        _permissionGranted = permissionRequestedResult;
      });
      if (permissionRequestedResult != PermissionStatus.GRANTED) {
        return;
      }
    }
    _checkService();
    _requestService();
  }

  bool _serviceEnabled;

  _checkService() async {
    bool serviceEnabledResult = await location.serviceEnabled();
    setState(() {
      _serviceEnabled = serviceEnabledResult;
    });
  }

  _requestService() async {
    if (_serviceEnabled == null || !_serviceEnabled) {
      bool serviceRequestedResult = await location.requestService();
      setState(() {
        _serviceEnabled = serviceRequestedResult;
      });
      if (!serviceRequestedResult) {
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // FirebaseApp.initializeApp(this);
    _checkPermissions();
    _requestPermission();
    FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage called: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume called: $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch called: $message');
      },
    );
    firebaseMessaging.getToken().then((token) {
      print('FCM Token: $token');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
            onWillPop: () async => false,
            child: SafeArea(
              child: WebviewScaffold(
                  url: 'https://careforcemdbeta.careportmd.com/',
                  withZoom: true,
                  withLocalStorage: true,
                  hidden: true,
                  initialChild: Center(child: CircularProgressIndicator())),
            )));
  }
}

// IndexedStack(
//       index: _stackToView,
//       children: [
//         Column(
//           children: <Widget>[
//             Expanded(
//                 child: WebView(
//               initialUrl: 'https://careforcemdbeta.careportmd.com/',
//               javascriptMode: JavascriptMode.unrestricted,
//               onPageFinished: _handleLoad,
//               onWebViewCreated: (WebViewController webViewController) {
//                 _controller.complete(webViewController);
//                 _checkPermissions();
//                 _requestPermission();
//               },
//             )),
//           ],
//         ),
//         Center(child: CircularProgressIndicator())
//       ],
//     )
