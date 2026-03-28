import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';

class CustomSegmentedControl<T> extends StatefulWidget {
  final List<T> buttonValues;
  final List<String> buttonLables;
  final T? defaultSelected;
  final ValueChanged<T> onValueChanged;
  final double height;
  final double? width;
  final double radius;
  final Color? selectedColor;
  final Color? unSelectedColor;
  final Color? selectedBorderColor;
  final Color? unSelectedBorderColor;
  final Color? textColor;
  final Color? unselectedTextColor;

  const CustomSegmentedControl({
    super.key,
    required this.buttonValues,
    required this.buttonLables,
    required this.onValueChanged,
    this.defaultSelected,
    this.height = 50,
    this.width,
    this.radius = 16,
    this.selectedColor,
    this.unSelectedColor,
    this.selectedBorderColor,
    this.unSelectedBorderColor,
    this.textColor,
    this.unselectedTextColor,
  }) : assert(buttonValues.length == buttonLables.length);

  @override
  State<CustomSegmentedControl<T>> createState() =>
      _CustomSegmentedControlState<T>();
}

class _CustomSegmentedControlState<T> extends State<CustomSegmentedControl<T>> {
  late T selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.defaultSelected ?? widget.buttonValues.first;
  }

  @override
  void didUpdateWidget(covariant CustomSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultSelected != null &&
        widget.defaultSelected != oldWidget.defaultSelected) {
      selectedValue = widget.defaultSelected as T;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double widgetWidth = widget.width ?? MediaQuery.of(context).size.width;
    final int itemCount = widget.buttonValues.length;
    final int selectedIndex = widget.buttonValues.indexOf(selectedValue);

    return Container(
      height: widget.height,
      width: size(context).width,
      decoration: BoxDecoration(
        color: widget.unSelectedColor ??
            context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: widget.unSelectedBorderColor ??
              context.appColors.glassBorder,
        ),
      ),
      child: Stack(
        children: [
          // Sliding Background
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: Alignment(
              -1 + (selectedIndex * (2 / (itemCount - 1))),
              0,
            ),
            child: Container(
              width: widgetWidth / itemCount,
              height: widget.height,
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.selectedColor ?? context.appColors.primaryColor,
                borderRadius: BorderRadius.circular(widget.radius - 4),
                boxShadow: [
                  BoxShadow(
                    color: (widget.selectedColor ?? context.appColors.primaryColor)
                        .withAlpha(60),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Labels
          Row(
            children: List.generate(itemCount, (index) {
              final isSelected = selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (selectedValue != widget.buttonValues[index]) {
                      setState(() {
                        selectedValue = widget.buttonValues[index];
                      });
                      widget.onValueChanged(selectedValue);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: isSelected
                            ? (widget.textColor ?? context.appColors.primaryTextColor)
                            : (widget.unselectedTextColor ??
                                context.appColors.secondaryTextColor),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                      child: Text(widget.buttonLables[index]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
