class TransactionModel {
  final int? id;
  final String timestamp;
  final double amount;
  final String channel; // 'PalPay', 'JawwalPay', 'BankOfPalestine'
  final String payeePhone;
  final String payeeName;
  final String type; // 'outgoing' or 'incoming'
  final String notes;

  TransactionModel({
    this.id,
    required this.timestamp,
    required this.amount,
    required this.channel,
    required this.payeePhone,
    required this.payeeName,
    required this.type,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'amount': amount,
      'channel': channel,
      'payeePhone': payeePhone,
      'payeeName': payeeName,
      'type': type,
      'notes': notes,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      timestamp: map['timestamp'] as String,
      amount: (map['amount'] as num).toDouble(),
      channel: map['channel'] as String,
      payeePhone: map['payeePhone'] as String,
      payeeName: map['payeeName'] as String,
      type: map['type'] as String,
      notes: map['notes'] as String? ?? '',
    );
  }
}
