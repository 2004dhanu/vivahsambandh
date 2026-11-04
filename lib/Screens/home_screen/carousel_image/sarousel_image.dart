import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Utils/const_helper.dart';

class SingleImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const SingleImageCarousel({super.key, required this.imageUrls});

  @override
  State<SingleImageCarousel> createState() => _SingleImageCarouselState();
}

class _SingleImageCarouselState extends State<SingleImageCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: Get.width / 1.2,
          width: Get.width / 1.2,
          child: CarouselSlider(
            carouselController: _controller,
            options: CarouselOptions(
              autoPlay: true,
              height: Get.width / 1.2,
              enlargeCenterPage: false,
              viewportFraction: 1.0,
              aspectRatio: 1,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: widget.imageUrls.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl.trim().isEmpty
                            ? ConstHelper.profileImagePath
                            : '${ConstHelper.userImagesPath}$imageUrl',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: ConstHelper.orangeColor,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: ConstHelper.whiteColor,
                          child: Image.asset(
                            'assets/image/imageNotFound.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageUrls.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key
                      ? ConstHelper.orangeColor
                      : ConstHelper.orangeColor.withAlpha(77),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
