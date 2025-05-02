import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trinity/screens/search_product_page.dart';
import 'package:trinity/screens/promotions_page.dart';
import 'package:trinity/screens/deals_page.dart';
import 'package:trinity/screens/shopping_lists_page.dart';
import 'package:trinity/screens/recipe_page.dart';
import 'package:trinity/screens/login_page.dart';
import 'package:trinity/stores/user_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserStore>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: MediaQuery.of(context).size.height * 0.23,
        backgroundColor: Colors.transparent,
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('lib/images/background.png', fit: BoxFit.cover),
            Container(color: Colors.grey.withValues(alpha: (0.7))),
          ],
        ),
        title:
            userStore.isAuthenticated
                ? Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Bienvenue ${userStore.currentUser?.firstName ?? 'Utilisateur'} !",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
                : ElevatedButton(
                  onPressed: () => _navigateTo(context, const LoginPage()),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(
                      MediaQuery.of(context).size.width * 0.45,
                      MediaQuery.of(context).size.height * 0.063,
                    ),
                  ),
                  child: Text(
                    "Se connecter",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: MediaQuery.of(context).size.width * 0.04,
                mainAxisSpacing: MediaQuery.of(context).size.width * 0.04,
                childAspectRatio:
                    MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height * 0.47),
                children: [
                  buildGridCard(
                    "lib/icons/promo.svg",
                    "Promotions",
                    () => _navigateTo(context, PromotionsPage()),
                    context,
                  ),
                  buildGridCard(
                    "lib/icons/deal.svg",
                    "Bons plans",
                    () => _navigateTo(context, DealsPage()),
                    context,
                  ),
                  buildGridCard(
                    "lib/icons/list.svg",
                    "Ma liste",
                    () => _navigateTo(context, ShoppingListsPage()),
                    context,
                  ),
                  buildGridCard(
                    "lib/icons/recette.svg",
                    "Recettes",
                    () => _navigateTo(context, RecipesPage()),
                    context,
                  ),
                ],
              ),
            ),
            buildCard(
              "lib/icons/search.svg",
              "Rechercher un produit",
              () => _navigateTo(context, ProductSearchPage()),
              context,
            ),
            // const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

/// Carte standard
Widget buildCard(
  String asset,
  String title,
  VoidCallback onTap,
  BuildContext context,
) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 10.0,
    ), // Adjusted from 'custom' to a valid property
    child: SizedBox(
      child: ShadCard(
        backgroundColor: Colors.grey[900],
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                asset,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                width: 30, // Fixed size for consistency
                height: 30, // Adjusted for better proportion
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20, // Fixed size for predictability
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Carte carrée
Widget buildGridCard(
  String asset,
  String title,
  VoidCallback onTap,
  BuildContext context,
) {
  return ShadCard(
    padding: EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width * 0.02,
      vertical: MediaQuery.of(context).size.height * 0.0008,
    ),
    backgroundColor: Colors.grey[900],
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 90,
            child: SvgPicture.asset(
              asset,
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
