import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/member_item_model.dart';
import '../../../controllers/user_home_controller.dart';

class CandidateBlockDialog extends StatefulWidget {
  final MemberItemModel member;
  final UserHomeController controller;

  const CandidateBlockDialog({
    super.key,
    required this.member,
    required this.controller,
  });

  static void show(BuildContext context, MemberItemModel member, UserHomeController controller) {
    showDialog(
      context: context,
      builder: (ctx) => CandidateBlockDialog(member: member, controller: controller),
    );
  }

  @override
  State<CandidateBlockDialog> createState() => _CandidateBlockDialogState();
}

class _CandidateBlockDialogState extends State<CandidateBlockDialog> {
  static const List<Map<String, dynamic>> _reasons = [
    {'title': 'Married/Engaged', 'value': 0},
    {'title': 'Duplicate Profile', 'value': 1},
    {'title': 'Incomplete Information', 'value': 2},
    {'title': 'Wrong Information', 'value': 3},
    {'title': 'Block User', 'value': 4},
  ];

  int _selectedReasonValue = 0;
  final TextEditingController _reasonController = TextEditingController();
  bool _isBlocking = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _confirmBlock() async {
    setState(() => _isBlocking = true);
    final selectedOption = _reasons.firstWhere(
      (r) => r['value'] == _selectedReasonValue,
      orElse: () => _reasons.first,
    );
    final String selectedTitle = selectedOption['title'] as String;
    final int selectedValue = selectedOption['value'] as int;
    final String notes = _reasonController.text.trim();
    final String finalDescription = notes.isNotEmpty ? '$selectedTitle: $notes' : selectedTitle;

    await widget.controller.blockProfile(
      toId: widget.member.id,
      candidateName: widget.member.name,
      reason: finalDescription,
      reasonValue: selectedValue,
      reasonTitle: selectedTitle,
    );
    if (mounted) {
      setState(() => _isBlocking = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.block, color: Color(0xFFD32F2F), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Block Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Block ${widget.member.name}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to block this profile? They will no longer appear in your partner recommendations.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reason for Blocking:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedReasonValue,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                    items: _reasons.map((r) {
                      return DropdownMenuItem<int>(
                        value: r['value'] as int,
                        child: Text(
                          r['title'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedReasonValue = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Additional Comments (Optional):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  hintText: 'e.g. Any additional details',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                  ),
                ),
              ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isBlocking ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isBlocking ? null : _confirmBlock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isBlocking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Block Profile',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
