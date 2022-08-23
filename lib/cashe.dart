// import 'package:flutter/cupertino.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// Future<String> _future;
//
// Future<String> _load() async {
//   SharedPreferences pref = await SharedPreferences.getInstance();
//   _view = pref.getString('url') ?? '';
//   return Future.value(_view);
// }
//
// @override
// void initState() {
//   super.initState();
//   _future = _load();
// }
//
// @override
// Widget build(BuildContext context) {
//   ...
//   body: FutureBuilder(
//   future: _future,
//   builder: (context, AsyncSnapshot<String> snapshot) {
//   switch (snapshot.connectionState) {
//   ...
//   case ConnectionState.done:
//   if (snapshot.hasError) {
//   return Text(
//   '${snapshot.error}',
//   style: TextStyle(color: Colors.red),
//   );
//   } else {
//   return WebView(
//   initialUrl: _view,
//   javascriptMode: JavascriptMode.unrestricted,
//   javascriptChannels: Set.from([
//   JavascriptChannel(
//   name: "getData",
//   onMessageReceived: (JavascriptMessage result) {}),
//   ]),
//   );
//   }
//   }
//   }));
