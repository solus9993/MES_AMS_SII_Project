import 'package:TrackerApp/utils/commons.dart';
import 'package:flutter/material.dart';
import 'package:TrackerApp/models/Zone.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
// import 'camera_screen.dart';

class ZoneDialog extends StatefulWidget {
  final Zone zone;
  ZoneDialog(this.zone);
  @override
  _ZoneDialogState createState() => new _ZoneDialogState(this.zone);
}

class _ZoneDialogState extends State<ZoneDialog> {
  final txtName = TextEditingController();
  final insideLimit = TextEditingController();
  final Zone zone;
  String addString = 'ADD';
  Icon addIcon = Icon(Icons.add);
  String txtMsg = '';
  int colorValue;
  _ZoneDialogState(this.zone);

  @override
  void initState() {
    super.initState();
    if (zone.id != null) {
      addString = 'EDIT';
      addIcon = Icon(Icons.edit);
    }
  }

  @override
  Widget build(BuildContext context) {
    Commons.log('##buildDialog##');
    Commons.log(zone.insideLimit);
    txtName.text = zone.name ?? '';
    insideLimit.text = zone.insideLimit!=null?zone.insideLimit.toString():'';
    colorValue = zone.getColor();
    return AlertDialog(
      title: Text(
        addString + ' ZONE',
        style: Commons.textStylePrimary,
      ),
      content: SingleChildScrollView(
        child: Column(children: <Widget>[
          TextField(
            controller: txtName,
            decoration: InputDecoration(hintText: 'Name'),
            onChanged: (name) => zone.setName(name),
          ),
          TextField(
            controller: insideLimit,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Limit inside'),
            onChanged: (limit) => zone.setInsideLimit(int.tryParse(limit)),
          ),
          Text(
            txtMsg,
            style: TextStyle(color: Colors.red, height: 2),
          ),
          FlatButton(
            color: Color(zone.getColor()).withOpacity(0.1),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    "Zone Color",
                    textAlign: TextAlign.center,
                    style: Commons.textStylePrimary,
                  ),
                  content: CircleColorPicker(
                    initialColor: Color(zone.getColor()),
                    onChanged: (color) {
                      colorValue = color.value;
                      // print(zone.getColor());
                    },
                    size: const Size(240, 240),
                    strokeWidth: 4,
                    thumbSize: 36,
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        zone.setColor(colorValue);
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                      child: Text("Confirm"),
                    ),
                    FlatButton(
                      child: Text('cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              );
            },
            child: Text(
              "Change zone color",
              style: TextStyle(
                color: Color(zone.getColor()),
              ),
            ),
          ),
        ]),
      ),
      actions: <Widget>[
        RaisedButton(
          color: Commons.colorTheme,
          child: Text(
            addString,
            style: TextStyle(
                color: Commons.colorSelectedItemNavigation,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            String msg =
                (zone.id == null) ? await zone.create() : await zone.update();
            if (msg != null) {
              txtMsg = msg;
              setState(() {});
            } else {
              Navigator.of(context).pop(true);
            }
          },
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text("cancel"),
        ),
      ],
    );
  }
}
