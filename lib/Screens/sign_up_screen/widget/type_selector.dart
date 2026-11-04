import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/const_helper.dart';

class HouseTypeSelector extends StatefulWidget {
  final String title;
  final String? firstTitle;
  final String? secondTitle;
  final String? selectedValue;
  final Color? allColor;
  final Function(String) onChanged;

  const HouseTypeSelector({
    super.key,
    required this.title,
    this.selectedValue,
    required this.onChanged,
    this.firstTitle,
    this.secondTitle,
    this.allColor,
  });

  @override
  HouseTypeSelectorState createState() => HouseTypeSelectorState();
}

class HouseTypeSelectorState extends State<HouseTypeSelector> {
  String? selectedHouseType;

  @override
  void initState() {
    super.initState();
    selectedHouseType = widget.selectedValue;
  }

  @override
  void didUpdateWidget(HouseTypeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Synchronize the state when `selectedValue` changes.
    if (widget.selectedValue != oldWidget.selectedValue) {
      selectedHouseType = widget.selectedValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "${widget.title} ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.allColor ?? ConstHelper.whiteColor,
              fontSize: Get.width * 0.04,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            Radio<String>(
              value: widget.firstTitle ?? "",
              groupValue: selectedHouseType,
              fillColor:
                  MaterialStatePropertyAll(widget.allColor ?? Colors.white),
              onChanged: (value) {
                setState(() {
                  selectedHouseType = value!;
                });
                widget.onChanged(value!);
              },
            ),
            Text(
              widget.firstTitle ?? "",
              style: TextStyle(
                fontSize: Get.width * 0.04,
                letterSpacing: 1,
                color: widget.allColor ?? ConstHelper.whiteColor,
              ),
            ),
            const SizedBox(width: 16),
            Radio<String>(
              value: widget.secondTitle ?? "",
              fillColor:
                  MaterialStatePropertyAll(widget.allColor ?? Colors.white),
              groupValue: selectedHouseType,
              onChanged: (value) {
                setState(() {
                  selectedHouseType = value!;
                });
                widget.onChanged(value!);
              },
            ),
            Text(
              widget.secondTitle ?? "",
              style: TextStyle(
                color: widget.allColor ?? ConstHelper.whiteColor,
                fontSize: Get.width * 0.04,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
