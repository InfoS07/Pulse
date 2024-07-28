import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/analytics.dart';
import 'package:pulse/core/common/widgets/loader.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/show_snackbar.dart';
import 'package:pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pulse/features/auth/presentation/widgets/auth_field.dart';
import 'package:pulse/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:go_router/go_router.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _dismissKeyboard,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthFailure) {
                        ToastService.showErrorToast(
                          context,
                          length: ToastLength.long,
                          expandedHeight: 100,
                          message: state.message,
                        );
                        //showSnackBar(context, state.message);
                      } else if (state is AuthSuccess) {
                        context.pushReplacement('/intro-slider');
                      }
                    },
                    builder: (context, state) {
                      return Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Inscription',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),
                            AuthField(
                              hintText: 'Prénom',
                              controller: firstNameController,
                            ),
                            const SizedBox(height: 15),
                            AuthField(
                              hintText: 'Nom',
                              controller: lastNameController,
                            ),
                            const SizedBox(height: 15),
                            AuthField(
                              hintText: 'Email',
                              controller: emailController,
                            ),
                            const SizedBox(height: 15),
                            AuthField(
                              hintText: 'Mot de passe',
                              controller: passwordController,
                              isObscureText: true,
                            ),
                            const SizedBox(height: 60),
                            AuthGradientButton(
                              buttonText: state is AuthLoading
                                  ? 'Inscriptions en cours...'
                                  : 'S\'inscrire',
                              onPressed: state is AuthLoading
                                  ? () {}
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        AnalyticsManager.of(context)
                                            .analytics
                                            .setUserProperty(
                                                name: "role", value: "new");
                                        context.read<AuthBloc>().add(
                                              AuthSignUp(
                                                email:
                                                    emailController.text.trim(),
                                                password: passwordController
                                                    .text
                                                    .trim(),
                                                firstName: firstNameController
                                                    .text
                                                    .trim(),
                                                lastName: lastNameController
                                                    .text
                                                    .trim(),
                                              ),
                                            );
                                      }
                                    },
                            ),
                            const SizedBox(height: 60),
                            GestureDetector(
                              onTap: () {
                                context.pushReplacement('/login');
                              },
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: 'Vous avez déjà un compte ? ',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  children: [
                                    TextSpan(
                                      text: 'Se connecter',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppPallete.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
