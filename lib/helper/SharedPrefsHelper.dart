import 'dart:convert';
import 'dart:io';
import 'package:http/src/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/networkConstants.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/sharedPrefsConstants.dart';
import '../utils/snapPeUI.dart';
import '../models/model_application.dart';

class SharedPrefsHelper {
  static late SharedPreferences prefs;
  SharedPrefsHelper() {
    init();
  }

  Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  //  <-- Catalogue -->
  Future<String?> getCatalogue() async {
    return prefs.getString(NetworkConstants.DB_CATALOGUE);
  }

  setCatalogue(String catalogue) async {
    prefs.setString(NetworkConstants.DB_CATALOGUE, catalogue);
  }

  removeCatalogue() {
    prefs.remove(NetworkConstants.DB_CATALOGUE);
  }

  //  <-- Orders -->
  Future<String?> getOrders() async {
    return prefs.getString(NetworkConstants.DB_ORDERS);
  }

  setOrders(String orders) async {
    prefs.setString(NetworkConstants.DB_ORDERS, orders);
  }

  removeOrders() {
    prefs.remove(NetworkConstants.DB_ORDERS);
  }

  Future<String?> getPendingOrders() async {
    return prefs.getString(NetworkConstants.DB_PENDING_ORDERS);
  }

  void setPendingOrders(String orders) {
    prefs.setString(NetworkConstants.DB_PENDING_ORDERS, orders);
  }

  Future<void> setSwitchValue(bool value) async {
    await prefs.setBool('switchValue', value);
  }

  Future<bool> getSwitchValue() async {
    return prefs.getBool('switchValue') ?? false;
  }

//  <-- Community -->
  Future<String?> getCommunity() async {
    return prefs.getString(NetworkConstants.DB_COMMUNITY);
  }

  setCommunity(String community) async {
    prefs.setString(NetworkConstants.DB_COMMUNITY, community);
  }

  //  <-- Login -->
  Future<bool> getLoginStatus() async {
    return (prefs.getBool(isLogin)) ?? false;
  }

  setLoginStatus() async {
    prefs.setBool(isLogin, true);
  }

  setInChatDetailsscreen(String? number) {
    prefs.setString("isChatDetailsScreen", number ?? "");
  }

  removeInChatDetailsscreen() {
    prefs.remove("isChatDetailsScreen");
  }

  Future<String> getInChatDetailsscreen() async {
    return (prefs.getString("isChatDetailsScreen")) ?? '';
  }

  Future<bool> isRequiredCompany() async {
    return prefs.getString(NetworkConstants.CUSTOMER_TYPE) == "B2C"
        ? false
        : true;
  }

  Future<String?> getToken() async {
    return prefs.getString(NetworkConstants.TOKEN);
  }

  Future<String?> getClientGroupName() async {
    return prefs.getString(NetworkConstants.CLIENT_GROUP_NAME);
  }

  static Future<File?> pickMedia(
      Future<File?> Function(File file) cropImage) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return null;
    }

    File file = File(pickedFile.path);
    return cropImage(file);
  }

  setCategories(resData) {
    prefs.setString(NetworkConstants.CATEGORIES, resData);
  }

  String? getCategories() {
    return prefs.getString(NetworkConstants.CATEGORIES);
  }

  String? getUnit() {
    return prefs.getString(NetworkConstants.UNIT);
  }

  setUnit(String unitData) {
    prefs.setString(NetworkConstants.UNIT, unitData);
  }

  setMode(mode) {
    prefs.setString(NetworkConstants.MODE, mode);
  }

  setClientGroupName(clientGroupName) {
    prefs.setString(NetworkConstants.CLIENT_GROUP_NAME, clientGroupName);
  }

  setClientPhoneNo(phoneNo) {
    prefs.setString(NetworkConstants.CLIENT_PHONE_NUMBER, phoneNo);
  }

  Future<String?> getClientPhoneNo() async {
    return prefs.getString(NetworkConstants.CLIENT_PHONE_NUMBER);
  }

  getClientPhoneNoTest() {
    return prefs.getString("clientPhoneNum");
  }

  setClientPhoneNoTest(String? clientPhoneNum) {
    prefs.setString("clientPhoneNum", clientPhoneNum ?? "");
  }

  setClientName(clientName) {
    prefs.setString("clientName", clientName);
  }

  Future<String?> getClientName() async {
    return prefs.getString("clientName");
  }

  getClientNameTest() {
    return prefs.getString("clientName");
  }

  setClientNameTest(String? clientName) {
    prefs.setString("clientName", clientName ?? "");
  }

  setToken(String token) {
    prefs.setString(NetworkConstants.TOKEN, token);
  }

  setCustomerType(String customerType) {
    prefs.setString(NetworkConstants.CUSTOMER_TYPE, customerType);
  }

  setMerchantProfile(String merchantProfileData) {
    prefs.setString(NetworkConstants.MERCHANT_PROFILE, merchantProfileData);
    try {
      var jsonData = json.decode(merchantProfileData);
      setCustomerType(jsonData["mode"]);
    } catch (ex) {
      SnapPeUI().toastError();
    }
  }

  removeMerchantProfile() {
    prefs.remove(NetworkConstants.MERCHANT_PROFILE);
  }

  getMerchantProfile() {
    return prefs.getString(NetworkConstants.MERCHANT_PROFILE);
  }

  setLoginDetails(String body) {
    prefs.setString(NetworkConstants.LOGIN_DETAILS, body);
  }

  getLoginDetails() {
    return prefs.getString(NetworkConstants.LOGIN_DETAILS);
  }

  getLeads() {
    return prefs.getString(NetworkConstants.LEADS);
  }

  setLeads(String leads) {
    prefs.setString(NetworkConstants.LEADS, leads);
  }

  getLeadTags() {
    return prefs.getString(NetworkConstants.LEAD_TAGS);
  }

  setLeadTags(String leadTags) {
    prefs.setString(NetworkConstants.LEAD_TAGS, leadTags);
  }

  removeLeads() {
    prefs.remove(NetworkConstants.LEADS);
  }

  getCustomers() {
    return prefs.getString(NetworkConstants.CUSTOMERS);
  }

  removeCustomers() {
    prefs.remove(NetworkConstants.CUSTOMERS);
  }

  setCustomers(String customers) {
    prefs.setString(NetworkConstants.CUSTOMERS, customers);
  }

  void setMerchantUserId(userid) {
    prefs.setString(NetworkConstants.MERCHANT_USER_ID, "$userid");
  }

  getMerchantUserId() {
    return prefs.getString(NetworkConstants.MERCHANT_USER_ID);
  }

  setClientId(clientId) {
    prefs.setString("clientId", "$clientId");
  }

  getClientId() {
    return prefs.getString("clientId");
  }

  setAppNames(String appNamesData) {
    prefs.setString(NetworkConstants.APP_NAMES, appNamesData);
    //default Selected AppName
    try {
      ApplicationModel applicationModel =
          applicationModelFromJson(appNamesData);
      String defaultSelectedChatBot =
          applicationModel.application![0].applicationName!;
      setSelectedChatBot(defaultSelectedChatBot);
    } catch (ex) {}
  }

  setProperties(String leadPropertyValue) {
    //response of properties is stored locally . use as u want.
    prefs.setString("leadPropertyValue", leadPropertyValue);
  }

  removeProperties() {
    prefs.remove("leadPropertyValue");
  }

  getProperties() {
    return prefs.getString("leadPropertyValue");
  }

  setPinnedTemplates(String pinnedTemplates) {
    //response of properties is stored locally . use as u want.
    prefs.setString("pinnedTemplates", pinnedTemplates);
  }

  removePinnedTemplates() {
    prefs.remove("pinnedTemplates");
  }

  getPinnedTemplates() {
    return prefs.getString("pinnedTemplates");
  }

  getSelectedChatBot() {
    return prefs.getString(NetworkConstants.SELECTED_CHATBOT);
  }

  setSelectedChatBot(String appName) {
    prefs.setString(NetworkConstants.SELECTED_CHATBOT, appName);
  }

  getUserSelectedChatbot(String? clientGroupName) {
    if (clientGroupName != null) {
      return prefs.getString(clientGroupName);
    }
    return null;
  }

  setUserSelectedChatBot(String? clientGroupName, String? appName) {
    if (appName != null && clientGroupName != null) {
      prefs.setString(clientGroupName, appName);
    } else if (clientGroupName != null) {
      prefs.remove(clientGroupName);
    }
  }

  void setMerchantName(String merchantName) {
    //This is also known as LiveAgentUserName
    prefs.setString(NetworkConstants.MERCHANT_NAME, merchantName);
  }

  getMerchantName() {
    //This is also known as LiveAgentUserName
    return prefs.getString(NetworkConstants.MERCHANT_NAME);
  }

  void setLiveAgentSessionId(String socketId) {
    //This might be Socket ID or Token
    print("$socketId");
    prefs.setString(NetworkConstants.LIVE_AGENT_SESSION_ID, socketId);
  }

  getLiveAgentSessionId() {
    //This might be Socket ID or Token
    return prefs.getString(NetworkConstants.LIVE_AGENT_SESSION_ID);
  }

  getFCMToken() {
    return prefs.getString(NetworkConstants.FCM_TOKEN_ID);
  }

  setFCMToken(String newFCMtoken) {
    prefs.setString(NetworkConstants.FCM_TOKEN_ID, newFCMtoken);
  }

  getUsers() {
    return prefs.getString(NetworkConstants.USERS);
  }

  setUsers(String userJson) {
    prefs.setString(NetworkConstants.USERS, userJson);
  }

  getLeadStatus() {
    return prefs.getString(NetworkConstants.LEAD_STATUS);
  }

  setLeadStatus(String leadStatusJson) {
    prefs.setString(NetworkConstants.LEAD_STATUS, leadStatusJson);
  }

  setResponse(Response? response) {
    prefs.setString('responseBody', response?.body ?? '');
  }

  removeResponse() {
    prefs.remove('responseBody');
  }

  getResponse() {
    return prefs.getString('responseBody');
  }

  setClientGroupNameTest(String? clientgrpnametest) {
    prefs.setString("clientGroupNam", clientgrpnametest ?? "");
  }

  getClientGroupNameTest() {
    return prefs.getString("clientGroupNam");
  }

  removeSelectedApplication() {
    prefs.remove('selectedApplicationId');
    prefs.remove('selectedApplicationName');
  }

  Future<String?> getChatSessionId() async {
    return prefs.getString("chat_Socket_Session_Id");
  }

  setChatSessionId(String chatSessionId) async {
    prefs.setString("chat_Socket_Session_Id", chatSessionId);
  }
}
