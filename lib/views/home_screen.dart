import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:purchases/widgets/non_consumable_star.dart';
import 'package:purchases/widgets/subscription.dart';

Set<String> prod_id = {'coins_taken','coins_taken1','flutter_gems'};
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
  List<PurchaseDetails> purchases = <PurchaseDetails>[];
  int credits = 0;
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
          verifyAndDeliverProducts(purchaseDetails);
          print('Deliver Products');
        }else{
          print('show invalid purchase UI and invalid purchases');
        }
        
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
       //products = response.productDetails;
       setState(() {
         products = response.productDetails;;
       });
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
  // checks if a user has purchased a certain product
  dynamic _hasUserPurchased(String productId) {
    if (purchases.isNotEmpty) {
      return purchases.firstWhere(
        (purchase) => purchase.productID == productId,
      );
    }
    return null;
  }
// Method to check if the product has been purchased already or not.
  void verifyAndDeliverProducts(PurchaseDetails purchaseDetails) {
    PurchaseDetails? purchase = _hasUserPurchased(purchaseDetails.productID);

    if (purchase != null &&
        purchase.status == PurchaseStatus.purchased &&
        (purchaseDetails.productID == 'coins_taken' || purchaseDetails.productID == 'coins_taken1' || purchaseDetails.productID == 'flutter_gems')) {
      credits = 10;
      setState(() {});
    } else {
      setState(() {});
    }
  }
// Method to purchase a product
  void _buyProduct(ProductDetails prod) async {
    debugPrint(prod.id);
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    debugPrint(
        'Product details =====> ${purchaseParam.productDetails.rawPrice}');
    switch (prod.id) {
      case 'coins_taken':
            await inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
        break;
      case 'coins_taken1':
        await inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
        break;
        case 'flutter_gems':
        await inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
        break;
    }
    
  }

  _spendCredit(PurchaseDetails hasPurchased) async {
    setState(() {
      credits--;
    });
    if (credits == 1) {
      purchases.removeWhere(
          (element) => element.productID == hasPurchased.productID);
      setState(() {});
    }
  }

  Future<void> restorePurchases() async {
        debugPrint('running restore purchases');

    await inAppPurchase.restorePurchases();
    debugPrint('restored purchases');
    setState(() {});
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              ElevatedButton(
                  onPressed: () async{
                   await restorePurchases();
                  } ,
                  child: const Text('Restore purchases')),
              const SizedBox(
                height: 50,
              ),
            for (var prod in products)
            if (_hasUserPurchased(prod.id) != null) ...[
              if (prod.id == 'coins_taken') ...[
                const Icon(Icons.diamond),
                Text(
                  credits.toString(),
                  style: const TextStyle(fontSize: 60),
                ),
                ElevatedButton(
                  onPressed: () => _spendCredit(_hasUserPurchased(prod.id)),
                  child: const Text('Consumeable Coins'),
                ),
              ] else if (prod.id == 'coins_taken1') ...[
               const Icon(Icons.star),
               ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const NonConsumableStarScreen(),
                                      ));
                                },
                                child: const Text('Coins'),),
              ] 
              else if (prod.id == 'flutter_gems') ...[
               const Icon(Icons.star),
              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SubscriptionScreen(),
                                      ));
                                },
                                child: const Text('Access'))
              ] 
            ] else ...[
              Text(
                prod.title,
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 30),
              ),
              Text(prod.description),
              Text(
                prod.price,
                style: const TextStyle(color: Colors.blue, fontSize: 40),
              ),
              ElevatedButton(
                  onPressed: () => _buyProduct(prod), child: const Text('Buy it',style: TextStyle(fontSize: 35),),),
            ]
            
          ],
        ),
      ),
    );
  }
}
