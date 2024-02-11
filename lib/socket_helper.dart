import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:keyboard/message_model.dart';

class SocketHelper{
  static const MethodChannel _methodChannel = MethodChannel('tech.murabit/method');

  static Future<void> sendMessage(MessageModel message, String address) async{
    final data = jsonEncode(message.toJson());
    await _methodChannel.invokeMethod('sendMessage', {"message": data, "address": address});
  }

}