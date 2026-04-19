import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/models/legal_document.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/core/core.dart';

class LegalDocumentPage extends StatefulWidget {
  const LegalDocumentPage({super.key});

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage>
    with SingleTickerProviderStateMixin {
  late final String _docType;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _docType = (Get.arguments as String?) ?? 'TERMS';

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SharedBloc>().add(
        GetLegalDocumentEvent(docType: _docType),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryColor = Theme.of(context).colorScheme.primary;
    final subtitleColor = textColor.withAlpha(150);

    return Scaffold(
      body: BlocConsumer<SharedBloc, SharedState>(
        listener: (context, state) {
          if (state is SuccessGetLegalDocumentState) {
            _fadeController.forward();
          }
        },
        builder: (context, state) {
          return GradientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.h,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withAlpha(60),
                              ),
                            ),
                            child: Icon(
                              FontAwesomeIcons.chevronLeft,
                              color: textColor,
                              size: 20.r,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            _docType == 'TERMS'
                                ? 'TERMS OF SERVICE'
                                : 'PRIVACY POLICY',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: _buildBody(
                      context,
                      state,
                      textColor,
                      subtitleColor,
                      secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SharedState state,
    Color textColor,
    Color subtitleColor,
    Color secondaryColor,
  ) {
    if (state is SharedLoadingState || state is SharedInitialState) {
      return Center(
        child: CircularProgressIndicator(color: secondaryColor),
      );
    }

    if (state is FailureGetLegalDocumentState) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.circleExclamation,
              size: 56.r,
              color: subtitleColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Documents not available',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please check back later.',
              style: TextStyle(color: subtitleColor, fontSize: 13.sp),
            ),
            SizedBox(height: 24.h),
            TextButton.icon(
              onPressed: () {
                context.read<SharedBloc>().add(
                  GetLegalDocumentEvent(docType: _docType),
                );
              },
              icon: FaIcon(FontAwesomeIcons.rotateRight, color: secondaryColor),
              label: Text(
                'Retry',
                style: TextStyle(color: secondaryColor),
              ),
            ),
          ],
        ),
      );
    }

    final List<LegalDocument> docs = SuccessGetLegalDocumentState.documents;
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.circleInfo,
              size: 56.r,
              color: subtitleColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'No documents found',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: docs.length,
        separatorBuilder: (context, index) => SizedBox(height: 32.h),
        itemBuilder: (context, index) {
          final doc = docs[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meta info card
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: secondaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: secondaryColor.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _docType == 'TERMS'
                          ? FontAwesomeIcons.gavel
                          : FontAwesomeIcons.shieldHalved,
                      color: secondaryColor,
                      size: 22.r,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Version ${doc.version}  â€¢  Last updated ${_formatDate(doc.updatedAt)}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              // Document content
              Text(
                doc.content,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: textColor.withAlpha(210),
                  height: 1.7,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day} ${_month(dt.month)} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _month(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m];
  }
}




