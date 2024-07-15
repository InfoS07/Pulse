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
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';

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
  late TextEditingController emailController;
  String originalFirstName = '';
  String originalLastName = '';

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
    emailController.dispose();
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
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tous les champs sont obligatoires")),
      );
      return;
    }

    if (firstNameController.text == originalFirstName &&
        lastNameController.text == originalLastName &&
        _selectedPhoto == null) {
      return;
    }

    if (userId != null) {
      final params = UpdateUserParams(
        userId: userId!,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        photo: _selectedPhoto,
      );
      context.read<ProfilBloc>().add(ProfilUpdateProfil(params));
      ToastService.showSuccessToast(
        context,
        length: ToastLength.long,
        expandedHeight: 100,
        message: "Profile mis à jour",
      );
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
              return _buildShimmerLoading();
            } else if (state is ProfilSuccess) {
              firstNameController =
                  TextEditingController(text: state.profil.firstName);
              lastNameController =
                  TextEditingController(text: state.profil.lastName);
              emailController = TextEditingController(text: state.profil.email);
              originalFirstName = state.profil.firstName;
              originalLastName = state.profil.lastName;

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
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        shape: BoxShape.circle,
                                      ),
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
                      readOnly: true,
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Mail',
                        border: OutlineInputBorder(),
                      ),
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Modifier',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 60.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.errorColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            enabled: true,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 16.0),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            enabled: true,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            enabled: true,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            enabled: true,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            enabled: true,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(
            height: 60.0,
          ),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            enabled: true,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
