import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../models/transaction.dart';

class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    if (authProvider.user != null) {
      transactionProvider.fetchTransactions(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;
    final allTransactions = transactionProvider.transactions;

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showTransactionForm(context, transactionProvider, userId),
          ),
        ],
      ),
      body: allTransactions.isEmpty
          ? Center(child: Text('No transactions yet.'))
          : ListView.builder(
        itemCount: allTransactions.length,
        itemBuilder: (context, index) {
          final transaction = allTransactions[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(_getCategoryIcon(transaction.category)),
              ),
              title: Text(transaction.title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${transaction.amount.toStringAsFixed(2)} \$ - ${transaction.date.toString().substring(0, 10)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showTransactionForm(context, transactionProvider, userId, transaction: transaction),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await transactionProvider.deleteTransaction(transaction.id);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.fastfood;
      case 'transport': return Icons.directions_car;
      case 'shopping': return Icons.shopping_bag;
      case 'entertainment': return Icons.movie;
      case 'bills': return Icons.receipt;
      default: return Icons.money;
    }
  }

  void _showTransactionForm(BuildContext context, TransactionProvider provider, String? userId, {Transaction? transaction}) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: transaction?.title ?? '');
    final amountController = TextEditingController(text: transaction?.amount.toString() ?? '');
    final categoryController = TextEditingController(text: transaction?.category ?? 'Food');
    final dateController = TextEditingController(text: transaction?.date.toString().substring(0, 10) ?? DateTime.now().toString().substring(0, 10));
    final descriptionController = TextEditingController(text: transaction?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction == null ? 'Add Transaction' : 'Edit Transaction'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
                ),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter amount';
                    if (double.tryParse(value) == null) return 'Enter valid number';
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: categoryController.text,
                  items: ['Food', 'Transport', 'Shopping', 'Entertainment', 'Bills', 'Other']
                      .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
                      .toList(),
                  onChanged: (value) => categoryController.text = value!,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: transaction?.date ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      dateController.text = date.toString().substring(0, 10);
                    }
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description (optional)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text(transaction == null ? 'Add' : 'Save'),
            onPressed: () async {
              if (formKey.currentState!.validate() && userId != null) {
                final newTransaction = Transaction(
                  id: transaction?.id ?? '',
                  title: titleController.text,
                  amount: double.parse(amountController.text),
                  category: categoryController.text,
                  date: DateTime.parse(dateController.text),
                  userId: userId,
                  description: descriptionController.text.isEmpty ? null : descriptionController.text,
                );

                if (transaction == null) {
                  await provider.addTransaction(newTransaction);
                } else {
                  await provider.updateTransaction(newTransaction);
                }
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}