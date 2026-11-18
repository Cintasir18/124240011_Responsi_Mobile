
import 'package:hive/hive.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  static Box get _box => Hive.box('cart');

  // Mengambil semua produk dalam keranjang berdasarkan username
  static List<CartItem> getCart(String username) {
    final List<dynamic> savedItems =
        _box.get(username, defaultValue: <dynamic>[]) as List<dynamic>;

    return savedItems
        .map((item) => CartItem.fromMap(item as Map<dynamic, dynamic>))
        .toList();
  }

  // Mengecek apakah produk sudah ada di keranjang
  static bool isInCart({
    required String username,
    required int productId,
  }) {
    final items = getCart(username);

    return items.any((item) => item.productId == productId);
  }

  // Menambahkan produk ke keranjang
  static Future<void> addProduct({
    required String username,
    required Product product,
  }) async {
    final List<CartItem> items = getCart(username);

    // Cek apakah produk sudah ada
    final bool alreadyExists =
        items.any((item) => item.productId == product.id);

    // Jika sudah ada, tidak perlu ditambahkan lagi
    if (alreadyExists) {
      return;
    }

    // Jika belum ada, tambahkan produk baru
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

    // Simpan ke Hive
    await _box.put(
      username,
      items.map((item) => item.toMap()).toList(),
    );
  }

  // Menghapus produk dari keranjang
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

  // Menghitung jumlah produk dalam keranjang
  static int getCartCount(String username) {
    return getCart(username).length;
  }
}
