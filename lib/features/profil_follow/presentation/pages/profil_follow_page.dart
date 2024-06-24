import 'package:flutter/material.dart';

class FollowProfile {
  final String profileImageUrl;
  final String username;
  final bool isFollowing;

  FollowProfile({
    required this.profileImageUrl,
    required this.username,
    required this.isFollowing,
  });
}

class ProfilFollowPage extends StatelessWidget {
  final List<FollowProfile> followers = [
    FollowProfile(
      profileImageUrl:
          'https://image-uniservice.linternaute.com/image/450/4/1708793598/8469657.jpg',
      username: 'Lacoste Nicolas',
      isFollowing: false,
    ),
    FollowProfile(
      profileImageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQPUXd-DRSv6xXUqE-_RaTJXf04IPJ4DYqK2EtjeRPvXHq4OCneqIblL4wKL1k_UX8D4l8&usqp=CAU',
      username: 'Lacoste Nicolas',
      isFollowing: true,
    ),
    FollowProfile(
      profileImageUrl:
          'https://i1.rgstatic.net/ii/profile.image/272583522254865-1442000384453_Q512/Thierry-Joubert.jpg',
      username: 'Lacoste Nicolas',
      isFollowing: false,
    ),
  ];

  final List<FollowProfile> following = [
    FollowProfile(
      profileImageUrl:
          'https://image-uniservice.linternaute.com/image/450/4/1708793598/8469657.jpg',
      username: 'Lacoste Nicolas',
      isFollowing: true,
    ),
    FollowProfile(
      profileImageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQPUXd-DRSv6xXUqE-_RaTJXf04IPJ4DYqK2EtjeRPvXHq4OCneqIblL4wKL1k_UX8D4l8&usqp=CAU',
      username: 'Lacoste Nicolas',
      isFollowing: false,
    ),
    FollowProfile(
      profileImageUrl:
          'https://i1.rgstatic.net/ii/profile.image/272583522254865-1442000384453_Q512/Thierry-Joubert.jpg',
      username: 'Lacoste Nicolas',
      isFollowing: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profil'),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Abonnés'),
              Tab(text: 'Abonnement'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFollowList(followers),
            _buildFollowList(following),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowList(List<FollowProfile> profiles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(profile.profileImageUrl),
                radius: 30,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  profile.username,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Action pour suivre / ne plus suivre
                },
                icon: profile.isFollowing
                    ? Icon(Icons.check, color: Colors.white)
                    : Icon(Icons.add, color: Colors.white),
                label: Text(
                  profile.isFollowing ? 'Suivi' : 'Suivre',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      profile.isFollowing ? Colors.grey : Colors.greenAccent,
                  side: BorderSide(
                      color: profile.isFollowing
                          ? Colors.grey
                          : Colors.greenAccent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
