import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;

import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:pulse/core/common/entities/exercice.dart';

class ActivityPage extends StatefulWidget {
  final Exercice exercise;

  const ActivityPage(this.exercise);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late Timer _timer;
  final ValueNotifier<Duration> _timeElapsed = ValueNotifier(Duration.zero);
  bool _isRunning = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
    BlocProvider.of<ActivityBloc>(context).add(StartActivity(widget.exercise));
  }

  @override
  void dispose() {
    _timer.cancel();
    _timeElapsed.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _isRunning) {
      _showPersistentNotification();
    } else if (state == AppLifecycleState.resumed) {
      _cancelNotification();
    }
  }

  void _initializeNotifications() {
    if (Platform.isAndroid) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      flutterLocalNotificationsPlugin.initialize(initializationSettings);
    }
  }

  void _showPersistentNotification() async {
    if (Platform.isAndroid) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true,
        playSound: false,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        0,
        'Chronomètre en cours',
        'Le chronomètre est toujours en cours d\'exécution.',
        platformChannelSpecifics,
      );
    }
  }

  void _cancelNotification() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.cancel(0);
    }
  }

  void _startStopTimer(BuildContext context) {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      setState(() {
        _isPaused = false;
      });
      _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
        _timeElapsed.value = _timeElapsed.value + Duration(milliseconds: 10);
        BlocProvider.of<ActivityBloc>(context).add(UpdateActivity(
          timeElapsed: _timeElapsed.value,
          touches: 23, // Exemple de valeur
          misses: 4, // Exemple de valeur
          caloriesBurned: 200, // Exemple de valeur
        ));
      });
    } else {
      setState(() {
        _isPaused = true;
      });
      _timer.cancel();
      _showPauseModal(context);
    }
  }

  void _showPauseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 62),
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _closePauseModal();
                  _startStopTimer(context); // Reprendre
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: AppPallete.primaryColor),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text('Reprendre',
                    style: TextStyle(
                        fontSize: 18, color: AppPallete.primaryColor)),
              ),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<ActivityBloc>(context).add(StopActivity(
                    _timeElapsed.value,
                  ));
                  context.push('/activity/save');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text('Terminer',
                    style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _closePauseModal() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds =
        twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
    return '$minutes:$seconds:$milliseconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showExitConfirmationDialog(
              context,
              () {
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      body: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${state.activity.caloriesBurned}',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24),
                            ),
                            Text(
                              'Calories brûlées',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SizedBox(height: 32),
                            ValueListenableBuilder<Duration>(
                              valueListenable: _timeElapsed,
                              builder: (context, value, child) {
                                return Text(
                                  _formatTime(value),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                            Text(
                              'Tour 1/4',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SizedBox(height: 32),
                            GestureDetector(
                              onTap: () => _startStopTimer(context),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: AppPallete.primaryColor,
                                child: Icon(
                                  _isRunning ? Icons.pause : Icons.play_arrow,
                                  color: Colors.black,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height *
                        0.4, // Définit une hauteur fixe pour le tiroir
                    child: DraggableScrollableSheet(
                      initialChildSize: 1.0,
                      minChildSize: 0.2,
                      maxChildSize: 1.0,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return Container(
                          color: Colors.black,
                          padding: EdgeInsets.all(16.0),
                          child: ListView(
                            controller: scrollController,
                            children: [
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Voir exercices',
                                    style: TextStyle(
                                        color: AppPallete.primaryColor,
                                        fontSize: 16),
                                  ),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                          radius: 6,
                                          backgroundColor: Colors.greenAccent),
                                      SizedBox(width: 4),
                                      CircleAvatar(
                                          radius: 6,
                                          backgroundColor: Colors.grey),
                                      SizedBox(width: 4),
                                      CircleAvatar(
                                          radius: 6,
                                          backgroundColor: Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildInfoCard('4', 'touches ratés'),
                                  _buildInfoCard('23', 'Touches',
                                      highlight: true),
                                  _buildInfoCard('200', 'temps reac'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (_isPaused) // Appliquer le flou seulement si le chronomètre est en pause
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String value, String label, {bool highlight = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? Colors.grey[800] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

void showExitConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          'Confirmation',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir quitter l\'activité ?',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Ferme le dialogue sans confirmer
            },
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Ferme le dialogue
              onConfirm(); // Appelle la fonction de confirmation
            },
            child: Text(
              'Confirmer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
