import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/admin_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/member_item_model.dart';

class EditAdminMemberDialog extends StatefulWidget {
  final MemberItemModel member;
  final AdminController controller;

  const EditAdminMemberDialog({
    super.key,
    required this.member,
    required this.controller,
  });

  @override
  State<EditAdminMemberDialog> createState() => _EditAdminMemberDialogState();
}

class _EditAdminMemberDialogState extends State<EditAdminMemberDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late String _selectedGender;
  File? _pickedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _emailController = TextEditingController(text: widget.member.email ?? '');
    _mobileController = TextEditingController(text: widget.member.mobile ?? '');
    _addressController = TextEditingController(text: widget.member.userAddress ?? '');
    _cityController = TextEditingController(text: widget.member.userCurrentCity ?? '');
    _selectedGender = (widget.member.gender.toLowerCase() == 'female') ? 'Female' : 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final mobile = _mobileController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Required', 'Please enter admin name.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (email.isEmpty) {
      Get.snackbar('Required', 'Please enter email address.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (mobile.isEmpty) {
      Get.snackbar('Required', 'Please enter 10-digit mobile number.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (address.isEmpty) {
      Get.snackbar('Required', 'Please enter address.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (city.isEmpty) {
      Get.snackbar('Required', 'Please enter current city.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);
    final success = await widget.controller.updateAdmin(
      adminId: widget.member.id,
      name: name,
      gender: _selectedGender,
      email: email,
      userAddress: address,
      userCurrentCity: city,
      mobile: mobile,
      faceImage: _pickedImage,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.85),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.edit_note, color: AppColors.primary, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Edit Admin Member',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 20, color: AppColors.border),

            // Form
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Picker
                    Center(
                      child: GestureDetector(
                        onTap: _pickPhoto,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage: _pickedImage != null
                                  ? FileImage(_pickedImage!) as ImageProvider
                                  : (widget.member.faceImage != null && widget.member.faceImage!.isNotEmpty)
                                      ? NetworkImage(widget.member.getImageUrl(widget.controller.userImageBase.value))
                                      : null,
                              child: (_pickedImage == null && (widget.member.faceImage == null || widget.member.faceImage!.isEmpty))
                                  ? const Icon(Icons.person, size: 40, color: AppColors.primary)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    _buildLabel('Full Name'),
                    _buildTextField(_nameController, 'Enter full name'),
                    const SizedBox(height: 12),

                    // Gender Radio
                    _buildLabel('Gender'),
                    Row(
                      children: ['Male', 'Female'].map((gender) {
                        final isSelected = _selectedGender == gender;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(gender),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedGender = gender);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Mobile
                    _buildLabel('Mobile Number'),
                    _buildTextField(_mobileController, 'Enter mobile number', keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),

                    // Email
                    _buildLabel('Email Address'),
                    _buildTextField(_emailController, 'Enter email address', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),

                    // Current City
                    _buildLabel('Current City'),
                    _buildTextField(_cityController, 'Enter current city'),
                    const SizedBox(height: 12),

                    // Address
                    _buildLabel('Full Address'),
                    _buildTextField(_addressController, 'Enter full address', maxLines: 2),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
