import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trinity/type/cart_item.dart';
import 'package:trinity/type/promo.dart';

class CartStore extends ChangeNotifier {
  static const String _storageKey = 'cart_items';

  List<CartItem> _items = [];
  List<Promo> _availablePromotions = [];

  bool _isLoadingPromotions = false;
  String? _promoError;

  /// Get all items in the cart
  List<CartItem> get items => List.unmodifiable(_items);

  /// Get available promotions for the current cart
  List<Promo> get availablePromotions => _availablePromotions;

  /// Check if promotions are currently loading
  bool get isLoadingPromotions => _isLoadingPromotions;

  /// Get any error that occurred while loading promotions
  String? get promoError => _promoError;

  /// Set available promotions
  void setAvailablePromotions(List<Promo> promotions) {
    _availablePromotions = promotions;
    notifyListeners();
  }

  /// Set loading promotions state
  void setLoadingPromotions(bool isLoading) {
    _isLoadingPromotions = isLoading;
    notifyListeners();
  }

  /// Set promotion error message
  void setPromoError(String? error) {
    _promoError = error;
    notifyListeners();
  }

  /// Check if a product has any applicable promotions
  bool hasPromotion(String productId) {
    return _availablePromotions.any(
      (promo) => promo.products.any((product) => product.id == productId),
    );
  }

  /// Get promotions applicable to a specific product
  List<Promo> getProductPromotions(String productId) {
    return _availablePromotions
        .where(
          (promo) => promo.products.any((product) => product.id == productId),
        )
        .toList();
  }

  /// Get the subtotal price (before applying promotions)
  double get subtotalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  /// Get the total discount amount from all applicable promotions
  double get discountAmount {
    if (_availablePromotions.isEmpty) return 0;

    double totalDiscount = 0;

    // Calculate discounts for each available promotion
    for (final promo in _availablePromotions) {
      // Get eligible product IDs for this promotion
      final eligibleProductIds =
          promo.products.map((product) => product.id).toList();

      // Find eligible items in the cart
      final eligibleItems =
          _items.where((item) => eligibleProductIds.contains(item.id)).toList();

      // Skip this promotion if no eligible products are in the cart
      if (eligibleItems.isEmpty) continue;

      switch (promo.discountType) {
        case 'percentage':
          // Calculate subtotal of only eligible products
          double eligibleSubtotal = eligibleItems.fold(
            0,
            (sum, item) => sum + (item.price * item.quantity),
          );

          // Apply percentage discount only to eligible products
          totalDiscount += (eligibleSubtotal * promo.discountValue / 100);
          break;

        case 'fixed':
          // Apply fixed discount if eligible products are in cart
          totalDiscount += promo.discountValue;
          break;

        case 'bogo':

          // Find the cheapest eligible item for the free item discount
          eligibleItems.sort((a, b) => a.price.compareTo(b.price));
          int freePairs = eligibleItems.fold(
            0,
            (sum, item) => sum + (item.quantity ~/ 2),
          );

          totalDiscount +=
              freePairs > 0 ? eligibleItems.first.price * freePairs : 0;
          break;
      }
    }

    return totalDiscount;
  }

  /// Calculate the discounted price for a specific product with all applicable promotions
  ///
  /// @param productId The ID of the product to calculate discount for
  /// @param quantity Optional quantity, defaults to 1
  /// @return The discounted price for the product
  double getProductDiscountedPrice(String productId, {int quantity = 1}) {
    final item = _items.firstWhere(
      (item) => item.id == productId,
      orElse:
          () => CartItem(
            id: productId,
            name: '',
            price: 0,
            imageUrl: '',
            quantity: quantity,
          ),
    );

    // Get the original price for the product
    final originalPrice = item.price * quantity;

    // If no promotions are available, return the original price
    if (_availablePromotions.isEmpty) return originalPrice;

    // Find all promotions applicable to this product
    final applicablePromos = getProductPromotions(productId);
    if (applicablePromos.isEmpty) return originalPrice;

    double totalDiscount = 0;

    // Calculate discounts for each applicable promotion
    for (final promo in applicablePromos) {
      switch (promo.discountType) {
        case 'percentage':
          // Apply percentage discount to the product
          totalDiscount += (originalPrice * promo.discountValue / 100);
          break;

        case 'fixed':
          // Apply fixed discount to the product
          // For a single product, we apply a proportional amount of the fixed discount
          totalDiscount += promo.discountValue / promo.products.length;
          break;

        case 'bogo':
          // Buy one get one free - if quantity is at least 2
          int freePairs = quantity ~/ 2;
          if (freePairs > 0) {
            totalDiscount += item.price * freePairs;
          }
          break;
      }
    }

    // Return the discounted price, ensuring it's never negative
    final discountedPrice = originalPrice - totalDiscount;
    return discountedPrice > 0 ? discountedPrice : 0;
  }

  /// Get the total price after applying promotions
  double get totalPrice {
    final total = subtotalPrice - discountAmount;
    return total > 0 ? total : 0; // Ensure we never go below zero
  }

  /// Add an item to the cart
  ///
  /// If the item already exists in the cart (same id),
  /// the quantity will be increased instead of adding a duplicate
  ///
  /// Example:
  /// ```dart
  /// cartStore.addItem(CartItem(
  ///   id: '123',
  ///   name: 'Product Name',
  ///   price: 9.99,
  ///   imageUrl: 'path/to/image.png',
  /// ));
  /// ```
  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.id == item.id);

    if (existingIndex >= 0) {
      // Item already exists, increase quantity
      _items[existingIndex].quantity += item.quantity;
    } else {
      // New item, add to cart
      _items.add(item);
    }

    _saveToStorage();
    notifyListeners();
  }

  /// Increment the quantity of an item by 1
  ///
  /// Example:
  /// ```dart
  /// cartStore.incrementQuantity('123');
  /// ```
  void incrementQuantity(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index].quantity += 1;
      _saveToStorage();
      notifyListeners();
    }
  }

  /// Decrement the quantity of an item by 1
  /// If the quantity becomes 0, the item is removed from the cart
  ///
  /// Example:
  /// ```dart
  /// cartStore.decrementQuantity('123');
  /// ```
  void decrementQuantity(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      _saveToStorage();
      notifyListeners();
    }
  }

  /// Clear all items from the cart
  ///
  /// Example:
  /// ```dart
  /// cartStore.clearCart();
  ///
  /// ```
  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _saveToStorage();
    notifyListeners();
  }

  /// Clear all items from the cart
  ///
  /// Example:
  /// ```dart
  /// cartStore.clearCart();
  /// ```
  void clearCart() {
    _items.clear();
    _saveToStorage();
    notifyListeners();
  }

  /// Save cart items to persistent storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = _items.map((item) => item.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(itemsJson));
    } catch (e) {
      debugPrint('Error saving cart to storage: $e');
    }
  }

  /// Load cart items from persistent storage
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsString = prefs.getString(_storageKey);

      if (itemsString != null && itemsString.isNotEmpty) {
        final itemsJson = jsonDecode(itemsString) as List;
        _items =
            itemsJson.map((itemJson) => CartItem.fromJson(itemJson)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart from storage: $e');
    }
  }
}
