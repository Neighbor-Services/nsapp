import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';

class SearchLocationMapWidget extends StatefulWidget {
  const SearchLocationMapWidget({super.key});

  @override
  State<SearchLocationMapWidget> createState() =>
      _SearchLocationMapWidgetState();
}

class _SearchLocationMapWidgetState extends State<SearchLocationMapWidget> {
  TextEditingController locationTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SharedBloc, SharedState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Column(
          children: [
            Container(
              width: 50.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: context.appColors.glassBorder,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 24.h),
            Hero(
              tag: 'map_search',
              child: SolidTextField(
                controller: locationTextController,
                hintText: "Search for a location...",
                label: "Search Location",
                prefixIcon: Icons.search_rounded,
                onChanged: (val) {
                  context.read<SharedBloc>().add(SearchPlacesEvent(input: val));
                },
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: SuccessPlacesState.places.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_rounded,
                            size: 60.r,
                            color: context.appColors.glassBorder,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "Find your perfect location",
                            style: TextStyle(
                              color: context.appColors.secondaryTextColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: SuccessPlacesState.places.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 12.0.h),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: context.appColors.cardBackground,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: context.appColors.glassBorder,
                                  width: 1.r,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.appColors.glassBorder,
                                    blurRadius: 10.r,
                                    offset: Offset(0, 4.h),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  onTap: () {
                                    context.read<SharedBloc>().add(
                                      SearchPlaceEvent(
                                        placeId: SuccessPlacesState
                                            .places[index]
                                            .placeId!,
                                      ),
                                    );
                                    Get.back();
                                  },
                                  leading: Container(
                                    padding: EdgeInsets.all(12.r),
                                    decoration: BoxDecoration(
                                      color: context.appColors.primaryColor.withAlpha(40),
                                      shape: BoxShape.circle,
                                      
                                    ),
                                    child:  Icon(
                                      Icons.location_on_rounded,
                                      color: context.appColors.primaryColor,
                                      size: 20.r,
                                    ),
                                  ),
                                  title: Text(
                                    SuccessPlacesState.places[index].name,
                                    style: TextStyle(
                                      color: context.appColors.primaryTextColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  subtitle: Text(
                                    SuccessPlacesState
                                            .places[index]
                                            .description ??
                                        "",
                                    style: TextStyle(
                                      color: context.appColors.secondaryTextColor,
                                      fontSize: 13.sp,
                                      letterSpacing: 0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
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
        );
      },
    );
  }
}
