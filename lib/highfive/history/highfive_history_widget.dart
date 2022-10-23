import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/home/home_bloc.dart';
import 'package:highfive/home/home_event.dart';
import 'package:highfive/locator/locator.dart';
import 'package:highfive/model/contacts_holder.dart';
import 'package:highfive/model/high_five.dart';
import 'package:highfive/model/high_five_data.dart';
import 'package:highfive/model/high_fives_holder.dart';
import 'package:highfive/route/navigation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HighfiveHistoryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    HomeBloc homeBloc = context.read();
    Widget child = new Text('У вас нет непросмотренных пятюнь');
    var highfives = homeBloc.state.highfives;
    if (highfives.length > 0) {
      child = new ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: highfives.map(
            (highfive) => Dismissible(
              onDismissed: (direction) {
                deleteHighFive(highfive, homeBloc);
              },
              background: Container(color: Colors.red),
              key: UniqueKey(),
              child: new ListTile(
                onLongPress: () async {
                  var willDelete = await locator.get<NavigationService>().pushNamed("delete-highfive");
                  if (willDelete != null && willDelete) {
                    deleteHighFive(highfive, homeBloc);
                  }
                },
                onTap: () async {
                  homeBloc.add(new ShowHighfive(highfive));
                },
                tileColor: Theme.of(context).cardColor,
                leading: FutureBuilder(
                  future: new HighFivesHolder().getById(highfive.highfiveId),
                  builder: (BuildContext context, AsyncSnapshot<HighFive> snapshot) {
                    if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                      return new Hero(
                        child: snapshot.data.getNetworkCachedImage(),
                        tag: highfive.documentId + 'highfivepic',
                      );
                    }
                    return CircularProgressIndicator();
                  },
                ),
                title: new FutureBuilder<String>(
                  future: new ContactsHolder().phoneToContactMap.then((contacts) => contacts[highfive.sender].displayName),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                      return _buildRichText(highfive, snapshot.data);
                    }
                    return _buildRichText(highfive, highfive.sender);
                  },
                ),
                trailing: new Text(formatter.format(DateTime.fromMillisecondsSinceEpoch(highfive.timestamp)).replaceFirst(new RegExp(" "), "\n")),
              ),
            ),
          ),
        ).toList(),
      );
    }
    return new Scaffold(
      body: new SafeArea(
        child: new Container(child: child),
      ),
      bottomNavigationBar: new BottomAppBar(
        child: new ElevatedButton(
          child: new Text('Хочу послать пятюню'),
          onPressed: () => Navigator.of(context).pushNamed("highfive-list"),
        ),
      ),
    );
  }

  void deleteHighFive(HighFiveData highfive, HomeBloc homeBloc) {
    homeBloc.add(DeleteHighfive(highfive));
  }

  ChangeNotifierProvider<ValueNotifier<bool>> _buildRichText(HighFiveData highfive, String text) {
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (BuildContext context) {
        var valueNotifier = new ValueNotifier<bool>(highfive.acknowledged);
        highfive.acknowledgedNotifier = valueNotifier;
        return valueNotifier;
      },
      child: new SenderRichText(text),
    );
  }
}

class SenderRichText extends StatelessWidget {
  final String text;

  SenderRichText(this.text);

  @override
  Widget build(BuildContext context) {
    return new Consumer<ValueNotifier<bool>>(builder: (context, valueNotifier, child) {
      var icon = valueNotifier.value
          ? null
          : new Icon(
              Icons.fiber_new_outlined,
              color: Colors.deepPurpleAccent,
              size: 30,
            );
      return new RichText(
          text: new TextSpan(
              children: [new TextSpan(text: text), if (icon != null) WidgetSpan(child: icon)],
              style: new TextStyle(color: Colors.black, fontSize: 20)));
    });
  }
}
