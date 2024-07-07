import 'package:flutter/material.dart';
import 'package:pulse/core/theme/app_pallete.dart';

class BottomSheetUtil {
  static void _defaultOnCancel() {}

  static void showCustomBottomSheet(
    BuildContext context, {
    required VoidCallback onConfirm,
    VoidCallback onCancel = _defaultOnCancel,
    String buttonText = 'Supprimer',
    Color buttonColor = AppPallete.primaryColor,
    Color confirmTextColor = Colors.black,
    String cancelText = 'Annuler',
    Color cancelTextColor = Colors.white,
    bool isDismissible = false,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: isDismissible,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onConfirm();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(color: confirmTextColor),
                  ),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () {
                    onCancel();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    cancelText,
                    style: TextStyle(color: cancelTextColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
