import 'package:flutter/material.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/login/login.dart';
import 'package:studipassau/pages/login/widgets/retry_button.dart';
import 'package:studipassau/util/navigation.dart';

class RetryScreen extends StatelessWidget {
  final String text;
  final Widget button;

  RetryScreen({
    super.key,
    required this.text,
    required String buttonText,
    required Function(BuildContext) buttonAction,
  }) : button = RetryButton(buttonText: buttonText, buttonAction: buttonAction);

  const RetryScreen.withButton({
    super.key,
    required this.text,
    required this.button,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text(text, textAlign: TextAlign.center),
        button,
      ],
    ),
  );
}

class CenteredRetryScreen extends RetryScreen {
  CenteredRetryScreen({
    super.key,
    required super.text,
    required super.buttonText,
    required super.buttonAction,
  });

  CenteredRetryScreen.login({
    Key? key,
    required BuildContext context,
    required String route,
  }) : this(
         key: key,
         text: S.of(context).loginRequired,
         buttonText: S.of(context).login.toUpperCase(),
         buttonAction: (context) {
           targetRoute = route;
           navigateTo(context, routeLogin);
         },
       );

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[super.build(context)],
    ),
  );
}
