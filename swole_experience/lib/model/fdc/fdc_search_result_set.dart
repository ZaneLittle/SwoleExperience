import 'package:uuid/uuid.dart';

import 'package:swole_experience/model/fdc/fdc_search_result.dart';
import 'package:swole_experience/model/food.dart';

/// See: https://app.swaggerhub.com/apis/fdcnal/food-data_central_api/1.0.1#/FDC/postFoodsSearch
class FdcSearchResultSet {
  FdcSearchResultSet({
    this.totalHits,
    this.currentPage,
    this.totalPages,
    this.foods,
  });

  final int? totalHits;
  final int? currentPage;
  final int? totalPages;
  final List<FdcSearchResult>? foods;

  factory FdcSearchResultSet.fromJson(Map<String, dynamic> json) {
    List<FdcSearchResult>? foods =  (json['foods'] as List)
        .map((i) => FdcSearchResult.fromJson(i))
        .toList();
    return FdcSearchResultSet(
      totalHits: json['totalHits'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      foods: foods
    );
  }

  Map<String, dynamic> toJson() => {
    'totalHits': totalHits,
    'currentPage': currentPage,
    'totalPages': totalPages,
    'foods': foods?.map((i) => i.toJson()).toList(),
  };

  List<Food>? getFoods() => foods?.map((f) => f.toFood()).toList();
}
