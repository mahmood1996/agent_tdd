final class SpecItem {
  final int id;
  final String title;
  final String? description;
  final String status; // pending, red, green, refactor, done

  const SpecItem({
    required this.id,
    required this.title,
    this.description,
    this.status = 'pending',
  });

  SpecItem copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
  }) {
    return SpecItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  factory SpecItem.fromJson(Map<String, dynamic> json) {
    return SpecItem(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'status': status,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          status == other.status;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ description.hashCode ^ status.hashCode;
}
