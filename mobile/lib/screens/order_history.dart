import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:trinity/utils/api/history.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;
import 'package:trinity/screens/order_details_page.dart';
import 'package:provider/provider.dart';
import 'package:trinity/stores/user_store.dart';
import 'package:trinity/config/routes.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trinity/theme/app_colors.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  DateTime? selectedDate;
  List<dynamic> orderHistory = [];
  List<dynamic> filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    final userStore = Provider.of<UserStore>(context, listen: false);
    if (!userStore.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Vous devez être connecté pour accéder à l'historique.",
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        AppRoutes.of(context).navigateTo(AppRoutes.login);
      });
    } else {
      // User is authenticated, fetch order history
      _fetchOrderHistory();
    }
  }

  Future<void> _fetchOrderHistory() async {
    try {
      final historyApi = HistoryApi();
      final response = await historyApi.getOrderHistory();

      if (response.statusCode == 200) {
        setState(() {
          orderHistory = response.data;
          filteredOrders = orderHistory;
        });
      } else {
        throw Exception('Failed to load order history');
      }
    } on DioException catch (e) {
      debugPrint(
        "Erreur lors du chargement de l'historique des commandes: ${e.message}",
      );
    }
  }

  void _filterOrdersByDate(DateTime selectedDate) {
    setState(() {
      filteredOrders = orderHistory.where((order) {
        DateTime orderDate = DateTime.parse(order['date']);
        return orderDate.year == selectedDate.year &&
            orderDate.month == selectedDate.month &&
            orderDate.day == selectedDate.day;
      }).toList();

      // Show feedback if no orders found for the selected date
      if (filteredOrders.isEmpty && orderHistory.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Aucune commande trouvée pour le ${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}',
            ),
            backgroundColor: Colors.amber.shade800,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Effacer le filtre',
              textColor: Colors.black,
              onPressed: () {
                setState(() {
                  selectedDate = DateTime.now();
                  filteredOrders = orderHistory;
                });
              },
            ),
          ),
        );
      }
    });
  }

  String _convertUtcToLocal(String utcDate) {
    DateTime utcDateTime = DateTime.parse(utcDate);
    DateTime localDateTime = utcDateTime.toLocal();

    final DateFormat dateFormat = DateFormat("dd MMM yyyy à HH:mm");
    return dateFormat.format(localDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.background,
        title: const Text(
          'Historique des commandes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Date picker card
            Card(
              color: Colors.grey.shade800,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade600, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filtrer par date",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _showDatePickerDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade500),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              lucide.LucideIcons.calendar,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate == null
                                  ? "Sélectionner une date"
                                  : "${selectedDate!.day} ${_getMonthName(selectedDate!.month)} ${selectedDate!.year}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              lucide.LucideIcons.chevronDown,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (selectedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: ShadButton(
                          size: ShadButtonSize.sm,
                          onPressed: () {
                            setState(() {
                              selectedDate = null;
                              filteredOrders = orderHistory;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(lucide.LucideIcons.x, size: 16),
                              const SizedBox(width: 4),
                              const Text("Effacer le filtre"),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Orders section title
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
              child: Row(
                children: [
                  Icon(lucide.LucideIcons.shoppingBag, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    "Vos commandes",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Orders list or empty state
            Expanded(
              child: orderHistory.isEmpty
                  ? _buildEmptyHistoryState()
                  : filteredOrders.isEmpty
                      ? _buildNoOrdersForDateState()
                      : _buildOrdersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            lucide.LucideIcons.packageX,
            size: 64,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 16),
          Text(
            "Aucune commande trouvée",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Vos commandes apparaîtront ici une fois effectuées",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildNoOrdersForDateState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            lucide.LucideIcons.calendarX,
            size: 64,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 16),
          Text(
            "Aucune commande pour cette date",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Essayez une autre date ou effacez le filtre",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.grey.shade800,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade700, width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsPage(orderId: order['id']),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        lucide.LucideIcons.receipt,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Commande #${order['id'].toString().substring(0, 8)}...",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            lucide.LucideIcons.calendar,
                            color: Colors.grey.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _convertUtcToLocal(order['date']),
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (order['subtotalPrice'] != null &&
                              order['totalVatPrice'] != null &&
                              order['subtotalPrice'] > order['totalVatPrice'])
                            Text(
                              "${order['subtotalPrice']} €",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade800,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              "${order['totalPrice'].toStringAsFixed(2)} €",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (order['subtotalPrice'] != null &&
                      order['totalVatPrice'] != null &&
                      order['subtotalPrice'] > order['totalVatPrice'])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            lucide.LucideIcons.tag,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Économie: ${(order['subtotalPrice'] - order['totalVatPrice']).toStringAsFixed(2)} €",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailsPage(orderId: order['id']),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(lucide.LucideIcons.eye, size: 16),
                            const SizedBox(width: 4),
                            const Text("Voir détails"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return monthNames[month - 1];
  }

  void _showDatePickerDialog(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.amber,
              onPrimary: Colors.black,
              surface: Colors.grey.shade800,
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.amber),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        _filterOrdersByDate(pickedDate);
      });
    }
  }
}
