class AppConfig {
  static const String productURL = 'https://fakestoreapi.com/products/';
  static String detailURL(int productId) {
    return 'https://fakestoreapi.com/products/$productId';
  }
}
