List<String> categories = [
  'CAT 1',
  'CAT 2',
  'CAT 3',
  'CAT 4',
  'CAT 5',
  'CAT 6'
];

Map<String, List<String>> seatsByCategory = {
  'CAT 1': List.generate(50, (index) => 'A${index + 1}'),
  'CAT 2': List.generate(50, (index) => 'B${index + 1}'),
  'CAT 3': List.generate(50, (index) => 'C${index + 1}'),
  'CAT 4': List.generate(50, (index) => 'D${index + 1}'),
  'CAT 5': List.generate(50, (index) => 'E${index + 1}'),
  'CAT 6': List.generate(50, (index) => 'F${index + 1}'),
};

List<String> selectedSeats = [];

List<String> reversedSeats = [
  'A3',
  'A7',
  'A46',
  'A39',
  'A34',
  'B20',
  'B2',
  'B6',
  'B50',
  'B10',
  'B34',
  'C2',
  'C3',
  'C3',
  'C7',
  'C11',
  'C29',
  'C34',
  'D3',
  'D7',
  'D39',
  'D39',
  'D37',
  'E3',
  'E4',
  'E5',
  'F1',
  'F8',
  'F46',
  'F33',
  'F44'
];
