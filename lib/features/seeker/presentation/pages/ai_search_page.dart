import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/di/injection_container.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/seeker/presentation/widgets/provider_list_item.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/core/core.dart';


class AISearchPage extends StatefulWidget {
  const AISearchPage({super.key});

  @override
  State<AISearchPage> createState() => _AISearchPageState();
}

class _AISearchPageState extends State<AISearchPage> {
  final TextEditingController _controller = TextEditingController();
  final SeekerBloc _bloc = sl<SeekerBloc>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    if (_controller.text.isNotEmpty) {
      _bloc.add(MatchProvidersEvent(description: _controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "AI MAGIC MATCH",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22.sp,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.read<SeekerBloc>().add(SeekerBackPressedEvent()),
          child: Container(
            margin: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: context.appColors.glassBorder,
                width: 1.5.r,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: context.appColors.primaryTextColor,
              size: 16.r,
            ),
          ),
        ),
      ),
      body: GradientBackground(
        child: BlocProvider.value(
          value: _bloc,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 120.h, 16.w, 0),
            child: Column(
              children: [
                SolidContainer(
                  padding: EdgeInsets.all(24.r),
                  borderColor: context.appColors.glassBorder,
                  borderWidth: 1.5.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 35.h),
                      Row(
                        children: [
                           Icon(
                            Icons.auto_awesome,
                            color: context.appColors.secondaryColor,
                            size: 24.r,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            "AI ASSISTANT",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SolidTextField(
                        controller: _controller,
                        hintText:
                            "DESCRIBE WHAT YOU NEED...",
                        label: "REQUIREMENTS",
                        allCapsLabel: true,
                        prefixIcon: Icons.chat_bubble_outline_rounded,
                        isMultiLine: true,
                      ),
                      SizedBox(height: 20.h),
                      SolidButton(
                        label: "Find Best Providers",
                        onPressed: _search,
                        isLoading: _bloc.state is LoadingSeekerState,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: BlocBuilder<SeekerBloc, SeekerState>(
                    builder: (context, state) {
                      if (state is LoadingSeekerState) {
                        return  Center(
                          child: CircularProgressIndicator(
                            color: context.appColors.secondaryColor,
                          ),
                        );
                      } else if (state is SuccessMatchProvidersState) {
                        return FutureBuilder<List<Profile>>(
                          future: state.providers,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return  Center(
                                child: CircularProgressIndicator(
                                  color: context.appColors.secondaryColor,
                                ),
                              );
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 64.r,
                                      color: Colors.white.withAlpha(60),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      "NO MATCHING PROVIDERS FOUND",
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(150),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.only(
                                top: 0,
                                bottom: 40.h,
                              ),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final provider = snapshot.data![index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: ProviderListItem(
                                    profile: provider,
                                    onTap: () {
                                      // Navigation logic if needed
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        );
                      } else if (state is FailureMatchProvidersState) {
                        return  Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: context.appColors.errorColor,
                                size: 48.r,
                              ),
                               SizedBox(height: 16.h),
                              Text(
                                "Failed to find providers. Please try again.",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      }

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.8, end: 1.2),
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeInOutSine,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 80.r,
                                    color: context.appColors.secondaryColor.withAlpha(100),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              "DESCRIBE YOUR TASK ABOVE\nAND LET AI DO THE MAGIC",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withAlpha(150),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                height: 1.5,
                              ),
                            ),
                          ],
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
