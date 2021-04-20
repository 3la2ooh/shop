import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {...this._items};
  }

  int get itemsCount {
    return this._items.length;
  }

  double get totalAmount {
    var total = 0.0;
    this._items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });

    return total;
  }

  void addItem(String productId, double price, String title) {
    if (this._items.containsKey(productId)) {
      this._items.update(
          productId,
          (oldCartItem) => CartItem(
                id: oldCartItem.id,
                price: oldCartItem.price,
                quantity: oldCartItem.quantity + 1,
                title: oldCartItem.title,
              ));
    } else {
      this._items.putIfAbsent(
          productId,
          () => CartItem(
                id: DateTime.now().toString(),
                title: title,
                price: price,
                quantity: 1,
              ));
    }
    notifyListeners();
  }

  toggleCartStatus({@required String productId, double price, String title}) {
    if (this._items.containsKey(productId))
      this.removeItem(productId);
    else
      addItem(productId, price, title);
  }

  void removeItem(String productId) {
    if (!this._items.containsKey(productId)) return;

    if (this._items[productId].quantity > 1)
      this._items.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                quantity: existingCartItem.quantity - 1,
                price: existingCartItem.price,
              ));
    else
      this._items.remove(productId);
    notifyListeners();
  }

  void clear() {
    this._items = {};
    notifyListeners();
  }
}
