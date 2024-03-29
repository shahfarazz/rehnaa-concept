import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../backend/services/authentication_service.dart';
import '../../Screens/login_page.dart';
import '../../Screens/signup_page.dart';
import '../../Screens/splash.dart';
import '../Landlorddashboard_pages/landlord_profile.dart';

class DealerProfilePage extends StatefulWidget {
  final String uid;

  const DealerProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  _DealerProfilePageState createState() => _DealerProfilePageState();
}

class _DealerProfilePageState extends State<DealerProfilePage> {
  bool showChangePassword = false;
  bool showDeleteAccount = false;
  final TextEditingController _enterPasswordController =
      TextEditingController();
  final TextEditingController _enterCodeController = TextEditingController();

  bool _obscurePassword = true; // Track whether the password is obscured or not
  bool _obscurePassword2 =
      true; // Track whether the password is obscured or not

  // bool isUploadLoading = false;
  //define two new controllers for the password fields
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final authService = AuthenticationService();

    void toggleChangePassword() {
      setState(() {
        showChangePassword = !showChangePassword;
      });
    }

    void toggleDeleteAccount() {
      setState(() {
        showDeleteAccount = !showDeleteAccount;
      });
    }

    Future<void> _uploadImageToFirebase() async {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return;

      final File imageFile = File(pickedImage.path);
      final String fileName = 'users/${widget.uid}/profile_image.jpg';

      try {
        // Upload the image to Firebase Storage
        final Reference storageReference =
            FirebaseStorage.instance.ref().child(fileName);
        final UploadTask uploadTask = storageReference.putFile(imageFile);
        final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

        // Get the download URL of the uploaded image
        final String downloadURL = await taskSnapshot.ref.getDownloadURL();

        // Update the 'pathToImage' property in the 'Tenants' collection
        await FirebaseFirestore.instance
            .collection('Dealers')
            .doc(widget.uid)
            .update({'pathToImage': downloadURL});

        // Show a success toast
        Fluttertoast.showToast(
          msg: 'Image uploaded successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (e) {
        // Show an error toast
        Fluttertoast.showToast(
          msg: 'Failed to upload image',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('Error uploading image: $e');
      }
    }

    Future<bool> openCamera() async {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.camera);

      if (pickedImage == null) {
        return false;
      }

      final File imageFile = File(pickedImage.path);
      final String fileName = 'users/${widget.uid}/profile_image.jpg';

      try {
        // Upload the image to Firebase Storage
        final Reference storageReference =
            FirebaseStorage.instance.ref().child(fileName);
        final UploadTask uploadTask = storageReference.putFile(imageFile);
        final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

        // Get the download URL of the uploaded image
        final String downloadURL = await taskSnapshot.ref.getDownloadURL();

        // Update the 'pathToImage' property in the 'Dealers' collection
        await FirebaseFirestore.instance
            .collection('Dealers')
            .doc(widget.uid)
            .update({'pathToImage': downloadURL});

        // Show a success toast
        Fluttertoast.showToast(
          msg: 'Image uploaded successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return true;
      } catch (e) {
        // Show an error toast
        Fluttertoast.showToast(
          msg: 'Failed to upload image',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('Error uploading image: $e');
        return false;
      }
    }

    Future<void> _openImagePicker() async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Upload Image',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                )),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    _uploadImageToFirebase();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    // padding: EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    width: size.width,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.photo_library,
                          color: Colors.green,
                        ),
                        SizedBox(width: size.width * 0.009),
                        Text(
                          'Choose from Gallery',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                GestureDetector(
                  onTap: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return WillPopScope(
                          onWillPop: () async => Future.value(
                              false), // Disable back button during upload
                          child: AlertDialog(
                            title: Text(
                              'Uploading Image',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 20,
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                CircularProgressIndicator(color: Colors.green),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    bool isUploadSuccess = await openCamera();
                    setState(() {});

                    // Dismiss the dialog
                    Navigator.of(context).pop();

                    if (isUploadSuccess) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    // padding: EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    width: size.width,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.camera_alt,
                          color: Colors.green,
                        ),
                        SizedBox(width: size.width * 0.009),
                        Text(
                          'Take a Photo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.cancel,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Future<void> changePassword(String oldPassword, String newPassword) async {
      try {
        //show green loading indicator
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Row(
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.green,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    const Text('Changing password...'),
                  ],
                ),
              );
            });
        User? user = FirebaseAuth.instance.currentUser;

        //check if user is signed up using mobile number or email
        FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get()
            .then((value) async {
          String emailOrPhone = value['emailOrPhone'];
          if (emailOrPhone == null) {
            //show toast that there is no email or phone number associated with this account
            Fluttertoast.showToast(
                msg:
                    'There is no email or phone number associated with this account',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
          if (emailOrPhone.contains('@')) {
            //user signed up using email
            print(
                'user signed up using email is $emailOrPhone ,password is $oldPassword, new pass is $newPassword');

            if (user != null) {
              // Reauthenticate the user with their old password
              AuthCredential credential = EmailAuthProvider.credential(
                email: user.email!,
                password: oldPassword,
              );
              await user.reauthenticateWithCredential(credential);

              // Change the user's password
              await user.updatePassword(newPassword);
              //show toast
              Fluttertoast.showToast(
                  msg: 'Password changed successfully',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              print('No user signed in');
            }
          } else {
            //user signed up using mobile number
            print('user signed up using mobile number');
            String hashPassword = hashString(oldPassword);
            //check firebase firestore users collecion to get hashed password
            // stored in password field
            FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .get()
                .then((value) async {
              String password = value['password'];
              if (password == hashPassword) {
                //user entered correct old password
                //update password in firebase firestore
                String newHashPassword = hashString(newPassword);
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .update({'password': newHashPassword});
                print('Password changed successfully');
              } else {
                //user entered wrong old password
                print('user entered wrong old password');
                Fluttertoast.showToast(
                    msg: 'Wrong old password entered',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            });
          }
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      } catch (e) {
        print('Error changing password: $e');
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('Dealers')
            .doc(widget.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While data is being fetched, show a loading indicator
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // If there's an error fetching data, display an error message
            return const Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData) {
            // If no data is available, display a message
            return const Center(child: Text('No data available'));
          }

          final docData = snapshot.data!.data();
          // print('docData is ${docData}');

          if (docData == null) {
            // If document data is null, display a message
            return const Center(child: Text('Data is null'));
          }

          final emailOrPhone = docData['emailOrPhone'] as String? ?? '';

          final firstName = docData['firstName'] as String? ?? '';
          final lastName = docData['lastName'] as String? ?? '';
          final pathToImage = docData['pathToImage'] as String? ?? '';
          final description = docData['description'] as String? ?? '';

          final isEmail = authService.isEmail(emailOrPhone);
          // final isPhoneNumber = authService.isPhoneNumber(emailOrPhone);
          String contactInfo = '';

          if (isEmail) {
            contactInfo = 'Email: $emailOrPhone';
          } else {
            contactInfo = 'Phone: $emailOrPhone';
          }

          return Container(
              constraints: BoxConstraints(),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: () {
                          _openImagePicker();
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 75,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: pathToImage != null &&
                                        pathToImage!.isNotEmpty
                                    ? (pathToImage!.startsWith('assets')
                                        ? Image.asset(
                                            pathToImage!,
                                            width: 150,
                                            height: 150,
                                          )
                                        : Image.network(
                                            fit: BoxFit.fill,
                                            pathToImage!,
                                            width: 150,
                                            height: 150,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.green,
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                          ))
                                    : Image.asset(
                                        'assets/defaulticon.png',
                                        width: 150,
                                        height: 150,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$firstName $lastName',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.montserrat().fontFamily),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontFamily: GoogleFonts.montserrat().fontFamily),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      ProfileInfoItem(
                        icon: Icons.email,
                        title: isEmail ? 'Email' : 'Contact',
                        subtitle: contactInfo,
                      ),
                      const ProfileInfoItem(
                        icon: Icons.location_on,
                        title: 'Location',
                        subtitle: 'Lahore, Punjab',
                      ),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showChangePassword = !showChangePassword;
                                  });
                                },
                                child: Row(
                                  children: [
                                    const SizedBox(width: 17, height: 60),
                                    Icon(
                                      Icons.settings,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 31),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 18),
                                          Text(
                                            'Additional Settings',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    GoogleFonts.montserrat()
                                                        .fontFamily),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Click to access additional settings',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                                fontFamily:
                                                    GoogleFonts.montserrat()
                                                        .fontFamily),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            transitionBuilder:
                                                (child, animation) {
                                              final height =
                                                  constraints.maxHeight;
                                              return ScaleTransition(
                                                scale: CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeInOut,
                                                ),
                                                child: child,
                                              );
                                            },
                                            child: showChangePassword
                                                ? const Icon(
                                                    Icons.arrow_drop_up,
                                                    color: Colors.grey,
                                                    key: Key('arrow_up'),
                                                  )
                                                : const Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.grey,
                                                    key: Key('arrow_down'),
                                                  ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, -0.5),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: showChangePassword
                                    ? Column(
                                        key: const Key('additional_settings'),
                                        children: [
                                          const SizedBox(
                                            height: 17,
                                            width: 8,
                                          ),
                                          ProfileInfoItem(
                                            icon: Icons.lock,
                                            title: 'Change Password',
                                            subtitle:
                                                'Click to change your password',
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder:
                                                          (BuildContext context,
                                                              setState) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Change Password'),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              TextField(
                                                                controller:
                                                                    _oldPasswordController,
                                                                obscureText:
                                                                    _obscurePassword,
                                                                decoration:
                                                                    InputDecoration(
                                                                  iconColor:
                                                                      Colors
                                                                          .green,
                                                                  focusColor:
                                                                      Colors
                                                                          .green,
                                                                  hoverColor:
                                                                      Colors
                                                                          .green,
                                                                  labelText:
                                                                      'Old Password',
                                                                  suffixIcon:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        _obscurePassword =
                                                                            !_obscurePassword;
                                                                      });
                                                                    },
                                                                    child: Icon(
                                                                      _obscurePassword
                                                                          ? Icons
                                                                              .visibility
                                                                          : Icons
                                                                              .visibility_off,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              TextField(
                                                                controller:
                                                                    _newPasswordController,
                                                                obscureText:
                                                                    _obscurePassword2,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'New Password',
                                                                  suffixIcon:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        _obscurePassword2 =
                                                                            !_obscurePassword2;
                                                                      });
                                                                    },
                                                                    child: Icon(
                                                                      _obscurePassword2
                                                                          ? Icons
                                                                              .visibility
                                                                          : Icons
                                                                              .visibility_off,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                    'Cancel',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green))),
                                                            TextButton(
                                                                onPressed: () {
                                                                  changePassword(
                                                                      _oldPasswordController
                                                                          .text,
                                                                      _newPasswordController
                                                                          .text);
                                                                  // Navigator.pop(context);
                                                                },
                                                                child: Text(
                                                                  'Change',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                ))
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  });
                                            },
                                          ),
                                          ProfileInfoItem(
                                            icon: Icons.delete,
                                            title: 'Delete Account',
                                            subtitle:
                                                'Click to delete your account',
                                            onTap: () async {
                                              User? currentUser = FirebaseAuth
                                                  .instance.currentUser;
                                              String? phoneNumber =
                                                  currentUser?.phoneNumber;
                                              bool isPhoneNumberLogin =
                                                  phoneNumber != null;

                                              if (isPhoneNumberLogin) {
                                                String? enteredVerificationCode;
                                                print(
                                                    'phone number is $phoneNumber');

                                                // Send verification code via SMS
                                                await FirebaseAuth.instance
                                                    .verifyPhoneNumber(
                                                  phoneNumber: phoneNumber!,
                                                  verificationCompleted:
                                                      (PhoneAuthCredential
                                                          credential) async {
                                                    try {
                                                      // Reauthenticate the user with the credential
                                                      print(
                                                          'credential is $credential');
                                                      await currentUser
                                                          ?.reauthenticateWithCredential(
                                                              credential);

                                                      // Delete the user account
                                                      await currentUser
                                                          ?.delete();

                                                      // Show a success message to the user
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Account deleted successfully.'),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      // Show an error message if the account deletion fails
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(e
                                                              .toString()
                                                              .substring(30)),
                                                        ),
                                                      );
                                                      print('Error: $e');
                                                    }
                                                  },
                                                  verificationFailed:
                                                      (FirebaseAuthException
                                                          e) {
                                                    // Handle verification failure
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(e
                                                            .toString()
                                                            .substring(30)),
                                                      ),
                                                    );
                                                    print(
                                                        'Phone number verification failed: ${e.message}');
                                                  },
                                                  codeSent: (String
                                                          verificationId,
                                                      [int?
                                                          forceResendingToken]) async {
                                                    // Prompt the user to enter the verification code
                                                    enteredVerificationCode =
                                                        await showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: Text(
                                                            'Phone Verification'),
                                                        content: TextFormField(
                                                          controller:
                                                              _enterCodeController,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Enter the verification code',
                                                          ),
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Please enter the verification code';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(null),
                                                            child:
                                                                Text('Cancel'),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              enteredVerificationCode =
                                                                  _enterCodeController
                                                                      .text;
                                                              if (enteredVerificationCode !=
                                                                  null) {
                                                                // Create PhoneAuthCredential using the entered verification code
                                                                PhoneAuthCredential
                                                                    credential =
                                                                    PhoneAuthProvider
                                                                        .credential(
                                                                  verificationId:
                                                                      verificationId,
                                                                  smsCode:
                                                                      enteredVerificationCode!,
                                                                );

                                                                try {
                                                                  // Reauthenticate the user with the credential
                                                                  await currentUser
                                                                      ?.reauthenticateWithCredential(
                                                                          credential);

                                                                  // // Delete the user account
                                                                  // await currentUser
                                                                  //     ?.delete();

                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'users')
                                                                      .doc(currentUser
                                                                          ?.uid)
                                                                      .set({
                                                                    'isDisabled':
                                                                        true,
                                                                  }, SetOptions(merge: true));

                                                                  // Show a success message to the user
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(
                                                                          'Account deleted successfully.'),
                                                                    ),
                                                                  );

                                                                  // Sign out the user
                                                                  await FirebaseAuth
                                                                      .instance
                                                                      .signOut();
                                                                  // navigate to splash screen
                                                                  Navigator.of(
                                                                          context)
                                                                      .pushReplacement(
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              SplashScreen(),
                                                                    ),
                                                                  );
                                                                } catch (e) {
                                                                  // Show an error message if the reauthentication fails
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(e
                                                                          .toString()
                                                                          .substring(
                                                                              30)),
                                                                    ),
                                                                  );
                                                                  print(
                                                                      'Error: $e');
                                                                }
                                                              }
                                                            },
                                                            child:
                                                                Text('Verify'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  codeAutoRetrievalTimeout:
                                                      (String
                                                          verificationId) {},
                                                );
                                              } else {
                                                String? enteredPassword;

                                                // Show a password prompt dialog to the user
                                                enteredPassword =
                                                    await showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: Text(
                                                        'Password Confirmation'),
                                                    content: TextFormField(
                                                      controller:
                                                          _enterPasswordController,
                                                      obscureText: true,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'Enter your password',
                                                      ),
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Please enter your password';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(null),
                                                        child: Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          enteredPassword =
                                                              _enterPasswordController
                                                                  .text;
                                                          if (enteredPassword !=
                                                              null) {
                                                            // Reauthenticate the user with the entered password
                                                            AuthCredential
                                                                credential =
                                                                EmailAuthProvider
                                                                    .credential(
                                                              email: currentUser
                                                                      ?.email ??
                                                                  '',
                                                              password:
                                                                  enteredPassword!,
                                                            );

                                                            // Delete the user account
                                                            try {
                                                              await currentUser
                                                                  ?.reauthenticateWithCredential(
                                                                      credential);

                                                              //navigate to splash screen with root context
                                                              Navigator.of(
                                                                      context,
                                                                      rootNavigator:
                                                                          true)
                                                                  .pushReplacement(
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          LoginPage(),
                                                                ),
                                                              );
                                                            } catch (e) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(e
                                                                      .toString()
                                                                      .substring(
                                                                          30)),
                                                                ),
                                                              );
                                                              print(
                                                                  'Error: $e');
                                                            }

                                                            // firebase isDisabled true
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(currentUser
                                                                    ?.uid)
                                                                .set(
                                                                    {
                                                                  'isDisabled':
                                                                      true,
                                                                },
                                                                    SetOptions(
                                                                        merge:
                                                                            true));

                                                            // // Sign out the user
                                                            // await FirebaseAuth.instance
                                                            //     .signOut();
                                                          }
                                                        },
                                                        child: Text('Confirm'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    : const SizedBox(
                                        width: 0,
                                        height: 0,
                                      ), // Empty SizedBox
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ));
        },
      ),
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ProfileInfoItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.montserrat().fontFamily),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
