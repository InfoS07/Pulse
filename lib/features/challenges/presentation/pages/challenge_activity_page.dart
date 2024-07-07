import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:pulse/core/common/entities/exercice.dart';

class ActivityChallengePage extends StatefulWidget {
  final Exercice exercise;

  const ActivityChallengePage(this.exercise);

  @override
  _ActivityChallengePageState createState() => _ActivityChallengePageState();
}

class _ActivityChallengePageState extends State<ActivityChallengePage>
    with WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer _timer = Timer(Duration.zero, () {});
  final ValueNotifier<Duration> _timeElapsed = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _reactionTime = ValueNotifier(Duration.zero);

  late ActivityBloc _activityBloc;

  bool _isRunning = false;
  bool _isPaused = false;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? notifyCharacteristic;
  int messageCount = 0;
  bool isScanning = false;
  DateTime? lastNotificationTime;
  String connectionStatus = 'Déconnecté';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
    _activityBloc = BlocProvider.of<ActivityBloc>(context);
    _activityBloc.add(StartActivity(widget.exercise));
    checkBluetoothPermissionsAndState();
  }

  Future<void> checkBluetoothPermissionsAndState() async {
    try {
      PermissionStatus bluetoothScanPermission =
          await Permission.bluetoothScan.request();
      PermissionStatus bluetoothConnectPermission =
          await Permission.bluetoothConnect.request();

      if (bluetoothScanPermission.isGranted &&
          bluetoothConnectPermission.isGranted) {
        bool isOn = await FlutterBluePlus.isOn;
        if (isOn) {
          reconnectIfNecessary();
        } else {
          print('Bluetooth is off. Requesting to turn it on...');
          // Code to request user to turn on Bluetooth
        }
      } else {
        print('Bluetooth permissions not granted.');
        // Handle permission not granted
      }
    } catch (e) {
      print('Error checking Bluetooth permissions and state: $e');
    }
  }

  Future<void> reconnectIfNecessary() async {
    try {
      FlutterBluePlus.connectedDevices.forEach((device) {
        print('reconnectIfNecessary...');
        print(device.platformName);
        if (device.platformName == 'Pulse') {
          print('Reconnecting to device...');
          connectToDevice(device);
          return;
        }
      });
      startScan();
    } catch (e) {
      print('Error reconnecting to Bluetooth device: $e');
    }
  }

  void startScan() {
    print('startScan...');
    print(!isScanning);
    if (!isScanning) {
      setState(() {
        isScanning = true;
      });
      FlutterBluePlus.startScan();
      FlutterBluePlus.scanResults.listen((results) {
        print('FlutterBluePlus...');
        for (ScanResult r in results) {
          print('Device found: ${r.device.platformName}');
          if (r.device.platformName == 'Pulse') {
            FlutterBluePlus.stopScan();
            connectToDevice(r.device);
            break;
          }
        }
      });
    }
    setState(() {
      isScanning = false;
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
      connectionStatus = 'Connecté';
    });
    discoverServices();
  }

  void discoverServices() async {
    if (connectedDevice == null) return;

    List<BluetoothService> services = await connectedDevice!.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == "4fafc201-1fb5-459e-8fcc-c5c9c331914b") {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString() ==
              "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
            setState(() {
              notifyCharacteristic = characteristic;
            });
            await characteristic.setNotifyValue(true);
            characteristic.value.listen((value) {
              handleNotification(value);
            });
            print('Sending OK notification...');
            characteristic.write(utf8.encode("ok"));
          }
        }
      }
    }
  }

  void sendDeviceNotification() async {
    print('Sending device notification...');
    if (notifyCharacteristic != null) {
      await notifyCharacteristic!.write(utf8.encode("ok"));
    }
  }

  void handleNotification(List<int> value) {
    String decodedValue = utf8.decode(value);
    DateTime currentTime = DateTime.now();
    if (decodedValue == "ok" &&
        (lastNotificationTime == null ||
            currentTime.difference(lastNotificationTime!).inMilliseconds >
                100)) {
      setState(() {
        messageCount++;
        if (lastNotificationTime != null) {
          _reactionTime.value = currentTime.difference(lastNotificationTime!);
        }
      });
      lastNotificationTime = currentTime;
    }
  }

  @override
  void dispose() {
    connectedDevice?.disconnect();
    _timer.cancel();
    _timeElapsed.dispose();
    _reactionTime.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  void _startStopTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      setState(() {
        _isPaused = false;
      });
      _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
        _timeElapsed.value = _timeElapsed.value + Duration(milliseconds: 10);
        _activityBloc.add(UpdateActivity(
          timeElapsed: _timeElapsed.value,
          touches: messageCount,
          misses: 4, // Exemple de valeur
          caloriesBurned: 200, // Exemple de valeur
        ));
      });
    } else {
      setState(() {
        _isPaused = true;
      });
      _timer.cancel();
      _showPauseModal();
    }
  }

  void _showPauseModal() {
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
                  _startStopTimer(); // Reprendre
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: AppPallete.primaryColor),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Reprendre',
                    style: TextStyle(
                        fontSize: 18, color: AppPallete.primaryColor)),
              ),
              ElevatedButton(
                onPressed: () {
                  _activityBloc.add(UpdateActivity(
                    timeElapsed: _timeElapsed.value,
                    touches: messageCount,
                    misses: 4, // Exemple de valeur
                    caloriesBurned: 200, // Exemple de valeur
                  ));

                  _activityBloc.add(StopActivity(
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

  String _formatReactionTime(Duration duration) {
    final milliseconds = duration.inMilliseconds;
    return '${milliseconds}ms';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.title),
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
                              'Tour 1/${widget.exercise.laps}',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SizedBox(height: 32),
                            GestureDetector(
                              onTap: () => _startStopTimer(),
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
                    color: Colors.red,
                    height: MediaQuery.of(context).size.height *
                        0.5, // Définit une hauteur fixe pour le tiroir
                    child: DraggableScrollableSheet(
                      initialChildSize: 1.0,
                      minChildSize: 0.2,
                      maxChildSize: 1.0,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return Container(
                          color: Colors.blueAccent,
                          padding: EdgeInsets.all(16.0),
                          child: ListView(
                            controller: scrollController,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Voir exercices',
                                    style: TextStyle(
                                        color: AppPallete.primaryColor,
                                        fontSize: 16),
                                  ),
                                  const Row(
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
                                  IconButton(
                                    icon: Icon(Icons.notifications_active,
                                        color: Colors.white),
                                    onPressed: () {
                                      sendDeviceNotification();
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.refresh,
                                        color: Colors.white),
                                    onPressed: () {
                                      print('Reconnecting...');
                                      print(connectedDevice);
                                      if (connectedDevice == null) {
                                        reconnectIfNecessary();
                                      } else {
                                        discoverServices();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'État de la connexion : $connectionStatus',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 16),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildInfoCard(
                                      messageCount.toString(), 'Touches',
                                      highlight: true),
                                  ValueListenableBuilder<Duration>(
                                    valueListenable: _reactionTime,
                                    builder: (context, value, child) {
                                      return _buildInfoCard(
                                          _formatReactionTime(value),
                                          'Temps de réaction');
                                    },
                                  ),
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
              Navigator.of(context).pop();
            },
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
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
