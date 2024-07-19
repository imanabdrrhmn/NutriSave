import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEditReminderDialog extends StatefulWidget {
  final Reminder? reminder;
  final Function(Reminder) onSave;

  const AddEditReminderDialog({Key? key, this.reminder, required this.onSave}) : super(key: key);

  @override
  _AddEditReminderDialogState createState() => _AddEditReminderDialogState();
}

class _AddEditReminderDialogState extends State<AddEditReminderDialog> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _time;
  final List<String> _days = [];
  bool _isEnabled = true;
  bool _everyday = false;
  final NotificationService _notificationService = NotificationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _time = widget.reminder!.time;
      _days.addAll(widget.reminder!.days);
      _isEnabled = widget.reminder!.isEnabled;
      _everyday = _days.length == 7;
    }
  }

  void _toggleEveryday(bool? value) {
    setState(() {
      _everyday = value ?? false;
      if (_everyday) {
        _days
          ..clear()
          ..addAll(['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']);
      } else {
        _days.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      backgroundColor: Colors.white,
      title: Text(
        widget.reminder == null ? 'Tambah Pengingat' : 'Edit Pengingat',
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              readOnly: true,
              controller: TextEditingController(
                text: _time != null ? "${_time!.hour}:${_time!.minute.toString().padLeft(2, '0')}" : '',
              ),
              decoration: InputDecoration(
                labelText: 'Waktu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_time ?? DateTime.now()),
                );
                if (pickedTime != null) {
                  setState(() {
                    _time = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              },
            ),
            SizedBox(height: 10),
            CheckboxListTile(
              title: Text('Setiap Hari'),
              value: _everyday,
              onChanged: _toggleEveryday,
            ),
            Wrap(
              spacing: 5,
              children: [
                for (String day in ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'])
                  ChoiceChip(
                    label: Text(day),
                    selected: _days.contains(day),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _days.add(day);
                        } else {
                          _days.remove(day);
                          _everyday = false;
                        }
                      });
                    },
                  ),
              ],
            ),
            SwitchListTile(
              title: Text('Aktif'),
              value: _isEnabled,
              onChanged: (value) {
                setState(() {
                  _isEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_time != null && _titleController.text.isNotEmpty) {
              final newReminder = Reminder(
                id: widget.reminder?.id ?? DateTime.now().toIso8601String(),
                title: _titleController.text,
                time: _time!,
                days: _days,
                isEnabled: _isEnabled,
              );

              // Simpan pengingat baru
              widget.onSave(newReminder);

              // Jadwalkan notifikasi jika diaktifkan
              if (_isEnabled) {
                await _notificationService.scheduleNotification(
                  newReminder.id.hashCode,
                  newReminder.title,
                  'It\'s time for your reminder!',
                  _time!,
                );
              }

              Navigator.of(context).pop(newReminder);
            }
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}
