import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final TextEditingController controller;
  final TextCapitalization textCap;
  final Function onFieldSubmitted;
  final TextInputType inputType;
  final TextInputAction action;
  final Function validator;
  final Color labelColor;
  final String labelText;
  final bool obscureText;
  final Color iconColor;
  final Color textColor;
  final IconData prefixIcon;
  final FocusNode node;
  final bool enable;
  final IconData icon;

  const CustomField({
    this.action = TextInputAction.next,
    this.obscureText = false,
    this.onFieldSubmitted,
    this.controller,
    this.labelColor,
    this.labelText,
    this.validator,
    this.inputType,
    this.iconColor,
    this.textColor,
    this.textCap,
    this.prefixIcon,
    this.enable,
    this.icon,
    this.node,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: true,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: Colors.white60, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: Colors.white, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: Colors.yellow[700], width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: Colors.yellow[700], width: 1.5),
        ),
        errorStyle:
            TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.w500),
        labelText: labelText,
        labelStyle: TextStyle(color: labelColor),
      ),
      onFieldSubmitted: onFieldSubmitted,
      textCapitalization: textCap,
      cursorColor: Colors.white,
      obscureText: obscureText,
      keyboardType: inputType,
      textInputAction: action,
      controller: controller,
      validator: validator,
      focusNode: node,
    );
  }
}
