import 'package:fit_allergy_check/component/round_icon_button.dart';
import 'package:fit_allergy_check/controller/bmi_controller.dart';
import 'package:fit_allergy_check/pages/bmi_result_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CheckBmiPage extends StatefulWidget {
  const CheckBmiPage({Key? key}) : super(key: key);

  @override
  State<CheckBmiPage> createState() => _CheckBmiPageState();
}

class _CheckBmiPageState extends State<CheckBmiPage> {
  int height = 150;
  int weight = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "HEIGHT",
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      height.toString(),
                    ),
                    Text(
                      "cm",
                    ),
                  ],
                ),
                Slider(
                    value: height.toDouble(),
                    min: 100,
                    max: 250,
                    activeColor: Color(0xFF4C4F5E),
                    inactiveColor: Colors.white,
                    onChanged: (double newHeight) {
                      setState(() {
                        height = newHeight.round();
                      });
                    })
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "WEIGHT",
                ),
                Text(
                  weight.toString(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundIconButton(
                      icon: FontAwesomeIcons.minus,
                      onPress: () {
                        setState(() {
                          weight--;
                        });
                        print("minus");
                      },
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    RoundIconButton(
                      icon: FontAwesomeIcons.plus,
                      onPress: () {
                        setState(() {
                          weight++;
                        });
                        print("plus");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              BMIController bmi = BMIController(height: height, weight: weight);
              Get.to(BMIResultPage(
                bmiValue: bmi.calcBMI(),
                bmiCategory: bmi.displayBMICategory(),
                words: bmi.displayWords(),
              ));
            },
            child: Text('CALCULATE'),
          ),
        ],
      ),
    );
  }
}
