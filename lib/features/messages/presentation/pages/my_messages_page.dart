import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import '../../../../core/models/chat.dart';
import '../../../provider/presentation/bloc/provider_bloc.dart';
import '../../../shared/presentation/bloc/shared_bloc.dart';
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
        listener: (context, state) {},
        builder: (context, state) {
          return GradientBackground(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 24 : 16,
                            vertical: 16,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: context.appColors.cardBackground,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: context.appColors.glassBorder,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: context.appColors.primaryTextColor,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Connect with your partners",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: context.appColors.hintTextColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: context.appColors.secondaryColor.withAlpha(40),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.appColors.secondaryColor.withAlpha(60),
                                    ),
                                  ),
                                  child:  Icon(
                                    Icons.chat_bubble_rounded,
                                    color: context.appColors.secondaryColor,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Text(
                            "RECENT CHATS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: context.appColors.primaryTextColor,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildMessagesList(
                            context,
                            state,
                            isLargeScreen,
                          ),
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

  Widget _buildMessagesList(
    BuildContext context,
    MessageState state,
    bool isLargeScreen,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (SuccessGetMyMessagesState.myMessages == null) {
      if (state is FailureGetMyMessagesState) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: context.appColors.glassBorder,
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 64,
                  color: context.appColors.secondaryColor.withAlpha(150),
                ),
                const SizedBox(height: 24),
                Text(
                  "NO CONVERSATIONS YET",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: context.appColors.primaryTextColor,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Your messages will appear here once you start chatting.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appColors.glassBorder,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return const Center(child: LoadingWidget());
    }

    return FutureBuilder<List<Chat>>(
      future: SuccessGetMyMessagesState.myMessages,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingWidget());
        }
        if (snapshot.hasError) {
          return const Center(
            child: EmptyWidget(
              message: "Error loading conversations",
              height: 400,
            ),
          );
        }
        if (snapshot.hasData) {
          final chats = snapshot.data!;
          if (chats.isEmpty) {
            return const Center(
              child: EmptyWidget(
                message: "No conversations found",
                height: 400,
              ),
            );
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: chats.length,
            itemBuilder: (context, index) =>
                _buildMessageCard(context, chats[index], index),
          );
        }
        return const Center(
          child: EmptyWidget(message: "No messages found", height: 400),
        );
      },
    );
  }

  Widget _buildMessageCard(BuildContext context, Chat chat, int index) {
    if (chat.other == null) return const SizedBox.shrink();
    final lastMessage =
        chat.chat?.lastMessage?.message ?? "Start a conversation";
    final unreadCount = chat.chat?.unreadCount ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.read<MessageBloc>().add(
            SetMessageReceiverEvent(profile: chat.other!),
          );
          context.read<MessageBloc>().add(
            SetSeenMessageEvent(reciever: chat.other!.user!.id!),
          );
          if (DashboardState.isProvider) {
            context.read<ProviderBloc>().add(
              NavigateProviderEvent(page: 4, widget: const ChatPage()),
            );
          } else {
            context.read<SeekerBloc>().add(
              NavigateSeekerEvent(page: 4, widget: const ChatPage()),
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: unreadCount > 0
                  ? context.appColors.secondaryColor.withAlpha(80)
                  : context.appColors.glassBorder,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white10,
                backgroundImage:
                    (chat.other!.profilePictureUrl != null &&
                        chat.other!.profilePictureUrl!.isNotEmpty)
                    ? NetworkImage(chat.other!.profilePictureUrl!)
                    : const AssetImage(logoAssets) as ImageProvider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        (chat.other!.firstName ?? "User").toUpperCase(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: context.appColors.primaryTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      lastMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: unreadCount > 0
                            ? context.appColors.primaryTextColor
                            : context.appColors.hintTextColor,
                        fontWeight: unreadCount > 0
                            ? FontWeight.w600
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
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$unreadCount",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.appColors.glassBorder,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
