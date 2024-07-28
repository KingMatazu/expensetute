import 'package:expensetute/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Expense> _allExpenses = [];

  /*

  SETUP

  */
  // INITIALIZE DB
  
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  /*

  GETTERS

  */
  
  List<Expense> get allExpense => _allExpenses;

  /*

  OPERATIONS

  */
  
  // Create
  
  Future<void> createNewExpense(Expense newExpense) async {
    // Add to db
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    // Re-read from db
    await readExpenses();
  }

  // Read
  Future<void> readExpenses() async {
    // fetch all existing expenses from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    // give to local expenses list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    // update UI
    notifyListeners();
  }

  // Update
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    // make sure new expense has same id as existing one
    updatedExpense.id = id;

    // update in db
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    // re-read from db
    await readExpenses();
  }

  // Delete
  Future<void> deleteExpense(int id) async {
    // delete from db
    await isar.writeTxn(() => isar.expenses.delete(id));

    // re-read from db
    await readExpenses();
  }


  /* H E L P E R */
  // Calculate total expense for each month
  Future<Map<int, double>> calculateMonthlyTotals() async{
    // ensure theexpense are read from the db
    await readExpenses();
    // create a map to keep track of total expenses per month
    Map<int, double> monthlyTotals = {};

    // iterate over all expenses
    for (var expense in _allExpenses) {
      // extract the month from the date of the expense
      int month = expense.date.month;
      // if the month is not yet in the map, initialize to 0
      if (!monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = 0;
      }
      // add th eexpense amount to the total for the month
      monthlyTotals[month] = monthlyTotals[month]! + expense.amount;
    }

    return monthlyTotals;
  }

  // get start month
  int getStartMonth(){
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
      // Default to current month is no expesenses are recorded
    }
    // sort expenses by date to find the earliest
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.month;
  }

  // get start year
  int getStartYear(){
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
      // Default to current year is no expesenses are recorded
    }
    // sort expenses by date to find the earliest
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.year;
  }

}