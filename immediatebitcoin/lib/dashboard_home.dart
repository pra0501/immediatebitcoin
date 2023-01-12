import 'dart:async';
import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'coinsPage.dart';
import 'localization/app_localization.dart';
import 'models/Bitcoin.dart';
import 'portfoliopage.dart';
import 'topcoin.dart';
import 'trendsPage.dart';


class DashboardHome extends StatefulWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  _DashboardHome createState() => _DashboardHome();
}

class _DashboardHome extends State<DashboardHome> {
  ScrollController? _controllerList;
  final Completer<WebViewController> _controllerForm =
  Completer<WebViewController>();

  bool isLoading = false;

  SharedPreferences? sharedPreferences;
  num _size = 0;
  String? iFrameUrl;
  List<Bitcoin> bitcoinList = [];
  bool? displayiframeEvo;
  String? URL;


  @override
  void initState() {
    _controllerList = ScrollController();
    super.initState();
    fetchRemoteValue();
  }

  fetchRemoteValue() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      // await remoteConfig.setConfigSettings(RemoteConfigSettings(
      //   fetchTimeout: const Duration(seconds: 10),
      //   minimumFetchInterval: Duration.zero,
      // ));
      // await remoteConfig.fetchAndActivate();

      await remoteConfig.fetch(expiration: const Duration(seconds: 30));
      await remoteConfig.activateFetched();
      iFrameUrl = remoteConfig.getString('immediate_form').trim();
      URL = remoteConfig.getString('immediate_image').trim();
      displayiframeEvo = remoteConfig.getBool('bool_immediate');

      print(iFrameUrl);
      setState(() {

      });
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
    callBitcoinApi();

  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:ListView(
        controller:_controllerList,
        children: <Widget>[
          Container(
            //decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/image/Design 27.png"),fit: BoxFit.fill)),
            //height: 1100,
            //child:Image.asset("assets/image/Design 27.png",fit: BoxFit.fitHeight,width:double.infinity),
            child: Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: const BoxDecoration(color: Color(0xfffcf2ea)),
                          child: Column(
                            children: <Widget>[
                              const SizedBox(
                                height: 40,
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _modalBottomMenu();
                                          });
                                        }, // Image tapped
                                        child: const Icon(Icons.menu_rounded,color: Colors.black,)
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(15),
                                child: Image.asset("assets/image/logo_hor.png"),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(AppLocalizations.of(context).translate('homesen1'),
                                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(AppLocalizations.of(context).translate('homesen2'),
                                    style: TextStyle(color: Color(0xff757575),fontWeight: FontWeight.bold,fontSize: 25),),
                                ),
                              ),
                              if(displayiframeEvo == true)
                                Container(
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  height: 520,
                                  child: WebView(
                                    initialUrl: iFrameUrl,
                                    gestureRecognizers: Set()
                                      ..add(Factory<VerticalDragGestureRecognizer>(
                                              () => VerticalDragGestureRecognizer())),
                                    javascriptMode: JavascriptMode.unrestricted,
                                    onWebViewCreated:
                                        (WebViewController webViewController) {
                                      _controllerForm.complete(webViewController);
                                    },
                                    // TODO(iskakaushik): Remove this when collection literals makes it to stable.
                                    // ignore: prefer_collection_literals
                                    javascriptChannels: <JavascriptChannel>[
                                      _toasterJavascriptChannel(context),
                                    ].toSet(),

                                    onPageStarted: (String url) {
                                      print('Page started loading: $url');
                                    },
                                    onPageFinished: (String url) {
                                      print('Page finished loading: $url');
                                    },
                                    gestureNavigationEnabled: true,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(color:Color(0xffDD650D)),
                          child: Column(
                            children:  <Widget>[
                              SizedBox(
                                height: 30,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(AppLocalizations.of(context).translate('homesen3'),style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold,color: Color(0xffFFFFFF)),),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(AppLocalizations.of(context).translate('homesen4'),style: TextStyle(fontSize: 30 ,color: Color(0xffFFFFFF)),),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(AppLocalizations.of(context).translate('homesen5'),style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold,color: Color(0xffFFFFFF)),),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(AppLocalizations.of(context).translate('homesen6'),style: TextStyle(fontSize: 30 ,color: Color(0xffFFFFFF)),),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(AppLocalizations.of(context).translate('homesen7'),style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold,color: Color(0xffFFFFFF)),),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(AppLocalizations.of(context).translate('homesen8'),style: TextStyle(fontSize: 30 ,color: Color(0xffFFFFFF)),),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(color: Color(0xfffcf2ea)),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen9'),textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen10'),textAlign: TextAlign.left,
                                  style: TextStyle(color: Color(0xff757575),fontWeight: FontWeight.bold,fontSize: 20),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen11'),textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen12'),textAlign: TextAlign.left,
                                  style: TextStyle(color: Color(0xff757575),fontWeight: FontWeight.bold,fontSize: 20),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                child:Column(
                                    children: <Widget>[
                                      Container(
                                          height: MediaQuery.of(context).size.height/4,
                                          width: MediaQuery.of(context).size.width/.7,
                                          child: bitcoinList.length <= 0
                                              ? const Center(child: CircularProgressIndicator())
                                              : ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: bitcoinList.length,
                                              itemBuilder: (BuildContext context, int i) {
                                                return InkWell(
                                                  child: Card(
                                                    elevation: 1,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(25),
                                                    ),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(10),
                                                      child:Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Row(
                                                              children: [
                                                                Container(
                                                                    child: Padding(
                                                                      padding:
                                                                      const EdgeInsets.only(left:5.0),
                                                                      child: FadeInImage(
                                                                        width: 70,
                                                                        height: 70,
                                                                        placeholder: const AssetImage('assets/image/cob.png'),
                                                                        image: NetworkImage("$URL/Bitcoin/resources/icons/${bitcoinList[i].name!.toLowerCase()}.png"),
                                                                      ),
                                                                    )
                                                                ),
                                                                const SizedBox(
                                                                  width: 40,
                                                                ),
                                                                Padding(
                                                                    padding:
                                                                    const EdgeInsets.only(left:10.0),
                                                                    child:Text('${bitcoinList[i].name}',
                                                                      style: const TextStyle(fontSize: 20,fontWeight:FontWeight.bold,color:Colors.black),
                                                                      textAlign: TextAlign.left,
                                                                    )
                                                                ),
                                                              ]
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text('\$${double.parse(bitcoinList[i].rate!.toStringAsFixed(2))}',
                                                                  style: const TextStyle(fontSize: 20,fontWeight:FontWeight.bold,color:Colors.black)
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                              margin: const EdgeInsets.only(left:200),
                                                              //height: 50,
                                                              decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(10)
                                                              ),
                                                              child:Row(
                                                                  crossAxisAlignment:CrossAxisAlignment.center,
                                                                  mainAxisAlignment:MainAxisAlignment.end,
                                                                  children:[
                                                                    double.parse(bitcoinList[i].diffRate!) < 0
                                                                        ? Container(child: const Icon(Icons.arrow_drop_down_sharp, color: Colors.red, size: 18,),)
                                                                        : Container(child: const Icon(Icons.arrow_drop_up_sharp, color: Colors.green, size: 18,),),
                                                                    const SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    Text(double.parse(bitcoinList[i].diffRate!) < 0
                                                                        ? "\$ " + double.parse(bitcoinList[i].diffRate!.replaceAll('-', "")).toStringAsFixed(2)
                                                                        : "\$ " + double.parse(bitcoinList[i].diffRate!).toStringAsFixed(2),
                                                                        style: TextStyle(fontSize: 18,
                                                                            color: double.parse(bitcoinList[i].diffRate!) < 0
                                                                                ? Colors.red
                                                                                : Colors.green)
                                                                    ),
                                                                    const SizedBox(
                                                                        height: 5,
                                                                        width:15
                                                                    ),
                                                                  ]
                                                              )
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    callCurrencyDetails(bitcoinList[i].name);
                                                  },
                                                );
                                              })
                                      ),
                                    ]
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen13'),textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen14'),textAlign: TextAlign.left,
                                  style: TextStyle(color: Color(0xff757575),fontWeight: FontWeight.bold,fontSize: 20),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right:8.0,top:15),
                                        child: Image.asset('assets/image/Frame 35.png'),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left:10.0,right: 10.0, bottom:5.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(AppLocalizations.of(context).translate('homesen15'),
                                                  style:TextStyle(fontWeight: FontWeight.bold,fontSize:20,
                                                      color:Colors.black,height:1.6)
                                              ),
                                              Text(AppLocalizations.of(context).translate('homesen16'),
                                                style:TextStyle(fontSize:15,
                                                    color:Color(0xff757575),height:1.6),softWrap: true,
                                              ),
                                            ],
                                          ),

                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right:8.0,top:15),
                                        child: Image.asset('assets/image/Frame 36.png'),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left:10.0,right: 10.0, bottom:5.0),
                                          child: Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(AppLocalizations.of(context).translate('homesen17'),
                                                    style:TextStyle(fontWeight: FontWeight.bold,fontSize:20,
                                                        color:Colors.black,height:1.6)),
                                                Text(AppLocalizations.of(context).translate('homesen18'),
                                                    style:TextStyle(fontSize:15,color:Color(0xff757575),height:1.6)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right:8.0,top:15),
                                        child: Image.asset('assets/image/Frame 37.png'),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left:10.0,right: 10.0, bottom:5.0),
                                          child: Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(AppLocalizations.of(context).translate('homesen19'),
                                                    style:TextStyle(fontWeight: FontWeight.bold,fontSize:20,
                                                        color:Colors.black,height:1.6)),
                                                Text(AppLocalizations.of(context).translate('homesen20'),
                                                    style:TextStyle(fontSize:15,color:Color(0xff757575),height:1.6)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Image.asset("assets/image/iPhone 13.png"),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen21'),textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen22'),textAlign: TextAlign.left,
                                  style: TextStyle(color: Color(0xff757575),fontWeight: FontWeight.bold,fontSize: 20),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Image.asset("assets/image/dist_crypto.png"),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen23'),textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen24'),textAlign: TextAlign.left,
                                  style: TextStyle(color: Color(0xff757575),fontWeight: FontWeight.bold,fontSize: 20),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Image.asset("assets/image/close_hand.png"),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen25'),textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen26'),textAlign: TextAlign.left,
                                  style: TextStyle(color: Color(0xff757575),fontWeight: FontWeight.bold,fontSize: 20),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Image.asset("assets/image/gold_bitcoin.png"),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen27'),textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(AppLocalizations.of(context).translate('homesen28'),textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xff757575),fontWeight: FontWeight.bold,fontSize: 20),),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(color: Color(0xffDD650D)),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(AppLocalizations.of(context).translate('homesen29'),
                                    style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(AppLocalizations.of(context).translate('homesen30'),
                                    style: TextStyle(color: Colors.white,fontSize: 20),),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Image.asset("assets/image/crypto_design.png"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            ),
          ),
        ],
      ),
    );
  }

  Future<void> callBitcoinApi() async {
    var uri = '$URL/Bitcoin/resources/getBitcoinList?size=0';
    var response = await get(Uri.parse(uri));
    //   print(response.body);
    final data = json.decode(response.body) as Map;
    //  print(data);
    if (data['error'] == false) {
      setState(() {
        bitcoinList.addAll(data['data']
            .map<Bitcoin>((json) => Bitcoin.fromJson(json))
            .toList());
        isLoading = false;
        _size = _size + data['data'].length;
      });
    } else {
      //  _ackAlert(context);
      setState(() {});
    }
  }


  Future<void> callCurrencyDetails(name) async {
    _saveProfileData(name);
  }


  _saveProfileData(String name) async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences!.setString("currencyName", name);
      sharedPreferences!.setString("title", AppLocalizations.of(context).translate('trends'));
      sharedPreferences!.commit();
    });

    Navigator.pushNamedAndRemoveUntil(context, '/driftPage', (r) => false);
  }


  _modalBottomMenu() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(40),
          ),
        ), builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, setState) =>
              SingleChildScrollView(
                child:Container(
                  decoration: const BoxDecoration(image: DecorationImage(
                    image: AssetImage("assets/image/Group 33770.png",),
                    fit: BoxFit.fill,
                  ),),
                  height: MediaQuery.of(context).size.height/1.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  <Widget> [
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Column(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => DashboardHome()),
                                );
                              },
                              child: Row(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(15),
                                      child:
                                      Image.asset("assets/image/Group 33764.png",height: 60,width: 60,)),
                                  Text(AppLocalizations.of(context).translate('home'),textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 25),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => TopCoinsPage()),
                                );
                              },
                              child: Row(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(15),
                                      child:
                                      Image.asset("assets/image/Group 33765.png",height: 60,width: 60,)),
                                  Text(AppLocalizations.of(context).translate('top_coin'),textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 25),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CoinsPage()),
                                );
                              },
                              child: Row(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(15),
                                      child:
                                      Image.asset("assets/image/Group 33766.png",height: 60,width: 60,)),
                                  Text(AppLocalizations.of(context).translate('coins'),textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 25),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => TrendsPage()),
                                );
                              },
                              child: Row(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(15),
                                      child:
                                      Image.asset("assets/image/Group 33767.png",height: 60,width: 60,)),
                                  Text(AppLocalizations.of(context).translate('trends'),textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 25),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PortfolioPage()),
                                );
                              },
                              child: Row(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(15),
                                      child:
                                      Image.asset("assets/image/Group 33768.png",height: 60,width: 60,)),
                                  Text(AppLocalizations.of(context).translate('portfolio'),textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 25),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
      );});
  }
}

