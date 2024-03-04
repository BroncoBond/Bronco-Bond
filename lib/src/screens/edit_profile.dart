import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays detailed information about a SampleItem.
class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
   EditProfilePageState createState() =>  EditProfilePageState();
}

class EditProfilePageState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black)),
        title: Text('Edit Profile',
        style: GoogleFonts.raleway(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)
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

  

              // Edit Picture button
              Center(
                child: ElevatedButton(
                  onPressed: () {
      // Add functionality to edit picture
                 },
                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Set button color to transparent
                elevation: 0, // Remove button elevation
                  ),
               child: Text(
                'Edit Picture',
                style: GoogleFonts.raleway(
                color: Colors.black, // Set text color to transparent
                fontSize: 16
                   ),
                  ),
                ),
                ),


              SizedBox(height: 10), // Add space below the Edit Picture button

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
            ],
          ),
        ),
      ),
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