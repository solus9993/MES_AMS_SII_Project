import 'package:TrackerApp/models/Zone.dart';
import 'package:TrackerApp/providers/ZoneProvider.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:TrackerApp/views/zone/ZoneCreate.dart';
import 'package:TrackerApp/views/zone/ZoneDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/**
 * Displays List of zones.
 * Can also edit and delete zones
 */
class ZoneList extends StatefulWidget {
  ZoneList({Key key}) : super(key: key);

  @override
  _ZoneListState createState() => _ZoneListState();
}

class _ZoneListState extends State<ZoneList> {
  var _tapPosition;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ZoneProvider>(builder: (context, data, child) {
      return GestureDetector(
        child: listViewWidget(data),
        onTapDown: _storePosition,
      );
    });
  }

  Widget listViewWidget(data) {
    print(data.getList());
    List<Widget> _widgetList = <Widget>[];
    List<Zone> list = data.getList();
    if (list != null) {
      for (var item in list) {
        _widgetList.add(
          ListTile(
              leading: Icon(
                Icons.map,
                color: Color(item.getColor()),
              ),
              title: Text(
                item.getName(),
                style: Commons.textStylePrimary,
              ),
              enabled: true,
              onLongPress: _onLongPressListTile(context, item),
              onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ZoneDetailsPage(item),
                      ),
                    );
                    Provider.of<ZoneProvider>(context, listen: false).notify();
                  },
              subtitle: Row(
                children: <Widget>[
                  Text('Owner: ' + item.ownerUser.name.toString()),
                  SizedBox(
                    width: 20,
                  ),
                  Text('Count: ' + item.insideCount.toString()),
                  item.insideLimit != null
                      ? Text('/' + item.insideLimit.toString())
                      : Text(''),
                ],
              )),
        );
      }
    }
    return ListView(children: _widgetList);
  }

  _onLongPressListTile(context, item) {
    return () async {
      final RenderBox overlay = Overlay.of(context).context.findRenderObject();
      String selected = await showMenu<String>(
        context: context,
        position: RelativeRect.fromRect(
            _tapPosition & Size(40, 40), // smaller rect, the touch area
            Offset.zero & overlay.size // Bigger rect, the entire screen
            ),
        items: ["Edit", "Delete"].map((String popupRoute) {
          return new PopupMenuItem<String>(
            child: new Text(popupRoute),
            value: popupRoute,
          );
        }).toList(),
      );
      Commons.log(selected);

      if (selected != null) {
        if (selected == 'Edit') _edit(item);
        if (selected == 'Delete') _delete(item);
        // setState(() {});
      }
    };
  }

  Future<void> _edit(Zone item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZoneCreate(zone: item),
      ),
    );
    Provider.of<ZoneProvider>(context, listen: false).notify();
  }

  void _delete(Zone item) {
    Commons.confirmationDialog(
        context,
        'Delete Zone',
        Column(children: [
          Text('Do you want to delete the zone:'),
          Text(
            item.getName(),
            style: TextStyle(
                color: Color(item.getColor()), fontWeight: FontWeight.bold),
          )
        ]),
        'DELETE',
        action: Provider.of<ZoneProvider>(context, listen: false).deleteItem,
        params: item);
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}
