import 'package:flutter/material.dart';
import 'package:pulse/core/theme/app_pallete.dart';

class SearchInput extends StatefulWidget {
  final Function(String)? onChanged;
  final Function()? onCancel;
  final TextEditingController? controller;
  final String? placeholder;

  const SearchInput({
    Key? key,
    this.onChanged,
    this.onCancel,
    this.controller,
    this.placeholder = 'Rechercher',
  }) : super(key: key);

  @override
  _SearchInputState createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late TextEditingController _searchController;
  bool _showCancel = false;

  @override
  void initState() {
    super.initState();
    _searchController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _searchController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                setState(() {
                  _showCancel = query.isNotEmpty;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(query);
                }
              },
              onTap: () {
                setState(() {
                  _showCancel = true;
                });
              },
              decoration: InputDecoration(
                hintText: widget.placeholder,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                fillColor: AppPallete.backgroundColor,
                filled: true,
              ),
            ),
          ),
        ),
        if (_showCancel)
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _showCancel = false;
              });
              FocusScope.of(context).unfocus();
              if (widget.onCancel != null) {
                widget.onCancel!();
              }
            },
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
