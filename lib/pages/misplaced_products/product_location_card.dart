import 'package:cached_network_image/cached_network_image.dart';
import 'package:ago_app/models/misplaced_products_response.dart';
import 'package:ago_app/pages/misplaced_product_detail/misplaced_product_detail_page.dart';
import 'package:flutter/material.dart';

class ProductLocationCard extends StatelessWidget {
  final MisplacedProduct product;

  const ProductLocationCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return SizedBox(
      width: size.width,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MisplacedProductDetailPage(product: product),
            )
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Card(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xffEBEBEAFF),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(5),
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CachedNetworkImage(
                              imageUrl: product.imagen!,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2,),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                                size: 30,
                              ),
                              fit: BoxFit.contain,
                            ),        
                          )
                        ),
                      ),
          
                      Expanded(
                        flex: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.nombreProducto ?? 'Nombre no disponible',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'UPC: ${product.upc ?? 'Sin descripción'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis, // 👈 opcional, evita desbordes
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_right, // 👈 el ícono que quieras
                                    color: Color(0xff636ae8),
                                    size: 22,
                                  ),
                                ],
                              ),
          
                              const SizedBox(height: 4),

                              Text(
                                'SKU: ${product.sku ?? 'Sin información'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
          
                              Visibility(
                                visible: false,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Texto izquierdo
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Frentes: ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${product.frentesRealograma}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Color(0xffe8618c),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 20), 
                                          
                                    // Texto derecho (otro RichText con mismo estilo)
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Esperados: ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${product.frentesPlanograma}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Color(0xffe8618c),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
          
                              
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ),
        )
      ),
    );
  }
}