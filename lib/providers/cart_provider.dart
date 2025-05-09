import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart.dart'; // Pastikan file cart.dart berisi class CartItem

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  String? _token;

  List<CartItem> get items => _items;

  // Inisialisasi cart saat aplikasi dimulai
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    print('Token di loadCart: $_token');

    await fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    if (_token == null || _token!.isEmpty) {
      print('Token kosong saat fetchCartItems');
      return;
    }

    final url = Uri.parse('https://plastik60.id/api/keranjang');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _items = data.map((item) => CartItem.fromJson(item)).toList();
      notifyListeners();
    } else {
      print('Gagal fetch cart: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  }

  Future<void> addItem(int produkId, int jumlah) async {
    final url = Uri.parse('https://plastik60.id/api/keranjang');
    final body = json.encode({'produk_id': produkId, 'jumlah': jumlah});

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      await fetchCartItems();
    } else {
      print('Gagal menambahkan item: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  }

  Future<void> updateItem(int id, int jumlah) async {
    final url = Uri.parse('https://plastik60.id/api/keranjang/update');
    final body = json.encode({'id': id, 'jumlah': jumlah});

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      await fetchCartItems();
    } else {
      print('Gagal update item: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  }

  Future<void> removeItem(int id) async {
    final url = Uri.parse('https://plastik60.id/api/keranjang/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } else {
      print('Gagal hapus item: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  }
}
