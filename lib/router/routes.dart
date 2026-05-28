import 'package:ago_app/pages/business/business_page.dart';
import 'package:ago_app/pages/home/home_page.dart';
import 'package:ago_app/pages/labels_with_incidents/labels_with_incidents_page.dart';
import 'package:ago_app/pages/layout_missing_products/layout_missing_products_page.dart';
import 'package:ago_app/pages/login/login_page.dart';
import 'package:ago_app/pages/misplaced_products/misplaced_products_page.dart';
import 'package:ago_app/pages/missing_products/missing_products_page.dart';
import 'package:ago_app/pages/search/search_page.dart';
import 'package:ago_app/pages/search_business/search_business_page.dart';
import 'package:ago_app/pages/search_planogram/search_planogram_page.dart';
import 'package:ago_app/pages/splash/splash_page.dart';
import 'package:ago_app/pages/supercito_stats/supercito_stats_page.dart';
import 'package:ago_app/pages/supercitos_search/search_supercitos_page.dart';
import 'package:ago_app/pages/supercitos_search/widgets/supercito_capture_page.dart';
import 'package:ago_app/pages/take_picture/take_picture_page.dart';
import 'package:ago_app/pages/total_product/total_product_page.dart';
import 'package:ago_app/pages/view_furniture/view_furniture_page.dart';
import 'package:ago_app/pages/view_products/view_products_page.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    HomePage.routeName: (BuildContext context) => const HomePage(),
    SearchPage.routeName: (BuildContext context) => const SearchPage(),
    SplashPage.routeName: (BuildContext context) => const SplashPage(),
    LoginPage.routeName: (BuildContext context) => const LoginPage(),
    TakePicturePage.routeName: (BuildContext context) =>
        const TakePicturePage(),
    ViewFurniturePage.routeName: (BuildContext context) =>
        const ViewFurniturePage(),
    ViewProductsPage.routeName: (context) => const ViewProductsPage(),
    BusinessPage.routeName: (BuildContext context) => const BusinessPage(),
    SearchBusinessPage.routeName: (BuildContext context) =>
        const BusinessPage(),
    MissingProductsPage.routeName: (BuildContext context) =>
        const MissingProductsPage(),
    TotalProductPage.routeName: (BuildContext context) =>
        const TotalProductPage(),
    LayoutMissingProductsPage.routeName: (BuildContext context) =>
        const LayoutMissingProductsPage(),
    SearchPlanogramPage.routeName: (BuildContext context) =>
        const SearchPlanogramPage(),
    SearchSupercitosPage.routeName: (BuildContext context) =>
        const SearchSupercitosPage(),
    SupercitoCapturePage.routeName: (BuildContext context) =>
        const SupercitoCapturePage(),
    SupercitoStatsPage.routeName: (BuildContext context) =>
        const SupercitoStatsPage(),
    MisplacedProductsPage.routeName: (BuildContext context) =>
        const MisplacedProductsPage(),
    LabelsWithIncidentsPage.routeName: (BuildContext context) =>
        const LabelsWithIncidentsPage(),
  };
}
