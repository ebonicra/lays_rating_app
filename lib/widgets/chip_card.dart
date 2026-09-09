import 'package:flutter/material.dart';
import 'package:lays_rating/models/chip.dart';
import 'package:lays_rating/pages/chips/chip_details_page.dart';

import '../services/auth_service.dart';

class ChipCard extends StatelessWidget {
  final LaysChip chip;
  final VoidCallback? onReturn;

  const ChipCard({
    super.key,
    required this.chip,
    this.onReturn,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChipDetailsPage(
                chipId: chip.id,
              ),
            ),
          );
          onReturn?.call();
        },

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  '${AuthService.baseUrl}/chips/images/${chip.imagePath}',
                  width: 100,
                  height: 130,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: 100,
                      height: 130,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 130,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: SizedBox(
                  height: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chip.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        chip.category.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            chip.available
                                ? Icons.shopping_bag_outlined
                                : Icons.inventory_2_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            chip.available
                                ? "В продаже"
                                : "Архивный вкус",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Row(
                        children: [

                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            chip.rating.average.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            " (${chip.rating.count})",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 16),

                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 17,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            // "10",
                            chip.commentCount.toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}