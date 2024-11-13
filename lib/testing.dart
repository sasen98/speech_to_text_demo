import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TestIngApp extends StatefulWidget {
  const TestIngApp({super.key});

  @override
  State<TestIngApp> createState() => _TestIngAppState();
}

class _TestIngAppState extends State<TestIngApp>
    with SingleTickerProviderStateMixin {
  ValueNotifier<String> spokenText =
      ValueNotifier<String>("The words you speak will appear here");
  ValueNotifier<bool> isListening = ValueNotifier<bool>(false);

  SpeechToText _speechToText = SpeechToText();

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    initSpeech();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void initSpeech() async {
    await _speechToText.initialize(onStatus: (status) {
      log("status::::::::::::: $status");

      if (status == 'done') {
        isListening.value = false;
        setState(() {});
      }
    }, onError: (error) {
      spokenText.value = error.errorMsg;
      isListening.value = false;
    });
  }

  void start() {
    _controller.forward(from: 0.0);
    isListening.value = true;
    _speechToText.listen(onResult: (result) {
      spokenText.value = result.recognizedWords;
      isListening.value = false;
      _controller.reset();
    });
  }

  void stop() {
    isListening.value = false;
    _speechToText.stop();
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder(
                valueListenable: isListening,
                builder: (_, list, __) {
                  return Text(list.toString());
                }),
            const SizedBox(
              height: 50,
            ),
            ValueListenableBuilder(
                valueListenable: spokenText,
                builder: (_, text, __) {
                  return Text(text);
                }),
            const SizedBox(
              height: 50,
            ),
            ValueListenableBuilder(
                valueListenable: isListening,
                builder: (_, isList, __) {
                  return isList
                      ? InkWell(
                          onTap: () => stop(),
                          child: CustomPaint(
                            painter: _CircleBorderPainter(_controller),
                            child: Container(
                                height: 70,
                                width: 70,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  isList ? Icons.speaker : Icons.mic,
                                  color: Colors.white,
                                )),
                          ),
                        )
                      : InkWell(
                          child: Container(
                              height: 70,
                              width: 70,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                isList ? Icons.speaker : Icons.mic,
                                color: Colors.white,
                              )),
                          onTap: () {
                            if (isList) {
                              stop();
                            } else {
                              start();
                            }
                          },
                        );
                }),
          ],
        ),
      ),
    );
  }
}

class _CircleBorderPainter extends CustomPainter {
  final Animation<double> _animation;

  _CircleBorderPainter(this._animation) : super(repaint: _animation);

  @override
  void paint(Canvas canvas, Size size) {
    double progress = _animation.value * 2 * 3.14;
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -0.5 * 3.14,
      progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
