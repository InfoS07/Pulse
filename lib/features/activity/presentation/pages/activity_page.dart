import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
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
import 'package:pulse/features/activity/presentation/widgets/buzzer_indicator.dart';

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
    {"color": "Colors.red", "stop": "a", "start": "1", "trigger": "z"},
    {"color": "Colors.blue", "stop": "b", "start": "2", "trigger": "y"},
    {"color": "Colors.green", "stop": "c", "start": "3", "trigger": "x"}
  ];

  final sequence = [1, 2, 3];
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
  int errorCount = 0; // Variable pour compter les erreurs
  bool isScanning = false;
  DateTime? lastNotificationTime;
  final ValueNotifier<String> connectionStatusNotifier =
      ValueNotifier('Recherche d\'appareils');

  // Dynamically created notifiers
  final Map<String, ValueNotifier<bool>> buzzerActivatedNotifiers = {
    "red": ValueNotifier(false),
    "blue": ValueNotifier(false),
    "green": ValueNotifier(false),
  };

  final Map<String, ValueNotifier<bool>> buzzerSyncedNotifiers = {
    "red": ValueNotifier(false),
    "blue": ValueNotifier(false),
    "green": ValueNotifier(false),
  };

  List<String> activeBuzzers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
    _activityBloc = BlocProvider.of<ActivityBloc>(context);
    _activityBloc.add(StartActivity(widget.exercise));
    _checkBluetoothState();
  }

  Future<void> _checkBluetoothState() async {
    if (await FlutterBluePlus.isOn) {
      checkBluetoothPermissionsAndState();
    } else {
      _showBluetoothActivationDialog();
    }
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
        _startBluetoothStateListener();
        reconnectIfNecessary();
      } else {
        print('Bluetooth permissions not granted.');
      }
    } catch (e) {
      print('Error checking Bluetooth permissions and state: $e');
    }
  }

  void _startBluetoothStateListener() {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        _showBluetoothActivationDialog();
      } else if (state == BluetoothAdapterState.on) {
        reconnectIfNecessary();
      }
    });
  }

  Future<void> reconnectIfNecessary() async {
    try {
      for (var device in await FlutterBluePlus.connectedDevices) {
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
      setState(() {
        isScanning = true;
      });
      FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
      FlutterBluePlus.scanResults.listen((results) {
        print('Scanning... $results');

        for (ScanResult r in results) {
          print('Scanning... $r');
          if (r.device.name == 'Pulse') {
            FlutterBluePlus.stopScan();
            connectToDevice(r.device);
            break;
          }
        }
      }).onDone(() {
        print('isScanning... $isScanning');
        print('connectedDevice... $connectedDevice');
        /* setState(() {
          isScanning = false;
        }); */
        if (connectedDevice == null) {
          _showConnectionErrorDialog();
        }
      });
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      connectionStatusNotifier.value = 'Connexion à l\'appareil...';
      setState(() {
        connectedDevice = device;
      });
      discoverServices();
    } catch (e) {
      print('Error connecting to device: $e');
    }
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
    connectionStatusNotifier.value = 'Les buzzers ont été trouvés';
    turnOffAllBuzzer();
    _showSyncDialog();
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
    setState(() {
      isActive = true;
    });

    if (activeBuzzers.isNotEmpty) {
      print('nextBuzzerColor: $activeBuzzers');
      String nextBuzzerColor = activeBuzzers[currentBuzzerIndex];
      String nextBuzzerStartCommand = buzzerClass.firstWhere((buzzer) =>
          buzzer['color']!.split('.').last == nextBuzzerColor)['start']!;
      print('currentBuzzerIndex: $currentBuzzerIndex');
      print('nextBuzzerColor: $nextBuzzerColor');
      print('nextBuzzerStartCommand: $nextBuzzerStartCommand');
      /* currentBuzzerIndex = buzzerClass.indexOf(buzzerClass.firstWhere(
          (buzzer) => buzzer['color']!.split('.').last == nextBuzzerColor)); */
      sendDeviceNotification(nextBuzzerStartCommand);
    }
  }

  void handleNotification(List<int> value) {
    String decodedValue = utf8.decode(value);
    DateTime currentTime = DateTime.now();

    // Synchronize buzzers
    buzzerClass.forEach((buzzer) {
      if (!buzzerSyncedNotifiers[buzzer["color"]!.split('.').last]!.value &&
          decodedValue == buzzer["trigger"]) {
        //player.play(AssetSource('sounds/notif.mp3'));
        buzzerSyncedNotifiers[buzzer["color"]!.split('.').last]!.value = true;
        if (!activeBuzzers.contains(buzzer["color"]!.split('.').last)) {
          setState(() {
            activeBuzzers.add(buzzer["color"]!.split('.').last);
          });

          if (activeBuzzers.length <= widget.exercise.podCount) {
            Navigator.pop(context);
            _showSyncDialog();
          }
        }
      }
    });

    bool allSynced = activeBuzzers.length == widget.exercise.podCount;

    if (!_isRunning || !isActive || !allSynced) return;

    if (["z", "y", "x"].contains(decodedValue)) {
      final color = activeBuzzers[currentBuzzerIndex];
      final buzzer = buzzerClass
          .firstWhere((buzzer) => buzzer['color']!.split('.').last == color);
      final trigger = buzzer['trigger']!;

      final int reactionTime = lastNotificationTime != null
          ? currentTime.difference(lastNotificationTime!).inMilliseconds
          : 0;
      _activityBloc.add(UpdateActivity(
        reactionTime: reactionTime,
        buzzerExpected: trigger,
        buzzerPressed: decodedValue,
        pressedAt: DateTime.now(),
      ));

      print('decodedValue: $decodedValue');
      print('currentBuzzerIndex aaa: $currentBuzzerIndex');
      print('trigger aaa: $trigger');
      print(
          'buzzerClass[currentBuzzerIndex]: ${buzzerClass[currentBuzzerIndex]}');
      if (decodedValue == trigger) {
        //player.play(AssetSource('sounds/notif.mp3'));

        setState(() {
          messageCount++;
          if (lastNotificationTime != null) {
            _reactionTime.value = currentTime.difference(lastNotificationTime!);
          }
          lastNotificationTime = currentTime;
        });

        sendDeviceNotification(buzzer['stop']!);

        currentBuzzerIndex = (currentBuzzerIndex + 1) % activeBuzzers.length;

        if (currentBuzzerIndex == 0) {
          currentRepetition++;
        }

        activateNextBuzzer();
      } else {
        setState(() {
          errorCount++;
        });
      }
    }
  }

  @override
  void dispose() {
    connectedDevice?.disconnect();
    _timer.cancel();
    _timeElapsed.dispose();
    _reactionTime.dispose();
    connectionStatusNotifier.dispose();
    buzzerActivatedNotifiers.forEach((key, notifier) => notifier.dispose());
    buzzerSyncedNotifiers.forEach((key, notifier) => notifier.dispose());
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
          misses: errorCount,
          caloriesBurned: 10,
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
          misses: errorCount, // Utilisation du compteur d'erreurs
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
                    misses: errorCount,
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

  void _showBluetoothActivationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Activer le Bluetooth'),
          content: const Text(
              'Veuillez activer le Bluetooth pour pouvoir continuer.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await FlutterBluePlus.turnOn();
                checkBluetoothPermissionsAndState();
              },
              child: const Text('Activer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pop();
              },
              child: const Text('Quitter'),
            ),
          ],
        );
      },
    );
  }

  void _showSyncDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Synchronisation des buzzers',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Veuillez allumer ${widget.exercise.podCount} buzzers nécessaires pour cet exercice.',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(widget.exercise.podCount, (index) {
                      return CircleAvatar(
                        radius: 30,
                        backgroundColor: activeBuzzers.length > index
                            ? _getColor(activeBuzzers[index])
                            : Colors.grey,
                        child: activeBuzzers.length > index
                            ? Icon(Icons.check, color: Colors.white)
                            : const SizedBox.shrink(),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    activeBuzzers.length == widget.exercise.podCount
                        ? 'Tous les buzzers sont synchronisés.'
                        : 'Synchronisation des buzzers en cours...',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              actions: [
                activeBuzzers.length == widget.exercise.podCount
                    ? TextButton(
                        onPressed: () {
                          turnOffAllBuzzer();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Lancer l\'exercice'),
                      )
                    : Container(),
              ],
            );
          },
        );
      },
    );
  }

  Color _getColor(String color) {
    switch (color) {
      case "red":
        return Colors.red;
      case "blue":
        return Colors.blue;
      case "green":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showConnectionErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur de connexion'),
          content: const Text(
              'Impossible de connecter aux buzzers. Veuillez réessayer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startScan();
              },
              child: const Text('Réessayer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pop();
              },
              child: const Text('Quitter'),
            ),
          ],
        );
      },
    );
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
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: activeBuzzers
                              .map((buzzerColor) => BuzzerIndicator(
                                    isActive: true,
                                    color: _getColor(buzzerColor),
                                  ))
                              .toList(),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: 100),
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
                                  _isRunning ? Icons.pause : Icons.play_arrow,
                                  color: Colors.black,
                                  size: 32,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: AppPallete.backgroundColorDarker,
                    padding: const EdgeInsets.symmetric(
                        vertical: 32.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.bluetooth,
                                  color: Colors.white),
                              onPressed: () {
                                _showConnectionDialog(
                                    context, connectionStatusNotifier);
                                if (connectedDevice == null) {
                                  reconnectIfNecessary();
                                } else {
                                  discoverServices();
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInfoCard(errorCount.toString(),
                                    'Erreurs'), // Affichage des erreurs
                                _buildInfoCard(
                                    messageCount.toString(), 'Touches',
                                    highlight: true),
                                ValueListenableBuilder<Duration>(
                                  valueListenable: _reactionTime,
                                  builder: (context, value, child) {
                                    return _buildInfoCard(
                                        _formatReactionTime(value), 'Réaction');
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
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

void _showConnectionDialog(
    BuildContext context, ValueListenable<String> connectionStatusNotifier) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: ValueListenableBuilder<String>(
          valueListenable: connectionStatusNotifier,
          builder: (context, value, child) {
            return Text('État de la connexion : $value');
          },
        ),
        content: const Text(
            'Veuillez patienter, nous tentons de connecter votre appareil aux buzzers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'CANCEL'),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
