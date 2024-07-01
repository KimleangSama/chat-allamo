import 'dart:async';
import 'dart:io';

import 'package:chat_allamo/controller/chat_controller.dart';
import 'package:chat_allamo/controller/model_controller.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:chat_allamo/util/custom_popup/popup.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BottomChatMessage extends StatefulWidget {
  final ValueNotifier<bool> scrollIndicator;

  const BottomChatMessage({super.key, required this.scrollIndicator});

  @override
  State<BottomChatMessage> createState() => _BottomChatMessageState();
}

class _BottomChatMessageState extends State<BottomChatMessage> {
  XFile? selectedImage;
  final GlobalKey _popupKey = GlobalKey();

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted) {
        return true;
      }
    }
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted &&
              await Permission.videos.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<XFile?> _pickImageFromCameraOrGallery(context, isCamera) async {
    if (await _promptPermissionSetting()) {
      try {
        XFile? image;
        final ImagePicker picker = ImagePicker();
        if (isCamera) {
          image = await picker.pickImage(source: ImageSource.camera);
        } else {
          image = await picker.pickImage(source: ImageSource.gallery);
        }
        if (image != null) {
          setState(() {
            selectedImage = image;
          });
          return image;
        }
      } catch (e) {
        final status = await Permission.photos.status;
        if (status.isDenied) {
          showAlertDialog(context);
        } else {
          showAlertDialog(context);
        }
      }
    } else {
      showAlertDialog(context);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ChatController>();
    final modelController = context.read<ModelController>();
    return ListenableBuilder(
      listenable: Listenable.merge(
        [
          controller.loading,
          modelController.currentModel,
          controller.selectedImage,
          controller.promptFieldController,
          controller.indexOfEditingMessage,
          controller.editingMessage,
        ],
      ),
      builder: (context, _) {
        final model = modelController.currentModel.value;
        final isMessageEditing = controller.indexOfEditingMessage.value != -1;
        final String editingMessage = controller.editingMessage.value;
        final isModelSupportImage =
            model?.details?.families?.contains('clip') ?? false;
        return Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey[400]!,
                width: 0.5,
              ),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Visibility(
                    maintainSize: selectedImage != null,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: selectedImage != null,
                    child: Container(
                      padding: const EdgeInsets.only(top: 4),
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.red.shade500,
                        onPressed: () {
                          setState(() {
                            selectedImage = null;
                          });
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: selectedImage != null
                        ? Container(
                            padding: const EdgeInsets.only(top: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(selectedImage!.path),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(),
                  ),
                  Visibility(
                    maintainSize: isMessageEditing,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: isMessageEditing,
                    child: Container(
                      padding: const EdgeInsets.only(top: 5),
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.red.shade500,
                        onPressed: () {
                          controller.cancelEditMessage();
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: isMessageEditing
                        ? Container(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              "Edit: $editingMessage",
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
              Row(
                children: [
                  Visibility(
                    visible: isModelSupportImage,
                    maintainSize: isModelSupportImage,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: CustomPopup(
                        anchorKey: _popupKey,
                        showArrow: false,
                        backgroundColor: textPaddingColor,
                        contentPadding:
                            const EdgeInsets.only(left: 5, right: 5),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                FluentIcons.camera_20_regular,
                                color: textColor,
                              ),
                              tooltip: "Camera",
                              onPressed: () async {
                                Navigator.of(context).pop();
                                XFile? image =
                                    await _pickImageFromCameraOrGallery(
                                        context, true);
                                if (image != null) {
                                  controller.addImage(image);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                FluentIcons.image_add_20_regular,
                                color: textColor,
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                XFile? image =
                                    await _pickImageFromCameraOrGallery(
                                        context, false);
                                if (image != null) {
                                  controller.addImage(image);
                                }
                              },
                            ),
                          ],
                        ),
                        child: const Icon(
                          FluentIcons.add_16_regular,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isModelSupportImage ? 0 : 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: TextField(
                        controller: controller.promptFieldController,
                        focusNode: controller.promptFieldFocusNode,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 5, top: 5),
                            hintText: "Message",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 182, 182, 182)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: const BorderSide(color: Colors.grey),
                            )),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        onEditingComplete: controller.chat,
                        onTap: () {
                          controller.scrollToEnd(milliseconds: 75);
                          widget.scrollIndicator.value = false;
                        },
                        onTapOutside: (event) {
                          controller.promptFieldFocusNode.unfocus();
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 1.8),
                    child: controller.loading.value
                        ? IconButton(
                            icon: const Icon(FluentIcons.stop_20_filled),
                            onPressed: () {
                              controller.cancelGenerateChat();
                            },
                          )
                        : IconButton(
                            icon: controller.promptFieldController.text.isEmpty
                                ? const Icon(FluentIcons.send_20_regular)
                                : const Icon(
                                    FluentIcons.send_20_filled,
                                    color: textColor,
                                  ),
                            onPressed: controller
                                    .promptFieldController.text.isEmpty
                                ? () {
                                    toast("Please enter a message");
                                    controller.promptFieldFocusNode
                                        .requestFocus();
                                  }
                                : () async {
                                    if (isMessageEditing) {
                                      setState(() {
                                        selectedImage = null;
                                        widget.scrollIndicator.value = false;
                                      });
                                      await controller.chatWithEditingMessage();
                                      controller.cancelEditMessage();
                                    } else {
                                      setState(() {
                                        selectedImage = null;
                                        widget.scrollIndicator.value = false;
                                      });
                                      bool chatSuccess =
                                          await controller.chat();
                                      if (chatSuccess) {
                                        controller.promptFieldFocusNode
                                            .unfocus();
                                      } else {
                                        Fluttertoast.showToast(
                                          msg:
                                              "Please check your internet connection, select a valid model, proper message, and try again!!!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red.shade600,
                                          textColor: textColor,
                                          fontSize: 16.0,
                                        );
                                      }
                                    }
                                  },
                          ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showAlertDialog(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Allow access to gallery and photos'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Settings'),
            ),
          ],
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Allow access to gallery and photos'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        ),
      );
    }
  }
}
