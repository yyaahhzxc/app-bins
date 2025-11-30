import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/friend.dart';
import '../utils/constants.dart';
import 'person_info_screen.dart';
import '../widgets/fade_in_slide.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'Name'; 
  bool _isAscending = true; 
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    final baseList = _showArchived ? appState.archivedFriends : appState.activeFriends;
    final sortedList = appState.sortFriends(baseList, _sortBy, _isAscending);
    final friends = _searchQuery.isEmpty
        ? sortedList
        : appState.searchFriends(_searchQuery, searchArchived: _showArchived);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kPaddingLarge),
              child: Column(
                children: [
                  const Text(
                    'Persons',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryColor),
                  ),
                  const SizedBox(height: kPaddingLarge),

                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      // FIXED: Quotes
                      hintText: _showArchived ? 'Search archive...' : 'Search people...',
                      suffixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[800] 
                          : const Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: kPaddingLarge, vertical: 14),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: kPaddingMedium),

                  Row(
                    children: [
                      const Icon(Icons.sort, size: 20),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        initialValue: _sortBy,
                        onSelected: (String item) {
                          setState(() {
                            if (_sortBy == item) {
                              _isAscending = !_isAscending; 
                            } else {
                              _sortBy = item;
                              _isAscending = true; 
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
                              // FIXED: Quotes
                              'Sort by: $_sortBy',
                              style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyMedium?.color),
                            ),
                            Icon(
                              _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _showArchived ? Icons.archive : Icons.archive_outlined,
                          color: kPrimaryColor,
                        ),
                        // FIXED: Quotes
                        tooltip: _showArchived ? 'Show Active' : 'Show Archived',
                        onPressed: () {
                          setState(() {
                            _showArchived = !_showArchived;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_showArchived)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      color: Colors.grey[200],
                      child: const Center(
                        child: Text(
                          'ARCHIVED VIEW',
                          style: TextStyle(fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: friends.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _showArchived ? 'No archived persons' : 'No persons found',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: kPaddingLarge),
                      itemCount: friends.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return FadeInSlide(
                          index: index,
                          child: _buildPersonTile(context, appState, friends[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonTile(BuildContext context, AppState appState, Friend friend) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => PersonInfoModal(friend: friend),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(kPaddingMedium),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8EAF6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'friend_name_${friend.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      friend.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF333333),
                      ),
                    ),
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
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}