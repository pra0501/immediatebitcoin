class TopCoinData {
  String? diffRate;
  double? rate;
  int? bitcoinId;
  String? name;

  TopCoinData({this.diffRate, this.rate, this.bitcoinId, this.name});

  TopCoinData.fromJson(Map<String, dynamic> json) {
    diffRate = json['diffRate'];
    rate = json['rate'];
    bitcoinId = json['bitcoinId'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['diffRate'] = this.diffRate;
    data['rate'] = this.rate;
    data['bitcoinId'] = this.bitcoinId;
    data['name'] = this.name;
    return data;
  }
}