import 'dart:io';

import 'package:casa_inteligente/pages/scan.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile(this.username, {Key? key, required this.imagePath}) : super(key: key);
  final String username;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            children: [
              Text(
                username,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Usuario',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(File(imagePath)),
              ),
            ),
            margin: EdgeInsets.all(20),
            width: 50,
            height: 50,
          ),
        ],
      ),
        
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: ScanScreen(username: username, imagePath: imagePath),
        ),
      ),
    );
  }
}






