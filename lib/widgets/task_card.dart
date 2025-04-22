import 'package:flutter/material.dart';

class TaskCard extends StatefulWidget {
  final String title;
  final String time;
  final bool isTask; // Menentukan apakah ini tugas (bisa dicentang) atau tidak

  TaskCard({required this.title, required this.time, this.isTask = false});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool isChecked = false; // Status checkbox untuk tugas

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: widget.isTask
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    isChecked = !isChecked;
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                    color: isChecked ? Colors.blue : Colors.transparent,
                  ),
                  child: isChecked
                      ? Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              )
            : null, // Jika bukan tugas, tidak ada checkbox
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
            color: isChecked ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(widget.time),
      ),
    );
  }
}
