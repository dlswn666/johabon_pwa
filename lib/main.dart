import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // URL에서 # 기호를 제거하기 위한 설정
  setPathUrlStrategy();

  // 환경 변수 로드
  try {
    await dotenv.load(fileName: ".env");
    print("[Main] 환경 변수 로드 완료");
  } catch (e) {
    print("[Main] 환경 변수 로드 실패: $e");
    // 개발 환경에서 .env 파일이 없을 경우 기본값 사용
  }

  // Supabase 초기화 (환경 변수 사용)
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://xschknzenjbtxddkxrnq.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzY2hrbnplbmpidHhkZGt4cm5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDczNzgzNDgsImV4cCI6MjA2Mjk1NDM0OH0.EASwXT9GTV6kpqAZIkY0WUxGnTJ3BBHF3m0GWmdSwqQ';
  
  // 임시 해결책: Service Role Key 사용 (개발용)
  // 주의: 프로덕션에서는 방법 1 (RLS 정책 생성)을 사용해야 합니다
  final supabaseServiceKey = dotenv.env['SUPABASE_SERVICE_KEY'] ?? supabaseAnonKey;
  
  // --- DEBUGGING CODE ---
  if (dotenv.env['SUPABASE_SERVICE_KEY'] == null) {
    print("🔴 [DEBUG] SUPABASE_SERVICE_KEY 로드 실패! Anon Key를 사용합니다.");
  } else {
    print("🟢 [DEBUG] SUPABASE_SERVICE_KEY 로드 성공!");
  }
  // --- END DEBUGGING CODE ---
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey, // 올바른 Anon Key 사용으로 수정
  );
  print("[Main] Supabase 초기화 완료");
  
  // 전체 화면 모드 설정
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [],
  );
  
  // 상태바 색상 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  
  // URL에서 슬러그 추출
  final uri = Uri.base;
  String? currentSlug;
  String initialRouteForApp = AppRoutes.notFound; // 기본 경로는 404 - 슬러그 지정되지 않음
  
  print("[Main] Current URI: $uri");
  print("[Main] URI Path: ${uri.path}");
  print("[Main] URI PathSegments: ${uri.pathSegments}");
  
  if (uri.pathSegments.isNotEmpty && uri.pathSegments.first.isNotEmpty) {
    final firstSegment = uri.pathSegments.first;
    
    // 'admin', 'assets' 등 실제 슬러그가 아닌 경로 세그먼트 제외
    if (firstSegment != 'admin' &&
        firstSegment != 'assets' &&
        !firstSegment.startsWith('flutter_service_worker.js') &&
        !firstSegment.startsWith('main.dart.js') &&
        firstSegment != 'splash' &&
        firstSegment != '404' &&
        firstSegment != 'login' &&  // 로그인 직접 접근
        firstSegment != 'register') { // 회원가입 직접 접근
      currentSlug = firstSegment;
      // 전체 경로를 초기 라우트로 설정 (새로고침 시 현재 페이지 유지)
      initialRouteForApp = uri.path.isEmpty || uri.path == '/' ? '/$currentSlug' : uri.path;
      print("[Main] Detected slug: '$currentSlug', Initial route set to: '$initialRouteForApp'");
    } else if (firstSegment == 'login' || firstSegment == 'register') {
      // 로그인/회원가입 직접 접근 시 404 처리 (슬러그 필요)
      initialRouteForApp = AppRoutes.notFound;
      print("[Main] Direct login/register access without slug, redirecting to 404: '$initialRouteForApp'");
    } else {
      // admin, assets, splash, 404 등의 특수 경로로 직접 접근한 경우
      initialRouteForApp = uri.path;
      print("[Main] Detected special path: '$initialRouteForApp'");
    }
  } else {
    // 경로가 없는 경우 404 페이지로 이동 (슬러그 필요)
    print("[Main] No path segments, redirecting to 404: '$initialRouteForApp'");
  }
  
  // AuthProvider와 UnionProvider 초기화
  print("[Main] Providers 초기화 시작");
  final authProvider = AuthProvider();
  final unionProvider = UnionProvider();
  
  // AuthProvider 초기화 완료 대기
  while (!authProvider.isInitialized) {
    await Future.delayed(const Duration(milliseconds: 10));
  }
  print("[Main] AuthProvider 초기화 완료");
  
  if (currentSlug != null) {
    print("[Main] Fetching union for slug: '$currentSlug'");
    unionProvider.fetchAndSetUnion(currentSlug);
  } else {
    print("[Main] No slug detected OR special path, not fetching union");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: unionProvider),
      ],
      child: MyApp(initialRoute: initialRouteForApp),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    print("[MyApp build] initialRoute: '$initialRoute'");
    return UserActivityWidget(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // AuthProvider 초기화 완료 대기
          if (!authProvider.isInitialized) {
            print('[MyApp] AuthProvider 초기화 대기 중...');
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('앱 초기화 중...')
                    ],
                  ),
                ),
              ),
            );
          }
          
          print('[MyApp] AuthProvider 초기화 완료 - 로그인: ${authProvider.isLoggedIn}, 사용자: ${authProvider.currentUser?.name}');
          
          return MaterialApp(
            title: '재개발/재건축',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: initialRoute,
            routes: AppRoutes.getRoutes(), // 기본 경로들 추가
            onGenerateRoute: (settings) {
              print("[MyApp onGenerateRoute] called with settings name: '${settings.name}', arguments: ${settings.arguments}");
              return AppRoutes.generateRoute(settings, context);
            },
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko', 'KR'),
              Locale('en', 'US'),
            ],
            locale: const Locale('ko', 'KR'),
          );
        },
      ),
    );
  }
}

// 사용자 활동 감지 위젯
class UserActivityDetector extends StatefulWidget {
  final Widget child;
  
  const UserActivityDetector({super.key, required this.child});

  @override
  State<UserActivityDetector> createState() => _UserActivityDetectorState();
}

class _UserActivityDetectorState extends State<UserActivityDetector> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onUserActivity(context),
      onPanDown: (_) => _onUserActivity(context),
      onScaleStart: (_) => _onUserActivity(context),
      child: Listener(
        onPointerDown: (_) => _onUserActivity(context),
        onPointerMove: (_) => _onUserActivity(context),
        onPointerUp: (_) => _onUserActivity(context),
        child: widget.child,
      ),
    );
  }
  
  void _onUserActivity(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      authProvider.refreshSession();
    }
  }
}

// UserActivityWidget으로 앱 전체를 감싸서 사용자 활동 감지
class UserActivityWidget extends StatefulWidget {
  final Widget child;
  
  const UserActivityWidget({super.key, required this.child});

  @override
  State<UserActivityWidget> createState() => _UserActivityWidgetState();
}

class _UserActivityWidgetState extends State<UserActivityWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onUserActivity(context),
      onPanDown: (_) => _onUserActivity(context),
      onScaleStart: (_) => _onUserActivity(context),
      child: Listener(
        onPointerDown: (_) => _onUserActivity(context),
        onPointerMove: (_) => _onUserActivity(context),
        onPointerUp: (_) => _onUserActivity(context),
        child: widget.child,
      ),
    );
  }
  
  void _onUserActivity(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      authProvider.refreshSession();
    }
  }
}
