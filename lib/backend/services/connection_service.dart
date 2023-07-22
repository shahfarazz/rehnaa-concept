import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  // Create our public controller
  StreamController<ConnectivityResult> connectivityController =
      StreamController<ConnectivityResult>();

  ConnectivityService() {
    // Subscribe to the Connectivity Chanaged Steam
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Use Connectivity() here to gather more info if you need t
      connectivityController.add(result);
    });
  }
}

class ConnectionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.red,
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Text(
          "No internet connection",
          style: TextStyle(color: Colors.white, fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
