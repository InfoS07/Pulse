import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/core/common/entities/exercice.dart';

class ExercicePage extends StatefulWidget {
  final Exercice exercice;

  ExercicePage({required this.exercice});

  @override
  _ExercicePageState createState() => _ExercicePageState();
}

class _ExercicePageState extends State<ExercicePage> {
  final List<String> imageUrls = [
    'https://images.pexels.com/photos/317157/pexels-photo-317157.jpeg?auto=compress&cs=tinysrgb&w=600',
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: MediaQuery.of(context).size.height * 0.5,
            floating: false,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                return FlexibleSpaceBar(
                  background: CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.5,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    items: imageUrls.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Image.network(
                            widget.exercice.urlPhoto,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      );
                    }).toList(),
                  ),
                  title: AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: top < 110.0 ? 1.0 : 0.0,
                    child: Text(widget.exercice.title),
                  ),
                );
              },
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
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
                  children: imageUrls.map((url) {
                    int index = imageUrls.indexOf(url);
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Color.fromRGBO(66, 162, 31, 0.966)
                            : Color.fromRGBO(8, 68, 235, 0.914),
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
                          const Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.fire,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text('Cardio'),
                            backgroundColor: Colors.grey[800],
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Chip(
                            label: Text('Course'),
                            backgroundColor: Colors.grey[800],
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Détails',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.exercice.description,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Informations complémentaires',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildInfoCard(
                              '${widget.exercice.duration}', 'Durée (min)'),
                          SizedBox(width: 16),
                          _buildInfoCard(
                              '${widget.exercice.caloriesBurned}', 'Calories'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildInfoCard('${widget.exercice.podCount}', 'Pods'),
                          SizedBox(width: 16),
                          _buildInfoCard('${widget.exercice.laps}', 'Tour'),
                        ],
                      ),
                      SizedBox(height: 60),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/activity', extra: widget.exercice);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 42, vertical: 16),
                          ),
                          child: const Text(
                            'Go',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 60),
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

  Widget _buildInfoCard(String value, String label) {
    return Container(
      width: 120,
      height: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
