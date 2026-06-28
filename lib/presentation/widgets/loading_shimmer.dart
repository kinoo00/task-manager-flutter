import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 5,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            leading: const CircleAvatar(),
            title: Container(height: 16, color: Colors.white),
            subtitle: Container(height: 12, color: Colors.white),
            trailing: Container(width: 40, height: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}