import 'package:flutter/material.dart';

// change here and all every adjusts itself
const bca = 255;
const bcr = 145;
const bcg = 145;
const bcb = 145;

// ceiling
const bcrc = bcr > 255 ? 255 : bcr;
const bcgc = bcg > 255 ? 255 : bcg;
const bcbc = bcb > 255 ? 255 : bcb;

// floor
const bcrf = bcr < 0 ? 0 : bcr;
const bcgf = bcg < 0 ? 0 : bcg;
const bcbf = bcb < 0 ? 0 : bcb;

//half
const bcrh = bcr < 128;
const bcgh = bcg < 128;
const bcbh = bcb < 128;

//quarter
const bcrq = bcr < 64;
const bcgq = bcg < 64;
const bcbq = bcb < 64;

//eighth
const bcre = bcr < 32;
const bcge = bcg < 32;
const bcbe = bcb < 32;

//inverted
const bcri = bcr - 255 < 0 ? (bcr - 255) * -1 : bcr - 255;
const bcgi = bcg - 255 < 0 ? (bcg - 255) * -1 : bcg - 255;
const bcbi = bcb - 255 < 0 ? (bcb - 255) * -1 : bcb - 255;

const bcrih = bcr - 128 < 0 ? (bcr - 128) * -1 : bcr - 128;
const bcgih = bcg - 128 < 0 ? (bcg - 128) * -1 : bcg - 128;
const bcbih = bcb - 128 < 0 ? (bcb - 128) * -1 : bcb - 128;

const bcriqe = bcr - 72 < 0 ? (bcr - 72) * -1 : bcr - 72;
const bcgiqe = bcg - 72 < 0 ? (bcg - 72) * -1 : bcg - 72;
const bcbiqe = bcb - 72 < 0 ? (bcb - 72) * -1 : bcb - 72;

const bcriq = bcr - 64 < 0 ? (bcr - 64) * -1 : bcr - 64;
const bcgiq = bcg - 64 < 0 ? (bcg - 64) * -1 : bcg - 64;
const bcbiq = bcb - 64 < 0 ? (bcb - 64) * -1 : bcb - 64;

const bcrie = bcr - 32 < 0 ? (bcr - 32) * -1 : bcr - 32;
const bcgie = bcg - 32 < 0 ? (bcg - 32) * -1 : bcg - 32;
const bcbie = bcb - 32 < 0 ? (bcb - 32) * -1 : bcb - 32;

const bcris = bcr - 16 < 0 ? (bcr - 16) * -1 : bcr - 16;
const bcgis = bcg - 16 < 0 ? (bcg - 16) * -1 : bcg - 16;
const bcbis = bcb - 16 < 0 ? (bcb - 16) * -1 : bcb - 16;

const primaryColor = Color.fromARGB(255, 41, 50, 71);
const primaryDarkenedColor = Color.fromARGB(255, 49, 49, 49);

const gradientColor = Color.fromARGB(255, 30, 36, 51);
const secondaryColor =
    secondaryVariant1Color; //Color.fromARGB(255, bcrih, bcgih, bcb);

const secondaryVariant1Color = Color.fromARGB(255, 68, 68, 85);
const secondaryVariant2Color = Color.fromARGB(255, 72, 72, 95);
const secondaryVariant3Color = Color.fromARGB(255, 53, 48, 66);

const accentColor = Color.fromARGB(255, 80, 96, 114);

const entryColor = secondaryVariant2Color;

const retrospectiveColor = secondaryVariant3Color;

const perspectiveColor = secondaryVariant1Color;

const ct = [
  Color.fromARGB(255, bcri, bcg, bcb), // 1 0 0
  Color.fromARGB(255, bcri, bcgi, bcb), // 1 1 0
  Color.fromARGB(255, bcri, bcgi, bcbi), // 1 1 1
  Color.fromARGB(255, bcr, bcgi, bcbi), // 0 1 1
  Color.fromARGB(255, bcr, bcg, bcbi), // 0 0 1
  Color.fromARGB(255, bcr, bcg, bcb), // 0 0 0
  Color.fromARGB(255, bcr, bcgi, bcb), // 0 1 0
  Color.fromARGB(255, bcri, bcg, bcbi), // 1 0 1
];

const ctd = [
  Color.fromARGB(255, bcrih, bcg, bcb), // 1 0 0
  Color.fromARGB(255, bcrih, bcgih, bcb), // 1 1 0
  Color.fromARGB(255, bcrih, bcgih, bcbih), // 1 1 1
  Color.fromARGB(255, bcr, bcgih, bcbih), // 0 1 1
  Color.fromARGB(255, bcr, bcg, bcbih), // 0 0 1
  Color.fromARGB(255, bcr, bcg, bcb), // 0 0 0
  Color.fromARGB(255, bcr, bcgih, bcb), // 0 1 0
  Color.fromARGB(255, bcrih, bcg, bcbih), // 1 0 1
];

const ctq = [
  Color.fromARGB(255, bcriq, bcg, bcb), // 1 0 0
  Color.fromARGB(255, bcriq, bcgiq, bcb), // 1 1 0
  Color.fromARGB(255, bcriq, bcgiq, bcbiq), // 1 1 1
  Color.fromARGB(255, bcr, bcgiq, bcbiq), // 0 1 1
  Color.fromARGB(255, bcr, bcg, bcbiq), // 0 0 1
  Color.fromARGB(255, bcr, bcg, bcb), // 0 0 0
  Color.fromARGB(255, bcr, bcgiq, bcb), // 0 1 0
  Color.fromARGB(255, bcriq, bcg, bcbiq), // 1 0 1
];

enum JournalColors {
  entry(
    value: primaryColor,
    gradient: [entryColor, gradientColor],
  ),
  retrospective(
    value: secondaryColor,
    gradient: [retrospectiveColor, gradientColor],
  ),
  perspective(
    value: perspectiveColor,
    gradient: [perspectiveColor, gradientColor],
  );

  const JournalColors({required this.value, required this.gradient});
  final Color value;
  final List<Color> gradient;
}

MaterialColor getMaterialColor(Color color) {
  final red = color.red;
  final green = color.green;
  final blue = color.blue;
  final alpha = color.alpha;

  final shades = {
    50: Color.fromARGB(alpha, red, green, blue),
    100: Color.fromARGB(alpha, red, green, blue),
    200: Color.fromARGB(alpha, red, green, blue),
    300: Color.fromARGB(alpha, red, green, blue),
    400: Color.fromARGB(alpha, red, green, blue),
    500: Color.fromARGB(alpha, red, green, blue),
    600: Color.fromARGB(alpha, red, green, blue),
    700: Color.fromARGB(alpha, red, green, blue),
    800: Color.fromARGB(alpha, red, green, blue),
    900: Color.fromARGB(alpha, red, green, blue),
  };

  return MaterialColor(color.value, shades);
}
