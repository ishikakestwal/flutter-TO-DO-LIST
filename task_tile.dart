import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final Function(bool?) onToggle;

  const TaskTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggle
  });

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(task.dueDate);
    Color taskColor = Color(int.parse(task.color));

    // Check if the app is currently in Dark Mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    String priorityLabel = task.priority == 3 ? "High" : task.priority == 2 ? "Medium" : "Low";
    Color pColor = task.priority == 3 ? Colors.red : task.priority == 2 ? Colors.orange : Colors.green;

    // Determine text colors dynamically
    // Title color: Grey if completed, otherwise automatic theme color (Black in Light, White in Dark)
    Color titleColor = task.completed
        ? Colors.grey
        : (Theme.of(context).textTheme.titleLarge?.color ?? Colors.black);

    // Subtitle color: Grey if completed, otherwise a slightly softer theme color
    Color subtitleColor = task.completed
        ? Colors.grey
        : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black54);

    return Card(
      elevation: task.completed ? 0 : 4,
      margin: const EdgeInsets.only(bottom: 12),
      // Background: If completed, use very faint grey. If not, use faint version of task color.
      color: task.completed
          ? (isDarkMode ? Colors.white10 : Colors.grey.withOpacity(0.1))
          : taskColor.withOpacity(isDarkMode ? 0.15 : 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
            color: taskColor.withOpacity(isDarkMode ? 0.4 : 0.2),
            width: 1
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: taskColor, width: 6)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Checkbox(
            value: task.completed,
            onChanged: onToggle,
            activeColor: taskColor,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              decoration: task.completed ? TextDecoration.lineThrough : null,
              color: titleColor, // DYNAMIC COLOR HERE
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  task.description,
                  style: TextStyle(
                    decoration: task.completed ? TextDecoration.lineThrough : null,
                    color: subtitleColor, // DYNAMIC COLOR HERE
                  )
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event, size: 14, color: subtitleColor.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                      "${date.year}-${date.month}-${date.day}",
                      style: TextStyle(fontSize: 12, color: subtitleColor.withOpacity(0.7))
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: pColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: pColor, width: 0.5)
                    ),
                    child: Text(
                        priorityLabel,
                        style: TextStyle(color: pColor, fontSize: 10, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              )
            ],
          ),
          trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: isDarkMode ? Colors.red[300] : Colors.redAccent),
              onPressed: onDelete
          ),
        ),
      ),
    );
  }
}
