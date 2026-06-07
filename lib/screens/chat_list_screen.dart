import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String? currentUserId;
  List<Map<String, dynamic>> chats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    loadChats();
  }

  Future<void> loadChats() async {
    final db = FirebaseDatabase.instance.ref();
    final snapshot = await db.child('chats').get();

    if (snapshot.exists) {
      List<Map<String, dynamic>> loadedChats = [];
      final data = snapshot.value as Map;

      data.forEach((chatId, messages) {
        if (chatId.toString().contains(currentUserId!)) {
          // Get other user ID
          List<String> ids = chatId.toString().split('_');
          String otherUserId = ids[0] == currentUserId ? ids[1] : ids[0];

          // Get last message
          String lastMessage = '';
          int lastTime = 0;
          if (messages is Map) {
            messages.forEach((key, value) {
              if (value is Map && value['timestamp'] > lastTime) {
                lastTime = value['timestamp'];
                lastMessage = value['text'] ?? '';
              }
            });
          }

          loadedChats.add({
            'chatId': chatId,
            'otherUserId': otherUserId,
            'lastMessage': lastMessage,
            'lastTime': lastTime,
          });
        }
      });

      // Sort by latest message
      loadedChats.sort((a, b) => b['lastTime'].compareTo(a['lastTime']));

      // Load other user names
      for (var chat in loadedChats) {
        final userSnapshot = await db
            .child('users/${chat['otherUserId']}')
            .get();
        if (userSnapshot.exists) {
          final userData = userSnapshot.value as Map;
          chat['otherUserName'] = userData['name'] ?? 'Unknown';
          chat['otherUserRole'] = userData['role'] ?? 'client';
        }
      }

      setState(() {
        chats = loadedChats;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  String timeAgo(int timestamp) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    Duration diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF2ECC71),
        title: Text(
          'My Chats',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF2ECC71)))
          : chats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No chats yet!',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hire a worker to start chatting',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                bool isWorker = chat['otherUserRole'] == 'worker';
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          workerName: chat['otherUserName'] ?? 'Unknown',
                          workerId: chat['otherUserId'],
                          categoryColor: isWorker
                              ? Color(0xFF2ECC71)
                              : Color(0xFF3498DB),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: isWorker
                              ? Color(0xFF2ECC71).withOpacity(0.2)
                              : Color(0xFF3498DB).withOpacity(0.2),
                          child: Icon(
                            isWorker ? Icons.handyman : Icons.person,
                            color: isWorker
                                ? Color(0xFF2ECC71)
                                : Color(0xFF3498DB),
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat['otherUserName'] ?? 'Unknown',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                chat['lastMessage'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          chat['lastTime'] != 0
                              ? timeAgo(chat['lastTime'])
                              : '',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
