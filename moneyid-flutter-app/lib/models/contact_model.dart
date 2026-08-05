class PayeeContact {
  final int? id;
  final String name;
  final String phone;
  final String preferredChannel; // e.g. "بال باي", "جوال باي", "بنك فلسطين"

  PayeeContact({
    this.id,
    required this.name,
    required this.phone,
    required this.preferredChannel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'preferredChannel': preferredChannel,
    };
  }

  factory PayeeContact.fromMap(Map<String, dynamic> map) {
    return PayeeContact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      preferredChannel: map['preferredChannel'],
    );
  }
}
