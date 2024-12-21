import 'package:flutter/material.dart';

const styleBold = const TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.bold,
  fontSize: 15.0,
);

const styleBold_2 = const TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.bold,
  fontSize: 12.0,
);

TextStyle styleBoldB = TextStyle(
  color: primaryColor,
  fontWeight: FontWeight.bold,
  fontSize: 12.0,
);

TextStyle styleBoldB_2 = TextStyle(
  color: primaryColor,
  fontWeight: FontWeight.bold,
  fontSize: 20.0,
);

TextStyle styleBoldB_3 = TextStyle(
  color: primaryColor,
  fontWeight: FontWeight.bold,
  fontSize: 15.0,
);

const styleNormal = const TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.normal,
  fontSize: 15.0,
);

const styleSmall_1 = const TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.normal,
  fontSize: 10,
);

const styleSmall_2 = const TextStyle(
  color: Colors.grey,
  fontWeight: FontWeight.normal,
  fontSize: 10,
);

InputDecoration inputStyle(String hintText, IconData icono) {
  return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icono),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ));
}

InputDecoration DropDStyle(String label) {
  return InputDecoration(
      border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ));
}

Color primaryColor = const Color.fromARGB(255, 27, 0, 255);

Color cardBackground = const Color.fromARGB(255, 248, 249, 250);

Icon primaryIconButton(IconData icono) {
  return Icon(
    icono,
    color: Colors.white,
    size: 20,
  );
}

Icon secondaryIconButton(IconData icono) {
  return Icon(
    icono,
    color: primaryColor,
    size: 20,
  );
}

ButtonStyle primaryButton =
    ElevatedButton.styleFrom(backgroundColor: primaryColor);

ButtonStyle secondaryButton = ElevatedButton.styleFrom(
  backgroundColor: Colors.white,
  side: BorderSide(color: primaryColor, width: 1),
);

ButtonStyle thridButton = ElevatedButton.styleFrom(
  backgroundColor: primaryColor,
  side: const BorderSide(color: Colors.white, width: 1),
);

TextStyle secondaryButtonText = TextStyle(
  color: primaryColor,
);

TextStyle primaryButtonText = const TextStyle(
  color: Colors.white,
);
