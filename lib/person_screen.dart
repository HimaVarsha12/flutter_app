import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Person {
  String? objectId;
  String name;
  int age;

  Person({this.objectId, required this.name, required this.age});

  factory Person.fromParse(ParseObject object) {
    return Person(
      objectId: object.objectId,
      name: object.get<String>('name') ?? '',
      age: object.get<int>('age') ?? 0,
    );
  }
}

class PersonScreen extends StatefulWidget {
  const PersonScreen({Key? key}) : super(key: key);

  @override
  _PersonScreenState createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  final List<Person> people = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _currentObjectId;

  Future<void> fetchPeople() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Person'));
    final ParseResponse response = await query.query();

    if (response.success && response.results != null) {
      setState(() {
        people.clear();
        people.addAll(response.results!.map((e) => Person.fromParse(e as ParseObject)));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch people')),
      );
    }
  }

  Future<void> addPerson(String name, int age) async {
    final person = ParseObject('Person')
      ..set('name', name)
      ..set('age', age);

    final ParseResponse response = await person.save();

    if (response.success) {
      fetchPeople();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add person')),
      );
    }
  }

  Future<void> updatePerson(String objectId, String name, int age) async {
    final person = ParseObject('Person')..objectId = objectId
      ..set('name', name)
      ..set('age', age);

    final ParseResponse response = await person.save();

    if (response.success) {
      fetchPeople();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update person')),
      );
    }
  }

  Future<void> deletePerson(String objectId) async {
    final person = ParseObject('Person')..objectId = objectId;
    final ParseResponse response = await person.delete();

    if (response.success) {
      fetchPeople();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete person')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPeople();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('People')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: people.length,
              itemBuilder: (context, index) {
                final person = people[index];
                return ListTile(
                  title: Text(person.name),
                  subtitle: Text('Age: ${person.age}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // When editing, pre-populate the fields
                          _nameController.text = person.name;
                          _ageController.text = person.age.toString();
                          _currentObjectId = person.objectId;
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deletePerson(person.objectId!);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text;
                    final age = int.tryParse(_ageController.text) ?? 0;

                    if (_currentObjectId != null) {
                      // Update the person
                      updatePerson(_currentObjectId!, name, age);
                    } else {
                      // Add a new person
                      addPerson(name, age);
                    }

                    // Clear the fields after submitting
                    _nameController.clear();
                    _ageController.clear();
                    setState(() {
                      _currentObjectId = null;
                    });
                  },
                  child: Text(_currentObjectId != null ? 'Update Person' : 'Add Person'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
