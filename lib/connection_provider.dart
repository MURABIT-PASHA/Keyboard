import 'package:flutter/material.dart';

class ConnectionProvider extends ChangeNotifier{
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String _hostAddress = 'NULL';
  String get hostAddress => _hostAddress;

  void updateConnectionStatus(bool newStatus){
    _isConnected = newStatus;
    notifyListeners();
  }

  void updateHostAddress(String address){
    _hostAddress = address;
    notifyListeners();
  }

}