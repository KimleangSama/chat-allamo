import 'package:chat_allamo/theme/constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserProfileSetting extends StatelessWidget {
  const UserProfileSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              onTap: () => context.push('/settings'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Image border
                    child: SizedBox.fromSize(
                      size: const Size.fromRadius(18), // Image radius
                      child: Image.asset(
                        'assets/icons/ollama.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      "Settings",
                      softWrap: true,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
