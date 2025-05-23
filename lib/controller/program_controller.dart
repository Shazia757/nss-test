import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nss/api.dart';
import 'package:nss/database/local_storage.dart';
import 'package:nss/view/program/program_list_screen.dart';
import '../model/programs_model.dart';

class ProgramListController extends GetxController {
  RxList<Program> programsList = <Program>[].obs;
  RxList<Program> searchList = <Program>[].obs;
  RxBool isLoading = true.obs;
  TextEditingController searchController = TextEditingController();
  Rx<Date> date = Rx<Date>(Date.oldestToLatest);

  @override
  void onInit() {
    getPrograms();
    super.onInit();
  }

  void getPrograms() async {
    isLoading.value = true;
    Api().allPrograms().then(
      (value) {
        programsList.assignAll(value?.programs ?? []);
        searchList.assignAll(programsList);
        isLoading.value = false;
      },
    );
  }

  void onSearchTextChanged(String searchText) async {
    if (searchText.isEmpty) {
      searchController.clear();
      searchList.assignAll(programsList);
    } else {
      final filtered = programsList.where((program) {
        final name = program.name?.toLowerCase() ?? '';
        return name.contains(searchText.toLowerCase());
      }).toList();

      searchList.assignAll(filtered);
    }
  }

  void sortByDate(Date selectedDate) {
    if (selectedDate == Date.oldestToLatest) {
      searchList.sort((a, b) => a.date!.compareTo(b.date!));
    } else {
      searchList.sort((a, b) => b.date!.compareTo(a.date!));
    }
  }
}

class AddProgramController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  var isUpdateButtonLoading = false.obs;
  var isDeleteButtonLoading = false.obs;

  DateTime? date;

  addProgram() {
    isUpdateButtonLoading.value = true;
    Api()
        .addProgram(Program(
            name: nameController.text,
            date: date,
            duration: int.tryParse(durationController.text),
            createdBy: (LocalStorage().readUser().admissionNo).toString(),
            description: descController.text))
        .then(
      (value) {
        isUpdateButtonLoading.value = false;
        if (value?.status == true) {
          Get.back();
          Get.snackbar(
              "Success", value?.message ?? "Program added successfully");
        } else {
          Get.snackbar("Error", value?.message ?? 'Failed to add program.');
        }
      },
    );
  }

  updateProgram(int id) {
    isUpdateButtonLoading.value = true;
    Api().updateProgram({
      'name': nameController.text,
      'date': date.toString(),
      'duration': durationController.text,
      'updated_by': LocalStorage().readUser().admissionNo,
      'id': id.toString(),
      'description': descController.text
    }).then(
      (value) {
        isUpdateButtonLoading.value = false;
        if (value?.status == true) {
          Get.back();
          Get.snackbar(
              "Success", value?.message ?? "Program updated successfully.");
        } else {
          Get.snackbar('Error', value?.message ?? 'Failed to update program.');
        }
      },
    );
  }

  deleteProgram(int id) {
    isDeleteButtonLoading.value = true;
    Api().deleteProgram(id).then(
      (value) {
        if (value?.status == true) {
          isDeleteButtonLoading.value = false;
          Get.snackbar(
              "Success", value?.message ?? "Program deleted successfully.");
          Get.to(() => ProgramsScreen());
        } else {
          Get.snackbar("Error", value?.message ?? 'Failed to delete program.');
        }
      },
    );
  }

  bool onSubmitProgramValidation() {
    if (nameController.text.isEmpty) {
      Get.snackbar('Invalid', 'Please enter program name');
      return false;
    }
    if (dateController.text.isEmpty) {
      Get.snackbar('Invalid', 'Please enter date');
      return false;
    }
    if (durationController.text.isEmpty) {
      Get.snackbar('Invalid', 'Please enter duration');
      return false;
    }
    if (descController.text.isEmpty) {
      Get.snackbar('Invalid', 'Please add description');
      return false;
    }
    return true;
  }
}
