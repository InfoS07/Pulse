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
          backgroundImageDecoration: BackgroundImageDecoration(
            image: const AssetImage('assets/images/background-1.png'),
          ),
          logo: Column(
            children: [
              Image.asset(
                'assets/ic_logobg.png',
                height: 200,
              ),
              SizedBox(height: 240), // Adds space between image and text
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
            image: const AssetImage('assets/images/background-1.png'),
          ),
          logo: Column(
            children: [
              Image.asset(
                'assets/images/avocado.png',
                height: 200,
              ),
              SizedBox(height: 240), // Adds space between image and text
            ],
          ),
          title: const Center(
            child: Text(
              "Développer votre physique et vos réflexes \n grâce à des exercices assistés \n à l'aide de pods connectés !",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
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
              SizedBox(height: 240), // Adds space between image and text
            ],
          ),
          title: const Center(
            child: Text(
              "Partagez vos progrès et comparez vos performances en créant des défis. ",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          backgroundImageDecoration: BackgroundImageDecoration(
            image: const AssetImage('assets/images/background-1.png'),
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
