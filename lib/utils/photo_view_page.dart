import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'const_helper.dart';

class PhotoViewPage extends StatelessWidget {
  final String imagePath;

  const PhotoViewPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          iconTheme: IconThemeData(color: ConstHelper.whiteColor),
          backgroundColor: Colors.black,
          title: Text(
            'photo'.tr,
            style: TextStyle(color: ConstHelper.whiteColor),
          ),
          centerTitle: true,
        ),
        body: InteractiveViewer(
          minScale: 1.0,
          maxScale: 3.0,
          child: imagePath.startsWith('http')
              ? Image.network(
                  imagePath,
                  height: Get.height,
                  width: Get.width,
                )
              : Image.file(
                  File(imagePath),
                  height: Get.height,
                  width: Get.width,
                ),
        ), // Optional: Align panning to one axis
      ),
    );
  }
}
