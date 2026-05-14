class Option {
  final String id;
  final String label;

  Option({required this.id, required this.label});

  factory Option.fromJson(Map<String, dynamic> json) =>
      Option(id: json['id'], label: json['label']);
  Map<String, dynamic> toMap() => {'id': id, 'label': label};
}
