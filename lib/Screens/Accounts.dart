import 'package:flutter/material.dart';
import 'package:movcheck/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Account',
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'ClashDisplay',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),
          // Use SliverToBoxAdapter to place regular widgets inside a CustomScrollView.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Dark Mode Toggle
                  ListTile(
                    title: const Text('Dark Mode'),
                    trailing: Switch.adaptive(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        final provider = Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        );
                        provider.toggleTheme(value);
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                  ),
                  // You can add more settings here in the future
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
