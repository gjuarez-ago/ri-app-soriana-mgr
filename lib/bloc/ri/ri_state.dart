import 'package:ago_app/models/FurnitureSupercitosResponse.dart';
import 'package:ago_app/models/consultas_response.dart';
import 'package:ago_app/models/location_response.dart';
import 'package:ago_app/models/label_incidents_response.dart';
import 'package:ago_app/models/misplaced_products_response.dart';
import 'package:ago_app/models/login_response.dart';
import 'package:ago_app/models/nuevos_planogramas_impl_response.dart';
import 'package:ago_app/models/planogram.dart';
import 'package:ago_app/models/capture_response.dart';
import 'package:ago_app/models/detalle_nivel_con_imagen.dart';
import 'package:ago_app/models/detalle_nivel_response.dart';
import 'package:ago_app/models/event_details.dart';
import 'package:ago_app/models/events_response.dart';
import 'package:ago_app/models/faltante_response.dart';
import 'package:ago_app/models/fix_response.dart';
import 'package:ago_app/models/fixissues_response.dart';
import 'package:ago_app/models/furniture_segm_response.dart';
import 'package:ago_app/models/incidents_response.dart';
import 'package:ago_app/models/layout_faltante_response.dart';
import 'package:ago_app/models/muebles_categoria_response.dart';
import 'package:ago_app/models/planogram_item_product.dart';
import 'package:ago_app/models/resume_pictures_response.dart';
import 'package:ago_app/models/segmentsSupercitos.dart';
import 'package:ago_app/models/segments_incidents_response.dart';
import 'package:ago_app/models/send_pictures_response.dart';
import 'package:ago_app/models/send_pictures_supercitos_response.dart';
import 'package:ago_app/models/supercito_delete_response.dart';
import 'package:ago_app/models/supercito_segm_stats_detail.dart';
import 'package:ago_app/models/supercito_segment_detail.dart';
import 'package:ago_app/models/supercito_segment_eventos.dart';
import 'package:ago_app/models/supercito_segment_stats_response.dart';
import 'package:ago_app/models/tienda_l_response.dart';
import 'package:ago_app/models/tramos_mueble_response.dart';
import 'package:ago_app/models/validate_ceros_response.dart';
import 'package:flutter/material.dart';
import 'package:ago_app/models/category_response.dart';
import 'package:ago_app/models/store_response.dart';
import 'package:ago_app/models/deparments_response.dart';
import 'package:ago_app/models/furniture_response.dart';
import 'package:ago_app/models/product_list_response.dart';
import 'package:ago_app/models/producto_mal_acomodado_secuencia.dart';
import 'package:ago_app/models/producto_sin_hueco.dart';
import 'package:ago_app/models/adyacencia_error_response.dart';

@immutable
class RIState {
  final String? messageError;

  const RIState({this.messageError});
}

class InitialRIState extends RIState {}

// Estados para Categorías
class IsLoadingGetCategory extends RIState {}

class ErrorGetCategory extends RIState {
  const ErrorGetCategory({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetCategory extends RIState {
  final List<CategoryResponse> response;

  const SuccessGetCategory({required this.response}) : super();
}

// Estados para Tiendas
class IsLoadingGetStore extends RIState {}

class ErrorGetStore extends RIState {
  const ErrorGetStore({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetStore extends RIState {
  final List<StoreResponse> response;

  const SuccessGetStore({required this.response}) : super();
}

// Estados para Departamentos
class IsLoadingGetDeparments extends RIState {}

class ErrorGetDeparments extends RIState {
  const ErrorGetDeparments({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetDeparments extends RIState {
  final List<DeparmentsResponse> response;

  const SuccessGetDeparments({required this.response}) : super();
}

// Estados para Muebles
class IsLoadingGetFurniture extends RIState {}

class ErrorGetFurniture extends RIState {
  const ErrorGetFurniture({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetFurniture extends RIState {
  final List<FurnitureResponse> response;

  const SuccessGetFurniture({required this.response}) : super();
}

// Estados para Incidentes de Segmentos
class IsLoadingGetSegmentIncidents extends RIState {}

class ErrorGetSegmentIncidents extends RIState {
  const ErrorGetSegmentIncidents({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetSegmentIncidents extends RIState {
  final List<SegmentIncidentsResponse> response;

  const SuccessGetSegmentIncidents({required this.response}) : super();
}

// Estados para Segmentos de Muebles
class IsLoadingGetFurnitureSegment extends RIState {}

class ErrorGetFurnitureSegment extends RIState {
  const ErrorGetFurnitureSegment({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetFurnitureSegment extends RIState {
  final List<FurnitureSegmentResponse> response;
  const SuccessGetFurnitureSegment({required this.response}) : super();
}

// Estados para Productos
class IsLoadingGetProducts extends RIState {}

class ErrorGetProducts extends RIState {
  const ErrorGetProducts({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetProducts extends RIState {
  final List<ProductListResponse> response;

  const SuccessGetProducts({required this.response}) : super();
}

// Estado para Resolver Incidencias
class IsLoadingFixIssue extends RIState {}

class ErrorFixIssue extends RIState {
  const ErrorFixIssue({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessFixIssue extends RIState {
  final FixIssuesResponse response;

  const SuccessFixIssue({required this.response}) : super();
}

// Estado para pegar las imágenes
class IsLoadingSendPictures extends RIState {}

class ErrorSendPictures extends RIState {
  const ErrorSendPictures({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessSendPictures extends RIState {
  final SendPictureResponse response;

  const SuccessSendPictures({required this.response}) : super();
}

class IsLoadingGetResumePicture extends RIState {}

class ErrorGetResumePicture extends RIState {
  const ErrorGetResumePicture({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetResumePicture extends RIState {
  final ResumePicturesResponse response;

  const SuccessGetResumePicture({required this.response}) : super();
}

class IsLoadingDeleteTramo extends RIState {}

class ErrorDeleteTramo extends RIState {
  const ErrorDeleteTramo({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessDeleteTramo extends RIState {
  final String response;
  const SuccessDeleteTramo({required this.response}) : super();
}

class IsLoadingGetResumeTramo extends RIState {}

class ErrorGetResumeTramo extends RIState {
  const ErrorGetResumeTramo({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetResumeTramo extends RIState {
  final FurnitureSegmentResponse response;
  const SuccessGetResumeTramo({required this.response}) : super();
}

// Estados para el servicio fixSingleIssue
class IsLoadingFixSingleIssue extends RIState {}

class ErrorFixSingleIssue extends RIState {
  const ErrorFixSingleIssue({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessFixSingleIssue extends RIState {
  final FixResponse response;

  const SuccessFixSingleIssue({required this.response}) : super();
}

// Estados para el servicio getIncidenciasV2
class IsLoadingGetIncidenciasV2 extends RIState {}

class ErrorGetIncidenciasV2 extends RIState {
  const ErrorGetIncidenciasV2({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetIncidenciasV2 extends RIState {
  final List<IncidentsResponse> response;

  const SuccessGetIncidenciasV2({required this.response}) : super();
}

// Estados para el servicio generarIndicadores
class IsLoadingGenerarIndicadores extends RIState {}

class ErrorGenerarIndicadores extends RIState {
  const ErrorGenerarIndicadores({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGenerarIndicadores extends RIState {
  final FixIssuesResponse response;

  const SuccessGenerarIndicadores({required this.response}) : super();
}

// Estados para el servicio generarIndicadores
class IsLoadingCierreTienda extends RIState {}

class ErrorCierreTienda extends RIState {
  const ErrorCierreTienda({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessCierreTienda extends RIState {
  final FixIssuesResponse response;

  const SuccessCierreTienda({required this.response}) : super();
}

class IsLoadingIndicadores extends RIState {}

class ErrorIndicadores extends RIState {
  const ErrorIndicadores({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessIndicadores extends RIState {
  final int status;

  const SuccessIndicadores({required this.status}) : super();
}

class IsLoadingReporteEventosTiendas extends RIState {}

class ErrorReporteEventosTiendas extends RIState {
  const ErrorReporteEventosTiendas({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessReporteEventosTiendas extends RIState {
  final List<EventsResponse> events;

  const SuccessReporteEventosTiendas({required this.events}) : super();
}

class IsLoadingResumenIndicadores extends RIState {}

class ErrorResumenIndicadores extends RIState {
  const ErrorResumenIndicadores({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessResumenIndicadores extends RIState {
  final EventDetail indicadores;

  const SuccessResumenIndicadores({required this.indicadores}) : super();
}

class IsLoadingProductosFaltantes extends RIState {}

class ErrorProductosFaltantes extends RIState {
  const ErrorProductosFaltantes({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessProductosFaltantes extends RIState {
  final List<FaltanteResponse> productosFaltantes;

  const SuccessProductosFaltantes({required this.productosFaltantes}) : super();
}

// Estados para MueblesCategoria
class IsLoadingGetMueblesCategoria extends RIState {}

class ErrorGetMueblesCategoria extends RIState {
  const ErrorGetMueblesCategoria({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetMueblesCategoria extends RIState {
  final List<MueblesCategoriaResponse> response;

  const SuccessGetMueblesCategoria({required this.response}) : super();
}

// Estados para DetalleNivel
class IsLoadingGetDetalleNivel extends RIState {}

class ErrorGetDetalleNivel extends RIState {
  const ErrorGetDetalleNivel({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetDetalleNivel extends RIState {
  final List<DetalleNivelResponse> response;

  const SuccessGetDetalleNivel({required this.response}) : super();
}

// Estados para TramosMueble
class IsLoadingGetTramosMueble extends RIState {}

class ErrorGetTramosMueble extends RIState {
  const ErrorGetTramosMueble({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetTramosMueble extends RIState {
  final List<TramosMuebleResponse> response;

  const SuccessGetTramosMueble({required this.response}) : super();
}

class IsLoadingGetImagenTramo extends RIState {}

class ErrorGetImagenTramo extends RIState {
  const ErrorGetImagenTramo({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetImagenTramo extends RIState {
  final DetalleNivelConImagen response;

  const SuccessGetImagenTramo({required this.response}) : super();
}

class IsLoadingCapturarFaltante extends RIState {}

class ErrorCapturarFaltante extends RIState {
  const ErrorCapturarFaltante({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessCapturarFaltante extends RIState {
  final CaptureResponse response;
  const SuccessCapturarFaltante({required this.response}) : super();
}

class IsLoadingPdfView extends RIState {}

class ErrorPdfView extends RIState {
  const ErrorPdfView({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessPdfView extends RIState {
  final String response;
  const SuccessPdfView({required this.response}) : super();
}

class IsLoadingLayoutProductosFaltantes extends RIState {}

class ErrorLayoutProductosFaltantes extends RIState {
  const ErrorLayoutProductosFaltantes({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessLayoutProductosFaltantes extends RIState {
  final List<LayoutFaltanteResponse> productosFaltantes;
  const SuccessLayoutProductosFaltantes({required this.productosFaltantes})
      : super();
}

class IsLoadingGetCategoriesByUPC extends RIState {}

class ErrorGetCategoriesByUPC extends RIState {
  const ErrorGetCategoriesByUPC({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetCategoriesByUPC extends RIState {
  final CategoryResponse response;
  const SuccessGetCategoriesByUPC({required this.response}) : super();
}

class IsLoadingGetPdfPlanogram extends RIState {}

class ErrorGetPdfPlanogram extends RIState {
  const ErrorGetPdfPlanogram({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetPdfPlanogram extends RIState {
  final List<Planograma> response;
  const SuccessGetPdfPlanogram({required this.response}) : super();
}

class IsLoadingGetStoresSupercitos extends RIState {}

class ErrorGetStoresSupercitos extends RIState {
  const ErrorGetStoresSupercitos({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetStoresSupercitos extends RIState {
  final List<StoreResponse> response;
  const SuccessGetStoresSupercitos({required this.response}) : super();
}

class IsLoadingGetFurnitureSupercitos extends RIState {}

class ErrorGetFurnitureSupercitos extends RIState {
  const ErrorGetFurnitureSupercitos({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetFurnitureSupercitos extends RIState {
  final List<FurnitureSupercitosResponse> response;
  const SuccessGetFurnitureSupercitos({required this.response}) : super();
}

class IsLoadingGetSegmentsSupercitos extends RIState {}

class ErrorGetSegmentsSupercitos extends RIState {
  const ErrorGetSegmentsSupercitos({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetSegmentsSupercitos extends RIState {
  final List<SegmentsSupercitos> response;
  const SuccessGetSegmentsSupercitos({required this.response}) : super();
}

class IsLoadingDeleteTramoSupercitos extends RIState {}

class ErrorDeleteTramoSupercitos extends RIState {
  const ErrorDeleteTramoSupercitos({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessDeleteTramoSupercitos extends RIState {
  
  final SupercitoDeleteResponse response;

  const SuccessDeleteTramoSupercitos({required this.response});
}

class IsLoadingGetDetailTramoSupercito extends RIState {}

class ErrorGetDetailTramoSupercito extends RIState {
  const ErrorGetDetailTramoSupercito({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetDetailTramoSupercito extends RIState {
  final SupercitoSegmentDetail response;

  const SuccessGetDetailTramoSupercito({required this.response});
}

class IsLoadingCierreSupercitos extends RIState {}

class ErrorCierreSupercitos extends RIState {
  const ErrorCierreSupercitos({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessCierreSupercitos extends RIState {
  final FixIssuesResponse response;

  const SuccessCierreSupercitos({required this.response});
}

// Estado para pegar las imágenes
class IsLoadingSendPicturesSupercitos extends RIState {}

class ErrorSendPicturesSupercitos extends RIState {
  const ErrorSendPicturesSupercitos({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessSendPicturesSupercitos extends RIState {
  final SendPictureSupectitosResponse response;

  const SuccessSendPicturesSupercitos({required this.response}) : super();
}





// Estados para obtener detalles de estadísticas
class IsLoadingGetStatsDetails extends RIState {}

class ErrorGetStatsDetails extends RIState {
  const ErrorGetStatsDetails({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetStatsDetails extends RIState {
  final List<SupercitoSegmStatsDetail> response;
  const SuccessGetStatsDetails({required this.response}) : super();
}

// Estados para obtener estadísticas de segmentos
class IsLoadingGetSegmentsStatsSupercitos extends RIState {}

class ErrorGetSegmentsStatsSupercitos extends RIState {
  const ErrorGetSegmentsStatsSupercitos({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetSegmentsStatsSupercitos extends RIState {
  final SupercitoSegmentStatsResponse response;
  const SuccessGetSegmentsStatsSupercitos({required this.response}) : super();
}

// Estados para obtener eventos de supercito
class IsLoadingGetEventsSupercito extends RIState {}

class ErrorGetEventsSupercito extends RIState {
  
  const ErrorGetEventsSupercito({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetEventsSupercito extends RIState {
  final List<SupercitoSegmentEventos> response;
  const SuccessGetEventsSupercito({required this.response}) : super();
}

// ---------------------------------------------------
class IsLoadingGetCategoriesSupercito extends RIState {}

class ErrorGetCategoriesSupercito extends RIState {  
  const ErrorGetCategoriesSupercito({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetCategoriesSupercito extends RIState {
  final List<CategoryResponse> response;
  const SuccessGetCategoriesSupercito({required this.response}) : super();
}

// Búsqueda de parametros
class IsLoadingGetConstants extends RIState {}

class ErrorGetConstants extends RIState {
  const ErrorGetConstants({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetConstants extends RIState {
  final ConstantsEnviroment response;
  const SuccessGetConstants({required this.response}) : super();
}

class IsLoadingGetAvanceAuditoria extends RIState {}

class ErrorGetAvanceAuditoria extends RIState {
  const ErrorGetAvanceAuditoria({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetAvanceAuditoria extends RIState {
  final List<TiendaLResponse> response;
  const SuccessGetAvanceAuditoria({required this.response}) : super();
}

// Estados para Productos mal ubicados
class IsLoadingGetMisplacedProducts extends RIState {}

class ErrorGetMisplacedProducts extends RIState {
  const ErrorGetMisplacedProducts({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetMisplacedProducts extends RIState {
  final MisplacedProductsResponse response;

  const SuccessGetMisplacedProducts({required this.response}) : super();
}

class IsLoadingGetLocations extends RIState {}

class ErrorGetLocations extends RIState {
  const ErrorGetLocations({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetLocations extends RIState {
  final List<UbicacionResponse> response;

  const SuccessGetLocations({required this.response}) : super();
}

// Estados para Etiquetas con Incidencias
class IsLoadingGetLabelWithIncidents extends RIState {}

class ErrorGetLabelWithIncidents extends RIState {
  const ErrorGetLabelWithIncidents({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetLabelWithIncidents extends RIState {
  final IncidenciasEtiquetasResponse response;

  const SuccessGetLabelWithIncidents({required this.response}) : super();
}



// Consultas para vlidar respuestas genericas
class IsLoadingValidations extends RIState {}

class ErrorValidations extends RIState {
  const ErrorValidations({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessValidationsTramos extends RIState {
  final ConsultasResponse response;

  const SuccessValidationsTramos({required this.response}) : super();
}

class SuccessValidationsZeros extends RIState {
  final ValidateCerosResponse response;

  const SuccessValidationsZeros({required this.response}) : super();
}


class SuccessValidationsCategory extends RIState {
  final ConsultasResponse response;

  const SuccessValidationsCategory({required this.response}) : super();
}

class IsLoadingImplementationOfPlanograms extends RIState {}

class ErrorGetImplementationOfPlanograms extends RIState {
  const ErrorGetImplementationOfPlanograms({required String errorMessage})
    : super(messageError: errorMessage);
}

class SuccessGetImplementationOfPlanograms extends RIState {
  final NuevosPlanogramasImplResponse response;
  const SuccessGetImplementationOfPlanograms({required this.response}) : super();
}

class IsLoadingSetPlanogramaImplementado extends RIState {}

class ErrorSetPlanogramaImplementado extends RIState {
  const ErrorSetPlanogramaImplementado({required String errorMessage})
    : super(messageError: errorMessage);
}

class SuccessSetPlanogramaImplementado extends RIState {
  final bool response;
  const SuccessSetPlanogramaImplementado({required this.response}) : super();
}


// Estados para comer
class IsLoadingGetPrductPLN extends RIState {}

class ErrorGetPrductPLN extends RIState {
  const ErrorGetPrductPLN({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetPrductPLN extends RIState {
  final List<PlanogramaItemResponse> response;
  const SuccessGetPrductPLN({required this.response}) : super();
}

class IsLoadingProductosMalAcomodadosSecuencia extends RIState {}

class ErrorProductosMalAcomodadosSecuencia extends RIState {
  const ErrorProductosMalAcomodadosSecuencia({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessProductosMalAcomodadosSecuencia extends RIState {
  final List<ProductoMalAcomodadoSecuencia> response;
  const SuccessProductosMalAcomodadosSecuencia({required this.response}) : super();
}

class IsLoadingProductosSinHuecos extends RIState {}

class ErrorProductosSinHuecos extends RIState {
  const ErrorProductosSinHuecos({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessProductosSinHuecos extends RIState {
  final List<ProductoSinHueco> response;
  const SuccessProductosSinHuecos({required this.response}) : super();
}

class IsLoadingGetAdyacenciaError extends RIState {}

class ErrorGetAdyacenciaError extends RIState {
  const ErrorGetAdyacenciaError({required String errorMessage})
      : super(messageError: errorMessage);
}

class SuccessGetAdyacenciaError extends RIState {
  final List<AdyacenciaErrorResponse> response;
  const SuccessGetAdyacenciaError({required this.response}) : super();
}