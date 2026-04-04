import 'package:flutter/material.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/core/core.dart';

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
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        border: Border.all(
          color: context.appColors.glassBorder,
          width: 1.r,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              children: [
                Container(
                  width: 50.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: context.appColors.glassBorder,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Select Service',
                  style: TextStyle(
                    color: context.appColors.primaryTextColor,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
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
                          size: 60.r,
                          color: context.appColors.glassBorder,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No services found',
                          style: TextStyle(
                            color: context.appColors.glassBorder,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color: context.appColors.primaryColor.withAlpha(50),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: context.appColors.primaryColor.withAlpha(100),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_more_rounded
                                          : Icons.chevron_right_rounded,
                                      color: context.appColors.primaryTextColor,
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        categoryName,
                                        style: TextStyle(
                                          color: context.appColors.primaryTextColor,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.appColors.secondaryColor.withAlpha(150),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        '${services.length}',
                                        style: TextStyle(
                                          color: context.appColors.primaryTextColor,
                                          fontSize: 12.sp,
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
                                  padding: EdgeInsets.only(bottom: 12.h),
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
                                      padding: EdgeInsets.all(16.r),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? context.appColors.primaryColor.withAlpha(50)
                                            : context.appColors.glassBorder,
                                        borderRadius: BorderRadius.circular(16.r),
                                        border: Border.all(
                                          color: isSelected
                                              ? context.appColors.primaryColor
                                              : context.appColors.glassBorder,
                                          width: isSelected ? 2.r : 1.r,
                                        ),
                                        boxShadow: (isSelected || isDark)
                                            ? null
                                            : [
                                                BoxShadow(
                                                  color: Colors.black.withAlpha(
                                                    5,
                                                  ),
                                                  blurRadius: 10.r,
                                                  offset: Offset(0, 4.h),
                                                ),
                                              ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(12.r),
                                            decoration: BoxDecoration(
                                              color: context.appColors.secondaryColor.withAlpha(
                                                30,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                            child: Icon(
                                              Icons.work_outline_rounded,
                                              color: context.appColors.secondaryColor,
                                              size: 24.r,
                                            ),
                                          ),
                                          SizedBox(width: 16.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  service.name!,
                                                  style: TextStyle(
                                                    color: context.appColors.primaryTextColor,
                                                    fontSize: 16.sp,
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
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    service.description!,
                                                    style: TextStyle(
                                                      color: context.appColors.secondaryTextColor,
                                                      fontSize: 13.sp,
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
                                             Icon(
                                              Icons.check_circle_rounded,
                                              color: context.appColors.secondaryColor,
                                              size: 24.r,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            SizedBox(height: 8.h),
                          ],
                        );
                      }),
                      if (widget.onOthersSelected != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 24.h),
                          child: GestureDetector(
                            onTap: () {
                              widget.onOthersSelected!();
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: context.appColors.glassBorder,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: context.appColors.glassBorder,
                                ),
                                boxShadow: isDark
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(5),
                                          blurRadius: 10.r,
                                          offset: Offset(0, 4.h),
                                        ),
                                      ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12.r),
                                    decoration: BoxDecoration(
                                      color: context.appColors.glassBorder,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: context.appColors.primaryTextColor,
                                      size: 24.r,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Text(
                                      'Others (Specify your service)',
                                      style: TextStyle(
                                        color: context.appColors.primaryTextColor,
                                        fontSize: 16.sp,
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
