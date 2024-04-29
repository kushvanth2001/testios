enum UrlName {
  Get_All_Communities,
  Get_Order_List,
  Get_All_Order_List,
  Get_Client_Properties,
  Get_Order_Details,
  Put_UpdateOrderStatus,
  Put_UpdatePaymentStatus,
  Get_All_Application,
  Get_Single_ChatData,
  Get_All_ChatData
}

class NetworkConstants {
  static const String CATEGORIES = "categories";
  static const String MERCHANT_PROFILE = "merchantProfile";
  static const String UNIT = "unit";
  static const String MODE = "mode";
  static const String CUSTOMER_TYPE = "customerType";
  static const String DB_CATALOGUE = "dbCatalogue";
  static const String DB_ORDERS = "dbOrders";
  static const String DB_PENDING_ORDERS = "dbPendingOrders";
  static const String DB_COMMUNITY = "dbCommunity";
  static const String CLIENT_GROUP_NAME = "clientGroupName";
  static const String CLIENT_PHONE_NUMBER = "clientPhoneNo";
  static const String CLIENT_NAME = "clientName";
  static const String TOKEN = "token";
  static const String ROLE = "role";
  static const String PHONE_NO = "phoneNo";
  static const String COMMUNITIES = "communities";
  static const String PROPERTIES = "properties";
  static const String SELECTED_COMMUNITY = "selected_community";
  static const String USER_DATA = "user_data";
  static const String NO_COMMUNITIES = "No Communities Available";
  static const String OTP = "OTP";
  static const String ACTION = "action";
  static const String ORDER_ID = "id";
  static const String AMOUNT = "amount";
  static const String ORDER_LIST_PATH = "order_list_path";
  static const String ORDER = "order";
  static const String SelectedOrderDetails = "SelectedOrderDetails";
  static const String SelectedOrderID = "SelectedOrderID";
  static const String CLIENT_KEY = "client_key";
  static const String CLIENT = "client";
  static const String NAME = "name";
  static const String SELECTED_CHATBOT = "selected_chatbot";
  static const String USER_SELECTED_CHATBOT = "user_selected_chatbot";
  static const String SERVICE_PHONE = "service_phone";
  static const String CHATBOT_DEVICE_KEY = "chatbot_device_key";
  static const String CHATBOT_APP_NAME = "chatbot_app_name";
  static const String CHATBOT_ASSET_NAME = "chatbot_asset_name";
  static const String MERCHANT_DETAILS = "merchant_details";
  static const String CONFIRMED = "CONFIRMED";
  static const String DELIVERED = "DELIVERED";
  static const String CANCELLED = "CANCELLED";
  static const String TAKE_OVER = "Take Over";
  static const String RELEASE = "Release";
  static const String LIVE_AGENT_USER_ID = "userId";
  static const String LIVE_AGENT_USER_NAME = "live_agent_user_name";
  static const String USER_ID = "userName";
  static const String PASSWORD = "password";
  static const String EXPIRY_IN_MINUTES = "expiresInMinutes"; //43800
  static const String EXPIRY_IN_MINUTES_VALUE = "43200";
  static const String FCM_TOKEN_ID = "fcm_id";
  static const String AGENT_CHANNEL_VALUE = "websocket";
  static const String LIVE_AGENT_SESSION_ID = "live_agent_session_id";
  static const String CUSTOMER_NAME = "customerName";
  static const String CUSTOMER_NUMBER =
      "customer_number"; //also it is fcm's Data message key
  static const String COUNT_CHATBOT = "count_chatbot";
  static const String LIVE_AGENT_PRIVILEGE = "live_agent_privilege";
  static const String APP_SIGNATURE = "live_agent_privilege";

  static const String LOGIN_DETAILS = "login_Details";
  static const String LEADS = "leads";
  static const String LEAD_TAGS = "lead_tags";
  static const String CUSTOMERS = "customers";
  static const String MERCHANT_USER_ID = "merchantUserId";
  static const String MERCHANT_NAME = "merchantName";
  static const String APP_NAMES = "appnames";
  static const String EVENT_CONNECT = "connect";
  static const String EVENT_CONNECT_ERROR = "connect_error";
  static const String EVENT_MESSAGE = "message";
  static const String EVENT_MESSAGE_RECEIVED = "message_received";
  static const String USERS = "users";
  static const String LEAD_STATUS = "lead_status";

  static String requestBodyLogin(String email, String password) {
    return "{\"" +
        USER_ID +
        "\":\"" +
        email +
        "\",\"" +
        PASSWORD +
        "\":\"" +
        password +
        "\",\"" +
        EXPIRY_IN_MINUTES +
        "\":\"" +
        EXPIRY_IN_MINUTES_VALUE +
        "\"}";
  }

  static String requestBodyVerifyOTP(
      String mobileOrEmail, String otp, String appSignature) {
    return "{\"userId\":\"" +
        mobileOrEmail +
        "\",\"otp\":\"" +
        otp +
        "\",\"" +
        EXPIRY_IN_MINUTES +
        "\":\"" +
        EXPIRY_IN_MINUTES_VALUE +
        "\",\"" +
        APP_SIGNATURE +
        "\":\"" +
        appSignature +
        "\"}";
  }

  static String requestBodyTakeOver(
      String liveAgentUserId,
      String liveAgentUserName,
      String agentChannel,
      String liveAgentSessionId,
      String clientGroup) {
    return "{\"live_agent_user_id\":\"" +
        liveAgentUserId +
        "\",\"live_agent_user_name\":\"" +
        liveAgentUserName +
        "\",\"agent_channel\":\"" +
        agentChannel +
        "\",\"live_agent_session_id\":\"" +
        liveAgentSessionId +
        "\",\"client_group\":\"" +
        clientGroup +
        "\"}";
  }

  static String requestBodyFCM(
      String liveAgentUserId, String token, String clientGroup) {
    String projectId = "com.leads.manager";
    return "{\"user_id\":\"" +
        liveAgentUserId +
        "\",\"fcm_id\":\"" +
        token +
        "\",\"client_group\":\"" +
        clientGroup +
        "\",\"client_app\":\"" +
        projectId +
        "\"}";
  }

  static const String SOCKET_SERVER = "https://websocket-new2.snap.pe/";
  // "https://websocket-staging.snap.pe/"; //"http://10.0.2.2:3001/";// https://websocket-staging.snap.pe/
  //static const String SOCKET_DOMAIN = "dev-cb.snap.pe";
  static const String SOCKET_DOMAIN = "retail.snap.pe";

  static const String Domain = "https://retail.snap.pe/"; //Production End-Point
  //static const String Domain = "https://qa.snap.pe/"; //QA End-Point
  static const String CHAT_DOMAIN =
      "https://retail.snap.pe/"; //Production End-Point
  //static const String CHAT_DOMAIN = "https://staging-cb.snap.pe/"; //QA End-Point
  //static const String CHAT_DOMAIN = "https://dev-cb.snap.pe/";                    //QA End-Point

  static const String MESSENGER_EP =
      "${CHAT_DOMAIN}messenger/chatbot/rest/v1/app/";
  static const String LIVEAGENT_EP =
      CHAT_DOMAIN + "chatbot/rest/v1/app/liveagent/";

  static const String DASHBOARD_EP = Domain + "merchant/orders";
  static const String SnapPe_SERVICES_EP = Domain + "snappe-services/rest/v1/";
  static const String SnapPe_SERVICES_EP_V2 =
      Domain + "snappe-services/rest/v2/";
  static const String MERCHANTS_EP = SnapPe_SERVICES_EP + "merchants/";

  static const String MERCHANTS_EP_V2 = SnapPe_SERVICES_EP_V2 + "merchants/";

  static Uri loginURL = Uri.parse(SnapPe_SERVICES_EP_V2 + "login");
  //https://retail.snap.pe/snappe-services/rest/v1/login

  static Uri getVerifyOtpURL =
      Uri.parse(SnapPe_SERVICES_EP_V2 + "verification/validate/otp");

  static Uri registration = Uri.parse(SnapPe_SERVICES_EP + "registration");
  //https://retail.snap.pe/snappe-services/rest/v1/registration

  // static Uri getOTPUrl() {
  //   return Uri.parse(SnapPe_SERVICES_EP_V2 + "verification/generate/otp");
  //   //https://qa.snap.pe/snappe-services/rest/v2/verification/generate/otp
  // }

  static Uri getUpdateFCMUrl() {
    return Uri.parse("${CHAT_DOMAIN}messenger/chatbot/rest/v1/fcm/connection");
  }

  static Uri getDeleteFCMUrl(String fcmToken) {
    return Uri.parse(
        "${CHAT_DOMAIN}messenger/chatbot/rest/v1/fcm/connection?fcm_id=$fcmToken");
  }

  static Uri getOTPUrl(String mobileOrEmail) {
    return Uri.parse(SnapPe_SERVICES_EP_V2 + "users/" + mobileOrEmail + "/otp");
  }

  static Uri getItems(String clientGroupName, int page, int size,
      {String serachKeyword = ""}) {
    serachKeyword = serachKeyword == "" ? "skus" : "web/skus/$serachKeyword";
    String finalURL = MERCHANTS_EP +
        clientGroupName +
        "/$serachKeyword?page=$page&size=$size&mode=desktop";
    return Uri.parse(finalURL); //&page="+page+"&size=20
    //"https://retail.snap.pe/snappe-services/rest/v1/merchants/RejoiceFresh/skus?page=0&size=15&mode=desktop"
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/web/skus/asd?mode=desktop&page=0&size=15
  }

  static Uri updateItem(String clientGroupName, String skuId) {
    String query = skuId == "null" ? "" : "/$skuId";
    String finalURL = MERCHANTS_EP + clientGroupName + "/skus$query";
    return Uri.parse(finalURL);
    //https://qa.snap.pe/snappe-services/rest/v1/merchants/RejoiceFresh/skus/30041
  }

  static Uri updateLead(String clientGroupName, String leadId) {
    String query = leadId == "null" ? "" : "/$leadId";
    String finalURL;
    if (query == "") {
      finalURL = MERCHANTS_EP + clientGroupName + "/lead$query";
    } else {
      finalURL = MERCHANTS_EP + clientGroupName + "/leads$query";
    }
    print('$query is query');
    print('here is the hitted url $finalURL');
    return Uri.parse(finalURL);
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/TallyDevelopment/leads/7788195
    //https://qa.snap.pe/snappe-services/rest/v1/merchants/RejoiceFresh/skus/30041
  }

  static Uri createNewCustomer(String clientGroupName) {
    String finalURL = MERCHANTS_EP + clientGroupName + "/customers";
    return Uri.parse(finalURL);
    //https://qa.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/customers
  }

  static Uri getCategory(String clientGroupName) {
    String finalURL = MERCHANTS_EP + clientGroupName + "/skus-types";
    return Uri.parse(finalURL);
    //https://qa.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/skus-types
  }

  static Uri getUnit(String clientGroupName) {
    String finalURL = MERCHANTS_EP + clientGroupName + "/skus-units";
    return Uri.parse(finalURL);
    //https://qa.snap.pe/snappe-services/rest/v1/merchants/Mtalkz/skus-units
  }

  static Uri uploadImage(String clientGroupName, int? skuId) {
    String query = skuId == null ? "" : "?skuId=$skuId";
    String finalURL = MERCHANTS_EP + clientGroupName + "/skus/images$query";
    return Uri.parse(finalURL);
    //https://qa.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/skus/images?skuId=707019
  }

  static Uri getAllOrderList(String clientGroupName, int page, int size,
      {int? timeFrom,
      int? timeTo,
      String? searchKeyword,
      String? customerNumber}) {
    String qsSearchKeyword =
        (searchKeyword != null ? "&keyword=$searchKeyword" : "");
    String qsCustomerNumber =
        (customerNumber != null ? "&customerNumber=$customerNumber" : "");
    String qsTimeFrom = (timeFrom != null ? "&timefrom=$timeFrom" : "");
    String qsTimeTo = (searchKeyword != null ? "&timeto=$timeTo" : "");

    String finalURL =
        "$MERCHANTS_EP$clientGroupName/divigo-orders?sortBy=createdOn&sortOrder=DESC&page=$page&size=$size$qsTimeFrom$qsTimeTo$qsSearchKeyword$qsCustomerNumber";

    return Uri.parse(finalURL); //&page="+page+"&size=20

    //https://retail.snap.pe/snappe-services/rest/v1/merchants/JustLaid/divigo-orders?timefrom=1631692192&timeto=1632383391&page=0&size=20&sortBy=createdOn&sortOrder=DESC
  }

  static Uri getTransactionUrl(String clientGroupName, int page, int size,
      {String? customerNumber}) {
    String qsCustomerNumber =
        (customerNumber != null ? "&customerNumber=$customerNumber" : "");

    String finalURL =
        "$MERCHANTS_EP$clientGroupName/transactions?sortBy=createdOn&sortOrder=DESC&page=$page&size=$size$qsCustomerNumber";

    return Uri.parse(finalURL); //&page="+page+"&size=20

    //https://retail.snap.pe/snappe-services/rest/v1/merchants/JustLaid/divigo-orders?timefrom=1631692192&timeto=1632383391&page=0&size=20&sortBy=createdOn&sortOrder=DESC
  }

  static Uri getpendingOrder(
      String clientGroupName, int timeFrom, int timeTo, int page, int size,
      {String? searchKeyword}) {
    String finalURL = MERCHANTS_EP +
        clientGroupName +
        "/snappe-orders?timefrom=$timeFrom&timeto=$timeTo&page=$page&size=$size&sortBy=createdOn&sortOrder=DESC" +
        (searchKeyword != null ? "&keyword=$searchKeyword" : "");
    return Uri.parse(finalURL); //&page="+page+"&size=20

    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/snappe-orders?timefrom=1632832658&timeto=1633523857&page=0&size=20&sortBy=createdOn&sortOrder=DESC
  }

  static Uri getOrderDetails(String clientGroupName, int orderId) {
    String finalURL =
        MERCHANTS_EP + clientGroupName + "/divigo-orders/$orderId";
    return Uri.parse(finalURL); //&page="+page+"&size=20

    //https://qa.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/divigo-orders/755362
  }

  static Uri getConsumer(String phonenNo) {
    String finalURL =
        SnapPe_SERVICES_EP + "consumers/consumer?phoneNo=91$phonenNo";
    return Uri.parse(finalURL); //&page="+page+"&size=20

    //https://qa.snap.pe/snappe-services/rest/v1/consumers/consumer?phoneNo=919026744092
  }

  static Uri getItemsSuggestion(
      String clientGroupName, String pattern, String? priceListCode) {
    String finalURL = MERCHANTS_EP +
        clientGroupName +
        "/web/skus/$pattern?mode=mobile${priceListCode == null ? "" : "&pricelist_code=$priceListCode"}";
    return Uri.parse(finalURL);

    //https://qa.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/web/skus/t?mode=mobile
  }

  static Uri getCustomerSuggestion(String clientGroupName, String pattern) {
    String finalURL = MERCHANTS_EP_V2 +
        clientGroupName +
        "/query-customers/$pattern?page=0&size=10&sortBy=createdOn&sortOrder=DESC";
    return Uri.parse(finalURL);

    //https://qa.snap.pe/snappe-services/rest/v2/merchants/FoodForTravel/query-customers/$pattern?page=0&size=10&sortBy=createdOn&sortOrder=DESC
  }

  static Uri createNewOrder(String clientGroupName) {
    String finalURL = MERCHANTS_EP + clientGroupName + "/web/snappe-order";
    return Uri.parse(finalURL);

    //https://qa.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/web/snappe-order
  }

  static Uri getDeliveryOption(String clientGroupName, String communityName) {
    communityName = "undefined"; // API creater are idiots
    String finalURL = MERCHANTS_EP +
        clientGroupName +
        "/communities/$communityName/deliver-options";
    return Uri.parse(finalURL);

    //https://qa.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/communities/AparnaCyberlife/deliver-options
  }

  static Uri getCommunity(String clientGroupName) {
    String finalURL = MERCHANTS_EP + clientGroupName + "/communities";
    return Uri.parse(finalURL);

    //https://qa.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/communities
  }

  static Uri getProfileUrl(String clientGroupName) {
    String finalURL = MERCHANTS_EP + clientGroupName + "/profile";
    return Uri.parse(finalURL);

    // https://qa.snap.pe/snappe-services/rest/v1/merchants/foodfortravel/profile
  }

  static Uri sendBill(String clientGroupName, String community, String mobile) {
    String finalURL =
        MERCHANTS_EP + clientGroupName + "/paymentlink/$community/$mobile";
    return Uri.parse(finalURL);

    //https://qa.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/paymentlink/DivigoCommunity/919026744092
  }

  static String requestBodySendBill(
      String merchantName, int userId, int orderId, double orderAmount) {
    return "{\"userId\":$userId,\"orderAmount\":$orderAmount,\"orderId\":$orderId,\"merchantName\":\"$merchantName\"}";
  }

  static String downloadInvoice(String clientGroupName, int orderId) {
    var today = DateTime.now().millisecondsSinceEpoch;
    print(today);
    String finalUrl = MERCHANTS_EP +
        clientGroupName +
        "/divigo-orders/$orderId/invoice?invoiceDate=$today&timeZone=Asia/Calcutta";
    return finalUrl;
  }

  static String downloadCatalogue(String clientGroupName) {
    String finalUrl = MERCHANTS_EP + clientGroupName + "/skus/pdf";
    return finalUrl;
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/skus/pdf
  }

  static getWhatsappUrlWithMsg(String? customerNumber, int? id) {
    return "https://api.whatsapp.com/send/?phone=$customerNumber&text=Greetings,%0A%0ARegarding%20your%20order%20number%20$id,%20kindly%20note%0A%0A";
  }

  static getWhatsappUrl(dynamic customerNumber, [message]) {
    if (message == null) {
      return "https://api.whatsapp.com/send/?phone=$customerNumber";
    } else {
      return "https://api.whatsapp.com/send/?phone=$customerNumber&text=$message";
    }
  }

  static Uri acceptOrder(String clientGroupName, int orderId) {
    return Uri.parse(
        MERCHANTS_EP + clientGroupName + "/snappe-orders/$orderId");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/snappe-orders/897897;
  }

  static Uri confirmOrder(String clientGroupName, int orderId) {
    return Uri.parse(MERCHANTS_EP +
        clientGroupName +
        "/snappe-orders/$orderId?paymentType=COD");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/snappe-orders/927641?paymentType=COD
  }

  static getPendingOrderDetails(String clientGroupName, int orderId) {
    String finalURL =
        MERCHANTS_EP + clientGroupName + "/snappe-orders/$orderId";
    return Uri.parse(finalURL);
  }

  static Uri getPriceListUrl(int customerId, String clientGroupName) {
    String finalUrl = MERCHANTS_EP +
        clientGroupName +
        "/pricelist-masters/customers/$customerId";
    return Uri.parse(finalUrl);
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/pricelist-masters/customers/7451
  }

  static Uri getQRCodeUrl(String applicationNo, int userId, int orderId) {
    String finalUrl = SnapPe_SERVICES_EP +
        "applications/$applicationNo/users/$userId/upi-code/${userId}_$orderId.png";
    return Uri.parse(finalUrl);
  }

  static Uri updateOrder(
      String? orderStatus, String? paymentStatus, String clientGroupName) {
    orderStatus = orderStatus == null ? "" : "orderStatus=$orderStatus";
    paymentStatus = paymentStatus == null ? "" : "paymentStatus=$paymentStatus";
    paymentStatus = orderStatus != "" && paymentStatus != ""
        ? "&$paymentStatus"
        : paymentStatus;
    String finalUrl =
        "$MERCHANTS_EP$clientGroupName/divigo-orders?$orderStatus$paymentStatus";
    return Uri.parse(finalUrl);
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/divigo-orders?orderStatus=DELIVERED&paymentStatus=COMPLETED
  }

  static Uri getLeadsUrl(String clientGroupName, int page, int size) {
    return Uri.parse(
        "$MERCHANTS_EP$clientGroupName/filter-leads?page=$page&size=$size&sortBy=lastModifiedTime&sortOrder=DESC");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/SnapPeLeads/filter-leads?page=0&size=20&sortBy=lastModifiedTime&sortOrder=DESC
  }

  static Uri getLeadTagsUrl(String clientGroupName) {
    return Uri.parse("$MERCHANTS_EP$clientGroupName/tags?type=lead");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/tags?type=lead
  }

  static Uri getAssignTagsUrl(String clientGroupName, int leadId) {
    return Uri.parse("$MERCHANTS_EP$clientGroupName/tags/$leadId");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/tags/1431585
  }

  static Uri getLeadStatusUrl(String clientGroupName) {
    return Uri.parse("$MERCHANTS_EP$clientGroupName/lead-status");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/DivigoIndia/lead-status
  }

  static Uri getUsersUrl(String clientGroupName) {
    return Uri.parse("$MERCHANTS_EP$clientGroupName/users?isInternal=true");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/users?isInternal=true
  }

  static Uri searchLeadUrl(String clientGroupName, dynamic searchValue) {
    String queryString = "";
    try {
      searchValue = int.parse(searchValue);
      queryString = "mobileNumber=$searchValue";
    } catch (ex) {
      queryString = "customerName=$searchValue";
    }

    return Uri.parse(
        "$MERCHANTS_EP$clientGroupName/lead-filter?page=0&size=20&sortBy=createdOn&sortOrder=DESC&$queryString");

    // https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/lead-filter?page=0&size=20&sortBy=createdOn&sortOrder=DESC&mobileNumber=9026744
    // https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/lead-filter?page=0&size=20&sortBy=createdOn&sortOrder=DESC&customerName=rohit
  }

  static Uri filterLeadsUrl(String clientGroupName, int page, int size,
      {dynamic nameOrMobile,
      List? assignedTo,
      List? tags,
      List? leadStatus,
      List? assignedBy,
      List<String>? selectedSources,
      List<String>? selectedDates}) {
    String period;
    String queryString = "";
    if (nameOrMobile != null) {
      try {
        nameOrMobile = int.parse(nameOrMobile);
        queryString = "&mobileNumber=$nameOrMobile";
      } catch (ex) {
        queryString =
            "&customerName=$nameOrMobile&cnameOrOrgName=$nameOrMobile";
      }
    }
    if (assignedTo != null && assignedTo.length != 0) {
      queryString = "&assignedTo=";

      assignedTo.forEach((e) => queryString += "$e,");
      queryString = queryString.substring(0, queryString.length - 1);
    }

    if (assignedBy != null && assignedBy.length != 0) {
      queryString += "&assignedBy=";

      assignedBy.forEach((e) => queryString += "$e,");
      queryString = queryString.substring(0, queryString.length - 1);
    }

    if (tags != null && tags.length != 0) {
      queryString += "&tags=";
      tags.forEach((e) => queryString += "$e,");
      queryString = queryString.substring(0, queryString.length - 1);
    }
    if (leadStatus != null && leadStatus.length != 0) {
      queryString += "&status=";
      leadStatus.forEach((e) => queryString += "$e,");
      queryString = queryString.substring(0, queryString.length - 1);
    }
    if (selectedSources != null && selectedSources.length != 0) {
      queryString += "&source=";
      selectedSources.forEach((e) => queryString += "$e,");
      queryString = queryString.substring(0, queryString.length - 1);
    }
    if (selectedDates != null && selectedDates.length != 0) {
      queryString +=
          "&createdOnFrom=${selectedDates[0]}&createdOnTo=${selectedDates[1]}";
    }

    // if (queryString == "") {
    //   period = "&period=lastWeek";
    // } else {
    //   period = "";
    // }
    return Uri.parse(
        "$MERCHANTS_EP$clientGroupName/filter-leads?page=$page&size=$size&sortBy=lastModifiedTime&sortOrder=DESC&$queryString");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/SnapPeLeads/filter-leads?page=0&size=20&sortBy=lastModifiedTime&sortOrder=DESC
  }

  static Uri getCustomersUrl(String clientGroupName) {
    return Uri.parse(
        "$MERCHANTS_EP$clientGroupName/customers?page=0&size=20&sortBy=createdOn&sortOrder=DESC");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/customers?page=0&size=20&sortBy=createdOn&sortOrder=DESC
  }

  static Uri getCustomerDetailsUrl(String clientGroupName, int customerId) {
    return Uri.parse("$MERCHANTS_EP$clientGroupName/customers/$customerId");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/customers/1044269
  }

  static Uri searchCustomerUrl(String clientGroupName, searchValue) {
    String queryString = "";
    try {
      searchValue = int.parse(searchValue);
      queryString = "mobileNumber=$searchValue";
    } catch (ex) {
      queryString = "customerName=$searchValue";
    }

    return Uri.parse(
        "$MERCHANTS_EP$clientGroupName/filter-customers?page=0&size=20&$queryString");

    // https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/filter-customers?page=0&size=20&customerName=rohit
  }

  static Uri getLeadDetailsUrl(String clientGroupName, int leadId) {
    return Uri.parse("$MERCHANTS_EP$clientGroupName/leads/$leadId");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/Plus91Inc/leads/1461947
  }

  static Uri getLeadNotesUrl(String clientGroupName, int leadId) {
    return Uri.parse("$MERCHANTS_EP$clientGroupName/lead-actions/$leadId");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/lead-actions/1431585
  }

  static Uri createNoteUrl(String clientGroupName, int leadId) {
    return Uri.parse("$MERCHANTS_EP$clientGroupName/lead-action/$leadId");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/lead-action/1431585
  }

  static Uri createTaskNoteUrl(String clientGroupName, int taskId) {
    return Uri.parse("$MERCHANTS_EP$clientGroupName/task-action/$taskId");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/task-action/1431585
  }

  static Uri createTaskUrl(String clientGroupName, int leadId) {
    return Uri.parse(
        "$MERCHANTS_EP$clientGroupName/task?leadId=$leadId&followUpUpdate=true");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/task?leadId=1431585
  }

  static Uri createFollowUpUrl(String clientGroupName, int leadId) {
    return Uri.parse("$MERCHANTS_EP$clientGroupName/lead-action/$leadId");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/FoodForTravel/lead-action/1443222
  }

  static Uri getAllAppNameURl(String clientGroupName) {
    return Uri.parse("$MERCHANTS_EP$clientGroupName/applications");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/{client_Group_name}/applications";
  }

  static Uri getPropertiesURl(String clientGroupName, userId) {
    return Uri.parse("$MERCHANTS_EP$clientGroupName/properties?userId=$userId");
    //https://retail.snap.pe/snappe-services/rest/v1/merchants/SnapPeLeads/properties?userId=156";
  }

  static Uri getAllChatDataUrl(
      String clientGroupName, String appName, String tsFrom, String tsTo,String divigoid,
      {int page = 0}) {

    return Uri.parse(
        "https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/applications/$appName/conversations/$tsFrom/$tsTo?page=$page&divigo_session_id=$divigoid");
    //"https://retail.snap.pe/snappe-services/messenger/chatbot/rest/v1/app/{appName}/Conversations/<ts_from>/<ts_to>"
  }

  static Uri getSingleChatData(dynamic mobile, String clientGroupName,
      String appName, String tsFrom, String tsTo) {
    return Uri.parse(
        "${SnapPe_SERVICES_EP}chats/$appName/conversation/$mobile/$tsFrom/$tsTo?merchantName=$clientGroupName");
    // "$MESSENGER_EP$appName/Conversations/Customer/$mobile/$tsFrom/$tsTo?multi_tenant_context=$clientGroupName");
    //"https://retail.snap.pe/snappe-services/messenger/chatbot/rest/v1/app/{appName}/Conversations/Customer/<destination_id>/<ts_from>/<ts_to>"
  }

  static Uri overrideStatusUrl(
      String appName, String destinationId, String clientGroupName,
      {bool isCheckOverrideStatus = false}) {
    //GET - CheckOverrideStatus
    //POST {"live_agent_user_id": None} - TakeOver
    //Delete - ReleaseOverrideStatus
    String url = "$LIVEAGENT_EP$appName/$destinationId";

    if (isCheckOverrideStatus) {
      url = url + "?client_group=$clientGroupName";
    }

    return Uri.parse(url);
  }

  // static String GetUrl(UrlName urlName, String clientGroupName) {
  //     //https://retail.snap.pe/snappe-services/rest/v1/merchants/{client_Group_name}";
  //     //http://44.238.171.136:8082/snappe-services/{client_Group_name}
  //     String finalURL = MERCHANTS_EP + clientGroupName;

  //     switch (urlName) {
  //         case  UrlName.Get_All_Communities:
  //             return finalURL + communities_URL;//https://.snap.pe/snappe-services/rest/v1/merchants/{client_Group_name}/communities";
  //         case UrlName.Get_Order_List:
  //             return finalURL + orders_URL;//https://retail.snap.pe/snappe-services/rest/v1/merchants/{client_Group_name}/orders?communityName=";
  //         case UrlName.Get_Client_Properties:
  //             return finalURL + properties_URL;//https://retail.snap.pe/snappe-services/rest/v1/merchants/{client_Group_name}/properties";
  //         case UrlName.Get_Order_Details:
  //             return finalURL + orderDetails_URL;//https://retail.snap.pe/snappe-services/rest/v1/merchants/{client_Group_name}/delivery/divigo-orders/details/";
  //         case UrlName.Put_UpdateOrderStatus:
  //             return finalURL + updateOrderStatus_URL;//https://retail.snap.pe/snappe-services/rest/v1/merchants/{client_Group_name}/divigo-orders?orderStatus=";
  //         case UrlName.Put_UpdatePaymentStatus:
  //             return finalURL + updatePaymentStatus_URL;//https://retail.snap.pe/snappe-services/rest/v1/merchants/{client_Group_name}/divigo-orders?orderStatus=DELIVERED&paymentStatus=COMPLETED";
  //         case UrlName.Get_All_Application:
  //             return finalURL + application_URL;//https://retail.snap.pe/snappe-services/rest/v1/merchants/{client_Group_name}/applications";
  //         default:
  //             return "";
  //     }
  // }

  // static const String communities_URL = "/communities";
  // static const String properties_URL = "/properties";
  // static const String orders_URL = "/orders?communityName=";
  // static const String orderDetails_URL = "/delivery/divigo-orders/details/";
  // static const String updateOrderStatus_URL = "/divigo-orders?orderStatus=";
  // static const String updatePaymentStatus_URL = "/divigo-orders?orderStatus=DELIVERED&paymentStatus=COMPLETED";
  // static const String application_URL = "/applications";

  // static String GetChatDataUrl(urlName urlName, String appName, String tsFrom, String tsTo, String destinationId,String clientGroup) {
  //     //https://retail.snap.pe/messenger/chatbot/rest/v1/app/divigo1/Conversations/1615053111/1617645111

  //     switch (urlName) {
  //         case Get_All_ChatData:
  //             //"https://retail.snap.pe/snappe-services/messenger/chatbot/rest/v1/app/{appName}/Conversations/<ts_from>/<ts_to>"
  //             return MESSENGER_EP + appName + "/Conversations/" + tsFrom + "/" + tsTo+"?multi_tenant_context="+clientGroup;

  //         case Get_Single_ChatData:
  //             //"https://retail.snap.pe/snappe-services/messenger/chatbot/rest/v1/app/{appName}/Conversations/Customer/<destination_id>/<ts_from>/<ts_to>"
  //             return MESSENGER_EP + appName + "/Conversations/Customer/" + destinationId + "/" + tsFrom + "/" + tsTo+"?multi_tenant_context="+clientGroup;

  //         default:
  //             return "";
  //     }
  // }

  // static String SendMessage(String appName, String destinationId) {
  //     return MESSENGER_EP + appName + "/customer/" + destinationId + "/sendmessage";
  // }

  // static String SearchOrder_URL(String clientGroupName, String timeFrom, String timeTo, int page, int size ,String searchKeyword){
  //     page = 0;
  //     size = 20;
  //     String finalURL = MERCHANTS_EP + clientGroupName +"/divigo-orders?timefrom="+timeFrom+"&timeto="+timeTo+"&page="+page+"&size="+size+"&keyword="+searchKeyword+"&sortBy=createdOn&sortOrder=DESC";
  //     return finalURL ;//&page="+page+"&size=20
  //     //https://retail.snap.pe/snappe-services/rest/v1/merchants/JustLaid/divigo-orders?timefrom=1623964229&timeto=1624655428&page=0&size=20&keyword=47&sortBy=createdOn&sortOrder=DESC
  // }

  // static const String PREF_NAME = "SnapBasketDelivery";
  // static const String MSG_INTERNET_CONNECTION_ERROR = "No Internet ConnectedActivity";
  // static const String MSG_PLEASE_CONNECT_INTERNET = "Please check your internet connection or try again later";
  // static const String MSG_PLEASE_SELECT_COMMUNITY = "Please Select Community";
  // static const String MSG_PROCESSING = "Processing...";
  // static const String URL_APPLICATION_TYPE = "application/json";
  // int ENCODE_URL_CONNECT_TIMEOUT = 10000;
  // static const String NO_INTERNET = "No Internet Connection!";
  // static const String SOMETHINGWRONG = "Something Went Wrong, Please Try After Sometime";
  // static const String INVALIDUSER = "Invalid User";
}
