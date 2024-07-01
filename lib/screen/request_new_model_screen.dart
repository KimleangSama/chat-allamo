import 'package:chat_allamo/theme/constant.dart';
import 'package:flutter/material.dart';

class RequestNewModelScreen extends StatefulWidget {
  const RequestNewModelScreen({super.key});

  @override
  State<RequestNewModelScreen> createState() => _RequestNewModelScreenState();
}

class _RequestNewModelScreenState extends State<RequestNewModelScreen> {
  final _nameController = TextEditingController();
  final _modelNameController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: const Text('Request New Model',
            style: TextStyle(color: textColor, fontSize: 17)),
        backgroundColor: appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _modelNameController,
                decoration: const InputDecoration(
                  labelText: 'Ollama model name',
                ),
              ),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for requesting the model',
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
