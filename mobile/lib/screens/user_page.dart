import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trinity/config/routes.dart';
import 'package:trinity/stores/user_store.dart';
import 'package:trinity/screens/login_page.dart';
import 'package:trinity/screens/home_page.dart';
import 'package:trinity/utils/api/user.dart';
import 'package:trinity/type/user.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _isDark = true;
  Future<User?>? currentUserDetailFuture;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    final userStore = Provider.of<UserStore>(context, listen: false);
    if (!userStore.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRoutes.of(context).navigateTo(AppRoutes.login);
      });
    } else {
      currentUserDetailFuture = UserApi().getUserDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserStore>(context);

    return Theme(
      data: _isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Votre compte")),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              children: [
                _SingleSection(
                  title: "Paramètres de l'application",
                  children: [
                    _CustomListTile(
                      title: "Mode Sombre",
                      icon: Icons.dark_mode_outlined,
                      trailing: Switch(
                        value: _isDark,
                        onChanged: (value) {
                          setState(() {
                            _isDark = value;
                          });
                        },
                      ),
                    ),
                    const _CustomListTile(
                      title: "Notifications",
                      icon: Icons.notifications_none_rounded,
                    ),
                  ],
                ),
                if (userStore.isAuthenticated) ...[
                  _SingleSection(
                    title: "Profil utilisateur",
                    children: [
                      FutureBuilder<User?>(
                        future: currentUserDetailFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text("Erreur de chargement"),
                            );
                          } else if (snapshot.hasData) {
                            final user = snapshot.data;
                            return Column(
                              children: [
                                _CustomListTileWithValue(
                                  title: "Nom",
                                  value: user?.lastName ?? "Non renseigné",
                                  icon: Icons.person_outline_rounded,
                                ),
                                _CustomListTileWithValue(
                                  title: "Prénom",
                                  value: user?.firstName ?? "Non renseigné",
                                  icon: Icons.message_outlined,
                                ),
                                _CustomListTileWithValue(
                                  title: "Email",
                                  value: user?.email ?? "Non renseigné",
                                  icon: Icons.email_outlined,
                                ),
                                _CustomListTileWithValue(
                                  title: "Numéro de téléphone",
                                  value: user?.phoneNumber ?? "Non renseigné",
                                  icon: Icons.phone_outlined,
                                ),
                                _CustomListTileWithValue(
                                  title: "Adresse",
                                  value: user?.address ?? "Non renseigné",
                                  icon: Icons.home_outlined,
                                ),
                                _CustomListTileWithValue(
                                  title: "Ville + Code postal",
                                  value: user?.city?.name ?? "Non renseigné",
                                  icon: Icons.location_city_outlined,
                                ),
                              ],
                            );
                          } else {
                            return const Center(
                              child: Text("Aucune donnée disponible"),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 160,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO - Modification des infos
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text("Modifier"),
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO - Changer le mot de passe
                            },
                            icon: const Icon(Icons.lock_outline),
                            label: const Text("Mot de passe"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
                _SingleSection(
                  children: [
                    const _CustomListTile(
                      title: "À propos",
                      icon: Icons.info_outline_rounded,
                    ),
                    _CustomListTile(
                      title:
                          userStore.isAuthenticated
                              ? "Se déconnecter"
                              : "Se connecter",
                      icon:
                          userStore.isAuthenticated
                              ? Icons.exit_to_app_rounded
                              : Icons.login_rounded,
                      onTap: () {
                        if (userStore.isAuthenticated) {
                          userStore.resetUser();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                            (route) => false,
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomListTileWithValue extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _CustomListTileWithValue({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _CustomListTile({
    required this.title,
    required this.icon,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SingleSection({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ...children,
        const Divider(),
      ],
    );
  }
}
