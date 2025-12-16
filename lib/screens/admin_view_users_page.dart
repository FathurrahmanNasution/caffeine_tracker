import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:caffeine_tracker/model/user_model.dart';
import 'package:caffeine_tracker/services/admin_user_service.dart';

class AdminViewUsersPage extends StatefulWidget {
  const AdminViewUsersPage({super.key});

  @override
  State<AdminViewUsersPage> createState() => _AdminViewUsersPageState();
}

class _AdminViewUsersPageState extends State<AdminViewUsersPage> {
  final _adminUserService = AdminUserService();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper method to get display name safely
  String _getDisplayName(UserModel user) {
    return user.displayName ?? user.username ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EBE0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD5BBA2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF42261D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'View Users',
          style: TextStyle(
            color: Color(0xFF42261D),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by name, username, or email...',
                hintStyle: const TextStyle(color: Color(0xFF9E8B7B)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6E3D2C)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF6E3D2C)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFA67C52)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFFA67C52)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF6E3D2C), width: 2),
                ),
              ),
            ),
          ),

          // User Statistics Cards
          _buildStatisticsCards(),

          // Users List
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _searchQuery.isEmpty
                  ? _adminUserService.getAllUsers()
                  : _adminUserService.searchUsers(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6E3D2C)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Color(0xFF6E3D2C)),
                    ),
                  );
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No users found' : 'No matching users',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(users[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: FutureBuilder<int>(
              future: _adminUserService.getUserCount(),
              builder: (context, snapshot) {
                return _buildStatCard(
                  'Total Users',
                  snapshot.data?.toString() ?? '...',
                  Icons.people,
                  const Color(0xFF4E8D7C),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FutureBuilder<int>(
              future: _adminUserService.getAdminCount(),
              builder: (context, snapshot) {
                return _buildStatCard(
                  'Admins',
                  snapshot.data?.toString() ?? '...',
                  Icons.admin_panel_settings,
                  const Color(0xFF6E3D2C),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6E3D2C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: user.isAdmin ? const Color(0xFF6E3D2C) : const Color(0xFFA67C52),
          width: user.isAdmin ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showUserDetailsDialog(user),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Profile Picture
                _buildProfileAvatar(user),
                const SizedBox(width: 12),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getDisplayName(user),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF42261D),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.isAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6E3D2C),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6E3D2C),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Joined: ${DateFormat('MMM dd, yyyy').format(user.createdAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF6E3D2C)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Color(0xFF4E8D7C), size: 20),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_admin',
                      child: Row(
                        children: [
                          Icon(
                            user.isAdmin ? Icons.remove_moderator : Icons.admin_panel_settings,
                            color: const Color(0xFF6E3D2C),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(user.isAdmin ? 'Remove Admin' : 'Make Admin'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete User', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'view') {
                      _showUserDetailsDialog(user);
                    } else if (value == 'toggle_admin') {
                      _toggleAdminStatus(user);
                    } else if (value == 'delete') {
                      _showDeleteDialog(user);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(UserModel user) {
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: const Color(0xFFE8DED1),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: user.photoUrl!,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42261D)),
              ),
            ),
            errorWidget: (context, url, error) => _buildDefaultAvatar(user),
          ),
        ),
      );
    }

    return _buildDefaultAvatar(user);
  }

  Widget _buildDefaultAvatar(UserModel user) {
    String name = _getDisplayName(user);
    String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return CircleAvatar(
      radius: 30,
      backgroundColor: const Color(0xFFE8DED1),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF42261D),
        ),
      ),
    );
  }

  void _showUserDetailsDialog(UserModel user) async {
    final consumptionCount = await _adminUserService.getUserConsumptionCount(user.uid);
    final totalCaffeine = await _adminUserService.getUserTotalCaffeine(user.uid);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5EBE0),
        title: Row(
          children: [
            _buildProfileAvatar(user),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getDisplayName(user),
                style: const TextStyle(
                  color: Color(0xFF42261D),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Username', '@${user.username}'),
              _buildDetailRow('Email', user.email ?? ''),
              if (user.displayName != null)
                _buildDetailRow('Display Name', user.displayName!),
              _buildDetailRow('Role', user.isAdmin ? 'Admin' : 'User'),
              if (user.createdAt != null)
                _buildDetailRow(
                  'Joined',
                  DateFormat('MMM dd, yyyy').format(user.createdAt!),
                ),
              const Divider(color: Color(0xFFA67C52)),
              _buildDetailRow('Total Logs', '$consumptionCount drinks'),
              _buildDetailRow(
                'Total Caffeine',
                '${totalCaffeine.toStringAsFixed(1)} mg',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF6E3D2C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF6E3D2C),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF42261D)),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleAdminStatus(UserModel user) async {
    final newStatus = !user.isAdmin;
    final action = newStatus ? 'promote to admin' : 'remove admin privileges';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5EBE0),
        title: Text(
          newStatus ? 'Make Admin?' : 'Remove Admin?',
          style: const TextStyle(color: Color(0xFF42261D)),
        ),
        content: Text(
          'Are you sure you want to $action for ${_getDisplayName(user)}?',
          style: const TextStyle(color: Color(0xFF6E3D2C)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6E3D2C))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Confirm',
              style: TextStyle(
                color: newStatus ? const Color(0xFF4E8D7C) : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _adminUserService.toggleAdminStatus(user.uid, user.isAdmin);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newStatus
                    ? 'User promoted to admin'
                    : 'Admin privileges removed',
              ),
              backgroundColor: const Color(0xFF6E3D2C),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDeleteDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5EBE0),
        title: const Text(
          'Delete User',
          style: TextStyle(
            color: Color(0xFF42261D),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${_getDisplayName(user)}"?\n\nThis will permanently delete:\n• User account\n• All consumption logs\n• All favorites\n\nThis action cannot be undone!',
          style: const TextStyle(color: Color(0xFF6E3D2C)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6E3D2C)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                await _adminUserService.deleteUser(user.uid);

                if (mounted) {
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('User deleted successfully!'),
                      backgroundColor: Color(0xFF6E3D2C),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}