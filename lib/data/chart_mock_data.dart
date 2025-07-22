// mock_data.dart

class Order {
  final DateTime date;
  final double amount;

  Order({required this.date, required this.amount});
}

class ProductSales {
  final String name;
  final int sales;

  ProductSales({required this.name, required this.sales});
}

class User {
  final DateTime joinedDate;

  User({required this.joinedDate});
}

final List<Order> mockOrders = [
  Order(date: DateTime.now().subtract(Duration(days: 6)), amount: 200),
  Order(date: DateTime.now().subtract(Duration(days: 5)), amount: 300),
  Order(date: DateTime.now().subtract(Duration(days: 4)), amount: 280),
  Order(date: DateTime.now().subtract(Duration(days: 3)), amount: 500),
  Order(date: DateTime.now().subtract(Duration(days: 2)), amount: 450),
  Order(date: DateTime.now().subtract(Duration(days: 1)), amount: 700),
  Order(date: DateTime.now(), amount: 650),
];

final List<ProductSales> mockProducts = [
  ProductSales(name: 'Product A', sales: 80),
  ProductSales(name: 'Product B', sales: 60),
  ProductSales(name: 'Product C', sales: 75),
  ProductSales(name: 'Product D', sales: 50),
  ProductSales(name: 'Product E', sales: 90),
];

final List<User> mockUsers = [
  for (int i = 0; i < 50; i++)
    User(joinedDate: DateTime.now().subtract(Duration(days: i * 3))),
];
