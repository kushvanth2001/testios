import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/models/model_application.dart';
import 'package:leads_manager/models/model_assignedTo.dart';
import 'package:leads_manager/models/model_chat.dart';
// import 'package:leads_manager/models/model_assignedTo.dart' ;
import 'package:leads_manager/models/model_customColumn.dart';
import 'package:leads_manager/models/model_leadDetails.dart';
import 'package:leads_manager/models/model_leadDetails.dart'
    as assignedTo_Model;
import 'package:leads_manager/models/model_priority.dart';
import 'package:leads_manager/utils/SharedFunctions.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/leads/leadDetails/appController.dart';
import 'package:leads_manager/views/leads/leadDetails/notesWidget.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
// import 'package:leads_manager/views/leads/leadNotesScreen.dart';
import 'package:leads_manager/views/leads/leadNotesScreen.dart';
import 'package:leads_manager/models/model_LeadStatus.dart';
import '../../../Controller/leadDetails_controller.dart';
import '../../../Controller/leads_controller.dart';
import '../../../constants/colorsConstants.dart';
import 'package:leads_manager/models/model_lead.dart' as model_lead;
import 'package:leads_manager/globals.dart';

class LeadDetails extends StatefulWidget {
  final VoidCallback? onBack;
  final model_lead.Lead? lead;
  final bool? isNewleadd;
  final bool? isFromChat;
  final LeadController leadController;
  final int? leadId;
  final Function openAssignTagsDialog;
  final Function? buildTags;
final bool? frominitallist;
  final void Function(String)? frominitallistcallback;
  final TextEditingController? textController;
  final TextEditingController? txtFollowUpName;
  final TextEditingController? txtDescription;
  final TextEditingController? txtDateTime;
  final Function? menuItems;
  final List<ChatModel>? chatModels;
  final String? firstAppName;
  const LeadDetails({
    Key? key,
    this.onBack,
    this.leadId,
    this.lead,
    required this.leadController,
    this.isNewleadd,
    required this.openAssignTagsDialog,
    this.buildTags,
    this.textController,
    this.txtFollowUpName,
    this.txtDescription,
    this.txtDateTime,
    this.menuItems,
    this.isFromChat,
    this.chatModels,
    this.firstAppName, this.frominitallist, this.frominitallistcallback,
  }) : super(key: key);

  @override
  _LeadDetailsState createState() => _LeadDetailsState(
        leadController,
        buildTags: buildTags,
        menuItems: menuItems,
        textController: textController,
        txtFollowUpName: txtFollowUpName,
        txtDescription: txtDescription,
        txtDateTime: txtDateTime,
      );
}

class _LeadDetailsState extends State<LeadDetails> {
  // LeadDetailsModel leadDetailsModel = LeadDetailsModel();
  late LeadController leadController;
  final Function? buildTags;
  final Function? menuItems;
  final TextEditingController? textController;
  final TextEditingController? txtFollowUpName;
  final TextEditingController? txtDescription;
  final TextEditingController? txtDateTime;

  _LeadDetailsState(
    this.leadController, {
    this.buildTags,
    this.menuItems,
    this.textController,
    this.txtFollowUpName,
    this.txtDescription,
    this.txtDateTime,
  });
  int? _leadId;

  late model_lead.Lead leadModel = new model_lead.Lead();
  late LeadDetailsModel leadDetailsModel = new LeadDetailsModel();
  bool isNewLead = true;
  final customerNameController = TextEditingController();
  final organizationNameController = TextEditingController();
  final mobileNumController = TextEditingController();
  final emailController = TextEditingController();
  final cityNameController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final followUpController = TextEditingController();
  final addressController = TextEditingController();
  final countryController = TextEditingController();
  List<TextEditingController> controllers = [];
  final statusNameController = TextEditingController();
  // final priorityController = TextEditingController();
  final sourceController = TextEditingController();
  final assignedToController = TextEditingController();
  final potentialDealValueController = TextEditingController();
  final actualDealValueController = TextEditingController();
  final assignedByController = TextEditingController();
  final scoreController = TextEditingController();
  TextEditingController customColumnscontroller = TextEditingController();
  TextEditingController dialCodeController = TextEditingController();
  TextEditingController priorityIdController = TextEditingController();

  Map leadStatusIds = {
    'ASSIGNED': 9,
    'CONTACTED': 10,
    'CONVERTED': 15,
    'DEAD': 16,
    'DEMO': 12,
    'FOLLOW UP': 4418774,
    'HOT': 13,
    'INPROGRESS': 11,
    'NEW': 8,
    'NO RESPONSE': 5864590,
  };
  Map leadSourceIds = {
    "Email": 14,
    "WhatsApp": 15,
    "Facebook": 16,
    "Google": 17,
    "Network": 18,
    "Referral": 19,
    "Paid Campaign": 20,
    "Pamphlets": 21,
    "Newspaper": 22,
    "Affilates": 23,
    "Others": 24,
    "Walk In": 25,
    "Phone Call": 26,
    "Website": 27,
    "IndiaMart": 28,
    "JustDial": 29,
    "Web Chat": 30,
    "Instagram": 31,
    "TradeIndia": 32,
    "Aajjo": 33
  };

  final List<Map<String, String>> countryCodes = [
    {"name": "India", "dial_code": "+91", "code": "IN"},
    {"name": "Afghanistan", "dial_code": "+93", "code": "AF"},
    {"name": "Aland Islands", "dial_code": "+358", "code": "AX"},
    {"name": "Albania", "dial_code": "+355", "code": "AL"},
    {"name": "Algeria", "dial_code": "+213", "code": "DZ"},
    {"name": "AmericanSamoa", "dial_code": "+1684", "code": "AS"},
    {"name": "Andorra", "dial_code": "+376", "code": "AD"},
    {"name": "Angola", "dial_code": "+244", "code": "AO"},
    {"name": "Anguilla", "dial_code": "+1264", "code": "AI"},
    // {"name": "Antarctica", "dial_code": "+672", "code": "AQ"},
    {"name": "Antigua and Barbuda", "dial_code": "+1268", "code": "AG"},
    {"name": "Argentina", "dial_code": "+54", "code": "AR"},
    {"name": "Armenia", "dial_code": "+374", "code": "AM"},
    {"name": "Aruba", "dial_code": "+297", "code": "AW"},
    {"name": "Australia", "dial_code": "+61", "code": "AU"},
    {"name": "Austria", "dial_code": "+43", "code": "AT"},
    {"name": "Azerbaijan", "dial_code": "+994", "code": "AZ"},
    {"name": "Bahamas", "dial_code": "+1242", "code": "BS"},
    {"name": "Bahrain", "dial_code": "+973", "code": "BH"},
    {"name": "Bangladesh", "dial_code": "+880", "code": "BD"},
    {"name": "Barbados", "dial_code": "+1246", "code": "BB"},
    {"name": "Belarus", "dial_code": "+375", "code": "BY"},
    {"name": "Belgium", "dial_code": "+32", "code": "BE"},
    {"name": "Belize", "dial_code": "+501", "code": "BZ"},
    {"name": "Benin", "dial_code": "+229", "code": "BJ"},
    {"name": "Bermuda", "dial_code": "+1441", "code": "BM"},
    {"name": "Bhutan", "dial_code": "+975", "code": "BT"},
    {
      "name": "Bolivia, Plurinational State of bolivia",
      "dial_code": "+591",
      "code": "BO"
    },
    {"name": "Bosnia and Herzegovina", "dial_code": "+387", "code": "BA"},
    {"name": "Botswana", "dial_code": "+267", "code": "BW"},
    {"name": "Brazil", "dial_code": "+55", "code": "BR"},
    {
      "name": "British Indian Ocean Territory",
      "dial_code": "+246",
      "code": "IO"
    },
    {"name": "Brunei Darussalam", "dial_code": "+673", "code": "BN"},
    {"name": "Bulgaria", "dial_code": "+359", "code": "BG"},
    {"name": "Burkina Faso", "dial_code": "+226", "code": "BF"},
    {"name": "Burundi", "dial_code": "+257", "code": "BI"},
    {"name": "Cambodia", "dial_code": "+855", "code": "KH"},
    {"name": "Cameroon", "dial_code": "+237", "code": "CM"},

    {"name": "Cape Verde", "dial_code": "+238", "code": "CV"},
    {"name": "Cayman Islands", "dial_code": "+345", "code": "KY"},
    {"name": "Central African Republic", "dial_code": "+236", "code": "CF"},
    {"name": "Chad", "dial_code": "+235", "code": "TD"},
    {"name": "Chile", "dial_code": "+56", "code": "CL"},
    {"name": "China", "dial_code": "+86", "code": "CN"},
    // {"name": "Christmas Island", "dial_code": "+61", "code": "CX"},
    // {"name": "Cocos (Keeling) Islands", "dial_code": "+61", "code": "CC"},
    {"name": "Colombia", "dial_code": "+57", "code": "CO"},
    {"name": "Comoros", "dial_code": "+269", "code": "KM"},
    {"name": "Congo", "dial_code": "+242", "code": "CG"},
    {
      "name": "Congo, The Democratic Republic of the Congo",
      "dial_code": "+243",
      "code": "CD"
    },
    {"name": "Cook Islands", "dial_code": "+682", "code": "CK"},
    {"name": "Costa Rica", "dial_code": "+506", "code": "CR"},
    {"name": "Cote d'Ivoire", "dial_code": "+225", "code": "CI"},
    {"name": "Croatia", "dial_code": "+385", "code": "HR"},
    {"name": "Cuba", "dial_code": "+53", "code": "CU"},
    {"name": "Cyprus", "dial_code": "+357", "code": "CY"},
    {"name": "Czech Republic", "dial_code": "+420", "code": "CZ"},
    {"name": "Denmark", "dial_code": "+45", "code": "DK"},
    {"name": "Djibouti", "dial_code": "+253", "code": "DJ"},
    {"name": "Dominica", "dial_code": "+1767", "code": "DM"},
    {"name": "Dominican Republic", "dial_code": "+1849", "code": "DO"},
    {"name": "Ecuador", "dial_code": "+593", "code": "EC"},
    {"name": "Egypt", "dial_code": "+20", "code": "EG"},
    {"name": "El Salvador", "dial_code": "+503", "code": "SV"},
    {"name": "Equatorial Guinea", "dial_code": "+240", "code": "GQ"},
    {"name": "Eritrea", "dial_code": "+291", "code": "ER"},
    {"name": "Estonia", "dial_code": "+372", "code": "EE"},
    {"name": "Ethiopia", "dial_code": "+251", "code": "ET"},
    {"name": "Falkland Islands (Malvinas)", "dial_code": "+500", "code": "FK"},
    {"name": "Faroe Islands", "dial_code": "+298", "code": "FO"},
    {"name": "Fiji", "dial_code": "+679", "code": "FJ"},
    // {"name": "Finland", "dial_code": "+358", "code": "FI"},
    {"name": "France", "dial_code": "+33", "code": "FR"},
    {"name": "French Guiana", "dial_code": "+594", "code": "GF"},
    {"name": "French Polynesia", "dial_code": "+689", "code": "PF"},
    {"name": "Gabon", "dial_code": "+241", "code": "GA"},
    {"name": "Gambia", "dial_code": "+220", "code": "GM"},
    {"name": "Georgia", "dial_code": "+995", "code": "GE"},
    {"name": "Germany", "dial_code": "+49", "code": "DE"},
    {"name": "Ghana", "dial_code": "+233", "code": "GH"},
    {"name": "Gibraltar", "dial_code": "+350", "code": "GI"},
    {"name": "Greece", "dial_code": "+30", "code": "GR"},
    {"name": "Greenland", "dial_code": "+299", "code": "GL"},
    {"name": "Grenada", "dial_code": "+1473", "code": "GD"},
    {"name": "Guadeloupe", "dial_code": "+590", "code": "GP"},
    {"name": "Guam", "dial_code": "+1671", "code": "GU"},
    {"name": "Guatemala", "dial_code": "+502", "code": "GT"},
    {"name": "Guernsey", "dial_code": "+44", "code": "GG"},
    {"name": "Guinea", "dial_code": "+224", "code": "GN"},
    {"name": "Guinea-Bissau", "dial_code": "+245", "code": "GW"},
    {"name": "Guyana", "dial_code": "+595", "code": "GY"},
    {"name": "Haiti", "dial_code": "+509", "code": "HT"},
    {
      "name": "Holy See (Vatican City State)",
      "dial_code": "+379",
      "code": "VA"
    },
    {"name": "Honduras", "dial_code": "+504", "code": "HN"},
    {"name": "Hong Kong", "dial_code": "+852", "code": "HK"},
    {"name": "Hungary", "dial_code": "+36", "code": "HU"},
    {"name": "Iceland", "dial_code": "+354", "code": "IS"},
    {"name": "Indonesia", "dial_code": "+62", "code": "ID"},
    {
      "name": "Iran, Islamic Republic of Persian Gulf",
      "dial_code": "+98",
      "code": "IR"
    },
    {"name": "Iraq", "dial_code": "+964", "code": "IQ"},
    {"name": "Ireland", "dial_code": "+353", "code": "IE"},
    {"name": "Isle of Man", "dial_code": "+44", "code": "IM"},
    {"name": "Israel", "dial_code": "+972", "code": "IL"},
    {"name": "Italy", "dial_code": "+39", "code": "IT"},
    {"name": "Jamaica", "dial_code": "+1876", "code": "JM"},
    {"name": "Japan", "dial_code": "+81", "code": "JP"},
    {"name": "Jersey", "dial_code": "+44", "code": "JE"},
    {"name": "Jordan", "dial_code": "+962", "code": "JO"},
    {"name": "Kazakhstan", "dial_code": "+77", "code": "KZ"},
    {"name": "Kenya", "dial_code": "+254", "code": "KE"},
    {"name": "Kiribati", "dial_code": "+686", "code": "KI"},
    {
      "name": "Korea, Democratic People's Republic of Korea",
      "dial_code": "+850",
      "code": "KP"
    },
    {
      "name": "Korea, Republic of South Korea",
      "dial_code": "+82",
      "code": "KR"
    },
    {"name": "Kuwait", "dial_code": "+965", "code": "KW"},
    {"name": "Kyrgyzstan", "dial_code": "+996", "code": "KG"},
    {"name": "Laos", "dial_code": "+856", "code": "LA"},
    {"name": "Latvia", "dial_code": "+371", "code": "LV"},
    {"name": "Lebanon", "dial_code": "+961", "code": "LB"},
    {"name": "Lesotho", "dial_code": "+266", "code": "LS"},
    {"name": "Liberia", "dial_code": "+231", "code": "LR"},
    {"name": "Libyan Arab Jamahiriya", "dial_code": "+218", "code": "LY"},
    {"name": "Liechtenstein", "dial_code": "+423", "code": "LI"},
    {"name": "Lithuania", "dial_code": "+370", "code": "LT"},
    {"name": "Luxembourg", "dial_code": "+352", "code": "LU"},
    {"name": "Macao", "dial_code": "+853", "code": "MO"},
    {"name": "Macedonia", "dial_code": "+389", "code": "MK"},
    {"name": "Madagascar", "dial_code": "+261", "code": "MG"},
    {"name": "Malawi", "dial_code": "+265", "code": "MW"},
    {"name": "Malaysia", "dial_code": "+60", "code": "MY"},
    {"name": "Maldives", "dial_code": "+960", "code": "MV"},
    {"name": "Mali", "dial_code": "+223", "code": "ML"},
    {"name": "Malta", "dial_code": "+356", "code": "MT"},
    {"name": "Marshall Islands", "dial_code": "+692", "code": "MH"},
    {"name": "Martinique", "dial_code": "+596", "code": "MQ"},
    {"name": "Mauritania", "dial_code": "+222", "code": "MR"},
    {"name": "Mauritius", "dial_code": "+230", "code": "MU"},
    {"name": "Mayotte", "dial_code": "+262", "code": "YT"},
    {"name": "Mexico", "dial_code": "+52", "code": "MX"},
    {
      "name": "Micronesia, Federated States of Micronesia",
      "dial_code": "+691",
      "code": "FM"
    },
    {"name": "Moldova", "dial_code": "+373", "code": "MD"},
    {"name": "Monaco", "dial_code": "+377", "code": "MC"},
    {"name": "Mongolia", "dial_code": "+976", "code": "MN"},
    {"name": "Montenegro", "dial_code": "+382", "code": "ME"},
    {"name": "Montserrat", "dial_code": "+1664", "code": "MS"},
    {"name": "Morocco", "dial_code": "+212", "code": "MA"},
    {"name": "Mozambique", "dial_code": "+258", "code": "MZ"},
    {"name": "Myanmar", "dial_code": "+95", "code": "MM"},
    {"name": "Namibia", "dial_code": "+264", "code": "NA"},
    {"name": "Nauru", "dial_code": "+674", "code": "NR"},
    {"name": "Nepal", "dial_code": "+977", "code": "NP"},
    {"name": "Netherlands", "dial_code": "+31", "code": "NL"},
    {"name": "Netherlands Antilles", "dial_code": "+599", "code": "AN"},
    {"name": "New Caledonia", "dial_code": "+687", "code": "NC"},
    {"name": "New Zealand", "dial_code": "+64", "code": "NZ"},
    {"name": "Nicaragua", "dial_code": "+505", "code": "NI"},
    {"name": "Niger", "dial_code": "+227", "code": "NE"},
    {"name": "Nigeria", "dial_code": "+234", "code": "NG"},
    {"name": "Niue", "dial_code": "+683", "code": "NU"},
    // {"name": "Norfolk Island", "dial_code": "+672", "code": "NF"},
    {"name": "Northern Mariana Islands", "dial_code": "+1670", "code": "MP"},
    {"name": "Norway", "dial_code": "+47", "code": "NO"},
    {"name": "Oman", "dial_code": "+968", "code": "OM"},
    {"name": "Pakistan", "dial_code": "+92", "code": "PK"},
    {"name": "Palau", "dial_code": "+680", "code": "PW"},
    {
      "name": "Palestinian Territory, Occupied",
      "dial_code": "+970",
      "code": "PS"
    },
    {"name": "Panama", "dial_code": "+507", "code": "PA"},
    {"name": "Papua New Guinea", "dial_code": "+675", "code": "PG"},
    {"name": "Paraguay", "dial_code": "+595", "code": "PY"},
    {"name": "Peru", "dial_code": "+51", "code": "PE"},
    {"name": "Philippines", "dial_code": "+63", "code": "PH"},
    {"name": "Pitcairn", "dial_code": "+872", "code": "PN"},
    {"name": "Poland", "dial_code": "+48", "code": "PL"},
    {"name": "Portugal", "dial_code": "+351", "code": "PT"},
    {"name": "Puerto Rico", "dial_code": "+1939", "code": "PR"},
    {"name": "Qatar", "dial_code": "+974", "code": "QA"},
    {"name": "Romania", "dial_code": "+40", "code": "RO"},
    {"name": "Russia", "dial_code": "+7", "code": "RU"},
    {"name": "Rwanda", "dial_code": "+250", "code": "RW"},
    {"name": "Reunion", "dial_code": "+262", "code": "RE"},
    {"name": "Saint Barthelemy", "dial_code": "+590", "code": "BL"},
    {
      "name": "Saint Helena, Ascension and Tristan Da Cunha",
      "dial_code": "+290",
      "code": "SH"
    },
    {"name": "Saint Kitts and Nevis", "dial_code": "+1869", "code": "KN"},
    {"name": "Saint Lucia", "dial_code": "+1758", "code": "LC"},
    {"name": "Saint Martin", "dial_code": "+590", "code": "MF"},
    {"name": "Saint Pierre and Miquelon", "dial_code": "+508", "code": "PM"},
    {
      "name": "Saint Vincent and the Grenadines",
      "dial_code": "+1784",
      "code": "VC"
    },
    {"name": "Samoa", "dial_code": "+685", "code": "WS"},
    {"name": "San Marino", "dial_code": "+378", "code": "SM"},
    {"name": "Sao Tome and Principe", "dial_code": "+239", "code": "ST"},
    {"name": "Saudi Arabia", "dial_code": "+966", "code": "SA"},
    {"name": "Senegal", "dial_code": "+221", "code": "SN"},
    {"name": "Serbia", "dial_code": "+381", "code": "RS"},
    {"name": "Seychelles", "dial_code": "+248", "code": "SC"},
    {"name": "Sierra Leone", "dial_code": "+232", "code": "SL"},
    {"name": "Singapore", "dial_code": "+65", "code": "SG"},
    {"name": "Slovakia", "dial_code": "+421", "code": "SK"},
    {"name": "Slovenia", "dial_code": "+386", "code": "SI"},
    {"name": "Solomon Islands", "dial_code": "+677", "code": "SB"},
    {"name": "Somalia", "dial_code": "+252", "code": "SO"},
    {"name": "South Africa", "dial_code": "+27", "code": "ZA"},
    {"name": "South Sudan", "dial_code": "+211", "code": "SS"},
    {
      "name": "South Georgia and the South Sandwich Islands",
      "dial_code": "+500",
      "code": "GS"
    },
    {"name": "Spain", "dial_code": "+34", "code": "ES"},
    {"name": "Sri Lanka", "dial_code": "+94", "code": "LK"},
    {"name": "Sudan", "dial_code": "+249", "code": "SD"},
    {"name": "Suriname", "dial_code": "+597", "code": "SR"},
    {"name": "Svalbard and Jan Mayen", "dial_code": "+47", "code": "SJ"},
    {"name": "Swaziland", "dial_code": "+268", "code": "SZ"},
    {"name": "Sweden", "dial_code": "+46", "code": "SE"},
    {"name": "Switzerland", "dial_code": "+41", "code": "CH"},
    {"name": "Syrian Arab Republic", "dial_code": "+963", "code": "SY"},
    {"name": "Taiwan", "dial_code": "+886", "code": "TW"},
    {"name": "Tajikistan", "dial_code": "+992", "code": "TJ"},
    {
      "name": "Tanzania, United Republic of Tanzania",
      "dial_code": "+255",
      "code": "TZ"
    },
    {"name": "Thailand", "dial_code": "+66", "code": "TH"},
    {"name": "Timor-Leste", "dial_code": "+670", "code": "TL"},
    {"name": "Togo", "dial_code": "+228", "code": "TG"},
    {"name": "Tokelau", "dial_code": "+690", "code": "TK"},
    {"name": "Tonga", "dial_code": "+676", "code": "TO"},
    {"name": "Trinidad and Tobago", "dial_code": "+1868", "code": "TT"},
    {"name": "Tunisia", "dial_code": "+216", "code": "TN"},
    {"name": "Turkey", "dial_code": "+90", "code": "TR"},
    {"name": "Turkmenistan", "dial_code": "+993", "code": "TM"},
    {"name": "Turks and Caicos Islands", "dial_code": "+1649", "code": "TC"},
    {"name": "Tuvalu", "dial_code": "+688", "code": "TV"},
    {"name": "Uganda", "dial_code": "+256", "code": "UG"},
    {"name": "Ukraine", "dial_code": "+380", "code": "UA"},
    {"name": "United Arab Emirates", "dial_code": "+971", "code": "AE"},
    {"name": "United Kingdom", "dial_code": "+44", "code": "GB"},
    {"name": "United States", "dial_code": "+1", "code": "US"},
    {"name": "Uruguay", "dial_code": "+598", "code": "UY"},
    {"name": "Uzbekistan", "dial_code": "+998", "code": "UZ"},
    {"name": "Vanuatu", "dial_code": "+678", "code": "VU"},
    {
      "name": "Venezuela, Bolivarian Republic of Venezuela",
      "dial_code": "+58",
      "code": "VE"
    },
    {"name": "Vietnam", "dial_code": "+84", "code": "VN"},
    {"name": "Virgin Islands, British", "dial_code": "+1284", "code": "VG"},
    {"name": "Virgin Islands, U.S.", "dial_code": "+1340", "code": "VI"},
    {"name": "Wallis and Futuna", "dial_code": "+681", "code": "WF"},
    {"name": "Yemen", "dial_code": "+967", "code": "YE"},
    {"name": "Zambia", "dial_code": "+260", "code": "ZM"},
    {"name": "Zimbabwe", "dial_code": "+263", "code": "ZW"}
  ];
  List<CustomColumn>? customColumns = [];
  List<TextEditingController> customColumnsControllers = [];

  late final SharedFunctions sharedFunctions;
  List<User> _users = [];
  List<String> DialCodes = [];
  Set<String> setdialCodes = {};
  List<String> dialCodes = [];
  List<dynamic> _status = [];
  List<LeadSource> sources = [];
  List<Priority> _priorities = [];
  String? _selectedApplicationName;
  List<String?> _applicationNames = [];
  @override
  void initState() {
    super.initState();
    _leadId = widget.leadId;
    

    fetchCustomColumns(_leadId, widget.isNewleadd).then((columns) {
      if (mounted) {
        setState(() {
          customColumns = columns;
        });
      }
    });

    fetchUsers().then((users) {
      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    });

    getAllLeadsStatus().then((allLeadsStatus) {
      if (mounted) {
        setState(() {
          _status = allLeadsStatus;
        });
      }
    });

    fetchLeadSources().then((leadSources) {
      if (mounted) {
        setState(() {
          sources = leadSources;
        });
      }
    });

    fetchPriorities().then((priorities) {
      if (mounted) {
        setState(() {
          _priorities = priorities;
        });
      }
    });

    fetchApplications().then((applications) {
      if (mounted) {
        setState(() {
          _applicationNames =
              applications.map((app) => app.applicationName).toList();
        });
      }
    });

    populateValue();
  }

  void rebuildPage() {
    setState(() {});
  }

  populateValue() {
    for (Map<String, String> countryCode in countryCodes) {
      DialCodes.add(countryCode['dial_code']!);
      DialCodes.sort((a, b) {
        int aNum = int.parse(a.substring(1));
        int bNum = int.parse(b.substring(1));
        return aNum.compareTo(bNum);
      });
    }
    Set<String> ddialCodes = DialCodes.toSet();
    dialCodes = ddialCodes.toList();

if(widget.frominitallist??false){
 String mobileNumberWithDialCode = widget.lead==null?"":widget.lead?.mobileNumber??"";
      String? mobileNumberWithoutDialCode;

      String? countryCode = leadModel.countryCode;
      String? dialCodeWithoutPlusSymbol =
          countryCode != null && countryCode.length > 1
              ? countryCode.substring(1)
              : null;

      if (dialCodeWithoutPlusSymbol != null &&
          mobileNumberWithDialCode.startsWith(dialCodeWithoutPlusSymbol)) {
        mobileNumberWithoutDialCode = mobileNumberWithDialCode
            .substring(dialCodeWithoutPlusSymbol.length);
      } else if (mobileNumberWithDialCode.length == 12) {
        mobileNumberWithoutDialCode = mobileNumberWithDialCode.substring(2);
      } else {
        mobileNumberWithoutDialCode = mobileNumberWithDialCode;
      }

      mobileNumController.text = mobileNumberWithoutDialCode;
print("your"+mobileNumController.text);
}


    if (_leadId != null) {
      leadModel = widget.lead!;
      isNewLead = false;
      customerNameController.text = leadModel.customerName ?? "";
      organizationNameController.text = leadModel.organizationName ?? "";
      String mobileNumberWithDialCode = leadModel.mobileNumber??"";
      String? mobileNumberWithoutDialCode;

      String? countryCode = leadModel.countryCode;
      String? dialCodeWithoutPlusSymbol =
          countryCode != null && countryCode.length > 1
              ? countryCode.substring(1)
              : null;

      if (dialCodeWithoutPlusSymbol != null &&
          mobileNumberWithDialCode.startsWith(dialCodeWithoutPlusSymbol)) {
        mobileNumberWithoutDialCode = mobileNumberWithDialCode
            .substring(dialCodeWithoutPlusSymbol.length);
      } else if (mobileNumberWithDialCode.length == 12) {
        mobileNumberWithoutDialCode = mobileNumberWithDialCode.substring(2);
      } else {
        mobileNumberWithoutDialCode = mobileNumberWithDialCode;
      }

      mobileNumController.text = mobileNumberWithoutDialCode;

      emailController.text = leadModel.email ?? "";

      cityNameController.text = leadModel.city ?? "";
      stateController.text = leadModel.state ?? "";
      countryController.text = leadModel.country ?? "";
      // dialCodeController.text = leadModel.countryCode ?? "+91";
      pincodeController.text = leadModel.pincode?.toString() ?? "";
      addressController.text = leadModel.fullAddress ?? "";
      scoreController.text = leadModel.score?.toString() ?? "0";

      potentialDealValueController.text =
          leadModel.potentialDealValue?.toString() ?? "";
      actualDealValueController.text =
          leadModel.actualDealValue?.toString() ?? "";

      String firstName = leadModel.assignedBy?.firstName?.toString() ?? "";
      String lastName = leadModel.assignedBy?.lastName?.toString() ?? "";

      assignedByController.text = firstName + " " + lastName;
    } else {
      print("creating new item");
      return;
    }
  }

  bool _isFormValid() {
    return (customerNameController.text.isNotEmpty ||
        (mobileNumController.text.isNotEmpty ||
            emailController.text.isNotEmpty));
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String message = mobileNumController.text.isEmpty ||
                emailController.text.isEmpty
            ? "Please fill in atleast one of the following:\n\n• Customer Name\n• Mobile Number\n• Email"
            : "Please enter a Customer Name!";
        return AlertDialog(
          title: Center(
            child: Text(
              "Invalid",
              style: TextStyle(color: Colors.red),
            ),
          ),
          content: Text(
            message,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              child: Text(
                "OKAY",
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  formFields() {
    List<Widget> textFields = [];
    //  textFields.add(Text('Tags :',style: TextStyle(fontWeight: FontWeight.w900,fontSize: 20),));

    if (widget.isFromChat == true) {
      if (menuItems != null &&
          textController != null &&
          txtFollowUpName != null &&
          txtDescription != null &&
          txtDateTime != null) {
        final menuItemss = menuItems!(context, textController!,
            txtFollowUpName!, txtDescription!, txtDateTime!);

        textFields.add(
          Container(
         
            padding: EdgeInsets.all(1),
            // decoration: BoxDecoration(
            //     color: Colors.grey.withOpacity(0.2),
            //     borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                FittedBox(
                  child: menuItemss,
                  fit: BoxFit.scaleDown,
                ),
              ],
            ),
          ),
        );
      }
    } else {
      if (menuItems != null &&
          textController != null &&
          txtFollowUpName != null &&
          txtDescription != null &&
          txtDateTime != null) {
        final menuItemss = menuItems!(
            textController!, txtFollowUpName!, txtDescription!, txtDateTime!);

        textFields.add(
          Container(
            padding: EdgeInsets.all(1),
            // decoration: BoxDecoration(
            //     color: Colors.grey.withOpacity(0.2),
            //     borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                FittedBox(
                  child: menuItemss,
                  fit: BoxFit.scaleDown,
                ),
              ],
            ),
          ),
        );
      }
    }

    if (widget.isFromChat == true) {
      if (buildTags != null &&
          textController != null &&
          txtFollowUpName != null &&
          txtDescription != null &&
          txtDateTime != null) {
        final BuildTags = buildTags!(context, textController!, txtFollowUpName!,
            txtDescription!, txtDateTime!);

        textFields.add(
          Obx(
            () {
              leadController.tagsUpdated.value;
              return Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Wrap(
                      children: BuildTags,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    } else {
      if (buildTags != null &&
          textController != null &&
          txtFollowUpName != null &&
          txtDescription != null &&
          txtDateTime != null) {
        final BuildTags = buildTags!(
            textController!, txtFollowUpName!, txtDescription!, txtDateTime!);

        textFields.add(
          Obx(
            () {
              leadController.tagsUpdated.value;
              return Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Wrap(
                      children: BuildTags,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    }

    // Add the default form fields
    textFields.add(SizedBox(height: 6));
    textFields.add(
 Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text("Customer Name",style: TextStyle(fontSize: 17),),
        ),
        SizedBox(height: 4,),
      TextFormField(

        controller: customerNameController,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          
          border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),

          filled: true,
          fillColor: Colors.grey.shade200,
          hintText: 'Enter Name',
        prefixIcon:Icon( Icons.person_2,color: Colors.blue.shade900,)
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter Customer Name';
          }
          return null;
        },
      ),],),

    
    );
    textFields.add(
 Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text("Organization Name",style: TextStyle(fontSize: 17),),
        ),
        SizedBox(height: 4,),
      TextFormField(
        controller: organizationNameController,
        keyboardType: TextInputType.name,
        
        // maxLength: 200,
        decoration: InputDecoration(fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),
        filled: true,
        prefixIcon:Icon( Icons.business,color: Colors.blue.shade900,),
            hintText: "Enter Organization",  ),
      ),],),

      
    );
    // textFields.add(SizedBox(width: 16));

    textFields.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text("Email",style: TextStyle(fontSize: 17),),
        ),
        SizedBox(height: 4,),
         TextFormField(
        
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(fillColor: Colors.grey.shade200,filled: true,hintText: "Enter email",border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),suffixIcon:Icon(Icons.email,color: Colors.blue.shade900,)),
    )],),
    );
    String? _selectedDialCode;

    textFields.add(
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 11),
              height: 60,
              width: 94,
              child: DropDownTextField(clearOption: false,dropDownList: dialCodes.map((String? dialCode) {
                    return DropDownValueModel(
                      
                      value: dialCode,
                      name: "$dialCode",
                    );
                  }).toList(),initialValue:  leadModel.countryCode == ""
                      ? "+91"
                      : leadModel.countryCode,
                      textFieldDecoration: InputDecoration(filled: true,fillColor: Colors.grey.shade200,hintText: "+91", border: OutlineInputBorder(
                    
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDialCode = newValue?.substring(1);
                      dialCodeController.text = _selectedDialCode ?? '';
                    });
                  },
                       )
              
            
          ),
          SizedBox(width: 4,),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 3.55),
              height: 80,
              child: TextFormField(
                controller: mobileNumController,
                keyboardType: TextInputType.number,
                // maxLength: 10,
                decoration: InputDecoration(
                    filled: true,
          fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),
                  hintText: "Enter Mobile Number",
                  labelText: "Mobile Number",
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (dialCodeController.text == "") {
      dialCodeController.text = leadModel.countryCode ?? "+91";
    }

    textFields.add(
    
   Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text("City",style: TextStyle(fontSize: 17),),
        ),
        SizedBox(height: 4,),
      TextFormField(
        controller: cityNameController,
        keyboardType: TextInputType.name,
        // maxLength: 10,
       
        decoration: InputDecoration(   prefixIcon:Icon(Icons.location_city,color: Colors.blue.shade900,),filled: true,
          fillColor: Colors.grey.shade200,hintText: "Enter City", border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),  ),
      ),],),
    );

    textFields.add(
       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text("State",style: TextStyle(fontSize: 17),),
        ),
        SizedBox(height: 4,),
      TextFormField(
        controller: stateController,
        keyboardType: TextInputType.name,
        // maxLength: 10,
        decoration:
            InputDecoration(  prefixIcon:Icon(Icons.location_on,color: Colors.blue.shade900,),filled: true,
          fillColor: Colors.grey.shade200,hintText: "Enter State",  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),),
      ),],),
    
    );
    textFields.add(
     
   Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text("Country",style: TextStyle(fontSize: 17),),
        ),
        SizedBox(height: 4,),
      TextFormField(
        controller: countryController,
        keyboardType: TextInputType.name,
        // maxLength: 10,
        decoration:
            InputDecoration(   prefixIcon:Icon(Icons.location_on,color: Colors.blue.shade900,),filled: true,
          fillColor: Colors.grey.shade200,hintText: "Enter Country",  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ), ),
      ),],),   );
    textFields.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text("Pincode",style: TextStyle(fontSize: 17),),
        ),
        SizedBox(height: 4,),
      TextFormField(
        controller: pincodeController,
        keyboardType: TextInputType.number,
        // maxLength: 10,
        decoration:
            InputDecoration(  filled: true, prefixIcon:Icon(Icons.pin_drop,color: Colors.blue.shade900,),
          fillColor: Colors.grey.shade200,hintText: "Enter Pincode",  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),),
      ),],),
     
    );
    textFields.add(
         Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text("Address",style: TextStyle(fontSize: 17),),
        ),
        SizedBox(height: 4,),
         Container(
        margin: EdgeInsets.only(top: 14, bottom: 10),
       
        child: TextFormField(
          controller: addressController,
          keyboardType: TextInputType.multiline,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: "Enter Address",
      filled: true,
          fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 10),
          ),
        ),
      ),],),
  
    );

    dynamic _selectedStatus = leadModel.leadStatus?.id;

    textFields.add(
      Container(
       
        child: DropdownButtonFormField(
          value: _selectedStatus,
          decoration: InputDecoration(
            hintText: 'Status',
            labelText: "Status",
            border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 10),
          ),
          items: _status.map((status) {
            return DropdownMenuItem(
              value: status['id'],
              child: Text(status['statusName']),
            );
          }).toList(),
          onChanged: (selectedStatusId) {
            setState(() {
              _selectedStatus = selectedStatusId;
              statusNameController.text = selectedStatusId.toString();
            });
          },
        ),
      ),
    );
    int? _selectedPriority = leadModel.priorityId?.id;

    textFields.add(
      Container(
       
        child: DropdownButtonFormField<int>(
          value: _selectedPriority,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 10),
            border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),
            hintText: 'Priority',
            labelText: "Priority",
          ),
          items: _priorities.map((priority) {
            return DropdownMenuItem<int>(
              value: priority.id,
              child: Text(priority.name),
            );
          }).toList(),
          onChanged: (selectedPriorityId) {
            setState(() {
              _selectedPriority = selectedPriorityId;
              priorityIdController.text = selectedPriorityId.toString();
            });
          },
        ),
      ),
    );

    int? _sourceId = leadModel.leadSource?.id;
    if (_sourceId != null && !sources.any((source) => source.id == _sourceId)) {
      _sourceId = null;
    }
    textFields.add(
      Container(
       
        child: DropdownButtonFormField<int>(
          value: _sourceId,
          decoration: InputDecoration(
            hintText: 'Source',
            labelText: "Source",
            border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 10),
          ),
          items: sources.map((source) {
            return DropdownMenuItem<int>(
              value: source.id,
              child: Text('${source.sourceName}'),
            );
          }).toList(),
          onChanged: (selectedSourceId) {
            setState(() {
              _sourceId = selectedSourceId;
              sourceController.text = selectedSourceId.toString();
            });
          },
        ),
      ),
    );
    String? firstName2;
    String? lastName2;
    if (leadModel.assignedTo?.firstName?.toString() != null) {
      firstName2 = leadModel.assignedTo?.firstName?.toString();
    }
    if (leadModel.assignedTo?.lastName?.toString() != null) {
      lastName2 = leadModel.assignedTo?.lastName?.toString();
    }
    int? _selectedUser = leadModel.assignedTo?.id;

    textFields.add(Container(
    
      child: DropdownButtonFormField<int>(
        value: _selectedUser,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 10),
            hintText: "Assign To",
            labelText: "Assign To"),
        items: _users.map((user) {
          return DropdownMenuItem<int>(
            value: user.id,
            child: Text('${user.firstName} ${user.lastName}'),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedUser = value;
            assignedToController.text = value?.toString() ?? '';
          });
        },
      ),
    ));

    textFields.add(
       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text( "Potential Deal Value",style: TextStyle(fontSize: 17),),
        ),
        SizedBox(height: 4,),
         TextFormField(
        controller: potentialDealValueController,
        keyboardType: TextInputType.number,
        // maxLength: 10,
        decoration: InputDecoration(
            prefixIcon:Icon(Icons.attach_money,color: Colors.blue.shade900,),
            filled: true,
          fillColor: Colors.grey.shade200,
            hintText: "Potential Deal Value",
             border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),),
      ),],),
   
    );
    textFields.add(
       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text("Actual Deal Value",style: TextStyle(fontSize: 17),),
        ),
        SizedBox(height: 4,),
      TextFormField(
        controller: actualDealValueController,
        keyboardType: TextInputType.number,
        // maxLength: 10,
        decoration: InputDecoration(
           prefixIcon:Icon(Icons.attach_money,color: Colors.blue.shade900,),
            filled: true,
          fillColor: Colors.grey.shade200,
            hintText: "Actual Deal Value",  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),),
      ),],),
      
    );

    String firstName = leadModel.assignedBy?.firstName?.toString() ?? "";
    String lastName = leadModel.assignedBy?.lastName?.toString() ?? "";
    if (!isNewLead && assignedByController.text != " ") {
      textFields.add(
        Container(
          margin: EdgeInsets.only(
            top: 14,
          ),
        
          child: TextFormField(
            readOnly: true,
            controller: assignedByController,
            keyboardType: TextInputType.multiline,
            // maxLength: 10,
            decoration: InputDecoration(
              hintText: "Assigned By",
              labelText: "Assigned By",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),
              contentPadding:
                  EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 10),
            ),
          ),
        ),
      );
    }

    int _currentValue = 0;
    if (scoreController.text != null && scoreController.text.isNotEmpty) {
      _currentValue = int.parse(scoreController.text);
    }
    textFields.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 30,
            // padding: EdgeInsets.only(bottom: 17, right: 12,top:17),
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 197, 197, 197),
              ),
              child: Center(
                child: Icon(Icons.remove, color: Colors.black),
              ),
            ),
            onPressed: () {
              if (_currentValue > 0) {
                setState(() => _currentValue -= 1);
                scoreController.text = _currentValue.toString();
              }
            },
          ),
          // SizedBox(width:13),

          Container(
            // margin: EdgeInsets.only(right: 15),
            padding: EdgeInsets.only(bottom: 17, top: 17),
            width: MediaQuery.of(context).size.width / 2,
            child: TextFormField(
              controller: scoreController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Score",
                labelText: "Score",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          IconButton(
            iconSize: 30,
            // padding: EdgeInsets.only(bottom: 17, right: 12,top: 17),
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 197, 197, 197),
              ),
              child: Center(
                child: Icon(Icons.add, color: Colors.black),
              ),
            ),
            onPressed: () {
              if (_currentValue < 10) {
                setState(() => _currentValue += 1);
                scoreController.text = _currentValue.toString();
              }
            },
          ),
        ],
      ),
    );

    // // Loop through the custom columns and add a TextFormField for each

    if (customColumns != null) {
      for (var i = 0; i < customColumns!.length; i++) {
        var customColumn = customColumns![i];

        // Only add the field if  type is "lead"
        if (customColumn.type == "lead") {
          TextInputType keyboardType;
          List<DropdownMenuItem<String>>? dropdownItems;
          switch (customColumn.dataType) {
            case "Number":
              keyboardType = TextInputType.number;
              break;
            case "Text":
              keyboardType = TextInputType.name;
              break;
            case "DropDown":
              keyboardType = TextInputType.text;
              dropdownItems = customColumn.optionValueArray is List<dynamic>
                  ? (customColumn.optionValueArray as List<dynamic>)
                      .toSet()
                      .map((optionValue) => DropdownMenuItem(
                            value: optionValue.toString(),
                            child: Text(optionValue.toString()),
                          ))
                      .toList()
                  : null;

              break;
            default:
              keyboardType = TextInputType.text;
          }
// final controller = TextEditingController(text: customColumn.value?.toString() ?? '');
// final textField = TextField(controller: controller);
          TextEditingController controller;
          if (customColumnsControllers.length > i &&
              customColumnsControllers[i] != null) {
            // reuse the existing controller
            controller = customColumnsControllers[i];
          } else {
            // create a new controller for the current custom column
            controller = TextEditingController(
                text: customColumn.value?.toString() ?? '');
            customColumnsControllers.add(controller);
          }
          controller.addListener(() {
            String newValue = controller.text;
            print("addlistener");
            print(
                "${newValue.runtimeType} and ${customColumn.value.runtimeType}");
            print('controller.text: ${controller.text}');
            if (customColumn.value != newValue) {
              print("inside if cusutom.value");
              setState(() {
                print("inside setstate");
                if (customColumn.dataType == "Number") {
                  print("inside if");
                  try {
                    print("inside try");
                    customColumn.value = int.parse(newValue);
                  } catch (e) {
                    print("Invalid number: $newValue");
                  }
                } else {
                  print("chaning1: $newValue");
                  customColumn.value = newValue;
                  print("chaning: $newValue");
                }
              });
            }
          });

          // if (customColumn.value != null) {
          //   controller.text = customColumn.value?.toString() ?? '';
          // }
          if (dropdownItems != null) {
            textFields.add(Container(
           
              child: DropdownButtonFormField<String>(
                value: customColumn.value == "" ? null : customColumn.value,
                onChanged: (newValue) {
                  setState(() {
                    customColumn.value = newValue!;
                    controller.text = newValue;
                  });
                },
                items: dropdownItems,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),
                  contentPadding:
                      EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 10),
                  hintText: customColumn.columnName,
                  labelText: customColumn.displayName,
                ),
              ),
            ));
          } else {
          textFields.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4,left: 4),
                child: Text(customColumn.displayName!,style: TextStyle(fontSize: 17),),
              ),
              Container(
            
                  child: TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: customColumn.dataType == "LargeText" ? 2 : null,
                    decoration: InputDecoration(
                        filled: true,
          fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                ),
                      contentPadding:
                          EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 10),
                      hintText: customColumn.columnName,
                      labelText: customColumn.displayName,
                      suffixIcon: customColumn.dataType == "Calendar"
                          ? IconButton(
                              icon: Icon(Icons.calendar_today,color: Colors.blue.shade900,),
                              onPressed: () async {
                                DateTime? selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2021),
                                  lastDate: DateTime(2030),
                                );
                                if (selectedDate != null) {
                                  setState(() {
                                    controller.text =
                                        DateFormat.yMd().format(selectedDate);
                                  });
                                }
                              },
                            )
                          : customColumn.dataType == "Time"
                              ? IconButton(
                                  icon: Icon(Icons.access_time,color: Colors.blue.shade900,),
                                  onPressed: () async {
                                    TimeOfDay? selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (selectedTime != null) {
                                      setState(() {
                                        controller.text =
                                            selectedTime.format(context).toString();
                                      });
                                    }
                                  },
                                )
                              : null,
                    ),
                  ),
                ),
            ],
          ));
          }
        }
      }
    }

    // // Return a ListView.builder() with the list of text fields
    final ScrollController _scrollController = ScrollController();

// Use the ScrollController in the Scrollbar and ListView.builder
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(0)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 190.0,
        width: MediaQuery.of(context).size.width,
        child: Scrollbar(
          thumbVisibility: false,
          controller:
              _scrollController, // Provide the ScrollController to the Scrollbar
          child: ListView.builder(
            controller:
                _scrollController, // Provide the ScrollController to the ListView.builder
            itemCount: textFields.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: textFields[index],
              );
            },
          ),
        ),
      ),
    );
  }

  _saveButton(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.only(left: 33),
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
              style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(Size(300, 40)),
                  backgroundColor: buttonCOlor),
              onPressed: () async {
                if(widget.frominitallist??false){
                   widget.frominitallistcallback?.call(widget.lead!.mobileNumber!);
                }
                if (_isFormValid()) {
                  // Perform save operation
                  leadDetailsModel.customerName = customerNameController.text;
                  leadDetailsModel.organizationName =
                      organizationNameController.text;
    
                  if (mobileNumController.text.isEmpty) {
                    leadDetailsModel.mobileNumber = null;
                  } else {
                    String mobileNumberString =
                        dialCodeController.text + mobileNumController.text;
                    int? mobileNumber = int.tryParse(mobileNumberString);
                    leadDetailsModel.mobileNumber = mobileNumber;
                  }
    
                  leadDetailsModel.email = emailController.text;
    
                  leadDetailsModel.city = cityNameController.text;
                  leadDetailsModel.state = stateController.text;
    
                  leadDetailsModel.country = countryController.text;
                  leadDetailsModel.countryCode = dialCodeController.text;
                  leadDetailsModel.pincode = pincodeController.text.isEmpty
                      ? null
                      : int.tryParse(pincodeController.text);
    
                  leadDetailsModel.fullAddress = addressController.text;
                  if (leadModel.leadStatus?.id == null) {
                    leadDetailsModel.leadStatus = null;
                  } else {
                    leadDetailsModel.leadStatus = LeadStatus(
                        status: null,
                        messages: [],
                        id: statusNameController.text.isNotEmpty
                            ? int.parse(statusNameController.text)
                            : leadModel
                                .leadStatus?.id, //becoz it depended on id
                        statusName: null,
                        lastModifiedTime: null,
                        lastModifiedBy: null,
                        isActive: leadModel.leadStatus?.isActive,
                        clientGroupId: null,
                        isPredefineRemoved: null);
                  }
    
                  if (leadModel.leadSource?.id == null) {
                    leadDetailsModel.leadSource =  LeadSource(
                      status:'OK',
                      messages: [],
                      id: sourceController.text.isNotEmpty
                          ? int.parse(sourceController.text)
                          : leadSourceIds["Others"],
                      sourceName: sourceController.text.isEmpty?"Others":sourceController.text,
                    );
                  } else {
                    leadDetailsModel.leadSource = LeadSource(
                      status: leadModel.leadSource?.status,
                      messages: [],
                      id: sourceController.text.isNotEmpty
                          ? int.parse(sourceController.text)
                          : leadModel.leadSource?.id,
                      sourceName: sourceController.text,
                    );
                  }
                  if (leadModel.priorityId?.id == null &&
                      int.tryParse(priorityIdController.text) == null) {
                    leadDetailsModel.priorityId = null;
                  } else {
                    leadDetailsModel.priorityId = PriorityId(
                      id: int.tryParse(priorityIdController.text) ??
                          leadModel.priorityId?.id,
                      lastModifiedBy: null,
                      lastModifiedTime: null,
                      isActive: true,
                      messages: [],
                      status: null,
                      name: null,
                    );
                  }
                  if (int.tryParse(assignedToController.text) == null &&
                      leadModel.assignedTo?.id == null) {
                    leadDetailsModel.assignedTo = null;
                  } else {
                    leadDetailsModel.assignedTo = assignedTo_Model.AssignedTo(
                      status: null,
                      messages: [],
                      id: int.tryParse(assignedToController.text) ??
                          leadModel.assignedTo?.id,
                      firstName: null,
                      userId: null,
                      lastName: null,
                      userName: null,
                      mobileNumber: null,
                      emailAddress: null,
                      password: null,
                      isDefault: null,
                      userRole: null,
                      role: null,
                      pincode: null,
                      city: null,
                      state: null,
                      country: null,
                      houseNo: null,
                      addressLine1: null,
                      addressLine2: null,
                      addressType: null,
                    );
                  }
    
                  leadDetailsModel.potentialDealValue =
                      potentialDealValueController.text;
                  leadDetailsModel.actualDealValue =
                      actualDealValueController.text;
                  leadDetailsModel.score = scoreController.text.isEmpty
                      ? null
                      : int.tryParse(scoreController.text);
    
                  List<CustomColumn> customColumnss = customColumnsControllers
                      .asMap()
                      .map((index, controller) {
                        String newValue = controller.text;
    
                        CustomColumn originalCustomColumn =
                            customColumns![index];
    
                        if (newValue != originalCustomColumn.value) {
                          CustomColumn updatedCustomColumn = CustomColumn(
                            id: originalCustomColumn.id,
                            clientGroupId: originalCustomColumn.clientGroupId,
                            columnName: originalCustomColumn.columnName,
                            displayName: originalCustomColumn.displayName,
                            type: originalCustomColumn.type,
                            optionValues: originalCustomColumn.optionValues,
                            isActive: originalCustomColumn.isActive,
                            value: newValue,
                            optionValueArray:
                                originalCustomColumn.optionValueArray,
                            dataType: originalCustomColumn.dataType,
                          );
    
                          return MapEntry(index, updatedCustomColumn);
                        } else {
                          return MapEntry(index, originalCustomColumn);
                        }
                      })
                      .values
                      .toList();
                  leadDetailsModel.customColumns = customColumnss;
    
                  bool result = await SnapPeNetworks()
                      .saveLead(_leadId, leadDetailsModel, isNewLead);
    
                  if (!result) {
                    print('in !result if loop');
                    return;
                  }
    
                  // Navigator.pop(context);
                  print('outside if loop');
    
                  SnapPeUI().toastSuccess(message: "Details Saved.");
    
                  if (isNewLead) {
                    print('in isNewlead if loop');
                    Navigator.pop(context);
    
                  }
    
                  //need to be reload screen after save item
    //@leadscroll
                 // leadController.loadData(forcedReload: true);
                } else {
                  _showDialog();
                }
              },
              child: Text(
                "Save",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: kPrimaryTextColor),
              )),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // buildNotes() {
    //   if (controller.leadNotesModel.value.leadActions != null &&
    //       controller.leadNotesModel.value.leadActions!.length != 0) {
    //     return Expanded(
    //       child: ListView.builder(
    //         padding: const EdgeInsets.all(20.0),
    //         shrinkWrap: true,
    //         scrollDirection: Axis.vertical,
    //         itemCount: controller.leadNotesModel.value.leadActions!.length,
    //         itemBuilder: (context, index) {
    //           return NoteWidget(
    //               leadAction:
    //                   controller.leadNotesModel.value.leadActions![index]);
    //         },
    //       ),
    //     );
    //   } else {
    //     //  return SnapPeUI().subHeadingText('sd');
    //     return SnapPeUI().noDataFoundImage(msg: "Uh-oh! Add Some Notes ");
    //   }
    // }
    WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {}));
    return WillPopScope(
      onWillPop: () async {
        if (widget.onBack != null) {
          widget.onBack!();
        }
        return true;
      },
      child: Scaffold(
        appBar: SnapPeUI().nAppBar2(
            isNewLead,
            isNewLead == true
                ? "New Lead"
                : "${leadModel.customerName ?? leadModel.mobileNumber ?? ""}",
            _leadId,
            leadController,
            context),
        //  AppBar(
        //   title: Obx(() => Text(
        //       "Lead : ${controller.leadDetailsModel.value.customerName ?? ""}")),
        // ),
        body: Container(
          // padding: EdgeInsets.only(top: 20,bottom: 0,left: 15,right: 15),
//decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white,Theme.of(context).primaryColor],begin: Alignment.topLeft)),
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [

Card(

    
  color: Colors.white,
                     child: formFields(),)
                    ],
                  ),
                ),
              ),
              // Expanded(
              //     child: SingleChildScrollView(
              //         child: Obx(
              //   () => buildNotes(),
              // ))
              // ),
            ],
          ),
        ),
        floatingActionButton: _saveButton(context),
      ),
    );
  }
}
