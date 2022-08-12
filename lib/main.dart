import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:carwash/connectionStatus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';

//void main() => runApp(const MaterialApp(home: MyHomePage()));
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());
  //await Permission.storage.request();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
          AndroidServiceWorkerController.instance();

      await serviceWorkerController
          .setServiceWorkerClient(AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      ));
    }
  }

  runApp(const MaterialApp(
    home: MyHomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer timer;
  String data = "";

  Future readData() async {
    var uri = "https://carwashapp.online/datanotify.php";

    var response = await http.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      // print('object1');
      // print(response.statusCode);
      print(response.body);
      // print('object2');
      var statusdata = response.body;

      setState(() {
        data = statusdata;
      });
      // print('test1');
      // print(data);
      // print('test2');
    }
    //   if (preferences.getString("randomtime") != null) {
    //   if (preferences.getString("randomtime") == "true") {
    //     NotificationApi.showNotification(
    //     body: "this is body",
    //     id: 3,
    //     payload: "this is payload",
    //     title: "this is title",
    //     );
    //    }
    //  }
  }

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late bool _main;
  final GlobalKey webViewKey = GlobalKey();
  var connectionStatus;
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(

      crossPlatform: InAppWebViewOptions(

          clearCache: false,
          javaScriptEnabled: true,
          useOnLoadResource: true,
          cacheEnabled: true,
          supportZoom: false,
          preferredContentMode: UserPreferredContentMode.MOBILE,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false),
      android: AndroidInAppWebViewOptions(
        cacheMode: AndroidCacheMode.LOAD_CACHE_ELSE_NETWORK,
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        sharedCookiesEnabled: true,
        allowsInlineMediaPlayback: true,


      ));

  // ignore: non_constant_identifier_names
  late Future<void> WKwebview;

  late PullToRefreshController pullToRefreshController;
  late ContextMenu contextMenu;
  String url = "";
  final urlController = TextEditingController();

  @override
  void initState() {
    getData();

    timer = Timer.periodic(const Duration(seconds: 5), (timer) => readData());

    notificationWidget.init();

    super.initState();
    checkLocationServicesInDevice();
    firstCheck();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              androidId: 1,
              iosId: "1",
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid)
              ? contextMenuItemClicked.androidId
              : contextMenuItemClicked.iosId;
          // print("onContextMenuActionItemClicked: " +
          //     id.toString() +
          //     " " +
          //     contextMenuItemClicked.title);
        });

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  getData() async {
    await readData();
  }

  @override
  void dispose() {
    super.dispose();
  }
Future<void> setHttpAuthCredential(
    {required URLProtectionSpace protectionSpace,
    required URLCredential credential}) async {
  Map<String, dynamic> args = <String, dynamic>{};
  args.putIfAbsent("host", () => protectionSpace.host);
  args.putIfAbsent("protocol", () => protectionSpace.protocol);
  args.putIfAbsent("realm", () => protectionSpace.realm);
  args.putIfAbsent("port", () => protectionSpace.port);
  args.putIfAbsent("username", () => credential.username);
  args.putIfAbsent("password", () => credential.password);
  var _channel;
  await _channel.invokeMethod('setHttpAuthCredential', args);
}
  Future<void> checkLocationServicesInDevice() async {
    Location location = new Location();

    _serviceEnabled = await location.serviceEnabled();

    if (_serviceEnabled) {
      _permissionGranted = await location.hasPermission();

      if (_permissionGranted == PermissionStatus.granted) {
        _main = true;
        location.onLocationChanged.listen((LocationData currentLocation) {
          // print(currentLocation.latitude.toString() +
          //     " " +
          //     currentLocation.longitude.toString());
        });
      } else {
        _permissionGranted = await location.requestPermission();

        if (_permissionGranted == PermissionStatus.granted) {
          print('user allowed');
          _main = true;
        } else {
          SystemNavigator.pop();
        }
      }
    } else {
      _serviceEnabled = await location.requestService();

      if (_serviceEnabled) {
        _permissionGranted = await location.hasPermission();

        if (_permissionGranted == PermissionStatus.granted) {
          print('user allowed before');
          _main = true;
        } else {
          _permissionGranted = await location.requestPermission();

          if (_permissionGranted == PermissionStatus.granted) {
            print('user allowed');
            _main = true;
          } else {
            SystemNavigator.pop();
          }
        }
      } else {
        SystemNavigator.pop();
      }
    }
  }

  Future firstCheck() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connectionStatus = true;
        // print("connected $connectionStatus");
      }
    } on SocketException catch (_) {
      connectionStatus = false;
      //print("not connected $connectionStatus");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => ConnectionStatus()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
            onWillPop: () async {
              setState(() {
                webViewController?.goBack();
              });

              return false;
            },
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: SafeArea(
                    child: Column(children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: [
                        InAppWebView(
                          key: webViewKey,

                          initialUrlRequest: URLRequest(
                              url: Uri.parse("https://carwashapp.online/")),
                          // initialFile: "assets/index.html",
                          initialUserScripts:
                              UnmodifiableListView<UserScript>([]),
                          initialOptions: options,

                          pullToRefreshController: pullToRefreshController,
                          onLoadHttpError: (InAppWebViewController controller,
                              Uri? url, int i, String s) async {
                            /** instead of printing the console message i want to render a static page or display static message **/
                            webViewController?.loadFile(
                                assetFilePath: "assets/error.html");
                          },
                          onWebViewCreated: (controller) {
                            webViewController = controller;
                          },
                          onLoadStart: (controller, url) {
                            setState(() {
                              this.url = url.toString();
                              urlController.text = this.url;
                            });
                          },

                          androidOnGeolocationPermissionsShowPrompt:
                              (InAppWebViewController controller,
                                  String origin) async {
                            if (_main == true) {
                              return Future.value(
                                  GeolocationPermissionShowPromptResponse(
                                      origin: origin,
                                      allow: true,
                                      retain: true));
                            } else {
                              checkLocationServicesInDevice();
                            }
                          },
                          androidOnPermissionRequest:
                              (controller, origin, resources) async {
                            return PermissionRequestResponse(
                                resources: resources,
                                action: PermissionRequestResponseAction.GRANT);
                          },
                          shouldOverrideUrlLoading:
                              (controller, navigationAction) async {
                            var uri = navigationAction.request.url!;

                            if (![
                              "http",
                              "https",
                              "file",
                              "chrome",
                              "data",
                              "javascript",
                              "about"
                            ].contains(uri.scheme)) {
                              if (await canLaunchUrlString(uri.toString())) {
                                // Launch the App
                                await launchUrlString(uri.toString(),
                                    mode: LaunchMode.externalApplication);
                                // and cancel the request
                                return NavigationActionPolicy.CANCEL;
                              }
                            }

                            return NavigationActionPolicy.ALLOW;
                          },
                          onLoadStop: (controller, url) async {
                            firstCheck();
                            pullToRefreshController.endRefreshing();
                            setState(() {
                              this.url = url.toString();
                              urlController.text = this.url;
                            });
                          },
                          onLoadError: (controller, url, code, message) {
                            pullToRefreshController.endRefreshing();
                          },

                          onUpdateVisitedHistory:
                              (controller, url, androidIsReload) {
                            setState(() {
                              this.url = url.toString();
                              urlController.text = this.url;
                            });
                          },
                          onConsoleMessage: (controller, consoleMessage) {
                            print(consoleMessage);
                          },
                        ),
                      ],
                    ),
                  ),
                ])))));
  }
}

class notificationWidget {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future init({bool scheduled = false}) async {
    var initAndroidSettings =
        AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    final settings =
        InitializationSettings(android: initAndroidSettings, iOS: ios);
    await _notifications.initialize(settings);
  }

  static Future shownotification(
          {var id = 0, var title, var body, var payload}) async =>
      _notifications.show(id, title, body, await notificationDetails());

  static notificationDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channel id', 'channel name',
            importance: Importance.max),
        iOS: IOSNotificationDetails());
  }
}
