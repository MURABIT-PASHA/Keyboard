import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionProvider extends ChangeNotifier{
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String _hostAddress = 'NULL';
  String get hostAddress => _hostAddress;

  void updateConnectionStatus(bool newStatus){
    _isConnected = newStatus;
    notifyListeners();
  }

  Future<bool> checkHostAddress()async{
    final prefs = await SharedPreferences.getInstance();
    final String tempHostAddress = prefs.getString('hostAddress')??'NULL';
    if(tempHostAddress != 'NULL'){
      if(_hostAddress != tempHostAddress){
        updateHostAddress(tempHostAddress);
      }
      return true;
    }
    else{
      return false;
    }
  }

  Future<bool> _registerHostAddress(String address)async{
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString('hostAddress', address);
  }

  void updateHostAddress(String address){
    _registerHostAddress(address).then((value){
      if(value){
        _hostAddress = address;
        if(_hostAddress == 'NULL'){
          updateConnectionStatus(false);
        }else{
          updateConnectionStatus(true);
        }
        notifyListeners();
      }
    });
  }

}