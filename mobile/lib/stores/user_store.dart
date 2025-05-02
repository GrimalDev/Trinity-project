import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trinity/type/user.dart';
import 'package:trinity/type/shopping_list_item.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class UserStore extends ChangeNotifier {
  List<ShoppingListItem> _shoppingList = [];
  final Uuid _uuid = Uuid();

  List<ShoppingListItem> get shoppingList => _shoppingList;
  User? _currentUser;
  bool _isAuthenticated = false;

  /// The currently authenticated user. Returns null if no user is authenticated.
  ///
  /// Example:
  /// ```dart
  /// if (userStore.currentUser != null) {
  ///   print(userStore.currentUser!.username);
  /// }
  ///````
  User? get currentUser => _currentUser;

  /// Whether a user is currently authenticated.
  ///
  /// Example:
  /// ```dart
  /// if (userStore.isAuthenticated) {
  ///   Navigator.pushNamed(context, '/dashboard');
  /// } else {
  ///   Navigator.pushNamed(context, '/login');
  /// }
  /// ```
  bool get isAuthenticated => _isAuthenticated;

  /// Sets the current user with admin permissions.
  ///
  /// Creates a new user with full access permissions (*) and sets them as authenticated.
  ///
  /// Example:
  /// ```dart
  /// userStore.setUser("admin_user");
  ///````
  void setUser(User user) {
    if (_currentUser == user) return;
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Logs out the current user and resets the authentication state.
  ///
  /// Example:
  /// ```dart
  /// userStore.resetUser();
  /// assert(userStore.currentUser == null);
  /// assert(userStore.isAuthenticated == false);
  /// ```
  void resetUser() {
    _currentUser = null;
    _isAuthenticated = false;
    _shoppingList.clear();
    _saveShoppingList();
    notifyListeners();
  }

  // Add a new shopping list item
  void addShoppingListItem(String text) {
    _shoppingList.add(ShoppingListItem(id: _uuid.v4(), text: text));
    _saveShoppingList();
    notifyListeners();
  }

  // Remove a shopping list item
  void removeShoppingListItem(String id) {
    _shoppingList.removeWhere((item) => item.id == id);
    _saveShoppingList();
    notifyListeners();
  }

  // Toggle item checked status
  void toggleShoppingListItem(String id) {
    final index = _shoppingList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _shoppingList[index].isChecked = !_shoppingList[index].isChecked;
      _saveShoppingList();
      notifyListeners();
    }
  }

  // Update personal note for an item
  void updateShoppingListItemNote(String id, String note) {
    final index = _shoppingList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _shoppingList[index].personalNote = note;
      _saveShoppingList();
      notifyListeners();
    }
  }

  // Save shopping list to persistent storage
  Future<void> _saveShoppingList() async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = _shoppingList.map((item) => item.toJson()).toList();
    await prefs.setString('shopping_list', json.encode(listJson));
  }

  // Load shopping list from persistent storage
  Future<void> loadShoppingList() async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getString('shopping_list');
    if (listJson != null) {
      final List<dynamic> decoded = json.decode(listJson);
      _shoppingList =
          decoded.map((item) => ShoppingListItem.fromJson(item)).toList();
      notifyListeners();
    }
  }

  /// Checks if the current user has permission to access a specific resource with a specific method.
  ///
  /// [resource] The resource path (e.g., "/users", "/products")
  /// [method] The HTTP method (e.g., "GET", "POST", "PUT", "DELETE")
  ///
  /// Returns false if no user is authenticated, true otherwise (currently always returns true for authenticated users).
  ///
  /// Example:
  /// ```dart
  /// if (userStore.hasPermission("/admin/users", "GET")) {
  ///   // User can access the admin users page
  /// }
  ///
  /// if (userStore.hasPermission("/api/products", "POST")) {
  ///   // User can create new products
  /// }
  /// ```
  bool hasPermission(String resource, String method) {
    return _currentUser?.hasPermission(resource, method) ?? false;
  }
}
