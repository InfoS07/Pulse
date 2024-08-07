import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/core/common/entities/difficulty.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';

class ExercicePage extends StatefulWidget {
  final Exercice exercice;

  const ExercicePage({super.key, required this.exercice});

  @override
  _ExercicePageState createState() => _ExercicePageState();
}

class _ExercicePageState extends State<ExercicePage> {
  int _currentIndex = 0;
  List<ChewieController>? _chewieControllers;

  String? userId;

  @override
  void initState() {
    super.initState();
    _chewieControllers =
        widget.exercice.photos.where((url) => url.endsWith('.mp4')).map((url) {
      final videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(url));
      return ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: videoPlayerController.value.aspectRatio,
        autoPlay: true,
        looping: true,
      );
    }).toList();

    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
    }
  }

  @override
  void dispose() {
    _chewieControllers?.forEach((controller) {
      controller.dispose();
      controller.videoPlayerController.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sequence =
        widget.exercice.sequence.length > 0 ? "Suite" : "Aléatoire";
    final nbColor = widget.exercice.podCount > 0 ? widget.exercice.podCount : 3;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            scrolledUnderElevation: 0,
            backgroundColor: AppPallete.backgroundColor,
            centerTitle: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.5,
            floating: false,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                return FlexibleSpaceBar(
                  background: CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.8,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    items: widget.exercice.photos.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          if (url.endsWith('.mp4')) {
                            final chewieController = _chewieControllers!
                                .firstWhere((controller) =>
                                    controller
                                        .videoPlayerController.dataSource ==
                                    url);
                            return Chewie(controller: chewieController);
                          } else {
                            return Image.network(
                              url,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: top < 110.0 ? 1.0 : 0.0,
                    child: Text(widget.exercice.title),
                  ),
                );
              },
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.exercice.photos.map((url) {
                    int index = widget.exercice.photos.indexOf(url);
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? const Color.fromRGBO(66, 162, 31, 0.966)
                            : Colors.grey,
                      ),
                    );
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.exercice.title,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Row(
                            children: [
                              FaIcon(
                                size: 16,
                                FontAwesomeIcons.fire,
                                color: widget.exercice.difficulty ==
                                        Difficulty.easy
                                    ? Colors.green
                                    : widget.exercice.difficulty ==
                                            Difficulty.medium
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Wrap(
                            spacing: 8.0,
                            children:
                                widget.exercice.categories.map((category) {
                              return Chip(
                                label: Text(category),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Détails',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        widget.exercice.description,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Mise en place',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 22),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /* _buildInfoCard(
                                '${widget.exercice.playerCount}', 'Joueur'),
                            const SizedBox(width: 16), */
                            _buildInfoCard('${nbColor}', 'Pods',
                                FontAwesomeIcons.circleDot),
                            const SizedBox(width: 16),
                            _buildInfoCard('$sequence', 'Sequence',
                                FontAwesomeIcons.shuffle),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                      if (widget.exercice.premiums.contains(userId) ||
                          widget.exercice.price == 0)
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/activity', extra: widget.exercice);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPallete.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 36, vertical: 14),
                            ),
                            child: const Text(
                              'Pulser',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String value, String label, IconData icon) {
    return Container(
      width: 120,
      height: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppPallete.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                size: 12,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatelessWidget {
  final ChewieController controller;

  const VideoPlayerWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: controller);
  }
}
