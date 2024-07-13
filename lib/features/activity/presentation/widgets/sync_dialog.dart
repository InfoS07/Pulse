import 'package:flutter/material.dart';

class SyncDialog extends StatefulWidget {
  final int podCount;
  final List<String> activeBuzzers;
  final VoidCallback onSyncComplete;

  const SyncDialog({
    required this.podCount,
    required this.activeBuzzers,
    required this.onSyncComplete,
    Key? key,
  }) : super(key: key);

  @override
  _SyncDialogState createState() => _SyncDialogState();
}

class _SyncDialogState extends State<SyncDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Synchronisation des buzzers',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Veuillez allumer ${widget.podCount} buzzers nécessaires pour cet exercice.',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.podCount, (index) {
              return CircleAvatar(
                radius: 30,
                backgroundColor: widget.activeBuzzers.length > index
                    ? _getColor(widget.activeBuzzers[index])
                    : Colors.grey,
                child: widget.activeBuzzers.length > index
                    ? Icon(Icons.check, color: Colors.white)
                    : const SizedBox.shrink(),
              );
            }),
          ),
          const SizedBox(height: 20),
          Text(
            widget.activeBuzzers.length == widget.podCount
                ? 'Tous les buzzers sont synchronisés.'
                : 'Synchronisation des buzzers en cours...',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      actions: [
        widget.activeBuzzers.length == widget.podCount
            ? TextButton(
                onPressed: () {
                  widget.onSyncComplete();
                  Navigator.pop(context);
                },
                child: const Text('Lancer l\'exercice'),
              )
            : Container(),
      ],
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
}
