import 'package:flutter/material.dart';
import '../marketing/addpromotions.dart';
import 'dashboard/notneeded.dart';
import '../constants/colorsConstants.dart';
import '../helper/SharedPrefsHelper.dart';
import '../utils/snapPeNetworks.dart';
import '../utils/snapPeUI.dart';
import 'package:get/get.dart';
import '../widgets/errowidget.dart';
import 'dashboard/dashboard.dart';
import 'support/support.dart';
import 'package:sms_autofill/sms_autofill.dart';

class CustomDrawer extends StatefulWidget {
  final BuildContext context;

  CustomDrawer({required this.context});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  SnapPeNetworks snapPeNetworks = SnapPeNetworks();
  SnapPeUI snapPeUI = SnapPeUI();
  List<Map<String, dynamic>> properties = [];
  bool _switchValue = false;

  @override
  void initState() {
    super.initState();
    storeLeadSaveProperty();
  }

  Future<void> storeLeadSaveProperty() async {
    SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
    String propertyValue = await sharedPrefsHelper.getProperties() ?? '';
    print("called and $propertyValue");
    setState(() {
      _switchValue = propertyValue == "Yes" ? true : false;
      SnapPeUI().sendSwitchValue(_switchValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        DrawerHeader(
            child: snapPeUI.appLogoDrawer(),
            decoration: BoxDecoration(color: kPrimaryColor.withOpacity(1))),
        ListTile(
          leading: Icon(Icons.donut_large),
          title: Text("Dashboard"),
          onTap: () {
            Get.back();
          //  Get.to(() => Dashboard());
           Get.to(() => DashBoardScreen());

          },
        ),
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ListTile(
              leading: Icon(Icons.donut_large),
              title: Row(
                children: [
                  Text("Save Lead from Calls"),
                  Spacer(),
                  Switch(
                    value: _switchValue,
                    onChanged: (bool value) {
                      setState(() {
                        _switchValue = value;

                        properties = [
                          {
                            "status": "OK",
                            "messages": [],
                            "propertyName": "create_lead_on_call",
                            "propertyType": "client_user_attributes",
                            "name": "Create Leads From Call",
                            "id": 9804159,
                            "propertyValue":
                                _switchValue == true ? "Yes" : "No",
                            "propertyAllowedValues": "yes,no",
                            "propertyDefaultValues": "no",
                            "isEditable": true,
                            "remarks": "Notification Sound ",
                            "category": "Lead",
                            "isVisibleToClient": true,
                            "interfaceType": "drop_down",
                            "pricelistCode": null
                          }
                        ];
                      });
                      SnapPeUI().sendSwitchValue(value);
                      if (value == true) {
                        SharedPrefsHelper().setProperties("Yes");
                      } else {
                        SharedPrefsHelper().setProperties("No");
                      }
                      snapPeNetworks.changeProperty(properties);
                    },
                  ),
                ],
              ),
              onTap: () {},
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.donut_large),
          title: Text("Switch Business"),
          onTap: () {
            Get.back();
            snapPeUI.showSelectMerchantDialog(context);
          },
        ),
         ListTile(
          leading: Icon(Icons.donut_large),
          title: Text("Add Promotions"),
          onTap: () {
          Get.to(()=> AddPromotions());
          }
        ),
        ListTile(
          leading: Icon(Icons.donut_large),
          title: Text("Privacy Policy"),
          onTap: () {
            Navigator.of(context).pop();
            snapPeUI.dialogbox(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.donut_large),
          title: Text("Support"),
          onTap: () {
            Get.back();
            Get.to(() => SupportPage());
          },
        ),
        ListTile(
          leading: Icon(Icons.donut_large),
          title: Text("Logout"),
          onTap: () {
            // FirebaseCrashlytics.instance.crash();
            sharedPrefsHelper.removeResponse();

            SnapPeNetworks().logOut();
          },
        ),
        
      ],
    )); // your custom drawer widget here
  }
}
