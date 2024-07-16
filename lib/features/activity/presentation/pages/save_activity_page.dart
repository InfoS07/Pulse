import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulse/core/common/entities/activity.dart';
import 'package:pulse/core/common/entities/difficulty.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:pulse/features/activity/presentation/widgets/activity_stats_chart.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';

class SaveActivityPage extends StatefulWidget {
  const SaveActivityPage({super.key});

  @override
  _SaveActivityPageState createState() => _SaveActivityPageState();
}

class _SaveActivityPageState extends State<SaveActivityPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final List<XFile> _photos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final statusCamera = await Permission.camera.status;

    if (!statusCamera.isGranted) {
      await Permission.camera.request();
    }
    if (await Permission.camera.isGranted) {
      _showPickerDialog();
    } else {
      ToastService.showErrorToast(
        context,
        length: ToastLength.long,
        expandedHeight: 100,
        message: "Permission d'accès à la galerie et à la caméra refusée",
      );
    }
  }

  void _showPickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final List<XFile> selectedPhotos =
                      await _picker.pickMultiImage();
                  setState(() {
                    for (var photo in selectedPhotos) {
                      if (!_photos.any((existingPhoto) =>
                          existingPhoto.path == photo.path)) {
                        _photos.add(photo);
                      }
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Caméra'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? photo =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() {
                      _photos.add(photo);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removePhoto(XFile photo) {
    setState(() {
      _photos.remove(photo);
    });
  }

  void _handleSave(BuildContext context) {
    if (_titleController.text.isNotEmpty) {
      BlocProvider.of<ActivityBloc>(context).add(
        SaveActivity(
          title: _titleController.text,
          description: _descriptionController.text,
          photos: _photos,
        ),
      );
    } else {
      ToastService.showWarningToast(
        context,
        length: ToastLength.long,
        expandedHeight: 100,
        message: "Veuillez ajouter un titre",
      );
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  String _generateTitle(String exerciseName) {
    final now = DateTime.now();
    final hour = now.hour;
    String timeOfDay;

    if (hour > 4 && hour < 12) {
      timeOfDay = 'matinée';
    } else if (hour < 18) {
      timeOfDay = 'journée';
    } else {
      timeOfDay = 'soirée';
    }

    return '$exerciseName dans la $timeOfDay';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enregistrer l\'activité'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: BlocListener<ActivityBloc, ActivityState>(
        listener: (context, state) {
          if (state is ActivitySavedError) {
            ToastService.showErrorToast(
              context,
              length: ToastLength.long,
              expandedHeight: 100,
              message: state.message,
            );
          } else if (state is ActivitySaved) {
            context.go('/home');
            BlocProvider.of<HomeBloc>(context).add(LoadPosts());

            ToastService.showSuccessToast(
              context,
              length: ToastLength.long,
              expandedHeight: 100,
              message: "Entrainement enregistré",
            );
          }
        },
        child: GestureDetector(
          onTap: _dismissKeyboard,
          child: BlocBuilder<ActivityBloc, ActivityState>(
            builder: (context, state) {
              final effectiveState =
                  state is ActivitySavedError ? state.previousState : state;

              if (effectiveState is ActivityStopped ||
                  effectiveState is ActivitySavedError) {
                final activity = effectiveState.activity;

                if (_titleController.text.isEmpty) {
                  _titleController.text =
                      _generateTitle(activity.exercise.title);
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activity.exercise.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            FaIcon(
                              size: 16,
                              FontAwesomeIcons.fire,
                              color: activity.exercise.difficulty ==
                                      Difficulty.easy
                                  ? Colors.green
                                  : activity.exercise.difficulty ==
                                          Difficulty.medium
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children:
                              activity.exercise.categories.map((category) {
                            return Chip(
                              label: Text(category),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoCard(
                                _formatDuration(activity.timer), 'Durée'),
                            _buildInfoCard(
                                '${activity.touches}', 'Répétitions'),
                            _buildInfoCard('${activity.misses}', 'Ratés'),
                          ],
                        ),
                        /* const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoCard(
                                '${activity.touches}', 'Répétitions'),
                            _buildInfoCard('${activity.misses}', 'Ratés'),
                          ],
                        ), */
                        if (activity.stats.isNotEmpty)
                          ActivityStatsChart(
                            stats: activity.stats,
                          ),
                        const SizedBox(height: 8),
                        const Text(
                          'Titre',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Donnez un titre à votre activité',
                            hintStyle: const TextStyle(color: Colors.grey),
                            fillColor: Colors.grey[900],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Description',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Décrivez votre activité (optionnel)',
                            hintStyle: const TextStyle(color: Colors.grey),
                            fillColor: Colors.grey[900],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Inclure des photos',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickPhotos,
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Center(
                              child: Text(
                                'Touchez pour sélectionner',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _photos.isNotEmpty
                            ? Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _photos.map((photo) {
                                  return Stack(
                                    children: [
                                      Image.file(
                                        File(photo.path),
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            _removePhoto(photo);
                                            _dismissKeyboard();
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              )
                            : Container(),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              _handleSave(context);
                              _dismissKeyboard();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPallete.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 14),
                            ),
                            child: const Text(
                              'Enregistrer',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              context.go('/home');
                              ToastService.showErrorToast(
                                context,
                                length: ToastLength.long,
                                expandedHeight: 100,
                                message: "Entrainement rejeté",
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPallete.errorColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 14),
                            ),
                            child: const Text(
                              'Rejeter',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = (duration.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds:$milliseconds';
  }

  Widget _buildInfoCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        //color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
