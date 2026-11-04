import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class LegalWebViewScreen extends StatefulWidget {
  final int initialTabIndex; // 0: Privacy Policy, 1: Terms & Conditions

  const LegalWebViewScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<LegalWebViewScreen> createState() => _LegalWebViewScreenState();
}

class _LegalWebViewScreenState extends State<LegalWebViewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const String privacyPolicyUrl = 'https://vivahsambandh.com/privacy';
  static const String termsConditionsUrl = 'https://vivahsambandh.com/terms';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openInAppWebView(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
      );
    } catch (e) {
      debugPrint("Error opening in-app webview: $e");
      try {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF880E4F),
                Color(0xFFC2185B),
                Color(0xFFE91E63),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Legal & Compliance',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Privacy Policy', icon: Icon(Icons.privacy_tip_outlined, size: 20)),
            Tab(text: 'Terms & Conditions', icon: Icon(Icons.description_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPolicyContent(
            title: 'Privacy Policy',
            subtitle: 'Official Webpage: https://vivahsambandh.com/privacy',
            url: privacyPolicyUrl,
            sections: _privacyPolicySections,
          ),
          _buildPolicyContent(
            title: 'Terms & Conditions',
            subtitle: 'Official Webpage: https://vivahsambandh.com/terms',
            url: termsConditionsUrl,
            sections: _termsConditionsSections,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyContent({
    required String title,
    required String subtitle,
    required String url,
    required List<Map<String, String>> sections,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner card with webview button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF8BBD0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFCE4EC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: Color(0xFFE91E63), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openInAppWebView(url),
                    icon: const Icon(Icons.open_in_browser, color: Colors.white, size: 18),
                    label: const Text(
                      'Open Official Web Page',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Policy Sections
          ...sections.map((section) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['heading'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF880E4F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section['body'] ?? '',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF424242),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static const List<Map<String, String>> _privacyPolicySections = [
    {
      'heading': '1. Introduction & Scope',
      'body':
          'VivahSambandh ("we", "our", or "us") operates the matrimonial matchmaking platform accessible via our mobile application and official website at https://vivahsambandh.com/privacy. We are deeply committed to protecting the privacy, confidentiality, and security of our members. This Privacy Policy outlines our transparent practices regarding the collection, processing, storage, sharing, and safeguarding of personal and sensitive data when you register, browse matches, or interact on our platform.',
    },
    {
      'heading': '2. Information We Collect',
      'body':
          'To provide authentic matchmaking services within communities and ensure genuine alliances, we collect the following categories of information:\n\n'
          '• Personal & Demographic Details: Full name, gender, date of birth, time of birth, place of birth, and marital status (Never Married, Divorced, Widowed, Awaiting Divorce).\n'
          '• Cultural & Astrological Information: Community, Sub-caste, Gotra, mother tongue, native place, Manglik status, and horoscope/Kundali parameters.\n'
          '• Educational & Professional Background: Highest education qualification, profession, company/business name, employment type, annual income bracket, current residence city, and permanent address.\n'
          '• Family Background: Father and mother details, siblings status (married/unmarried), family values, and residential ownership status.\n'
          '• Photographs & Media: Profile face photographs and full-length portraits uploaded willingly for member discovery.\n'
          '• Contact & Authentication Data: Verified mobile number, alternate mobile number, contact person name, email address, and SMS OTP logs.\n'
          '• Device & App Identifiers: Device ID, operating system version, and Firebase Cloud Messaging (FCM) tokens used strictly for secure authentication and push notifications.',
    },
    {
      'heading': '3. How We Use Your Information',
      'body':
          'Your personal information is processed strictly for legitimate matrimonial purposes:\n\n'
          '• Account authentication, security validation, and identity verification via SMS OTP.\n'
          '• Serving algorithmic match suggestions and preference-based filtering according to age, height, gotra, community, education, and location.\n'
          '• Enabling consensual contact exchange, wishlisting, shortlisting, and direct family communication.\n'
          '• Fraud detection, spam suppression, prevention of multiple duplicate accounts, and community safety enforcement.\n'
          '• Dispatching transactional updates, membership confirmations, match alerts, and service communications.',
    },
    {
      'heading': '4. Profile Privacy, Visibility & Contact Masking',
      'body':
          'We provide robust privacy controls to safeguard our members:\n\n'
          '• No Public Web Crawling: Sensitive member profiles and personal details are restricted to registered and verified members within the app.\n'
          '• Masked Contact Details: Phone numbers and personal contact information are masked and only revealed to verified, subscribed members.\n'
          '• Blocking & Reporting: Members can instantly block or report suspicious, incomplete, or inappropriate profiles. Blocked users cannot view your profile or initiate any interaction.',
    },
    {
      'heading': '5. Financial & Payment Security',
      'body':
          'All premium membership subscription transactions (UPI, Net Banking, QR, or Card payments) are processed through secure, encrypted, RBI-authorized payment gateways. Vivahsambandh never stores your confidential banking passwords, UPI PINs, or card CVV numbers on its servers.',
    },
    {
      'heading': '6. Data Protection, Storage & Security Standards',
      'body':
          'We implement enterprise-grade security protocols including 256-bit SSL transport layer encryption, secure credential caching, and isolated cloud databases. Access to user data is strictly restricted to authorized administrative personnel on a verified need-to-know basis.',
    },
    {
      'heading': '7. Account Deletion & Data Retention Rights',
      'body':
          'In full compliance with Google Play Store data safety standards, you retain complete autonomy over your personal information:\n\n'
          '• You can permanently delete your account and associated profile directly in the app at any time by selecting "Delete Account" in the Side Drawer.\n'
          '• You may also submit a deletion request by emailing info@vivahsambandh.com.\n'
          '• Upon account deletion, your profile is immediately de-indexed from all matchmaking searches and your personal data is permanently scrubbed from our active production database.',
    },
    {
      'heading': '8. Grievance Redressal Officer & Contact Details',
      'body':
          'In accordance with the Information Technology Act, 2000 and the Information Technology (Intermediary Guidelines and Digital Media Ethics Code) Rules, 2021, the contact details of our Grievance Officer are:\n\n'
          '• Organization: Vivahsambandh\n'
          '• Address: Jayanagar, Bangalore - 560078, Karnataka, India\n'
          '• Official Email: info@vivahsambandh.com\n'
          '• Support Phone: +91 8310782820 / 080-48531999\n'
          '• Official Privacy Webpage: https://vivahsambandh.com/privacy',
    },
  ];

  static const List<Map<String, String>> _termsConditionsSections = [
    {
      'heading': '1. Acceptance of Terms',
      'body':
          'By downloading, installing, registering, or accessing the VivahSambandh mobile application or website (https://vivahsambandh.com/terms), you acknowledge that you have read, understood, and agreed to be legally bound by these Terms and Conditions. If you do not accept these terms in their entirety, you must discontinue using our services immediately.',
    },
    {
      'heading': '2. Legal Eligibility Criteria',
      'body':
          'To register on VivahSambandh, you must satisfy all of the following eligibility requirements:\n\n'
          '• Legal Marriageable Age: You must be at least 21 years of age for males and at least 18 years of age for females as prescribed under applicable Indian matrimonial laws.\n'
          '• Legal Marital Status: You must be legally single—either Never Married, legally Divorced with a decree granted by a court of competent jurisdiction, or Widowed.\n'
          '• Matrimonial Purpose: This service is exclusively intended for genuine matchmaking for marriage. Use of this platform for casual dating, friendships, commercial exploitation, or escort services is strictly forbidden.',
    },
    {
      'heading': '3. User Account, Verification & Authenticity',
      'body':
          '• Authenticity of Profile: You warrant that all information, photographs, marital declarations, educational qualifications, gotra, and family details provided by you are true, accurate, current, and authentic.\n'
          '• One Account Per User: Creating duplicate, misleading, fictitious, or proxy profiles without authorization is strictly prohibited.\n'
          '• Account Security: You are solely responsible for maintaining the confidentiality of your credentials and OTP verification codes. You agree to notify us immediately of any unauthorized account access.',
    },
    {
      'heading': '4. Code of Conduct & Prohibited Activities',
      'body':
          'Members agree to treat fellow prospective brides, grooms, and their families with courtesy and respect. The following activities will lead to immediate account termination and potential legal action:\n\n'
          '• Soliciting financial aid, loans, investments, gifts, or direct funds under any matrimonial pretext.\n'
          '• Uploading offensive, obscene, defamatory, sexually suggestive, or copyright-infringing media.\n'
          '• Harassment, stalking, abusive language, or persistent unsolicited communication after being blocked or declined.\n'
          '• Misrepresenting identity or uploading photographs of celebrities or third parties without written authorization.',
    },
    {
      'heading': '5. Membership Plans & Subscriptions',
      'body':
          '• Free & Premium Services: Basic browsing and profile creation are free. Premium subscriptions unlock access to candidate contact information, direct communication, and advanced preference filters.\n'
          '• Validity & Non-Transferability: Subscriptions are strictly non-transferable and valid for the specified duration from the date of activation.\n'
          '• No Refund Policy: Since digital matrimonial contact privileges are provisioned immediately upon confirmation, membership subscription fees are non-refundable and non-cancellable.',
    },
    {
      'heading': '6. Role of VivahSambandh & Matrimonial Disclaimer',
      'body':
          '• Intermediary Matchmaking Directory: VivahSambandh operates as an intermediary facilitator connecting interested individuals. We do not guarantee marriage, alliance finalization, or compatibility.\n'
          '• Due Diligence Mandate: While we verify mobile numbers and review profiles, users and their families are strongly urged to independently verify the background, employment, salary, character, marital history, and family standing of prospective candidates before finalizing any matrimonial commitment.',
    },
    {
      'heading': '7. Limitation of Liability',
      'body':
          'VivahSambandh, its directors, and employees shall not be liable for any direct, indirect, incidental, or consequential damages resulting from interactions, communications, promises, or matrimonial arrangements between members whether taking place on or off the platform.',
    },
    {
      'heading': '8. Account Termination & Moderation Rights',
      'body':
          'VivahSambandh reserves the absolute authority to suspend, hold, or permanently terminate any account that violates our terms, receives repeated member complaints, or fails safety audits. Members may delete their account at any time using the in-app "Delete Account" button.',
    },
    {
      'heading': '9. Governing Law & Dispute Jurisdiction',
      'body':
          'These Terms and Conditions shall be governed by and interpreted in accordance with the laws of the Republic of India. Any legal dispute, claim, or controversy arising out of or related to these terms shall be subject to the exclusive jurisdiction of the competent courts in Bangalore, Karnataka, India.',
    },
    {
      'heading': '10. Contact & Official Web Links',
      'body':
          'For inquiries or questions concerning these Terms and Conditions:\n\n'
          '• Email: info@vivahsambandh.com\n'
          '• Telephone: +91 8310782820 / 080-48531999\n'
          '• Registered Office: Jayanagar, Bangalore - 560078, Karnataka, India\n'
          '• Official Terms Webpage: https://vivahsambandh.com/terms',
    },
  ];
}
