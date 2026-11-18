
import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import 'detail_screen.dart';

class CartScreen extends StatefulWidget {
  final String username;

  const CartScreen({
    super.key,
    required this.username,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> items;

  final ProductService _productService = ProductService();

  final Map<int, Future<Product>> _productDetails = {};

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  void loadCart() {
    items = CartService.getCart(widget.username);

    for (final item in items) {
      _productDetails.putIfAbsent(
        item.productId,
        () => _productService.getProductById(item.productId),
      );
    }
  }

  Future<void> deleteItem(int productId) async {
    await CartService.removeProduct(
      username: widget.username,
      productId: productId,
    );

    if (!mounted) return;

    setState(() {
      items.removeWhere((item) => item.productId == productId);
      _productDetails.remove(productId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produk berhasil dihapus dari keranjang'),
      ),
    );
  }

  Future<void> openDetail(CartItem item) async {
    try {
      final product = await (_productDetails[item.productId] ??
          _productService.getProductById(item.productId));

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            product: product,
            username: widget.username,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka detail produk'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double total = items.fold(
      0,
      (sum, item) => sum + item.subtotal,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
      ),

      body: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text('Keranjang kamu masih kosong.'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final CartItem item = items[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => openDetail(item),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.thumbnail,
                                    width: 90,
                                    height: 110,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Container(
                                        width: 90,
                                        height: 110,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      FutureBuilder<Product>(
                                        future: _productDetails[item.productId],
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text(
                                              'Memuat rating...',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            );
                                          }

                                          if (snapshot.hasError ||
                                              !snapshot.hasData) {
                                            return const Text(
                                              'Rating tidak tersedia',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            );
                                          }

                                          final rating =
                                              snapshot.data!.rating;

                                          return Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${rating.rate} (${rating.count} ulasan)',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        'Quantity: ${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      const Text(
                                        'Ketuk untuk melihat detail',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  tooltip: 'Hapus produk',
                                  onPressed: () =>
                                      deleteItem(item.productId),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  color: Colors.white,
                  child: Text(
                    'Total: \$${total.toStringAsFixed(2)}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
