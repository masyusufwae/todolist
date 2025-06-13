import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B46C1),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const TodoListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Task {
  final int id;
  final String title;
  final String priority;
  final String dueDate;
  final String createdAt;
  final String updatedAt;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isDone,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      priority: json['priority'],
      dueDate: json['due_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isDone: json['is_done'].toString().toLowerCase() == 'true',
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});
  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage>
    with SingleTickerProviderStateMixin {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  List<Task> tasks = [];
  late TabController _tabController;

  final TextEditingController titleController = TextEditingController();
  String selectedPriority = 'low';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Task> getTasksByStatus(String status) {
    List<Task> filtered;
    
    switch (status) {
      case 'completed':
        filtered = tasks.where((task) => task.isDone).toList();
        break;
      case 'pending':
        filtered = tasks.where((task) => !task.isDone).toList();
        break;
      case 'high':
        filtered = tasks.where((task) => task.priority == 'high' && !task.isDone).toList();
        break;
      default:
        filtered = tasks;
    }

    filtered.sort((a, b) {
      DateTime aDate = DateTime.parse(a.dueDate);
      DateTime bDate = DateTime.parse(b.dueDate);
      return aDate.compareTo(bDate);
    });

    return filtered;
  }

  Future<void> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tasks'));
      if (response.statusCode == 200) {
        List jsonData = json.decode(response.body);
        setState(() {
          tasks = jsonData.map((e) => Task.fromJson(e)).toList();
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addTask() async {
    if (titleController.text.isEmpty || selectedDate == null) return;
    try {
      await http.post(Uri.parse('$baseUrl/tasks'), body: {
        'title': titleController.text,
        'priority': selectedPriority,
        'due_date': selectedDate!.toIso8601String().split('T')[0],
      });
      titleController.clear();
      selectedDate = null;
      fetchTasks();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> editTask(Task task) async {
    if (titleController.text.isEmpty || selectedDate == null) return;
    try {
      await http.put(Uri.parse('$baseUrl/tasks/${task.id}'), body: {
        'title': titleController.text,
        'priority': selectedPriority,
        'due_date': selectedDate!.toIso8601String().split('T')[0],
        'is_done': task.isDone.toString(),
      });
      titleController.clear();
      selectedDate = null;
      fetchTasks();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await http.delete(Uri.parse('$baseUrl/tasks/$id'));
      fetchTasks();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateTaskStatus(Task task, bool newStatus) async {
    try {
      await http.put(Uri.parse('$baseUrl/tasks/${task.id}'), body: {
        'title': task.title,
        'priority': task.priority,
        'due_date': task.dueDate,
        'is_done': newStatus.toString(),
      });
      setState(() {
        task.isDone = newStatus;
      });
      fetchTasks();
    } catch (e) {
      // Handle error
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;
      
      if (difference == 0) return 'Hari ini';
      if (difference == 1) return 'Besok';
      if (difference == -1) return 'Kemarin';
      if (difference > 1) return '${difference} hari lagi';
      return '${difference.abs()} hari lalu';
    } catch (e) {
      return dateString;
    }
  }

  void showTaskDialog({Task? task}) {
    if (task != null) {
      titleController.text = task.title;
      selectedPriority = task.priority;
      selectedDate = DateTime.parse(task.dueDate);
    } else {
      titleController.clear();
      selectedPriority = 'low';
      selectedDate = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.center,
                ),
                Text(
                  task == null ? 'Tambah Tugas Baru' : 'Edit Tugas',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul Tugas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.task_alt),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'Prioritas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.flag),
                  ),
                  items: [
                    DropdownMenuItem(value: 'low', child: Text('🟢 Rendah')),
                    DropdownMenuItem(value: 'medium', child: Text('🟡 Sedang')),
                    DropdownMenuItem(value: 'high', child: Text('🔴 Tinggi')),
                  ],
                  onChanged: (value) => setModalState(() => selectedPriority = value!),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate == null
                              ? 'Pilih Tanggal Deadline'
                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          style: TextStyle(
                            color: selectedDate == null ? Colors.grey : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (task == null) {
                      addTask();
                    } else {
                      editTask(task);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    task == null ? 'Tambah Tugas' : 'Simpan Perubahan',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => showTaskDialog(task: task),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => updateTaskStatus(task, !task.isDone),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isDone ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                        color: task.isDone ? Colors.green : Colors.transparent,
                      ),
                      child: task.isDone
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        showTaskDialog(task: task);
                      } else if (value == 'delete') {
                        deleteTask(task.id);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getPriorityText(task.priority),
                      style: TextStyle(
                        color: _getPriorityColor(task.priority),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    formatDate(task.dueDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'high':
        return '🔴 Tinggi';
      case 'medium':
        return '🟡 Sedang';
      case 'low':
      default:
        return '🟢 Rendah';
    }
  }

  Widget buildTaskList(String filter) {
    final filteredTasks = getTasksByStatus(filter);
    
    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(filter),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(filter),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) => buildTaskCard(filteredTasks[index]),
    );
  }

  IconData _getEmptyIcon(String filter) {
    switch (filter) {
      case 'completed':
        return Icons.task_alt;
      case 'pending':
        return Icons.pending_actions;
      case 'high':
        return Icons.priority_high;
      default:
        return Icons.inbox;
    }
  }

  String _getEmptyMessage(String filter) {
    switch (filter) {
      case 'completed':
        return 'Belum ada tugas yang selesai';
      case 'pending':
        return 'Tidak ada tugas tertunda';
      case 'high':
        return 'Tidak ada tugas prioritas tinggi';
      default:
        return 'Tidak ada tugas';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Task Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Tertunda'),
            Tab(text: 'Selesai'),
            Tab(text: 'Prioritas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTaskList('all'),
          buildTaskList('pending'),
          buildTaskList('completed'),
          buildTaskList('high'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tugas Baru'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}