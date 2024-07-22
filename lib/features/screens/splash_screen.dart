import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/widgets/loader.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go('/home');
          } else if (state is AuthFailure) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const RippleAnimation(
                    child: CircleAvatar(
                      minRadius: 75,
                      maxRadius: 75,
                      backgroundImage: AssetImage('assets/ic_logobg.png'),
                    ),
                    color: AppPallete.primaryColor,
                    delay: const Duration(milliseconds: 300),
                    repeat: true,
                    minRadius: 75,
                    ripplesCount: 6,
                    duration: const Duration(milliseconds: 6 * 300),
                  ),
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
                  SizedBox(height: 20),
                  Text(
                    'Bienvenue !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .white, // Ajout de couleur blanche pour le texte
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nous préparons votre expérience...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors
                          .white, // Ajout de couleur blanche pour le texte
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
