import 'package:flutter/material.dart';


class FloatingActionButtonWorkaround extends StatelessWidget {
    final Icon child;
    final void Function() onPressed;
    final String tooltip;
    const FloatingActionButtonWorkaround({required this.child,required this.onPressed, this.tooltip = ''});

    @override
    Widget build(BuildContext context)
    => GestureDetector(
              onTap: onPressed,
              child: child,
            );
}
