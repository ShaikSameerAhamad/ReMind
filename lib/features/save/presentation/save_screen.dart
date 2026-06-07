import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/utils/validation.dart';
import '../domain/save_link.dart';
import 'save_providers.dart';

class SaveScreen extends ConsumerStatefulWidget {
  const SaveScreen({super.key});

  @override
  ConsumerState<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends ConsumerState<SaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  var _isSaving = false;

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Save')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Save your first link', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                'Paste a secure link or share one from another Android app to start building your queue.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                autofillHints: const [AutofillHints.url],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Link',
                  hintText: 'https://example.com/article',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
                validator: (value) {
                  final result = ReMindValidators.secureUrl(value ?? '');
                  return switch (result) {
                    Valid() => null,
                    Invalid(:final message) => message,
                  };
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Optional; reMind can use the source domain',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bookmark_add_outlined),
                label: Text(_isSaving ? 'Saving' : 'Save link'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final saveLink = await ref.read(saveLinkProvider.future);
      final result = await saveLink(
        ownerId: guestOwnerId,
        url: _urlController.text,
        title: _titleController.text,
      );
      if (!mounted) {
        return;
      }
      switch (result) {
        case SaveLinkSuccess():
          ref.invalidate(savedItemsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved locally.')),
          );
          context.go(AppRoutes.queue('recently-saved'));
        case SaveLinkFailure(:final reason):
          final message = reason is Invalid ? reason.message : 'Could not save this link.';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
