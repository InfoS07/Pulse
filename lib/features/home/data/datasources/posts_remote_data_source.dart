import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/common/entities/post.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';

abstract class PostsRemoteDataSource {
  Future<List<SocialMediaPost>> getPosts();
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  @override
  Future<List<SocialMediaPost>> getPosts() async {
    return Future.value([
      SocialMediaPost(
        title: 'Course à pied matinale',
        profileImageUrl:
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
        postImageUrl:
            'https://images.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg',
        username: 'Jean',
        timestamp: DateTime.now().subtract(Duration(hours: 1)).toString(),
        content:
            'J\'ai fait une course à pied de 5 km ce matin, ça fait du bien!',
        likes: 23,
        comments: [
          Comment(
            profileImageUrl:
                'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
            username: 'Marie',
            timestamp: DateTime.now().subtract(Duration(hours: 2)).toString(),
            content: 'Bravo Jean, tu es un vrai sportif!',
          ),
          Comment(
            profileImageUrl:
                'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
            username: 'Pierre',
            timestamp: DateTime.now().subtract(Duration(hours: 2)).toString(),
            content: 'Tu es une source d\'inspiration Jean!',
          ),
        ],
      ),
      SocialMediaPost(
        title: 'Séance de yoga',
        profileImageUrl:
            'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
        postImageUrl:
            'https://images.pexels.com/photos/356378/pexels-photo-356378.jpeg',
        username: 'Marie',
        timestamp: DateTime.now().subtract(Duration(hours: 2)).toString(),
        content:
            'Le yoga est vraiment relaxant. Voici quelques photos de ma séance d\'aujourd\'hui.',
        likes: 45,
        comments: [
          Comment(
            profileImageUrl:
                'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
            username: 'Jean',
            timestamp: DateTime.now().subtract(Duration(hours: 3)).toString(),
            content: 'Tu es très souple Marie!',
          ),
          Comment(
            profileImageUrl:
                'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
            username: 'Pierre',
            timestamp: DateTime.now().subtract(Duration(hours: 3)).toString(),
            content: 'Tu es une vraie pro Marie!',
          ),
        ],
      ),
      SocialMediaPost(
        title: 'Entraînement HIIT',
        profileImageUrl:
            'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
        postImageUrl:
            'https://images.pexels.com/photos/221210/pexels-photo-221210.jpeg',
        username: 'Pierre',
        timestamp: DateTime.now().subtract(Duration(days: 1)).toString(),
        content:
            'J\'ai essayé une nouvelle routine HIIT aujourd\'hui, je suis épuisé mais c\'était génial!',
        likes: 67,
        comments: [
          Comment(
            profileImageUrl:
                'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
            username: 'Jean',
            timestamp: DateTime.now().subtract(Duration(days: 2)).toString(),
            content: 'Bravo Pierre, tu es un vrai guerrier!',
          ),
          Comment(
            profileImageUrl:
                'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
            username: 'Marie',
            timestamp: DateTime.now().subtract(Duration(days: 2)).toString(),
            content: 'Tu es une source d\'inspiration Pierre!',
          ),
          Comment(
            profileImageUrl:
                'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
            username: 'Pierre',
            timestamp: DateTime.now().subtract(Duration(days: 2)).toString(),
            content: 'Merci les amis, vous êtes géniaux!',
          ),
        ],
      ),
      SocialMediaPost(
          title: 'Randonnée en montagne',
          profileImageUrl:
              'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
          postImageUrl:
              'https://images.pexels.com/photos/239520/pexels-photo-239520.jpeg',
          username: 'Paul',
          timestamp: DateTime.now().subtract(Duration(days: 2)).toString(),
          content:
              'Une magnifique randonnée en montagne aujourd\'hui, la vue était incroyable!',
          likes: 89,
          comments: [
            Comment(
              profileImageUrl:
                  'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
              username: 'Jean',
              timestamp: DateTime.now().subtract(Duration(days: 3)).toString(),
              content: 'Bravo Paul, tu as l\'air en forme!',
            ),
            Comment(
              profileImageUrl:
                  'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
              username: 'Marie',
              timestamp: DateTime.now().subtract(Duration(days: 3)).toString(),
              content: 'Tu as de la chance, j\'aurais aimé être là!',
            ),
            Comment(
              profileImageUrl:
                  'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
              username: 'Pierre',
              timestamp: DateTime.now().subtract(Duration(days: 3)).toString(),
              content: 'Tu es un vrai aventurier Paul!',
            ),
          ]),
      SocialMediaPost(
          title: 'Nouveau record de pompes',
          profileImageUrl:
              'https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg',
          postImageUrl:
              'https://images.pexels.com/photos/416809/pexels-photo-416809.jpeg',
          username: 'Alice',
          timestamp: DateTime.now().subtract(Duration(days: 3)).toString(),
          content:
              'J\'ai battu mon record de pompes aujourd\'hui, 50 en une minute!',
          likes: 120,
          comments: [
            Comment(
              profileImageUrl:
                  'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
              username: 'Jean',
              timestamp: DateTime.now().subtract(Duration(days: 3)).toString(),
              content: 'Bravo Alice, tu es une machine!',
            ),
            Comment(
              profileImageUrl:
                  'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
              username: 'Marie',
              timestamp: DateTime.now().subtract(Duration(days: 3)).toString(),
              content: 'Incroyable, je suis impressionnée!',
            ),
            Comment(
              profileImageUrl:
                  'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
              username: 'Pierre',
              timestamp: DateTime.now().subtract(Duration(days: 3)).toString(),
              content: 'Tu es une source d\'inspiration Alice!',
            ),
          ])
    ]);
  }
}
