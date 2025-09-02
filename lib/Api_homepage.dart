import 'package:flutter/material.dart';

import 'database/api/api.dart';
import 'model/todo.dart';

class ApiHomepage extends StatefulWidget {
  const ApiHomepage({super.key});

  @override
  State<ApiHomepage> createState() => _ApiHomepageState();
}

class _ApiHomepageState extends State<ApiHomepage> {
  late List<EmployeModel> modellist = [];
  List<EmployeModel> filteredTodos = [];
  int idCounter = 1;
  String searchQuery = "";

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await API().getUserList();
      print("Fetched data++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++: $data"); // debug: check what data comes

      setState(() {
        modellist = data;
        applyFilter(); // apply filter after data is loaded
      });
    } catch (e, stackTrace) {
      print("?????????????????????????????????????????????Error fetching data: $e");
      print(stackTrace);
    }
  }

  void addOrEditTodo({EmployeModel?  todo}) {
    final nameController = TextEditingController(text: todo?.name ?? "");
    final emailController = TextEditingController(text: todo?.email ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(todo == null ? "Add Employee" : "Edit Employee"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(todo == null ? "Add" : "Save"),
              onPressed: () {
                setState(() {
                  if (todo == null) {
                    modellist.add(EmployeModel(
                      name: nameController.text,
                      email: emailController.text,
                    ));
                  } else {
                    todo.name = nameController.text;
                    todo.email = emailController.text;
                  }
                  applyFilter();
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteTodo(EmployeModel todo) {
    setState(() {
      modellist.remove(todo);
      applyFilter();
    });
  }

  void applyFilter() {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredTodos = modellist;
      } else {
        filteredTodos = modellist
            .where((t) =>
        t.name!.toLowerCase().contains(searchQuery.toLowerCase()) ||
            t.email!.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee List"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by Name or Email...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                searchQuery = val;
                applyFilter();
              },
            ),
          ),
        ),
      ),
      body: filteredTodos.isEmpty
          ? const Center(
        child: Text(
          "No Employees Found",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: filteredTodos.length,
        itemBuilder: (context, index) {
          final todo = filteredTodos[index];
          return Dismissible(
            key: ValueKey(todo.id),
            direction: DismissDirection.endToStart,
            background: Container(
              padding: const EdgeInsets.only(right: 20),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) => deleteTodo(todo),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Text(
                    todo.id.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(todo.name.toString(),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(todo.email.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.indigo),
                  onPressed: () => addOrEditTodo(todo: todo),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditTodo(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
