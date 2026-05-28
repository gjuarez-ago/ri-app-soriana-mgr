import 'package:ago_app/models/FurnitureSupercitosResponse.dart';
import 'package:ago_app/models/category_response.dart';
import 'package:ago_app/models/fixissues_response.dart';
import 'package:ago_app/models/segmentsSupercitos.dart';
import 'package:ago_app/models/send_pictures_supercitos_params.dart';
import 'package:ago_app/models/send_pictures_supercitos_response.dart';
import 'package:ago_app/models/store_response.dart';
import 'package:ago_app/models/supercito_delete_response.dart';
import 'package:ago_app/models/supercito_segm_stats_detail.dart';
import 'package:ago_app/models/supercito_segment_detail.dart';
import 'package:ago_app/models/supercito_segment_eventos.dart';
import 'package:ago_app/models/supercito_segment_stats_response.dart';
import 'package:ago_app/models/supercito_segments_stats_detail_request.dart';
import 'package:ago_app/services/supercitos_service.dart';

class SupercitosRepository {
  
  SupercitosService service = SupercitosService();

  Future<List<StoreResponse>> getStoresBySupercitos(String category) =>
      service.getStoresBySupercitos(category);

  Future<List<CategoryResponse>> getCategoriesBySupercitos() =>
      service.getCategoriesBySupercitos();

  Future<List<FurnitureSupercitosResponse>> getFurnitureBySupercito(
          int store, int idBitacora) =>
      service.getFurnitureBySupercito(store, idBitacora);

  Future<List<SegmentsSupercitos>> getSegmentsBySupercito(int piIdRealograma) =>
      service.getSegmentsBySupercito(piIdRealograma);

  Future<SupercitoDeleteResponse> deleteTramoSupercitos(
          int idRealograma, int tramo) =>
      service.deleteTramoSupercitos(idRealograma, tramo);

  /// Obtiene el detalle de un tramo de supercitos.
  Future<SupercitoSegmentDetail> getDetailTramoSupercito(
          int idRealograma, int tramo) =>
      service.getDetailTramoSupercito(idRealograma, tramo);

  /// Cierra el proceso de supercitos.
  Future<FixIssuesResponse> cierreSupercitos(int idRealograma) =>
      service.cierreSupercitos(idRealograma);

  Future<SendPictureSupectitosResponse> sendPicturesV1Supercitos(SendPicturesSupercitosParams params) =>
      service.sendPicturesV1Supercitos(params);



  Future<List<SupercitoSegmStatsDetail>> getStatsDetails(
          SupercitoSegmentStatsDetailRequest request) =>
      service.getStatsDetails(request);

  Future<SupercitoSegmentStatsResponse> getSegmentsStatsSupercitos(
          int tienda, int idEvento, int idBitacora) =>
      service.getSegmentsStatsSupercitos(
        tienda,
        idEvento,
        idBitacora,
      );

  Future<List<SupercitoSegmentEventos>> getEventsSupercito(int tienda, String categoria) =>
      service.getEventsSupercito(tienda, categoria);
 
}
