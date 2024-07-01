import 'package:chat_allamo/controller/model_controller.dart';
import 'package:chat_allamo/model/conversation.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:chat_allamo/util/async_result.dart';
import 'package:chat_allamo/util/expansion_tile_card.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OllamaModelListScreen extends StatelessWidget {
  const OllamaModelListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ModelController>();
    return Material(
      color: scaffoldColor,
      child: Scaffold(
        backgroundColor: scaffoldColor,
        appBar: AppBar(
          title: const Text(
            "List of Ollama Models",
            style: TextStyle(
              color: textColor,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: appBarColor,
        ),
        body: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: Listenable.merge(
              [
                controller.models,
                controller.currentModel,
              ],
            ),
            builder: (context, _) {
              final models = controller.models.value.data ?? [];
              return ListView.builder(
                itemCount: models.length,
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                itemBuilder: (context, index) {
                  final model = models[index];
                  final isSelected = model == controller.currentModel.value;
                  return Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          controller.selectModelNamed(model.model!);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        icon: Icon(isSelected
                            ? FluentIcons.checkmark_square_20_filled
                            : FluentIcons.square_add_20_regular),
                        iconSize: 28,
                      ),
                      Expanded(
                        child: ExpansionTileCard(
                          finalPadding: const EdgeInsets.only(top: 5, left: 10),
                          initialPadding: const EdgeInsets.only(top: 5),
                          title: Text(model.model ?? 'error'),
                          initiallyExpanded: isSelected,
                          subtitle: isSelected
                              ? const Text(
                                  "Selected Model",
                                  style: TextStyle(color: Colors.blue),
                                )
                              : null,
                          baseColor: textPaddingColor,
                          expandedColor: canvasColor,
                          shadowColor: Colors.transparent,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                left: 25,
                                right: 10,
                                bottom: 10,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Modified At: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(model.formattedLastUpdate),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Text(
                                        'Model Size: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(model.size!.asDiskSize()),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Text(
                                        'Support Image: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(model.details?.families
                                                  ?.contains('clip') ==
                                              true
                                          ? 'Yes'
                                          : 'No'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onExpansionChanged: (value) async {
                            if (value) {
                              controller.loadModelInfo(model);
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
