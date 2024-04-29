import 'dart:convert';

import 'package:flutter/material.dart';

import '../../helper/SharedPrefsHelper.dart';
import '../../helper/networkHelper.dart';
import 'leadsDashboard.dart';
import 'marketingDashboard.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String selectedRadio = 'Last 7 days'; // Initial value for Last 7 days
  List<Map<String, dynamic>> dataSummary = [];

  @override
  void initState() {
    super.initState();
    fetchSummaryData('Last 7 days'); // Fetch data for last 7 days initially
  }

  Future<void> fetchSummaryData(String range) async {
    String? clientGroup = await SharedPrefsHelper().getClientGroupName();
    DateTime now = DateTime.now();
    DateTime pastDate;
    DateTime nextDate;
    switch (range) {
      case 'Today':
        pastDate = DateTime(now.year, now.month, now.day);
        nextDate = pastDate.add(Duration(days: 1));
        break;
      case 'Yesterday':
        nextDate = DateTime(now.year, now.month, now.day + 1);
        pastDate = nextDate.subtract(Duration(days: 2));
        break;
      case 'Last 7 days':
        nextDate = DateTime(now.year, now.month, now.day + 1);
        pastDate = nextDate.subtract(Duration(days: 8));
        break;
      case 'Current month':
        pastDate = DateTime(now.year, now.month, 1);
        nextDate = DateTime(now.year, now.month, now.day + 1);
        break;
      case 'Last month':
        nextDate = DateTime(now.year, now.month, 1);
        pastDate = DateTime(now.year, now.month - 1, 1);
        break;
      case 'Current year':
        pastDate = DateTime(now.year, 1, 1);
        nextDate = DateTime(now.year, now.month, now.day + 1);
        break;
      case 'Last year':
        pastDate = DateTime(now.year - 1, 1, 1);
        nextDate = DateTime(now.year, 1, 1).subtract(Duration(days: 1));
        break;
      default:
        throw Exception('Invalid date range: $range');
    }

    // Get the start of the past date and the next date in seconds since epoch
    int past = pastDate.millisecondsSinceEpoch ~/ 1000;
    int next = nextDate.millisecondsSinceEpoch ~/ 1000;

    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://retail.snap.pe/snappe-services/rest/v1/reportings/merchants/$clientGroup/crm-reports?timefrom=$past&timeto=$next'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      final parsed = json.decode(response.body);
      final List<dynamic> dataList = parsed['reports'];
      setState(() {
        dataSummary = dataList
            .map((json) =>
                {'statusName': json['statusName'], 'value': json['value']})
            .toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Leads"),
              Tab(text: "Marketing"),
            ],
          ),
          title: Text('Dashboard'),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Select Date Range"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          RadioListTile(
                            value: 'Today',
                            groupValue: selectedRadio,
                            title: Text("Today"),
                            onChanged: (val) {
                              setState(() {
                                selectedRadio = val as String;
                              });
                              fetchSummaryData(selectedRadio);
                              Navigator.of(context).pop();
                            },
                          ),
                          RadioListTile(
                              value: "Yesterday",
                              groupValue: selectedRadio,
                              title: Text("Yesterday"),
                              onChanged: (val) {
                                setState(() {
                                  selectedRadio = val as String;
                                });
                                fetchSummaryData(selectedRadio);
                                Navigator.of(context).pop();
                              }),
                          RadioListTile(
                            value: "Last 7 days",
                            groupValue: selectedRadio,
                            title: Text("Last 7 days"),
                            onChanged: (val) {
                              setState(() {
                                selectedRadio = val as String;
                              });
                              fetchSummaryData(selectedRadio);
                              Navigator.of(context).pop();
                            },
                          ),
                          RadioListTile(
                            value: 'Current month',
                            groupValue: selectedRadio,
                            title: Text('Current month'),
                            onChanged: (val) {
                              setState(() {
                                selectedRadio = val as String;
                              });
                              fetchSummaryData(selectedRadio);
                              Navigator.of(context).pop();
                            },
                          ),
                          RadioListTile(
                            value: 'Last month',
                            groupValue: selectedRadio,
                            title: Text('Last month'),
                            onChanged: (val) {
                              setState(() {
                                selectedRadio = val as String;
                              });
                              fetchSummaryData(selectedRadio);
                              Navigator.of(context).pop();
                            },
                          ),
                          RadioListTile(
                            value: 'Current year',
                            groupValue: selectedRadio,
                            title: Text('Current year'),
                            onChanged: (val) {
                              setState(() {
                                selectedRadio = val as String;
                              });
                              fetchSummaryData(selectedRadio);
                              Navigator.of(context).pop();
                            },
                          ),
                          RadioListTile(
                            value: 'Last year',
                            groupValue: selectedRadio,
                            title: Text('Last year'),
                            onChanged: (val) {
                              setState(() {
                                selectedRadio = val as String;
                              });
                              fetchSummaryData(selectedRadio);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: Icon(Icons.calendar_month),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            LeadsDashboard(data: dataSummary, selectedRadio: selectedRadio),
            MarketingDashboard(selectedRadio: selectedRadio)
          ],
        ),
      ),
    );
  }
}
