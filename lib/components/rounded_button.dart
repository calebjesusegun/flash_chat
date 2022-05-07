import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    Key? key,
    this.label,
    this.color,
    this.callback,
  }) : super(key: key);

  final Color? color;
  final String? label;
  final Function()? callback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color!,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: callback!,
          minWidth: 200.0,
          height: 42.0,
          child: Text(label!, style: const TextStyle(color: Colors.white),),
        ),
      ),
    );
  }
}
