import 'package:flutter/material.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/models/category.dart';

class CategoryGrid extends StatelessWidget {
  final List<Category> categories;

  const CategoryGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: categories.length > 8 ? 8 : categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.productList,
              arguments: {
                'categoryId': category.id,
                'categoryName': category.name,
              },
            );
          },
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child:
                    category.image != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            category.image!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.category,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                          ),
                        )
                        : const Icon(
                          Icons.category,
                          size: 30,
                          color: Colors.grey,
                        ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
