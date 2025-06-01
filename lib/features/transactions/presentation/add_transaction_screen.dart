import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/animation.dart';
import 'dart:io'; // Added for File
import 'package:image_picker/image_picker.dart'; // Added for ImagePicker
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'; // Added for OCR
import '../../../providers/transaction_provider.dart';
import '../models/transaction.dart'; // Corrected import path

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _payeeController = TextEditingController();
  final List<String> _categories = [
    'General',
    'Food & Groceries',
    'Income',
    'Transportation',
    'Entertainment',
    'Health & Fitness',
    'Shopping',
    'Bills',
    'Other',
  ];
  String? _selectedCategory = 'General';
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  bool _isLoading = false;
  bool _isRecurring = false;
  String _recurringFrequency = 'Monthly';
  final List<String> _recurringOptions = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  // Animation controller
  late AnimationController _animationController;

  // Category icon mapping
  final Map<String, IconData> _categoryIcons = {
    'General': Icons.category,
    'Food & Groceries': Icons.shopping_basket,
    'Income': Icons.attach_money,
    'Transportation': Icons.directions_car,
    'Entertainment': Icons.movie,
    'Health & Fitness': Icons.fitness_center,
    'Shopping': Icons.shopping_cart,
    'Bills': Icons.receipt_long,
    'Other': Icons.more_horiz,
  };

  // OCR and Image Picker instances
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();


  @override
  void initState() {
    super.initState();
    // Autofocus title field on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_titleFocusNode);
    });

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  // Add focus nodes for keyboard navigation
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _payeeFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _payeeController.dispose();
    _titleFocusNode.dispose();
    _amountFocusNode.dispose();
    _noteFocusNode.dispose();
    _payeeFocusNode.dispose();
    _animationController.dispose();
    _textRecognizer.close(); // Dispose TextRecognizer
    super.dispose();
  }

  Future<void> _pickImageAndScan(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected.')),
          );
        }
        return;
      }

      final File imageFile = File(pickedFile.path);
      setState(() => _isLoading = true);

      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      String allRecognizedText = recognizedText.text;
      if (allRecognizedText.isEmpty) {
        allRecognizedText = "No text found in the image.";
      }

      // For now, let's put all recognized text into the notes.
      // And clear other fields that were previously auto-filled by simulation.
      setState(() {
        _noteController.text = allRecognizedText;
        _titleController.clear();
        _amountController.clear();
        _payeeController.clear();
        _selectedCategory = _categories.firstWhere((cat) => cat == 'General', orElse: () => _categories.first);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt scanned. Text added to notes.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageAndScan(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageAndScan(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _scanReceipt() async {
    // Show options to pick from camera or gallery
    _showImageSourceActionSheet(context);
  }

  void _toggleRecurring() {
    setState(() {
      _isRecurring = !_isRecurring;
    });
  }

  void _showBudgetImpact() {
    // This would show a modal with budget impact
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount first')),
      );
      return;
    }

    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Budget Impact',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                LinearProgressIndicator(
                  value:
                      0.7, // This would be calculated from actual budget data
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isExpense ? Colors.orange : Colors.green,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  _isExpense
                      ? 'This expense would use ${(amount / 1000 * 100).toStringAsFixed(1)}% of your monthly budget'
                      : 'This income would add ${(amount / 1000 * 100).toStringAsFixed(1)}% to your monthly income',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Got it'),
                ),
              ],
            ),
          ),
    );
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final title = _titleController.text.trim();
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      // If it's an expense, make the amount negative
      final finalAmount = _isExpense ? -amount : amount;
      final category = _selectedCategory ?? _categories.first;

      // Build an enhanced description that includes payee and recurring info
      final payee = _payeeController.text.trim();
      String description = _noteController.text.trim();

      // Add payee and recurring info to description since the API doesn't support them directly
      if (payee.isNotEmpty) {
        description = "Payee: $payee\n$description";
      }
      if (_isRecurring) {
        description = "$description\n[Recurring: $_recurringFrequency]";
      }

      try {
        // Create a new Transaction using our consolidated model
        final newTransaction = Transaction(
          title: title,
          amount: finalAmount, // finalAmount is already a double
          category: category,
          date: _selectedDate,
        );

        // Using the existing provider method
        final success = await Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).addTransaction(newTransaction);

        if (!mounted) return;

        if (success) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isRecurring
                    ? 'Recurring transaction saved'
                    : 'Transaction saved',
                semanticsLabel:
                    _isRecurring
                        ? 'Recurring transaction saved'
                        : 'Transaction saved',
              ),
              backgroundColor: _isRecurring ? Colors.green.shade700 : null,
            ),
          );
          Navigator.pop(context);
        } else {
          final error =
              Provider.of<TransactionProvider>(context, listen: false).error;
          throw Exception(error ?? 'Failed to save transaction');
        }
      } catch (e) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save transaction: $e',
              semanticsLabel: 'Failed to save transaction',
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.colorScheme.surface : Colors.white;
    final borderColor =
        isDark
            ? theme.dividerColor.withOpacity(0.18)
            : theme.dividerColor.withOpacity(0.10);
    final inputFillColor =
        isDark
            ? theme.colorScheme.surfaceVariant.withOpacity(0.18)
            : theme.colorScheme.surfaceVariant.withOpacity(0.10);
    final now = DateTime.now();
    final isFuture = _selectedDate.isAfter(now);
    final isPast = _selectedDate.isBefore(
      DateTime(now.year, now.month, now.day),
    );

    // For accessibility: semantic labels for all fields/buttons
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Semantics(
            label: 'Add Transaction',
            child: Text(
              'Add Transaction',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          elevation: 0,
          actions: [
            // Budget impact preview button
            Semantics(
              label: 'Budget Impact',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.pie_chart_outline),
                onPressed: _showBudgetImpact,
                tooltip: 'Show Budget Impact',
                color: theme.colorScheme.onBackground,
              ),
            ),
            Semantics(
              label: 'Close',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Close',
                color: theme.colorScheme.onBackground,
              ),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Card(
              elevation: isDark ? 0 : 3,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
                side: BorderSide(color: borderColor, width: 1.2),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              label: 'Transaction Type',
                              child: Text(
                                'Transaction Type',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          // Receipt scan button
                          Semantics(
                            label: 'Scan Receipt',
                            button: true,
                            child: IconButton(
                              icon: const Icon(Icons.document_scanner),
                              onPressed: _scanReceipt,
                              tooltip: 'Scan Receipt',
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                foregroundColor:
                                    theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // Transaction type selector (Expense/Income)
                      Semantics(
                        label:
                            _isExpense ? 'Expense selected' : 'Income selected',
                        toggled: true,
                        child: SizedBox(
                          width: double.infinity, // Make it take full width
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment<bool>(
                                value: true,
                                label: Text('Expense'),
                                icon: Icon(Icons.remove_circle_outline),
                              ),
                              ButtonSegment<bool>(
                                value: false,
                                label: Text('Income'),
                                icon: Icon(Icons.add_circle_outline),
                              ),
                            ],
                            selected: {_isExpense},
                            onSelectionChanged: (Set<bool> newSelection) {
                              setState(() {
                                _isExpense = newSelection.first;
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.selected,
                                    )) {
                                      if (_isExpense) {
                                        return Colors.red.withOpacity(0.13);
                                      } else {
                                        return Colors.green.withOpacity(0.13);
                                      }
                                    }
                                    return inputFillColor;
                                  }),
                              foregroundColor: MaterialStateProperty.all(
                                theme.colorScheme.onSurface,
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              overlayColor: MaterialStateProperty.all(
                                theme.colorScheme.primary.withOpacity(0.08),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Title field
                      Semantics(
                        label: 'Title',
                        textField: true,
                        child: TextFormField(
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                            ),
                            filled: true,
                            fillColor: inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_amountFocusNode);
                          },
                          autofocus: true,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Amount field
                      Semantics(
                        label: 'Amount',
                        textField: true,
                        child: TextFormField(
                          controller: _amountController,
                          focusNode: _amountFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            labelStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                            ),
                            prefixText: '\u0024 ',
                            prefixStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                              color: _isExpense ? Colors.red : Colors.green,
                            ),
                            filled: true,
                            fillColor: inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calculate_outlined),
                              tooltip: 'Show Budget Impact',
                              onPressed: _showBudgetImpact,
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                            color: _isExpense ? Colors.red : Colors.green,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            final parsed = double.tryParse(
                              value.replaceAll(',', '.'),
                            );
                            if (parsed == null) {
                              return 'Please enter a valid number';
                            }
                            if (parsed <= 0) {
                              return 'Amount must be greater than zero';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_payeeFocusNode);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^[0-9]*[.,]?[0-9]{0,2}$'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Payee field
                      Semantics(
                        label: 'Payee',
                        textField: true,
                        child: TextFormField(
                          controller: _payeeController,
                          focusNode: _payeeFocusNode,
                          decoration: InputDecoration(
                            labelText: _isExpense ? 'Payee' : 'Payer',
                            labelStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                            ),
                            filled: true,
                            fillColor: inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.person_outlined),
                          ),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_noteFocusNode);
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Visual category selection
                      Text(
                        'Category',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 120.h, // Increased height to prevent overflow
                        margin: EdgeInsets.only(
                          bottom: 4.h,
                        ), // Added bottom margin
                        child: GridView.builder(
                          physics:
                              const BouncingScrollPhysics(), // Added physics for better scrolling
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8.w,
                                crossAxisSpacing: 8.h,
                                childAspectRatio: 1 / 1,
                              ),
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = _selectedCategory == category;
                            return Semantics(
                              label: category,
                              selected: isSelected,
                              child: GestureDetector(
                                onTap:
                                    () => setState(
                                      () => _selectedCategory = category,
                                    ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? theme.colorScheme.primaryContainer
                                            : inputFillColor,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? theme.colorScheme.primary
                                              : borderColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize:
                                        MainAxisSize
                                            .min, // Important: minimize the column's height
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _categoryIcons[category] ??
                                            Icons.category,
                                        color:
                                            isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.onSurface
                                                    .withOpacity(0.7),
                                        size: 22.sp, // Slightly smaller icon
                                      ),
                                      SizedBox(height: 4.h), // Reduce spacing
                                      Flexible(
                                        // Wrap text in Flexible
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 9.sp, // Smaller font
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                            color:
                                                isSelected
                                                    ? theme.colorScheme.primary
                                                    : theme
                                                        .colorScheme
                                                        .onSurface,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1, // Force single line
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Recurring transaction toggle
                      SwitchListTile(
                        title: Text(
                          'Recurring Transaction',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          _isRecurring
                              ? 'This transaction will repeat $_recurringFrequency'
                              : 'One-time transaction',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: _isRecurring,
                        onChanged: (value) => _toggleRecurring(),
                        secondary: Icon(
                          _isRecurring ? Icons.repeat : Icons.repeat_one,
                          color:
                              _isRecurring
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: theme.colorScheme.primary,
                      ),

                      // Recurring frequency options
                      if (_isRecurring)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(top: 8.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: inputFillColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Repeat Frequency',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.sp,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Wrap(
                                spacing: 8.w,
                                children:
                                    _recurringOptions.map((frequency) {
                                      final isSelected =
                                          _recurringFrequency == frequency;
                                      return ChoiceChip(
                                        label: Text(frequency),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          if (selected) {
                                            setState(
                                              () =>
                                                  _recurringFrequency =
                                                      frequency,
                                            );
                                          }
                                        },
                                        backgroundColor: inputFillColor,
                                        selectedColor:
                                            theme.colorScheme.primaryContainer,
                                        labelStyle: TextStyle(
                                          color:
                                              isSelected
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.onSurface,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 16.h),

                      // Note field
                      Semantics(
                        label: 'Note (optional)',
                        textField: true,
                        child: TextFormField(
                          controller: _noteController,
                          focusNode: _noteFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Note (optional)',
                            labelStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                            ),
                            hintText: 'Add any additional details',
                            filled: true,
                            fillColor: inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.sticky_note_2_outlined,
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                          ),
                          maxLines: 2,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                            // Attempt to save when done typing note
                            if (_formKey.currentState?.validate() ?? false) {
                              _saveTransaction();
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Date picker
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              label: 'Date',
                              child: Text(
                                // Use locale-aware date formatting
                                'Date:  ${MaterialLocalizations.of(context).formatMediumDate(_selectedDate)}',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.sp,
                                  color:
                                      isPast
                                          ? Colors.red.shade700
                                          : isFuture
                                          ? Colors.green.shade700
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.8),
                                  fontWeight:
                                      isPast || isFuture
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          Semantics(
                            label: 'Pick Date',
                            button: true,
                            child: TextButton.icon(
                              onPressed: _pickDate,
                              icon: Icon(
                                Icons.calendar_today_outlined,
                                color: theme.colorScheme.primary,
                                size: 20.sp,
                              ),
                              label: Text(
                                'Pick Date',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.sp,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: AnimatedScale(
                          scale: _isLoading ? 0.97 : 1.0,
                          duration: const Duration(milliseconds: 120),
                          child: Semantics(
                            label:
                                _isLoading ? 'Saving...' : 'Save Transaction',
                            button: true,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          HapticFeedback.mediumImpact();
                                          _saveTransaction();
                                        } else {
                                          HapticFeedback.vibrate();
                                        }
                                      },
                              icon:
                                  _isLoading
                                      ? SizedBox(
                                        width: 20.w,
                                        height: 20.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      )
                                      : const Icon(Icons.save_alt_rounded),
                              label: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  _isLoading ? 'Saving...' : 'Save Transaction',
                                  key: ValueKey(_isLoading),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: isDark ? 0 : 2,
                                shadowColor:
                                    isDark
                                        ? Colors.transparent
                                        : theme.shadowColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Clear form button
                      if (!_isLoading)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              _formKey.currentState?.reset();
                              _titleController.clear();
                              _amountController.clear();
                              _noteController.clear();
                              _payeeController.clear();
                              setState(() {
                                _selectedCategory = _categories.first;
                                _selectedDate = DateTime.now();
                                _isExpense = true;
                                _isRecurring = false;
                                _recurringFrequency = 'Monthly';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Form cleared'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.secondary,
                            ),
                            child: Text(
                              'Clear Form',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
