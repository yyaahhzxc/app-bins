import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/friend.dart';
import '../utils/constants.dart';
import 'person_info_screen.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Sort State
  String _sortBy = 'Name'; // 'Name' or 'Last Paid'
  bool _isAscending = true; // Ascending Order?

  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    // Get the base list (Active or Archived)
    final baseList = _showArchived ? appState.archivedFriends : appState.activeFriends;

    // Apply Sort to the base list first
    final sortedList = appState.sortFriends(baseList, _sortBy, _isAscending);
    
    // Apply Search to the sorted list
    final friends = _searchQuery.isEmpty
        ? sortedList
        : appState.searchFriends(_searchQuery, searchArchived: _showArchived);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kPaddingLarge),
              child: Column(
                children: [
                  const Text(
                    'Persons',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: kPaddingLarge),

                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _showArchived ? 'Search archive...' : 'Hinted search text',
                      suffixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: kPaddingLarge,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: kPaddingMedium),

                  // Sort & Archive Row
                  Row(
                    children: [
                      const Icon(Icons.sort, size: 20),
                      const SizedBox(width: 8),
                      
                      // Sort Clickable Text
                      PopupMenuButton<String>(
                        initialValue: _sortBy,
                        onSelected: (String item) {
                          setState(() {
                            if (_sortBy == item) {
                              _isAscending = !_isAscending; // Toggle order if same selected
                            } else {
                              _sortBy = item;
                              _isAscending = true; // Reset to Ascending for new item
                            }
                          });
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(value: 'Name', child: Text('Name')),
                          const PopupMenuItem<String>(value: 'Last Paid', child: Text('Last Paid Date')),
                        ],
                        child: Row(
                          children: [
                            Text(
                              'Sort by: $_sortBy',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Icon(
                              _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Archive Button
                      IconButton(
                        icon: Icon(
                          _showArchived ? Icons.archive : Icons.archive_outlined,
                          color: kPrimaryColor,
                        ),
                        tooltip: _showArchived ? "Show Active" : "Show Archived",
                        onPressed: () {
                          setState(() {
                            _showArchived = !_showArchived;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  // Context indicator
                  if (_showArchived)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      color: Colors.grey[200],
                      child: const Center(
                        child: Text(
                          "ARCHIVED VIEW",
                          style: TextStyle(fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: friends.isEmpty
                  ? Center(
                      child: Text(
                        _showArchived ? 'No archived persons' : 'No persons found',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: kPaddingLarge),
                      itemCount: friends.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return _buildPersonTile(context, appState, friend);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonTile(BuildContext context, AppState appState, Friend friend) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => PersonInfoModal(friend: friend),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(kPaddingMedium),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EAF6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              friend.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last Paid: ${friend.lastPaidDate != null ? appState.formatDate(friend.lastPaidDate!) : "Never"}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}