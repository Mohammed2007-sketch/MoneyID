import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/db_service.dart';

class FinancialNotesScreen extends StatefulWidget {
  const FinancialNotesScreen({Key? key}) : super(key: key);

  @override
  State<FinancialNotesScreen> createState() => _FinancialNotesScreenState();
}

class _FinancialNotesScreenState extends State<FinancialNotesScreen> {
  List<NoteModel> _notes = [];
  bool _loading = true;
  String _filter = 'all'; // 'all', 'Pending', 'Completed'

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    final list = await DbService.getNotes(filterStatus: _filter);
    setState(() {
      _notes = list;
      _loading = false;
    });
  }

  void _showAddNoteModal([NoteModel? existing]) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final detailCtrl = TextEditingController(text: existing?.detail ?? '');
    final amountCtrl = TextEditingController(text: existing?.amount?.toString() ?? '');
    String status = existing?.status ?? 'Pending';
    String debtType = existing?.debtType ?? 'none';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existing == null ? 'إضافة ملاحظة مالية جديدة 📝' : 'تعديل الملاحظة المالية',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'العنوان (مثال: دين على فلان، إيجار...)',
                        labelStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailCtrl,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'التفاصيل أو الملاحظات',
                        labelStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountCtrl,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'المبلغ (اختياري) ₪',
                              labelStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: const Color(0xFF1E293B),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: status,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white),
                          items: const [
                            DropdownMenuItem(value: 'Pending', child: Text('قيد الانتظار ⏳')),
                            DropdownMenuItem(value: 'Completed', child: Text('مكتمل ✔️')),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => status = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('نوع التصنيف: ', style: TextStyle(color: Colors.white70)),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('بدون'),
                          selected: debtType == 'none',
                          onSelected: (val) => setModalState(() => debtType = 'none'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('دين لِي 🟢'),
                          selected: debtType == 'li',
                          onSelected: (val) => setModalState(() => debtType = 'li'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('دين عَلَيّ 🔴'),
                          selected: debtType == 'alay',
                          onSelected: (val) => setModalState(() => debtType = 'alay'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleCtrl.text.isEmpty) return;
                        final note = NoteModel(
                          id: existing?.id,
                          title: titleCtrl.text,
                          detail: detailCtrl.text,
                          status: status,
                          timestamp: existing?.timestamp ?? DateTime.now().toString().substring(0, 16),
                          amount: double.tryParse(amountCtrl.text),
                          debtType: debtType,
                        );
                        if (existing == null) {
                          await DbService.insertNote(note);
                        } else {
                          await DbService.updateNote(note);
                        }
                        Navigator.pop(ctx);
                        _loadNotes();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('حفظ الملاحظة', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('دفتر الملاحظات المالي 📝', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF10B981),
        onPressed: () => _showAddNoteModal(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterTab('الكل', 'all'),
                _buildFilterTab('قيد الانتظار ⏳', 'Pending'),
                _buildFilterTab('مكتمل ✔️', 'Completed'),
              ],
            ),
          ),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                : _notes.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد ملاحظات مالية حالياً. اضغط + للإضافة',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notes.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final n = _notes[index];
                          final isDone = n.status == 'Completed';
                          return InkWell(
                            onTap: () => _showAddNoteModal(n),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDone
                                      ? const Color(0xFF10B981).withOpacity(0.3)
                                      : const Color(0xFFF59E0B).withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: isDone ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                    ),
                                    onPressed: () async {
                                      final toggled = NoteModel(
                                        id: n.id,
                                        title: n.title,
                                        detail: n.detail,
                                        status: isDone ? 'Pending' : 'Completed',
                                        timestamp: n.timestamp,
                                        amount: n.amount,
                                        debtType: n.debtType,
                                      );
                                      await DbService.updateNote(toggled);
                                      _loadNotes();
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          n.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            decoration: isDone ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        if (n.detail.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            n.detail,
                                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Text(
                                          n.timestamp,
                                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (n.amount != null) ...[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${n.amount!.toStringAsFixed(2)} ₪',
                                          style: TextStyle(
                                            color: n.debtType == 'li'
                                                ? const Color(0xFF10B981)
                                                : n.debtType == 'alay'
                                                    ? const Color(0xFFEF4444)
                                                    : Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (n.debtType == 'li')
                                          const Text('لِي', style: TextStyle(color: Color(0xFF10B981), fontSize: 11))
                                        else if (n.debtType == 'alay')
                                          const Text('عَلَيّ', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
                                      ],
                                    ),
                                  ],
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                                    onPressed: () async {
                                      if (n.id != null) {
                                        await DbService.deleteNote(n.id!);
                                        _loadNotes();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final active = _filter == value;
    return InkWell(
      onTap: () {
        setState(() => _filter = value);
        _loadNotes();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF10B981) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
