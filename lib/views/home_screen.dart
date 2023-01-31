import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

Set<String> prod_id = {'coins_taken','coins_taken1'};
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> subscription;
  // keeps a list of products queried from Playstore or app store
  List<ProductDetails> products =[];
  Set<String> subscriptionProductId = prod_id;
  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = inAppPurchase.purchaseStream;
    subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      subscription.cancel();
    },
    onError: (error){

    },
    );
    initStoreInfo();
    super.initState();
  }
  _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print('show pending UI');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        bool valid = await verifyPurchase(purchaseDetails);
        //// to-do implementation of after purchased
        if(valid){
          print('Deliver Products');
        }else{
          print('show invalid purchase UI and invalid purchases');
        }
       // verifyAndDeliverProduct(purchaseDetails);
      }else if(purchaseDetails.status == PurchaseStatus.error){
        print('show error UI & handle errors.');
      //  handleError(purchaseDetails.error);
      }
      if(purchaseDetails.pendingCompletePurchase){
        await inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }
  Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) {
    // Verify the purchase in your backend, and return true if valid
    return Future.value(true);
  }

  Future<void> initStoreInfo() async{
    final bool isAvailable = await inAppPurchase.isAvailable();
    if(isAvailable){
      final ProductDetailsResponse response = await inAppPurchase.queryProductDetails(subscriptionProductId);
      if(response.notFoundIDs.isNotEmpty){
        // Handle the error
      }
       products = response.productDetails;
      for(ProductDetails product in products){
        print('product: ' + product.id);
        print('price: ' + product.price);
        print('product: ' + product.title);
        print('product: ' + product.description);
      }
      // Update UI with products data.
    }else{
      // Show placeholder UI
      print('Unfortunately store is not available');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('In App Purchase'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            for(ProductDetails product in products)...[
              Text(
                product.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(product.description),
              Text(
                product.price,
                style: TextStyle(color: Colors.blueAccent, fontSize: 40),
              ),
            ],
            
          ],
        ),
      ),
    );
  }
}
