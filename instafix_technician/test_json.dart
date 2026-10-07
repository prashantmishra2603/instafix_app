import "dart:convert";
import "lib/models/booking.dart";

void main() {
  String jsonStr = """[{"id":15,"booking_code":"INSTA-DSIVNT","customer_id":null,"technician_id":null,"brand_name":"Apple","model_name":"iPhone","service_name":"Repair","estimated_cost":"100.00","final_cost":"100.00","status":"pending","customer_name":"Test","customer_phone":"9876543210","customer_address":"Test","city":"Bengaluru","scheduled_date":"2024-01-01","time_slot":"2:00 PM","extra_work_requested":false,"extra_work_description":null,"extra_work_cost":"0.00","extra_work_approved":false,"payment_status":"pending","warranty_days":90,"created_at":"2026-10-05T13:37:57.000000Z","updated_at":"2026-10-05T13:37:57.000000Z","fulfillment_type":"admin_shop"}]""";

  var list = jsonDecode(jsonStr) as List;
  for (var item in list) {
    try {
      var booking = Booking.fromJson(Map<String, dynamic>.from(item));
      print("Success: ${booking.id}");
    } catch(e, s) {
      print("Error: $e\n$s");
    }
  }
}
