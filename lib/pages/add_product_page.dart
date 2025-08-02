// Same imports
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:my_vendor_app/common/common_layout.dart';
import 'package:my_vendor_app/models/product.dart';
import 'package:my_vendor_app/models/product_category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddProductPage extends StatefulWidget {
  final Product? initialData;

  const AddProductPage({super.key, this.initialData});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  late String _name;
  late String _description;
  late double _defaultCommissionPct;
  late double _price;
  late double _basePrice;
  late double _taxRate;
  late int _stock;
  int? _vendorId;
  int? _categoryId;

  List<ProductCategory> _categories = [];
  bool _loadingCategories = true;

  List<String> _imageUrls = [];
  List<bool> _imageUploading = [];

  List<Map<String, dynamic>> _complianceList = [];

  bool get isEditMode => widget.initialData != null;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _name = data?.name ?? '';
    _description = data?.description ?? '';
    _basePrice = data?.basePrice ?? 0;
    _taxRate = data?.taxRate ?? 0;
    _defaultCommissionPct = widget.initialData?.defaultCommissionPct ?? 0;
    _price = _calculatePrice();
    _priceController = TextEditingController(text: _price.toStringAsFixed(2));
    _stock = data?.stock ?? 0;
    _vendorId = data?.vendorId;
    _categoryId = data?.categoryId;
    _imageUrls = data?.images.map((e) => e.url).toList() ?? [];
    _imageUploading = List.generate(_imageUrls.length, (_) => false);
    _fetchCategories();

    if (data?.compliance != null && data!.compliance!.isNotEmpty) {
      _complianceList =
          data.compliance!
              .map(
                (c) => {
                  'type': c.type ?? '',
                  'fileUrl': c.fileUrl ?? '',
                  'fileName': c.fileUrl?.split('/').last ?? '',
                  'uploading': false,
                },
              )
              .toList();
    }
  }

  double _calculatePrice() => _basePrice + (_basePrice * _taxRate / 100);

  void _updatePrice() {
    setState(() {
      _price = _calculatePrice();
      _priceController.text = _price.toStringAsFixed(2);
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint('Token not found.');
        setState(() => _loadingCategories = false);
        return;
      }

      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/api/MobileApp/vendor/product-categories',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded['data'];

        setState(() {
          _categories =
              data.map((json) => ProductCategory.fromJson(json)).toList();
          _loadingCategories = false;
          print(_categories);
        });
      } else {
        debugPrint('Failed to load categories: ${response.statusCode}');
        setState(() => _loadingCategories = false);
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      setState(() => _loadingCategories = false);
    }
  }

  Future<void> _pickImage() async {
    if (_imageUrls.length >= 5) return;
    setState(() => _imageUploading.add(true));

    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        final url = await _uploadWebFileToCloudinary(
          result.files.single.bytes!,
          result.files.single.name,
        );
        if (url != null) {
          setState(() {
            _imageUrls.add(url);
            _imageUploading[_imageUrls.length - 1] = false;
          });
        } else {
          setState(() => _imageUploading.removeLast());
        }
      } else {
        setState(() => _imageUploading.removeLast());
      }
    } else {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final url = await _uploadWebFileToCloudinary(bytes, pickedFile.name);
        if (url != null) {
          setState(() {
            _imageUrls.add(url);
            _imageUploading[_imageUrls.length - 1] = false;
          });
        } else {
          setState(() => _imageUploading.removeLast());
        }
      } else {
        setState(() => _imageUploading.removeLast());
      }
    }
  }

  void _addComplianceRow() {
    setState(() {
      _complianceList.add({
        'type': '',
        'fileName': '',
        'fileUrl': '',
        'uploading': false,
      });
    });
  }

  Future<void> _pickComplianceFile(int index) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.bytes != null) {
      setState(() => _complianceList[index]['uploading'] = true);

      final url = await _uploadWebFileToCloudinary(
        result.files.single.bytes!,
        result.files.single.name,
      );

      if (url != null) {
        setState(() {
          _complianceList[index]['fileUrl'] = url;
          _complianceList[index]['fileName'] = result.files.single.name;
          _complianceList[index]['uploading'] = false;
        });
      } else {
        setState(() => _complianceList[index]['uploading'] = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to upload file.')));
      }
    }
  }

  Future<String?> _uploadWebFileToCloudinary(
    Uint8List bytes,
    String filename,
  ) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dhas7vy3k/upload');
    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'vendors'
          ..files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: filename),
          );

    final response = await request.send();
    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      return jsonDecode(res.body)['secure_url'];
    }
    return null;
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one image.')),
      );
      return;
    }

    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    setState(() => _isSaving = true); // ✅ Start loading

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token missing')),
        );
        return;
      }

      final requestBody = {
        if (isEditMode)
          'id': widget.initialData!.id, // Only include ID on update
        'name': _name,
        'description': _description,
        'basePrice': _basePrice,
        'taxRate': _taxRate,
        'price': _price,
        'stock': _stock,
        'categoryId': _categoryId,
        'imageUrls': _imageUrls,
        'defaultCommissionPct': _defaultCommissionPct,
        'compliance':
            _complianceList
                .where(
                  (c) =>
                      c['fileUrl'] != null &&
                      c['fileUrl'].toString().isNotEmpty,
                )
                .map((c) => {'type': c['type'], 'fileUrl': c['fileUrl']})
                .toList(),
      };

      final url = Uri.parse(
        'http://localhost:3000/api/MobileApp/vendor/add-product',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Product Updated' : 'Product Saved'),
          ),
        );
        context.go('/products/management');
      } else {
        debugPrint('Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit product.')),
        );
      }
    } catch (e) {
      debugPrint('Exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong.')));
    } finally {
      setState(() => _isSaving = false); // ✅ Stop loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/products/management'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditMode ? 'Update Product' : 'Add Product',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextFormField(
                initialValue: _name,
                enabled: !isEditMode, // Disable in edit mode
                decoration: const InputDecoration(labelText: 'Product Name'),
                onChanged: (val) => _name = val,
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'Product name is required'
                            : null,
              ),

              const SizedBox(height: 10),
              _loadingCategories
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<int>(
                    value: _categoryId,
                    items:
                        _categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }).toList(),
                    onChanged: (val) => setState(() => _categoryId = val),
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator:
                        (val) =>
                            val == null ? 'Please select a category' : null,
                  ),

              const SizedBox(height: 10),

              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (val) => _description = val,
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'Description is required'
                            : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                initialValue: _basePrice.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Base Price'),
                onChanged: (val) {
                  _basePrice = double.tryParse(val) ?? 0;
                  _updatePrice();
                },
                validator: (val) {
                  final parsed = double.tryParse(val ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Base price must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              TextFormField(
                initialValue: _taxRate.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tax Rate'),
                onChanged: (val) {
                  _taxRate = double.tryParse(val) ?? 0;
                  _updatePrice();
                },
                validator: (val) {
                  final parsed = double.tryParse(val ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Tax rate must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _priceController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              const SizedBox(height: 10),

              TextFormField(
                initialValue: _stock.toString(),
                enabled: !isEditMode, // Disable in edit mode
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
                onChanged: (val) => _stock = int.tryParse(val) ?? 0,
                validator: (val) {
                  final parsed = int.tryParse(val ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Stock must be greater than zero';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              TextFormField(
                initialValue: _defaultCommissionPct.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Default Commission (%)',
                ),
                onChanged:
                    (val) => _defaultCommissionPct = double.tryParse(val) ?? 0,
                validator: (val) {
                  final parsed = double.tryParse(val ?? '');
                  if (parsed == null || parsed <= 0 || parsed > 100) {
                    return 'Commission must be between 1 and 100';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              const Text('Images:'),
              Wrap(
                spacing: 10,
                children: [
                  for (int i = 0; i < _imageUrls.length; i++)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.network(
                          _imageUrls[i],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        if (_imageUploading.length > i && _imageUploading[i])
                          const Positioned.fill(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _imageUrls.removeAt(i);
                              _imageUploading.removeAt(i);
                            });
                          },
                        ),
                      ],
                    ),
                  if (_imageUrls.length < 5)
                    IconButton(
                      icon: const Icon(Icons.add_a_photo),
                      onPressed: _pickImage,
                    ),
                ],
              ),

              const SizedBox(height: 20),
              const Text('Compliances:'),
              Column(
                children: List.generate(_complianceList.length, (index) {
                  final item = _complianceList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: item['type'],
                            decoration: const InputDecoration(
                              labelText: 'Type',
                            ),
                            onChanged: (val) => item['type'] = val,
                          ),
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: () => _pickComplianceFile(index),
                                child: const Text('Upload File'),
                              ),
                              const SizedBox(height: 4),
                              if (item['uploading'] == true)
                                const LinearProgressIndicator()
                              else if (item['fileName'] != null &&
                                  item['fileName'].isNotEmpty)
                                Text(
                                  item['fileName'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed:
                              () => setState(
                                () => _complianceList.removeAt(index),
                              ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Compliance'),
                onPressed: _addComplianceRow,
              ),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isSaving
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            isEditMode ? 'Update Product' : 'Save Product',
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
