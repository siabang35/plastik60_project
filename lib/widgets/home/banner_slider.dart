import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _banners = [
    {
      'image': 'assets/images/banner1.jpg',
      'title': 'Special Offer',
      'subtitle': 'Get 20% off on all products',
    },
    {
      'image': 'assets/images/banner2.jpg',
      'title': 'New Arrivals',
      'subtitle': 'Check out our latest products',
    },
    {
      'image': 'assets/images/banner3.jpg',
      'title': 'Free Shipping',
      'subtitle': 'On orders over Rp 500.000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _banners.length,
          itemBuilder: (context, index, realIndex) {
            final banner = _banners[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(banner['image'], fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner['subtitle'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            height: 180,
            viewportFraction: 0.9,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              _banners.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == entry.key ? 10.0 : 8.0,
                  height: _currentIndex == entry.key ? 10.0 : 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentIndex == entry.key
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
