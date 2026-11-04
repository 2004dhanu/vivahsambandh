import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/user_model.dart';
import 'widgets/member_card.dart';
import '../notifications/notification_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final UserModel? user;

  const AdminDashboardScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.isRegistered<AdminController>()
        ? Get.find<AdminController>()
        : Get.put(AdminController(user: user));

    if (user != null && controller.currentUser.value != user) {
      controller.currentUser.value = user;
    }

    final isSuperAdmin = user?.isSuperAdmin ?? controller.isSuperAdmin;
    final tabCount = isSuperAdmin ? 6 : 4;

    return DefaultTabController(
      key: ValueKey('admin_portal_${isSuperAdmin ? "super" : "admin"}_${controller.currentUser.value?.id}'),
      length: tabCount,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          return Scaffold(
            backgroundColor: const Color(0xFFF6F8FA),
            appBar: _buildExecutiveAppBar(context, controller, isSuperAdmin),
            body: Column(
              children: [
                // Modern Pill TabBar
                _buildModernTabBar(controller, isSuperAdmin),

                // Content View for Tabs
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 0: Dashboard Overview (Executive Command Center)
                      _buildDashboardOverviewTab(context, controller, isSuperAdmin, tabController),

                      // Tab 1: Pending Approvals Queue
                      _buildPendingQueueTab(controller),

                      // Tab 2: Candidates Directory (Full with Gender & Status Multi-filters)
                      _buildCandidatesDirectoryTab(controller),

                      // Super Admin Exclusive Tabs:
                      if (isSuperAdmin) ...[
                        // Tab 3: Admin Staff Management
                        _buildAdminStaffTab(controller),

                        // Tab 4: Pending Admin Applications
                        _buildPendingAdminRequestsTab(controller),
                      ],

                      // Last Tab: Others (Hold / Married / Cancel)
                      _buildOthersTab(controller),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 1. Executive Top AppBar with Role Badge, Admin Profile & Actions
  PreferredSizeWidget _buildExecutiveAppBar(
    BuildContext context,
    AdminController controller,
    bool isSuperAdmin,
  ) {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A0D3C), // Deep Burgundy
              Color(0xFF880E4F), // Royal Maroon
              Color(0xFFAD1457), // Royal Magenta
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          // Admin Shield / Crown Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSuperAdmin
                    ? [const Color(0xFFFFD700), const Color(0xFFFFA000)]
                    : [const Color(0xFF80CBC4), const Color(0xFF00897B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isSuperAdmin ? Icons.workspace_premium_rounded : Icons.shield_rounded,
                color: isSuperAdmin ? const Color(0xFF4A2C00) : Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Portal Title & Role Tag
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        isSuperAdmin ? 'Super Admin Portal' : 'Admin Console',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSuperAdmin
                            ? const Color(0xFFFFD700)
                            : const Color(0xFF26A69A),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        isSuperAdmin ? 'SUPER ADMIN' : 'STAFF ADMIN',
                        style: TextStyle(
                          color: isSuperAdmin ? const Color(0xFF5D4037) : Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Obx(() {
                  final u = controller.currentUser.value;
                  final displayName = (u != null && u.name.isNotEmpty) ? u.name : 'vivahsambandh';
                  final mobile = (u != null && u.mobile.isNotEmpty) ? ' • ${u.mobile}' : '';
                  return Text(
                    '$displayName$mobile',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Notifications
        IconButton(
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
          onPressed: () => Get.to(() => NotificationScreen(user: user ?? controller.currentUser.value)),
        ),
        // Refresh
        IconButton(
          tooltip: 'Refresh Dashboard Data',
          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
          onPressed: () => controller.refreshAllData(),
        ),
        // Logout
        IconButton(
          tooltip: 'Sign Out',
          icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
          onPressed: () {
            Get.defaultDialog(
              title: 'Sign Out',
              titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              middleText: 'Are you sure you want to sign out of the management console?',
              textConfirm: 'Sign Out',
              textCancel: 'Cancel',
              confirmTextColor: Colors.white,
              buttonColor: const Color(0xFF880E4F),
              radius: 14,
              onConfirm: () {
                Get.back();
                controller.logout();
              },
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  /// 2. Modern Pill TabBar
  Widget _buildModernTabBar(AdminController controller, bool isSuperAdmin) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8EAF0), width: 1),
        ),
      ),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: const Color(0xFF880E4F),
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorColor: const Color(0xFF880E4F),
        indicatorWeight: 3.5,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: [
          // Tab 0: Overview Dashboard
          const Tab(
            child: Row(
              children: [
                Icon(Icons.dashboard_rounded, size: 16),
                SizedBox(width: 6),
                Text('Overview'),
              ],
            ),
          ),

          // Tab 1: Pending Approvals
          Obx(
            () => Tab(
              child: Row(
                children: [
                  const Icon(Icons.pending_actions_rounded, size: 16),
                  const SizedBox(width: 6),
                  const Text('Pending'),
                  if (controller.pendingMembersCount > 0) ...[
                    const SizedBox(width: 6),
                    _buildCountBadge(
                      count: controller.pendingMembersCount,
                      color: const Color(0xFFE65100),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Tab 2: Candidates Directory
          Obx(
            () => Tab(
              child: Row(
                children: [
                  const Icon(Icons.people_alt_rounded, size: 16),
                  const SizedBox(width: 6),
                  const Text('Candidates'),
                  if (controller.totalMembersCount > 0) ...[
                    const SizedBox(width: 6),
                    _buildCountBadge(
                      count: controller.totalMembersCount,
                      color: const Color(0xFF6A0D3C),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Super Admin Exclusive Tabs:
          if (isSuperAdmin) ...[
            // Tab 3: Admin Staff
            Obx(
              () => Tab(
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings_rounded, size: 16, color: Colors.teal),
                    const SizedBox(width: 6),
                    const Text('Admin Staff'),
                    if (controller.adminCount > 0) ...[
                      const SizedBox(width: 6),
                      _buildCountBadge(
                        count: controller.adminCount,
                        color: Colors.teal,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Tab 4: Pending Admin Applications
            Obx(
              () => Tab(
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded, size: 16, color: Colors.deepOrange),
                    const SizedBox(width: 6),
                    const Text('Admin Requests'),
                    if (controller.pendingAdminCount > 0) ...[
                      const SizedBox(width: 6),
                      _buildCountBadge(
                        count: controller.pendingAdminCount,
                        color: Colors.deepOrange,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          // Last Tab: Others (Hold / Married / Cancel)
          Obx(
            () => Tab(
              child: Row(
                children: [
                  const Icon(Icons.archive_outlined, size: 16),
                  const SizedBox(width: 6),
                  const Text('Archive / Others'),
                  if (controller.otherCount > 0) ...[
                    const SizedBox(width: 6),
                    _buildCountBadge(
                      count: controller.otherCount,
                      color: const Color(0xFF475569),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Tab 0: Executive Command Center Overview
  Widget _buildDashboardOverviewTab(
    BuildContext context,
    AdminController controller,
    bool isSuperAdmin,
    TabController tabController,
  ) {
    return RefreshIndicator(
      color: const Color(0xFF880E4F),
      onRefresh: () => controller.refreshAllData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Executive Hero Banner
            _buildExecutiveHeroBanner(controller, isSuperAdmin),
            const SizedBox(height: 16),

            // Section 1: KPI Summary Metric Cards Grid
            Row(
              children: [
                const Icon(Icons.analytics_rounded, size: 18, color: Color(0xFF880E4F)),
                const SizedBox(width: 6),
                const Text(
                  'Key Performance Metrics',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Obx(
                  () => Text(
                    '${controller.totalMembersCount} Total Profiles',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Metrics Grid (2 columns or responsive wrap)
            Obx(() {
              return Column(
                children: [
                  // Row 1: Pending Approvals & Approved Active
                  Row(
                    children: [
                      // Pending Approvals Card (High Alert)
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Pending Approvals',
                          count: controller.pendingMembersCount,
                          subtitle: controller.pendingMembersCount > 0
                              ? 'Action Required'
                              : 'Up to date',
                          icon: Icons.pending_actions_rounded,
                          gradient: const [Color(0xFFE65100), Color(0xFFFF9800)],
                          hasAlert: controller.pendingMembersCount > 0,
                          onTap: () => tabController.animateTo(1),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Approved Active Members Card
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Approved Active',
                          count: controller.approvedCount,
                          subtitle: 'Live Matrimony Profiles',
                          icon: Icons.verified_user_rounded,
                          gradient: const [Color(0xFF1B5E20), Color(0xFF43A047)],
                          onTap: () {
                            controller.selectedStatusFilter.value = 'Approved';
                            tabController.animateTo(2);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Row 2: Total Candidates & Success Stories (Married)
                  Row(
                    children: [
                      // Total Candidates
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Total Candidates',
                          count: controller.totalMembersCount,
                          subtitle: 'All Registered',
                          icon: Icons.people_alt_rounded,
                          gradient: const [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                          onTap: () {
                            controller.selectedGenderFilter.value = 'All';
                            controller.selectedStatusFilter.value = 'All';
                            tabController.animateTo(2);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Success Stories (Married)
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Matches / Married',
                          count: controller.marriedCount,
                          subtitle: 'Successful Matches',
                          icon: Icons.favorite_rounded,
                          gradient: const [Color(0xFF880E4F), Color(0xFFC2185B)],
                          onTap: () {
                            controller.selectedOtherFilter.value = 'Married';
                            tabController.animateTo(isSuperAdmin ? 5 : 3);
                          },
                        ),
                      ),
                    ],
                  ),

                  // Row 3 for Super Admin: Admin Staff & Pending Admin Requests
                  if (isSuperAdmin) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            title: 'Admin Staff',
                            count: controller.adminCount,
                            subtitle: 'Active Coordinators',
                            icon: Icons.admin_panel_settings_rounded,
                            gradient: const [Color(0xFF004D40), Color(0xFF00897B)],
                            onTap: () => tabController.animateTo(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricTile(
                            title: 'Admin Requests',
                            count: controller.pendingAdminCount,
                            subtitle: controller.pendingAdminCount > 0
                                ? 'Review Application'
                                : 'None Pending',
                            icon: Icons.hourglass_top_rounded,
                            gradient: const [Color(0xFFBF360C), Color(0xFFFF5722)],
                            hasAlert: controller.pendingAdminCount > 0,
                            onTap: () => tabController.animateTo(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: 20),

            // Section 2: Gender Demographics Card
            _buildGenderDemographicsCard(controller, tabController),
            const SizedBox(height: 20),

            // Section 3: Status Pipeline Distribution (Hold, Married, Cancel)
            _buildStatusPipelineCard(controller, isSuperAdmin, tabController),
            const SizedBox(height: 20),

            // Section 4: Urgent Action Pending Queue Preview
            _buildUrgentPendingSection(controller, tabController),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Executive Hero Welcome Banner
  Widget _buildExecutiveHeroBanner(AdminController controller, bool isSuperAdmin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSuperAdmin
              ? [const Color(0xFF2E0824), const Color(0xFF531238), const Color(0xFF880E4F)]
              : [const Color(0xFF1E293B), const Color(0xFF334155), const Color(0xFF475569)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuperAdmin ? Icons.auto_awesome_rounded : Icons.dashboard_customize_rounded,
                  color: isSuperAdmin ? const Color(0xFFFFD700) : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSuperAdmin
                          ? 'Executive Super Admin Dashboard'
                          : 'Matrimony Staff Admin Console',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'VivahSambandh Central Management',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFFFD700)),
                const SizedBox(width: 6),
                Expanded(
                  child: Obx(() {
                    final pending = controller.pendingMembersCount;
                    return Text(
                      pending > 0
                          ? '$pending candidate profiles waiting for approval. Review them to publish.'
                          : 'All candidate profiles are up to date and verified!',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Metric Tile Builder for Dashboard Grid
  Widget _buildMetricTile({
    required String title,
    required int count,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    bool hasAlert = false,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAlert ? const Color(0xFFFF9800) : const Color(0xFFE2E8F0),
          width: hasAlert ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasAlert
                ? const Color(0xFFFF9800).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: Colors.white, size: 18),
                    ),
                    if (hasAlert)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE0B2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACTION',
                          style: TextStyle(
                            color: Color(0xFFE65100),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: hasAlert ? const Color(0xFFE65100) : const Color(0xFF94A3B8),
                    fontWeight: hasAlert ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Gender Demographics Visual Breakdown Card
  Widget _buildGenderDemographicsCard(AdminController controller, TabController tabController) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Obx(() {
        final total = controller.totalMembersCount;
        final males = controller.maleCount;
        final females = controller.femaleCount;
        final malePercent = total > 0 ? (males / total) : 0.5;
        final femalePercent = total > 0 ? (females / total) : 0.5;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wc_rounded, size: 18, color: Color(0xFF880E4F)),
                const SizedBox(width: 6),
                const Text(
                  'Candidate Gender Demographics',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Text(
                  '$total candidates',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Two-tone Ratio Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    Expanded(
                      flex: (malePercent * 100).toInt().clamp(1, 100),
                      child: Container(color: const Color(0xFF1976D2)),
                    ),
                    Expanded(
                      flex: (femalePercent * 100).toInt().clamp(1, 100),
                      child: Container(color: const Color(0xFFD81B60)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Male / Female Clickable Filter Buttons
            Row(
              children: [
                // Grooms Button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      controller.selectedGenderFilter.value = 'Male';
                      tabController.animateTo(2);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF90CAF9)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.male_rounded, color: Color(0xFF1976D2), size: 18),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Grooms (Male)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                              Text(
                                '$males (${(malePercent * 100).toStringAsFixed(0)}%)',
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF1976D2)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Brides Button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      controller.selectedGenderFilter.value = 'Female';
                      tabController.animateTo(2);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF48FB1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.female_rounded, color: Color(0xFFD81B60), size: 18),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Brides (Female)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF880E4F),
                                ),
                              ),
                              Text(
                                '$females (${(femalePercent * 100).toStringAsFixed(0)}%)',
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFFD81B60)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  /// Status Pipeline Card (Hold, Married, Cancel counts)
  Widget _buildStatusPipelineCard(
    AdminController controller,
    bool isSuperAdmin,
    TabController tabController,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              const Icon(Icons.filter_list_rounded, size: 18, color: Color(0xFF880E4F)),
              const SizedBox(width: 6),
              const Text(
                'Candidate Status Pipeline',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            return Row(
              children: [
                // Hold
                Expanded(
                  child: _buildStatusMiniPill(
                    label: 'On Hold',
                    count: controller.holdCount,
                    color: const Color(0xFF1976D2),
                    bgColor: const Color(0xFFE3F2FD),
                    onTap: () {
                      controller.selectedOtherFilter.value = 'Hold';
                      tabController.animateTo(isSuperAdmin ? 5 : 3);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Married
                Expanded(
                  child: _buildStatusMiniPill(
                    label: 'Married',
                    count: controller.marriedCount,
                    color: const Color(0xFF7B1FA2),
                    bgColor: const Color(0xFFF3E5F5),
                    onTap: () {
                      controller.selectedOtherFilter.value = 'Married';
                      tabController.animateTo(isSuperAdmin ? 5 : 3);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Cancel
                Expanded(
                  child: _buildStatusMiniPill(
                    label: 'Canceled',
                    count: controller.cancelCount,
                    color: const Color(0xFFD32F2F),
                    bgColor: const Color(0xFFFFEBEE),
                    onTap: () {
                      controller.selectedOtherFilter.value = 'Cancel';
                      tabController.animateTo(isSuperAdmin ? 5 : 3);
                    },
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusMiniPill({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Urgent Action Pending Queue Section on Dashboard
  Widget _buildUrgentPendingSection(AdminController controller, TabController tabController) {
    return Obx(() {
      final pending = controller.pendingMembers;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on_rounded, size: 18, color: Color(0xFFE65100)),
                  const SizedBox(width: 6),
                  const Text(
                    'Urgent: Pending Approvals',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              if (pending.isNotEmpty)
                TextButton(
                  onPressed: () => tabController.animateTo(1),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All Queue',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFF880E4F)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          if (pending.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF43A047), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Profiles Pending Approval',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          'All new candidate registrations have been successfully reviewed.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            // Display up to the first 3 pending cards
            Column(
              children: pending.take(3).map((m) {
                return MemberCard(member: m, controller: controller);
              }).toList(),
            ),
        ],
      );
    });
  }

  /// 4. Tab 1: Pending Approvals Queue
  Widget _buildPendingQueueTab(AdminController controller) {
    return Column(
      children: [
        // Search & info banner for pending queue
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              _buildSearchBar(controller, 'Search pending candidates by name, mobile, city...'),
              const SizedBox(height: 6),
              Obx(() {
                final count = controller.filteredPendingMembers.length;
                return Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFE65100)),
                    const SizedBox(width: 4),
                    Text(
                      '$count candidates waiting for administrator approval',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFFE65100), fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),

        // Pending Member List
        Expanded(
          child: _buildMemberList(
            isLoading: controller.isLoadingPending,
            membersGetter: () => controller.filteredPendingMembers,
            onRefresh: () => controller.fetchPendingMembers(),
            emptyTitle: 'Queue Clean!',
            emptySubtitle: 'No candidate profiles currently waiting for approval.',
            emptyIcon: Icons.task_alt_rounded,
            controller: controller,
          ),
        ),
      ],
    );
  }

  /// 5. Tab 2: Candidates Directory with Multi-Filters
  Widget _buildCandidatesDirectoryTab(AdminController controller) {
    return Column(
      children: [
        // Search Bar & Filter Chips Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(controller, 'Search candidate name, mobile, gotra, ID...'),
              const SizedBox(height: 8),

              // Filter Chips: Gender (All, Grooms, Brides)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() {
                  final currentGender = controller.selectedGenderFilter.value;
                  final currentStatus = controller.selectedStatusFilter.value;

                  return Row(
                    children: [
                      // Gender Chips
                      _buildFilterChip(
                        label: 'All Genders',
                        isSelected: currentGender == 'All',
                        onTap: () => controller.selectedGenderFilter.value = 'All',
                        activeColor: const Color(0xFF880E4F),
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: '👨 Grooms (M)',
                        isSelected: currentGender == 'Male',
                        onTap: () => controller.selectedGenderFilter.value = 'Male',
                        activeColor: const Color(0xFF1976D2),
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: '👩 Brides (F)',
                        isSelected: currentGender == 'Female',
                        onTap: () => controller.selectedGenderFilter.value = 'Female',
                        activeColor: const Color(0xFFD81B60),
                      ),
                      const SizedBox(width: 10),
                      Container(width: 1, height: 20, color: const Color(0xFFCBD5E1)),
                      const SizedBox(width: 10),

                      // Status Chips
                      _buildFilterChip(
                        label: 'All Statuses',
                        isSelected: currentStatus == 'All',
                        onTap: () => controller.selectedStatusFilter.value = 'All',
                        activeColor: const Color(0xFF880E4F),
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: 'Approved',
                        isSelected: currentStatus == 'Approved',
                        onTap: () => controller.selectedStatusFilter.value = 'Approved',
                        activeColor: const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: 'Pending',
                        isSelected: currentStatus == 'Pending',
                        onTap: () => controller.selectedStatusFilter.value = 'Pending',
                        activeColor: const Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: 'Hold',
                        isSelected: currentStatus == 'Hold',
                        onTap: () => controller.selectedStatusFilter.value = 'Hold',
                        activeColor: const Color(0xFF2196F3),
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: 'Married',
                        isSelected: currentStatus == 'Married',
                        onTap: () => controller.selectedStatusFilter.value = 'Married',
                        activeColor: const Color(0xFF9C27B0),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 6),

              // Filter summary
              Obx(() {
                final count = controller.filteredCandidates.length;
                return Row(
                  children: [
                    Text(
                      'Showing $count candidates',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (controller.selectedGenderFilter.value != 'All' ||
                        controller.selectedStatusFilter.value != 'All' ||
                        controller.searchQuery.value.isNotEmpty)
                      InkWell(
                        onTap: () {
                          controller.selectedGenderFilter.value = 'All';
                          controller.selectedStatusFilter.value = 'All';
                          controller.searchController.clear();
                          controller.searchQuery.value = '';
                        },
                        child: const Text(
                          'Clear Filters',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF880E4F), fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),

        // Candidates List
        Expanded(
          child: _buildMemberList(
            isLoading: controller.isLoadingAll,
            membersGetter: () => controller.filteredCandidates,
            onRefresh: () => controller.fetchAllMembers(),
            emptyTitle: 'No Candidates Found',
            emptySubtitle: 'No profiles match the search query and selected filters.',
            emptyIcon: Icons.people_outline,
            controller: controller,
          ),
        ),
      ],
    );
  }

  /// 6. Tab 3 (Super Admin): Admin Staff Management
  Widget _buildAdminStaffTab(AdminController controller) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              _buildSearchBar(controller, 'Search administrator by name, mobile, city...'),
              const SizedBox(height: 6),
              Obx(() {
                final count = controller.filteredAdminMembers.length;
                return Row(
                  children: [
                    const Icon(Icons.shield_rounded, size: 14, color: Colors.teal),
                    const SizedBox(width: 4),
                    Text(
                      '$count active staff administrators managing candidate data',
                      style: const TextStyle(fontSize: 11.5, color: Colors.teal, fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        Expanded(
          child: _buildMemberList(
            isLoading: controller.isLoadingAdmin,
            membersGetter: () => controller.filteredAdminMembers,
            onRefresh: () => controller.fetchAdminMembers(),
            emptyTitle: 'No Admin Accounts Found',
            emptySubtitle: 'No active staff administrators are registered yet.',
            emptyIcon: Icons.shield_outlined,
            controller: controller,
          ),
        ),
      ],
    );
  }

  /// 7. Tab 4 (Super Admin): Pending Admin Member Applications
  Widget _buildPendingAdminRequestsTab(AdminController controller) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              _buildSearchBar(controller, 'Search pending admin requests...'),
              const SizedBox(height: 6),
              Obx(() {
                final count = controller.filteredPendingAdminMembers.length;
                return Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded, size: 14, color: Colors.deepOrange),
                    const SizedBox(width: 4),
                    Text(
                      '$count administrator applications awaiting Super Admin approval',
                      style: const TextStyle(fontSize: 11.5, color: Colors.deepOrange, fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        Expanded(
          child: _buildMemberList(
            isLoading: controller.isLoadingPendingAdmin,
            membersGetter: () => controller.filteredPendingAdminMembers,
            onRefresh: () => controller.fetchPendingAdminMembers(),
            emptyTitle: 'No Pending Admin Requests',
            emptySubtitle: 'All administrator applications have been reviewed.',
            emptyIcon: Icons.admin_panel_settings_outlined,
            controller: controller,
          ),
        ),
      ],
    );
  }

  /// 8. Last Tab: Others (Hold / Married / Cancel)
  Widget _buildOthersTab(AdminController controller) {
    const filterOptions = ['All', 'Hold', 'Married', 'Cancel'];

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(controller, 'Search archived candidates by name, mobile...'),
              const SizedBox(height: 8),
              Obx(
                () => Row(
                  children: filterOptions.map((filter) {
                    final isSelected = controller.selectedOtherFilter.value == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => controller.selectedOtherFilter.value = filter,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF880E4F) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF880E4F) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Text(
                            filter == 'All' ? 'All Archived' : filter,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        Expanded(
          child: _buildMemberList(
            isLoading: controller.isLoadingAll,
            membersGetter: () => controller.filteredOtherMembers,
            onRefresh: () => controller.fetchAllMembers(),
            emptyTitle: 'No Archived Profiles',
            emptySubtitle: 'No profiles match the selected status (Hold / Married / Cancel).',
            emptyIcon: Icons.filter_list_off_rounded,
            controller: controller,
          ),
        ),
      ],
    );
  }

  /// Helper: Search Bar
  Widget _buildSearchBar(AdminController controller, String hint) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: (val) => controller.searchQuery.value = val,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF880E4F)),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF64748B)),
                    onPressed: () {
                      controller.searchController.clear();
                      controller.searchQuery.value = '';
                    },
                  )
                : const SizedBox(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  /// Helper: Filter Chip
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  /// Badge count pill for tabs
  Widget _buildCountBadge({required int count, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Generic Member List Builder with RefreshIndicator & Modern Empty State
  Widget _buildMemberList({
    required RxBool isLoading,
    required List<dynamic> Function() membersGetter,
    required Future<void> Function() onRefresh,
    required String emptyTitle,
    required String emptySubtitle,
    required IconData emptyIcon,
    required AdminController controller,
  }) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF880E4F)),
        );
      }

      final list = membersGetter();
      if (list.isEmpty) {
        return RefreshIndicator(
          color: const Color(0xFF880E4F),
          onRefresh: onRefresh,
          child: ListView(
            children: [
              SizedBox(height: Get.height * 0.15),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF880E4F).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(emptyIcon, size: 48, color: const Color(0xFF880E4F)),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        emptyTitle,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emptySubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: const Color(0xFF880E4F),
        onRefresh: onRefresh,
        child: ListView.builder(
          itemCount: list.length,
          padding: const EdgeInsets.only(top: 6, bottom: 24),
          itemBuilder: (context, index) {
            return MemberCard(
              member: list[index],
              controller: controller,
            );
          },
        ),
      );
    });
  }
}
