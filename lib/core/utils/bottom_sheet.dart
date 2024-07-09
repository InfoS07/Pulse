import 'package:flutter/material.dart';

class BottomSheeChallengeUtil {
  // Méthode pour afficher une BottomSheet personnalisée avec un builder
  static void showCustomBottomSheet({
    required BuildContext context,
    required WidgetBuilder builder,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    required String buttonText,
    required Color buttonColor,
    bool isDismissible = true,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Contenu personnalisé passé par le builder
              builder(context),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
