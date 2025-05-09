import 'package:flutter/material.dart';
import 'package:plastik60_app/utils/validators.dart';
import 'package:plastik60_app/widgets/common/custom_text_field.dart';

class AddressForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController provinceController;
  final TextEditingController postalCodeController;
  final TextEditingController notesController;

  const AddressForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.cityController,
    required this.provinceController,
    required this.postalCodeController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: nameController,
          labelText: 'Nama Lengkap',
          hintText: 'Contoh: Budi Santoso',
          prefixIcon: Icons.person_outline,
          validator: Validators.validateName,
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: phoneController,
          labelText: 'No. HP / WhatsApp',
          hintText: 'Contoh: 081234567890',
          prefixIcon: Icons.phone_android,
          keyboardType: TextInputType.phone,
          validator: Validators.validatePhone,
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: addressController,
          labelText: 'Alamat Lengkap',
          hintText: 'Contoh: Jl. Melati No. 123, RT 05 RW 03',
          prefixIcon: Icons.location_on_outlined,
          maxLines: 2,
          validator: Validators.validateAddress,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: provinceController,
          labelText: 'Provinsi',
          hintText: 'Contoh: Jawa Barat',
          prefixIcon: Icons.map_outlined,
          validator: Validators.validateProvince, // jika ada validator-nya
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                controller: cityController,
                labelText: 'Kota / Kabupaten',
                hintText: 'Contoh: Jakarta Selatan',
                prefixIcon: Icons.apartment,
                validator: Validators.validateCity,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: CustomTextField(
                controller: postalCodeController,
                labelText: 'Kode Pos',
                hintText: 'Contoh: 12345',
                prefixIcon: Icons.local_post_office_outlined,
                keyboardType: TextInputType.number,
                validator: Validators.validatePostalCode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: notesController,
          labelText: 'Catatan untuk Kurir (Opsional)',
          hintText: 'Contoh: Tolong kirim siang hari',
          prefixIcon: Icons.sticky_note_2_outlined,
          maxLines: 2,
          validator: null,
        ),
      ],
    );
  }
}
