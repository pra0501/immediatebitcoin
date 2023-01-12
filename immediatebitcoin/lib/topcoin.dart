// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:immediatebitcoin/dashboard_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'coinsPage.dart';
import 'localization/app_localization.dart';
import 'models/Bitcoin.dart';
import 'models/TopCoinData.dart';
import 'portfoliopage.dart';
import 'trendsPage.dart';

class TopCoinsPage extends StatefulWidget {
  @override
  _TopCoinsPageState createState() => _TopCoinsPageState();

}

class _TopCoinsPageState extends State<TopCoinsPage> {
  List<Bitcoin> _gainerlosserHTC = [];
  List<TopCoinData> _allDataTC = [];
  List<Bitcoin> gainerLooserCoinList = [];
  bool isLoading = false;
  SharedPreferences? sharedPreferences;
  String? URL;

  @override
  void initState() {
    fetchRemoteValue();
    super.initState();
    _getDataForBitcoin();
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
      URL = remoteConfig.getString('immediate_image').trim();

      print(URL);
      setState(() {

      });
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
    callGainerLooserBitcoinApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:    isLoading?const Center(child:CircularProgressIndicator(color: Color(0xFF4A42F3),),)
            :Container(
            margin: const EdgeInsets.all(15),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
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
                      const SizedBox(
                        width: 90,
                      ),
                      Text(AppLocalizations.of(context).translate('top_coin'),
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height/4,
                      width: MediaQuery.of(context).size.width/.7,
                      child: gainerLooserCoinList.length <= 0
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: gainerLooserCoinList.length,
                          itemBuilder: (BuildContext context, int i) {
                            return InkWell(
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  height:80,
                                  padding: const EdgeInsets.all(10),
                                  child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left:5.0),
                                                  child: FadeInImage(
                                                    width: 50,
                                                    height: 50,
                                                    placeholder: const AssetImage('assets/image/cob.png'),
                                                    image: NetworkImage("$URL/Bitcoin/resources/icons/${gainerLooserCoinList[i].name!.toLowerCase()}.png"),
                                                  ),
                                                ),
                                                Padding(
                                                    padding: const EdgeInsets.only(left:10.0),
                                                    child:Text('${gainerLooserCoinList[i].name}',
                                                      style: const TextStyle(fontSize: 25,fontWeight:FontWeight.bold,color:Colors.black),
                                                      textAlign: TextAlign.left,
                                                    )
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left:65),
                                                  child: Text('\$ ${double.parse(gainerLooserCoinList[i].rate!.toStringAsFixed(2))}',
                                                    style: const TextStyle(fontSize: 20,color:Colors.black),textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ]
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                                crossAxisAlignment:CrossAxisAlignment.end,
                                                mainAxisAlignment:MainAxisAlignment.end,
                                                children:[
                                                  double.parse(gainerLooserCoinList[i].diffRate!) < 0
                                                      ? const Icon(Icons.arrow_downward, color: Colors.red, size: 20,)
                                                      : const Icon(Icons.arrow_upward, color: Colors.green, size: 20,),
                                                  const SizedBox(
                                                    width: 2,
                                                  ),
                                                  Text(double.parse(gainerLooserCoinList[i].diffRate!) < 0
                                                      ? "${double.parse(gainerLooserCoinList[i].diffRate!.replaceAll('-', "")).toStringAsFixed(2)} %"
                                                      : "${double.parse(gainerLooserCoinList[i].diffRate!).toStringAsFixed(2)} %",
                                                      style: TextStyle(fontSize: 18,
                                                          color: double.parse(gainerLooserCoinList[i].diffRate!) < 0
                                                              ? Colors.red
                                                              : Colors.green)
                                                  ),
                                                ]
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            children: <Widget>[
                                              GestureDetector(
                                                child: Container(
                                                  width:MediaQuery.of(context).size.width/2,
                                                  height: 80,
                                                  child: charts.LineChart(
                                                    _createSampleData(gainerLooserCoinList[i].historyRate, double.parse(gainerLooserCoinList[i].diffRate!)),
                                                    layoutConfig: charts.LayoutConfig(
                                                        leftMarginSpec: charts.MarginSpec.fixedPixel(5),
                                                        topMarginSpec: charts.MarginSpec.fixedPixel(10),
                                                        rightMarginSpec: charts.MarginSpec.fixedPixel(5),
                                                        bottomMarginSpec: charts.MarginSpec.fixedPixel(10)),
                                                    defaultRenderer: charts.LineRendererConfig(includeArea: true, stacked: true,roundEndCaps: true),
                                                    animate: true,
                                                    domainAxis: const charts.NumericAxisSpec(showAxisLine: false, renderSpec: charts.NoneRenderSpec()),
                                                    primaryMeasureAxis: const charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(AppLocalizations.of(context).translate('top_gain'), style:GoogleFonts.openSans(textStyle: const TextStyle(fontSize: 19,
                      fontWeight: FontWeight.bold, color: Colors.black))
                  ),
                  Expanded(child:
                  ListView.separated(
                      separatorBuilder: (_, __) =>  const SizedBox(width: 8),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: _gainerlosserHTC.length,
                      itemBuilder: (BuildContext context, int i) {
                        return InkWell(
                            child:
                            double.parse(_gainerlosserHTC[i].diffRate!) >= 0
                                ?
                            Card(
                              margin: const EdgeInsets.only(bottom: 30),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.white70, width: 1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 1.8,
                                //  height: 100,
                                // padding: EdgeInsets.all(8),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      const SizedBox(height: 10,),
                                      ListTile(
                                          leading:GestureDetector(
                                            onTap: (){
                                              savsDataForChart(_gainerlosserHTC[i].name);
                                            },
                                            child:   FadeInImage(
                                              width: 60,
                                              height: 50,
                                              placeholder: const AssetImage(
                                                  'assets/image/cob.png'),
                                              image: NetworkImage(
                                                  "$URL/Bitcoin/resources/icons/${_gainerlosserHTC[i]
                                                      .name?.toLowerCase()}.png"),

                                            ),),
                                          title: Text(
                                            '${_gainerlosserHTC[i].name}',
                                            style:GoogleFonts.openSans(textStyle: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600)
                                            ),)
                                      ),
                                      const SizedBox(height: 15,),

                                      Row(
                                        children: [
                                          const SizedBox(width: 20,),
                                          Text('\$ ${double.parse(
                                              _gainerlosserHTC[i].rate!
                                                  .toStringAsFixed(2))}',
                                            style: GoogleFonts.openSans(textStyle:const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600)
                                            ),),
                                          const SizedBox(width: 30,),
                                          Text('{ ${_gainerlosserHTC[i]
                                              .perRate!}}',
                                            style: GoogleFonts.openSans(textStyle:const TextStyle(
                                                color: Colors.green,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600)
                                            ),),
                                        ],
                                      )
                                    ]
                                ),
                              ),
                            )
                                : const SizedBox()
                        );
                      }),),

                  Text(AppLocalizations.of(context).translate('top_lose'), style:GoogleFonts.openSans(textStyle: const TextStyle(fontSize: 19,
                      fontWeight: FontWeight.bold, color: Colors.black))
                  ),
                  Expanded(child:
                    ListView.separated(
                      separatorBuilder: (_, __) => const SizedBox(height: 5),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: _gainerlosserHTC.length,
                      itemBuilder: (BuildContext context, int i) {
                        return InkWell(
                            child: double.parse(
                                _gainerlosserHTC[i].diffRate!) < 0
                                ?
                            Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Colors.white70, width: 1),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Container(
                                  //  height: 100,
                                  // padding: EdgeInsets.all(8),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        const SizedBox(height: 5,),
                                        ListTile(
                                          leading: GestureDetector(
                                            onTap: (){
                                              savsDataForChart(_gainerlosserHTC[i].name);
                                            },
                                            child:
                                            FadeInImage(
                                              width: 60,
                                              height: 50,
                                              placeholder: const AssetImage(
                                                  'assets/image/cob.png'),
                                              image: NetworkImage(
                                                  "$URL/Bitcoin/resources/icons/${_gainerlosserHTC[i]
                                                      .name?.toLowerCase()}.png"),

                                            ),),
                                          title: Text(
                                            '${_gainerlosserHTC[i].name}',
                                            style: GoogleFonts.openSans(textStyle:const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600)
                                            ),),
                                          subtitle:
                                          Row(
                                            children: [
                                              Row(
                                                  children:[
                                                    Text('\$ ${double.parse(
                                                        _gainerlosserHTC[i].rate!
                                                            .toStringAsFixed(2))}',
                                                      style:GoogleFonts.openSans(textStyle: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w600)
                                                      ),),
                                                    const SizedBox(width: 3,),
                                                    Text('{ ${_gainerlosserHTC[i]
                                                        .perRate!}}',
                                                      style: GoogleFonts.openSans(textStyle:const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w600)
                                                      ),),
                                                  ]),

                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10,),

                                      ]
                                  ),
                                )
                            )
                                : const SizedBox()
                        );
                      }),),

                ])),),


    );
  }

  void _modalBottomMenu() {
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

  List<charts.Series<CartData, int>> _createSampleData(
      historyRate, diffRate) {
    List<CartData> listData = [];
    for (int i = 0; i < historyRate.length; i++) {
      // print("linear sales"+historyRate);
      double rate = historyRate[i]['rate'];
      listData.add(CartData(i, rate));
    }

    return [
      charts.Series<CartData, int>(
        id: 'Tablet',
        // colorFn specifies that the line will be red.
        colorFn: (_, __) => diffRate < 0
            ? charts.MaterialPalette.red.shadeDefault
            : charts.MaterialPalette.green.shadeDefault,
        // areaColorFn specifies that the area skirt will be light red.
        // areaColorFn: (_, __) => charts.MaterialPalette.red.shadeDefault.lighter,
        domainFn: (CartData sales, _) => sales.count,
        measureFn: (CartData sales, _) => sales.rate,
        data: listData,
      ),
    ];
  }


  Future<void> _getDataForBitcoin() async {
    setState(() {
      isLoading = true;
    });
    var uri =
        '$URL/Bitcoin/resources/getBitcoinHistoryLists?size=0';
    var response = await get(Uri.parse(uri));
    print(response.body);
    final data = json.decode(response.body) as Map;
    print(data);
    if (data['error'] == false) {
      setState(() {
        _allDataTC.addAll(data['data']
            .map<TopCoinData>((json) => TopCoinData.fromJson(json))
            .toList());

      });
    } else {
      setState(() {});
    }
    _getForGainerLoserData();
  }

  Future<void> _getForGainerLoserData() async {

    var uri =
        '$URL/Bitcoin/resources/getBitcoinListLoser?size=0';

    print(uri);
    var response = await get(Uri.parse(uri));
    //   print(response.body);
    final data = json.decode(response.body) as Map;
    print(data['data']);
    if (data['error'] == false) {
      setState(() {
        _gainerlosserHTC.addAll(data['data']
            .map<Bitcoin>((json) => Bitcoin.fromJson(json))
            .toList());
        isLoading = false;
      });
    } else {
      //  _ackAlert(context);
      setState(() {});
    }
    callGainerLooserBitcoinApi();
  }

  Future<void> savsDataForChart(String? name) async {
    print('enter'+name!);
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences!.setString("Name", name);
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TrendsPage()),
    );
  }

  Future<void> callGainerLooserBitcoinApi() async {

    var uri =
        '$URL/Bitcoin/resources/getBitcoinListLoser?size=0';

    //  print(uri);
    var response = await get(Uri.parse(uri));
    //   print(response.body);
    final data = json.decode(response.body) as Map;
    //  print(data);
    if (mounted) {
      if (data['error'] == false) {
        setState(() {
          gainerLooserCoinList.addAll(data['data']
              .map<Bitcoin>((json) => Bitcoin.fromJson(json))
              .toList());
          isLoading = false;
          // _size = _size + data['data'].length;
        }
        );
      }

      else {
        //  _ackAlert(context);
        setState(() {});
      }
    }
  }
}


class CartData {
  final int count;
  final double rate;

  CartData(this.count, this.rate);
}