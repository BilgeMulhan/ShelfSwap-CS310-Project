import 'package:flutter/material.dart';
import '../utils/app_paddings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Incoming'),
            Tab(text: 'Outgoing'),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.screen,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search requests...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [

                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('requests')
                          .where('toUserId', isEqualTo: currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final requests = snapshot.data!.docs;

                        if (requests.isEmpty) {
                          return const Center(child: Text("No incoming requests"));
                        }

                        return ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final data = requests[index].data();

                            return FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('listings')
                                  .doc(data['itemId'])
                                  .get(),
                              builder: (context, itemSnapshot) {
                                if (!itemSnapshot.hasData) {
                                  return const ListTile(title: Text("Loading..."));
                                }

                                final itemData = itemSnapshot.data!.data();

                                if (itemData == null) {
                                  return const ListTile(title: Text("Item not found"));
                                }

                                return ListTile(
                                  leading: itemData['imageUrl'] != null
                                      ? Image.network(
                                    itemData['imageUrl'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                      : const Icon(Icons.image),

                                  title: Text(itemData['title'] ?? 'Item'),

                                  subtitle: Text("Status: ${data['status']}"),

                                  trailing: data['status'] == 'pending'
                                      ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('requests')
                                              .doc(requests[index].id)
                                              .update({'status': 'accepted'});
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('requests')
                                              .doc(requests[index].id)
                                              .update({'status': 'rejected'});
                                        },
                                      ),
                                    ],
                                  )
                                      : null,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),

                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('requests')
                          .where('fromUserId', isEqualTo: currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final requests = snapshot.data!.docs;

                        if (requests.isEmpty) {
                          return const Center(child: Text("No outgoing requests"));
                        }

                        return ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final data = requests[index].data();

                            return FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('listings')
                                  .doc(data['itemId'])
                                  .get(),
                              builder: (context, itemSnapshot) {
                                if (!itemSnapshot.hasData) {
                                  return const ListTile(title: Text("Loading..."));
                                }

                                final itemData = itemSnapshot.data!.data();

                                if (itemData == null) {
                                  return const ListTile(title: Text("Item not found"));
                                }

                                return ListTile(
                                  leading: itemData['imageUrl'] != null
                                      ? Image.network(
                                    itemData['imageUrl'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                      : const Icon(Icons.image),

                                  title: Text(itemData['title'] ?? 'Item'),

                                  subtitle: Text("Status: ${data['status']}"),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}