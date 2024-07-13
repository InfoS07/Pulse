import 'package:flutter/material.dart';
import 'package:introduction_slider/introduction_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/home/presentation/pages/home_page.dart';

class IntroductionSliderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionSlider(
      items: [
        IntroductionSliderItem(
          logo: Column(
            children: [
              Image.asset(
                'assets/ic_logobg.png',
                height: 200,
              ),
              SizedBox(height: 50), // Adds space between image and text
            ],
          ),
          title: const Center(
            child: Text(
              "Bienvenue sur l'application Pulse",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: AppPallete.backgroundColor,
        ),
        IntroductionSliderItem(
          backgroundImageDecoration: BackgroundImageDecoration(
            image: const AssetImage('assets/images/background.png'),
          ),
          logo: Column(
            children: [
              Image.asset(
                'assets/images/avocado.png',
                height: 200,
              ),
              const SizedBox(height: 35), // Adds space between image and text
            ],
          ),
          title: const Center(
            child: Text(
              "Maintenez vous en forme grâce aux multiples exercices proposés.\n \n Des pods sont mis à votre disposition pour vous aider à atteindre vos objectifs!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        IntroductionSliderItem(
          logo: Column(
            children: [
              Image.asset(
                'assets/images/friends.png',
                height: 200,
              ),
              SizedBox(height: 50), // Adds space between image and text
            ],
          ),
          title: const Center(
            child: Text(
              "Partagez vos progrès et comparez vos performances en créant des défis. ",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          backgroundImageDecoration: BackgroundImageDecoration(
            image: const AssetImage('assets/images/background.png'),
          ),
          backgroundColor: AppPallete.backgroundColor,
        ),
      ],
      done: Done(
        child: ElevatedButton(
          onPressed: () {
            context.go('/login');
          },
          child: const Icon(
            Icons.check,
            color: Colors.green,
          ),
        ),
        home: null,
      ),
      next: const Next(child: Icon(Icons.arrow_forward)),
      back: const Back(child: Icon(Icons.arrow_back)),
      dotIndicator: const DotIndicator(
        selectedColor: Colors.white,
      ),
    );
  }
}
