import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import '../../../core/utils/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../profile/pages/profile_page.dart';

class DashboardHeader extends StatelessWidget {
  final User user;

  const DashboardHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: GoogleFonts.inter(
                fontSize: 24,
                height: 32 / 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3D9889),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.name,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
            );
          },
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(top: 2, left: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3D9889), width: 1),
            ),
            child: user.avatarPath != null
                ? ClipOval(
                    child: user.avatarPath!.startsWith('assets/')
                        ? Image.asset(
                            user.avatarPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person,
                              color: AppColors.lightTextSecondary,
                              size: 28,
                            ),
                          )
                        : Image.file(
                            File(user.avatarPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person,
                              color: AppColors.lightTextSecondary,
                              size: 28,
                            ),
                          ),
                  )
                : Icon(
                    Icons.person,
                    color: AppColors.lightTextSecondary,
                    size: 28,
                  ),
          ),
        ),
      ],
    );
  }
}
