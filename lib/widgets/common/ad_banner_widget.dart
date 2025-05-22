import 'package:flutter/material.dart';

class AdBannerWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final Color backgroundColor;
  final String title;
  final String? description;
  final String? imageUrl;
  final VoidCallback? onTap;
  final double aspectRatio; // 이미지 비율 (가로:세로)

  const AdBannerWidget({
    super.key,
    this.width,
    this.height,
    this.backgroundColor = const Color(0xFF508AE7), // Figma 디자인에서 가져온 색상
    this.title = '광고 배너',
    this.description,
    this.imageUrl,
    this.onTap,
    this.aspectRatio = 16 / 9, // 기본 비율 16:9
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: imageUrl != null
          ? _buildWithImage() 
          : _buildWithoutImage(),
      ),
    );
  }
  
  Widget _buildWithImage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 이미지 영역
        Flexible(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              imageUrl!,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
        // 텍스트 영역
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Wanted Sans',
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildWithoutImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Wanted Sans',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 복수의 광고 배너를 표시하는 위젯
class AdBannersColumn extends StatelessWidget {
  final List<AdBannerWidget> banners;
  final double spacing;

  const AdBannersColumn({
    super.key, 
    required this.banners,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(banners.length * 2 - 1, (index) {
        if (index.isEven) {
          return banners[index ~/ 2];
        } else {
          return SizedBox(height: spacing);
        }
      }),
    );
  }
} 