// To parse this JSON data, do
//
//     final createOrderModel = createOrderModelFromJson(jsonString);

import 'dart:convert';

import 'package:leads_manager/models/model_PriceList.dart';

import 'model_catalogue.dart';

OrderSummaryModel orderSummaryModelFromJson(String str) =>
    OrderSummaryModel.fromJson(json.decode(str));

String orderSummaryModelToJson(OrderSummaryModel data) =>
    json.encode(data.toJson());

class OrderSummaryModel {
  OrderSummaryModel({
    this.status,
    this.messages,
    this.id,
    this.orderStatus,
    this.remarks,
    this.amountPaid,
    this.orderAmount,
    this.selectedDeliveryBucketId,
    this.originalAmount,
    this.paymentStatus,
    this.paymentType,
    this.pinCode,
    this.firstName,
    this.middleName,
    this.lastName,
    this.customerName,
    this.customerNumber,
    this.merchantName,
    this.clientGroupId,
    this.flatNo,
    this.community,
    this.userId,
    this.applicationNo,
    this.applicationName,
    this.city,
    this.lastModifiedTime,
    this.createdOn,
    this.houseNo,
    this.deliveryTime,
    this.orderDetails,
    this.promotion,
    this.shipment,
    this.pricelist,
    this.coupon,
    this.validTill,
    this.deliveryCharges,
    this.previousBalance,
    this.referredBy,
    this.lastUpdatedBy,
    this.isPickup,
    this.merchantRemarks,
  });

  String? status;
  List<String>? messages;
  int? id;
  String? orderStatus;
  String? remarks;
  double? amountPaid;
  double? orderAmount;
  int? selectedDeliveryBucketId;
  double? originalAmount;
  String? paymentStatus;
  dynamic paymentType;
  int? pinCode;
  String? firstName;
  String? middleName;
  String? lastName;
  String? customerName;
  String? customerNumber;
  String? merchantName;
  int? clientGroupId;
  String? flatNo;
  String? community;
  int? userId;
  String? applicationNo;
  String? applicationName;
  String? city;
  DateTime? lastModifiedTime;
  DateTime? createdOn;
  String? houseNo;
  String? deliveryTime;
  List<Sku>? orderDetails;
  dynamic promotion;
  dynamic shipment;
  PricelistMaster? pricelist;
  dynamic coupon;
  double? deliveryCharges;
  double? previousBalance;
  String? referredBy;
  dynamic lastUpdatedBy;
  bool? isPickup;
  String? merchantRemarks;
  String?  validTill;
  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) =>
      OrderSummaryModel(
        status: json["status"],
        messages: [],
        id: json["id"],
        orderStatus: json["orderStatus"],
        remarks: json["remarks"],
        amountPaid:
            json["amountPaid"] == null ? 0.0 : json["amountPaid"].toDouble(),
        orderAmount:
            json["orderAmount"] == null ? 0.0 : json["orderAmount"].toDouble(),
        selectedDeliveryBucketId: json["selectedDeliveryBucketId"],
        originalAmount: json["originalAmount"],
        paymentStatus: json["paymentStatus"],
        paymentType: json["paymentType"],
        pinCode: json["pinCode"],
        firstName: json["firstName"],
        middleName: json["middleName"],
        lastName: json["lastName"],
        customerName: json["customerName"],
        customerNumber: json["customerNumber"],
        merchantName: json["merchantName"],
        clientGroupId: json["clientGroupId"],
         validTill:json[ "validTill"],
        flatNo: json["flatNo"],
        community: json["community"],
        userId: json["userId"],
        applicationNo: json["applicationNo"],
        applicationName: json["applicationName"],
        city: json["city"],
        lastModifiedTime: json["lastModifiedTime"] == null
            ? null
            : DateTime.parse(json["lastModifiedTime"]),
        createdOn: json["createdOn"] == null
            ? null
            : DateTime.parse(json["createdOn"]),
        houseNo: json["houseNo"],
        deliveryTime: json["deliveryTime"],
        orderDetails: json["orderDetails"] == null
            ? null
            : List<Sku>.from(
                json["orderDetails"].map((x) => Sku.fromJsonForOrderDetail(x))),
        promotion: json["promotion"],
        shipment: json["shipment"],
        pricelist: json["pricelist"] == null
            ? null
            : PricelistMaster.fromJson(json["pricelist"]),
        coupon: json["coupon"],
        deliveryCharges: json["deliveryCharges"],
        previousBalance: json["previousBalance"],
        referredBy: json["referredBy"],
        lastUpdatedBy: json["lastUpdatedBy"],
        isPickup: json["isPickup"] ?? false,
        merchantRemarks: json["merchantRemarks"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "orderStatus": orderStatus,
        "remarks": remarks,
        "amountPaid": amountPaid,
        "orderAmount": orderAmount,
        "selectedDeliveryBucketId": selectedDeliveryBucketId,
        "originalAmount": originalAmount,
        "paymentStatus": paymentStatus,
        "paymentType": paymentType,
        "pinCode": pinCode,
        "firstName": firstName,
        "middleName": middleName,
        "lastName": lastName,
        "customerName": customerName,
        "customerNumber": customerNumber,
        "merchantName": merchantName,
        "clientGroupId": clientGroupId,
        "flatNo": flatNo,
        "community": community,
        "userId": userId,
         "validTill":validTill,
        "applicationNo": applicationNo,
        "applicationName": applicationName,
        "city": city,
        "lastModifiedTime": lastModifiedTime  !=null?lastModifiedTime!.toIso8601String() : null,
        "createdOn": createdOn!=null?createdOn!.toIso8601String() : DateTime.now().toIso8601String(),
        "houseNo": houseNo,
        "deliveryTime": deliveryTime,
        "orderDetails": orderDetails == null
            ? []
            : List<dynamic>.from(
                orderDetails!.map((x) => x.toJsonFororderDetail())),
        "promotion": promotion,
        "shipment": shipment,
        "pricelist": pricelist == null ? null : pricelist!.toJson(),
        "coupon": coupon,
        "deliveryCharges": deliveryCharges,
        "previousBalance": previousBalance,
        "referredBy": referredBy,
        "lastUpdatedBy": lastUpdatedBy,
        "isPickup": isPickup,
        "merchantRemarks": merchantRemarks,
      };
}
