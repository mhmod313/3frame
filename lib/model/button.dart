import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  AnimatedButton({required this.label, required this.onPressed});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
        widget.onPressed();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          gradient: isPressed? LinearGradient(
            colors: [Colors.amber[700]!, Colors.brown[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [Colors.amber[600]!, Colors.black38!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: isPressed ? 2 : 5,
              offset: Offset(0, isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Text(
          widget.label,
          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}