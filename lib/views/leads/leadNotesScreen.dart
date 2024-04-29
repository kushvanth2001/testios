import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leads_manager/constants/styleConstants.dart';
import 'package:leads_manager/models/model_leadDetails.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/leads/leadDetails/notesWidget.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/leads/leadsScreen.dart';
import '../../../Controller/leadDetails_controller.dart';
import '../../../Controller/leads_controller.dart';
import '../../../constants/colorsConstants.dart';
import 'package:leads_manager/models/model_lead.dart' as model_lead;
import '../../../models/model_lead.dart';

class LeadNotesScreen extends StatefulWidget {
  final int? leadId;
  final LeadController? leadController;
  final model_lead.Lead? lead;
  final VoidCallback? onBack;
  const LeadNotesScreen(
      {Key? key, this.leadId, this.leadController, this.lead, this.onBack})
      : super(key: key);

  @override
  State<LeadNotesScreen> createState() => _LeadNotesScreenState(leadController);
}

class _LeadNotesScreenState extends State<LeadNotesScreen> {
  late LeadController? leadController;
  _LeadNotesScreenState(LeadController? leadController) {
    this.leadController = leadController;
  }

  bool showLoading = true;

  @override
  void initState() {
    super.initState();
  }

  TextEditingController textController = TextEditingController();

  late model_lead.Lead lead = new model_lead.Lead();

  openCreateNoteDialog(TextEditingController textController) {
    return Get.defaultDialog(
      title: "Create Note",
      content: Column(
        children: [
          TextField(
            controller: textController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: kPrimaryColor))),
            maxLines: 10,
            // maxLength: 200,
            keyboardType: TextInputType.multiline,
          )
        ],
      ),
      textConfirm: "Save",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        leadController?.createNote(widget.leadId, textController.text);
        // Navigator.pop(context);
        // Navigator.pop(context);
        //  Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => LeadNotesScreen(
        //                 leadId: widget.leadId,
        //                 leadController: widget.leadController,
        //               )),
        //     );
        //      Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => LeadNotesScreen(
        //                 leadId: widget.leadId,
        //                 leadController: widget.leadController,
        //               )),
        //     );

        // widget.leadController?.loadData(forcedReload: true);  not working
        Get.back();
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => super.widget));
      },
      onCancel: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final LeadDetailsController controller =
        LeadDetailsController(widget.leadId);

    bool dataLoaded = false;

    // This function is called when the data has finished loading from the API
    void onDataLoaded() {
      setState(() {
        dataLoaded = true;
      });
    }

    buildNotes() {
      if (controller.leadNotesModel.value.leadActions != null &&
          controller.leadNotesModel.value.leadActions!.length != 0) {
        return Expanded(
          child: ListView.builder(
            // reverse: true,
            padding: const EdgeInsets.all(20.0),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: controller.leadNotesModel.value.leadActions!.length,
            itemBuilder: (context, index) {
              return NoteWidget(
                  leadAction:
                      controller.leadNotesModel.value.leadActions![index]);
            },
          ),
        );
      } else {
        return SnapPeUI().noDataFoundImage(msg: "Empty Notes !");
      }
    }

    return WillPopScope(
      onWillPop: () async {
        if (widget.onBack != null) {
          widget.onBack!();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: SnapPeUI().appBarText("Notes", kBigFontSize),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                openCreateNoteDialog(textController);
              },
            ),
          ],
        ),
        body: Column(children: [
          Obx(
            () => buildNotes(),
          ),
        ]),
      ),
    );
  }
}
