import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pref/pref.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/settings/settings.dart';

class PrefColor extends StatelessWidget {
  const PrefColor({
    required this.pref,
    super.key,
    this.title,
    this.subtitle,
    this.onChange,
    this.enableAlpha = false,
    this.disabled,
  });

  final String pref;

  final Widget? title;

  final Widget? subtitle;

  final ValueChanged<Color>? onChange;

  final bool enableAlpha;

  final bool? disabled;

  int get defaultValue => defaults[pref] as int;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('pref', pref))
      ..add(ObjectFlagProperty<ValueChanged<Color>?>.has('onChange', onChange))
      ..add(DiagnosticsProperty<bool>('enableAlpha', enableAlpha))
      ..add(DiagnosticsProperty<bool?>('disabled', disabled))
      ..add(IntProperty('defaultValue', defaultValue));
  }

  @override
  Widget build(BuildContext context) => PrefCustom<int>(
    pref: pref,
    title: title,
    subtitle: subtitle,
    onChange: onChange != null
        ? (v) => onChange!(Color(v ?? defaultValue))
        : null,
    disabled: disabled,
    onTap: _tap,
    builder: (c, v) => Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Container(color: Color(v ?? defaultValue), width: 20, height: 20),
    ),
  );

  Future<int?> _tap(BuildContext context, int? value) async {
    var newValue = value ?? defaultValue;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).colorPickerTitle),
        content: SingleChildScrollView(
          child: ColorPicker(
            enableAlpha: enableAlpha,
            pickerColor: Color(newValue),
            onColorChanged: (v) => newValue = v.intValue,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text(S.of(context).okay),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );

    return (result ?? false) ? newValue : value;
  }
}
