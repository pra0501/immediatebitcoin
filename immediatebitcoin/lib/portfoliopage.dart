import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coinsPage.dart';
import 'dashboard_home.dart';
import 'localization/app_localization.dart';
import 'models/Bitcoin.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'models/PortfolioBitcoin.dart';
import 'dashboard_helper.dart';
import 'topcoin.dart';
import 'trendsPage.dart';
import 'localization/AppLanguage.dart';
import 'models/LanguageData.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  List<Bitcoin> bitcoinList = [];
  List<Bitcoin> gainerLooserCoinList = [];
  SharedPreferences? sharedPreferences;
  Future<SharedPreferences> _sprefs = SharedPreferences.getInstance();
  num _size = 0;
  int buttonType = 3;
  double totalValuesOfPortfolio = 0.0;
  final _formKey = GlobalKey<FormState>();
  String? URL;
  String result = '';
  String image='';
  String name = '';
  String _lable = "Coins";
  double coin = 0;
  double diffRate = 0;
  var currencyName = "BTC";
  List<LinearSales> currencyData = [];
  var scaffoldKey = GlobalKey<ScaffoldState>();

  final PageStorageBucket bucket = PageStorageBucket();
  String? languageCodeSaved;

  TextEditingController? coinCountTextEditingController;
  TextEditingController? coinCountEditTextEditingController;
  final dbHelper = DatabaseHelper.instance;
  List<PortfolioBitcoin> items = [];

  List<LanguageData> languages = [
    LanguageData(languageCode: "en", languageName: "English"),
    LanguageData(languageCode: "it", languageName: "Italian"),
    LanguageData(languageCode: "de", languageName: "German"),
    LanguageData(languageCode: "sv", languageName: "Swedish"),
    LanguageData(languageCode: "fr", languageName: "French"),
    LanguageData(languageCode: "nb", languageName: "Norwegian"),
    LanguageData(languageCode: "es", languageName: "Spanish"),
    LanguageData(languageCode: "nl", languageName: "Dutch"),
    LanguageData(languageCode: "fi", languageName: "Finnish"),
    LanguageData(languageCode: "ru", languageName: "Russian"),
    LanguageData(languageCode: "pt", languageName: "Portuguese"),
    LanguageData(languageCode: "ar", languageName: "Arabic"),
  ];

  @override
  void initState() {
    fetchRemoteValue();
    coinCountTextEditingController = TextEditingController();
    coinCountEditTextEditingController = TextEditingController();
    dbHelper.queryAllRows().then((notes) {
      notes.forEach((note) {
        items.add(PortfolioBitcoin.fromMap(note));
        totalValuesOfPortfolio = totalValuesOfPortfolio + note["total_value"];
      });
      setState(() {});
    });
    super.initState();

  }

  Future<void> getSharedPrefData() async {
    final SharedPreferences prefs = await _sprefs;
    setState(() {
      _lable = prefs.getString("title") ?? AppLocalizations.of(context).translate('portfolio');
      languageCodeSaved = prefs.getString('language_code') ?? "en";
      _saveLangData();
    });
  }

  _saveLangData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences!.setInt("index", 0);
      sharedPreferences!.setString("title", AppLocalizations.of(context).translate('portfolio'));
      // sharedPreferences.commit();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  fetchRemoteValue() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {


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
    callBitcoinApi();
  }

  @override
  Widget build(BuildContext context) {
    var appLanguage = Provider.of<AppLanguage>(context);
    return Scaffold(
      body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xffd76614)
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                          child: const Icon(Icons.menu_rounded,color: Colors.white,)
                      ),
                    ),
                    const Spacer(),
                    Text(AppLocalizations.of(context).translate('portfolio'),
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.start,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.translate_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Center(child: Text(AppLocalizations.of(context).translate('select_language'))),
                                content: Container(
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: languages.length,
                                        itemBuilder: (BuildContext context, int i) {
                                          return Container(
                                            child: Column(
                                              children: <Widget>[
                                                InkWell(
                                                    onTap: () async {
                                                      appLanguage.changeLanguage(Locale(
                                                          languages[i].languageCode!));
                                                      await getSharedPrefData();
                                                      Navigator.pop(context);
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text(languages[i].languageName!),
                                                        languageCodeSaved ==
                                                            languages[i].languageCode
                                                            ? const Icon(
                                                          Icons
                                                              .radio_button_checked,
                                                          color: Colors.deepOrange,
                                                        )
                                                            : const Icon(
                                                          Icons
                                                              .radio_button_unchecked,
                                                          color: Colors.deepOrange,
                                                        ),
                                                      ],
                                                    )),
                                                const Divider()
                                              ],
                                            ),
                                          );
                                        })),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(AppLocalizations.of(context).translate('cancel')),
                                  )
                                ],
                              );
                            });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '\$${totalValuesOfPortfolio.toStringAsFixed(2)}',textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(AppLocalizations.of(context).translate('portfolio_value'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
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
                                height:160,
                                decoration: BoxDecoration(color: const Color(0xffc1580b),borderRadius: BorderRadius.circular(20)),
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
                                                    style: const TextStyle(fontSize: 25,fontWeight:FontWeight.bold,color:Color(0xffa0bef8)),
                                                    textAlign: TextAlign.left,
                                                  )
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left:65),
                                                child: Text('\$ ${double.parse(gainerLooserCoinList[i].rate!.toStringAsFixed(2))}',
                                                  style: const TextStyle(fontSize: 20,color:Colors.white),textAlign: TextAlign.left,
                                                ),
                                              ),
                                            ]
                                        ),
                                      ],
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
                Expanded(
                  child: Container(
                  decoration: const BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40),)
                  ),
                  child: Expanded(
                    child: items.length > 0 && bitcoinList.length > 0
                        ? ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Dismissible(
                            child: Card(
                              elevation: 1,
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.white),
                                height: MediaQuery.of(context).size.height/11,
                                width: MediaQuery.of(context).size.width/.5,
                                child:GestureDetector(
                                    onTap: () {
                                      showPortfolioEditDialog(items[i]);
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Container(
                                              height: 40,
                                              width:40,
                                              child: FadeInImage(
                                                placeholder: const AssetImage('assets/image/cob.png'),
                                                image: NetworkImage("$URL/Bitcoin/resources/icons/${items[i].name.toLowerCase()}.png"),
                                              ),
                                            )
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.all(1),
                                            child:Container(
                                                child:Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text('${items[i].name}',
                                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black), textAlign: TextAlign.left,
                                                    ),
                                                    Text('\$ ${items[i].rateDuringAdding.toStringAsFixed(2)}',
                                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),

                                                  ],
                                                )
                                            )
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(0),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: Text(' ${items[i].numberOfCoins.toStringAsFixed(0)}',
                                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                                                  textAlign: TextAlign.end,),
                                              ),
                                              Text('\$${items[i].totalValue.toStringAsFixed(2)}',
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                                                textAlign: TextAlign.end,),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width:10),
                                        const SizedBox(
                                          width: 2,
                                        )
                                      ],
                                    )
                                ),
                              ),
                            ),
                            background : Container(
                              color: Colors.red,
                              child: InkWell(
                                  onTap: () {
                                    _showdeleteCoinFromPortfolioDialog(items[i]);
                                  }, // Image tapped
                                  child: const Icon(Icons.delete,color: Colors.white,size:20)
                              ),
                            ),
                            key: UniqueKey(),
                            onDismissed: (direction){
                              setState(() {
                                _showdeleteCoinFromPortfolioDialog(items[i]);
                              });
                            },
                          );
                        })
                        :Center(
                      child: ElevatedButton(
                        onPressed:(){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CoinsPage()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(AppLocalizations.of(context).translate('add_coins')),
                        ),
                        style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white,),
                            backgroundColor: MaterialStateProperty.all<Color>(const Color(0xffd76614),),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35.0),
                                )
                            )
                        ),
                      ),
                      // Text("No Coins Added", style: TextStyle(color: Colors.white))
                    ),
                  ),
                ),
                )
              ],
            ),
          )
      ),
    );
  }

  List<charts.Series<LinearSales, int>> _createSampleData(
      historyRate, diffRate) {
    List<LinearSales> listData = [];
    for (int i = 0; i < historyRate.length; i++) {
      double rate = historyRate[i]['rate'];
      listData.add(LinearSales(i, rate));
    }

    return [
      charts.Series<LinearSales, int>(
        id: 'Tablet',
        // colorFn specifies that the line will be red.
        colorFn: (_, __) => diffRate < 0
            ? charts.MaterialPalette.red.shadeDefault
            : charts.MaterialPalette.green.shadeDefault,
        // areaColorFn specifies that the area skirt will be light red.
        // areaColorFn: (_, __) => charts.MaterialPalette.red.shadeDefault.lighter,
        domainFn: (LinearSales sales, _) => sales.count,
        measureFn: (LinearSales sales, _) => sales.rate,
        data: listData,
      ),
    ];
  }

  Future<void> callBitcoinApi() async {
    var uri = '$URL/Bitcoin/resources/getBitcoinList?size=${_size}';

    //  print(uri);
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
      callGainerLooserBitcoinApi();
    }
    else {
      //  _ackAlert(context);
      setState(() {});
    }

  }

  Future<void> showPortfolioEditDialog(PortfolioBitcoin bitcoin) async {
    coinCountEditTextEditingController!.text = bitcoin.numberOfCoins.toInt().toString();
    showModalBottomSheet(
        context: context,
        builder: (ctxt) => Container(
          height: MediaQuery.of(context).size.height,
          child: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                color: Color(0xffc1580b),borderRadius: BorderRadius.vertical(top: Radius.circular(40))
              ),
              child: ListView(
                  children: [
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(AppLocalizations.of(context).translate('update_coins'),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(30),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                  children:<Widget>[
                                    Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: FadeInImage(
                                              height: 40,
                                              placeholder: const AssetImage('assets/image/cob.png'),
                                              image: NetworkImage(
                                                  "$URL/Bitcoin/resources/icons/${bitcoin.name.toLowerCase()}.png"),
                                            ),
                                          ),
                                        ]
                                    ),
                                    const SizedBox(
                                      width: 50,
                                    ),
                                    Text(bitcoin.name,
                                      style: const TextStyle(fontSize: 25, color: Colors.black),),
                                  ]
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:15),
                            child: Text(AppLocalizations.of(context).translate('enter_coins'),textAlign: TextAlign.left,
                                style: const TextStyle(fontSize: 15, color: Color(0xffdca076), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 50.0),
                            child: Container(
                              decoration: BoxDecoration(color: const Color(0xffc1580b),
                                  border: Border.all(color: Colors.white, width: 2)
                              ),
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: coinCountEditTextEditingController,
                                  style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center,
                                  cursorColor: Colors.white,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ], // O
                                  //only numbers can be entered
                                  validator: (val) {
                                    if (coinCountEditTextEditingController!.value.text == "" ||
                                        int.parse(coinCountEditTextEditingController!.value.text) <= 0) {
                                      return AppLocalizations.of(context).translate('invalid_coins');
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: InkWell(
                                onTap:(){
                                  _updateSaveCoinsToLocalStorage(bitcoin);
                                } ,// Image tapped
                                child: Container(
                                  decoration: BoxDecoration(color: const Color(0xffc1580b),border: Border.all(color: Colors.white,width: 2)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text(AppLocalizations.of(context).translate('add_coins'),textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),]
              ),
            ),
          ),
        )
    );
  }

  getCurrentRateDiff(PortfolioBitcoin items, List<Bitcoin> bitcoinList) {
    Bitcoin j = bitcoinList.firstWhere((element) => element.name == items.name);

    double newRateDiff = j.rate! - items.rateDuringAdding;
    return newRateDiff;
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

    Navigator.pushNamedAndRemoveUntil(context, 'driftPage', (r) => false);
  }

  _updateSaveCoinsToLocalStorage(PortfolioBitcoin bitcoin) async {
    if (_formKey.currentState!.validate()) {
      int adf = int.parse(coinCountEditTextEditingController!.text);
      print(adf);
      Map<String, dynamic> row = {
        DatabaseHelper.columnName: bitcoin.name,
        DatabaseHelper.columnRateDuringAdding: bitcoin.rateDuringAdding,
        DatabaseHelper.columnCoinsQuantity:
        double.parse(coinCountEditTextEditingController!.value.text),
        DatabaseHelper.columnTotalValue: (adf) * (bitcoin.rateDuringAdding),
      };
      final id = await dbHelper.update(row);
      print('inserted row id: $id');
      sharedPreferences = await SharedPreferences.getInstance();
      setState(() {
        sharedPreferences!.setString("currencyName", bitcoin.name);
        sharedPreferences!.setString("title", AppLocalizations.of(context).translate('portfolio'));
        sharedPreferences!.commit();
      });
      Navigator.pushNamedAndRemoveUntil(context, '/homePage', (r) => false);
    } else {}
  }

  void _showdeleteCoinFromPortfolioDialog(PortfolioBitcoin item) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40))
      ),
        context: context,
        builder: (ctxt) => Container(
          height: MediaQuery.of(context).size.height,
          child: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                  color: Color(0xffc1580b),borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
              child: ListView(
                  children: [
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(AppLocalizations.of(context).translate('remove_coins'),
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(AppLocalizations.of(context).translate('do_you'),
                              style: const TextStyle(color: Colors.white,fontSize: 18),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(30),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                  children:<Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: FadeInImage(
                                                height: 70,
                                                placeholder: const AssetImage('assets/image/cob.png'),
                                                image: NetworkImage(
                                                    "$URL/Bitcoin/resources/icons/${item.name.toLowerCase()}.png"),
                                              ),
                                            ),
                                            const SizedBox(
                                              height:10,
                                            ),
                                          ]
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 50,
                                    ),
                                    Column(
                                      children: [
                                        Text(item.name,
                                          style: const TextStyle(fontSize: 25, color: Colors.black),),
                                        const SizedBox(
                                          height:10,
                                        ),
                                      ],
                                    ),
                                  ]
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: InkWell(
                                onTap:(){
                                  _deleteCoinsToLocalStorage(item);
                                } ,// Image tapped
                                child: Container(
                                  decoration: BoxDecoration(color: const Color(0xffc1580b),border: Border.all(color: Colors.white,width: 2)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text(AppLocalizations.of(context).translate('remove'),textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 50,),
                        ],
                      ),
                    ),
                  ]
              ),
            ),
          ),
        )
    );
  }

  _deleteCoinsToLocalStorage(PortfolioBitcoin item) async {
    // int adf = int.parse(coinCountEditTextEditingController.text);
    // print(adf);

    final id = await dbHelper.delete(item.name);
    print('inserted row id: $id');
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences!.setString("title", AppLocalizations.of(context).translate('portfolio'));
      sharedPreferences!.commit();
    });
    Navigator.pushNamedAndRemoveUntil(context, '/homePage', (r) => false);
  }
}
class LinearSales {
  final int count;
  final double rate;

  LinearSales(this.count, this.rate);
}
