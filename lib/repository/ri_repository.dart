import 'package:ago_app/models/CapturarFaltanteParams.dart';
import 'package:ago_app/models/consultas_response.dart';
import 'package:ago_app/models/location_response.dart';
import 'package:ago_app/models/label_incidents_response.dart';
import 'package:ago_app/models/login_response.dart';
import 'package:ago_app/models/nuevos_planogramas_impl_response.dart';
import 'package:ago_app/models/planogram.dart';
import 'package:ago_app/models/capture_response.dart';
import 'package:ago_app/models/category_response.dart';
import 'package:ago_app/models/detalle_nivel_con_imagen.dart';
import 'package:ago_app/models/detalle_nivel_params.dart';
import 'package:ago_app/models/detalle_nivel_response.dart';
import 'package:ago_app/models/event_details.dart';
import 'package:ago_app/models/events_response.dart';
import 'package:ago_app/models/faltante_response.dart';
import 'package:ago_app/models/fix_response.dart';
import 'package:ago_app/models/fix_single_issue.dart';
import 'package:ago_app/models/fixissues_response.dart';
import 'package:ago_app/models/furniture_segm_response.dart';
import 'package:ago_app/models/get_issues_params.dart';
import 'package:ago_app/models/incidents_response.dart';
import 'package:ago_app/models/layout_faltante_params.dart';
import 'package:ago_app/models/layout_faltante_response.dart';
import 'package:ago_app/models/muebles_categoria_response.dart';
import 'package:ago_app/models/planogram_item_product.dart';
import 'package:ago_app/models/resume_pictures_params.dart';
import 'package:ago_app/models/resume_pictures_response.dart';
import 'package:ago_app/models/segments_incidents_response.dart';
import 'package:ago_app/models/send_picture_params.dart';
import 'package:ago_app/models/send_picture_params_v2.dart';
import 'package:ago_app/models/send_pictures_response.dart';
import 'package:ago_app/models/store_response.dart';
import 'package:ago_app/models/deparments_response.dart';
import 'package:ago_app/models/furniture_response.dart';
import 'package:ago_app/models/product_list_response.dart';
import 'package:ago_app/models/tienda_l_request.dart';
import 'package:ago_app/models/tienda_l_response.dart';
import 'package:ago_app/models/tramos_mueble_response.dart';
import 'package:ago_app/models/validate_categories.dart';
import 'package:ago_app/models/validate_ceros_response.dart';
import 'package:ago_app/models/validate_tramos_request.dart';
import 'package:ago_app/models/validateceros.dart';
import 'package:ago_app/services/ri_service.dart';
import '../models/misplaced_products_response.dart';
import '../models/producto_mal_acomodado_secuencia.dart';
import '../models/producto_sin_hueco.dart';
import '../models/adyacencia_error_response.dart';

class RIRepository {
  RIService service = RIService();

  Future<List<CategoryResponse>> getCategories() => service.getAllCategories();

  Future<List<Planograma>> getPdfPlanogram(
          String category, String store, bool esSupercito) =>
      service.getPdfPlanogram(store, category, esSupercito);

  Future<CategoryResponse> getAllCategoriesByUPC(int store, String upc) =>
      service.getAllCategoriesByUPC(store, upc);

  Future<List<StoreResponse>> getStores(String categoria) =>
      service.getStores(categoria);

  Future<List<StoreResponse>> getStoresIndicadores() =>
      service.getStoresIndicadores();

  Future<List<DeparmentsResponse>> getDeptosTienda(int storeId, int event) =>
      service.getDeptosTienda(storeId, event);

  Future<List<FurnitureResponse>> getMueblesTienda(
          int storeId, int event, String categoria, int bitacora) =>
      service.getMueblesTienda(storeId, event, categoria, bitacora);

  Future<List<SegmentIncidentsResponse>> getIncidencias(
          int idReconocimiento, int tramo) =>
      service.getIncidencias(idReconocimiento, tramo);

  Future<List<FurnitureSegmentResponse>> getSegmentos(
          int idRealograma, String idCategoria) =>
      service.getSegmentos(idRealograma, idCategoria);

  Future<List<ProductListResponse>> getProductos(
          int idReconocimiento, int tramo) =>
      service.getProductos(idReconocimiento, tramo);

  Future<FixIssuesResponse> getFixIssue(String incidencias) =>
      service.getFixIssue(incidencias);

  Future<FixResponse> fixSingleIssue(FixSingleIssueParams incidencia) =>
      service.fixSingleIssue(incidencia);

  Future<CaptureResponse> capturarFaltante(CapturarFaltanteParams incidencia) =>
      service.capturarFaltante(incidencia);

  Future<List<IncidentsResponse>> getIncidenciasV2(GetIssuesParams request) =>
      service.getListIncidentsV2(request);

  Future<FixIssuesResponse> generarIndicadores(GetIssuesParams request) =>
      service.generarIndicadores(request);

  Future<int> getStatusIndicadores(GetIssuesParams request) =>
      service.getStatusIndicadores(request);

  Future<FixIssuesResponse> cierreTienda(GetIssuesParams request) =>
      service.cierreTienda(request);

  Future<SendPictureResponse> sendPictures(SendPictureParams params) =>
      service.sendPictures(params);

  Future<SendPictureResponse> sendPicturesV2(SendPictureParamsV2 params) =>
      service.sendPicturesV2(params);

  Future<ResumePicturesResponse> getResumenProducts(
          ResumePicturesParams params) =>
      service.getResumenProducts(params);

  Future<String> deleteTramo(int idReconocimiento, int tramo) =>
      service.deleteTramo(idReconocimiento, tramo);

  Future<FurnitureSegmentResponse> getResumeTramo(
          int idReconocimiento, int tramo) =>
      service.getResumeTramo(idReconocimiento, tramo);

  Future<List<EventsResponse>> getReporteEventosTiendas(
          GetIssuesParams request) =>
      service.getReporteEventosTiendas(request);

  Future<EventDetail> getResumenIndicadores(GetIssuesParams request) =>
      service.getResumenIndicadores(request);

  Future<List<FaltanteResponse>> getProductosFaltantes(
          GetIssuesParams request) =>
      service.getProductosFaltantes(request);

  Future<List<LayoutFaltanteResponse>> getLayoutProductosFaltantes(
          LayoutFaltantesParams request) =>
      service.getLayoutProductosFaltantes(request);

  // Repositorio para getMueblesCategoria
  Future<List<MueblesCategoriaResponse>> getMueblesCategoria(
          GetIssuesParams request, bool esSupercito) =>
      service.getMueblesCategoria(request, esSupercito);

// Repositorio para getDetalleNivel
  Future<List<DetalleNivelResponse>> getDetalleNivel(
          DetalleNivelParams request, bool esSupercito) =>
      service.getDetalleNivel(request, esSupercito);

// Repositorio para getTramosMueble
  Future<List<TramosMuebleResponse>> getTramosMueble(
          int idReconocimiento, int idRealograma, bool esSupercito) =>
      service.getTramosMueble(idReconocimiento, idRealograma, esSupercito);

  Future<String> getImagenByTramo(
          int idReconocimiento, int idRealograma, int tramo) =>
      service.getImagenByTramo(idReconocimiento, idRealograma, tramo);

  Future<String> getPdfByCategory(String categoria, int tienda) =>
      service.getPdfByCategory(categoria, tienda);

  Future<DetalleNivelConImagen> getDetalleNivelConImagen(
          DetalleNivelParams request, bool esSupercito) =>
      service.getDetalleNivelConImagen(request, esSupercito);

  Future<ConstantsEnviroment> getConstants() => service.getParams();

  Future<List<TiendaLResponse>> getAvanceCategoria(TiendaLRequest request) =>
      service.getAvanceAuditoria(request);

  Future<MisplacedProductsResponse> getMisplacedProducts(
    int idBitacora, {
    required int idTienda,
    required int idEvento,
    required String categoria,
  }) =>
      service.getMisplacedProducts(
        idBitacora,
        idTienda: idTienda,
        idEvento: idEvento,
        categoria: categoria,
      );
  Future<IncidenciasEtiquetasResponse> getLabelWithIncidents(int idBitacora) =>
      service.getLabelWithIncidents(idBitacora);

  Future<List<UbicacionResponse>> getLocations() => service.getLocations();

  Future<ValidateCerosResponse> getValidateCeros(ValidateCeros idBitacora) =>
      service.getValidateCeros(idBitacora);

  Future<ConsultasResponse> getValidateCategories(ValidateCategories request) =>
      service.getValidateCategories(request);

  Future<ConsultasResponse> getValidateTramos(ValidaTramosRequest request) =>
      service.getValidateTramos(request);

  Future<List<PlanogramaItemResponse>> getProductPLN(int store, String upc) =>
      service.getProductPLN(store, upc);

  Future<NuevosPlanogramasImplResponse> getImplementationOfPlanograms(
          int idTienda) =>
      service.getImplementationOfPlanograms(idTienda);

  Future<bool> setPlanogramaImplementado(int id, int idTienda) =>
      service.setPlanogramaImplementado(id, idTienda);

  Future<List<ProductoMalAcomodadoSecuencia>> getProductosMalAcomodadosSecuencia(int idBitacora) =>
      service.getProductosMalAcomodadosSecuencia(idBitacora);

  Future<List<ProductoSinHueco>> getProductosSinHuecos(int idBitacora) =>
      service.getProductosSinHuecos(idBitacora);

  Future<List<AdyacenciaErrorResponse>> getAdyacenciaError(int idBitacora) =>
      service.getAdyacenciaError(idBitacora);
}
