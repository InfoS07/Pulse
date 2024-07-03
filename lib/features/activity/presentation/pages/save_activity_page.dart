import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';

class SaveActivityPage extends StatefulWidget {
  @override
  _SaveActivityPageState createState() => _SaveActivityPageState();
}

class _SaveActivityPageState extends State<SaveActivityPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final List<XFile> _photos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Permission d'accès à la galerie refusée")));
          return;
        }
      }

      if (await Permission.manageExternalStorage.isDenied) {
        var manageExternalStorageStatus =
            await Permission.manageExternalStorage.request();
        if (!manageExternalStorageStatus.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Permission d'accès à la galerie refusée")));
          return;
        }
      }
    } else if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        status = await Permission.photos.request();
        /* if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Permission d'accès à la galerie refusée")));
          return;
        } */
      }
    }

    try {
      final List<XFile>? selectedPhotos = await _picker.pickMultiImage();
      if (selectedPhotos != null) {
        setState(() {
          for (var photo in selectedPhotos) {
            if (!_photos
                .any((existingPhoto) => existingPhoto.path == photo.path)) {
              _photos.add(photo);
            }
          }
        });
      }
    } catch (e) {
      print('Erreur lors de la sélection des photos: $e');
    }
  }

  void _removePhoto(XFile photo) {
    setState(() {
      _photos.remove(photo);
    });
  }

  void _handleSave(BuildContext context) {
    print("_handleSave");
    if (_descriptionController.text.isNotEmpty) {
      BlocProvider.of<ActivityBloc>(context).add(
        SaveActivity(
          description: _descriptionController.text,
          photos: _photos,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez ajouter une description")));
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enregistrer l\'activité'),
        backgroundColor: Colors.black,
      ),
      body: BlocListener<ActivityBloc, ActivityState>(
        listener: (context, state) {
          if (state is ActivitySavedError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ActivitySaved) {
            context.go('/home');
            BlocProvider.of<HomeBloc>(context).add(LoadPosts());
          }
        },
        child: GestureDetector(
          onTap: _dismissKeyboard,
          child: BlocBuilder<ActivityBloc, ActivityState>(
            builder: (context, state) {
              // Garder l'état précédent si l'état actuel est une erreur de sauvegarde
              final effectiveState =
                  state is ActivitySavedError ? state.previousState : state;

              if (effectiveState is ActivityStopped ||
                  effectiveState is ActivitySavedError) {
                final activity = effectiveState.activity;

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
                            const Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.fire,
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text('Cardio'),
                              backgroundColor: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Chip(
                              label: Text('Course'),
                              backgroundColor: Colors.green,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoCard(
                                _formatDuration(activity.timer), 'Durée'),
                            _buildInfoCard(
                                '${activity.caloriesBurned}', 'calories kcal'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Description',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Décrivez votre activité',
                            hintStyle: TextStyle(color: Colors.grey),
                            fillColor: Colors.grey[900],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Inclure des photos',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickPhotos,
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Center(
                              child: Text(
                                'Touchez pour sélectionner',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
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
                                            _dismissKeyboard(); // Close the keyboard
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
                              _dismissKeyboard(); // Close the keyboard
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                            ),
                            child: const Text(
                              'Enregistrer',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              context.go('/home');
                            },
                            child: const Text(
                              'Rejeter',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
