import 'package:flutter/foundation.dart';
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
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/bottom_sheet_util.dart';
import 'package:pulse/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:pulse/features/activity/presentation/widgets/buzzer_indicator.dart';
import 'package:pulse/features/challenges_users/presentation/bloc/challenges_users_bloc.dart';

class ActivityChallengeUserPage extends StatefulWidget {
  final Exercice exercise;
  final ChallengeUserModel? challengeUserModel;

  const ActivityChallengeUserPage(this.exercise,
      {this.challengeUserModel, super.key});

  @override
  _ActivityChallengePageState createState() => _ActivityChallengePageState();
}

class _ActivityChallengePageState extends State<ActivityChallengeUserPage>
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
  int errorCount = 0;
  bool isScanning = false;
  DateTime? lastNotificationTime;
  final ValueNotifier<String> connectionStatusNotifier =
      ValueNotifier('Recherche d\'appareils');

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
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
    }
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
    _activityBloc = BlocProvider.of<ActivityBloc>(context);
    _activityBloc.add(StartActivity(widget.exercise));
    _checkBluetoothState();
    _preloadSound();
  }

  Future<void> _preloadSound() async {
    await player.setSource(AssetSource('sounds/notif.mp3'));
  }

  Future<void> _checkBluetoothState() async {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        _showBluetoothActivationDialog();
      } else if (state == BluetoothAdapterState.on) {
        checkBluetoothPermissionsAndState();
      }
    });
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
      /* setState(() {
        isScanning = true;
      }); */
      FlutterBluePlus.startScan(/* timeout: const Duration(seconds: 5) */);
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
      String nextBuzzerColor = activeBuzzers[currentBuzzerIndex];
      String nextBuzzerStartCommand = buzzerClass.firstWhere((buzzer) =>
          buzzer['color']!.split('.').last == nextBuzzerColor)['start']!;
      sendDeviceNotification(nextBuzzerStartCommand);
      buzzerActivatedNotifiers[nextBuzzerColor]!.value = true;
    }
  }

  void handleNotification(List<int> value) {
    String decodedValue = utf8.decode(value);
    DateTime currentTime = DateTime.now();

    buzzerClass.forEach((buzzer) {
      if (!buzzerSyncedNotifiers[buzzer["color"]!.split('.').last]!.value &&
          decodedValue == buzzer["trigger"]) {
        buzzerSyncedNotifiers[buzzer["color"]!.split('.').last]!.value = true;
        if (!activeBuzzers.contains(buzzer["color"]!.split('.').last)) {
          setState(() {
            activeBuzzers.add(buzzer["color"]!.split('.').last);
          });

          if (activeBuzzers.length <= widget.exercise.podCount) {
            Navigator.pop(context);

            setState(() {
              isScanning = true;
            });
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

      if (decodedValue == trigger) {
        player.play(AssetSource('sounds/notif.mp3'));
        setState(() {
          messageCount++;
          if (lastNotificationTime != null) {
            _reactionTime.value = currentTime.difference(lastNotificationTime!);
          }
          lastNotificationTime = currentTime;
        });

        sendDeviceNotification(buzzer['stop']!);

        buzzerActivatedNotifiers[color]!.value = false;
        currentBuzzerIndex = (currentBuzzerIndex + 1) % activeBuzzers.length;

        if (currentBuzzerIndex == 0) {
          currentRepetition++;
        }

        final dure = Duration(
            seconds: _durationFromStartAndEndInSecondes(
                widget.challengeUserModel!.training.startAt,
                widget.challengeUserModel!.training.endAt));
        print("duree : $dure");
        if (_timeElapsed.value >=
            Duration(
                seconds: _durationFromStartAndEndInSecondes(
                    widget.challengeUserModel!.training.startAt,
                    widget.challengeUserModel!.training.endAt))) {
          _showSuccessDialog(
              'Bravo tu viens de finir le défi lancé par ton ami',
              messageCount);
          _stopTimer();
        }

        activateNextBuzzer();
      } else {
        setState(() {
          errorCount++;
        });
      }
    }
  }

  String? userId;

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

  void _stopTimer() {
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
          caloriesBurned: 0,
        ));
      });
      startBuzzerSequence();
    } else {
      setState(() {
        _isPaused = true;
        isActive = false;
      });
      _timer.cancel();
      //_showDeleteDialog();
    }
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
          caloriesBurned: 0,
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
          misses: errorCount,
          caloriesBurned: 0,
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

  void _showSuccessDialog(String message, int score) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Félicitations!'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                context.read<ChallengesUsersBloc>().add(
                    FinishChallengeUserEvent(
                        widget.challengeUserModel!.id, userId!, score));
                Navigator.of(context).pop();
              },
              child: const Text('Terminer'),
            ),
          ],
        );
      },
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

  /* void _showPersistentNotification() async {
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
  } */

  /* void _showPauseModal() {
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
                    caloriesBurned: 0,
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
 */
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds =
        twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
    return '$minutes:$seconds:$milliseconds';
  }

  String _durationFromStartAndEnd(String start, String end) {
    final start2 = DateTime.parse(start);
    final end2 = DateTime.parse(end);
    final duration = end2.difference(start2);
    return _formatTime(duration);
  }

  int _durationFromStartAndEndInSecondes(String start, String end) {
    final start2 = DateTime.parse(start);
    final end2 = DateTime.parse(end);
    final duration = end2.difference(start2);
    return duration.inSeconds;
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
                    style: const TextStyle(color: Colors.white),
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
                            ? const Icon(Icons.check, color: Colors.white)
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
                TextButton(
                  onPressed: () => {
                    Navigator.pop(context, 'CANCEL'),
                  },
                  child: const Text('Annuler'),
                ),
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
                        const SizedBox(height: 30),
                        if (widget.challengeUserModel!.type == 'Timer' ||
                            widget.challengeUserModel!.type == 'Répétitions')
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                Text(
                                  'Nombre de répétitions à battre : ${widget.challengeUserModel!.training.repetitions}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Durée pour faire l'exercice : ${_durationFromStartAndEnd(widget.challengeUserModel!.training.startAt, widget.challengeUserModel!.training.endAt!)}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        if (activeBuzzers.isEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Mise en place : ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      widget.exercise.description,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Une fois mis en place, appuyez sur le bouton ci-dessous pour commencer l\'exercice.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        if (activeBuzzers.isNotEmpty)
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 30.0,
                            runSpacing: 10.0,
                            children: activeBuzzers
                                .map((buzzerColor) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable:
                                            buzzerActivatedNotifiers[
                                                buzzerColor]!,
                                        builder: (context, isActive, child) {
                                          return BuzzerIndicator(
                                            isActive: isActive,
                                            color: isActive
                                                ? _getColor(buzzerColor!)
                                                : Colors.grey,
                                          );
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                  Container(
                    color: AppPallete.backgroundColorDarker,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => {
                            if (isScanning)
                              {_startStopTimer()}
                            else
                              {
                                _showConnectionDialog(
                                    context, connectionStatusNotifier),
                                startScan()
                              }
                          },
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
                                  constraints:
                                      const BoxConstraints(minWidth: 100),
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
                        const SizedBox(height: 30),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInfoCard(
                                    errorCount.toString(), 'Erreurs'),
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
        backgroundColor: AppPallete.backgroundColor,
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
              style: TextStyle(color: Colors.grey),
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
