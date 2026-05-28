import 'dart:io';

import 'package:ago_app/bloc/ri/bloc.dart';
import 'package:ago_app/models/FurnitureSupercitosResponse.dart';
import 'package:ago_app/models/consultas_response.dart';
import 'package:ago_app/models/location_response.dart';
import 'package:ago_app/models/label_incidents_response.dart';
import 'package:ago_app/models/login_response.dart';
import 'package:ago_app/models/misplaced_products_response.dart';
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
import 'package:ago_app/models/store_response.dart';
import 'package:ago_app/models/deparments_response.dart';
import 'package:ago_app/models/furniture_response.dart';
import 'package:ago_app/models/product_list_response.dart';
import 'package:ago_app/models/tienda_l_response.dart';
import 'package:ago_app/models/tramos_mueble_response.dart';
import 'package:ago_app/models/validate_ceros_response.dart';
import 'package:ago_app/repository/log_repository.dart';
import 'package:ago_app/repository/ri_repository.dart';
import 'package:ago_app/repository/supercitos_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:ago_app/models/adyacencia_error_response.dart';

class RIBloc extends Bloc<RIEvent, RIState> {
  final RIRepository _repository = RIRepository();
  final SupercitosRepository _supercitosRepository = SupercitosRepository();
  final LogRepository _repositoryLog = LogRepository();

  RIBloc() : super(InitialRIState()) {
    on<EventGetCategories>((event, emit) async {
      emit(IsLoadingGetCategory());
      try {
        List<CategoryResponse> response = await _repository.getCategories();
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event} ',
        );

        emit(SuccessGetCategory(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );
        emit(ErrorGetCategory(errorMessage: e.toString()));
      }
    });

    on<EventGetPdfPlanogram>((event, emit) async {
      emit(IsLoadingGetPdfPlanogram());
      try {
        List<Planograma> response = await _repository.getPdfPlanogram(
            event.category, event.store, event.esSupercito);
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params= category=${event.category}, store=${event.store}, esSupercito=${event.esSupercito}',
        );

        emit(SuccessGetPdfPlanogram(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );
        emit(ErrorGetPdfPlanogram(errorMessage: e.toString()));
      }
    });

    on<EventGetCategoryByUPC>((event, emit) async {
      emit(IsLoadingGetCategoriesByUPC());
      try {
        CategoryResponse response =
            await _repository.getAllCategoriesByUPC(event.store, event.upc);
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--  store=${event.store}, upc=${event.upc} -- response=${response.toJson()}',
        );
        emit(SuccessGetCategoriesByUPC(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetCategoriesByUPC(errorMessage: e.toString()));
      }
    });

    on<EventGetStores>((event, emit) async {
      emit(IsLoadingGetStore());
      try {
        List<StoreResponse> response =
            await _repository.getStores(event.categoryId);
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params= categoryId=${event.categoryId}',
        );
        emit(SuccessGetStore(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetStore(errorMessage: e.toString()));
      }
    });

    on<EventGetStoresIndicadores>((event, emit) async {
      emit(IsLoadingGetStore());
      try {
        List<StoreResponse> response = await _repository.getStoresIndicadores();
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}',
        );
        emit(SuccessGetStore(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetStore(errorMessage: e.toString()));
      }
    });

    on<EventGetDeparments>((event, emit) async {
      emit(IsLoadingGetDeparments());
      try {
        List<DeparmentsResponse> response =
            await _repository.getDeptosTienda(event.storeId, event.event);
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params= storeId=${event.storeId}, event=${event.event}',
        );
        emit(SuccessGetDeparments(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetDeparments(errorMessage: e.toString()));
      }
    });

    on<EventGetFurnitures>((event, emit) async {
      emit(IsLoadingGetFurniture());
      try {
        List<FurnitureResponse> response = await _repository.getMueblesTienda(
            event.storeId, event.event, event.categoriaId, event.bitacora);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params= storeId=${event.storeId}, event=${event.event}, categoriaId=${event.categoriaId}, bitacora=${event.bitacora}',
        );
        emit(SuccessGetFurniture(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetFurniture(errorMessage: e.toString()));
      }
    });

    on<EventGetIncidents>((event, emit) async {
      emit(IsLoadingGetSegmentIncidents());
      try {
        List<SegmentIncidentsResponse> response = await _repository
            .getIncidencias(event.idReconocimiento, event.tramo);
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--  params= idReconocimiento=${event.idReconocimiento}, tramo=${event.tramo}',
        );
        emit(SuccessGetSegmentIncidents(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetSegmentIncidents(errorMessage: e.toString()));
      }
    });

    on<EventGetSegments>((event, emit) async {
      emit(IsLoadingGetFurnitureSegment());
      try {
        List<FurnitureSegmentResponse> response = await _repository
            .getSegmentos(event.idRealograma, event.idCategoria);
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params=idRealograma= ${event.idRealograma}, idCategoria=${event.idCategoria} ',
        );
        emit(SuccessGetFurnitureSegment(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetFurnitureSegment(errorMessage: e.toString()));
      }
    });

    on<EventGetProducts>((event, emit) async {
      emit(IsLoadingGetProducts());
      try {
        List<ProductListResponse> response =
            await _repository.getProductos(event.idReconocimiento, event.tramo);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params= idReconocimiento=${event.idReconocimiento}, tramo=${event.tramo}',
        );
        emit(SuccessGetProducts(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetProducts(errorMessage: e.toString()));
      }
    });

    on<EventFixIssue>((event, emit) async {
      emit(IsLoadingFixIssue());

      try {
        FixIssuesResponse response =
            await _repository.getFixIssue(event.incidencias);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--  params: ${event.incidencias} -- response=${response.toJson()}',
        );
        emit(SuccessFixIssue(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorFixIssue(errorMessage: e.toString()));
      }
    });

    on<EventSendPictures>((event, emit) async {
      emit(IsLoadingSendPictures());

      try {
        SendPictureResponse response =
            await _repository.sendPictures(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params: ${event.params.toJson()} -- response=${response.toJson()}',
        );
        emit(SuccessSendPictures(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorSendPictures(errorMessage: e.toString()));
      }
    });

    /* on<EventGetResumePictures>((event, emit) async {
      emit(IsLoadingGetResumePicture());
      try {
        ResumePicturesResponse response =
            await _repository.getResumenProducts(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: ${event.params}-- response=${response.toJson()}',
        );
        emit(SuccessGetResumePicture(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetResumePicture(errorMessage: e.toString()));
      }
    }); */

    on<EventSendPictures2>((event, emit) async {
      emit(IsLoadingSendPictures());

      try {
        SendPictureResponse response =
            await _repository.sendPicturesV2(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: ${event.params.toJson()} --response=${response.toJson().toString()}',
        );

        emit(SuccessSendPictures(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorSendPictures(errorMessage: e.toString()));
      }
    });

    on<EventGetResumePictures>((event, emit) async {
      emit(IsLoadingGetResumePicture());
      try {
        ResumePicturesResponse response =
            await _repository.getResumenProducts(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params=${event.params.toJson()} -- response=${response.toJson().toString()}',
        );
        emit(SuccessGetResumePicture(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetResumePicture(errorMessage: e.toString()));
      }
    });

    on<EventDeleteTramo>((event, emit) async {
      emit(IsLoadingDeleteTramo());
      try {
        String response =
            await _repository.deleteTramo(event.idReconocimiento, event.tramo);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params: idReconocimiento=${event.idReconocimiento}, tramo=${event.tramo} response=${response}',
        );
        emit(SuccessDeleteTramo(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorDeleteTramo(errorMessage: e.toString()));
      }
    });

    on<EventGetResumeTramo>((event, emit) async {
      emit(IsLoadingGetResumeTramo());
      try {
        FurnitureSegmentResponse response = await _repository.getResumeTramo(
            event.idReconocimiento, event.tramo);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: idReconocimiento=${event.idReconocimiento},tramo= ${event.tramo} -- response=${response.toMap()}',
        );
        emit(SuccessGetResumeTramo(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetResumeTramo(errorMessage: e.toString()));
      }
    });

    // Lógica para EventFixSingleIssue
    on<EventFixSingleIssue>((event, emit) async {
      emit(IsLoadingFixSingleIssue());

      try {
        FixResponse response = await _repository.fixSingleIssue(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params=${event.params.toJson()}--response=${response.toJson().toString()}',
        );
        emit(SuccessFixSingleIssue(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorFixSingleIssue(errorMessage: e.toString()));
      }
    });

// Lógica para EventGetIncidenciasV2
    on<EventGetIncidenciasV2>((event, emit) async {
      emit(IsLoadingGetIncidenciasV2());

      try {
        List<IncidentsResponse> response =
            await _repository.getIncidenciasV2(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: ${event.params.toJson()}',
        );
        emit(SuccessGetIncidenciasV2(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetIncidenciasV2(errorMessage: e.toString()));
      }
    });

// Lógica para EventGenerarIndicadores
    on<EventGenerarIndicadores>((event, emit) async {
      emit(IsLoadingGenerarIndicadores());

      try {
        FixIssuesResponse response =
            await _repository.generarIndicadores(event.params);

        print(response.toJson().toString());

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params: ${event.params.toJson()}-- response=${response.toJson().toString()}',
        );
        emit(SuccessGenerarIndicadores(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGenerarIndicadores(errorMessage: e.toString()));
      }
    });

    on<EventCierreTienda>((event, emit) async {
      emit(IsLoadingGenerarIndicadores());

      try {
        FixIssuesResponse response =
            await _repository.cierreTienda(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params: ${event.params.toJson()}--response=${response.toJson().toString()}',
        );
        emit(SuccessCierreTienda(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorCierreTienda(errorMessage: e.toString()));
      }
    });

    on<EventStatusIndicadores>((event, emit) async {
      emit(IsLoadingIndicadores());

      try {
        int response = await _repository.getStatusIndicadores(event.params);
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params: ${event.params.toJson()}--response=${response}',
        );
        emit(SuccessIndicadores(status: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorIndicadores(errorMessage: e.toString()));
      }
    });

    // Para EventReporteEventosTiendas
    on<EventReporteEventosTiendas>((event, emit) async {
      emit(IsLoadingReporteEventosTiendas());

      try {
        List<EventsResponse> response =
            await _repository.getReporteEventosTiendas(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params: ${event.params.toJson()}',
        );
        emit(SuccessReporteEventosTiendas(events: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorReporteEventosTiendas(errorMessage: e.toString()));
      }
    });

// Para EventResumenIndicadores

    on<EventResumenIndicadores>((event, emit) async {
      emit(IsLoadingResumenIndicadores());

      try {
        EventDetail response =
            await _repository.getResumenIndicadores(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params= ${event.params.toJson()}--response=${response.toJson().toString()}',
        );
        emit(SuccessResumenIndicadores(indicadores: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorResumenIndicadores(errorMessage: e.toString()));
      }
    });

// Para EventProductosFaltantes
    on<EventProductosFaltantes>((event, emit) async {
      emit(IsLoadingProductosFaltantes());

      try {
        List<FaltanteResponse> response =
            await _repository.getProductosFaltantes(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params= ${event.params.toJson()}',
        );
        emit(SuccessProductosFaltantes(productosFaltantes: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorProductosFaltantes(errorMessage: e.toString()));
      }
    });

// Para EventProductosFaltantes
    on<EventLayoutProductosFaltantes>((event, emit) async {
      emit(IsLoadingLayoutProductosFaltantes());

      try {
        List<LayoutFaltanteResponse> response =
            await _repository.getLayoutProductosFaltantes(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params=${event.params.toJson()}',
        );
        emit(SuccessLayoutProductosFaltantes(productosFaltantes: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorLayoutProductosFaltantes(errorMessage: e.toString()));
      }
    });

    // Bloc para EventGetMueblesCategoria
    on<EventGetMueblesCategoria>((event, emit) async {
      emit(IsLoadingGetMueblesCategoria());
      try {
        List<MueblesCategoriaResponse> response = await _repository
            .getMueblesCategoria(event.request, event.esSupercito);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: request=${event.request.toJson()}, esSupercito= ${event.esSupercito}',
        );
        emit(SuccessGetMueblesCategoria(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetMueblesCategoria(errorMessage: e.toString()));
      }
    });

// Bloc para EventGetDetalleNivel
    on<EventGetDetalleNivel>((event, emit) async {
      emit(IsLoadingGetDetalleNivel());
      try {
        List<DetalleNivelResponse> response =
            await _repository.getDetalleNivel(event.request, event.esSupercito);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: request=${event.request.toJson()}, esSupercito=${event.esSupercito}',
        );

        emit(SuccessGetDetalleNivel(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetDetalleNivel(errorMessage: e.toString()));
      }
    });

// Bloc para EventGetTramosMueble
    on<EventGetTramosMueble>((event, emit) async {
      emit(IsLoadingGetTramosMueble());
      try {
        List<TramosMuebleResponse> response = await _repository.getTramosMueble(
            event.idReconocimiento, event.idRealograma, event.esSupercito);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: idReconocimiento=${event.idReconocimiento},idRealograma= ${event.idRealograma},esSupercito= ${event.esSupercito}',
        );
        emit(SuccessGetTramosMueble(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetTramosMueble(errorMessage: e.toString()));
      }
    });

    on<EventGetImagenTramo>((event, emit) async {
      emit(IsLoadingGetImagenTramo());
      try {
        DetalleNivelConImagen response =
            await _repository.getDetalleNivelConImagen(
                DetalleNivelParams(
                  idRealograma: event.idRealograma,
                  nivel: event.nivel,
                  tramo: event.tramo,
                  idReconocimiento: event.idReconocimiento,
                ),
                event.esSupercito);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params: idRealograma: ${event.idRealograma},nivel: ${event.nivel},tramo: ${event.tramo}, idReconocimiento: ${event.idReconocimiento}--${response.toJson()}',
        );
        emit(SuccessGetImagenTramo(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetImagenTramo(errorMessage: e.toString()));
      }
    });

    on<EventCapturarFaltante>((event, emit) async {
      emit(IsLoadingCapturarFaltante());

      try {
        CaptureResponse response =
            await _repository.capturarFaltante(event.request);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: ${event.request.toJson()} --${response.toJson().toString()}',
        );
        emit(SuccessCapturarFaltante(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorCapturarFaltante(errorMessage: e.toString()));
      }
    });

    on<EventGetStoresSupercitos>((event, emit) async {
      emit(IsLoadingGetStoresSupercitos());
      try {
        List<StoreResponse> response =
            await _supercitosRepository.getStoresBySupercitos(event.category);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params: category= ${event.category}',
        );
        emit(SuccessGetStoresSupercitos(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetStoresSupercitos(errorMessage: e.toString()));
      }
    });

    on<EventGetPdfPlanogramSupercitos>((event, emit) async {
      emit(IsLoadingGetFurnitureSupercitos());
      try {
        List<FurnitureSupercitosResponse> response = await _supercitosRepository
            .getFurnitureBySupercito(event.store, event.idBitacora);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: store=${event.store}, idBitacora=${event.idBitacora}',
        );
        emit(SuccessGetFurnitureSupercitos(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetFurnitureSupercitos(errorMessage: e.toString()));
      }
    });

    on<EventGetSegmentsSupercitos>((event, emit) async {
      emit(IsLoadingGetSegmentsSupercitos());
      try {
        print(event.piIdRealograma);

        List<SegmentsSupercitos> response = await _supercitosRepository
            .getSegmentsBySupercito(event.piIdRealograma);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: piIdRealograma=${event.piIdRealograma}',
        );

        emit(SuccessGetSegmentsSupercitos(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetSegmentsSupercitos(errorMessage: e.toString()));
      }
    });

    on<EventPdfView>((event, emit) async {
      emit(IsLoadingPdfView());

      try {
        String response =
            await _repository.getPdfByCategory(event.category, event.store);

        String filePath = await downloadFile(response);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--´params: category=${event.category}, store=${event.store} -- response=${response}',
        );

        emit(SuccessPdfView(response: filePath));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorPdfView(errorMessage: e.toString()));
      }
    });

    on<EventDeleteTramoSupercitos>((event, emit) async {
      emit(IsLoadingDeleteTramoSupercitos());
      try {
        final response = await _supercitosRepository.deleteTramoSupercitos(
            event.idRealograma, event.tramo);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: realograma=${event.idRealograma}, tramo=${event.tramo}-- response= ${response.toJson().toString()}',
        );

        emit(SuccessDeleteTramoSupercitos(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        print(e);
        emit(ErrorDeleteTramoSupercitos(errorMessage: e.toString()));
      }
    });

    // Obtener detalle del tramo
    on<EventGetDetailTramoSupercito>((event, emit) async {
      emit(IsLoadingGetDetailTramoSupercito());
      try {
        final response = await _supercitosRepository.getDetailTramoSupercito(
            event.idRealograma, event.tramo);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- idRealograma=${event.idRealograma}, tramo=${event.tramo} --response=${response.toJson().toString()}',
        );

        emit(SuccessGetDetailTramoSupercito(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetDetailTramoSupercito(errorMessage: e.toString()));
      }
    });

    // Cerrar proceso de supercitos
    on<EventCierreSupercitos>((event, emit) async {
      emit(IsLoadingCierreSupercitos());
      try {
        final response =
            await _supercitosRepository.cierreSupercitos(event.idRealograma);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params= idRealograma=${event.idRealograma}, reponse=${response.toJson().toString()}',
        );
        emit(SuccessCierreSupercitos(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorCierreSupercitos(errorMessage: e.toString()));
      }
    });

    on<EventSendPicturesSupercitos>((event, emit) async {
      emit(IsLoadingSendPicturesSupercitos());

      try {
        SendPictureSupectitosResponse response =
            await _supercitosRepository.sendPicturesV1Supercitos(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: ${event.params.toJson()} --${response.toJson().toString()}',
        );
        emit(SuccessSendPicturesSupercitos(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorSendPicturesSupercitos(errorMessage: e.toString()));
      }
    });

    on<EventGetStatsDetails>((event, emit) async {
      emit(IsLoadingGetStatsDetails());

      try {
        final response =
            await _supercitosRepository.getStatsDetails(event.request);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params: ${event.request.toJson()}',
        );

        emit(SuccessGetStatsDetails(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e}',
        );

        emit(ErrorGetStatsDetails(errorMessage: e.toString()));
      }
    });

    on<EventGetSegmentsStatsSupercitos>((event, emit) async {
      emit(IsLoadingGetSegmentsStatsSupercitos());

      try {
        final response = await _supercitosRepository.getSegmentsStatsSupercitos(
          event.tienda,
          event.idEvento,
          event.idBitacora,
        );

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: Tienda= ${event.tienda}, Evento= ${event.idEvento} Bitacora= ${event.idBitacora} --response: ${response.toJson().toString()}',
        );
        emit(SuccessGetSegmentsStatsSupercitos(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetSegmentsStatsSupercitos(errorMessage: e.toString()));
      }
    });

    on<EventGetEventsSupercito>((event, emit) async {
      emit(IsLoadingGetEventsSupercito());

      try {
        final response = await _supercitosRepository.getEventsSupercito(
            event.tienda, event.category);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params: Tienda= ${event.tienda} Categoria= ${event.category}',
        );
        emit(SuccessGetEventsSupercito(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetEventsSupercito(errorMessage: e.toString()));
      }
    });

    on<EventGetCategorieSupercito>((event, emit) async {
      emit(IsLoadingGetCategoriesSupercito());

      try {
        List<CategoryResponse> response =
            await _supercitosRepository.getCategoriesBySupercitos();

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}',
        );

        emit(SuccessGetCategoriesSupercito(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetCategoriesSupercito(errorMessage: e.toString()));
      }
    });

    on<EventGetLocations>((event, emit) async {
      emit(IsLoadingGetLocations());

      try {
        List<UbicacionResponse> response = await _repository.getLocations();

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}',
        );

        emit(SuccessGetLocations(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetLocations(errorMessage: e.toString()));
      }
    });

    on<EventGetConstants>((event, emit) async {
      emit(IsLoadingGetConstants());

      try {
        ConstantsEnviroment response = await _repository.getConstants();

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--${response.toJson().toString()}',
        );

        emit(SuccessGetConstants(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );
        emit(ErrorGetConstants(errorMessage: e.toString()));
      }
    });

    on<EventGetAvanceAuditoria>((event, emit) async {
      emit(IsLoadingGetAvanceAuditoria());

      try {
        List<TiendaLResponse> response =
            await _repository.getAvanceCategoria(event.params);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}--params: ${event.params.toJson()}',
        );

        emit(SuccessGetAvanceAuditoria(response: response));
      } catch (e, stackTrace) {
        // Debug prints to inspect the exact error and request that failed
        try {
          debugPrint('EventGetAvanceAuditoria request params: ${event.params.toJson()}');
        } catch (_) {
          debugPrint('EventGetAvanceAuditoria request params: <unavailable>');
        }
        debugPrint('EventGetAvanceAuditoria error: ${e.toString()}');
        debugPrint(stackTrace.toString());

        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetAvanceAuditoria(errorMessage: e.toString()));
      }
    });

    on<EventGetMisplacedProducts>((event, emit) async {
      emit(IsLoadingGetMisplacedProducts());
      try {
        MisplacedProductsResponse response =
            await _repository.getMisplacedProducts(
          event.idBitacora,
          idTienda: event.idTienda,
          idEvento: event.idEvento,
          categoria: event.categoria,
        );

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- Params: idBitacora: ${event.idBitacora}, idTienda: ${event.idTienda}, idEvento: ${event.idEvento}, categoria: ${event.categoria} --Response: ${response.toJson().toString()}',
        );
        emit(SuccessGetMisplacedProducts(response: response));
      } catch (e, stackTrace) {
        print("====== ERROR CRITICO EN MAPEO ======");
        print(e);
        print(stackTrace);
        print("====================================");
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetMisplacedProducts(errorMessage: e.toString()));
      }
    });

    on<EventGetLabelWithIncidents>((event, emit) async {
      emit(IsLoadingGetLabelWithIncidents());
      try {
        IncidenciasEtiquetasResponse response =
            await _repository.getLabelWithIncidents(event.idBitacora);
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- Params ${event.idBitacora}--Response:${response.toJson().toString()}',
        );
        emit(SuccessGetLabelWithIncidents(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event}--${e.toString()}',
        );

        emit(ErrorGetLabelWithIncidents(errorMessage: e.toString()));
      }
    });

    // VALIDACIONES
    on<EventValidateTramos>((event, emit) async {
      emit(IsLoadingValidations());
      try {
        ConsultasResponse response =
            await _repository.getValidateTramos(event.request);
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: ${event.request.toJson()} --${response.toJson().toString()}',
        );
        emit(SuccessValidationsTramos(response: response));
      } catch (e) {
        _repositoryLog.writeLog('ERROR', '${event}--${e.toString()}');
        emit(ErrorValidations(errorMessage: e.toString()));
      }
    });

    on<EventValidateCategories>((event, emit) async {
      emit(IsLoadingValidations());
      try {
        ConsultasResponse response =
            await _repository.getValidateCategories(event.request);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: ${event.request.toJson()} --${response.toJson().toString()}',
        );

        emit(SuccessValidationsCategory(response: response));
      } catch (e) {
        _repositoryLog.writeLog('ERROR', '${event}--${e.toString()}');
        emit(ErrorValidations(errorMessage: e.toString()));
      }
    });

    on<EventValidateZeros>((event, emit) async {
      emit(IsLoadingValidations());
      try {
        ValidateCerosResponse response =
            await _repository.getValidateCeros(event.request);
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: ${event.request.toJson()} --${response.toJson().toString()}',
        );
        emit(SuccessValidationsZeros(response: response));
      } catch (e) {
        _repositoryLog.writeLog('ERROR', '${event}--${e.toString()}');
        emit(ErrorValidations(errorMessage: e.toString()));
      }
    });

    on<EventGetProductPLN>((event, emit) async {
      emit(IsLoadingGetPrductPLN());
      try {
        List<PlanogramaItemResponse> response =
            await _repository.getProductPLN(event.tienda, event.upc);
        _repositoryLog.writeLog(
          'SUCCESS',
          '${event}-- params: ${event.tienda}/ ${event.upc} -- Too large}',
        );

        print('${event}-- params: ${event.tienda}/ ${event.upc} -- Too large}');

        emit(SuccessGetPrductPLN(response: response));
      } catch (e) {
        _repositoryLog.writeLog('ERROR', '${event}--${e.toString()}');
        emit(ErrorGetPrductPLN(errorMessage: e.toString()));
      }
    });

    on<EventGetImplementationOfPlanograms>((event, emit) async {
      emit(IsLoadingImplementationOfPlanograms());
      try {
        NuevosPlanogramasImplResponse response =
            await _repository.getImplementationOfPlanograms(event.idTienda);
        _repositoryLog.writeLog('SUCCESS', '${event}');
        emit(SuccessGetImplementationOfPlanograms(response: response));
      } catch (e) {
        _repositoryLog.writeLog('ERROR', '${event}--${e.toString()}');
        emit(ErrorGetImplementationOfPlanograms(errorMessage: e.toString()));
      }
    });

    on<EventSetPlanogramaImplementado>((event, emit) async {
      emit(IsLoadingSetPlanogramaImplementado());
      try {
        final response = await _repository.setPlanogramaImplementado(
            event.id, event.idTienda);
        _repositoryLog.writeLog('SUCCESS', '${event}-- response=${response}');
        print('********************* TERMINANDO SER   ${response}');
        emit(SuccessSetPlanogramaImplementado(response: response));
      } catch (e) {
        _repositoryLog.writeLog('ERROR', '${event}--${e.toString()}');
        emit(ErrorSetPlanogramaImplementado(errorMessage: e.toString()));
      }
    });

    on<EventGetProductosMalAcomodadosSecuencia>((event, emit) async {
      emit(IsLoadingProductosMalAcomodadosSecuencia());
      try {
        final response = await _repository
            .getProductosMalAcomodadosSecuencia(event.idBitacora);
        _repositoryLog.writeLog(
            'SUCCESS', '${event}-- idBitacora=${event.idBitacora}');
        emit(SuccessProductosMalAcomodadosSecuencia(response: response));
      } catch (e) {
        _repositoryLog.writeLog('ERROR', '${event}--${e.toString()}');
        emit(ErrorProductosMalAcomodadosSecuencia(errorMessage: e.toString()));
      }
    });

    on<EventGetProductosSinHuecos>((event, emit) async {
      emit(IsLoadingProductosSinHuecos());
      try {
        final response =
            await _repository.getProductosSinHuecos(event.idBitacora);
        _repositoryLog.writeLog(
            'SUCCESS', '${event}-- idBitacora=${event.idBitacora}');
        emit(SuccessProductosSinHuecos(response: response));
      } catch (e) {
        _repositoryLog.writeLog('ERROR', '${event}--${e.toString()}');
        emit(ErrorProductosSinHuecos(errorMessage: e.toString()));
      }
    });

    on<EventGetAdyacenciaError>((event, emit) async {
      emit(IsLoadingGetAdyacenciaError());
      try {
        List<AdyacenciaErrorResponse> response =
            await _repository.getAdyacenciaError(event.idBitacora);

        _repositoryLog.writeLog(
          'SUCCESS',
          '${event} -- params: idBitacora=${event.idBitacora}',
        );
        emit(SuccessGetAdyacenciaError(response: response));
      } catch (e) {
        _repositoryLog.writeLog(
          'ERROR',
          '${event} -- ${e.toString()}',
        );
        emit(ErrorGetAdyacenciaError(errorMessage: e.toString()));
      }
    });
  }

  // Mantener la función `downloadFile` y capturar errores HTTP
  Future<String> downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));

    // Verificar si la respuesta es exitosa (status code 200)
    if (response.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      // Si el servidor responde con un error, lanzar una excepción
      throw Exception('No se pudo encontrar el archivo PDF');
    }
  }
}
