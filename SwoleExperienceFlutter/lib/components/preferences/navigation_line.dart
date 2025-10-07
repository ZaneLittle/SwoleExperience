import 'package:flutter/material.dart';

enum NavigationType { internal, external }

class NavigationLine extends StatefulWidget {
  const NavigationLine(
      {Key? key,
      required this.navType,
      required this.lineText,
      required this.onTap})
      : super(key: key);

  final NavigationType navType;
  final String lineText;
  final Function onTap;

  @override
  State<NavigationLine> createState() => _NavigationLineState();
}

class _NavigationLineState extends State<NavigationLine> {
  Widget buildNavIcon() {
    switch (widget.navType) {
      case NavigationType.internal:
        {
          return const Icon(Icons.arrow_forward_ios);
        }
      case NavigationType.external:
        {
          return const Icon(Icons.link);
        }
      default:
        {
          return Container();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => widget.onTap(),
        child: Card(
            child: SizedBox(
                height: 48,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(widget.lineText)),
                      Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: buildNavIcon())
                    ]))));
  }
}
