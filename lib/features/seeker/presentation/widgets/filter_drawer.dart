import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/core/core.dart';


class FilterDrawer extends StatefulWidget {
  const FilterDrawer({super.key});

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  double _priceMin = 0;
  double _priceMax = 500;
  double _ratingMin = 0;
  String _city = "";

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E1E2E),
          border: Border(
            left: BorderSide(color: Colors.white.withAlpha(20), width: 0.5),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Filter Results",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(
                  "Price Range",
                  "\$${_priceMin.round()} - \$${_priceMax.round()}",
                ),
                RangeSlider(
                  values: RangeValues(_priceMin, _priceMax),
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  activeColor: context.appColors.secondaryColor,
                  inactiveColor: Colors.white10,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _priceMin = values.start;
                      _priceMax = values.end;
                    });
                  },
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(
                  "Minimum Rating",
                  "${_ratingMin.toStringAsFixed(1)}+ Stars",
                ),
                Slider(
                  value: _ratingMin,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  activeColor: context.appColors.secondaryColor,
                  inactiveColor: Colors.white10,
                  onChanged: (double value) {
                    setState(() {
                      _ratingMin = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(
                  "Location",
                  _city.isEmpty ? "All Cities" : _city,
                ),
                const SizedBox(height: 12),
                TextField(
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Enter city name...",
                    hintStyle: TextStyle(color: Colors.white.withAlpha(60)),
                    filled: true,
                    fillColor: Colors.white.withAlpha(10),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withAlpha(15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: context.appColors.secondaryColor),
                    ),
                    prefixIcon: Icon(
                      Icons.location_on_rounded,
                      color: Colors.white.withAlpha(150),
                      size: 20,
                    ),
                  ),
                  onChanged: (val) => setState(() => _city = val),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.secondaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      context.read<SeekerBloc>().add(
                        SearchProviderEvent(
                          priceMin: _priceMin,
                          priceMax: _priceMax,
                          ratingMin: _ratingMin,
                          city: _city.isEmpty ? null : _city,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Apply Filters",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withAlpha(200),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: context.appColors.secondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
