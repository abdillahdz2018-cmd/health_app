import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _noRtController = TextEditingController();
  final _noRwController = TextEditingController();
  final _kelurahanController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _noTeleponController = TextEditingController();
  String _selectedRole = 'pasien';

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _namaLengkapController.dispose();
    _noRtController.dispose();
    _noRwController.dispose();
    _kelurahanController.dispose();
    _kecamatanController.dispose();
    _noTeleponController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      namaLengkap: _namaLengkapController.text.trim(),
      role: _selectedRole,
      noRt: _noRtController.text.trim(),
      noRw: _noRwController.text.trim(),
      kelurahan: _kelurahanController.text.trim(),
      kecamatan: _kecamatanController.text.trim(),
      noTelepon: _noTeleponController.text.trim(),
    );

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Registrasi gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Username',
                controller: _usernameController,
                hint: 'Masukkan username',
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Username wajib diisi' : null,
              ),
              CustomTextField(
                label: 'Nama Lengkap',
                controller: _namaLengkapController,
                hint: 'Masukkan nama lengkap',
                prefixIcon: Icons.badge_outlined,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama lengkap wajib diisi' : null,
              ),
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                hint: 'Masukkan email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Email wajib diisi' : null,
              ),
              CustomTextField(
                label: 'Password',
                controller: _passwordController,
                hint: 'Masukkan password',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Password wajib diisi' : null,
              ),
              const Text(
                'Role',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'pasien', child: Text('Pasien')),
                  DropdownMenuItem(value: 'nakes', child: Text('Tenaga Kesehatan')),
                  DropdownMenuItem(value: 'admin_rt', child: Text('Admin RT')),
                  DropdownMenuItem(value: 'admin_rw', child: Text('Admin RW')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'No. RT',
                      controller: _noRtController,
                      hint: 'Contoh: 003',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'No. RW',
                      controller: _noRwController,
                      hint: 'Contoh: 012',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              CustomTextField(
                label: 'Kelurahan',
                controller: _kelurahanController,
                hint: 'Masukkan kelurahan',
                prefixIcon: Icons.location_on_outlined,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Kelurahan wajib diisi' : null,
              ),
              CustomTextField(
                label: 'Kecamatan',
                controller: _kecamatanController,
                hint: 'Masukkan kecamatan',
                prefixIcon: Icons.location_city_outlined,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Kecamatan wajib diisi' : null,
              ),
              CustomTextField(
                label: 'No. Telepon (Opsional)',
                controller: _noTeleponController,
                hint: 'Contoh: 08123456789',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 8),
              CustomButton(
                label: 'Daftar',
                onPressed: _register,
                isLoading: authProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}