import 'package:flutter/material.dart';
import '../models/vault_item_model.dart';
import '../services/vault_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final VaultService _vaultService = VaultService();
  final TextEditingController _searchController = TextEditingController();

  List<VaultItemModel> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems([String? search]) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _vaultService.getItems(search: search);
      setState(() {
        _items = items;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddItemDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final payloadController = TextEditingController();
    final tagsController = TextEditingController();
    int itemType = 0; // 0 = Document, 1 = Secret, 2 = Card
    int visibility = 0; // 0 = Private, 1 = Shared

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Store in Vault'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                ),
                DropdownButtonFormField<int>(
                  value: itemType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Document / Note')),
                    DropdownMenuItem(value: 1, child: Text('Secret / Password / PIN')),
                    DropdownMenuItem(value: 2, child: Text('Card / Identification')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => itemType = val);
                  },
                ),
                TextField(
                  controller: payloadController,
                  decoration: const InputDecoration(labelText: 'Content / Secret Data'),
                  obscureText: itemType == 1,
                ),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(labelText: 'Tags (e.g. finance, home)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: visibility,
                  decoration: const InputDecoration(labelText: 'Privacy Boundary'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Private (Strictly My Vault)')),
                    DropdownMenuItem(value: 1, child: Text('Shared (Partner Can Access)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => visibility = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final payload = payloadController.text.trim();
                if (title.isEmpty || payload.isEmpty) return;

                try {
                  await _vaultService.createItem(
                    title: title,
                    description: descController.text.trim(),
                    itemType: itemType,
                    encryptedPayload: payload,
                    tags: tagsController.text.trim(),
                    visibility: visibility,
                  );
                  if (mounted) Navigator.of(ctx).pop();
                  await _loadItems();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Save Securely'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(int type) {
    switch (type) {
      case 1:
        return Icons.vpn_key;
      case 2:
        return Icons.credit_card;
      default:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Vault'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => _loadItems()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search documents, secrets, tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadItems();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (val) => _loadItems(val),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                    : _items.isEmpty
                        ? const Center(
                            child: Text(
                              'No vault items found.\nStore documents, passwords, or shared keys safely! 🔐',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              final isShared = item.visibility != 0;

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: Icon(
                                    _iconForType(item.itemType),
                                    color: item.itemType == 1 ? Colors.amber.shade800 : Colors.indigo,
                                  ),
                                  title: Text(
                                    item.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (item.description != null && item.description!.isNotEmpty)
                                        Text(item.description!),
                                      if (item.tags != null && item.tags!.isNotEmpty)
                                        Text('🏷️ ${item.tags!}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                  trailing: Chip(
                                    label: Text(
                                      isShared ? 'Shared' : 'Private',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: (isShared ? Colors.pink : Colors.deepPurple).withOpacity(0.1),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
