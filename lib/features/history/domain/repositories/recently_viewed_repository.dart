import '../../../home/domain/entities/product_entity.dart';

abstract class RecentlyViewedRepository {
  List<ProductEntity> load();
  void save(List<ProductEntity> items);
}
