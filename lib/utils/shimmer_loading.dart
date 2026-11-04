import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'const_helper.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerLoading.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
  }) : shapeBorder = const RoundedRectangleBorder();

  const ShimmerLoading.circular({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
    this.shapeBorder = const CircleBorder(),
  });

  const ShimmerLoading.rounded({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[400]!,
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class MemberCardShimmer extends StatelessWidget {
  const MemberCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ConstHelper.whiteColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
        border: Border.all(
          width: 0.8,
          color: const Color(0xFFF0F0F5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular avatar skeleton
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 3.0,
              ),
            ),
            padding: const EdgeInsets.all(2.5),
            child: const ShimmerLoading.circular(),
          ),
          const SizedBox(width: 10),
          // Vertical accent bar
          Container(
            width: 5,
            height: 86,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300]!,
            ),
          ),
          const SizedBox(width: 10),
          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & ID badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerLoading.rounded(
                      height: 16,
                      width: 120,
                    ),
                    ShimmerLoading.rounded(
                      height: 18,
                      width: 36,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // DOB
                const ShimmerLoading.rounded(
                  height: 12,
                  width: 130,
                ),
                const SizedBox(height: 4),
                // EDU
                const ShimmerLoading.rounded(
                  height: 12,
                  width: 90,
                ),
                const SizedBox(height: 4),
                // Profession
                const ShimmerLoading.rounded(
                  height: 12,
                  width: 140,
                ),
                const SizedBox(height: 8),
                // Badges & Button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        ShimmerLoading.rounded(
                          height: 20,
                          width: 65,
                        ),
                        SizedBox(width: 6),
                        ShimmerLoading.rounded(
                          height: 20,
                          width: 55,
                        ),
                      ],
                    ),
                    const ShimmerLoading.rounded(
                      height: 26,
                      width: 85,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MemberGridShimmer extends StatelessWidget {
  const MemberGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.52,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const MemberCardShimmer();
      },
    );
  }
}

class MemberListShimmer extends StatelessWidget {
  const MemberListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const MemberCardShimmer();
      },
    );
  }
}

class ProfileDetailsShimmer extends StatelessWidget {
  const ProfileDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            color: Colors.grey[200],
            child: const Center(
              child: ShimmerLoading.circular(
                width: 120,
                height: 120,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading.rounded(height: 24, width: 200),
                const SizedBox(height: 8),
                const ShimmerLoading.rounded(height: 14, width: 100),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const ShimmerLoading.rounded(height: 18, width: 150),
                const SizedBox(height: 12),
                const ShimmerLoading.rounded(height: 14, width: double.infinity),
                const SizedBox(height: 8),
                const ShimmerLoading.rounded(height: 14, width: 250),
                const SizedBox(height: 24),
                const ShimmerLoading.rounded(height: 18, width: 150),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) => const ShimmerLoading.rounded(height: 40, width: 100)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
