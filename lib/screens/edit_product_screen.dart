import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
  };
  var _isLoading = false;

  @override
  void initState() {
    super.initState();

    this._imageUrlFocusNode.addListener(this._updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (this._isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        this._editedProduct =
            Provider.of<ProductsProvider>(context, listen: false)
                .findById(productId);
        this._initValues = {
          'title': this._editedProduct.title,
          'description': this._editedProduct.description,
          'price': this._editedProduct.price.toString(),
        };
        this._imageUrlController.text = this._editedProduct.imageUrl;
      }
    }
    this._isInit = false;
  }

  @override
  void dispose() {
    super.dispose();

    this._priceFocusNode.dispose();
    this._descriptionFocusNode.dispose();
    this._imageUrlController.dispose();
    this._imageUrlFocusNode.dispose();
    this._imageUrlFocusNode.removeListener(this._updateImageUrl);
  }

  void _updateImageUrl() {
    if ((!this._imageUrlController.text.startsWith('http') &&
            !this._imageUrlController.text.startsWith('https')) ||
        (!this._imageUrlController.text.endsWith('.jpg') &&
            !this._imageUrlController.text.endsWith('.png') &&
            !this._imageUrlController.text.endsWith('jpeg'))) return;

    if (!this._imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = this._form.currentState.validate();
    if (!isValid) return;

    this._form.currentState.save();

    setState(() {
      this._isLoading = true;
    });

    try {
      if (this._editedProduct.id != null) {
        await Provider.of<ProductsProvider>(context, listen: false)
            .updateProduct(this._editedProduct.id, this._editedProduct);
      } else {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(this._editedProduct);
      }
    } catch (error) {
      await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('An error occurred!'),
                content: Text('Something went wrong.'),
                actions: [
                  TextButton(
                    child: Text('Okay'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  )
                ],
              ));
    } finally {
      setState(() {
        this._isLoading = false;
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: this._saveForm)
        ],
      ),
      body: this._isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: this._form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Title',
                        ),
                        initialValue: this._initValues['title'],
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(this._priceFocusNode),
                        keyboardType: TextInputType.text,
                        onSaved: (value) {
                          this._editedProduct = Product(
                            id: this._editedProduct.id,
                            isFavorite: this._editedProduct.isFavorite,
                            title: value,
                            description: this._editedProduct.description,
                            price: this._editedProduct.price,
                            imageUrl: this._editedProduct.imageUrl,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Price',
                        ),
                        initialValue: this._initValues['price'],
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(this._descriptionFocusNode),
                        keyboardType: TextInputType.number,
                        focusNode: this._priceFocusNode,
                        onSaved: (value) {
                          this._editedProduct = Product(
                            id: this._editedProduct.id,
                            isFavorite: this._editedProduct.isFavorite,
                            title: this._editedProduct.title,
                            description: this._editedProduct.description,
                            price: double.parse(value),
                            imageUrl: this._editedProduct.imageUrl,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) return 'Please enter a price';
                          if (double.tryParse(value) == null)
                            return 'Please enter a valid number';
                          if (double.parse(value) <= 0)
                            return 'Please enter a number greater than zero';

                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                        initialValue: this._initValues['description'],
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: this._descriptionFocusNode,
                        onSaved: (value) {
                          this._editedProduct = Product(
                            id: this._editedProduct.id,
                            isFavorite: this._editedProduct.isFavorite,
                            title: this._editedProduct.title,
                            description: value,
                            price: this._editedProduct.price,
                            imageUrl: this._editedProduct.imageUrl,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Please enter a description';
                          if (value.length < 10)
                            return 'Should be at least 10 characters long';

                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: this._imageUrlController.text.isEmpty
                                ? Text('Enter a URL')
                                : FittedBox(
                                    child: Image.network(
                                        this._imageUrlController.text),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Image URL',
                              ),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: this._imageUrlController,
                              // onEditingComplete: () {
                              //   setState(() {});
                              // },
                              focusNode: this._imageUrlFocusNode,
                              onFieldSubmitted: (_) {
                                this._saveForm();
                              },
                              onSaved: (value) {
                                this._editedProduct = Product(
                                  id: this._editedProduct.id,
                                  isFavorite: this._editedProduct.isFavorite,
                                  title: this._editedProduct.title,
                                  description: this._editedProduct.description,
                                  price: this._editedProduct.price,
                                  imageUrl: value,
                                );
                              },
                              validator: (value) {
                                if (value.isEmpty)
                                  return 'Please enter an image URL';
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https'))
                                  return 'Please enter a valid URL';
                                if (!value.endsWith('.jpg') &&
                                    !value.endsWith('.png') &&
                                    !value.endsWith('jpeg'))
                                  return 'Supported types are JPG, JPEG, PNG';

                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
