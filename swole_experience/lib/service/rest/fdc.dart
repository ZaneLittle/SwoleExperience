import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'package:swole_experience/model/fdc/fdc_search_result_set.dart';
import 'package:swole_experience/model/response/food_response.dart';
import 'package:swole_experience/model/response/response.dart';

/// REST API Service for the FDC
/// https://fdc.nal.usda.gov/api-guide.html
class FdcService {
  final _apiKey = "8JJYtSEUdi3ctFQR5ClTq2qudftpqfIEWgOJo6fA"; // TODO: Should probably obfuscate this somehow?
  final Logger logger = Logger();

  Future<FoodResponse> search(String? userQuery) async {
    if (userQuery == null || userQuery.length < 2) {
      return FoodResponse(data: [], total: 0);
    }

    final response = await http.post(
        Uri.parse('https://api.nal.usda.gov/fdc/v1/foods/search?api_key=$_apiKey'),
        headers: { 'Content-Type': 'application/json', },
        body: jsonEncode({
          'query': userQuery,
        })
    ).catchError((e, st) {
      logger.e('Encountered an unexpected error with the FDC API.', time: DateTime.now(), error: e, stackTrace: st);
      return http.Response(e, 500);
    });
    
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final res = FdcSearchResultSet.fromJson(body);
      return FoodResponse(data: res.getFoods() ?? [], total: res.totalHits ?? 0); // TODO: Should we exclude foods with a serving size of 0 / no nutritional info?
    } else {
      logger.e('FDC search returned an error: ${response.statusCode} - ${response.body}');
      return FoodResponse(data: [], total: 0, error: ResponseError(statusCode: response.statusCode, message: response.body));
    }
  }
}