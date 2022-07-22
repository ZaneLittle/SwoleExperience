import 'dart:async';

import 'package:flutter/material.dart';

import 'package:swole_experience/components/preferences/settings.dart';

class SettingsButton extends StatefulWidget {
  const SettingsButton({
    Key? key,
    this.rebuildCallback,
  }) : super(key: key);

  final Function? rebuildCallback;

  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
  FutureOr rebuild(dynamic value) {
    widget.rebuildCallback != null ? widget.rebuildCallback!(value) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 32,
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Settings()))
                  .then(rebuild);
            }));
  }
}
