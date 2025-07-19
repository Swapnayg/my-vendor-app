import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_vendor_app/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class AddProductPage extends StatefulWidget {
  final bool isEditMode;
  final Map<String, dynamic>? initialData;

  const AddProductPage({super.key, this.isEditMode = false, this.initialData});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<String> _imageUrls = [];

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dhas7vy3k';
    const uploadPreset = 'vendors';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final jsonResponse = json.decode(resStr);
      return jsonResponse['secure_url'];
    } else {
      debugPrint('Failed to upload: ${response.statusCode}');
      return null;
    }
  }

  String? _name;
  String? _description;
  double? _basePrice;
  double? _taxRate;
  double? _price;
  int? _vendorId;
  int? _categoryId;
  List<File> _images = [];
  List<Map<String, dynamic>> _complianceList = [];

  final List<Map<String, dynamic>> _vendors = [
    {'id': 1, 'name': 'Vendor A'},
    {'id': 2, 'name': 'Vendor B'},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Electronics'},
    {'id': 2, 'name': 'Books'},
    {'id': 3, 'name': 'Fashion'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode && widget.initialData != null) {
      final data = widget.initialData!;
      _name = data['name'];
      _description = data['description'];
      _price = data['price'];
      _basePrice = data['basePrice'];
      _taxRate = data['taxRate'];
      _vendorId = data['vendorId'];
      _categoryId = data['categoryId'];
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      debugPrint('Product Name: $_name');
      debugPrint('Description: $_description');
      debugPrint('Price: $_price');
      debugPrint('Base Price: $_basePrice');
      debugPrint('Tax Rate: $_taxRate');
      debugPrint('Vendor: $_vendorId');
      debugPrint('Category: $_categoryId');
      debugPrint('Status: PENDING');
      debugPrint('Images: ${_images.length}');
    }
  }

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          final localFile = File(file.path!);
          final uploadedUrl = await uploadImageToCloudinary(localFile);
          if (uploadedUrl != null) {
            setState(() {
              _imageUrls.add(uploadedUrl);
            });
          } else {
            _showError('Upload failed for ${file.name}');
          }
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _pickComplianceFile(int index) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _complianceList[index]['file'] = File(result.files.single.path!);
      });
    }
  }

  void _addComplianceField() {
    setState(() {
      _complianceList.add({'name': '', 'file': null});
    });
  }

  Widget _imagePreviewGrid() {
    return Column(
      children: [
        if (_imageUrls.isEmpty)
          InkWell(
            onTap: _pickImages,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                // border: Border.all(color: Colors.grey),
                // borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
              ),
              child: const Icon(
                Icons.cloud_upload,
                color: AppColors.primary,
                size: 40,
              ),
            ),
          ),
        if (_imageUrls.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._imageUrls.map(
                (url) => Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: Image.network(url, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          size: 18,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() => _imageUrls.remove(url));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (_imageUrls.length < 5)
                InkWell(
                  onTap: _pickImages,
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.cloud_upload,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Product' : 'Add Product'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator:
                      (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _name = val,
                ),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator:
                      (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _description = val,
                ),
                TextFormField(
                  initialValue: _basePrice?.toString(),
                  decoration: const InputDecoration(labelText: 'Base Price'),
                  keyboardType: TextInputType.number,
                  validator:
                      (val) =>
                          val == null || double.tryParse(val) == null
                              ? 'Enter valid Base Price'
                              : null,
                  onSaved: (val) => _basePrice = double.tryParse(val!),
                ),
                TextFormField(
                  initialValue: _taxRate?.toString(),
                  decoration: const InputDecoration(labelText: 'Tax Rate'),
                  keyboardType: TextInputType.number,
                  validator:
                      (val) =>
                          val == null || double.tryParse(val) == null
                              ? 'Enter valid Tax Rate'
                              : null,
                  onSaved: (val) => _taxRate = double.tryParse(val!),
                ),
                TextFormField(
                  initialValue: _price?.toString(),
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator:
                      (val) =>
                          val == null || double.tryParse(val) == null
                              ? 'Enter valid price'
                              : null,
                  onSaved: (val) => _price = double.tryParse(val!),
                ),
                DropdownButtonFormField<int>(
                  value: _vendorId,
                  decoration: const InputDecoration(labelText: 'Vendor'),
                  items:
                      _vendors
                          .map(
                            (v) => DropdownMenuItem<int>(
                              value: v['id'],
                              child: Text(v['name']),
                            ),
                          )
                          .toList(),
                  validator: (val) => val == null ? 'Select vendor' : null,
                  onChanged: (val) => setState(() => _vendorId = val),
                ),
                DropdownButtonFormField<int>(
                  value: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      _categories
                          .map(
                            (c) => DropdownMenuItem<int>(
                              value: c['id'],
                              child: Text(c['name']),
                            ),
                          )
                          .toList(),
                  validator: (val) => val == null ? 'Select category' : null,
                  onChanged: (val) => setState(() => _categoryId = val),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Upload Product Images (Max 5)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Center(child: _imagePreviewGrid()),

                const SizedBox(height: 32),
                const Text(
                  'Compliance Documents (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._complianceList.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> comp = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: comp['name'],
                            decoration: const InputDecoration(
                              labelText: 'Compliance Name',
                            ),
                            onChanged:
                                (val) => _complianceList[index]['name'] = val,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _pickComplianceFile(index),
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Pick File'),
                              ),
                              const SizedBox(width: 8),
                              if (comp['file'] != null)
                                Expanded(
                                  child: Text(
                                    (comp['file'] as File).path.split('/').last,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed:
                              () => setState(() {
                                _complianceList.removeAt(index);
                              }),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                TextButton.icon(
                  onPressed: _addComplianceField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Compliance'),
                ),

                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: _submit,
                    child: Text(
                      widget.isEditMode ? 'Update Product' : 'Add Product',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
