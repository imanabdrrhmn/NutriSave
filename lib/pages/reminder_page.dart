import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reminder.dart';
import '../services/firestore_service.dart';
import '../widgets/add_edit_reminder_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReminderPage extends StatefulWidget {
  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Reminder>> _remindersFuture;

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    setState(() {
      _remindersFuture = _firestoreService.getReminders();
    });
  }

  void _addOrEditReminder({Reminder? reminder}) async {
    Reminder? result = await showDialog<Reminder>(
      context: context,
      builder: (context) => AddEditReminderDialog(
        reminder: reminder,
        onSave: (newReminder) async {
          if (reminder == null) {
            await _firestoreService.addReminder(newReminder);
            _showToast('Successfully added!');
          } else {
            await _firestoreService.updateReminder(newReminder);
            _showToast('Successfully updated!');
          }
          _fetchReminders();
        },
      ),
    );

    if (result != null) {
      _fetchReminders();
    }
  }

  void _deleteReminder(String id) async {
    await _firestoreService.deleteReminder(id);
    _fetchReminders();
    _showToast('Successfully deleted!');
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _toggleReminder(Reminder reminder) async {
    Reminder updatedReminder = reminder.copyWith(isEnabled: !reminder.isEnabled);
    await _firestoreService.updateReminder(updatedReminder);
    _fetchReminders();
    _showToast(updatedReminder.isEnabled ? 'Reminder enabled!' : 'Reminder disabled!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Pengingat',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Reminder>>(
        future: _remindersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading reminders'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No reminders available'));
          }

          List<Reminder> reminders = snapshot.data!;
          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              Reminder reminder = reminders[index];
              return Dismissible(
                key: Key(reminder.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _deleteReminder(reminder.id);
                },
                child: ListTile(
                  title: Text(reminder.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${reminder.time.hour}:${reminder.time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(reminder.days.join(', ')),
                    ],
                  ),
                  trailing: Switch(
                    value: reminder.isEnabled,
                    onChanged: (value) => _toggleReminder(reminder),
                  ),
                  onTap: () => _addOrEditReminder(reminder: reminder),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditReminder(),
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: Colors.teal,
        shape: CircleBorder(),
      ),
    );
  }
}
