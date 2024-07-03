import 'package:flutter/material.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/home/presentation/pages/home_page.dart';
import 'package:pulse/features/widget/news_data.dart';

class Challenge {
  final String title;
  final String description;
  final String status;
  final Color statusColor;
  final Color textColor;

  Challenge({
    required this.title,
    required this.description,
    required this.status,
    required this.statusColor,
    this.textColor = AppPallete.backgroundColor,
  });
}

class GroupPage extends StatelessWidget {
  final List<Challenge> challenges = [
    Challenge(
      title: 'Réaliser 3 entraînements',
      description: 'Atteignez 1000 calories brûlées aujourd’hui\nDu 20 juin au 23 juin 2024',
      status: 'Accepter',
      statusColor: AppPallete.primaryColor,
    ),
    Challenge(
      title: 'Réaliser 3 entraînements',
      description: 'Atteignez 1000 calories brûlées aujourd’hui\nDu 20 juin au 23 juin 2024',
      status: 'En cours',
      statusColor: AppPallete.primaryColorFade,
      textColor: AppPallete.primaryColor,
    ),
    Challenge(
      title: 'Réaliser 3 entraînements',
      description: 'Atteignez 1000 calories brûlées aujourd’hui\nDu 20 juin au 23 juin 2024',
      status: 'Échoué',
      statusColor: AppPallete.errorColorFade,
      textColor: AppPallete.errorColor,
    ),
    Challenge(
      title: 'Réaliser 3 entraînements',
      description: 'Atteignez 1000 calories brûlées aujourd’hui\nDu 20 juin au 23 juin 2024',
      status: 'Échoué',
      statusColor: AppPallete.errorColorFade,
      textColor: AppPallete.errorColor,
    ),
    Challenge(
      title: 'Réaliser 3 entraînements',
      description: 'Atteignez 1000 calories brûlées aujourd’hui\nDu 20 juin au 23 juin 2024',
      status: 'Échoué',
      statusColor: AppPallete.errorColorFade,
      textColor: AppPallete.errorColor,
    ),
    // Ajoutez d'autres challenges si nécessaire
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Groupe'),
          bottom: const TabBar(
            indicatorColor: AppPallete.primaryColor,
            indicatorWeight: 3.0,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                child: Text(
                  'En cours',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Challenges',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Mettre à jour',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChallengeGrid(),
            _buildChallengeGrid(),
            _buildUpdateTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return _buildChallengeCard(challenge);
        },
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white, width: 0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Text(
                challenge.description,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: challenge.statusColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  challenge.status,
                  style: TextStyle(
                      color: challenge.textColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateTab(BuildContext context) {
    return Center(
      child: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Updating home screen widget...')),
          );
          // New: call updateHeadline
          final newHeadline = getNewsStories()[1]; // Assurez-vous que getNewsStories est disponible
          updateHeadline(newHeadline);
        },
        label: const Text('Update Homescreen'),
      ),
    );
  }
}
