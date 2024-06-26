import 'dart:math';

String generateUniqueReaderName() {
  List<String> adjectives = [
    'Avid', 'Curious', 'Intrepid', 'Keen', 'Voracious', 'Wise', 'Zealous'
  ];
  List<String> nouns = [
    'Reader', 'Bookworm', 'Learner', 'Explorer', 'Scholar', 'Enthusiast', 'Aficionado'
  ];

  Random random = Random();
  String adjective = adjectives[random.nextInt(adjectives.length)];
  String noun = nouns[random.nextInt(nouns.length)];

  // Generate a unique random ID (example using a simple random string)
  String uniqueId = generateRandomString(8); // Adjust length as needed

  // Combine the random name with the unique ID without spaces
  String uniqueName = '$adjective$noun$uniqueId';

  return uniqueName;
}

String generateRandomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  Random random = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
}
