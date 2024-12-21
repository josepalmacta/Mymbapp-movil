import 'package:flutter/material.dart';

class card_text extends StatelessWidget {
  const card_text({super.key, required this.txt, required this.icono});

  final String txt;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.black, fontSize: 12.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            Icon(
              icono,
              size: 20,
              color: const Color.fromARGB(255, 27, 0, 255),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(width: 150, child: Text(txt, style: style))
          ],
        ),
      ),
    );
  }
}
