import 'package:audioplayers/audioplayers.dart';
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
import 'package:pulse/core/utils/bottom_sheet_util.dart';
import 'package:pulse/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:pulse/core/common/entities/exercice.dart';

class ActivityPage extends StatefulWidget {
  final Exercice exercise;

  const ActivityPage(this.exercise, {super.key});

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer _timer = Timer(Duration.zero, () {});
  final ValueNotifier<Duration> _timeElapsed = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _reactionTime = ValueNotifier(Duration.zero);
  final player = AudioPlayer();

  final List<Map<String, String>> buzzerClass = [
    {"color": "Colors.purple", "stop": "a", "start": "1", "trigger": "z"},
    {"color": "Colors.yellow", "stop": "b", "start": "2", "trigger": "y"}
  ];

  final sequence = [1, 2];
  final repetitions = 10;

  int currentBuzzerIndex = 0;
  int currentRepetition = 0;
  bool isActive = false;

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
    isActive = false; // Initialisation de isActive
  }

  Future<void> checkBluetoothPermissionsAndState() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetooth,
        Permission.location
      ].request();

      if (statuses[Permission.bluetoothScan]!.isGranted &&
          statuses[Permission.bluetoothConnect]!.isGranted &&
          statuses[Permission.bluetooth]!.isGranted &&
          statuses[Permission.location]!.isGranted) {
        bool isOn = await FlutterBluePlus.isOn;
        if (isOn) {
          reconnectIfNecessary();
        } else {
          print('Bluetooth is off. Requesting to turn it on...');
        }
      } else {
        print('Bluetooth permissions not granted.');
      }
    } catch (e) {
      print('Error checking Bluetooth permissions and state: $e');
    }
  }

  Future<void> reconnectIfNecessary() async {
    try {
      for (var device in FlutterBluePlus.connectedDevices) {
        if (device.name == 'Pulse') {
          connectToDevice(device);
          return;
        }
      }
      startScan();
    } catch (e) {
      print('Error reconnecting to Bluetooth device: $e');
    }
  }

  void startScan() {
    if (!isScanning) {
      FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.name == 'Pulse') {
            FlutterBluePlus.stopScan();
            connectToDevice(r.device);
            break;
          }
        }
      }).onDone(() {
        setState(() {
          isScanning = false;
        });
      });
    }
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
          }
        }
      }
    }
    turnOffAllBuzzer();
  }

  void sendDeviceNotification(String value) async {
    if (notifyCharacteristic != null) {
      await notifyCharacteristic!.write(utf8.encode(value));
    }
  }

  void turnOffAllBuzzer() {
    for (var buzzer in buzzerClass) {
      sendDeviceNotification(buzzer['stop']!);
    }
  }

  void startBuzzerSequence() {
    turnOffAllBuzzer();
    currentBuzzerIndex = 0;
    currentRepetition = 0;
    activateNextBuzzer();
  }

  void activateNextBuzzer() {
    if (currentRepetition < repetitions) {
      setState(() {
        isActive = true;
      });
      sendDeviceNotification(buzzerClass[currentBuzzerIndex]['start']!);
    }
  }

  void handleNotification(List<int> value) {
    if (!_isRunning || !isActive) return; // Ignorer si inactif ou en pause

    String decodedValue = utf8.decode(value);
    DateTime currentTime = DateTime.now();

    if (decodedValue == buzzerClass[currentBuzzerIndex]['trigger']) {
      player.play(AssetSource('sounds/allez-le-nwoar.mp3'));
      setState(() {
        messageCount++;
        if (lastNotificationTime != null) {
          _reactionTime.value = currentTime.difference(lastNotificationTime!);
        }
        lastNotificationTime = currentTime;
      });

      sendDeviceNotification(buzzerClass[currentBuzzerIndex]['stop']!);
      currentBuzzerIndex = (currentBuzzerIndex + 1) % buzzerClass.length;

      if (currentBuzzerIndex == 0) {
        currentRepetition++;
      }

      activateNextBuzzer();
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

  void _startStopTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      setState(() {
        _isPaused = false;
        isActive = true;
      });
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        _timeElapsed.value =
            _timeElapsed.value + const Duration(milliseconds: 10);
        _activityBloc.add(UpdateActivity(
          timeElapsed: _timeElapsed.value,
          touches: messageCount,
          misses: 4,
          caloriesBurned: 200,
        ));
      });
      startBuzzerSequence();
    } else {
      setState(() {
        _isPaused = true;
        isActive = false;
      });
      _timer.cancel();
      _showDeleteDialog();
    }
  }

  void _showDeleteDialog() {
    BottomSheetUtil.showCustomBottomSheet(
      context,
      onConfirm: () {
        _activityBloc.add(UpdateActivity(
          timeElapsed: _timeElapsed.value,
          touches: messageCount,
          misses: 4,
          caloriesBurned: 200,
        ));
        _activityBloc.add(StopActivity(_timeElapsed.value));
        context.push('/activity/save');
      },
      onCancel: () {
        _startStopTimer();
      },
      buttonText: 'Terminer',
      buttonColor: AppPallete.primaryColor,
      cancelText: 'Reprendre',
      cancelTextColor: Colors.grey,
    );
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

  void _showPauseModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 62),
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _startStopTimer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: AppPallete.primaryColor),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                    misses: 4,
                    caloriesBurned: 200,
                  ));
                  _activityBloc.add(StopActivity(_timeElapsed.value));
                  context.push('/activity/save');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Terminer',
                    style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BuzzerIndicator(
                                  isActive: currentBuzzerIndex == 0,
                                  color: Colors.purple,
                                ),
                                const SizedBox(width: 16),
                                BuzzerIndicator(
                                  isActive: currentBuzzerIndex == 1,
                                  color: Colors.yellow,
                                ),
                              ],
                            ),
                            const SizedBox(height: 64),
                            GestureDetector(
                              onTap: () => _startStopTimer(),
                              child: Container(
                                width: 300,
                                decoration: BoxDecoration(
                                  color: AppPallete.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                margin: const EdgeInsets.only(top: 32),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ConstrainedBox(
                                      constraints:
                                          BoxConstraints(minWidth: 100),
                                      child: ValueListenableBuilder<Duration>(
                                        valueListenable: _timeElapsed,
                                        builder: (context, value, child) {
                                          return Text(
                                            _formatTime(value),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      _isRunning
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.black,
                                      size: 32,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Tour 1/${widget.exercise.laps}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.red,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: DraggableScrollableSheet(
                      initialChildSize: 1.0,
                      minChildSize: 0.2,
                      maxChildSize: 1.0,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return Container(
                          color: Colors.blueAccent,
                          padding: const EdgeInsets.all(16.0),
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
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.notifications_active,
                                        color: Colors.white),
                                    onPressed: () {
                                      sendDeviceNotification("1");
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh,
                                        color: Colors.white),
                                    onPressed: () {
                                      if (connectedDevice == null) {
                                        reconnectIfNecessary();
                                      } else {
                                        discoverServices();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'État de la connexion : $connectionStatus',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildInfoCard('4', 'Erreurs'),
                                      _buildInfoCard(
                                          messageCount.toString(), 'Touches',
                                          highlight: true),
                                      ValueListenableBuilder<Duration>(
                                        valueListenable: _reactionTime,
                                        builder: (context, value, child) {
                                          return _buildInfoCard(
                                              _formatReactionTime(value),
                                              'Réaction');
                                        },
                                      ),
                                    ],
                                  ),
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
              if (_isPaused)
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? Colors.grey[800] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class BuzzerIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const BuzzerIndicator({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: isActive ? color : Colors.grey,
    );
  }
}

void showExitConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Confirmation',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir quitter l\'activité ?',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text(
              'Confirmer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
