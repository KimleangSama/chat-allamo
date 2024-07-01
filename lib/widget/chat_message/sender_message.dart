import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SenderMessage extends StatelessWidget {
  final String question;
  final String? imageURL;
  final bool isNetworkImage;

  const SenderMessage({
    super.key,
    required this.question,
    required this.imageURL,
    this.isNetworkImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: imageURL == null
          ? Container(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              decoration: const BoxDecoration(
                color: textPaddingColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Text(
                question,
                style: const TextStyle(fontSize: 14, color: textColor),
              ),
            )
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: isNetworkImage
                          ? GestureDetector(
                              child: CachedNetworkImage(
                                imageUrl: imageURL!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) {
                                  return const Center(
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                              onTap: () {
                                String base64Str =
                                    base64Encode(utf8.encode(imageURL!));
                                context.push('/image_viewer/$base64Str');
                              },
                            )
                          : Image.file(File(imageURL!), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 2.5),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    decoration: const BoxDecoration(
                      color: textPaddingColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      question,
                      style: const TextStyle(fontSize: 14, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
