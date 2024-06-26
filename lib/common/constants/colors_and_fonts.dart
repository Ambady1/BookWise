import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

TextTheme textTheme = TextTheme(
  displayLarge: GoogleFonts.lato(
    fontSize: 32,
    color: Colors.black87,
    fontWeight: FontWeight.bold,
  ),
  displayMedium: GoogleFonts.lato(
    fontSize: 20,
    color: Colors.black87,
    fontWeight: FontWeight.w800,
  ),
  displaySmall: GoogleFonts.lato(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  ),
  headlineMedium: GoogleFonts.poppins(
    fontSize: 16,
    color: Colors.black87,
    fontWeight: FontWeight.w400,
  ),
  headlineSmall: GoogleFonts.poppins(
    color: Colors.grey,
    fontWeight: FontWeight.w400,
  ),
);

class AppColors {
  static Color lightBlue = const Color(0xffCFEDEF);
  static Color black = Colors.black87;
}

List<Color> boxColors = const [
  Color(0xffCEEDEF),
  Color(0xffBFBFBF),
  Color(0xffEBECF1),
  Color(0xffFDF7DD),
  Color(0xffF9CFE3),
  Color(0xffFBEBC7),
  Color(0xffE9E8E6)
];
