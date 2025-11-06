import 'package:flutter/material.dart';

class Barang {
  final int id;
  final String nama;
  final int harga;
  final int stok;
  final String kategori;

  Barang({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.kategori,
  });
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  List<Barang> _listBarang = [
    Barang(id: 1, nama: 'Laptop Asus ROG', harga: 15000000, stok: 15, kategori: 'Elektronik'),
    Barang(id: 2, nama: 'Iphone 17 PRO MAX', harga: 300000000, stok: 50, kategori: 'Gadget'),
    Barang(id: 3, nama: 'Keyboard Logitech', harga: 1200000, stok: 30, kategori: 'Aksesoris'),
    Barang(id: 4, nama: 'Monitor Samsung 34" 4K', harga: 45000000, stok: 20, kategori: 'Elektronik'),
    Barang(id: 5, nama: 'Webcam Logitech 4k', harga: 85000000, stok: 25, kategori: 'Aksesoris'),
  ];

  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _kategoriController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Barang> get _filteredBarang {
    if (_searchQuery.isEmpty) {
      return _listBarang;
    }
    return _listBarang.where((barang) {
      return barang.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          barang.kategori.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _tambahBarang() {
    _clearControllers();
    _showFormDialog(
      title: 'Tambah Barang Baru',
      icon: Icons.add_circle_outline,
      onSave: () {
        if (_validateForm()) {
          setState(() {
            int newId = _listBarang.isEmpty ? 1 : _listBarang.last.id + 1;
            _listBarang.add(
              Barang(
                id: newId,
                nama: _namaController.text,
                harga: int.parse(_hargaController.text),
                stok: int.parse(_stokController.text),
                kategori: _kategoriController.text,
              ),
            );
          });
          Navigator.pop(context);
          _showSnackBar('✓ Barang berhasil ditambahkan!', Colors.green);
          _clearControllers();
        }
      },
    );
  }

  void _editBarang(Barang barang) {
    _namaController.text = barang.nama;
    _hargaController.text = barang.harga.toString();
    _stokController.text = barang.stok.toString();
    _kategoriController.text = barang.kategori;

    _showFormDialog(
      title: 'Edit Barang',
      icon: Icons.edit_outlined,
      onSave: () {
        if (_validateForm()) {
          setState(() {
            int index = _listBarang.indexWhere((b) => b.id == barang.id);
            _listBarang[index] = Barang(
              id: barang.id,
              nama: _namaController.text,
              harga: int.parse(_hargaController.text),
              stok: int.parse(_stokController.text),
              kategori: _kategoriController.text,
            );
          });
          Navigator.pop(context);
          _showSnackBar('✓ Barang berhasil diubah!', Colors.blue);
          _clearControllers();
        }
      },
    );
  }

  void _hapusBarang(Barang barang) {
    showDialog(
      context: context,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticOut,
        ),
        child: AlertDialog(
          backgroundColor: const Color(0xFF173648),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[300], size: 32),
              const SizedBox(width: 12),
              const Text(
                'Konfirmasi Hapus',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah Anda yakin ingin menghapus barang ini?',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1C7FDD).withOpacity(0.3),
                      const Color(0xFF0FB7D4).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF1C7FDD).withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barang.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rp ${_formatCurrency(barang.harga)}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Color(0xFF0FB7D4), fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _listBarang.removeWhere((b) => b.id == barang.id);
                });
                Navigator.pop(context);
                _showSnackBar('✓ Barang berhasil dihapus!', Colors.red);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Hapus', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF173648),
              const Color(0xFF0A5A99),
              const Color(0xFF1C7FDD),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 30),
            Hero(
              tag: 'profile_avatar',
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1C7FDD), Color(0xFF0FB7D4)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1C7FDD).withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Dashboard Barang',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Luthfi - 5E',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'admin@dashboard.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    _buildProfileItem(
                      icon: Icons.inventory_2_outlined,
                      title: 'Total Barang',
                      value: '${_listBarang.length} Items',
                      color: Color(0xFF1C7FDD),
                    ),
                    const SizedBox(height: 20),
                    _buildProfileItem(
                      icon: Icons.shopping_cart_outlined,
                      title: 'Total Stok',
                      value: '${_listBarang.fold<int>(0, (sum, item) => sum + item.stok)} Units',
                      color: Color(0xFF0FB7D4),
                    ),
                    const SizedBox(height: 20),
                    _buildProfileItem(
                      icon: Icons.attach_money,
                      title: 'Total Nilai',
                      value: 'Rp ${_formatCurrency(_listBarang.fold<int>(0, (sum, item) => sum + (item.harga * item.stok)))}',
                      color: Color(0xFF0A5A99),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 24),
                        label: const Text('Tutup Profil', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C7FDD),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFormDialog({
    required String title,
    required IconData icon,
    required VoidCallback onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1C7FDD).withOpacity(0.1),
                          const Color(0xFF0FB7D4).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, color: const Color(0xFF1C7FDD), size: 30),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildTextField(
                controller: _namaController,
                label: 'Nama Barang',
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _kategoriController,
                label: 'Kategori',
                icon: Icons.category_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _hargaController,
                label: 'Harga',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _stokController,
                label: 'Stok',
                icon: Icons.inventory_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearControllers();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Batal', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: const Color(0xFF1C7FDD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF1C7FDD)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF0A5A99)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1C7FDD), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  bool _validateForm() {
    if (_namaController.text.isEmpty) {
      _showSnackBar('Nama barang tidak boleh kosong', Colors.red);
      return false;
    }
    if (_kategoriController.text.isEmpty) {
      _showSnackBar('Kategori tidak boleh kosong', Colors.red);
      return false;
    }
    if (_hargaController.text.isEmpty) {
      _showSnackBar('Harga tidak boleh kosong', Colors.red);
      return false;
    }
    if (_stokController.text.isEmpty) {
      _showSnackBar('Stok tidak boleh kosong', Colors.red);
      return false;
    }
    return true;
  }

  void _clearControllers() {
    _namaController.clear();
    _hargaController.clear();
    _stokController.clear();
    _kategoriController.clear();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : 
              color == Colors.blue ? Icons.info : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 16))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.9),
                  color.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 35),
                const SizedBox(height: 15),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF173648),
              Color(0xFF0A5A99),
              Color(0xFF1C7FDD),
              Color(0xFF0FB7D4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header dengan Profil
              Padding(
                padding: const EdgeInsets.all(25),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) => FadeTransition(
                              opacity: _fadeAnimation,
                              child: const Text(
                                'Dashboard Barang',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) => FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                '${_listBarang.length} Barang Tersedia • Luthfi 5E',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Hero(
                      tag: 'profile_avatar',
                      child: GestureDetector(
                        onTap: _showProfile,
                        child: AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) => FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1C7FDD), Color(0xFF0FB7D4)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1C7FDD).withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Cards
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(_slideAnimation),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        _buildStatsCard('Total Barang', _listBarang.length.toString(), 
                            Icons.inventory_2, const Color(0xFF1C7FDD)),
                        _buildStatsCard('Total Stok', '${_listBarang.fold<int>(0, (sum, item) => sum + item.stok)}', 
                            Icons.shopping_cart, const Color(0xFF0FB7D4)),
                        _buildStatsCard('Kategori', '${_listBarang.map((item) => item.kategori).toSet().length}', 
                            Icons.category, const Color(0xFF0A5A99)),
                        _buildStatsCard('Total Nilai', 'Rp ${_formatCurrency(_listBarang.fold<int>(0, (sum, item) => sum + (item.harga * item.stok)))}', 
                            Icons.attach_money, const Color(0xFF173648)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_slideAnimation),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1C7FDD).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari barang...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF1C7FDD), size: 24),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // List Barang
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: _filteredBarang.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 100,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Belum ada barang'
                                    : 'Barang tidak ditemukan',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                          itemCount: _filteredBarang.length,
                          itemBuilder: (context, index) {
                            final barang = _filteredBarang[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: AnimatedBuilder(
                                animation: _slideAnimation,
                                builder: (context, child) => SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.5, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(0.1 + (index * 0.08), 1.0, curve: Curves.easeOutBack),
                                  )),
                                  child: FadeTransition(
                                    opacity: CurvedAnimation(
                                      parent: _animationController,
                                      curve: Interval(0.1 + (index * 0.08), 1.0, curve: Curves.easeIn),
                                    ),
                                    child: _buildBarangCard(barang),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: _tambahBarang,
          backgroundColor: const Color(0xFF1C7FDD),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add, size: 28),
          label: const Text('Tambah Barang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildBarangCard(Barang barang) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF173648).withOpacity(0.9),
            const Color(0xFF0A5A99).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C7FDD).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _editBarang(barang),
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1C7FDD), Color(0xFF0FB7D4)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1C7FDD).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barang.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A5A99).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF0A5A99).withOpacity(0.5)),
                            ),
                            child: Text(
                              barang.kategori,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.inventory_outlined, size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            'Stok: ${barang.stok}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${_formatCurrency(barang.harga)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _editBarang(barang),
                      icon: const Icon(Icons.edit_outlined, size: 24),
                      color: Color(0xFF0FB7D4),
                      style: IconButton.styleFrom(
                        backgroundColor: Color(0xFF0FB7D4).withOpacity(0.2),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      onPressed: () => _hapusBarang(barang),
                      icon: const Icon(Icons.delete_outline, size: 24),
                      color: Colors.red,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        padding: const EdgeInsets.all(12),
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