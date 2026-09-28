import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';

class SignUpPrompt extends StatelessWidget {
  const SignUpPrompt({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          'New to Hikey?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: enabled
              ? () {
                  context.read<AuthController>().clearMessage();

                  /** Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RegisterScreen(),
                    ),
                  ); */
                }
              : null,
          child: const Text('Create an account'),
        ),
      ],
    );
  }
}
