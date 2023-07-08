import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Screens/Admin/admindashboard.dart';

class AdminAccountsControlPage extends StatefulWidget {
  const AdminAccountsControlPage({super.key});

  @override
  State<AdminAccountsControlPage> createState() =>
      _AdminAccountsControlPageState();
}

Future<dynamic> fetchAllUsers() async {
  var usersList;
  usersList = await FirebaseFirestore.instance.collection('users').get();
  // print(usersList.docs.length);
  return usersList;
}

class _AdminAccountsControlPageState extends State<AdminAccountsControlPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Contracts'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminDashboard()),
              );
            }),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff0FA697),
                Color(0xff45BF7A),
                Color(0xff0DF205),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: fetchAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                // print(snapshot.data.docs[index]['firstName'] +
                //     ' ' +
                //     snapshot.data.docs[index]['lastName']);
                return ListTile(
                  title: Text(snapshot.data.docs[index]['firstName'] +
                      ' ' +
                      snapshot.data.docs[index]['lastName']),
                  subtitle: snapshot.data.docs[index]['emailOrPhone'] != null
                      ? Text(snapshot.data.docs[index]['emailOrPhone'])
                      : Text(''),
                  trailing: snapshot.data.docs[index]['type'] != null
                      ? Text(snapshot.data.docs[index]['type'])
                      : Text(''),
                  leading: (snapshot.data.docs[index]
                                  .data()
                                  .containsKey('isDisabled') &&
                              snapshot.data.docs[index].data()['isDisabled'] !=
                                  null) &&
                          snapshot.data.docs[index]['isDisabled'] == true
                      ? Icon(Icons.block, color: Colors.red)
                      : Text(''),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          //stateful builder with a checkbox to enable or disable user by setting the isDisabled field to true or false
                          // and then update the user in the database
                          return StatefulBuilder(
                            builder: (context, setState) {
                              bool? isDisabled = snapshot.data.docs[index]
                                          .data()
                                          .containsKey('isDisabled') &&
                                      snapshot.data.docs[index]['isDisabled'] !=
                                          null &&
                                      snapshot.data.docs[index]['isDisabled'] ==
                                          true
                                  ? true
                                  : false;
                              return StatefulBuilder(
                                builder: (BuildContext context, setState) {
                                  return AlertDialog(
                                    title: Text(snapshot.data.docs[index]
                                            ['firstName'] +
                                        ' ' +
                                        snapshot.data.docs[index]['lastName']),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Text(snapshot.data.docs[index]
                                        //     ['emailOrPhone']),
                                        // Text(snapshot.data.docs[index]['type']),
                                        CheckboxListTile(
                                          title: Text('Disable User'),
                                          value: isDisabled,
                                          onChanged: (value) {
                                            setState(() {
                                              print('activated');
                                              isDisabled = !isDisabled!;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(snapshot.data.docs[index].id)
                                              .update({
                                            'isDisabled': isDisabled,
                                          });

                                          //snackbar to show that the user has been updated
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content:
                                                Text('User has been updated'),
                                            duration:
                                                const Duration(seconds: 2),
                                          ));

                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return AdminAccountsControlPage();
                                          }));
                                        },
                                        child: Text('Save'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        });
                  },
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
