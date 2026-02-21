import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/di/injection_container.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/seeker/presentation/widgets/provider_list_item.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';

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
        title: const Text(
          "AI Magic Match",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.read<SeekerBloc>().add(SeekerBackPressedEvent()),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
      body: GradientBackground(
        child: BlocProvider.value(
          value: _bloc,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 120, 16, 0),
            child: Column(
              children: [
                SolidContainer(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: const Color(0xFF1E1E2E),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 35),
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: appOrangeColor1,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "AI Assistant",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SolidTextField(
                        controller: _controller,
                        hintText:
                            "Describe what you need help with (e.g. I need a plumber for a leaking pipe)",
                        prefixIcon: Icons.chat_bubble_outline_rounded,
                        isMultiLine: true,
                      ),
                      const SizedBox(height: 20),
                      SolidButton(
                        label: "Find Best Providers",
                        onPressed: _search,
                        isLoading: _bloc.state is LoadingSeekerState,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: BlocBuilder<SeekerBloc, SeekerState>(
                    builder: (context, state) {
                      if (state is LoadingSeekerState) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: appOrangeColor1,
                          ),
                        );
                      } else if (state is SuccessMatchProvidersState) {
                        return FutureBuilder<List<Profile>>(
                          future: state.providers,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: appOrangeColor1,
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
                                      size: 64,
                                      color: Colors.white.withAlpha(60),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No matching providers found.",
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(150),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(
                                top: 0,
                                bottom: 40,
                              ),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final provider = snapshot.data![index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
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
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Colors.redAccent,
                                size: 48,
                              ),
                               SizedBox(height: 16),
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
                                    size: 80,
                                    color: appOrangeColor1.withAlpha(100),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Describe your task above\nand let AI do the magic",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withAlpha(150),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
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
