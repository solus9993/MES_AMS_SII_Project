class TrackedEntity {
  String id;
  String name;
  double lat;
  double lon;
  TrackedEntity({this.id, this.name, this.lat, this.lon});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lon': lon,
    };
  }

  factory TrackedEntity.fromJson(Map<String, dynamic> json) {
    return TrackedEntity(
      id: json['_id'] ?? null,
      name: json['name'] ?? null,
      lat: json['location']['latitude'] ?? '',
      lon: json['location']['longitude'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['name'] = this.name;
    data['location']['latitude'] = this.lat;
    data['location']['longitude'] = this.lon;

    return data;
  }
}
