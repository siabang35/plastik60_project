import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductQuantitySelector extends StatefulWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;
  final Function(int) onChanged;

  const ProductQuantitySelector({
    super.key,
    this.initialValue = 1,
    this.minValue = 1,
    this.maxValue = 999,
    required this.onChanged,
  });

  @override
  State<ProductQuantitySelector> createState() =>
      _ProductQuantitySelectorState();
}

class _ProductQuantitySelectorState extends State<ProductQuantitySelector> {
  late TextEditingController _controller;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialValue.clamp(widget.minValue, widget.maxValue);
    _controller = TextEditingController(text: _quantity.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    if (_quantity < widget.maxValue) {
      setState(() {
        _quantity++;
        _controller.text = _quantity.toString();
      });
      widget.onChanged(_quantity);
    }
  }

  void _decrement() {
    if (_quantity > widget.minValue) {
      setState(() {
        _quantity--;
        _controller.text = _quantity.toString();
      });
      widget.onChanged(_quantity);
    }
  }

  void _updateQuantity(String value) {
    if (value.isEmpty) return;

    final newQuantity = int.tryParse(value);
    if (newQuantity != null) {
      final clampedQuantity = newQuantity.clamp(
        widget.minValue,
        widget.maxValue,
      );
      if (clampedQuantity != _quantity) {
        setState(() {
          _quantity = clampedQuantity;
          if (_controller.text != _quantity.toString()) {
            _controller.text = _quantity.toString();
          }
        });
        widget.onChanged(_quantity);
      }
    } else {
      // Reset to previous valid value
      _controller.text = _quantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          icon: Icons.remove,
          onPressed: _quantity > widget.minValue ? _decrement : null,
        ),
        SizedBox(
          width: 40,
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: _updateQuantity,
            onSubmitted: _updateQuantity,
          ),
        ),
        _buildButton(
          icon: Icons.add,
          onPressed: _quantity < widget.maxValue ? _increment : null,
        ),
      ],
    );
  }

  Widget _buildButton({required IconData icon, VoidCallback? onPressed}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onPressed,
      ),
    );
  }
}
