import 'package:get/get.dart';
import '../models/model_LeadNotes.dart';
import '../models/model_leadDetails.dart';
import '../utils/snapPeNetworks.dart';

class LeadDetailsController extends GetxController {
  Rx<LeadDetailsModel> leadDetailsModel = LeadDetailsModel().obs;
  Rx<LeadNotesModel> leadNotesModel = LeadNotesModel().obs;

  LeadDetailsController(int? leadId) {
    loadData(leadId);
  }

  loadData(int? leadId) async {
    //Get Lead Details
    String? response = await SnapPeNetworks().getLeadDetails(leadId);
    if (response != null) {
      leadDetailsModel.value = leadDetailsModelFromJson(response);
    }
    // Get Lead Notes
    String? res = await SnapPeNetworks().getLeadNotes(leadId);
    if (res != null) {
      leadNotesModel.value = leadNotesModelFromJson(res);
    }
  }
}
