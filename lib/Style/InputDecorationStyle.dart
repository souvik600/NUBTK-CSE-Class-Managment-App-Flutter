import 'package:flutter/material.dart';

import '../AppColors/AppColors.dart';

InputDecoration AppInputDecoration(label, ){
  return InputDecoration(
      focusedBorder:  const OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.pColor, width: 1.5),
      ),
      fillColor: Colors.black38,
      filled: false,
      contentPadding: EdgeInsets.fromLTRB(20, 10, 10, 20),
      enabledBorder: const OutlineInputBorder(
        borderSide: const BorderSide(color: colorDarkBlue, width: 1.5),
      ),
      border: OutlineInputBorder(),
      labelText: label
  );
}