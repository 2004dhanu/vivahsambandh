class ApiEndpoints {
  // Base API URL
  static const String baseUrl = 'https://vivahsambandh.com/crmapi/public/api/';

  // Public Endpoints
  static const String getEducation = 'getEducation';
  static const String getCommunity = 'getCommunity';
  static const String getGotra = 'getGotra'; // Append /{community_id}
  static const String getProfession = 'getProfession';
  static const String createUserRegister = 'create-user-register';

  // Auth & Account Endpoints
  static const String appCheckMobile = 'app-check-mobile';
  static const String appLogin = 'app-login';
  static const String appLogout = 'app-logout';
  static const String appDeleteProfile = 'app-delete-profile';
  static const String appFetchVersion = 'app-fetch-version';

  // Member Management Endpoints
  static const String member = 'member';
  static const String getPendingMember = 'getPendingMember';
  static const String getAdminMember = 'getAdminMember';
  static const String getPendingAdminMember = 'getPendingAdminMember';

  // Candidate / User Interactions
  static const String wishlist = 'wishlist';
  static const String shortlist = 'wishlist'; // Route points to wishlist API
  static const String feedback = 'feedback';
  static const String blockProfile = 'blockProfile';

  // Notifications
  static const String notification = 'notification';

  // Dynamic parameterized URLs
  static String memberById(int id) => 'member/$id';
  static String updateMemberStatus(int id) => 'members/$id/status';
  static String updateMemberCity(int id) => 'members/$id/city';
  static String updateAdminMember(int id) => 'admin-member/$id';
  static String wishlistById(int id) => 'wishlist/$id';
  static String shortlistById(int id) => 'wishlist/$id';
  static String feedbackById(int id) => 'feedback/$id';
  static String blockProfileById(int id) => 'blockProfile/$id';
  static String notificationById(int id) => 'notification/$id';
  static String removeDeviceId(int id) => 'removeDeviceId/$id';

  // Company Details
  static const String getCompany = 'getCompany';

  // Payment Endpoints
  static const String getPaymentHistory = 'getPaymentHistory';
  static const String createUserPayment = 'create-user-payment';
}
