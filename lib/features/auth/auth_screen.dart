import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/backend.dart';
import '../../core/widgets.dart';
import '../../l10n/app_localizations.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(),
      password = TextEditingController(),
      name = TextEditingController();
  bool register = false, busy = false;
  String? message;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    final l = AppLocalizations.of(context)!;
    final auth = ref.read(backendProvider)!.auth;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      if (register) {
        final response = await auth.signUp(
          email: email.text.trim(),
          password: password.text,
          data: {'display_name': name.text.trim()},
        );
        if (response.session == null) {
          if (mounted) {
            setState(() {
              message = l.checkEmail;
              register = false;
            });
          }
          return;
        }
      } else {
        await auth.signInWithPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      }
    } catch (_) {
      if (mounted) setState(() => message = l.authError);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (ref.watch(backendProvider) == null) {
      return Scaffold(
        appBar: AppBar(),
        body: StatusPanel(message: l.setupBody),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(register ? l.signUp : l.signIn)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Form(
                key: form,
                child: AutofillGroup(
                  child: Column(
                    children: [
                      if (register) ...[
                        TextFormField(
                          controller: name,
                          maxLength: 100,
                          decoration: InputDecoration(labelText: l.displayName),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? l.requiredField
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(labelText: l.email),
                        validator: (v) =>
                            v != null &&
                                RegExp(
                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                ).hasMatch(v.trim())
                            ? null
                            : l.invalidEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        autofillHints: [
                          register
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        decoration: InputDecoration(labelText: l.password),
                        validator: (v) => v == null || v.isEmpty
                            ? l.requiredField
                            : register && v.length < 12
                            ? l.invalidPassword
                            : null,
                        onFieldSubmitted: (_) {
                          if (!busy) submit();
                        },
                      ),
                      const SizedBox(height: 24),
                      if (message != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(message!),
                        ),
                      if (busy) const LinearProgressIndicator(),
                      FilledButton(
                        onPressed: busy ? null : submit,
                        child: Text(register ? l.signUp : l.signIn),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () {
                                form.currentState!.reset();
                                setState(() {
                                  register = !register;
                                  message = null;
                                });
                              },
                        child: Text(register ? l.signIn : l.signUp),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
