class FormEnvironment {
  final int id;
  final String name;

  FormEnvironment({
    required this.id,
    required this.name,
  });

  factory FormEnvironment.fromJson(Map<String, dynamic> json) {
    return FormEnvironment(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}