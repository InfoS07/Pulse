import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulse/features/profil/domain/usecases/update_profil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/widgets/loader.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? userId;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedPhoto;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController usernameController;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
      context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final statusCamera = await Permission.camera.status;
    if (!statusCamera.isGranted) {
      await Permission.camera.request();
    }
    if (await Permission.camera.isGranted) {
      _showPickerDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Permission d'accès à la galerie et à la caméra refusée"),
        ),
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
                  final XFile? photo =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (photo != null) {
                    setState(() {
                      _selectedPhoto = photo;
                    });
                  }
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
                      _selectedPhoto = photo;
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

  void _signOut() {
    context.read<AuthBloc>().add(AuthSignOut());
  }

  void _updateProfile() {
    if (userId != null) {
      final params = UpdateUserParams(
        userId: userId!,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        username: usernameController.text,
        photo: _selectedPhoto,
      );
      context.read<ProfilBloc>().add(ProfilUpdateProfil(params));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: BlocConsumer<ProfilBloc, ProfilState>(
          listener: (context, state) {
            if (state is ProfilFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfilLoading) {
              return const Loader();
            } else if (state is ProfilSuccess) {
              firstNameController =
                  TextEditingController(text: state.profil.firstName);
              lastNameController =
                  TextEditingController(text: state.profil.lastName);
              usernameController =
                  TextEditingController(text: state.profil.username);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          child: _selectedPhoto != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(_selectedPhoto!.path),
                                    width: 100.0,
                                    height: 100.0,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: state.profil.profilePhoto,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 100.0,
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    enabled: true,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[200],
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey,
                                    child: const Center(
                                      child: Icon(Icons.person,
                                          size: 50, color: Colors.white),
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: _pickPhoto,
                            color: Colors.blue,
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Pseudo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 14),
                      ),
                      child: const Text(
                        'Modifier',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: _signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.errorColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 14),
                        ),
                        child: const Text(
                          'Se déconnecter',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text(
                  'Erreur de chargement des données.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
