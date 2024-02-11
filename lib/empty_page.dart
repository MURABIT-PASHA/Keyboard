import 'package:flutter/material.dart';
import 'package:keyboard/scan_dialog.dart';
class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keyboard"),
        actions: [IconButton(onPressed: (){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Scan QR"),
                content: Container(
                  width: width,
                  height: width,
                  padding: const EdgeInsets.all(10),
                  child: ScanDialog(size: width),
                ),
              );
            },
          );
        }, icon: const Icon(Icons.qr_code_scanner))],
      ),
    );
  }
}
