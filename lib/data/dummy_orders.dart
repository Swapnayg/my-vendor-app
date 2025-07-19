import '../models/order.dart';
import '../models/order_item.dart';
import '../models/payment.dart';

final dummyOrders = [
  Order(
    id: 1001,
    customerId: 1,
    vendorId: 1,
    status: OrderStatus.PENDING,
    subTotal: 200,
    taxTotal: 36,
    shippingCharge: 10,
    shippingTax: 1.8,
    discount: 0,
    total: 247.8,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    items: [
      OrderItem(
        id: 1,
        orderId: 1001,
        productId: 101,
        quantity: 2,
        basePrice: 100,
        taxRate: 18,
        taxAmount: 36,
        price: 236,
        commissionPct: 10,
        commissionAmt: 23.6,
      ),
    ],

    payment: Payment(
      id: 1,
      amount: 247.8,
      method: 'Credit Card',
      status: PaymentStatus.PAID,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      orderId: 1001,
    ),
  ),
  Order(
    id: 1002,
    customerId: 2,
    vendorId: 1,
    status: OrderStatus.DELIVERED,
    subTotal: 150,
    taxTotal: 27,
    shippingCharge: 5,
    shippingTax: 0.9,
    discount: 10,
    total: 172.9,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    items: [
      OrderItem(
        id: 1,
        orderId: 1001,
        productId: 101,
        quantity: 2,
        basePrice: 100,
        taxRate: 18,
        taxAmount: 36,
        price: 236,
        commissionPct: 10,
        commissionAmt: 23.6,
      ),
    ],
    payment: Payment(
      id: 2,
      amount: 172.9,
      method: 'UPI',
      status: PaymentStatus.REFUNDED,
      orderId: 1002,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ),
];
