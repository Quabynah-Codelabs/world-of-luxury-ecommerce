import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:handyman/app/model/prefs_provider.dart';
import 'package:handyman/app/widget/user_avatar.dart';
import 'package:handyman/core/constants.dart';
import 'package:handyman/core/size_config.dart';
import 'package:handyman/data/local_database.dart';
import 'package:handyman/domain/models/user.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:random_color/random_color.dart';

/// Each item in the [Conversation] list
class ChatListItem extends StatefulWidget {
  final Conversation conversation;
  final BaseUser sender;
  final BaseUser recipient;
  final Function(Conversation) onTap;

  const ChatListItem(
      {Key key,
      @required this.conversation,
      @required this.sender,
      @required this.recipient,
      @required this.onTap})
      : super(key: key);

  @override
  _ChatListItemState createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  double _kWidth;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _kWidth = size.width;

    return Consumer<PrefsProvider>(
      builder: (_, provider, __) {
        final isMe = widget.conversation.author == provider.userId;
        final conversation = widget.conversation;
        final color =
            provider.isLightTheme ? kChatBackgroundLight : kChatBackgroundDark;
        final textAlignment = isMe ? TextAlign.end : TextAlign.start;

        return InkWell(
          onTap: () => widget.onTap(conversation),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isMe
                  ? SizedBox.shrink()
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        UserAvatar(
                          url: widget.recipient?.user?.avatar ?? "",
                          radius: kSpacingX42,
                          ringColor: RandomColor(1).randomColor(
                              colorBrightness: ColorBrightness.dark),
                        ),
                        SizedBox(
                          width: getProportionateScreenWidth(kSpacingX8),
                        ),
                      ],
                    ),
              Container(
                padding: EdgeInsets.only(
                  left: isMe
                      ? getProportionateScreenWidth(kSpacingX8)
                      : getProportionateScreenWidth(kSpacingX16),
                  right: isMe
                      ? getProportionateScreenWidth(kSpacingX16)
                      : getProportionateScreenWidth(kSpacingX4),
                  top: getProportionateScreenWidth(kSpacingX8),
                  bottom: getProportionateScreenWidth(kSpacingX16),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(kSpacingX16),
                    topRight: Radius.circular(kSpacingX16),
                    bottomLeft:
                        isMe ? Radius.circular(kSpacingX16) : Radius.zero,
                    bottomRight:
                        isMe ? Radius.zero : Radius.circular(kSpacingX16),
                  ),
                  color: color,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // TODO: Add support for images & timestamps
                    // Use  -> Jiffy.unix(timestampInMilliseconds).yMd
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: _kWidth * 0.5,
                      ),
                      child: Text(
                        conversation.content,
                        textAlign: textAlignment,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// List of [Conversation]s
class ChatMessages extends StatefulWidget {
  final Stream<List<Conversation>> messages;
  final BaseUser recipient;
  final BaseUser sender;

  const ChatMessages(
      {Key key,
      @required this.messages,
      @required this.recipient,
      @required this.sender})
      : super(key: key);

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Conversation>>(
      stream: widget.messages,
      builder: (context, snapshot) {
        // FIXME: Add swipe action for instant reply
        return snapshot.hasData
            ? AnimationLimiter(
                child: ListView.separated(
                  padding: EdgeInsets.only(
                      bottom: getProportionateScreenHeight(kSpacingX8)),
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  clipBehavior: Clip.hardEdge,
                  separatorBuilder: (_, __) => SizedBox(
                      height: getProportionateScreenHeight(kSpacingX8)),
                  itemBuilder: (_, index) {
                    final conversation = snapshot.data[index];
                    return AnimationConfiguration.staggeredList(
                      duration: kScaleDuration,
                      position: index,
                      child: SlideAnimation(
                        verticalOffset: kSlideOffset,
                        child: FadeInAnimation(
                          child: ChatListItem(
                            onTap: (_) {},
                            conversation: conversation,
                            recipient: widget.recipient,
                            sender: widget.sender,
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: snapshot.data.length,
                ),
              )
            : Container();
      });
}
