import 'package:flutter/material.dart';

class ConsumeableStarScreen extends StatelessWidget {
  const ConsumeableStarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Consumable'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Successfully buy consumable products'),
          ],
        ),
      ),
    );
  }
}