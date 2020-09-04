import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mail_card_preview.dart';
import 'model/email_store.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({Key key, @required this.destination})
      : assert(destination != null),
        super(key: key);

  final String destination;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 4.0;

    return Consumer<EmailStore>(
      builder: (context, model, child) {
        return SafeArea(
          bottom: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: model.emails[model.currentlySelectedInbox].isEmpty
                    ? Center(
                        child: Text(
                          'Empty in ${model.currentlySelectedInbox.toLowerCase()}',
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsetsDirectional.only(
                          start: horizontalPadding,
                          end: horizontalPadding,
                        ),
                        child: Column(
                          children: [
                            for (int index = 0;
                                index < model.emails[destination].length;
                                index++) ...[
                              MailPreviewCard(
                                id: index,
                                email:
                                    model.emails[destination].elementAt(index),
                                onDelete: () =>
                                    model.deleteEmail(destination, index),
                                onStar: () =>
                                    model.starEmail(destination, index),
                              ),
                              const SizedBox(height: 4),
                            ],
                            const SizedBox(height: kToolbarHeight),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
