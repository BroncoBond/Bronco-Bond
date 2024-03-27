import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfile> {
  final List<String> clubSuggestions = ['CSS', 'sheCodes', 'Flutter Club', 'Coding Club', 'Art Club'];
  late TextEditingController _clubController;
  late TextEditingController _textController;
  List<String> selectedClubs = [];
  List<String> addedInterests = [];

  @override
  void initState() {
    super.initState();
    _clubController = TextEditingController();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _clubController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.raleway(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20), // Add space from the top

              // Profile icon
              Center(
                child: Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.grey,
                ),
              ),

              SizedBox(height: 20), // Add space below the profile icon

              // Rows for editing profile information
              EditableRow(label: 'User Name', initialValue: 'JohnGreen123'),
              Divider(color: Colors.grey), // Add a horizontal line
              EditableRow(label: 'Full Name', initialValue: 'John James Green'),
              Divider(color: Colors.grey), // Add a horizontal line
              EditableRow(label: 'Preferred Name', initialValue: 'Johnny'),
              Divider(color: Colors.grey), // Add a horizontal line
              EditableRow(label: 'Major', initialValue: 'Art History'),
              Divider(color: Colors.grey), // Add a horizontal line
              EditableRow(label: 'Minor', initialValue: 'Communications'),
              Divider(color: Colors.grey), // Add a horizontal line
              EditableRow(label: 'Graduation Date', initialValue: '2024'),
              Divider(color: Colors.grey), // Add a horizontal line
              EditableRow(label: 'Bio', initialValue: 'Lorem ipsum dolor sit amet'),
              Divider(color: Colors.grey),
                     
              SizedBox(height: 10),
               // Add space between profile info and selection widgets
              AddTextWidget(
                initialInterests: addedInterests,
                onInterestsChanged: (interests) {
                  setState(() {
                    addedInterests = interests;
                  });
                },
              ),
              SizedBox(height: 20), 
              Divider(color: Colors.grey),
              // Selected clubs widget
                             SizedBox(height: 20), 
              SelectedClubsList(
                selectedClubs: selectedClubs,
                onDelete: (club) {
                  setState(() {
                    selectedClubs.remove(club);
                  });
                },
              ),// Add space between selected clubs and added texts

              // Added texts widge

              SizedBox(height: 20), // Add space between added texts and selection dropdown

              // Dropdown menu for club selection
              DropdownButtonFormField<String>(
                value: null,
                items: clubSuggestions.map((String suggestion) {
                  return DropdownMenuItem<String>(
                    value: suggestion,
                    child: Text(suggestion),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null && !selectedClubs.contains(newValue)) {
                    setState(() {
                      selectedClubs.add(newValue);
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Select Club',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectedClubsList extends StatelessWidget {
  final List<String> selectedClubs;
  final void Function(String) onDelete;

  const SelectedClubsList({Key? key, required this.selectedClubs, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Clubs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 8),
        if (selectedClubs.isEmpty)
          Text(
            'No clubs selected',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selectedClubs
                .map((club) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(club),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              onDelete(club);
                            },
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class EditableRow extends StatelessWidget {
  final String label;
  final String initialValue;

  const EditableRow({Key? key, required this.label, required this.initialValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent), // Border
                borderRadius: BorderRadius.circular(5.0), // Rounded corners
              ),
              child: TextFormField(
                initialValue: initialValue,
                decoration: InputDecoration(
                  border: InputBorder.none, // Hide border
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddTextWidget extends StatefulWidget {
  final List<String> initialInterests;
  final void Function(List<String>) onInterestsChanged;

  const AddTextWidget({
    Key? key,
    required this.initialInterests,
    required this.onInterestsChanged,
  }) : super(key: key);

  @override
  _AddTextWidgetState createState() => _AddTextWidgetState();
}

class _AddTextWidgetState extends State<AddTextWidget> {
  late TextEditingController _textController;
  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _interests.addAll(widget.initialInterests);
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Interests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 8),
        if (_interests.isEmpty)
          Text(
            'No interests added',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _interests
                .map((interest) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(interest),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _interests.remove(interest);
                                widget.onInterestsChanged(_interests);
                              });
                            },
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        SizedBox(height: 16),
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            labelText: 'Enter Interest',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (interest) {
            setState(() {
              _interests.add(interest);
              widget.onInterestsChanged(_interests);
              _textController.clear();
            });
          },
        ),
      ],
    );
  }
}
