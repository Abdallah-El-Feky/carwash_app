import 'dart:io';

import 'package:flutter/material.dart';
import 'package:carwash/connectionStatus.dart';

import 'package:flutter/services.dart';

import 'main.dart';

class ConnectionStatus extends StatefulWidget {
  ConnectionStatus({Key? key}) : super(key: key);

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  var connectionStatus;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('assets/images/opps_internet.png'),
          const SizedBox(height: 20),
          const Text("No Internet"),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: () {
                check();
              },
              icon: Icon(
                Icons.refresh,
                size: 24.0,
              ),
              label: Text('Retry'),
            ),
            SizedBox(
              width: 50,
            ),
            ElevatedButton.icon(
              onPressed: () {
                SystemNavigator.pop();
              },
              icon: Icon(
                Icons.close,
                size: 24.0,
              ),
              label: Text('Close'),
            )
          ])
        ])),
      ),
    );
  }

  Future check() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connectionStatus = true;
        print("connected $connectionStatus");
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => MyHomePage()), (route) => false);
      }
    } on SocketException catch (_) {
      connectionStatus = false;
      print("not connected $connectionStatus");
    }
  }
}
