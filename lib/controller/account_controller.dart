import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nss/api.dart';
import 'package:nss/database/local_storage.dart';
import 'package:nss/model/volunteer_model.dart';
import 'package:nss/view/home_screen.dart';

class AccountController extends GetxController {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  TextEditingController admissionNoController = TextEditingController();
  String email = '';
  final api = Api();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  onInit() {
    if (kDebugMode) {
      userNameController.text = 'sec@fc';
      passwordController.text = '0000';
    }

    super.onInit();
  }

  Future<void> login() async {
    isLoading.value = true;
    errorMessage.value = '';

    final userName = userNameController.text;
    final password = passwordController.text;

    if (userName.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill all fields!';
      Get.snackbar('Error', 'Please fill all fields!');
      return;
    }

    api.login({'admission_number': userName, 'password': password}).then(
      (response) async {
        if (response?.status == true && response?.data.admissionNo != null) {
          await LocalStorage().writeUser(response?.data ?? Users());
          Get.snackbar('Welcome', '${response?.data.name}');
          Get.offAll(() => HomeScreen());
        } else {
          errorMessage.value =
              response?.message ?? 'Invalid username or password!';
          Get.snackbar('Error', errorMessage.value);
        }
        isLoading.value = false;
      },
    );
  }

  Future<void> changePassword(String id) async {
    isLoading.value = true;
    if ((newPassController.text.trim().isEmpty)) {
      Get.snackbar('Invalid', 'Please enter password.');
    } else if (confirmPassController.text.trim().isEmpty) {
      Get.snackbar('Invalid', 'Confirm password is empty.');
    } else {
      if (newPassController.text == confirmPassController.text) {
        api.changePassword({
          'admission_number': id,
          'old_password': passwordController.text,
          'new_password': confirmPassController.text
        }).then(
          (value) {
            isLoading.value = false;
            if (value?.status == true) {
              passwordController.clear();
              newPassController.clear();
              confirmPassController.clear();
              Get.back();
              Get.snackbar('Success', value?.message ?? 'Password Changed.');
            } else {
              Get.snackbar('Error', value?.message ?? 'Password not changed.');
            }
          },
        );
      } else {
        Get.snackbar('Invalid', 'Passwords do not match');
      }
    }
  }

  Future<void> resetPassword(String id) async {
    isLoading.value = true;
    if ((passwordController.text.trim().isEmpty)) {
      Get.snackbar('Invalid', 'Please enter password.');
      if ((newPassController.text.trim().isEmpty)) {
        Get.snackbar('Invalid', 'Please enter password.');
      } else if (confirmPassController.text.trim().isEmpty) {
        Get.snackbar('Invalid', 'Confirm password is empty.');
      } else {
        if (newPassController.text == confirmPassController.text) {
          api.resetPassword({
            'admission_number': id,
            'old_password': passwordController.text,
            'new_password': confirmPassController.text
          }).then(
            (value) {
              isLoading.value = false;
              if (value?.status == true) {
                passwordController.clear();
                newPassController.clear();
                confirmPassController.clear();
                Get.back();
                Get.snackbar('Success', value?.message ?? 'Password Changed.');
              } else {
                Get.snackbar(
                    'Error', value?.message ?? 'Password not changed.');
              }
            },
          );
        } else {
          Get.snackbar('Invalid', 'Passwords do not match');
        }
      }
    }
  }
}
