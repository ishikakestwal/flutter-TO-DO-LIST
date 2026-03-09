import 'package:flutter/material.dart';
import '../widgets/task_tile.dart';
import '../services/notification_service.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  String _currentSort = 'recent';

  // Define the available colors
  final List<Color> taskColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal
  ];

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future _refreshTasks() async {
    final data = await DatabaseHelper.instance.getTasks(sortBy: _currentSort);
    setState(() => tasks = data);
  }

  void _showAddTaskSheet() {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    DateTime tempDate = DateTime.now();
    double tempPriority = 2.0;
    Color tempColor = Colors.blue; // Default selection

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add New Task", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: titleC, decoration: const InputDecoration(labelText: "Task Title")),
              TextField(controller: descC, decoration: const InputDecoration(labelText: "Description")),
              const SizedBox(height: 20),

              Text("Priority: ${tempPriority == 1 ? "Low" : tempPriority == 2 ? "Medium" : "High"}",
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              Slider(
                  value: tempPriority,
                  min: 1, max: 3, divisions: 2,
                  onChanged: (v) => setModalState(() => tempPriority = v)
              ),

              const Text("Select Task Color", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),

              // FIXED COLOR PICKER
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: taskColors.map((c) {
                    bool isSelected = tempColor.value == c.value;
                    return GestureDetector(
                      onTap: () {
                        setModalState(() => tempColor = c);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isSelected ? Colors.black : Colors.transparent,
                              width: 2
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: c,
                          radius: 14,
                          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () async {
                  final p = await showDatePicker(
                      context: context,
                      initialDate: tempDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100)
                  );
                  if (p != null) setModalState(() => tempDate = p);
                },
                icon: const Icon(Icons.calendar_month),
                label: Text("Due: ${tempDate.year}-${tempDate.month}-${tempDate.day}"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: tempColor, // Button reflects chosen color
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (titleC.text.isEmpty) return;

                  await DatabaseHelper.instance.insertTask(Task(
                    title: titleC.text,
                    description: descC.text,
                    dueDate: tempDate.toIso8601String(),
                    priority: tempPriority.toInt(),
                    color: tempColor.value.toString(), // Saves the color value
                    createdAt: DateTime.now().toIso8601String(),
                  ));

                  Navigator.pop(context);
                  _refreshTasks();
                },
                child: const Text("Save Task", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks"),
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (v) { setState(() => _currentSort = v); _refreshTasks(); },
          itemBuilder: (c) => [
            const PopupMenuItem(value: 'recent', child: Text("Sort by Newest")),
            const PopupMenuItem(value: 'priority', child: Text("Sort by Priority")),
            const PopupMenuItem(value: 'dueDate', child: Text("Sort by Due Date")),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(themeNotifier.value == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeNotifier.value = themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
          )
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text("No tasks found. Tap + to start!"))
          : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: tasks.length,
        itemBuilder: (c, i) => TaskTile(
          task: tasks[i],
          onDelete: () async {
            await DatabaseHelper.instance.deleteTask(tasks[i].id!);
            _refreshTasks();
          },
          onToggle: (v) async {
            await DatabaseHelper.instance.updateCompletion(tasks[i].id!, v!);
            _refreshTasks();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _showAddTaskSheet,
          child: const Icon(Icons.add)
      ),
    );
  }
}
