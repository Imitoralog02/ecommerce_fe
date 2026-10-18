import '../entities/cart_snapshot.dart';

abstract class CartRepository {
  CartSnapshot load();
  void save(CartSnapshot snapshot);
  CartSnapshot demoCart();
}
