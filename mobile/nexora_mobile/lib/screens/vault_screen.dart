import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vault_item_model.dart';
import '../services/vault_service.dart';
import '../theme/nexora_theme.dart';
import '../widgets/bento_card.dart';
import '../widgets/vault_secret_tile.dart';

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
  int? _selectedTypeFilter; // null = all, 0 = Docs, 1 = Passwords, 2 = Cards

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
      if (mounted) {
        setState(() {
          _items = items;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddItemDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final payloadController = TextEditingController();
    final tagsController = TextEditingController();
    int itemType = 1; // Default to Secret
    int visibility = 0; // 0 = Private, 1 = Shared

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final tokens = NexoraTheme.of(context);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: tokens.cardSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(NexoraRadius.lg)),
                border: Border.all(color: tokens.strokeSubtle),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: tokens.strokeSubtle,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.shield_rounded, color: tokens.vaultAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Store Encrypted Secret',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: tokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: tokens.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. Netflix Login, House Safe PIN',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: TextStyle(color: tokens.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'Account identifier, recovery note',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Item Type Dropdown
                    DropdownButtonFormField<int>(
                      initialValue: itemType,
                      dropdownColor: tokens.cardSurface,
                      style: TextStyle(color: tokens.textPrimary),
                      decoration: const InputDecoration(labelText: 'Vault Category'),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('📄 Document / Sensitive Note')),
                        DropdownMenuItem(value: 1, child: Text('🔑 Secret / Password / PIN')),
                        DropdownMenuItem(value: 2, child: Text('💳 Card / Identification')),
                      ],
                      onChanged: (val) {
                        if (val != null) setSheetState(() => itemType = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: payloadController,
                      obscureText: itemType == 1,
                      style: TextStyle(
                        fontFamily: itemType == 1 ? NexoraTheme.monoFont : null,
                        color: tokens.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Sensitive Secret / Data',
                        hintText: itemType == 1 ? '••••••••••••' : 'Enter payload',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: tagsController,
                      style: TextStyle(color: tokens.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                        hintText: 'finance, home, personal',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Visibility Boundary
                    Text(
                      'Access Boundary',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: tokens.strokeSubtle,
                        borderRadius: NexoraRadius.borderSm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setSheetState(() => visibility = 0);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: visibility == 0 ? tokens.cardSurface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '🔒 Strictly Only You',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: visibility == 0
                                          ? tokens.vaultAccent
                                          : tokens.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setSheetState(() => visibility = 1);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: visibility == 1 ? tokens.cardSurface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '💖 Shared Pair Vault',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: visibility == 1
                                          ? tokens.coupleAccent
                                          : tokens.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.vaultAccent,
                        ),
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
                              if (ctx.mounted) Navigator.of(ctx).pop();
                              await _loadItems();
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                        },
                        child: const Text('Encrypt & Store', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NexoraTheme.of(context);

    final filteredItems = _items.where((i) {
      if (_selectedTypeFilter != null && i.itemType != _selectedTypeFilter) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        title: const Text('Knowledge Vault'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => _loadItems()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: tokens.vaultAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Hardware-encrypted Security Indicator & Biometric Reminder Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: BentoCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              borderRadius: NexoraRadius.borderMd,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tokens.vaultAccent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.fingerprint_rounded, color: tokens.vaultAccent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AES-256 Hardware Encrypted',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: tokens.textPrimary,
                          ),
                        ),
                        Text(
                          'Payloads obscured by default with biometric lock',
                          style: TextStyle(
                            fontSize: 11,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.vaultAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SECURE',
                      style: TextStyle(
                        fontFamily: NexoraTheme.monoFont,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: tokens.vaultAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: tokens.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search encrypted vault & tags...',
                prefixIcon: Icon(Icons.search_rounded, color: tokens.textSecondary, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _loadItems();
                  },
                ),
              ),
              onSubmitted: (val) => _loadItems(val),
            ),
          ),

          // Category Choice Chips (All, Passwords, Cards, Documents)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              children: [
                _buildChoiceChip('All', null, tokens),
                const SizedBox(width: 8),
                _buildChoiceChip('Passwords', 1, tokens),
                const SizedBox(width: 8),
                _buildChoiceChip('Cards', 2, tokens),
                const SizedBox(width: 8),
                _buildChoiceChip('Documents', 0, tokens),
              ],
            ),
          ),

          // Vault Secret Tiles Stream
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error', style: TextStyle(color: tokens.vaultAccent)))
                    : filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline_rounded,
                                    size: 48, color: tokens.textSecondary.withOpacity(0.4)),
                                const SizedBox(height: 12),
                                Text(
                                  'No vault items found.\nStore passwords or shared duo secrets safely!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: tokens.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadItems(),
                            color: tokens.vaultAccent,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                return VaultSecretTile(item: filteredItems[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, int? type, NexoraThemeExtension tokens) {
    final isSelected = _selectedTypeFilter == type;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        HapticFeedback.selectionClick();
        setState(() => _selectedTypeFilter = selected ? type : null);
      },
      selectedColor: tokens.vaultAccent.withOpacity(0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? tokens.vaultAccent : tokens.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? tokens.vaultAccent : tokens.strokeSubtle,
      ),
      backgroundColor: tokens.cardSurface,
    );
  }
}
