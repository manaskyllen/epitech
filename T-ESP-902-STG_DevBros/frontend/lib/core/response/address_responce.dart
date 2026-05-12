  import 'package:inspiria/core/model/address_model.dart';

class AddressResponces {

  AddressResponces({required this.statusCode, this.address, this.errorMessage});

  final List<AddressModel>? address;
  final int statusCode;
  final String? errorMessage;
}

class AddressResponce {

  AddressResponce({required this.statusCode, this.address, this.errorMessage});
  
  final AddressModel? address;
  final int statusCode;
  final String? errorMessage;
  
}