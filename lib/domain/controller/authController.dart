import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import '../../presentation/pages/navPage.dart';
import '../../presentation/pages/registrationPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/pages/loginPage.dart';
import '../services/restApi.dart';

class AuthController extends GetxController {
  final RestApi _restAPI = RestApi();
  late SharedPreferences _prefs;
  bool isLoggedIn = false;
  String token = '';

  // Textediting controller
  TextEditingController? emailController;
  TextEditingController? passwordController;
  TextEditingController? nameController;
  TextEditingController? ageController;
  TextEditingController? genderController;
  TextEditingController? heightController;
  TextEditingController? weightController;
  TextEditingController? bloodGroupController;

  // State
  RxBool isRequesting = false.obs;

  AuthController() {
    checkLogin();
  }

  // Login check
  Future<void> checkLogin() async {
    _prefs = await SharedPreferences.getInstance();

    if (_prefs.containsKey("token")) {
      // Fetch token from sharedpreferences
      String storedToken = _prefs.getString('token') ?? '';
      // Check if token is valid
      if (storedToken.isNotEmpty) {
        isLoggedIn = true;
        token = storedToken;
      }
    }

    if (isLoggedIn) {
      _restAPI.setApiKey(token);
      Get.offAll(NavPage());
    } else {
      emailController = TextEditingController();
      passwordController = TextEditingController();
      Get.offAll(LoginPage());
    }
  }

  // Login function
  Future<void> login() async {
    // Check variables
    if (emailController!.text.isEmpty || passwordController!.text.isEmpty) {
      Get.snackbar("Error", "Please fill all the fields",
          backgroundColor: Colors.red.shade400);
      return;
    }
    // Requesting
    isRequesting.value = true;
    // Login
    var response = await _restAPI.post("/auth/login", {},
        {"email": emailController!.text, "password": passwordController!.text});
    // If successful, set token and move to homepage , also dispose editingcontrollers
    if(response.success){
      Get.snackbar("Hurray ! 🎉🎉", "You have been logged in");
      _restAPI.setApiKey(response.payload["token"]);
      await _prefs.setString("token", response.payload["token"]);
      await _prefs.setString("name", response.payload["name"]);
      await Get.offAll(NavPage());
      emailController!.dispose();
      passwordController!.dispose();
    }
    // If unsuccessful, so error messages
    else{
       Get.snackbar("Failed to login 😢", "Check credentials !");
    }
    isRequesting.value = false;
  }

  // Go to registration page
  Future<void> goToRegistrationPage()async{
    passwordController!.text = "";

    nameController = TextEditingController();
    ageController = TextEditingController();
    genderController = TextEditingController();
    heightController = TextEditingController();
    weightController = TextEditingController();
    bloodGroupController = TextEditingController();

    Get.to(const RegistrationPage());
  }

  // Submit info for registration
  Future<void> submitRegistration()async{
    // Check all fields is filled
    if(nameController!.text.isEmpty || ageController!.text.isEmpty || genderController!.text.isEmpty || heightController!.text.isEmpty || weightController!.text.isEmpty){
      Get.snackbar("Error", "Please fill all the fields",
          backgroundColor: Colors.red.shade400);
      return;
    }
    String gender  = "";
    // check gender field is valid
    if(genderController!.text.toLowerCase() == "male" || genderController!.text.toLowerCase() == "m") gender = "m";
    if(genderController!.text.toLowerCase() == "female" || genderController!.text.toLowerCase() == "f") gender = "f";

    if(gender != "m" && gender != "f"){
        Get.snackbar("Gender error", "Only male and female is allowed",backgroundColor: Colors.red.shade400);
        genderController!.text = "";
        return;
    }

    String bloodGroup = "";
    // check blood group field is valid
    if(bloodGroupController!.text.toLowerCase() == "a+" || bloodGroupController!.text.toLowerCase() == "a positive") bloodGroup = "APos";
    if(bloodGroupController!.text.toLowerCase() == "a-" || bloodGroupController!.text.toLowerCase() == "a negative") bloodGroup = "ANeg";
    if(bloodGroupController!.text.toLowerCase() == "b+" || bloodGroupController!.text.toLowerCase() == "b positive") bloodGroup = "BPos";
    if(bloodGroupController!.text.toLowerCase() == "b-" || bloodGroupController!.text.toLowerCase() == "b negative") bloodGroup = "BNeg";
    if(bloodGroupController!.text.toLowerCase() == "o+" || bloodGroupController!.text.toLowerCase() == "o positive") bloodGroup = "OPos";
    if(bloodGroupController!.text.toLowerCase() == "o-" || bloodGroupController!.text.toLowerCase() == "o negative") bloodGroup = "ONeg";
    if(bloodGroupController!.text.toLowerCase() == "ab+" || bloodGroupController!.text.toLowerCase() == "ab positive") bloodGroup = "ABPos";
    if(bloodGroupController!.text.toLowerCase() == "ab-" || bloodGroupController!.text.toLowerCase() == "ab negative") bloodGroup = "ABNeg";

    if(bloodGroup.isEmpty){
      Get.snackbar("Blood group error", "Only A+, A-, B+, B-, O+, O-, AB+, AB- is allowed",backgroundColor: Colors.red.shade400);
      bloodGroupController!.text = "";
      return;
    }

    // Requesting
    isRequesting.value = true;

    // Register
    var response = await _restAPI.post("/auth/register", {}, {
      "name" : nameController!.text,
      "email" : emailController!.text,
      "password" : passwordController!.text,
      "age" : int.parse(ageController!.text),
      "gender" : gender,
      "weight" : double.parse(weightController!.text),
      "height" : double.parse(heightController!.text),
      "bloodGroup" : bloodGroup
    });

    if(response.success){
      Get.snackbar("Hurray ! 🎉🎉", response.message);
      _restAPI.setApiKey(response.payload["token"]);
      await _prefs.setString("token", response.payload["token"]);
      await _prefs.setString("name", response.payload["name"]);
      await Get.offAll(NavPage());
      emailController!.dispose();
      passwordController!.dispose();
      nameController!.dispose();
      ageController!.dispose();
      genderController!.dispose();
      heightController!.dispose();
      weightController!.dispose();
      bloodGroupController!.dispose();
    }
    else{
      Get.snackbar("Failed to register 😢", response.message);
    }

    isRequesting.value = false;
  }
}
