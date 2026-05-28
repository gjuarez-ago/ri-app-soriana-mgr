import 'package:ago_app/models/CapturarFaltanteParams.dart';
import 'package:ago_app/models/detalle_nivel_params.dart';
import 'package:ago_app/models/fix_single_issue.dart';
import 'package:ago_app/models/get_issues_params.dart';
import 'package:ago_app/models/layout_faltante_params.dart';
import 'package:ago_app/models/resume_pictures_params.dart';
import 'package:ago_app/models/send_picture_params.dart';
import 'package:ago_app/models/send_picture_params_v2.dart';
import 'package:ago_app/models/send_pictures_supercitos_params.dart';
import 'package:ago_app/models/supercito_segments_stats_detail_request.dart';
import 'package:ago_app/models/tienda_l_request.dart';
import 'package:ago_app/models/validate_categories.dart';
import 'package:ago_app/models/validate_tramos_request.dart';
import 'package:ago_app/models/validateceros.dart';
import 'package:flutter/material.dart';

@immutable
abstract class RIEvent {}

class EventGetCategories extends RIEvent {}

class EventGetStores extends RIEvent {
  final String categoryId;
  EventGetStores({required this.categoryId});
}

class EventGetStoresIndicadores extends RIEvent {}

class EventGetDeparments extends RIEvent {
  final int storeId;
  final int event;

  EventGetDeparments({required this.storeId, required this.event});
}

class EventGetFurnitures extends RIEvent {
  final int storeId;
  final int event;
  final String categoriaId;
  final int bitacora;

  EventGetFurnitures(
      {required this.storeId,
      required this.event,
      required this.categoriaId,
      required this.bitacora});
}

class EventGetIncidents extends RIEvent {
  final int idReconocimiento;
  final int tramo;

  EventGetIncidents({required this.idReconocimiento, required this.tramo});
}

class EventGetSegments extends RIEvent {
  final int idRealograma;
  final String idCategoria;

  EventGetSegments({required this.idRealograma, required this.idCategoria});
}

class EventGetProducts extends RIEvent {
  final int idReconocimiento;
  final int tramo;

  EventGetProducts({required this.idReconocimiento, required this.tramo});
}

class EventFixIssue extends RIEvent {
  final String incidencias;

  EventFixIssue({required this.incidencias});
}

class EventSendPictures extends RIEvent {
  final SendPictureParams params;
  EventSendPictures({required this.params});
}

class EventSendPictures2 extends RIEvent {
  final SendPictureParamsV2 params;
  EventSendPictures2({required this.params});
}

class EventGetResumePictures extends RIEvent {
  final ResumePicturesParams params;
  EventGetResumePictures({required this.params});
}

class EventDeleteTramo extends RIEvent {
  final int idReconocimiento;
  final int tramo;

  EventDeleteTramo({required this.idReconocimiento, required this.tramo});
}

class EventGetResumeTramo extends RIEvent {
  final int idReconocimiento;
  final int tramo;

  EventGetResumeTramo({required this.idReconocimiento, required this.tramo});
}

// Evento para fixSingleIssue
class EventFixSingleIssue extends RIEvent {
  final FixSingleIssueParams params;

  EventFixSingleIssue({required this.params});
}

// Evento para getIncidenciasV2
class EventGetIncidenciasV2 extends RIEvent {
  final GetIssuesParams params;

  EventGetIncidenciasV2({required this.params});
}

// Evento para generarIndicadores
class EventGenerarIndicadores extends RIEvent {
  final GetIssuesParams params;

  EventGenerarIndicadores({required this.params});
}

// Evento para generarIndicadores
class EventCierreTienda extends RIEvent {
  final GetIssuesParams params;

  EventCierreTienda({required this.params});
}

class EventStatusIndicadores extends RIEvent {
  final GetIssuesParams params;

  EventStatusIndicadores({required this.params});
}

class EventReporteEventosTiendas extends RIEvent {
  final GetIssuesParams params;

  EventReporteEventosTiendas({required this.params});
}

class EventResumenIndicadores extends RIEvent {
  final GetIssuesParams params;

  EventResumenIndicadores({required this.params});
}

class EventProductosFaltantes extends RIEvent {
  final GetIssuesParams params;

  EventProductosFaltantes({required this.params});
}

// Evento para obtener MueblesCategoria
class EventGetMueblesCategoria extends RIEvent {
  final GetIssuesParams request;
  final bool esSupercito;

  EventGetMueblesCategoria({required this.request, required this.esSupercito});
}

// Evento para obtener DetalleNivel
class EventGetDetalleNivel extends RIEvent {
  final DetalleNivelParams request;
  final bool esSupercito;

  EventGetDetalleNivel({required this.request, required this.esSupercito});
}

// Evento para obtener TramosMueble
class EventGetTramosMueble extends RIEvent {
  final int idReconocimiento;
  final int idRealograma;
  final bool esSupercito;

  EventGetTramosMueble(
      {required this.idReconocimiento,
      required this.idRealograma,
      required this.esSupercito});
}

class EventGetImagenTramo extends RIEvent {
  final int idReconocimiento;
  final int idRealograma;
  final int tramo;
  final int nivel;
  final bool esSupercito;

  EventGetImagenTramo(
      {required this.idReconocimiento,
      required this.idRealograma,
      required this.tramo,
      required this.nivel,
      required this.esSupercito});
}

class EventCapturarFaltante extends RIEvent {
  final CapturarFaltanteParams request;

  EventCapturarFaltante({required this.request});
}

class EventPdfView extends RIEvent {
  final String category;
  final int store;

  EventPdfView({required this.store, required this.category});
}

class EventLayoutProductosFaltantes extends RIEvent {
  final LayoutFaltantesParams params;
  EventLayoutProductosFaltantes({required this.params});
}

class EventGetCategoryByUPC extends RIEvent {
  final int store;
  final String upc;

  EventGetCategoryByUPC({required this.store, required this.upc});
}

class EventGetPdfPlanogram extends RIEvent {
  final String store;
  final String category;
  final bool esSupercito;

  EventGetPdfPlanogram(
      {required this.store, required this.category, required this.esSupercito});
}

class EventGetStoresSupercitos extends RIEvent {
  final String category;

  EventGetStoresSupercitos({required this.category});
}

class EventGetPdfPlanogramSupercitos extends RIEvent {
  final int store;
  final int idBitacora;

  EventGetPdfPlanogramSupercitos(
      {required this.store, required this.idBitacora});
}

class EventGetSegmentsSupercitos extends RIEvent {
  final int piIdRealograma;

  EventGetSegmentsSupercitos({required this.piIdRealograma});
}

class EventDeleteTramoSupercitos extends RIEvent {
  final int idRealograma;
  final int tramo;

  EventDeleteTramoSupercitos({
    required this.idRealograma,
    required this.tramo,
  });
}

class EventGetDetailTramoSupercito extends RIEvent {
  final int idRealograma;
  final int tramo;

  EventGetDetailTramoSupercito({
    required this.idRealograma,
    required this.tramo,
  });
}

class EventCierreSupercitos extends RIEvent {
  final int idRealograma;

  EventCierreSupercitos({
    required this.idRealograma,
  });
}



// Evento para obtener detalles de estadísticas
class EventGetStatsDetails extends RIEvent {
  final SupercitoSegmentStatsDetailRequest request;
  EventGetStatsDetails({required this.request});
}

// Evento para obtener estadísticas de segmentos
class EventGetSegmentsStatsSupercitos extends RIEvent {
  final int tienda;
  final int idEvento;
  final int idBitacora;

  EventGetSegmentsStatsSupercitos({
    required this.tienda,
    required this.idEvento,
    required this.idBitacora,
  });
}

// Evento para obtener eventos de supercito
class EventGetEventsSupercito extends RIEvent {
  final int tienda;
  final String category;
  EventGetEventsSupercito({required this.tienda, required this.category});
}

class EventSendPicturesSupercitos extends RIEvent {
  final SendPicturesSupercitosParams params;
  EventSendPicturesSupercitos({required this.params});
}

class EventGetCategorieSupercito extends RIEvent {}

class EventGetConstants extends RIEvent {}

class EventGetAvanceAuditoria extends RIEvent {
  final TiendaLRequest params;
  EventGetAvanceAuditoria({required this.params});
}

class EventGetMisplacedProducts extends RIEvent {
  final int idBitacora;
  final int idTienda;
  final int idEvento;
  final String categoria;

  EventGetMisplacedProducts({
    required this.idBitacora,
    required this.idTienda,
    required this.idEvento,
    required this.categoria,
  });
}


class EventGetLocations extends RIEvent {
  EventGetLocations();
}

class EventGetLabelWithIncidents extends RIEvent {
  final int idBitacora;
  EventGetLabelWithIncidents({required this.idBitacora});
}

// Eventos par las validacioenes

class EventValidateCategories extends RIEvent {
  final ValidateCategories request;
  EventValidateCategories({required this.request});
}

class EventValidateZeros extends RIEvent {
  final ValidateCeros request;
  EventValidateZeros({required this.request});
}

class EventValidateTramos extends RIEvent {
  final ValidaTramosRequest request;
  EventValidateTramos({required this.request});
}

class EventGetProductPLN extends RIEvent {
  final int tienda;
  final String upc;
  EventGetProductPLN({required this.tienda, required this.upc});
}

class EventGetImplementationOfPlanograms extends RIEvent {
  final int idTienda;

  EventGetImplementationOfPlanograms({
    required this.idTienda
  });
}

class EventSetPlanogramaImplementado extends RIEvent {
  final int id;
  final int idTienda;
  EventSetPlanogramaImplementado({
    required this.id,
    required this.idTienda
  });
}

class EventGetProductosMalAcomodadosSecuencia extends RIEvent {
  final int idBitacora;

  EventGetProductosMalAcomodadosSecuencia({required this.idBitacora});
}

class EventGetProductosSinHuecos extends RIEvent {
  final int idBitacora;

  EventGetProductosSinHuecos({required this.idBitacora});
}

class EventGetAdyacenciaError extends RIEvent {
  final int idBitacora;

  EventGetAdyacenciaError({required this.idBitacora});
}
