import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trinity/stores/user_store.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ShoppingListsPage extends StatefulWidget {
  const ShoppingListsPage({super.key});

  @override
  State<ShoppingListsPage> createState() => _ShoppingListsPageState();
}

class _ShoppingListsPageState extends State<ShoppingListsPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load shopping list when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserStore>(context, listen: false).loadShoppingList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ma liste de courses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              final userStore = Provider.of<UserStore>(context, listen: false);
              userStore.shoppingList
                  .where((item) => item.isChecked)
                  .forEach((item) => userStore.removeShoppingListItem(item.id));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ShadInput(
                    controller: _textController,
                    placeholder: const Text("Ajouter un article"),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addItem),
              ],
            ),
          ),
          Expanded(
            child: Consumer<UserStore>(
              builder: (context, userStore, child) {
                return ListView.builder(
                  itemCount: userStore.shoppingList.length,
                  itemBuilder: (context, index) {
                    final item = userStore.shoppingList[index];
                    return Dismissible(
                      key: Key(item.id),
                      background: Container(color: Colors.red),
                      onDismissed: (_) {
                        userStore.removeShoppingListItem(item.id);
                      },
                      child: CheckboxListTile(
                        title: Text(
                          item.text,
                          style: TextStyle(
                            decoration:
                                item.isChecked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        value: item.isChecked,
                        onChanged: (_) {
                          userStore.toggleShoppingListItem(item.id);
                        },
                        secondary: IconButton(
                          icon: const Icon(Icons.note_add),
                          onPressed: () => _showNoteDialog(context, item),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      Provider.of<UserStore>(context, listen: false).addShoppingListItem(text);
      _textController.clear();
    }
  }

  void _showNoteDialog(BuildContext context, dynamic item) {
    final noteController = TextEditingController(text: item.personalNote ?? '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Note personnelle'),
            content: ShadInput(
              controller: noteController,
              placeholder: const Text("Ajouter une note"),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<UserStore>(
                    context,
                    listen: false,
                  ).updateShoppingListItemNote(item.id, noteController.text);
                  Navigator.of(context).pop();
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
