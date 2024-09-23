
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../AppColors/AppColors.dart';

Container CatagoriList(inWell, image, text) {
  return Container(
    height: 110,
    decoration: const BoxDecoration(
        color: colorWhite,
        boxShadow:[
          BoxShadow(blurRadius: 5.0,color: colorDarkBlue)
        ] ,
        borderRadius: BorderRadius.all(Radius.circular(10)),

    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        InkWell(
          onTap: inWell,
          child: Container(
            height: 75,
            width: 98,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Lottie.asset(
                image, // Replace this with your animation file path
                width: 75,
                height: 98,
                fit: BoxFit.fill,
              )
            ),
          ),
        ),
        const SizedBox(height: 5,),

             Center(child: Text(text,style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 12,fontFamily: 'kalpurush',))),
        const SizedBox(height: 5,),

      ],

    ),
  );
}
