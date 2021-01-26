import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class textformfield extends StatelessWidget {
  String label;
  String hint;
  bool password = false;
  TextEditingController controller;
  FormFieldValidator<String> validator;
  TextInputType keyboardType;
  TextInputAction textInputAction;
  FocusNode focusNode;
  FocusNode nextFocus;
  bool enabled;
  List<TextInputFormatter> inputFormatters;

  textformfield(this.label, this.hint, this.password,
      {this.controller,
      this.validator,
      this.keyboardType,
      this.textInputAction,
      this.focusNode,
      this.nextFocus,
      this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // autofocus: true,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: (String text) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      validator: validator,
      controller: controller,
      obscureText: password,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 15, color: Colors.black26),
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black38,
          fontWeight: FontWeight.w400,
          fontSize: 25,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(0.0)),
      ),
      style: TextStyle(
        fontSize: 20,
      ),
    );
  }
}
