// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:budget_tracker/failure_error.dart';
import 'package:budget_tracker/items.dart';
import 'package:budget_tracker/budgetRepo.dart';
import 'package:budget_tracker/spending.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Future<List<Item>> _futureItems;

  @override
  void initState() {
    super.initState();
    _futureItems = BudgetRepo().getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _futureItems = BudgetRepo().getItems();
          setState(() {});
        },
        child: FutureBuilder<List<Item>>(
          future: _futureItems,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Show pie chart and list view of items.
              final items = snapshot.data!;
              return ListView.builder(
                itemCount: items.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) return SpendingChart(items: items);

                  final item = items[index - 1];
                  return Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all (
                        width: 2,
                        color: getCategoryColor(item.category)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.category} • ${DateFormat.yMd().format(item.date)}'
                      ),
                      trailing: Text(
                        '-\$${item.price.toStringAsFixed(2)}',
                      ),
                    ),
                  );
                }
                );
            } else if (snapshot.hasError) {
              // Show failure error message.
              final failure = snapshot.error as Failure;
              return Center(child: Text(failure.message));
            }
            // Show a loading spinner.
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'Entertainment':
      return Colors.red[400]!;
    case 'Food':
      return Colors.green[400]!;
    case 'Discretionary':
      return Colors.blue[400]!;
    case 'Transportation':
      return Colors.purple[400]!;
    case 'Rent':
      return Colors.orange[400]!;
    default: 
      return Colors.blueGrey[400]!;
  }
}