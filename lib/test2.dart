import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Image.asset('assets/images/RoadyTaxi-image.png'),
            Image.asset('assets/images/car_icon_final.png'),
            Image.asset('assets/images/IMG_0185.jpg'),
          ],
        ),
      ),
    );
  }
}
