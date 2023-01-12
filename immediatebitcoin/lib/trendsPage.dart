import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'coinsPage.dart';
import 'dashboard_home.dart';
import 'localization/app_localization.dart';
import 'models/Bitcoin.dart';
import 'portfoliopage.dart';
import 'topcoin.dart';

class TrendsPage extends StatefulWidget {
  @override
  _TrendsPageState createState() => _TrendsPageState();

}

class _TrendsPageState extends State<TrendsPage> {
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();
  List<Bitcoin> bitcoinDataList = [];
  double diffRate = 0;
  List<CartData> currencyData = [];
  String name = "";
  double coin = 0;
  String result = '';
  int graphButton = 1;
  String _type = 'Week';
  String? URL;
  bool isLoading = false;

  @override
  void initState() {
    fetchRemoteValue();
    super.initState();
    callGraphApi();
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
    callGraphApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(100, 50),
        child:
        AppBar(
            centerTitle: true,
            shadowColor: Colors.white,
            elevation: 0.0,
            backgroundColor: const Color(0xFFFFFFFF),
            leading: Padding(
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
            title:
            Text(AppLocalizations.of(context).translate('trends'), style: GoogleFonts.openSans(textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold),)
            )),
      ),
      body: SafeArea(
        child: isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A42F3),),)
            : Column(
          children: [
            const SizedBox(height: 5,),
            Card(
                color: Colors.white70,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[

                              Text('\$ ${coin} ${name} ',
                                style:GoogleFonts.openSans(textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.5,
                                    fontWeight: FontWeight.w600
                                ),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(diffRate < 0 ? '-' : "+", style: TextStyle(fontSize: 16, color: diffRate < 0 ? Colors.red : Colors.green)),
                                  Icon(Icons.attach_money, size: 16, color: diffRate < 0 ? Colors.red : Colors.green),
                                  Text('$result', style: TextStyle(fontSize: 16, color: diffRate < 0 ? Colors.red : Colors.green)),
                                ],
                              ),
                            ]
                        ),
                        FadeInImage(
                          width: 40,
                          height: 50,
                          placeholder: const AssetImage(
                              'assets/image/cob.png'),
                          image: NetworkImage(
                              "http://45.34.15.25:8080/Bitcoin/resources/icons/${name.toLowerCase()}.png"),

                        ),]),

                )
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                ButtonTheme(
                  minWidth: 50.0, height: 40.0,
                  child: ElevatedButton(
                    child: new Text("Week" , style: TextStyle(fontSize: 15)
                    ),
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(graphButton == 1 ? Colors.white:Color(0xff50af95)),
                        backgroundColor: MaterialStateProperty.all<Color>(graphButton == 1 ? Color(0xff50af95) : Colors.white,),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              // side: BorderSide(color: Color(0xfff4f727))
                            )
                        )
                    ),
                    // textColor: buttonType == 3 ? Color(0xff96a5ff) : Colors.white,
                    // shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),),
                    // color: buttonType == 3 ? Colors.white : Color(0xff96a5ff),
                    onPressed: () {
                      setState(() {
                        graphButton = 1;
                        _type = "Week";
                        callGraphApi();
                      });
                    },
                  ),
                ),
                ButtonTheme(
                  minWidth: 50.0, height: 40.0,
                  child: ElevatedButton(
                    child: new Text("Month" , style: TextStyle(fontSize: 15)
                    ),
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(graphButton == 2 ? Colors.white:Color(0xff50af95)),
                        backgroundColor: MaterialStateProperty.all<Color>(graphButton == 2 ? Color(0xff50af95) : Colors.white,),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              // side: BorderSide(color: Color(0xfff4f727))
                            )
                        )
                    ),
                    // textColor: buttonType == 3 ? Color(0xff96a5ff) : Colors.white,
                    // shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),),
                    // color: buttonType == 3 ? Colors.white : Color(0xff96a5ff),
                    onPressed: () {
                      setState(() {
                        graphButton = 2;
                        _type = "Month";
                        callGraphApi();
                      });
                    },
                  ),
                ),
                ButtonTheme(
                  minWidth: 50.0, height: 40.0,
                  child: ElevatedButton(
                    child: new Text("Year" , style: TextStyle(fontSize: 15)
                    ),
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(graphButton == 3 ? Colors.white:Color(0xff50af95)),
                        backgroundColor: MaterialStateProperty.all<Color>(graphButton == 3 ? Color(0xff50af95) : Colors.white,),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              // side: BorderSide(color: Color(0xfff4f727))
                            )
                        )
                    ),
                    // textColor: buttonType == 3 ? Color(0xff96a5ff) : Colors.white,
                    // shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),),
                    // color: buttonType == 3 ? Colors.white : Color(0xff96a5ff),
                    onPressed: () {
                      setState(() {
                        graphButton = 3;
                        _type = "Year";
                        callGraphApi();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child:Container(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(),
                            child:  Row(children: <Widget>[

                              Container(
                                  width: MediaQuery.of(context).size.width ,
                                  height: MediaQuery.of(context).size.height / 1.51,
                                  //   height :MediaQuery.of(context).size.height,
                                  //     width: MediaQuery.of(context).size.width,
                                  child: SfCartesianChart(
                                    isTransposed: false,
                                    plotAreaBorderWidth: 0,
                                    enableAxisAnimation: true,
                                    enableSideBySideSeriesPlacement: true,
                                    //  plotAreaBackgroundColor:Colors.blue.shade100 ,
                                    series: <ChartSeries>[
                                      // Renders spline chart
                                      SplineSeries<CartData,
                                          double>(
                                        dataSource: currencyData,
                                        xValueMapper: (CartData data, _) => data.date,
                                        yValueMapper: (CartData data, _) => data.rate,
                                        color: const Color(0xFF4A42F3),
                                        splineType: SplineType.clamped,
                                        //cardinalSplineTension: 10,
                                        dataLabelSettings: const DataLabelSettings(
                                          // Renders the data label
                                          isVisible: true,
                                          useSeriesColor: true,
                                          labelAlignment: ChartDataLabelAlignment.bottom,
                                          showCumulativeValues: true,

                                        ),
                                        markerSettings: const MarkerSettings(
                                          isVisible: true,
                                          height: 20,
                                          width: 20,

                                        ),
                                      ),
                                    ],
                                    primaryXAxis: NumericAxis(

                                      isVisible: false,
                                      borderColor: Colors.blue,

                                    ),
                                    primaryYAxis: NumericAxis(
                                        isVisible: false,
                                        borderColor: Colors.blue
                                      // edgeLabelPlacement: EdgeLabelPlacement.shift,
                                    ),
                                  )
                              )
                            ],),
                          ),

                        ],
                      ),
                    ),

            ),
          ],
        ),
      ),
    );
  }


  Future<void> callGraphApi() async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences prefs = await _sprefs;
    var currName = prefs.getString("Name") ?? 'BTC';
    name = currName;
    var uri = '$URL/Bitcoin/resources/getBitcoinGraph?type=${_type}&name=${name}';

    print(uri);
    var response = await get(Uri.parse(uri));
    //  print(response.body);
    final data = json.decode(response.body) as Map;
    //print(data);
    if(data['error'] == false){
      setState(() {
        bitcoinDataList = data['data'].map<Bitcoin>((json) =>
            Bitcoin.fromJson(json)).toList();
        double count = 0;
        diffRate = double.parse(data['diffRate']);
        if(diffRate < 0)
          result = data['diffRate'].replaceAll("-", "");
        else
          result = data['diffRate'];

        currencyData = [];
        bitcoinDataList.forEach((element) {
          currencyData.add(CartData(count, element.rate!));
          name = element.name!;
//         coin = element.rate;
          String step2 = element.rate!.toStringAsFixed(2);

          print(step2);
          double step3 = double.parse(step2);
          coin = step3;
          count = count+1;
        });
        //  print(currencyData.length);
        isLoading = false;
      });

    }
    else {
      //  _ackAlert(context);

    }

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
class CartData {
  final double date;
  final double rate;

  CartData(this.date, this.rate);
}