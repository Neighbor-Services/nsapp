import 'package:flutter/material.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';

class SearchableServiceSelector extends StatefulWidget {
  final List<Service> services;
  final List<Category> categories;
  final String? selectedServiceId;
  final Function(String serviceId, String serviceName) onServiceSelected;
  final VoidCallback? onOthersSelected;

  const SearchableServiceSelector({
    super.key,
    required this.services,
    required this.categories,
    this.selectedServiceId,
    required this.onServiceSelected,
    this.onOthersSelected,
  });

  @override
  State<SearchableServiceSelector> createState() =>
      _SearchableServiceSelectorState();
}

class _SearchableServiceSelectorState extends State<SearchableServiceSelector> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _expandedCategories = {};
  List<Service> _filteredServices = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredServices = widget.services;
    for (var category in widget.categories) {
      _expandedCategories[category.id!] = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterServices(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredServices = widget.services;
      } else {
        _filteredServices = widget.services
            .where(
              (service) =>
                  service.name!.toLowerCase().contains(_searchQuery) ||
                  (service.description?.toLowerCase().contains(_searchQuery) ??
                      false),
            )
            .toList();
      }
    });
  }

  Map<String, List<Service>> _groupServicesByCategory() {
    final Map<String, List<Service>> grouped = {};

    for (var service in _filteredServices) {
      final categoryId = service.categoryId ?? 'uncategorized';
      if (!grouped.containsKey(categoryId)) {
        grouped[categoryId] = [];
      }
      grouped[categoryId]!.add(service);
    }

    return grouped;
  }

  String _getCategoryName(String categoryId) {
    if (categoryId == 'uncategorized') return 'Other Services';
    final category = widget.categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category(name: 'Unknown'),
    );
    return category.name ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final groupedServices = _groupServicesByCategory();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withAlpha(10),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Select Service',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SolidTextField(
                  controller: _searchController,
                  hintText: 'Search services...',
                  label: 'Search',
                  prefixIcon: Icons.search_rounded,
                  onChanged: _filterServices,
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredServices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 60,
                          color: isDark
                              ? Colors.white24
                              : Colors.black.withAlpha(30),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No services found',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      ...groupedServices.entries.map((entry) {
                        final categoryId = entry.key;
                        final services = entry.value;
                        final categoryName = _getCategoryName(categoryId);
                        final isExpanded =
                            _expandedCategories[categoryId] ?? true;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _expandedCategories[categoryId] = !isExpanded;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: appDeepBlueColor1.withAlpha(50),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: appDeepBlueColor1.withAlpha(100),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_more_rounded
                                          : Icons.chevron_right_rounded,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        categoryName,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: appOrangeColor1.withAlpha(150),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${services.length}',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded)
                              ...services.map((service) {
                                final isSelected =
                                    service.id == widget.selectedServiceId;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      widget.onServiceSelected(
                                        service.id!,
                                        service.name!,
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? appDeepBlueColor1.withAlpha(
                                                isDark ? 100 : 30,
                                              )
                                            : (isDark
                                                  ? Colors.white.withAlpha(15)
                                                  : Colors.white),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? appDeepBlueColor1
                                              : (isDark
                                                    ? Colors.white.withAlpha(40)
                                                    : Colors.black.withAlpha(
                                                        10,
                                                      )),
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: (isSelected || isDark)
                                            ? null
                                            : [
                                                BoxShadow(
                                                  color: Colors.black.withAlpha(
                                                    5,
                                                  ),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: appOrangeColor1.withAlpha(
                                                30,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.work_outline_rounded,
                                              color: appOrangeColor1,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  service.name!,
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black87,
                                                    fontSize: 16,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.w600,
                                                  ),
                                                ),
                                                if (service.description !=
                                                        null &&
                                                    service
                                                        .description!
                                                        .isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    service.description!,
                                                    style: TextStyle(
                                                      color: isDark
                                                          ? Colors.white70
                                                          : Colors.black54,
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: appOrangeColor1,
                                              size: 24,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            const SizedBox(height: 8),
                          ],
                        );
                      }),
                      if (widget.onOthersSelected != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: GestureDetector(
                            onTap: () {
                              widget.onOthersSelected!();
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withAlpha(15)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withAlpha(40)
                                      : Colors.black.withAlpha(10),
                                ),
                                boxShadow: isDark
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(5),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withAlpha(30)
                                          : Colors.black.withAlpha(5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black54,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Others (Specify your service)',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
