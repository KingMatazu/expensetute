import 'package:expensetute/components/my_list_tile.dart';
import 'package:expensetute/database/expense_database.dart';
import 'package:expensetute/helper/helper_functions.dart';
import 'package:expensetute/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();


  @override
  void initState() {
    // read db on initial startup
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    super.initState();
  }

  // open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //   User input -> expense name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            //   User input -> expense amount
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Amount"),
            ),
          ],
        ),
        actions: [
          //   cancel button
          _cancelButton(),
          //   save button
          _createNewExpenseButton()
        ],
      ),
    );
  }

  // open edit box

  void openEditBox(Expense expense) {
    // pre-fill existing values into text fields
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //   User input -> expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: existingName),
            ),
            //   User input -> expense amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: existingAmount),
            ),
          ],
        ),
        actions: [
          //   cancel button
          _cancelButton(),
          //   save button
          _editExpenseButton(expense),
        ],
      ),
    );
  }

  // open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Expense"),
        actions: [
          //   cancel button
          _cancelButton(),
          //   save button
          _deleteExpenseButton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      // get dates
      // int startMonth = value.getStartMonth();
      // int startYear = value.getStartYear();
      // int currentMonth = DateTime.now().month;
      // int currentYear = DateTime.now().year;

      // calculate the number of months since the first month
      // int monthCount = calculateMonthCount(startYear, startMonth, currentYear, currentMonth);
      // return UI
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpenseBox,
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Expense List
              Expanded(
                child: ListView.builder(
                  itemCount: value.allExpense.length,
                  itemBuilder: (context, index) {
                    //   get individual expense
                    Expense individualExpense = value.allExpense[index];
          
                    //   return list tile UI
                    return MyListTile(
                      title: individualExpense.name,
                      trailing: formatAmount(individualExpense.amount),
                      onEditPressed: (context) => openEditBox(individualExpense),
                      onDeletePressed: (context) =>
                          openDeleteBox(individualExpense),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

//   cancel Button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        //   pop box
        Navigator.pop(context);
        //   clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

// SAVE BUTTON
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        //   only save if there is something in the text field to save
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //   pop box
          Navigator.pop(context);

          //   create new expense
          Expense newExpense = Expense(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              date: DateTime.now());

          //   save to db
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          // refresh graph
          //   clear controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

// SAVE Button -> Edit existing expense
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        // save as long as at least one text field changes
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          // pop box
          Navigator.pop(context);
          // create a new updated expense
          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            amount: amountController.text.isNotEmpty
                ? convertStringToDouble(amountController.text)
                : expense.amount,
            date: DateTime.now(),
          );
          // old expense id
          int existingId = expense.id;
          // save to db
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);
        }
      },
      child: const Text("Save"),
    );
  }

  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        // pop box
        Navigator.pop(context);
        // delete expense from db
        await context.read<ExpenseDatabase>().deleteExpense(id);
      },
      child: const Icon(Icons.delete),
    );
  }
}
