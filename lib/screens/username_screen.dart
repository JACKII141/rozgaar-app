import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home_screen.dart';

class UsernameScreen extends StatefulWidget {
  @override
  _UsernameScreenState createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final _usernameController = TextEditingController();
  bool isLoading = false;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    checkVerification();
  }

  Future<void> checkVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    setState(() {
      isVerified = user?.emailVerified ?? false;
    });
  }

  Future<void> resendEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.sendEmailVerification();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification email sent again!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> saveUsername() async {
    await checkVerification();

    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please verify your email first!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String username = _usernameController.text.trim().toLowerCase();

    if (username.isEmpty || username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username must be at least 3 characters!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (username.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username cannot contain spaces!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final db = FirebaseDatabase.instance.ref();
      final snapshot = await db.child('usernames/$username').get();

      if (snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Username already taken! Try another one.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      String uid = FirebaseAuth.instance.currentUser!.uid;
      await db.child('usernames/$username').set(uid);
      await db.child('users/$uid/username').set(username);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isVerified ? Icons.verified : Icons.mark_email_unread,
                size: 100,
                color: isVerified ? Color(0xFF2ECC71) : Colors.orange,
              ),
              SizedBox(height: 20),
              Text(
                isVerified ? 'Choose Username' : 'Verify Your Email',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isVerified ? Color(0xFF2ECC71) : Colors.orange,
                ),
              ),
              SizedBox(height: 10),
              Text(
                isVerified
                    ? 'Pick a unique username for your profile'
                    : 'Please verify your email to continue',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 40),
              if (!isVerified) ...[
                ElevatedButton.icon(
                  onPressed: checkVerification,
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    'I have verified my email',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2ECC71),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: Size(double.infinity, 55),
                  ),
                ),
                SizedBox(height: 15),
                TextButton(
                  onPressed: resendEmail,
                  child: Text(
                    'Resend verification email',
                    style: GoogleFonts.poppins(color: Colors.orange),
                  ),
                ),
              ],
              if (isVerified) ...[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'e.g. ahmed_plumber',
                    prefixIcon: Icon(
                      Icons.alternate_email,
                      color: Color(0xFF2ECC71),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF2ECC71)),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveUsername,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2ECC71),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
