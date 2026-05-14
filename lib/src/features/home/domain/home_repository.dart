import 'home_snapshot.dart';

abstract class HomeRepository {
  Future<HomeSnapshot> fetchSnapshot();
}
