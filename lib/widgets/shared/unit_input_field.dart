import 'package:flutter/material.dart';

class UnitInputField extends StatefulWidget {
  const UnitInputField({
    super.key,
    required this.value,
    required this.unit,
    required this.onChanged,
  });

  final String value;
  final String unit;
  final ValueChanged<String> onChanged;

  @override
  State<UnitInputField> createState() => _UnitInputFieldState();
}

class _UnitInputFieldState extends State<UnitInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant UnitInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Avoid cursor jumps while user is typing.
    if (!_focusNode.hasFocus && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        suffixText: widget.unit,
      ),
    );
  }
}
