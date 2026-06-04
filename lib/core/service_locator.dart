import 'package:get_it/get_it.dart';
import '../data/repositories/interfaces/catalog_repository.dart';
import '../data/repositories/interfaces/cart_repository.dart';
import '../data/repositories/interfaces/auth_repository.dart';
import '../data/repositories/implementations/catalog_repository_impl.dart';
import '../data/repositories/implementations/cart_repository_impl.dart';
import '../data/repositories/implementations/auth_repository_impl.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Register repositories
  getIt.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(),
  );

  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );
}
