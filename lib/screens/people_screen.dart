import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/friend.dart';
import '../utils/constants.dart';
import '../widgets/friend_list_tile.dart';
import '../widgets/custom_text_field.dart';
import 'person_info_screen.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'Name';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final friends = _searchQuery.isEmpty
        ? appState.sortFriends(_sortBy)
        : appState.searchFriends(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Persons',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kTextOnPrimary,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Sort Header
          Container(
            padding: const EdgeInsets.all(kPaddingMedium),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Hinted search text',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: kPaddingMedium),

                // Sort Dropdown
                Row(
                  children: [
                    const Icon(Icons.sort, color: kPrimaryColor),
                    const SizedBox(width: kPaddingSmall),
                    const Text(
                      'Sort by:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: kPaddingSmall),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        underline: Container(),
                        items: ['Name', 'Balance', 'Last Paid'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _sortBy = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 28),
                      color: kPrimaryColor,
                      onPressed: () => _showAddPersonModal(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Friends List
          Expanded(
            child: friends.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: kPaddingMedium),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No persons yet'
                              : 'No results found',
                          style: TextStyle(
                            fontSize: kTitleSize,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(kPaddingMedium),
                    itemCount: friends.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: kPaddingMedium),
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return FriendListTile(
                        friend: friend,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PersonInfoScreen(friend: friend),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonModal(context),
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: kTextOnPrimary),
      ),
    );
  }

  void _showAddPersonModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    final appState = context.read<AppState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadius)),
      ),
      builder: (BuildContext modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: kPaddingMedium,
            right: kPaddingMedium,
            top: kPaddingMedium,
            bottom: MediaQuery.of(context).viewInsets.bottom + kPaddingMedium,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Modal Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: kPaddingMedium),
                
                // Title
                const Text(
                  'Add New Person',
                  style: TextStyle(
                    fontSize: kHeadingSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: kPaddingLarge),

                // Person Name
                CustomTextField(
                  label: 'Person Name',
                  hintText: 'Enter name',
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kPaddingMedium),

                // Notes
                CustomTextField(
                  label: 'Notes',
                  hintText: 'Optional notes',
                  controller: notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: kPaddingLarge),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: kPaddingMedium),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final friend = Friend(
                              name: nameController.text,
                              notes: notesController.text,
                            );

                            final success = await appState.addFriend(friend);
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Person added successfully'),
                                    backgroundColor: kPrimaryColor,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to add person'),
                                    backgroundColor: kErrorColor,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: const Text('Add Person'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
