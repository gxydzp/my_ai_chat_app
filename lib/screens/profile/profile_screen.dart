// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().profile;
    _nameController = TextEditingController(text: user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<UserProvider>().setName(_nameController.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人资料'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: '昵称'),
        ),
      ),
    );
  }
}
