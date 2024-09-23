import 'package:flutter/material.dart';
import '../AppColors/AppColors.dart';

AppBar appBarStyle( barName){
  return AppBar(
    backgroundColor: AppColors.pColor,
    title:  Center(
      child: Text(
        barName,
        style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            fontFamily: 'kalpurush',
            color: colorWhite),
      ),
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(20), // Adjust the radius for circular edges
      ),
    ),
  );
}


