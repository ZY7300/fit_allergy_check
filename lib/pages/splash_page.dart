import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double imageRotation = 0.0;
  double progressWidth = 0.0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    animateImageRotation();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  route() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  startTimer() {
    var duration = Duration(seconds: 2);
    return Timer(duration, route);
  }

  animateImageRotation() {
    timer = Timer.periodic(Duration(milliseconds: 50), (Timer timer) {
      if (mounted) {
        setState(() {
          imageRotation += math.pi / 180;
        });

        if (progressWidth < MediaQuery.of(context).size.width) {
          setState(() {
            progressWidth += 2;
          });
        } else {
          timer.cancel();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Transform.rotate(
              angle: imageRotation,
              child: Image.asset('assets/images/logo.png', width: 100, height: 100),
            ),
            SizedBox(height: 20),
            Container(
              height: 2,
              width: progressWidth,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
