import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../layout/screens/app_shell.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _service = CategoryService();

  late Future<List<Category>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _service.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final created = await context.push<bool>('/categories/new');

                    if (created == true) {
                      setState(() {
                        _categories = _service.getCategories();
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Category'),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Expanded(
              child: FutureBuilder<List<Category>>(
                future: _categories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Failed to load categories'),
                    );
                  }

                  final categories = snapshot.data!;

                  if (categories.isEmpty) {
                    return const Center(child: Text('No categories found'));
                  }

                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: categories.map((category) {
                      return DataRow(
                        cells: [
                          DataCell(Text(category.name)),

                          DataCell(Text(category.description ?? '')),

                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final updated = await context.push<bool>(
                                      '/categories/${category.id}/edit',
                                    );

                                    if (updated == true) {
                                      setState(() {
                                        _categories = _service.getCategories();
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Delete Category'),
                                          content: const Text('Are you sure?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmed == true) {
                                      await _service.deleteCategory(
                                        category.id,
                                      );

                                      setState(() {
                                        _categories = _service.getCategories();
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
