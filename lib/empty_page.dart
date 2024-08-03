import 'package:flutter/material.dart';
import 'package:keyboard/scan_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class EmptyPage extends StatefulWidget {
  const EmptyPage({super.key});

  @override
  State<EmptyPage> createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage> {
  List<TargetFocus> targets = [];
  GlobalKey keyButton = GlobalKey();

  @override
  void initState() {
    super.initState();
    setTargets();
    configureTutorial();
  }

  void showTutorial() {
    TutorialCoachMark(
      targets: targets, // List<TargetFocus>
      colorShadow: Colors.black, // DEFAULT Colors.black
      textSkip: "GEÇ",
      onSkip: () {
        saveTutorialPreferences();
        return true;
      },
      onFinish: () {
        saveTutorialPreferences();
      },
    ).show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keyboard"),
        actions: [
          IconButton(
            key: keyButton,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Scan QR",textAlign: TextAlign.center,),
                    content: Container(
                      width: 230,
                      height: 230,
                      padding: const EdgeInsets.all(10),
                      child: const ScanDialog(),
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
    );
  }

  void setTargets() {
    targets.add(
      TargetFocus(
        identify: "Target 1",
        keyTarget: keyButton,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Windows cihazınızı bağlayın",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: SizedBox(
                    width: 300,
                    height: 200,
                    child: Image.asset('assets/gif/tutorial.gif'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "https://murabit.tech adresinden Windows cihazınıza uygulamayı indirin. Uygulamayı çalıştırdığınızda Windows cihazınızın sistem bildirimleri köşesinde uygulamanın bir ikonu oluşacaktır. İkona sağ tıklayığ 'Bağla' seçeneğini seçin. Açılan karekodu Android cihazınızda taratın.\nNot: İnternet erişimi olmasa dahi iki cihazınızın da aynı ağa bağlanmış olması gerekmektedir.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future configureTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isShown = prefs.getBool('isShown') ?? false;
    if (!isShown) {
      showTutorial();
    }
  }

  Future saveTutorialPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isShown', true);
  }
}
