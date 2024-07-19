import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/daily_plan.dart';

class ReadOnlyDailyPlanItem extends StatelessWidget {
  final DailyPlan plan;

  const ReadOnlyDailyPlanItem({
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(plan.imagePath),
              radius: 30,
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Adjust color to match the theme
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "${plan.dateTime.hour}:${plan.dateTime.minute.toString().padLeft(2, '0')} ${plan.dateTime.day}/${plan.dateTime.month}/${plan.dateTime.year}",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: 15),
            Text(
              "${plan.calories} Calories",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
