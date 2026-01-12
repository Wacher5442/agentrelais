import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Widget suffixIcon;
  final Widget? prefixIcon;

  final TextEditingController controller;
  final ValueChanged<String>? onchange;
  final TextInputType? keyboardType;
  final bool disabled;
  final FormFieldValidator<String>? validator;
  final String label;
  final double labelPadding;

  const InputField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    required this.suffixIcon,
    required this.controller,
    this.onchange,
    this.keyboardType = TextInputType.text,
    this.disabled = false,
    this.validator,
    this.label = "",
    this.labelPadding = 2.0,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: labelPadding),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        Container(
          padding: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            enabled: !disabled,
            controller: controller,
            obscureText: obscureText,
            onChanged: onchange,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFCCCCCC),
              ),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon,
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            ),
          ),
        ),
      ],
    );
  }
}
