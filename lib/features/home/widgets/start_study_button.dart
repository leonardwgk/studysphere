import 'package:flutter/material.dart';
import 'package:studysphere_app/features/study_tracker/pages/pomodoro_page.dart';

class StartStudyButton extends StatelessWidget {
  const StartStudyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          // Aksi ketika tombol ditekan
          Navigator.of(context).push(
            MaterialPageRoute(
              // builder adalah fungsi yang mengembalikan widget
              builder: (BuildContext context) {
                return const PomodoroPage();
              },
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Warna biru
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Start Study',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
