import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss/controller/account_controller.dart';
import 'package:nss/view/common_pages/custom_decorations.dart';

class DeleteAccountScreen extends StatelessWidget {
  DeleteAccountScreen({super.key});

  final AccountController c = Get.put(AccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delete Account"),
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        foregroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Please specify reason to delete this account:",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 17),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          CustomWidgets().textField(
            controller: c.reasonController,
            label: '',
            hintText: 'Please specify the reason here',
            maxlines: 8,
            margin: EdgeInsets.symmetric(horizontal: 10),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomWidgets().buildActionButton(
                context: context,
                onPressed: () => CustomWidgets().showConfirmationDialog(
                    title: "Do you want to delete?",
                    content: Text(
                      "This will send request to the admin to delete your account.After approving, all your data will be lost and cannot login again.",
                    ),
                    onConfirm: () => c.deleteAccount(),
                    data: Obx(
                      () => (c.isLoading.value)
                          ? CircularProgressIndicator()
                          : Text('Confirm'),
                    )),
                text: "Delete Account",
                icon: Icons.delete,
                color: const Color.fromARGB(255, 158, 13, 3)),
          )
        ],
      ),
    );
  }
}
