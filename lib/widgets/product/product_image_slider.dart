import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductImageSlider extends StatefulWidget {
  final List<String> images;

  const ProductImageSlider({super.key, required this.images});

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          items:
              widget.images.map((imageUrl) {
                return GestureDetector(
                  onTap: () {
                    _showFullScreenImage(context, imageUrl);
                  },
                  child: Hero(
                    tag: 'product_image_$imageUrl',
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
          carouselController: _controller,
          options: CarouselOptions(
            aspectRatio: 1,
            viewportFraction: 1.0,
            enableInfiniteScroll: widget.images.length > 1,
            autoPlay: widget.images.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  widget.images.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(
                                _currentIndex == entry.key ? 0.9 : 0.4,
                              ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Hero(
                    tag: 'product_image_$imageUrl',
                    child: Image.network(imageUrl, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
