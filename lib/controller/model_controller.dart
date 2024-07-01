import 'dart:async';

import 'package:chat_allamo/util/async_result.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelController {
  final SharedPreferences prefs;

  final OllamaClient _client;
  OllamaClient get client => _client;

  final ValueNotifier<Model?> currentModel = ValueNotifier(null);

  final ValueNotifier<AsyncData<List<Model>>> models =
      ValueNotifier(const Data([]));

  final ValueNotifier<AsyncData<ModelInfo?>> modelInfo =
      ValueNotifier(const Data(null));

  ModelController({
    required OllamaClient client,
    required this.prefs,
  }) : _client = client;

  Future<void> init() async {
    await loadModels();
  }

  Future<void> loadModels() async {
    models.value = const Pending();
    try {
      final response = await _client.listModels();
      if (response.models?.isNotEmpty ?? false) {
        models.value = Data(List.unmodifiable(response.models!));

        final prefs = await SharedPreferences.getInstance();

        if (prefs.containsKey('currentModel')) {
          final lastModel = prefs.getString('currentModel');
          if (lastModel != null) {
            selectModel(
              response.models!.firstWhere(
                (element) => element.model == lastModel,
                orElse: () => response.models!.first,
              ),
            );
          }
          return;
        }
        selectModel(response.models!.first);
      } else {
        models.value = const Data([]);
      }
    } catch (err, _) {
      models.value = const DataError('Models listing error :s');
    }
  }

  Future<void> loadModelInfo(final Model model) async {
    try {
      modelInfo.value = const Pending();

      final info = await _client.showModelInfo(
        request: ModelInfoRequest(model: model.model!),
      );
      modelInfo.value = Data(info);
    } catch (err) {
      modelInfo.value = const DataError('Model info error :s');
    }
  }

  Future<void> selectModel(final Model? model) async {
    if (model == null) return;

    if (model.model != null) {
      (await SharedPreferences.getInstance())
          .setString('currentModel', model.model!);
    }

    currentModel.value = model;
    loadModelInfo(model);
  }

  Future<void> selectModelNamed(final String modelName) async {
    final newModel = models.value.data?.firstWhereOrNull(
      (element) => element.model?.startsWith(modelName) ?? false,
    );

    if (newModel != null) await selectModel(newModel);
  }

  Future<void> deleteModel(Model model) async {
    final name = model.model;
    if (name != null) {
      final request = DeleteModelRequest(model: name);
      await _client.deleteModel(request: request);

      await loadModels();
    }
  }

  ValueNotifier<double?> pullProgress = ValueNotifier(null);

  Future<void> updateModel(Model model) async {
    if (model.model == null) return;

    await _downloadModel(model.model!);
    loadModelInfo(model);
  }

  Future<void> _downloadModel(String name) async {
    pullProgress.value = 0;

    try {
      final streamResponse = _client.pullModelStream(
        request: PullModelRequest(
          model: name,
          stream: true,
        ),
      );

      await for (final chunk in streamResponse) {
        pullProgress.value =
            chunk.total != null ? (chunk.completed ?? 0) / chunk.total! : 0;
      }

      pullProgress.value = null;
    } catch (err) {
      rethrow;
    }

    await loadModels();
  }
}
