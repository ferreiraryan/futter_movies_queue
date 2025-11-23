

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_queue/app/services/firestore_service.dart';

class PendingInviteCard extends StatefulWidget {
  
  final QueryDocumentSnapshot invite;

  const PendingInviteCard({super.key, required this.invite});

  @override
  State<PendingInviteCard> createState() => _PendingInviteCardState();
}

class _PendingInviteCardState extends State<PendingInviteCard> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    
    final data = widget.invite.data() as Map<String, dynamic>;
    final inviterName = data['inviterName'] ?? 'Alguém';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.deepPurple[400],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$inviterName convidou você para a fila dele!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      await _firestoreService.declineInvite(widget.invite.id);
                      
                    },
                    child: const Text(
                      'Recusar',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      await _firestoreService.acceptInvite(widget.invite.id);
                      
                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                    ),
                    child: const Text('Aceitar'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
