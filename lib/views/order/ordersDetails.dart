import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../Controller/orderAction_controller.dart';
import '../../constants/colorsConstants.dart';
import '../../models/model_orders.dart';
import '../../utils/snapPeNetworks.dart';
import '../../utils/snapPeUI.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/styleConstants.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool isPendingOrder;
  final Order order;
  final VoidCallback onBack;
  const OrderDetailsScreen(
      {Key? key,
      required this.orderId,
      required this.isPendingOrder,
      required this.order,
      required this.onBack})
      : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order? order;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var response = await SnapPeNetworks()
        .getOrderDetail(widget.orderId ?? 0, widget.isPendingOrder);

    setState(() {
      order = orderFromJson(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBack();

        return true;
      },
      child: Scaffold(
        appBar: buildAppBar(),
        backgroundColor: Colors.grey[200],
        body: buildBodyContent(),
      ),
    );
  }

  buildBodyContent() {
    if (order == null) {
      return Center(
        child: CupertinoActivityIndicator(radius: 20),
      );
    }
    return ListView(children: <Widget>[
      ordersDetailsTable(),
      customerDetailsCard(),
      deliveryScheduleCard(),
      actionCard()
    ]);
  }

  customerDetailsCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Customer Details',
                    style: TextStyle(
                        fontSize: kBigFontSize, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
              child: Wrap(
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: 'Name : ',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    TextSpan(
                      text: '${order?.customerName ?? ""}',
                      style: TextStyle(
                          fontSize: kMediumFontSize, color: kLightTextColor),
                    ),
                  ])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
              child: Wrap(
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: 'Address : ',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    TextSpan(
                      text: '${order?.flatNo ?? ""}',
                      style: TextStyle(
                          fontSize: kMediumFontSize, color: kLightTextColor),
                    ),
                  ])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
              child: Wrap(
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: 'City & Pincode : ',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    TextSpan(
                      text: '${(order?.city) ?? ""} , ${order?.pinCode ?? ""}',
                      style: TextStyle(
                          fontSize: kMediumFontSize, color: kLightTextColor),
                    ),
                  ])),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  deliveryScheduleCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Schedule',
                    style: TextStyle(
                        fontSize: kBigFontSize, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
              child: Wrap(
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: 'Delivery Date : ',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    TextSpan(
                      text: '${order?.deliveryTime ?? ""}',
                      style: TextStyle(
                          fontSize: kMediumFontSize, color: kLightTextColor),
                    ),
                  ])),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  actionCard() {
    OrderActionController actionController = new OrderActionController();
    final paymentStatusItems = [
      'Select',
      'PENDING',
      'NOT_REQUIRED',
      'COMPLETED',
      'PARTIAL',
      'CANCELLED',
      'FULL_REFUND',
      'PARTIAL_REFUND'
    ];
    final orderStatusItems = ['Select', 'SHIPPED', 'DELIVERED', 'CANCELLED'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Action',
                    style: TextStyle(
                        fontSize: kBigFontSize, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
              child: Wrap(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Order Status : ',
                        style: TextStyle(
                            fontSize: kMediumFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),

                        // dropdown below..
                        child: Obx(() => DropdownButton<String>(
                              value: actionController.selectedOrderStatus.value,
                              onChanged: (x) {
                                actionController.setOrderStatus(x!);
                              },
                              items: orderStatusItems
                                  .map<DropdownMenuItem<String>>(
                                      (String value) =>
                                          DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          ))
                                  .toList(),
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 32,
                              underline: SizedBox(),
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 55,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Payment Status : ',
                        style: TextStyle(
                            fontSize: kMediumFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),

                        // dropdown below..
                        child: Obx(() => DropdownButton<String>(
                              value:
                                  actionController.selectedPaymentStatus.value,
                              onChanged: (x) {
                                actionController.setPaymentStatus(x!);
                              },
                              items: paymentStatusItems
                                  .map<DropdownMenuItem<String>>(
                                      (String value) =>
                                          DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          ))
                                  .toList(),

                              // add extra sugar..
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 32,
                              underline: SizedBox(),
                            )),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            ElevatedButton(
                onPressed: () {
                  SnapPeNetworks().updateOrder(
                      actionController.selectedOrderStatus.value == "Select"
                          ? null
                          : actionController.selectedOrderStatus.value,
                      actionController.selectedPaymentStatus.value == "Select"
                          ? null
                          : actionController.selectedPaymentStatus.value,
                      widget.order);
                  Navigator.pop(context);
                },
                child: Text("Update")),
            ElevatedButton(
                onPressed: () {
                  SnapPeNetworks().getQRCode(order!);
                },
                child: Text("Show QR Code")),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  buildAppBar() {
    var id = "";
    var orderDate = "";
    if (order != null) {
      id = "${order?.id}";

      DateTime tempDate = DateTime.parse("${order?.createdOn}");
      orderDate = DateFormat().format(tempDate);
    }
    return AppBar(
      toolbarHeight: 80,
      actions: [
        IconButton(
            onPressed: () async {
              var url = "tel:${order?.customerNumber! ?? ""}";
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            icon: Image.asset("assets/icon/callIcon.png")),
        IconButton(
            onPressed: () async {
              var url =
                  "https://wa.me/${order?.customerNumber!}?text=Hello ${order?.customerName!}";
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            icon: Image.asset("assets/icon/whatsappIcon.png"))
      ],
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SnapPeUI().appBarText("Order #$id", kBigFontSize),
        SnapPeUI().appBarSubText("$orderDate", kSmallFontSize),
      ]),
    );
  }

  ordersDetailsTable() {
    List<DataRow> rowList = order!.orderDetails!
        .map(
          (e) => DataRow(cells: [
            DataCell(SizedBox(width: 30, height: 30, child: Text("")
                // e.images!.isEmpty
                //     ? Text("")
                //     : Image.network("${e.images![0].imageUrl}"),
                )),
            DataCell(SizedBox(
                width: 150,
                child: Flex(
                  mainAxisAlignment: MainAxisAlignment.center,
                  direction: Axis.vertical,
                  children: [Flexible(child: Text("${e.displayName ?? ""}"))],
                ))),
            DataCell(Text("${e.measurement ?? ""}")),
            DataCell(Text("${e.unit?.name ?? ""}")),
            DataCell(Text("${e.quantity ?? "0"}")),
            DataCell(Text("₹ ${e.sellingPrice ?? "0.0"}")),
            DataCell(Text("₹ ${e.totalAmount ?? "0.0"}")),
          ]),
        )
        .toList();

    rowList.add(DataRow(cells: [
      DataCell(Text("")),
      DataCell(Text("(+) Delivery Charges")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("₹ ${order?.deliveryCharges ?? "0.0"}")),
    ]));

    rowList.add(DataRow(cells: [
      DataCell(Text("")),
      DataCell(Text("(-) Discount")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text(
          "- ₹ ${order?.promotion == null ? 0.0 : (order?.promotion?.maximumDiscount?.toStringAsFixed(1)) ?? 0.0}")),
    ]));

    rowList.add(DataRow(cells: [
      DataCell(Text("")),
      DataCell(
          Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text("")),
      DataCell(Text(
        "₹ ${order?.orderAmount ?? "0.0"}",
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
    ]));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            dataRowHeight: 50,
            columnSpacing: 20,
            columns: [
              DataColumn(label: Text("#")),
              DataColumn(
                  label: Text('Items',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Measurement',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Unit(s)',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Qty',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Price',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Total',
                      style: TextStyle(
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold))),
            ],
            rows: rowList,
          ),
        ),
      ),
    );
  }
}
