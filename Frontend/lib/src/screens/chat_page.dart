import 'package:bronco_bond/src/config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final String userID;
  const ChatPage({Key? key, required this.userID}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  bool isOutgoingMessage = true;
  late SharedPreferences prefs;
  late String username = '';
  List<Map<String, dynamic>> messages = [];
  late Future<SharedPreferences> prefsFuture;
  String? currentUserID;
  IO.Socket? socket;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController(
    initialScrollOffset: 1e10,
  );

  @override
  void initState() {
    super.initState();
    prefsFuture = initSharedPref();
    prefsFuture.then((value) {
      prefs = value;
      // Get user data using the userID
      fetchDataUsingUserID(widget.userID);
      currentUserID = prefs.getString('userID');

      fetchMessageHistory(widget.userID);

      // Connect to Socket.io server
      connectToSocket();
    });
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }

  Future<SharedPreferences> initSharedPref() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> fetchDataUsingUserID(String userID) async {
    String? token = prefs.getString('token');
    var regBody = {"_id": userID};

    try {
      final response = await http.post(
        Uri.parse(getUserByID),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(regBody),
      );

      // print('Request URL: ${Uri.parse('$getUserByID/$userID')}'); // Debug URL
      // print('Token used: $token'); // Debug token

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        setState(() {
          username = userData['user']['username'] ?? 'Unknown';
        });
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchMessageHistory(String userID) async {
    String? token = prefs.getString('token');
    var regBody = {"userToChatId": userID};

    try {
      final response = await http.post(
        Uri.parse(getMessage),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedMessages = json.decode(response.body);
        // print('Fetched messages: $fetchedMessages');
        // Convert to Iterable Map
        final Iterable<Map<String, dynamic>> typedMessages =
            fetchedMessages.map((message) => message as Map<String, dynamic>);

        setState(() {
          messages.clear();
          messages.addAll(typedMessages);
        });
      } else {
        print(
            'Failed to fetch message history. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {}
  }

  void connectToSocket() {
    socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'query': {'userId': widget.userID},
    });

    socket!.connect();

    // Listen to the 'connect' event
    socket!.onConnect((_) {
      print('Connected to Socket.io server');
      // Join a room or emit an event if needed
      // socket!.emit('join', widget.userID);
    });

    // List to the 'chat message' event
    socket!.on('newMessage', (data) {
      print('Got new message');
      print('Received message: $data');

      fetchMessageHistory(widget.userID);

      setState(() {
        messages.add(data);
      });

      scrollToBottom();
    });
  }

  void sendMessage(String message) {
    String? senderID = currentUserID;
    String receiverID = widget.userID;

    Map<String, dynamic> newMessage = {
      'senderId': senderID,
      'receiverId': receiverID,
      'messageContent': message,
    };

    // setState(() {
    //   messages.add(newMessage);
    // });

    if (socket != null && socket!.connected) {
      socket!.emit(
        'sendMessage',
        newMessage,
      );

      // Listen for server response
      socket!.once('sendMessageResponse', (response) {
        if (response['status'] == 'sent') {
          print('Message sent successfully');
          // Handle any additional actions you want to take upon successful sending
        } else {
          print('Failed to send message: ${response['error']}');
          // Handle the error
        }
      });
    }
    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          username,
          style: GoogleFonts.raleway(
            textStyle: Theme.of(context).textTheme.displaySmall,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3B5F43),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10.0),
          Expanded(
            child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isOutgoing =
                      messages[index]['senderId'] == currentUserID;
                  return MessageBubble(
                    isOutgoing: isOutgoing,
                    message: messages[index]['message'] ?? '',
                  );
                }),
          ),
          buildMessageField(messageController)
        ],
      ),
    );
  }

  Widget buildMessageField(TextEditingController textController) {
    String message = '';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: textController,
              onChanged: (value) => message = value,
              onFieldSubmitted: (value) {
                if (value.isNotEmpty) {
                  sendMessage(value);
                  messageController.clear();
                }
              },
              decoration: InputDecoration(
                hintText: 'Message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Color(0xffABABAB)),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Color(0xFF3B5F43))),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              sendMessage(message);
              messageController.clear();
            },
            icon: const Icon(Icons.send_rounded, color: Color(0xff3B5F43)),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final bool isOutgoing;
  final String message;

  const MessageBubble({
    super.key,
    required this.isOutgoing,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment:
            isOutgoing ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isOutgoing
                  ? const Color(0xFF3B5F43)
                  : const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFFABABAB)),
            ),
            child: Text(
              message,
              style: TextStyle(color: isOutgoing ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
