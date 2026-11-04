import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/register_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../models/community_model.dart';
import '../../models/education_model.dart';
import '../../models/gotra_model.dart';
import '../../models/profession_model.dart';
import 'widgets/counter_field.dart';
import 'widgets/custom_dropdown_field.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/photo_upload_card.dart';
import 'widgets/radio_selector_card.dart';

class RegisterScreen extends StatelessWidget {
  final String? verifiedMobile;

  const RegisterScreen({super.key, this.verifiedMobile});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(
      RegisterController(initialMobile: verifiedMobile),
    );

    final List<String> steps = [
      'Basic Info',
      'Career',
      'Family',
      'Community',
      'Photos & Bio',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoadingDropdowns.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Loading registration data...',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Step Progress Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(steps.length, (index) {
                      final isCurrent = controller.currentStep.value == index;
                      final isDone = controller.currentStep.value > index;

                      return Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? AppColors.primary
                                    : (isCurrent ? AppColors.primaryLight : AppColors.inputBg),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDone || isCurrent
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: isDone
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isCurrent
                                              ? AppColors.primary
                                              : AppColors.textMuted,
                                        ),
                                      ),
                              ),
                            ),
                            if (index < steps.length - 1)
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: isDone ? AppColors.primary : AppColors.border,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step ${controller.currentStep.value + 1} of ${steps.length}: ${steps[controller.currentStep.value]}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.border),

            // Form Content Based on Current Step
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildCurrentStepContent(context, controller),
              ),
            ),

            // Navigation Bottom Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (controller.currentStep.value > 0)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          controller.currentStep.value--;
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Previous',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (controller.currentStep.value > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () {
                              if (controller.currentStep.value < steps.length - 1) {
                                if (controller.validateStep(controller.currentStep.value)) {
                                  controller.currentStep.value++;
                                }
                              } else {
                                controller.submitRegistration();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 1,
                      ),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              controller.currentStep.value < steps.length - 1
                                  ? 'Next Step'
                                  : 'Complete Registration',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCurrentStepContent(BuildContext context, RegisterController controller) {
    switch (controller.currentStep.value) {
      case 0:
        return _buildStep1BasicInfo(context, controller);
      case 1:
        return _buildStep2EducationCareer(context, controller);
      case 2:
        return _buildStep3FamilyInfo(context, controller);
      case 3:
        return _buildStep4CommunityGotra(context, controller);
      case 4:
        return _buildStep5PhotosAndBio(context, controller);
      default:
        return const SizedBox();
    }
  }

  /// Step 1: Personal, Horoscope & Basic Info
  Widget _buildStep1BasicInfo(BuildContext context, RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Personal Details', 'Enter candidate basic identity details'),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Full Name',
          controller: controller.nameController,
          isRequired: true,
          hint: 'e.g. Rahul Sharma',
        ),
        const SizedBox(height: 16),
        Obx(
          () => RadioSelectorGroup(
            label: 'Gender',
            selectedValue: controller.selectedGender.value,
            options: const ['Male', 'Female'],
            isRequired: true,
            onChanged: (val) => controller.selectedGender.value = val,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Date of Birth',
                controller: controller.dobController,
                readOnly: true,
                isRequired: true,
                hint: 'YYYY-MM-DD',
                suffixIcon: const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                onTap: () => controller.pickDateOfBirth(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'Time of Birth',
                controller: controller.tobController,
                readOnly: true,
                isRequired: true,
                hint: 'HH:MM',
                suffixIcon: const Icon(Icons.access_time, size: 18, color: AppColors.primary),
                onTap: () => controller.pickTimeOfBirth(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Place of Birth',
          controller: controller.pobController,
          isRequired: true,
          hint: 'City / Town name',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Email Address',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
          hint: 'e.g. candidate@example.com',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => CustomDropdownField<String>(
                  label: 'Height (Feet)',
                  value: controller.selectedHeightFeet.value,
                  items: controller.feetOptions,
                  itemLabel: (item) => '$item ft',
                  isRequired: true,
                  onChanged: (val) {
                    if (val != null) controller.selectedHeightFeet.value = val;
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => CustomDropdownField<String>(
                  label: 'Height (Inches)',
                  value: controller.selectedHeightInch.value,
                  items: controller.inchOptions,
                  itemLabel: (item) => '$item in',
                  isRequired: true,
                  onChanged: (val) {
                    if (val != null) controller.selectedHeightInch.value = val;
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () => RadioSelectorGroup(
            label: 'Physical Disability',
            selectedValue: controller.physicalDisability.value,
            options: const ['No', 'Yes'],
            isRequired: true,
            onChanged: (val) => controller.physicalDisability.value = val,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => RadioSelectorGroup(
            label: 'Have you been married before?',
            selectedValue: controller.marriedBefore.value,
            options: const ['No', 'Yes'],
            isRequired: true,
            onChanged: (val) => controller.marriedBefore.value = val,
          ),
        ),

        // Conditional Marital Status fields if marriedBefore == 'Yes'
        Obx(() {
          if (controller.marriedBefore.value != 'Yes') return const SizedBox();
          return Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prior Marriage Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                RadioSelectorGroup(
                  label: 'Divorce Status',
                  selectedValue: controller.divorceStatus.value,
                  options: const ['Divorced', 'Awaiting Divorce', 'Widowed'],
                  isRequired: true,
                  onChanged: (val) => controller.divorceStatus.value = val,
                ),
                const SizedBox(height: 12),
                RadioSelectorGroup(
                  label: 'Children from Prior Marriage?',
                  selectedValue: controller.childrenFromPriorMarriage.value,
                  options: const ['No', 'Yes'],
                  isRequired: true,
                  onChanged: (val) => controller.childrenFromPriorMarriage.value = val,
                ),
                if (controller.childrenFromPriorMarriage.value == 'Yes') ...[
                  const SizedBox(height: 12),
                  CounterField(
                    label: 'Number of Children',
                    count: controller.childrenCount.value,
                    onChanged: (val) => controller.childrenCount.value = val > 0 ? val : 1,
                  ),
                  const SizedBox(height: 12),
                  RadioSelectorGroup(
                    label: 'Children Living Status',
                    selectedValue: controller.childrenWith.value,
                    options: const ['Living with me', 'Not living with me'],
                    isRequired: true,
                    onChanged: (val) => controller.childrenWith.value = val,
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Step 2: Education & Career (With Dynamic Conditional Fields from User Images!)
  Widget _buildStep2EducationCareer(BuildContext context, RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Education & Career', 'Qualifications and professional occupation'),
        const SizedBox(height: 16),

        // Education Dynamic Dropdown (From getEducation API)
        Obx(
          () => CustomDropdownField<EducationModel>(
            label: 'Education',
            value: controller.selectedEducation.value,
            items: controller.educationList,
            itemLabel: (item) => item.educationName,
            isRequired: true,
            hint: 'Select Education Qualification',
            onChanged: (val) => controller.selectedEducation.value = val,
          ),
        ),

        const SizedBox(height: 20),

        // Profession Dynamic Dropdown (From getProfession API)
        Obx(
          () => CustomDropdownField<ProfessionModel>(
            label: 'Profession',
            value: controller.selectedProfession.value,
            items: controller.professionList,
            itemLabel: (item) => item.professionName,
            isRequired: true,
            hint: 'Select Occupation / Profession',
            onChanged: (val) => controller.selectedProfession.value = val,
          ),
        ),

        const SizedBox(height: 16),

        // Dynamic Conditional Fields based on Selected Profession (Matching User's 5 Mockup Images)
        Obx(() {
          final prof = controller.selectedProfession.value;
          if (prof == null) return const SizedBox();

          // Case 1: Employed in Private Sector or Employed in Govt. Sector
          if (prof.isPrivateOrGovt) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Company Name',
                  controller: controller.companyNameController,
                  isRequired: true,
                  hint: 'Enter employer or organization name',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Company Type',
                  controller: controller.companyTypeController,
                  isRequired: true,
                  hint: 'e.g. MNC, Private Ltd, PSU',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Annual Income (in Lakh)',
                  controller: controller.annualIncomeController,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  hint: 'e.g. 12',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('₹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          }

          // Case 2: Own Business / Family Business
          if (prof.isBusiness) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Business Name',
                  controller: controller.businessNameController,
                  isRequired: true,
                  hint: 'Enter your business / firm name',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Business Type',
                  controller: controller.businessTypeController,
                  isRequired: true,
                  hint: 'e.g. Retail, Manufacturing, Trading',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Annual Income (in Lakh)',
                  controller: controller.annualIncomeController,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  hint: 'e.g. 25',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('₹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          }

          // Case 3: Self Employed (CA, CS, Lawyer, etc.)
          if (prof.isSelfEmployed) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Annual Income (in Lakh)',
                  controller: controller.annualIncomeController,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  hint: 'e.g. 15',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('₹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          }

          // Case 4: Others
          if (prof.isOthers) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Other Profession',
                  controller: controller.otherProfessionController,
                  isRequired: true,
                  hint: 'Specify your profession',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Annual Income (in Lakh)',
                  controller: controller.annualIncomeController,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  hint: 'e.g. 8',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('₹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          }

          // Case 5: Not in any Profession / None
          return const SizedBox();
        }),
      ],
    );
  }

  /// Step 3: Family Details & Residence
  Widget _buildStep3FamilyInfo(BuildContext context, RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Family Background', 'Parents, siblings and residence information'),
        const SizedBox(height: 16),
        CustomTextField(
          label: "Father's Name",
          controller: controller.fatherNameController,
          isRequired: true,
          hint: 'e.g. Shri Rajesh Sharma',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: "Mother's Name",
          controller: controller.motherNameController,
          hint: 'e.g. Smt. Sunita Sharma',
        ),
        const SizedBox(height: 20),

        const Text(
          'Siblings Information',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        Obx(
          () => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CounterField(
                      label: 'Brother (Married)',
                      count: controller.brotherMarried.value,
                      onChanged: (val) => controller.brotherMarried.value = val,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CounterField(
                      label: 'Brother (Unmarried)',
                      count: controller.brotherUnMarried.value,
                      onChanged: (val) => controller.brotherUnMarried.value = val,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CounterField(
                      label: 'Sister (Married)',
                      count: controller.sisterMarried.value,
                      onChanged: (val) => controller.sisterMarried.value = val,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CounterField(
                      label: 'Sister (Unmarried)',
                      count: controller.sisterUnMarried.value,
                      onChanged: (val) => controller.sisterUnMarried.value = val,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Obx(
          () => RadioSelectorGroup(
            label: 'House Type',
            selectedValue: controller.houseType.value,
            options: const ['Own', 'Rent'],
            isRequired: true,
            onChanged: (val) => controller.houseType.value = val,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Residential Address',
          controller: controller.userAddressController,
          maxLines: 2,
          isRequired: true,
          hint: 'House / Flat no, Street, Landmark',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Current City',
          controller: controller.userCurrentCityController,
          isRequired: true,
          hint: 'City where candidate currently resides',
        ),
      ],
    );
  }

  /// Step 4: Community, Gotra & Horoscope
  Widget _buildStep4CommunityGotra(BuildContext context, RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Community & Gotra', 'Dynamic samaj selection and astrological details'),
        const SizedBox(height: 16),

        // Community Dropdown (From getCommunity API)
        Obx(
          () => CustomDropdownField<CommunityModel>(
            label: 'Community',
            value: controller.selectedCommunity.value,
            items: controller.communityList,
            itemLabel: (item) => item.communityName,
            isRequired: true,
            hint: 'Select Community',
            onChanged: (val) => controller.onCommunityChanged(val),
          ),
        ),

        const SizedBox(height: 16),

        // Dynamic Gotra Dropdown (Fetched dynamically when Community is chosen!)
        Obx(
          () => CustomDropdownField<GotraModel>(
            label: 'Gotra',
            value: controller.selectedGotra.value,
            items: controller.gotraList,
            itemLabel: (item) => item.gotraName,
            isRequired: true,
            isLoading: controller.isLoadingGotra.value,
            hint: controller.isLoadingGotra.value
                ? 'Loading Gotras...'
                : 'Select Gotra',
            onChanged: (val) => controller.selectedGotra.value = val,
          ),
        ),

        const SizedBox(height: 20),

        // Multi-select for Marry in Community
        const Row(
          children: [
            Text(
              'Preferred Marry in Community',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(' *', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Select all communities candidate is open to marry in:',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.communityList.map((comm) {
              final isSelected = controller.selectedMarryCommunities.contains(comm);
              return FilterChip(
                label: Text(comm.communityName),
                selected: isSelected,
                selectedColor: AppColors.primaryLight,
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                onSelected: (_) => controller.toggleMarryCommunity(comm),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),
        Obx(
          () => RadioSelectorGroup(
            label: 'Will marry in same Gotra?',
            selectedValue: controller.willMarrySameGotra.value,
            options: const ['No', 'Yes'],
            isRequired: true,
            onChanged: (val) => controller.willMarrySameGotra.value = val,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => RadioSelectorGroup(
            label: 'Is Candidate Manglik?',
            selectedValue: controller.isManglik.value,
            options: const ['No', 'Yes', 'Anshik Manglik', "Don't Know"],
            isRequired: true,
            onChanged: (val) => controller.isManglik.value = val,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => RadioSelectorGroup(
            label: 'Will Marry Manglik?',
            selectedValue: controller.willMarryManglik.value,
            options: const ['Yes', 'No', "Doesn't Matter"],
            isRequired: true,
            onChanged: (val) => controller.willMarryManglik.value = val,
          ),
        ),
      ],
    );
  }

  /// Step 5: Contact, Bio & Photos
  Widget _buildStep5PhotosAndBio(BuildContext context, RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Contact & Photos', 'Communication info, bio summary and profile photos'),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Primary Contact Person',
          controller: controller.contactNameController,
          isRequired: true,
          hint: 'e.g. Father / Candidate',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Verified Mobile Number',
          controller: controller.mobileController,
          keyboardType: TextInputType.phone,
          isRequired: true,
          readOnly: controller.mobileController.text.isNotEmpty,
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 18, color: Color(0xFF4CAF50)),
                SizedBox(width: 4),
                Text('+91', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Alternate Contact Person',
          controller: controller.alternateContactNameController,
          isRequired: true,
          hint: 'e.g. Mother / Uncle / Sibling',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Alternate Mobile Number',
          controller: controller.alternateMobileNoController,
          keyboardType: TextInputType.phone,
          isRequired: true,
          hint: '10-digit mobile number',
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'About Candidate (Summary)',
          controller: controller.userSummaryController,
          maxLines: 4,
          isRequired: true,
          hint: 'Describe personality, family values, hobbies and partner expectations...',
        ),
        const SizedBox(height: 24),

        // Photo Uploads: full_image and face_image
        Obx(
          () => PhotoUploadCard(
            title: 'Full Length Photo',
            subtitle: 'Upload a clear full-length photograph of the candidate',
            imageFile: controller.fullImage.value,
            isRequired: true,
            onPickImage: (source) => controller.pickFullImage(source),
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => PhotoUploadCard(
            title: 'Close-up Face Photo',
            subtitle: 'Upload a well-lit portrait/face photograph of the candidate',
            imageFile: controller.faceImage.value,
            isRequired: true,
            onPickImage: (source) => controller.pickFaceImage(source),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
