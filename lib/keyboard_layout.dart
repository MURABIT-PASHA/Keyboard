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
    const Locale('tr'),
    const Locale('ar'),
    const Locale('de'),
    const Locale('ru'),
    const Locale('kk'),
    const Locale('en'),
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Keyboard"),
          actions: [
            IconButton(
              onPressed: () {
                connection.updateHostAddress('NULL');
              },
              icon: const Icon(Icons.private_connectivity_outlined),
            ),
          ],
        ),
        drawer: Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            child: ListView(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Icon(
                  Icons.palette,
                  color: Colors.red.shade900,
                  size: 75,
                ),
                const Text("Tema", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                const Divider(
                  indent: 15,
                  endIndent: 15,
                  height: 5,
                  color: Colors.grey,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  height: 100,
                  child: const Text('Çok yakında sizlerle demek isterdim ama değil maalesef.\nYani daha ne yapayım ücretsiz, reklamsız uygulama işte.'),
                ),
                //TODO: Add theme here
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
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
      ),
    );
  }

  Widget createKey(
      Map<String, dynamic> function, double width, String hostAddress) {
    final keyLabel = function.keys.first;
    final functions = function[keyLabel];
    return GestureDetector(
      onLongPressStart: (details) {
        specialKey.add(keyLabel.toLowerCase());
      },
      onLongPressEnd: (details) {
        specialKey.clear();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (keyLabel == 'Space') {
          if (details.velocity.pixelsPerSecond.dx > 500) {
            setState(() {
              if (index != 5) {
                index = index + 1;
              } else {
                index = 0;
              }
            });
          } else if (details.velocity.pixelsPerSecond.dx < -500) {
            setState(() {
              if (index != 0) {
                index = index - 1;
              } else {
                index = 5;
              }
            });
          }
        }
      },
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        onTap: () async {
          if (specialKey.isNotEmpty) {
            await SocketHelper.sendMessage(
                MessageModel(
                    orderType: MessageOrderType.type,
                    message: "${specialKey.first}+$keyLabel"),
                hostAddress);
          } else {
            await SocketHelper.sendMessage(
                MessageModel(
                    orderType: MessageOrderType.type, message: keyLabel),
                hostAddress);
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 0.25, right: 0.25),
          child: Ink(
            width: width - 0.5,
            height: 50,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 4,
                  blurRadius: 7,
                  offset: const Offset(0, 5),
                ),
              ],
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
        ),
      ),
    );
  }
}
