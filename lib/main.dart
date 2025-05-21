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

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // URL에서 # 기호를 제거하기 위한 설정
  setPathUrlStrategy();

  await Supabase.initialize(
    url: 'https://xschknzenjbtxddkxrnq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzY2hrbnplbmpidHhkZGt4cm5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDczNzgzNDgsImV4cCI6MjA2Mjk1NDM0OH0.EASwXT9GTV6kpqAZIkY0WUxGnTJ3BBHF3m0GWmdSwqQ',
  );
  
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
      initialRouteForApp = '/$currentSlug'; 
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
  
  // UnionProvider 초기화
  final unionProvider = UnionProvider();
  if (currentSlug != null) {
    print("[Main] Fetching union for slug: '$currentSlug'");
    unionProvider.fetchAndSetUnion(currentSlug);
  } else {
    print("[Main] No slug detected OR special path, not fetching union");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
    );
  }
}
