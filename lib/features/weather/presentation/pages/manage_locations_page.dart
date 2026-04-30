// lib/features/weather/presentation/pages/manage_locations_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';

class ManageLocationsPage extends ConsumerStatefulWidget {
  const ManageLocationsPage({super.key});

  @override
  ConsumerState<ManageLocationsPage> createState() =>
      _ManageLocationsPageState();
}

class _ManageLocationsPageState extends ConsumerState<ManageLocationsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(savedLocationsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Quản lý địa điểm',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Ô TÌM KIẾM ĐỂ THÊM THÀNH PHỐ
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nhập tên thành phố để thêm...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(
                      Icons.add_location_alt,
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.amberAccent,
                      ),
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          ref
                              .read(savedLocationsProvider.notifier)
                              .addCity(_searchController.text.trim());
                          _searchController.clear();
                          FocusScope.of(context).unfocus(); // Ẩn bàn phím
                        }
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      ref
                          .read(savedLocationsProvider.notifier)
                          .addCity(value.trim());
                      _searchController.clear();
                    }
                  },
                ),
                const SizedBox(height: 24),

                // DANH SÁCH THÀNH PHỐ
                Expanded(
                  child: ListView.builder(
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final city = locations[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.white.withOpacity(0.1),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.location_city,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  city,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    if (locations.length > 1) {
                                      ref
                                          .read(savedLocationsProvider.notifier)
                                          .removeCity(city);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Phải giữ lại ít nhất 1 thành phố!',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
