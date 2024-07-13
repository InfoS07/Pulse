import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class SettingsPage extends StatelessWidget {
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
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Compte'),
            tiles: [
              SettingsTile(
                title: Text('Email'),
                trailing: Icon(Icons.arrow_forward_ios),
                leading: Icon(Icons.email),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: Text('Person'),
                trailing: Icon(Icons.arrow_forward_ios),
                leading: Icon(Icons.person),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: Text('Language'),
                leading: Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
            ],
          ),
          SettingsSection(
            title: Text('Compte'),
            tiles: [
              SettingsTile(
                title: Text('Language'),
                leading: Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/**
 * Center(
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
 */