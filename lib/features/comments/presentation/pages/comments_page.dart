import 'package:flutter/material.dart';
import 'package:pulse/core/common/entities/comment.dart';

class CommentsPage extends StatelessWidget {
  final List<Comment> comments = [
    Comment(
      profileImageUrl:
          'https://image-uniservice.linternaute.com/image/450/4/1708793598/8469657.jpg',
      username: 'T-O',
      timestamp: '12/01/2024 - 12:46',
      content: 'Trop performant le rafiq par contre. Sextianal ce soir ?',
    ),
    Comment(
      profileImageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQPUXd-DRSv6xXUqE-_RaTJXf04IPJ4DYqK2EtjeRPvXHq4OCneqIblL4wKL1k_UX8D4l8&usqp=CAU',
      username: 'Bank gank',
      timestamp: '13/01/2024 - 08:05',
      content: 'Belle perf, mais petite bite :(',
    ),
    Comment(
      profileImageUrl:
          'https://i1.rgstatic.net/ii/profile.image/272583522254865-1442000384453_Q512/Thierry-Joubert.jpg',
      username: 'Unsacrépaquet',
      timestamp: '14/01/2024 - 19:52',
      content: 'Mouais, je fais mieux a ma femme',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discussion'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://media.licdn.com/dms/image/C5603AQGS7eAEozhDzw/profile-displayphoto-shrink_200_200/0/1562875334307?e=2147483647&v=beta&t=Pp3nnMsNgTceqPRuxDHG1NU-3wEA_hQR3lL5ru1Ghvw'),
                  radius: 20,
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lacoste Nicolas',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '12/01/2024 - 12:45',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Une séance bien dure',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.comment, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  '3 commentaires',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(color: Colors.grey[800]),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(comment.profileImageUrl),
                          radius: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    comment.username,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    comment.timestamp,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                comment.content,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
