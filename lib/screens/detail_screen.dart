
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  final String username;

  const DetailScreen({
    super.key,
    required this.product,
    required this.username,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Product> productFuture;

  bool isInCart = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    productFuture = ProductService().getProductById(
      widget.product.id,
    );

    isInCart = CartService.isInCart(
      username: widget.username,
      productId: widget.product.id,
    );
  }

  Future<void> addToCart(Product product) async {
    setState(() {
      isSaving = true;
    });

    try {
      await CartService.addProduct(
        username: widget.username,
        product: product,
      );

      if (!mounted) return;

      setState(() {
        isInCart = true;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil ditambahkan ke keranjang!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menambahkan produk ke keranjang.'),
        ),
      );
    }
  }

  void openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          username: widget.username,
        ),
      ),
    ).then((_) {
      if (!mounted) return;

      setState(() {
        isInCart = CartService.isInCart(
          username: widget.username,
          productId: widget.product.id,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        actions: [
          IconButton(
            onPressed: openCart,
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),

      body: FutureBuilder<Product>(
        future: productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 50,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  const Text('Gagal memuat detail produk.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        productFuture =
                            ProductService().getProductById(
                          widget.product.id,
                        );
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final Product product = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      size: 60,
                      color: AppColors.secondary,
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              Text(
                product.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                product.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    product.rating.rate.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${product.rating.count} reviews)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Divider(color: AppColors.card),

              const SizedBox(height: 12),

              const Text(
                'Deskripsi Produk',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                product.description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: AppColors.muted,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSaving || isInCart
                      ? null
                      : () => addToCart(product),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInCart
                        ? Colors.grey
                        : AppColors.primary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: isInCart
                        ? Colors.grey
                        : AppColors.secondary,
                    disabledForegroundColor: AppColors.white,
                  ),

                  icon: Icon(
                    isInCart
                        ? Icons.check_circle_outline
                        : Icons.shopping_bag_outlined,
                  ),

                  label: Text(
                    isSaving
                        ? 'Menambahkan...'
                        : isInCart
                            ? 'Sudah di Keranjang'
                            : 'Masukkan ke Keranjang',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
