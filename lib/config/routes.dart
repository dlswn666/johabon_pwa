import 'package:flutter/material.dart';
import 'package:johabon_pwa/screens/admin/admin_home_screen.dart';
import 'package:johabon_pwa/screens/admin/alarm_manage_screen.dart';
import 'package:johabon_pwa/screens/admin/banner_manage_screen.dart';
import 'package:johabon_pwa/screens/admin/basic_info_screen.dart';
import 'package:johabon_pwa/screens/admin/company_manage_screen.dart';
import 'package:johabon_pwa/screens/admin/slide_manage_screen.dart';
import 'package:johabon_pwa/screens/admin/user_manage_screen.dart';
import 'package:johabon_pwa/screens/association/association_intro_screen.dart';
import 'package:johabon_pwa/screens/association/office_info_screen.dart';
import 'package:johabon_pwa/screens/association/organization_screen.dart';
import 'package:johabon_pwa/screens/auth/login_screen.dart';
import 'package:johabon_pwa/screens/auth/register_screen.dart';
import 'package:johabon_pwa/screens/community/community_home_screen.dart';
import 'package:johabon_pwa/screens/community/company_board_screen.dart';
import 'package:johabon_pwa/screens/community/gallery_screen.dart';
import 'package:johabon_pwa/screens/community/info_sharing_screen.dart';
import 'package:johabon_pwa/screens/community/notice_screen.dart';
import 'package:johabon_pwa/screens/community/qna_screen.dart';
import 'package:johabon_pwa/screens/community/share_screen.dart';
import 'package:johabon_pwa/screens/development/development_info_screen.dart';
import 'package:johabon_pwa/screens/development/development_process_screen.dart';
import 'package:johabon_pwa/screens/home/home_screen.dart';
import 'package:johabon_pwa/screens/splash_screen.dart';
import 'package:johabon_pwa/screens/user/profile_screen.dart';

class AppRoutes {
  // 라우트 이름 정의
  static const String splash = '/splash';
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  
  // 조합 소개
  static const String associationIntro = '/association/intro';
  static const String officeInfo = '/association/office';
  static const String organization = '/association/organization';
  static const String organizationChart = '/association/organization-chart';
  
  // 재개발 소개
  static const String developmentProcess = '/development/process';
  static const String developmentInfo = '/development/info';
  
  // 커뮤니티
  static const String notice = '/community/notice';
  static const String qna = '/community/qna';
  static const String share = '/community/share';
  static const String infoSharing = '/community/info-sharing';
  static const String companyBoard = '/community/company';
  static const String communityHome = '/community/home';
  static const String gallery = '/community/gallery';
  
  // 관리자
  static const String adminHome = '/admin/home';
  static const String userManage = '/admin/user';
  static const String adminUser = '/admin/users';
  static const String alarmManage = '/admin/alarm';
  static const String adminNotification = '/admin/notification';
  static const String slideManage = '/admin/slide';
  static const String adminSlide = '/admin/slides';
  static const String companyManage = '/admin/company';
  static const String adminCompany = '/admin/companies';
  static const String adminBanner = '/admin/banners';
  static const String adminBasicInfo = '/admin/basic-info';
  
  // 사용자
  static const String profile = '/user/profile';
  
  // 라우트 정의
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      landing: (context) => const LoginScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(),
      
      // 조합 소개
      associationIntro: (context) => const AssociationIntroScreen(),
      officeInfo: (context) => const OfficeInfoScreen(),
      organization: (context) => const OrganizationScreen(),
      organizationChart: (context) => const OrganizationScreen(),
      
      // 재개발 소개
      developmentProcess: (context) => const DevelopmentProcessScreen(),
      developmentInfo: (context) => const DevelopmentInfoScreen(),
      
      // 커뮤니티
      notice: (context) => const NoticeScreen(),
      qna: (context) => const QnaScreen(),
      share: (context) => const ShareScreen(),
      infoSharing: (context) => const InfoSharingScreen(),
      companyBoard: (context) => const CompanyBoardScreen(),
      communityHome: (context) => const CommunityHomeScreen(),
      gallery: (context) => const GalleryScreen(),
      
      // 관리자
      adminHome: (context) => const AdminHomeScreen(),
      userManage: (context) => const UserManageScreen(),
      adminUser: (context) => const UserManageScreen(),
      alarmManage: (context) => const AlarmManageScreen(),
      adminNotification: (context) => const AlarmManageScreen(),
      slideManage: (context) => const SlideManageScreen(),
      adminSlide: (context) => const SlideManageScreen(),
      companyManage: (context) => const CompanyManageScreen(),
      adminCompany: (context) => const CompanyManageScreen(),
      adminBanner: (context) => const BannerManageScreen(),
      adminBasicInfo: (context) => const BasicInfoScreen(),
      
      // 사용자
      profile: (context) => const ProfileScreen(),
    };
  }
  
  // 애니메이션 라우트 생성
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        if (settings.name == null) return const LoginScreen();
        final routes = getRoutes();
        final builder = routes[settings.name];
        if (builder == null) return const LoginScreen();
        return builder(context);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
} 