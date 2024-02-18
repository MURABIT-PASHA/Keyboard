import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard/enums.dart';
import 'package:keyboard/message_model.dart';
import 'package:keyboard/socket_helper.dart';
import 'package:provider/provider.dart';
import 'connection_provider.dart';
import 'keyboard_helper.dart';

class KeyboardLayoutWidget extends StatefulWidget {
  const KeyboardLayoutWidget({Key? key}) : super(key: key);

  @override
  State<KeyboardLayoutWidget> createState() => _KeyboardLayoutWidgetState();
}

class _KeyboardLayoutWidgetState extends State<KeyboardLayoutWidget> {
  final KeyboardLayoutHelper helper = KeyboardLayoutHelper();
  List<String> specialKey = [];
  final List<Locale> locales = [
    Locale('tr'),
    Locale('ar'),
    Locale('de'),
    Locale('ru'),
    Locale('kk'),
    Locale('en'),
  ];
  int index = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
          ),
          IconButton(
            onPressed: () {
              //TODO: Open customize menu
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: helper.getKeyboardLayout(locales[index]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final maxKeys = data.values.fold<int>(
                0, (max, item) => item.length > max ? item.length : max);
            final baseWidth = screenWidth / maxKeys;

            final hostAddress = connection.hostAddress;
            List<Widget> columnChildren = data.entries.map((entry) {
              int specialKeysCount = entry.value.where((button) {
                final keyLabel = button.keys.first;
                return [
                  'Shift',
                  'Backspace',
                  'Tab',
                  'Enter',
                  'Caps Lock',
                  'Space'
                ].contains(keyLabel);
              }).length;
              double standardWidth = baseWidth - 1;
              double gaps = entry.value.length * 0.5;
              double extraWidth =
                  screenWidth - (entry.value.length * standardWidth) - gaps;
              double extraWidthPerSpecialKey =
                  specialKeysCount > 0 ? extraWidth / specialKeysCount : 0;
              List<Widget> rowChildren = entry.value.map<Widget>((button) {
                final keyLabel = button.keys.first;
                bool isSpecialKey = [
                  'Shift',
                  'Backspace',
                  'Tab',
                  'Enter',
                  'Caps Lock',
                  'Space'
                ].contains(keyLabel);
                double keyWidth = isSpecialKey
                    ? standardWidth + extraWidthPerSpecialKey
                    : standardWidth;
                return createKey(button, keyWidth, hostAddress);
              }).toList();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: rowChildren,
              );
            }).toList();

            return SizedBox(
              width: screenWidth,
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: columnChildren,
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Widget createKey(
      Map<String, dynamic> function, double width, String hostAddress) {
    final keyLabel = function.keys.first;
    final functions = function[keyLabel];
    return GestureDetector(
      onTap: () async {
        if (specialKey.isNotEmpty) {
          await SocketHelper.sendMessage(
              MessageModel(
                  orderType: MessageOrderType.type,
                  message: "${specialKey.first}+$keyLabel"),
              hostAddress);
        } else {
          await SocketHelper.sendMessage(
              MessageModel(orderType: MessageOrderType.type, message: keyLabel),
              hostAddress);
        }
      },
      onLongPressStart: (details) {
        specialKey.add(keyLabel.toLowerCase());
      },
      onLongPressEnd: (details) {
        specialKey.clear();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (keyLabel == 'Space') {
          if(details.velocity.pixelsPerSecond.dx>1000){
            setState(() {
              if(index != 5) {
                index = index + 1;
              }else{
                index = 0;
              }
            });
          }else if(details.velocity.pixelsPerSecond.dx<-1000){
            setState(() {
              if(index != 0) {
                index = index - 1;
              }else{
                index = 5;
              }
            });
          }
        }
      },
      child: AnimatedContainer(
        margin: const EdgeInsets.only(left: 0.25, right: 0.25),
        duration: const Duration(milliseconds: 100),
        width: width,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade500, Colors.blue.shade900],
          ),
          border: Border.all(
            color: Colors.blueGrey,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            if (functions.containsKey('shift'))
              Positioned(
                top: 5,
                left: 8,
                child: Text(
                  functions['shift'],
                  style: const TextStyle(fontSize: 9),
                  maxLines: 1,
                ),
              ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Builder(builder: (context) {
                  if (keyLabel == 'Space') {
                    return const Icon(Icons.space_bar);
                  } else if (keyLabel == 'Tab') {
                    return const Icon(Icons.keyboard_tab);
                  } else if (keyLabel == 'Backspace') {
                    return const Icon(Icons.keyboard_backspace);
                  } else if (keyLabel == 'Enter') {
                    return const Icon(Icons.keyboard_return);
                  } else if (keyLabel == 'Win') {
                    return const Icon(Icons.window_sharp);
                  } else if (keyLabel == 'Menu') {
                    return const Icon(Icons.menu);
                  } else {
                    return Text(
                      keyLabel,
                      style: const TextStyle(fontSize: 15),
                      maxLines: 1,
                    );
                  }
                }),
              ),
            ),
            if (functions.containsKey('alt_gr'))
              Positioned(
                bottom: 5,
                right: 8,
                child: Text(
                  functions['alt_gr'],
                  style: const TextStyle(fontSize: 9),
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
