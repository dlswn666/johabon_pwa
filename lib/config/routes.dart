import 'package:flutter/material.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:johabon_pwa/screens/common/not_found_screen.dart';
import 'package:johabon_pwa/screens/splash_screen.dart';
import 'package:provider/provider.dart';
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
import 'package:johabon_pwa/screens/community/notice_list_screen.dart';
import 'package:johabon_pwa/screens/community/notice_write_screen.dart';
import 'package:johabon_pwa/screens/community/qna_screen.dart';
import 'package:johabon_pwa/screens/community/share_screen.dart';
import 'package:johabon_pwa/screens/development/development_info_screen.dart';
import 'package:johabon_pwa/screens/development/development_process_screen.dart';
import 'package:johabon_pwa/screens/home/home_screen.dart';
import 'package:johabon_pwa/screens/user/profile_screen.dart';

class AppRoutes {
  // 고정 경로는 앱 내부에서만 사용하거나, 특별한 경우에만 직접 접근 (대부분 슬러그 기반)
  static const String splash = '/splash'; // 앱 초기화 등 내부적 사용
  static const String notFound = '/404';   // 잘못된 경로 시 내부적으로 사용
  
  // 슬러그 하위에 사용될 경로들 (슬래시 없이, 실제 경로는 /:slug/home 형태)
  static const String home = 'home';
  static const String login = 'login'; // /:slug/login
  static const String register = 'register'; // /:slug/register
  static const String associationIntro = 'association/intro';
  static const String officeInfo = 'association/office';
  static const String organization = 'association/organization';
  static const String organizationChart = 'association/organization-chart'; // 사용된다면 이것도 추가
  static const String developmentProcess = 'development/process';
  static const String developmentInfo = 'development/info';
  static const String notice = 'community/notice';
  static const String noticeWrite = 'community/notice/write';
  static const String qna = 'community/qna';
  static const String share = 'community/share';
  static const String infoSharing = 'community/info-sharing';
  static const String companyBoard = 'community/company';
  static const String communityHome = 'community/home';
  static const String gallery = 'community/gallery';
  static const String profile = 'user/profile';

  // Admin 경로 (슬래시 없이, 'admin/' 접두어는 generateRoute에서 처리)
  static const String adminHome = 'home'; // admin/home
  static const String userManage = 'user'; // admin/user
  static const String adminUser = 'users'; // admin/users (userManage와 동일 화면이라면 하나로 통일)
  static const String alarmManage = 'alarm'; // admin/alarm
  static const String adminNotification = 'notification'; // admin/notification (alarmManage와 동일 화면이라면 하나로 통일)
  static const String slideManage = 'slide'; // admin/slide
  static const String adminSlide = 'slides'; // admin/slides (slideManage와 동일 화면이라면 하나로 통일)
  static const String companyManage = 'company'; // admin/company
  static const String adminCompany = 'companies'; // admin/companies (companyManage와 동일 화면이라면 하나로 통일)
  static const String adminBanner = 'banners'; // admin/banners
  static const String adminBasicInfo = 'basic-info'; // admin/basic-info
  
  // 슬러그가 포함된 전체 경로 생성 메서드
  static String getFullRoute(String slug, String path) {
    if (path.isEmpty) {
      return '/$slug';
    }
    return '/$slug/$path';
  }
  
  // 메뉴에서 사용할 슬러그 기반 경로들
  static Map<String, String> getSlugRoutes(String slug) {
    return {
      'home': getFullRoute(slug, home),
      'login': getFullRoute(slug, login),
      'register': getFullRoute(slug, register),
      'associationIntro': getFullRoute(slug, associationIntro),
      'officeInfo': getFullRoute(slug, officeInfo),
      'organization': getFullRoute(slug, organization),
      'developmentProcess': getFullRoute(slug, developmentProcess),
      'developmentInfo': getFullRoute(slug, developmentInfo),
      'notice': getFullRoute(slug, notice),
      'noticeWrite': getFullRoute(slug, noticeWrite),
      'qna': getFullRoute(slug, qna),
      'share': getFullRoute(slug, share),
      'infoSharing': getFullRoute(slug, infoSharing),
      'companyBoard': getFullRoute(slug, companyBoard),
      'communityHome': getFullRoute(slug, communityHome),
      'gallery': getFullRoute(slug, gallery),
      'profile': getFullRoute(slug, profile),
    };
  }

  // getRoutes는 이제 splash, notFound 외에는 거의 사용되지 않음
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      notFound: (context) => const NotFoundScreen(),
    };
  }
  
  static PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
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

  static Route<dynamic>? generateRoute(RouteSettings settings, BuildContext context) {
    // 라우트 이름이 null이면 404로 처리
    if (settings.name == null) {
      print("[Routes] Route name is null, navigating to 404");
      return _buildPageRoute(const NotFoundScreen(), RouteSettings(name: AppRoutes.notFound));
    }
    
    // Provider 인스턴스 획득
    final unionProvider = Provider.of<UnionProvider>(context, listen: false);
    final currentSlug = unionProvider.currentUnion?.homepage;
    
    // 모든 라우트 이름이 '/'로 시작하는지 확인
    final routeName = settings.name!.startsWith('/') ? settings.name! : '/${settings.name}';
    
    final uri = Uri.parse(routeName);
    List<String> pathSegments = List.from(uri.pathSegments);

    print("[Routes] generateRoute called with settings.name: '${settings.name}'");
    print("[Routes] Normalized route name: '$routeName'");
    print("[Routes] URI parsed: $uri, pathSegments: $pathSegments");
    print("[Routes] Current slug from provider: $currentSlug");

    // 중요: 특수한 경우 처리 - community/notice 형태의 경로가 직접 입력될 경우
    // 이 경우 pathSegments 길이가 2 이상이고 첫 세그먼트가 'community', 'association' 등인 경우
    if (pathSegments.length >= 2 && 
        (pathSegments[0] == 'community' || 
         pathSegments[0] == 'association' || 
         pathSegments[0] == 'development' || 
         pathSegments[0] == 'user')) {
      
      // 현재 유효한 슬러그가 있으면 해당 슬러그로 리다이렉트
      if (currentSlug != null) {
        print("[Routes] Direct path detected without slug. Redirecting using current slug: $currentSlug");
        String actualPath = pathSegments.join('/');
        
        // 슬러그와 경로를 조합한 전체 경로
        String redirectPath = getFullRoute(currentSlug, actualPath);
        print("[Routes] Redirecting to: $redirectPath");
        
        // 원래 경로에 해당하는 화면 결정
        Widget pageContent = const NotFoundScreen();
        
        switch (actualPath) {
          case AppRoutes.associationIntro:
            pageContent = const AssociationIntroScreen(); break;
          case AppRoutes.officeInfo:
            pageContent = const OfficeInfoScreen(); break;
          case AppRoutes.organization:
          case AppRoutes.organizationChart:
            pageContent = const OrganizationScreen(); break;
          case AppRoutes.developmentProcess:
            pageContent = const DevelopmentProcessScreen(); break;
          case AppRoutes.developmentInfo:
            pageContent = const DevelopmentInfoScreen(); break;
          case AppRoutes.notice:
            pageContent = const NoticeListScreen(); break;
          case AppRoutes.noticeWrite:
            pageContent = const NoticeWriteScreen(); break;
          case AppRoutes.qna:
            pageContent = const QnaScreen(); break;
          case AppRoutes.share:
            pageContent = const ShareScreen(); break;
          case AppRoutes.infoSharing:
            pageContent = const InfoSharingScreen(); break;
          case AppRoutes.companyBoard:
            pageContent = const CompanyBoardScreen(); break;
          case AppRoutes.communityHome:
            pageContent = const CommunityHomeScreen(); break;
          case AppRoutes.gallery:
            pageContent = const GalleryScreen(); break;
          case AppRoutes.profile:
            pageContent = const ProfileScreen(); break;
          default:
            print("[Routes] Unhandled direct path: $actualPath, navigating to 404");
            return _buildPageRoute(const NotFoundScreen(), 
                RouteSettings(name: AppRoutes.notFound, arguments: settings.arguments));
        }
        
        return _buildPageRoute(pageContent, 
            RouteSettings(name: redirectPath, arguments: settings.arguments));
      } else {
        // 유효한 슬러그가 없고 로딩 중이 아니면 메인 페이지로 이동 또는 로그인 페이지로 리다이렉트 고려
        print("[Routes] Cannot redirect without valid slug. Showing 404 page.");
        return _buildPageRoute(const NotFoundScreen(), 
            RouteSettings(name: AppRoutes.notFound, arguments: settings.arguments));
      }
    }
    
    // 루트 경로 (/) 접근 시 무조건 404 처리
    if (routeName == '/') {
      print("[Routes] Root path access (/) is not allowed, navigating to 404.");
      return _buildPageRoute(const NotFoundScreen(), RouteSettings(name: AppRoutes.notFound, arguments: settings.arguments));
    }

    // admin, assets 등 특수 경로 우선 처리
    if (pathSegments.isNotEmpty) {
      if (pathSegments.first == 'admin') {
        // 관리자 경로 처리 로직 (기존과 유사하게 유지)
        pathSegments.removeAt(0);
        String adminPath = pathSegments.join('/');
        String finalAdminRouteName = '/admin/$adminPath';
        Widget adminPageContent = const NotFoundScreen();

        switch (adminPath) {
          case AppRoutes.adminHome:
            adminPageContent = const AdminHomeScreen(); break;
          case AppRoutes.userManage:
          case 'users': // AppRoutes.adminUser 대신 직접 문자열 사용 가능성 고려
            adminPageContent = const UserManageScreen(); break;
          case AppRoutes.alarmManage:
          case 'notification': // AppRoutes.adminNotification
            adminPageContent = const AlarmManageScreen(); break;
          case AppRoutes.slideManage:
          case 'slides': // AppRoutes.adminSlide
            adminPageContent = const SlideManageScreen(); break;
          case AppRoutes.companyManage:
          case 'companies': // AppRoutes.adminCompany
            adminPageContent = const CompanyManageScreen(); break;
          case AppRoutes.adminBanner:
            adminPageContent = const BannerManageScreen(); break;
          case AppRoutes.adminBasicInfo:
            adminPageContent = const BasicInfoScreen(); break;
          default:
            print("[Routes] Unhandled admin path: $adminPath, navigating to 404");
            finalAdminRouteName = AppRoutes.notFound;
        }
        return _buildPageRoute(adminPageContent, RouteSettings(name: finalAdminRouteName, arguments: settings.arguments));
      }
      // assets, flutter_service_worker.js 등은 Flutter 엔진이 처리하거나 별도 처리 필요시 여기에 추가
      if (pathSegments.first == 'assets' || 
          pathSegments.first.startsWith('flutter_service_worker.js') || 
          pathSegments.first.startsWith('main.dart.js')) {
        // 이러한 경로는 Flutter의 기본 핸들러로 넘어가도록 null 반환 (또는 특정 처리)
        print("[Routes] Flutter asset path detected, delegating to default handlers");
        return null; 
      }
      if (pathSegments.first == 'splash') {
         print("[Routes] Splash screen route detected");
         return _buildPageRoute(const SplashScreen(), RouteSettings(name: AppRoutes.splash, arguments: settings.arguments));
      }
      if (pathSegments.first == '404') {
         print("[Routes] 404 route explicitly requested");
         return _buildPageRoute(const NotFoundScreen(), RouteSettings(name: AppRoutes.notFound, arguments: settings.arguments));
      }
      
      // 'login', 'register' 등이 첫 번째 세그먼트로 오면 404 처리 (슬러그 없이 직접 접근 금지)
      if ((pathSegments.first == 'login' || pathSegments.first == 'register') && pathSegments.length == 1) {
        print("[Routes] Direct access to ${pathSegments.first} without slug is not allowed");
        
        // 만약 유효한 조합 정보가 이미 있다면 해당 슬러그로 리다이렉트
        if (unionProvider.currentUnion != null) {
          final slug = unionProvider.currentUnion!.homepage;
          print("[Routes] Redirecting to '$slug/${pathSegments.first}' as valid union exists");
          
          // 리다이렉트 처리
          if (pathSegments.first == 'login') {
            return _buildPageRoute(const LoginScreen(), 
                RouteSettings(name: '/$slug/${AppRoutes.login}', arguments: settings.arguments));
          } else { // register
            return _buildPageRoute(const RegisterScreen(), 
                RouteSettings(name: '/$slug/${AppRoutes.register}', arguments: settings.arguments));
          }
        }
        
        // 유효한 조합 정보가 없다면 404로 처리
        return _buildPageRoute(const NotFoundScreen(), RouteSettings(name: AppRoutes.notFound, arguments: settings.arguments));
      }
    }

    // 위에서 처리되지 않은 모든 경로는 slug로 시작해야 함
    if (pathSegments.isEmpty) {
      // pathSegments가 비었다는 것은 settings.name이 '/' 이거나, 특수 경로 처리 후 비었음을 의미.
      // '/'는 이미 위에서 404 처리되었으므로, 이 경우는 거의 발생하지 않거나 잘못된 경로.
      print("[Routes] Empty path segments after initial checks, navigating to 404.");
      return _buildPageRoute(const NotFoundScreen(), RouteSettings(name: AppRoutes.notFound, arguments: settings.arguments));
    }

    // 첫 번째 세그먼트를 slug로 간주
    String slug = pathSegments.first;
    pathSegments.removeAt(0);
    // slug 다음 경로가 없으면 home으로 간주 (예: /mia_solsam -> /mia_solsam/home)
    String actualPath = pathSegments.isNotEmpty ? pathSegments.join('/') : home;
    
    print("[Routes] Processing as slug route - slug: '$slug', actualPath: '$actualPath'");
    print("[Routes] UnionProvider state - isLoading: ${unionProvider.isLoading}, " +
          "currentUnion: ${unionProvider.currentUnion?.homepage}, " +
          "error: ${unionProvider.error}");

    // 중요: 슬러그 라우팅에 도달했지만 UnionProvider가 초기화되지 않았다면 강제로 초기화
    if (unionProvider.currentUnion == null && !unionProvider.isLoading) {
      print("[Routes] Union not initialized, initiating fetch for slug: $slug");
      // fetchAndSetUnion는 비동기 함수지만, 
      // 여기서는 실제 로딩 완료를 기다리진 않고 로딩 상태로 전환시키는 목적
      unionProvider.fetchAndSetUnion(slug);
      // 로딩 화면으로 임시 전환
      return _buildPageRoute(const SplashScreen(), settings);
    }

    // UnionProvider 로딩 및 오류 처리
    if (unionProvider.isLoading) {
      print("[Routes] UnionProvider is loading, showing splash screen");
      return _buildPageRoute(const SplashScreen(), settings); 
    }
    
    if (unionProvider.currentUnion == null) {
      print("[Routes] Union not found after loading (null), showing 404");
      // 조합 정보가 없으면 404 페이지로 이동
      return _buildPageRoute(const NotFoundScreen(), RouteSettings(name: AppRoutes.notFound, arguments: settings.arguments));
    }
    
    if (unionProvider.currentUnion!.homepage != slug) {
      print("[Routes] Slug mismatch - requested: '$slug', current: '${unionProvider.currentUnion?.homepage}'");
      // 현재 있는 조합과 요청된 슬러그가 다르면 새 슬러그로 로딩 시도
      unionProvider.fetchAndSetUnion(slug);
      return _buildPageRoute(const SplashScreen(), settings);
    }
    
    // 여기까지 왔다면 unionProvider.currentUnion이 있고, 요청된 slug와 일치함
    print("[Routes] Valid union found for slug '$slug', routing to '$actualPath'");

    Widget pageContent = const NotFoundScreen();
    String finalRouteName = '/$slug/$actualPath';
    if (actualPath == home) finalRouteName = '/$slug'; // /slug/home 은 /slug 로 표시

    switch (actualPath) {
      case AppRoutes.home: // 'home'
        pageContent = const HomeScreen(); break;
      case AppRoutes.login: // 'login' (/:slug/login)
        pageContent = const LoginScreen(); break;
      case AppRoutes.register: // 'register' (/:slug/register)
        pageContent = const RegisterScreen(); break;
      case AppRoutes.associationIntro:
        pageContent = const AssociationIntroScreen(); break;
      case AppRoutes.officeInfo:
        pageContent = const OfficeInfoScreen(); break;
      case AppRoutes.organization:
      case AppRoutes.organizationChart:
        pageContent = const OrganizationScreen(); break;
      case AppRoutes.developmentProcess:
        pageContent = const DevelopmentProcessScreen(); break;
      case AppRoutes.developmentInfo:
        pageContent = const DevelopmentInfoScreen(); break;
      case AppRoutes.notice:
        pageContent = const NoticeListScreen(); break;
      case AppRoutes.noticeWrite:
        pageContent = const NoticeWriteScreen(); break;
      case AppRoutes.qna:
        pageContent = const QnaScreen(); break;
      case AppRoutes.share:
        pageContent = const ShareScreen(); break;
      case AppRoutes.infoSharing:
        pageContent = const InfoSharingScreen(); break;
      case AppRoutes.companyBoard:
        pageContent = const CompanyBoardScreen(); break;
      case AppRoutes.communityHome:
        pageContent = const CommunityHomeScreen(); break;
      case AppRoutes.gallery:
        pageContent = const GalleryScreen(); break;
      case AppRoutes.profile:
        pageContent = const ProfileScreen(); break;
      default:
        print("[Routes] Unhandled path '$actualPath' for slug '$slug', navigating to 404.");
        finalRouteName = AppRoutes.notFound;
        // pageContent는 이미 NotFoundScreen으로 초기화되어 있음
    }
    
    print("[Routes] Final route determined: $finalRouteName");
    return _buildPageRoute(pageContent, RouteSettings(name: finalRouteName, arguments: settings.arguments));
  }
} 