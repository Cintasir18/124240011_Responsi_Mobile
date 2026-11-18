
import 'package:get/get.dart';

import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartController extends GetxController {
  final String username;

  CartController({required this.username});

  // Daftar produk keranjang yang reaktif
  final RxList<CartItem> items = <CartItem>[].obs;

  // Status loading
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  // Mengambil data keranjang dari Hive
  void loadCart() {
    items.assignAll(
      CartService.getCart(username),
    );
  }

  // Menghitung total harga
  double get total {
    return items.fold(
      0,
      (sum, item) => sum + item.subtotal,
    );
  }

  // Menghapus produk dari keranjang
  Future<void> deleteItem(int productId) async {
    await CartService.removeProduct(
      username: username,
      productId: productId,
    );

    items.removeWhere(
      (item) => item.productId == productId,
    );

    Get.snackbar(
      'Berhasil',
      'Produk berhasil dihapus dari keranjang',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
