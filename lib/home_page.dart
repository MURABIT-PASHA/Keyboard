import 'package:flutter/material.dart';
import 'package:keyboard/connection_provider.dart';
import 'package:keyboard/enums.dart';
import 'package:keyboard/message_model.dart';
import 'package:keyboard/socket_helper.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _previousValue = "";
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final connection = Provider.of<ConnectionProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keyboard"),
        actions: [
          IconButton(
            onPressed: () {
              connection.updateConnectionStatus(false);
            },
            icon: const Icon(Icons.private_connectivity_outlined),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: width,
          height: 50,
          child: TextField(
            onChanged: (val) async {
              //TODO: Kontrol ekle otomatik tamamlama kullanılmış mı kullanıldıysa parçala vs.
              if (val.length > _previousValue.length) {
                await SocketHelper.sendMessage(MessageModel(orderType: MessageOrderType.type, message: val.substring(val.length - 1)), connection.hostAddress);
              } else if (val.length < _previousValue.length) {
                await SocketHelper.sendMessage(const MessageModel(orderType: MessageOrderType.type, message: "backspace"), connection.hostAddress);
              }
              _previousValue = val;
            },
          ),
        ),
      ),
    );
  }
}
