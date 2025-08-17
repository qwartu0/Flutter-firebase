import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  List<Transaction> _transactions = [];
  bool _isOffline = false;
  bool _isSyncing = false;

  List<Transaction> get transactions => _transactions;
  bool get isOffline => _isOffline;
  bool get isSyncing => _isSyncing;

  Future<void> checkConnection() async {
    _isOffline = !(await InternetConnectionChecker().hasConnection);
    notifyListeners();
  }

  Future<void> fetchTransactions(String userId) async {
    try {
      await checkConnection();

      setState(() => _isSyncing = true);

      final source = _isOffline ? firestore.Source.cache : firestore.Source.server;

      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get(firestore.GetOptions(source: source));

      _transactions = snapshot.docs
          .map((doc) => Transaction.fromMap(doc.id, doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching transactions: $e');
      rethrow;
    } finally {
      setState(() => _isSyncing = false);
    }
  }


  Future<void> addTransaction(Transaction transaction) async {
    try {
      await checkConnection();
      setState(() => _isSyncing = true);

      final docRef = await _firestore.collection('transactions').add(transaction.toMap());
      final newTransaction = transaction.copyWith(id: docRef.id);
      _transactions.insert(0, newTransaction);

      notifyListeners();

      if (!_isOffline) {
        await docRef.snapshots().firstWhere((snap) => !snap.metadata.hasPendingWrites);
      }
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await checkConnection();
      setState(() => _isSyncing = true);

      final docRef = _firestore.collection('transactions').doc(transaction.id);
      await docRef.update(transaction.toMap());

      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }

      if (!_isOffline) {
        await docRef.snapshots().firstWhere((snap) => !snap.metadata.hasPendingWrites);
      }
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await checkConnection();
      setState(() => _isSyncing = true);

      final docRef = _firestore.collection('transactions').doc(transactionId);
      await docRef.delete();

      _transactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();

      if (!_isOffline) {
        await docRef.snapshots().firstWhere((snap) => !snap.metadata.hasPendingWrites);
      }
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  void setState(void Function() fn) {
    fn();
    notifyListeners();
  }
}