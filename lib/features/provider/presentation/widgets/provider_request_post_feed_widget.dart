import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../shared/presentation/widget/empty_widget.dart';
import '../../../shared/presentation/widget/loading_widget.dart';
import '../../../shared/presentation/widget/solid_container_widget.dart';
import '../bloc/provider_bloc.dart';

class ProviderRequestPostFeedWidget extends StatefulWidget {
  const ProviderRequestPostFeedWidget({super.key});

  @override
  State<ProviderRequestPostFeedWidget> createState() =>
      _ProviderRequestPostFeedWidgetState();
}

class _ProviderRequestPostFeedWidgetState
    extends State<ProviderRequestPostFeedWidget> {
  @override
  void initState() {
    context.read<ProviderBloc>().add(GetRequestsEvent(requestData: null));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProviderBloc, ProviderState>(
        builder: (context, state) {
          return FutureBuilder<List<RequestData>>(
            future: SuccessGetRequestsState.requests,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    primary: false,
                    itemBuilder: (context, index) {
                      RequestData requestData = snapshot.data![index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: SolidContainer(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withAlpha(50),
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      requestData.user!.profilePictureUrl != ""
                                      ? NetworkImage(
                                          requestData.user!.profilePictureUrl!,
                                        )
                                      : AssetImage(logoAssets) as ImageProvider,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextWidget(
                                          text: requestData.user!.firstName!,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            CustomTextWidget(
                                              text: DateFormat("MMM d, HH:mm")
                                                  .format(
                                                    requestData
                                                        .request!
                                                        .createdAt!,
                                                  ),
                                              fontSize: 12,
                                              color: Colors.white.withAlpha(
                                                150,
                                              ),
                                            ),
                                            if (requestData.request?.distance !=
                                                null)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 10,
                                                    color: Colors.white
                                                        .withAlpha(100),
                                                  ),
                                                  SizedBox(width: 2),
                                                  CustomTextWidget(
                                                    text:
                                                        "${requestData.request!.distance!.toStringAsFixed(1)}km",
                                                    fontSize: 10,
                                                    color: Colors.white
                                                        .withAlpha(100),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    CustomTextWidget(
                                      text:
                                          requestData.request!.service!.name ??
                                          "",
                                      fontSize: 14,
                                      color: Colors.lightBlueAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    SizedBox(height: 4),
                                    CustomTextWidget(
                                      text: requestData.request!.title ?? "",
                                      fontSize: 13,
                                      color: Colors.white.withAlpha(200),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return EmptyWidget(
                    message: "No requests available",
                    height: 200,
                  );
                }
              } else {
                return LoadingWidget();
              }
            },
          );
        },
      ),
    );
  }
}
