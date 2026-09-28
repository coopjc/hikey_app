import 'package:flutter/material.dart';
import 'package:hikey_app/widgets/background.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/validators.dart';
import '../../widgets/hikey_logo.dart';
import '../../widgets/hikey_text_field.dart';
import 'widgets/error_banner.dart';
import 'widgets/password_strength_bar.dart';
import 'widgets/submit_button.dart';
import 'widgets/terms_checkbox.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  final FocusNode _ageFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  bool _acceptedTerms = false;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _ageFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms to create an account.'),
        ),
      );

      return;
    }

    final AuthController auth = context.read<AuthController>();

    final bool ok = await auth.register(
      displayName: _name.text,
      age: int.parse(_age.text.trim()),
      email: _email.text,
      password: _password.text,
    );

    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController auth = context.watch<AuthController>();
    final ThemeData theme = Theme.of(context);
    final bool busy = auth.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: BackButton(
          onPressed: busy
              ? null
              : () {
                  context.read<AuthController>().clearMessage();
                  Navigator.of(context).pop();
                },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Background(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const HikeyLogo(size: 56, showWordmark: false),
                        const SizedBox(height: 28),
                        Text(
                          'Create your account',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start logging trails, distances and elevation.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),
                        AuthErrorBanner(message: auth.message),
                        HikeyTextField(
                          controller: _name,
                          label: 'Name',
                          hint: 'Alex Rivera',
                          icon: Icons.person_outline_rounded,
                          enabled: !busy,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          autofillHints: const <String>[AutofillHints.name],
                          validator: Validators.name,
                          onChanged: (_) => auth.clearMessage(),
                          onSubmitted: (_) => _ageFocus.requestFocus(),
                        ),
                        const SizedBox(height: 16),
                        HikeyTextField(
                          controller: _age,
                          focusNode: _ageFocus,
                          label: 'Age',
                          hint: '28',
                          icon: Icons.cake_outlined,
                          enabled: !busy,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: Validators.age,
                          onChanged: (_) => auth.clearMessage(),
                          onSubmitted: (_) => _emailFocus.requestFocus(),
                        ),
                        const SizedBox(height: 16),
                        HikeyTextField(
                          controller: _email,
                          focusNode: _emailFocus,
                          label: 'Email',
                          hint: 'you@example.com',
                          icon: Icons.alternate_email_rounded,
                          enabled: !busy,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const <String>[AutofillHints.email],
                          validator: Validators.email,
                          onChanged: (_) => auth.clearMessage(),
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                        ),
                        const SizedBox(height: 16),
                        HikeyTextField(
                          controller: _password,
                          focusNode: _passwordFocus,
                          label: 'Password',
                          hint: 'At least 8 characters',
                          icon: Icons.lock_outline_rounded,
                          obscure: true,
                          enabled: !busy,
                          textInputAction: TextInputAction.next,
                          autofillHints: const <String>[
                            AutofillHints.newPassword,
                          ],
                          validator: Validators.password,
                          onChanged: (_) {
                            auth.clearMessage();
                            setState(() {});
                          },
                          onSubmitted: (_) => _confirmFocus.requestFocus(),
                        ),
                        PasswordStrengthBar(password: _password.text),
                        const SizedBox(height: 16),
                        HikeyTextField(
                          controller: _confirm,
                          focusNode: _confirmFocus,
                          label: 'Confirm password',
                          hint: 'Re-enter your password',
                          icon: Icons.lock_reset_rounded,
                          obscure: true,
                          enabled: !busy,
                          textInputAction: TextInputAction.done,
                          validator: (String? v) =>
                              Validators.confirmPassword(v, _password.text),
                          onChanged: (_) => auth.clearMessage(),
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 12),
                        TermsCheckbox(
                          value: _acceptedTerms,
                          enabled: !busy,
                          onChanged: (bool v) =>
                              setState(() => _acceptedTerms = v),
                        ),
                        const SizedBox(height: 16),
                        SubmitButton(
                          label: 'Create account',
                          busy: busy,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Text(
                              'Already have an account?',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: busy
                                  ? null
                                  : () {
                                      auth.clearMessage();
                                      Navigator.of(context).pop();
                                    },
                              child: const Text('Sign in'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
