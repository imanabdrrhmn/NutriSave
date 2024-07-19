import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_plan.dart';
import '../services/firestore_service.dart';

class DailyPlanDialog extends StatefulWidget {
  final DailyPlan? plan;
  final Function(DailyPlan) onSave;
  final Function(String) onDelete;

  DailyPlanDialog({this.plan, required this.onSave, required this.onDelete});

  @override
  _DailyPlanDialogState createState() => _DailyPlanDialogState();
}

class _DailyPlanDialogState extends State<DailyPlanDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  DateTime? _dateTime = DateTime.now();
  String selectedType = 'Makanan';
  Map<String, String> typeImages = {
    'Makanan': 'assets/icons/food.png',
    'Minuman': 'assets/icons/drink.png',
    'Cemilan': 'assets/icons/snack.png',
  };

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if (widget.plan != null) {
      titleController.text = widget.plan!.title;
      caloriesController.text = widget.plan!.calories;
      _dateTime = widget.plan!.dateTime;
      selectedType = widget.plan!.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.plan == null ? 'Tambah Rencana Harian' : 'Edit Rencana Harian',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: caloriesController,
              decoration: InputDecoration(
                labelText: 'Kalori',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              readOnly: true,
              controller: TextEditingController(
                text: "${_dateTime?.day}/${_dateTime?.month}/${_dateTime?.year} ${_dateTime?.hour}:${_dateTime?.minute.toString().padLeft(2, '0')}",
              ),
              decoration: InputDecoration(labelText: 'Tanggal dan Waktu'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _dateTime ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_dateTime ?? DateTime.now()),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      _dateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: ['Makanan', 'Minuman', 'Cemilan'].map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedType = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Jenis',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Batal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        caloriesController.text.isNotEmpty &&
                        _dateTime != null) {
                      User? user = _auth.currentUser;
                      if (user != null) {
                        DailyPlan newPlan = DailyPlan(
                          id: widget.plan?.id ?? _firestoreService.createDocumentId('users/${user.uid}/daily_plans'),
                          title: titleController.text,
                          calories: caloriesController.text,
                          dateTime: _dateTime!,
                          type: selectedType,
                          imagePath: typeImages[selectedType]!,
                        );
                        widget.onSave(newPlan);
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
