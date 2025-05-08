import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/models/banner_model.dart';

class BannerSlider extends StatefulWidget {
  final List<BannerModel> banners;
  final double height;

  const BannerSlider({
    super.key,
    required this.banners,
    this.height = 180,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  // 자동 슬라이드를 위한 타이머
  late Timer _timer;
  
  @override
  void initState() {
    super.initState();
    if (widget.banners.length > 1) {
      _startAutoSlide();
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    if (widget.banners.length > 1) {
      _timer.cancel();
    }
    super.dispose();
  }
  
  void _startAutoSlide() {
    // 5초마다 자동 슬라이드
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentIndex < widget.banners.length - 1) {
        _pageController.animateToPage(
          _currentIndex + 1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return Column(
      children: [
        // 배너 슬라이더
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return GestureDetector(
                onTap: () => _handleBannerTap(banner),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // 배너 이미지
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: banner.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                          ),
                        ),
                        
                        // 텍스트 오버레이
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 1.0],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  banner.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (banner.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    banner.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // 인디케이터
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (index) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? AppTheme.primaryColor
                      : AppTheme.dividerColor,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  void _handleBannerTap(BannerModel banner) {
    switch (banner.linkType) {
      case 'notice':
        // 공지사항 상세 페이지로 이동
        Navigator.pushNamed(context, AppRoutes.notice);
        break;
      case 'qna':
        // QnA 상세 페이지로 이동
        Navigator.pushNamed(context, AppRoutes.qna);
        break;
      case 'share':
        // 정보공유 상세 페이지로 이동
        Navigator.pushNamed(context, AppRoutes.share);
        break;
      case 'company':
        // 제휴업체 상세 페이지로 이동
        Navigator.pushNamed(context, AppRoutes.companyBoard);
        break;
      case 'external':
        if (banner.externalUrl != null && banner.externalUrl!.isNotEmpty) {
          // 외부 링크 열기 로직 추가 필요
        }
        break;
      default:
        break;
    }
  }
} 