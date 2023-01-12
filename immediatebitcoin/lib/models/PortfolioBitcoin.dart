class PortfolioBitcoin {
  int? _id;
  String? _name;
  double? _rate;
  double? _rateDuringAdding;
  double? _numberOfCoins;
  double? _totalValue;


  PortfolioBitcoin(this._id, this._name, this._rate, this._rateDuringAdding,
      this._numberOfCoins, this._totalValue);

  int get id => _id!;

  String get name => _name!;

  double get rate => _rate!;

  double get rateDuringAdding => _rateDuringAdding!;

  double get numberOfCoins => _numberOfCoins!;

  double get totalValue => _totalValue!;

  PortfolioBitcoin.map(dynamic obj) {
    this._id = obj['id'];
    this._name=obj['name'] ;
    this._rate =  obj['rate'];
    this._rateDuringAdding= obj['rate_during_adding'] ;
    this._numberOfCoins = obj['coins_quantity'];
    this._totalValue= obj['total_value'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['name'] = _name;
    map['rate'] = _rate;
    map['rate_during_adding'] = _rateDuringAdding;
    map['coins_quantity'] = _numberOfCoins;
    map['total_value'] = _numberOfCoins;

    return map;
  }

  PortfolioBitcoin.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name=map['name'] ;
    this._rate =  map['rate'];
    this._rateDuringAdding= map['rate_during_adding'] ;
    this._numberOfCoins = map['coins_quantity'] ;
    this._totalValue= map['total_value'];
  }
// All dogs start out at 10, because they're good dogs.




}
