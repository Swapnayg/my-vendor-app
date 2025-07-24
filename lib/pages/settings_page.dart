import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/models/bank_account.dart'; // Your BankAccount model file

class SettingsPage extends StatefulWidget {
  final BankAccount? existingAccount; // null means create, non-null means edit

  const SettingsPage({super.key, this.existingAccount});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _upiIdController = TextEditingController();

  File? _upiQrFile;

  @override
  void initState() {
    super.initState();
    if (widget.existingAccount != null) {
      final account = widget.existingAccount!;
      _accountHolderController.text = account.accountHolder;
      _accountNumberController.text = account.accountNumber;
      _ifscCodeController.text = account.ifscCode;
      _bankNameController.text = account.bankName;
      _branchNameController.text = account.branchName ?? '';
      _upiIdController.text = account.upiId ?? '';
      if (account.upiQrUrl != null && account.upiQrUrl!.isNotEmpty) {
        _upiQrFile = File(account.upiQrUrl!);
      }
    }
  }

  Future<void> _pickUpiQrFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _upiQrFile = File(result.files.single.path!);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newAccount = BankAccount(
        id: widget.existingAccount?.id ?? 0,
        vendorId:
            widget.existingAccount?.vendorId ?? 0, // set vendorId properly
        accountHolder: _accountHolderController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        ifscCode: _ifscCodeController.text.trim(),
        bankName: _bankNameController.text.trim(),
        branchName:
            _branchNameController.text.trim().isEmpty
                ? null
                : _branchNameController.text.trim(),
        upiId:
            _upiIdController.text.trim().isEmpty
                ? null
                : _upiIdController.text.trim(),
        upiQrUrl: _upiQrFile?.path,
        createdAt: widget.existingAccount?.createdAt ?? DateTime.now(),
      );

      // TODO: Call API to save or update this model
      print('Saving Bank Account: $newAccount');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Bank Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Account Name',
                _accountHolderController,
                Icons.person_outline,
              ),
              _buildTextField(
                'Account Number',
                _accountNumberController,
                Icons.credit_card,
                TextInputType.number,
              ),
              _buildTextField(
                'IFSC Code',
                _ifscCodeController,
                Icons.qr_code_scanner,
              ),
              _buildTextField(
                'Bank Name',
                _bankNameController,
                Icons.account_balance,
              ),
              _buildTextField(
                'Branch Name',
                _branchNameController,
                Icons.location_city,
              ),
              _buildTextField(
                'UPI ID',
                _upiIdController,
                Icons.alternate_email,
              ),
              const SizedBox(height: 16),
              _buildFilePickerTile(
                'Upload UPI QR Code',
                _upiQrFile,
                _pickUpiQrFile,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.existingAccount == null
                      ? 'Submit Bank Details'
                      : 'Update Bank Details',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator:
            (value) =>
                (value == null || value.trim().isEmpty)
                    ? 'Required field'
                    : null,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildFilePickerTile(String title, File? file, VoidCallback onPick) {
    return ListTile(
      onTap: onPick,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      title: Text(title),
      subtitle: Text(
        file != null ? file.path.split('/').last : 'No file selected.',
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
