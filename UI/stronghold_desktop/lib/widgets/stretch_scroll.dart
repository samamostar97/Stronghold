import 'package:flutter/material.dart';

/// Rasteze tabelu na punu sirinu kartice, a kad je tabela sira od prozora
/// skroluje se horizontalno umjesto da se kolone (npr. Akcije) odsijeku.
class StretchScroll extends StatelessWidget {
  final Widget child;

  const StretchScroll({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: child,
        ),
      ),
    );
  }
}
