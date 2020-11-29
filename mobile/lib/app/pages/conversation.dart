import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/app/widget/buttons.dart';
import 'package:handyman/app/widget/chat_header.dart';
import 'package:handyman/app/widget/chat_input_entry.dart';
import 'package:handyman/app/widget/chat_list_item.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:handyman/domain/services/auth.dart';
import 'package:handyman/domain/services/data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ConversationPage extends StatefulWidget {
  final bool isCustomer;
  final String recipient;

  const ConversationPage({Key key, this.recipient, this.isCustomer})
      : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  DataService _apiService;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Scaffold(
      extendBody: true,
      body: Consumer<DataService>(
        builder: (_, service, __) {
          _apiService = service;
          return Consumer<PrefsProvider>(
            builder: (_, provider, __) => Container(
              child: SafeArea(
                child: StreamBuilder<BaseUser>(
                  stream: widget.isCustomer
                      ? _apiService.getCustomerById(id: widget.recipient)
                      : _apiService.getArtisanById(id: widget.recipient),
                  builder: (_, snapshot) {
                    return snapshot.hasError
                        ? Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("No recipient found"),
                                SizedBox(
                                    height: getProportionateScreenHeight(
                                        kSpacingX24)),
                                ButtonOutlined(
                                  width:
                                      getProportionateScreenWidth(kSpacingX200),
                                  themeData: themeData,
                                  onTap: () => context.navigator.pop(),
                                  label: "Go back",
                                )
                              ],
                            ),
                          )
                        : _buildChatWidget(snapshot.data);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatWidget(BaseUser recipient) => Consumer<AuthService>(
        builder: (_, authService, __) => StreamBuilder<BaseUser>(
            stream: authService.currentUser(),
            builder: (context, snapshot) => Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: ChatMessages(
                            messages: _apiService.getConversation(
                              sender: snapshot.data?.user?.id,
                              recipient: widget.recipient,
                            ),
                            recipient: recipient,
                            sender: snapshot.data,
                          ),
                        ),
                        UserInput(
                          user: snapshot.data,
                          onMessageSent: (content) async {
                            if (content.isEmpty) return;
                            final timestamp =
                                DateFormat.jms().format(DateTime.now());
                            final conversation = Conversation(
                              id: Uuid().v4(),
                              author: snapshot.data?.user?.id,
                              recipient: widget.recipient,
                              content: content,
                              createdAt: timestamp,
                            );
                            await _apiService.sendMessage(
                                conversation: conversation);
                          },
                        ),
                      ],
                    ),
                    Positioned(
                      top: kSpacingNone,
                      left: kSpacingNone,
                      right: kSpacingNone,
                      child: ChatHeader(user: recipient),
                    ),
                  ],
                )),
      );
}
