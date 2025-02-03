import 'package:flutter/cupertino.dart';

class CupertinoAvatar extends StatelessWidget {
  const CupertinoAvatar({
    super.key,
    required this.name,
    required this.size,
  });
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage(name),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}