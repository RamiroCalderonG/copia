import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final List<String> items;
  final String label;
  final Function(String?) onSelected;
  final String hint;

  const SearchableDropdown({
    Key? key,
    required this.items,
    required this.label,
    required this.onSelected, required this.hint,
  }) : super(key: key);

  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  List<String> filteredItems = [];
  String? selectedValue;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items; // Initialize with all items
  }
void filterItems(String query) {
  setState(() {
    filteredItems = widget.items
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();


    if (filteredItems.isNotEmpty) {
      selectedValue = filteredItems.first;
    } else {
      selectedValue = null; 
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Text(widget.label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 2),
        TextField(
  controller: searchController,
  decoration: InputDecoration(
    helperText: widget.label,
    hintText: 'Buscar...',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    prefixIcon: const Icon(Icons.search),
  ),
  onChanged: (query) {
    filterItems(query);
    
    if (query.isEmpty) {
      setState(() {
        selectedValue = null;
      });
    }
  },
),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          hint: const Text('Selecciona una opción'),
          items: filteredItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue;
            });
            widget.onSelected(newValue);
          },
        ),
        if (filteredItems.isEmpty) // Display a message if no matches are found
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'No se encontraron coincidencias',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
      ],
    );
  }
}