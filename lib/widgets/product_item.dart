import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final String name;
  final String status;
  final Color color;
  final String imageUrl;
  final VoidCallback onTap;

  const ProductItem({
    super.key,
    required this.name,
    required this.status,
    required this.color,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(name, style: const TextStyle(fontSize: 16)),
        subtitle: Text('Estado: $status'),
        trailing: CircleAvatar(
          radius: 10,
          backgroundColor: color, // Color según estado
        ),
      ),
    );
  }
}
