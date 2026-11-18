
import 'package:hive/hive.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  static Box get _box => Hive.box('cart');

  // Mengambil semua produk dlm keranjang berdasarkan username
  static List<CartItem> getCart(String username) {
    final List<dynamic> savedItems =
        _box.get(username, defaultValue: <dynamic>[]) as List<dynamic>;

    return savedItems
        .map((item) => CartItem.fromMap(item as Map<dynamic, dynamic>))
        .toList();
  }

  static bool isInCart({
    required String username,
    required int productId,
  }) {
    final items = getCart(username);

    return items.any((item) => item.productId == productId);
  }

  // tambah produk ke kranjang
  static Future<void> addProduct({
    required String username,
    required Product product,
  }) async {
    final List<CartItem> items = getCart(username);

    // afkh produk udh ada
    final bool alreadyExists =
        items.any((item) => item.productId == product.id);
    if (alreadyExists) {
      return;
    }

    // klo blum ada, tambah produk
    items.add(
      CartItem(
        username: username,
        productId: product.id,
        title: product.title,
        price: product.price,
        thumbnail: product.image,
        quantity: 1,
      ),
    );

    // Simpan ke hive
    await _box.put(
      username,
      items.map((item) => item.toMap()).toList(),
    );
  }

  // hapus produk dri keranjang
  static Future<void> removeProduct({
    required String username,
    required int productId,
  }) async {
    final List<CartItem> items = getCart(username);

    items.removeWhere((item) => item.productId == productId);

    await _box.put(
      username,
      items.map((item) => item.toMap()).toList(),
    );
  }

  static int getCartCount(String username) {
    return getCart(username).length;
  }
}
