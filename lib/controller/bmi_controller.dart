import 'dart:math';

class BMIController {
  final int height;
  final int weight;
  double? bmi;

  BMIController({required this.height, required this.weight});

  String calcBMI() {
    bmi = weight / pow(height/100, 2);
    return bmi!.toStringAsFixed(1);
  }

  String displayBMICategory() {
    String category;

    if(bmi! < 18.5) category = "Underweight";
    else if (bmi! >= 18.5 && bmi! < 25) category = "Normal";
    else if (bmi! >= 25 && bmi! < 30) category = "Overweight";
    else category = "Obesity";

    return category;
  }

  String displayWords() {
    String words;

    if(bmi! < 18.5) words = "Oh no! You need to eat more";
    else if (bmi! >= 18.5 && bmi! < 25) words = "Good, You\'re healthy. Keep it up";
    else if (bmi! >= 25 && bmi! < 30) words = "Oh no! Please have a balanced diet";
    else words = "Oh no! Please have a balanced diet and work out more";

    return words;
  }
}