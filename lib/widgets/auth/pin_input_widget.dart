import 'package:flutter/material.dart';

/// Widget for PIN input with visual feedback
class PinInputWidget extends StatefulWidget {
  final int pinLength;
  final Function(String) onPinChanged;
  final VoidCallback? onComplete;
  final TextEditingController? controller;
  final bool obscureText;

  const PinInputWidget({
    Key? key,
    this.pinLength = 4,
    required this.onPinChanged,
    this.onComplete,
    this.controller,
    this.obscureText = false,
  }) : super(key: key);

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      widget.onPinChanged(_controller.text);
      if (_controller.text.length == widget.pinLength) {
        widget.onComplete?.call();
      }
    });

    // Auto-focus the input after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PIN dots display - make it tappable
        GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.pinLength,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: index < _controller.text.length
                            ? Colors.blue
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: index < _controller.text.length
                          ? Icon(
                              widget.obscureText ? Icons.circle : Icons.check,
                              color: Colors.blue,
                              size: 24,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Hidden text field for input
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: widget.pinLength,
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),
      ],
    );
  }
}
