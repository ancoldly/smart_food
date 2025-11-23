class PaymentModel {
  final int id;

  final String bankName;      
  final String bankLogo;      

  final String accountNumber; 
  final String accountHolder; 
  final String idNumber;      

  final bool isDefault;  

  PaymentModel({
    required this.id,
    required this.bankName,
    required this.bankLogo,
    required this.accountNumber,
    required this.accountHolder,
    required this.idNumber,
    required this.isDefault,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json["id"],
      bankName: json["bank_name"] ?? "",
      bankLogo: json["bank_logo"] ?? "",

      accountNumber: json["account_number"] ?? "",
      accountHolder: json["account_holder"] ?? "",
      idNumber: json["id_number"] ?? "",

      isDefault: json["is_default"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "bank_name": bankName,
      "bank_logo": bankLogo,
      "account_number": accountNumber,
      "account_holder": accountHolder,
      "id_number": idNumber,
      "is_default": isDefault,
    };
  }
}
