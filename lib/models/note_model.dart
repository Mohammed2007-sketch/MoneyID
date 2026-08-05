class NoteModel {
  final int? id;
  final String title;
  final String detail;
  final String status; // 'Completed' or 'Pending'
  final String timestamp;
  final double? amount; // Optional associated debt/credit amount
  final String debtType; // 'li' (لي - credit) or 'alay' (علي - debt) or 'none'

  NoteModel({
    this.id,
    required this.title,
    required this.detail,
    required this.status,
    required this.timestamp,
    this.amount,
    this.debtType = 'none',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'detail': detail,
      'status': status,
      'timestamp': timestamp,
      'amount': amount,
      'debtType': debtType,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      detail: map['detail'] as String,
      status: map['status'] as String,
      timestamp: map['timestamp'] as String,
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null,
      debtType: map['debtType'] as String? ?? 'none',
    );
  }
}
