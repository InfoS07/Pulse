import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/common/widgets/loader.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/show_snackbar.dart';
import 'package:pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pulse/features/auth/presentation/widgets/auth_field.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                      } else if (state is AuthSuccess) {
                        context.go('/home');
                      }
                    },
                    builder: (context, state) {
                      return Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/ic_logobg.png',
                              height: 100,
                            ),
                            const SizedBox(height: 20),
                            ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return const LinearGradient(
                                    colors: [
                                      AppPallete.primaryColor,
                                      AppPallete.secondaryColor
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                child: Animate(
                                  effects: [FadeEffect(), ScaleEffect()],
                                  child: Text(
                                    'PULSE',
                                    style: TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 30),
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
                            const SizedBox(height: 20),
                            AuthGradientButton(
                              buttonText: state is AuthLoading
                                  ? 'Connexion en cours...'
                                  : 'Se connecter',
                              onPressed: state is AuthLoading
                                  ? () {}
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        context.read<AuthBloc>().add(
                                              AuthLogin(
                                                email:
                                                    emailController.text.trim(),
                                                password: passwordController
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
                                context.go('/signup');
                              },
                              child: Center(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: 'Tu n\'es pas encore un pulseur?\n ',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    children: [
                                      TextSpan(
                                        text: 'Cree ton compte',
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
