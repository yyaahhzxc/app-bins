import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final Widget? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool showClearButton;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.showClearButton = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = isDark ? kTextPrimaryDark : kTextPrimary;
    final hintColor = isDark ? Colors.grey[600] : Colors.grey[400];
    final fillColor = isDark ? kSurfaceColorDark : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLines: widget.maxLines,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          style: TextStyle(
            fontSize: kBodySize,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            alignLabelWithHint: true,
            
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.showClearButton && widget.controller != null && widget.controller!.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.cancel_outlined, color: hintColor),
                    onPressed: () {
                      widget.controller?.clear();
                      setState(() {});
                    },
                  )
                : null,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kErrorColor, width: 1.5),
            ),
            
            labelStyle: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              backgroundColor: fillColor, // Match background to hide line behind label
            ),
            hintStyle: TextStyle(color: hintColor),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          onChanged: (_) {
            if (widget.showClearButton) setState(() {});
          },
        ),
      ],
    );
  }
}