import 'package:nsapp/core/helpers/use_case.dart';

class RequestSearchParams extends Params {
  final String? query;
  final double? lat;
  final double? lng;
  final double? radius;
  final int? page;

  final bool? targeted;
  final String? catalogServiceId;

  RequestSearchParams({
    this.query,
    this.lat,
    this.lng,
    this.radius,
    this.page,
    this.targeted,
    this.catalogServiceId,
  });
}
