class RawCategory {
  final int id;
  final String name, photoUrl;
  const RawCategory(
      {required this.id, required this.name, required this.photoUrl});
  factory RawCategory.fromJson(Map<String, dynamic> json) => RawCategory(
        id: json['id'],
        name: json['title'],
        photoUrl: json['photo_url'],
      );
}
