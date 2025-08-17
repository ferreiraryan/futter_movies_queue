// lib/features/social/widgets/member_card.dart

// lib/features/social/widgets/member_card.dart

import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  final String name;
  final String email;

  const MemberCard({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(email),
      ),
    );
  }
}
