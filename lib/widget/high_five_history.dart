import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/main.dart';
import 'package:highfive/model/change_notifier_highfive.dart';
import 'package:highfive/model/contacts_holder.dart';
import 'package:highfive/model/high_five.dart';
import 'package:highfive/model/high_five_data.dart';
import 'package:highfive/model/high_fives_holder.dart';
import 'package:highfive/repository/repository.dart';
import 'package:highfive/widget/high_five_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HighFiveHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    var highFivesModel = context.watch<ChangeNotifierHighFive>();
    Widget child = new Text('У вас нет непросмотренных пятюнь');
    if (highFivesModel.highFives.length > 0) {
      child = new ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: highFivesModel.highFives.map(
            (highfive) => Dismissible(
              onDismissed: (direction) {
                deleteRow(highfive.documentId);
                highFivesModel.highFives.remove(highfive);
                highFivesModel.notifyListeners();
              },
              background: Container(color: Colors.red),
              key: UniqueKey(),
              child: new ListTile(
                onTap: () async {
                  handleHighFiveData(context, highfive);
                },
                tileColor: Theme.of(context).cardColor,
                leading: FutureBuilder(
                  future: new HighFivesHolder().highFivesImageMap,
                  builder: (BuildContext context, AsyncSnapshot<Map<int, Image>> snapshot) {
                    if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                      return new Hero(
                        child: snapshot.data[highfive.highfiveId],
                        tag: highfive.documentId + 'highfivepic',
                      );
                    }
                    return Icon(
                      Icons.data_usage,
                      color: Colors.blue,
                    );
                  },
                ),
                title: new FutureBuilder<String>(
                  future: new ContactsHolder().phoneToContactMap.then((contacts) => contacts[highfive.sender].displayName),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                      return buildRichText(highfive, snapshot.data);
                    }
                    return buildRichText(highfive, highfive.sender);
                  },
                ),
                trailing: new Text(formatter.format(DateTime.fromMillisecondsSinceEpoch(highfive.timestamp))),
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
          onPressed: () => Navigator.of(context).push(new HighFiveList()),
        ),
      ),
    );
  }

  ChangeNotifierProvider<ValueNotifier<bool>> buildRichText(HighFiveData highfive, String text) {
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
  String text;

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

HighFiveData parseHighFiveData(Map<String, dynamic> data) {
  var highFiveData =
      new HighFiveData(data['sender'], int.parse(data['highfiveId']), data['comment'], int.parse(data['timestamp']), data['id']);
  highFiveData.acknowledged = false;
  return highFiveData;
}
