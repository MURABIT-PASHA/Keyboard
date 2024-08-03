import 'dart:io';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:keyboard/connection_provider.dart';
import 'package:keyboard/enums.dart';
import 'package:keyboard/message_model.dart';
import 'package:keyboard/socket_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanDialog extends StatefulWidget {
  const ScanDialog({Key? key}) : super(key: key);

  @override
  State<ScanDialog> createState() => _ScanDialogState();
}

class _ScanDialogState extends State<ScanDialog> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatus =
    Provider.of<ConnectionProvider>(context, listen: true);
    connectionStatus.checkHostAddress().then((value) => print(value));
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          DotLottieLoader.fromAsset("assets/lottie/qr-scanner.lottie",
              frameBuilder: (BuildContext ctx, DotLottie? dotlottie) {
                if (dotlottie != null) {
                  return Lottie.memory(dotlottie.animations.values.single);
                } else {
                  return Container();
                }
              }),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null) {
          final connection =
              Provider.of<ConnectionProvider>(context, listen: false);
          SocketHelper.sendMessage(
            const MessageModel(orderType: MessageOrderType.connect),
            result!.code ?? "NULL",
          ).then((value) {
            if (mounted) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              connection.updateHostAddress(result!.code ?? "NULL");
              connection.updateConnectionStatus(true);
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
