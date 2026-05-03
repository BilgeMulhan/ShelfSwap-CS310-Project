import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/request_item.dart';
import '../providers/auth_provider.dart';
import '../providers/requests_provider.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../widgets/request_card.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;

      if (user != null) {
        context.read<RequestsProvider>().loadRequests(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<RequestItem> _filterRequests(List<RequestItem> requests) {
    final query = _searchQuery.toLowerCase().trim();

    if (query.isEmpty) return requests;

    return requests.where((request) {
      return request.itemTitle.toLowerCase().contains(query) ||
          request.senderName.toLowerCase().contains(query) ||
          request.senderEmail.toLowerCase().contains(query) ||
          request.location.toLowerCase().contains(query) ||
          request.status.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildRequestsList({
    required List<RequestItem> requests,
    required bool showActions,
  }) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.trim().isEmpty
              ? 'No requests yet'
              : 'No matching requests found',
        ),
      );
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];

        return InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.requestChat,
            arguments: request,
          ),
          child: RequestCard(
            request: request,
            showActions: showActions,
            onAccept: showActions
                ? () {
                    context.read<RequestsProvider>().updateRequestStatus(
                          request.id,
                          'accepted',
                        );
                  }
                : null,
            onDecline: showActions
                ? () {
                    context.read<RequestsProvider>().updateRequestStatus(
                          request.id,
                          'declined',
                        );
                  }
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final requestsProvider = context.watch<RequestsProvider>();

    final incomingRequests =
        _filterRequests(requestsProvider.incomingRequests);

    final outgoingRequests =
        _filterRequests(requestsProvider.outgoingRequests);

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
          child: user == null
              ? const Center(
                  child: Text('Please log in to see your requests.'),
                )
              : Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
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
                      child: requestsProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildRequestsList(
                                  requests: incomingRequests,
                                  showActions: true,
                                ),
                                _buildRequestsList(
                                  requests: outgoingRequests,
                                  showActions: false,
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