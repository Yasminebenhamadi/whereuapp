import 'package:country_currency_pickers/country.dart';
import 'package:country_currency_pickers/currency_picker_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_currency_pickers/country_pickers.dart';
import 'package:whereuapp/authentication/Inscription.dart';
import 'package:whereuapp/authentication/phoneAuth.dart';
import 'package:whereuapp/authentication/send_code.dart';



class Phone extends StatefulWidget {
  @override
  _PhoneState createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
  final formkey = GlobalKey <FormState>();
  String phoneNumber;
  Country country ;
  String _validatePhoneNumber(String value){
    final phoneExp = RegExp(r'^(?:[+0]9)?[0-9]{10}$');
    if (!phoneExp.hasMatch(value)) {
    return ' ENTRER UN NUMERO VALIDE';

    }
    if (value.length == 0 ) {
      return'VEUILLEZ ENTRER UN NUMERO SVP';

    }return null ;  }

  Widget _buildCurrencyDropdownItem(Country country) => Container(
    child: Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(
          width: 8.0,
        ),
        Text("${country.currencyCode}"),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/mer.jpeg"), fit: BoxFit.cover)),
          ),Center(
            child:new Container(
              height: 300.00,
              width: 380.00,
              /*alignment:Alignment.*/
              decoration: BoxDecoration(
                color: Color(0xfff2e9db).withAlpha(100),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(24.00,24.00),
                    color: Color(0xffd9cebf).withAlpha(40),
                    blurRadius: 42,
                  ),
                ], borderRadius: BorderRadius.circular(50.00),
              ),
            ),
          ),
          Container(
            child : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  "C'est quoi votre numéro ?",
                  style: TextStyle(
                    fontFamily: "Segoe UI",fontWeight: FontWeight.w700,
                    fontSize: 23,
                    color:Color(0xffffffff),
                    shadows:[
                      Shadow(
                        offset: Offset(0.00,3.00),
                        color: Color(0xFFE8652D),
                        blurRadius: 6,
                      ),
                    ],
                  ),textAlign:TextAlign.center,
                ),
                SizedBox(
                  height:  25.0,
                ),
                Form(
                  key : formkey,
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center( child:  Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6.0,
                              offset: Offset(0,2 ),
                            ),
                          ],),
                        height: 60.0,
                        width: 340,
                        child:
                        Row(
                          children: <Widget>[
                            SizedBox(width: 30,),
                            Expanded(
                              child: Container(

                                child : CurrencyPickerDropdown(
                                  initialValue: 'DZD',
                                  itemBuilder: _buildCurrencyDropdownItem,
                                  onValuePicked: (Country country) {
                                    this.country = country ;
                                    print("${country.name}");
                                  },
                                ),
                              ),),
                            SizedBox( width:10.0),
                            Expanded(
                              child: TextFormField(keyboardType: TextInputType.phone,
                                style: TextStyle(
                                    color:Color(0xff739D84)  ),
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,),
                                    hintText: "Téléphone",
                                    hintStyle: TextStyle(
                                      color: Color(0xff739D84),
                                      letterSpacing: 1.5,
                                      fontSize: 18.0,
                                    )),
                                validator:_validatePhoneNumber,
                                onSaved: ( String val){phoneNumber = val; },
                                textAlign:TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                      SizedBox(height: 25.0,),
                      Center( child:
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 25.0),

                        width: 250,
                        child: RaisedButton(
                          elevation: 10.0,
                          onPressed: (){
                            if (formkey.currentState.validate()){
                              formkey.currentState.save();
                              String phone;
                              if (country!=null)
                                phone = '+'+country.phoneCode+' '+phoneNumber;
                              else
                                phone = '+213 '+phoneNumber;
                              print(phone);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> PhoneAuth(phoneNumber: phone,)));
                            }
                          },
                          padding: EdgeInsets.all(15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          color: Color(0xFFF1B97A),
                          child: Text(
                            'Continuer',
                            style: TextStyle(
                              color: Color(0xFFE8652D),
                              letterSpacing: 1.5,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ),
                    ],
                  ),

                ),
              ],
            ),

          ),
          Container( padding:EdgeInsets.only(top:670,bottom:20),
            child : SizedBox( child:
            Text( "nous recueillons vos informations auprés de nos partenaires de confiance afin d'améliorer votre expérience client lorsque vous utilisez nos services.", style: TextStyle(
              fontFamily: "Segoe UI",fontWeight: FontWeight.w700,
              fontSize:12,
              color:Color(0xffffffff),),
              textAlign:TextAlign.center,
            ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            width: 250.0,
            child:  FlatButton(
              child:
              Text("Annuler",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color:Color(0xFFF1B97A),
                ),
              ),
              onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Register())) ;},
            ),
          ),
        ],
      ),
    );
  }
}
