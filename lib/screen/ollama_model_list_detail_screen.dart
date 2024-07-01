import 'package:chat_allamo/controller/model_controller.dart';
import 'package:chat_allamo/model/conversation.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:chat_allamo/util/async_result.dart';
import 'package:chat_allamo/util/expansion_tile_card.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:provider/provider.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';

class OllamaModelListDetailScreen extends StatelessWidget {
  final ValueNotifier<String> filterNotifier = ValueNotifier('');

  OllamaModelListDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ModelController>();
    return ListenableBuilder(
      listenable: Listenable.merge(
        [
          controller.models,
          controller.currentModel,
          filterNotifier,
        ],
      ),
      builder: (context, _) {
        final models = controller.models.value.data ?? [];
        final filter = filterNotifier.value;
        return SuperScaffold(
          stretch: true,
          appBar: SuperAppBar(
            title: const Text(
              "Models",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.normal,
                color: textColor,
              ),
            ),
            backgroundColor: appBarColor,
            largeTitle: SuperLargeTitle(
              enabled: true,
              largeTitle: "Models",
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(FluentIcons.add_20_regular, size: 24),
                  onPressed: () {
                    context.push('/models/request_new_model');
                  },
                ),
                const SizedBox(width: 15),
              ],
            ),
            searchBar: SuperSearchBar(
              resultColor: scaffoldColor,
              enabled: true,
              scrollBehavior: SearchBarScrollBehavior.pinned,
              resultBehavior: SearchBarResultBehavior.visibleOnInput,
              onChanged: (query) {
                filterNotifier.value = query;
              },
              searchResult: ValueListenableBuilder(
                valueListenable: filterNotifier,
                builder: (context, value, _) {
                  if (filter.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  bool match(Model element) => (element.model!)
                      .toLowerCase()
                      .contains(filter.toLowerCase());
                  final filteredModels =
                      filter.isEmpty ? models : models.where(match).toList();
                  return _modelsListView(filteredModels, controller);
                },
              ),
            ),
          ),
          body: models.isNotEmpty
              ? _modelsListView(models, controller)
              : const Center(
                  child: Text("No model available."),
                ),
        );
      },
    );
  }

  Widget _modelsListView(List<Model> models, ModelController controller) {
    return ListView.builder(
      itemCount: models.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
      itemBuilder: (context, index) {
        final model = models[index];
        final isSelected = model == controller.currentModel.value;
        return Row(
          children: [
            IconButton(
              onPressed: () {
                controller.selectModelNamed(model.model!);
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
                            Text(model.details?.families?.contains('clip') ==
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
  }
}
