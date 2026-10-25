import 'package:material_ui/material_ui.dart';

class RetryButton extends StatelessWidget {
  final String buttonText;
  final Function(BuildContext) buttonAction;

  const RetryButton({
    super.key,
    required this.buttonText,
    required this.buttonAction,
  });

  @override
  Widget build(BuildContext context) => MaterialButton(
    onPressed: () => buttonAction(context),
    child: Text(buttonText),
  );
}
