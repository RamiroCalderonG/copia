//Extension to capitalize strings result
//Example: "HELLO WORLD     " = 'Hello World'

extension StringCasingExtension on String {
  String get toCapitalized =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String get toTitleCase => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized)
      .join(' ');

  //Get first letter of a string
  String get firstLetter => length > 0 ? this[0] : '';

  //Get the first letter of each word after a space 
  //Example: Jhon Doe Martz = JDM
   String get initials => split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0])
      .join();

}
