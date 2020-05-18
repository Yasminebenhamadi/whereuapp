import 'package:flutter/material.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/gestures.dart';
import 'package:country_pickers/country.dart';
import '../authentication/phoneAuth.dart' ;

class PhonePage extends StatefulWidget {
  @override
  _PhonePageState createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {

  final formKey = GlobalKey<FormState>();
  String phoneNumber;
  Country country ;

  String confirmedNumber = '';
  String _validatePhoneNumber(String value){
    final phoneExp = RegExp(r'^(?:[+0]9)?[0-9]{10}$');
    if (!phoneExp.hasMatch(value)) { return ' ENTRER UN NUMERO VALIDE';

    }
    if (value.length == 0 ) {
      return'VEUILLEZ ENTRER UN NUMERO SVP';

    }return null ;  }

  Widget _text() {
    return Positioned(
      top: 200,
      child: Container(
        margin: EdgeInsets.all(20),
        height: 250,
        width: MediaQuery.of(context).size.width * 0.90,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0,
                offset: new Offset(10.0, 10.0),
              )
            ]),
        child: Column (
          children: <Widget>[
            SizedBox( height :20.0),
            Text( ' Veuillez utiliser votre numéro de téléphone pour réinitialiser votre mot de passe . ' , style:TextStyle( fontSize:15.0 , fontWeight:FontWeight.bold, color:Color(0xFFF57C00 )  ) ,
                textAlign:TextAlign.center ),
            SizedBox( height:25.0),
            Row( children: <Widget>[




              SizedBox( width : 18.0),
              Form(
                key :  formKey,
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
                            blurRadius: 4.0,
                            offset: Offset(0,2 ),
                          ),
                        ],),
                      height: 60.0,
                      width: 340,
                      child:
                      Row(
                        children: <Widget>[
                          SizedBox(width:20.0),
                          Expanded(
                            child: CountryPickerDropdown(
                              initialValue:('DZ'),
                              itemBuilder: _buildDropdownItem,
                              onValuePicked: (Country country) {
                                this.country = country ;
                              },
                            ),
                          ),
                          SizedBox( width:2.0),
                          Expanded (child :
                          Form(
                            key: formKey,
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
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
                          )),
                        ],
                      ),
                    ),



                    ),
                  ],
                ),






              ),
            ],
            ),

            SizedBox( height : 20.0),

            RaisedButton(
              elevation: 10.0,
              onPressed: (){
                if (formKey.currentState.validate()){
                  formKey.currentState.save();
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

          ],
        ),
      ),
    );
  }

  Widget _buildDropdownItem(Country country) => Container(
    child: Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(
          width: 4.0,
        ),
        Text("+${country.phoneCode}(${country.isoCode})"),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xffF2E9DB),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
            _text(),
          ],
        ),
      ),
    );
  }
}