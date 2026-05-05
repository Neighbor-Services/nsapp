import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/skeleton_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import '../../../../core/models/chat.dart';
import '../../../provider/presentation/bloc/provider_bloc.dart';
import '../../../shared/presentation/bloc/settings/settings_bloc.dart';
import '../bloc/message_bloc.dart';
import 'chat_page.dart';

class MyMessagesPage extends StatefulWidget {
  const MyMessagesPage({super.key});

  @override
  State<MyMessagesPage> createState() => _MyMessagesPageState();
}

class _MyMessagesPageState extends State<MyMessagesPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  List<Chat> _chats = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    context.read<MessageBloc>().add(GetMyMessagesEvent());

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: BlocConsumer<MessageBloc, MessageState>(
        listener: (context, state) {
          if (state is SuccessGetMyMessagesState) {
            setState(() {
              _chats = state.myMessages;
              _isLoading = false;
              _errorMessage = null;
            });
          } else if (state is LoadingMessageState) {
            setState(() => _isLoading = true);
          } else if (state is FailureGetMyMessagesState) {
            setState(() {
              _isLoading = false;
              _errorMessage = state.message;
            });
          }
        },
        builder: (context, state) {
          return GradientBackground(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800.w),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 24.w : 16.w,
                            vertical: 16.h,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.r,
                              vertical: 24.r,
                            ),
                            decoration: BoxDecoration(
                              color: context.appColors.cardBackground,
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: context.appColors.glassBorder,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 10.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "MESSAGES",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w500,
                                        color: context.appColors.primaryTextColor,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "Connect with your partners",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: context.appColors.hintTextColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: context.appColors.secondaryColor.withAlpha(40),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.appColors.secondaryColor.withAlpha(60),
                                    ),
                                  ),
                                  child:  Icon(
                                    FontAwesomeIcons.comment,
                                    color: context.appColors.secondaryColor,
                                    size: 22.r,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 8.h,
                          ),
                          child: Text(
                            "RECENT CHATS",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: context.appColors.primaryTextColor,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildMessagesList(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context) {
    if (_isLoading && _chats.isEmpty) {
      return const ListSkeletonLoader();
    }

    if (_errorMessage != null && _chats.isEmpty) {
      return Center(
        child: EmptyWidget(
          message: _errorMessage!,
          height: 400.h,
        ),
      );
    }

    if (_chats.isEmpty) {
      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(40.r),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: context.appColors.glassBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.comment,
                size: 64.r,
                color: context.appColors.secondaryColor.withAlpha(150),
              ),
              SizedBox(height: 24.h),
              Text(
                "NO CONVERSATIONS YET",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.primaryTextColor,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Your messages will appear here once you start chatting.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.appColors.hintTextColor,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: _chats.length,
      itemBuilder: (context, index) =>
          _buildMessageCard(context, _chats[index], index),
    );
  }

  Widget _buildMessageCard(BuildContext context, Chat chat, int index) {
    if (chat.other == null) return const SizedBox.shrink();
    final lastMessage =
        chat.chat?.lastMessage?.message ?? "Start a conversation";
    final unreadCount = chat.chat?.unreadCount ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {
          context.read<MessageBloc>().add(
            SetMessageReceiverEvent(profile: chat.other!),
          );
          context.read<MessageBloc>().add(
            SetSeenMessageEvent(reciever: chat.other!.user!.id!),
          );
          
          final settingsState = context.read<SettingsBloc>().state;
          if (settingsState.isProvider) {
            context.read<ProviderBloc>().add(
              NavigateProviderEvent(page: 4, widget: const ChatPage()),
            );
          } else {
            context.read<SeekerBloc>().add(
              NavigateSeekerEvent(page: 4, widget: const ChatPage()),
            );
          }
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: unreadCount > 0
                  ? context.appColors.secondaryColor.withAlpha(80)
                  : context.appColors.glassBorder,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.white10,
                backgroundImage:
                    (chat.other!.profilePictureUrl != null &&
                        chat.other!.profilePictureUrl!.isNotEmpty)
                    ? NetworkImage(chat.other!.profilePictureUrl!)
                    : const AssetImage(logoAssets) as ImageProvider,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        (chat.other!.firstName ?? "User").toUpperCase(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.primaryTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    SizedBox(height: 6.h),
                    Text(
                      lastMessage,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: unreadCount > 0
                            ? context.appColors.primaryTextColor
                            : context.appColors.hintTextColor,
                        fontWeight: unreadCount > 0
                            ? FontWeight.w400
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.secondaryColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "$unreadCount",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Icon(
                  FontAwesomeIcons.chevronRight,
                  color: context.appColors.glassBorder,
                  size: 24.r,
                ),
            ],
          ),
        ),
      ),
    );
  }
}


