import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String userName;
  final String profileImagePath;

  const EditProfilePage({super.key, required this.userName, required this.profileImagePath});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  String avatarPath = '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userName);
    avatarPath = widget.profileImagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
                radius: 50,
                backgroundImage: avatarPath.startsWith('assets/')
                    ? AssetImage(avatarPath)
                    : FileImage(File(avatarPath)) as ImageProvider),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => avatarPath = picked.path);
                }
              },
              child: const Text("Change Avatar"),
            ),
            const SizedBox(height: 20),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Get.back(result: {'name': nameController.text, 'avatar': avatarPath});
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
