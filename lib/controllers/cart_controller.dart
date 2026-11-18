
import 'package:get/get.dart';

import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartController extends GetxController {
  final String username;

  CartController({required this.username});

  final RxList<CartItem> items = <CartItem>[].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  void loadCart() {
    items.assignAll(
      CartService.getCart(username),
    );
  }

  double get total {
    return items.fold(
      0,
      (sum, item) => sum + item.subtotal,
    );
  }

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
