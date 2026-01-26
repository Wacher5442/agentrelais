import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.validator,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (FormFieldState<T> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final result = await showDialog<T>(
                  context: context,
                  builder: (context) => _SearchDialog<T>(
                    items: widget.items,
                    itemLabel: widget.itemLabel,
                  ),
                );
                if (result != null) {
                  widget.onChanged(result);
                  state.didChange(result);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: widget.label,
                  border: const OutlineInputBorder(),
                  errorText: state.errorText,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  widget.value != null
                      ? widget.itemLabel(widget.value as T)
                      : 'Sélectionner ${widget.label}',
                  style: TextStyle(
                    color: widget.value != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SearchDialog<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;

  const _SearchDialog({required this.items, required this.itemLabel});

  @override
  State<_SearchDialog<T>> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T> extends State<_SearchDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        return widget.itemLabel(item).toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          itemCount: _filteredItems.length,
          itemBuilder: (context, index) {
            final item = _filteredItems[index];
            return ListTile(
              title: Text(widget.itemLabel(item)),
              onTap: () {
                Navigator.of(context).pop(item);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
