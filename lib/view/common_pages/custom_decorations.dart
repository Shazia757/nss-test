import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss/view/home_screen.dart';
import 'package:nss/view/issues/user_issues_screen.dart';
import 'package:nss/view/volunteers/profile_screen.dart';

typedef StringValueOf<T> = String Function(T item);

class CustomWidgets {
  static InputDecoration textFieldDecoration({
    required String label,
    String? errorText,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      label: Text(label),
      prefix: prefix,
      suffix: suffix,
      border: const OutlineInputBorder(),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
      errorText: errorText,
    );
  }


  SearchBar searchBar(
      {BoxConstraints? constraints,
      Widget? leading,
      TextEditingController? controller,
      String? hintText,
      void Function(String)? onChanged,
      bool visible = true,
      void Function()? onPressedCancel}) {
    return SearchBar(
        constraints: constraints,
        leading: Icon(Icons.search),
        controller: controller,
        hintText: hintText,
        onChanged: onChanged,
        trailing: [
          Visibility(
            visible: visible,
            child:
                IconButton(onPressed: onPressedCancel, icon: Icon(Icons.close)),
          )
        ]);
  }

  static Padding searchableDropDown<T>({
    required TextEditingController controller,
    required StringValueOf<T> stringValueOf,
    required void Function(T) onSelected,
    void Function(String)? onChanged,
    required List<T> selectionList,
    TextInputType? keyboardType,
    required String label,
    bool show = true,
    EdgeInsets margin = const EdgeInsets.symmetric(vertical: 5),
    double elevation = 2,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10),
  }) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: margin,
        elevation: elevation,
        child: Padding(
          padding: padding,
          child: Visibility(
            visible: show,
            child: TypeAheadField<T>(
              debounceDuration: const Duration(milliseconds: 500),
              builder: (context, controller, focusNode) {
                return TextField(
                  keyboardType: keyboardType,
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (value) {
                    if (onChanged != null) {
                      onChanged(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: label,
                    border: InputBorder.none,
                  ),
                );
              },
              suggestionsCallback: (search) => selectionList
                  .where((element) =>
                      stringValueOf(element).toLowerCase().contains(
                            search.trim().toLowerCase(),
                          ))
                  .toList(),
              itemBuilder: (context, itemData) =>
                  ListTile(title: Text(stringValueOf(itemData))),
              controller: controller,
              onSelected: (value) => onSelected(value),
            ),
          ),
        ),
      ),
    );
  }

  Padding datePickerTextField({
    required BuildContext context,
    required DateTime firstDate,
    required DateTime lastDate,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    required String label,
    required TextEditingController controller,
    DateTime? currentDate,
    DateTime? initialDate,
    required void Function(DateTime) selectedDate,
    bool disableTap = false,
    InputDecoration? decoration,
  }) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          if (!disableTap) {
            DateTime pickedDate = await showDatePicker(
                  context: context,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  currentDate: currentDate,
                  initialDate: initialDate,
                ) ??
                lastDate;

            controller.text = DateFormat.yMMMd().format(pickedDate);

            selectedDate(pickedDate);
          }
        },
        decoration: decoration ?? textFieldDecoration(label: label),
      ),
    );
  }

  Card textField({
    required TextEditingController controller,
    required String label,
    EdgeInsets margin = const EdgeInsets.symmetric(vertical: 5),
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10),
    TextInputType? keyboardType,
    bool isEnabled = true,
    bool readOnly = false,
    bool? hideText,
    TextStyle? labelStyle,
    void Function()? onTap,
    List<TextInputFormatter>? inputFormatters,
    double elevation = 2,
    String? errorText,
    Widget? suffix,
    Color? color,
    int maxlines = 1,
    String? hintText,
  }) {
    return Card(
      color: color,
      elevation: elevation,
      margin: margin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding,
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          enabled: isEnabled,
          onTap: onTap,
          obscureText: hideText ?? false,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          maxLines: maxlines,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            labelText: label,
            border: InputBorder.none,
            labelStyle: labelStyle,
            suffix: suffix,
          ),
        ),
      ),
    );
  }

  Padding customDatePickerTextField({
    required BuildContext context,
    required DateTime firstDate,
    required DateTime lastDate,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    required String label,
    required TextEditingController controller,
    DateTime? currentDate,
    DateTime? initialDate,
    required void Function(DateTime) selectedDate,
    bool disableTap = false,
    InputDecoration? decoration,
  }) {
    return Padding(
      padding: padding,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: () async {
              if (!disableTap) {
                DateTime pickedDate = await showDatePicker(
                      context: context,
                      firstDate: firstDate,
                      lastDate: lastDate,
                      currentDate: currentDate,
                      initialDate: initialDate,
                    ) ??
                    lastDate;

                controller.text = DateFormat.yMMMd().format(pickedDate);

                selectedDate(pickedDate);
              }
            },
            decoration: decoration ?? textFieldDecoration(label: label),
          ),
        ),
      ),
    );
  }

  static Padding textWidget(
    MapEntry<String, dynamic> entry, {
    TextStyle? keyStyle,
    TextStyle? valueStyle,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
  }) {
    return Padding(
      padding: padding,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "${formatKey(entry.key)} : ",
              style: keyStyle ?? Theme.of(Get.context!).textTheme.titleMedium,
            ),
            TextSpan(
              text: "${entry.value ?? ""}",
              style: valueStyle ?? Theme.of(Get.context!).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  static Padding salesRow({label, amount}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                  color: Theme.of(Get.context!).colorScheme.primary)),
          Text(amount, style: Theme.of(Get.context!).textTheme.labelMedium),
        ],
      ),
    );
  }

  static void showSnackBar(
    String title,
    String message, {
    Widget? icon = const Icon(Icons.error),
  }) {
    Get.showSnackbar(GetSnackBar(
      title: title,
      isDismissible: true,
      duration: const Duration(milliseconds: 2000),
      icon: icon,
      message: message,
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 5,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      snackStyle: SnackStyle.GROUNDED,
      barBlur: 30,
      backgroundGradient: LinearGradient(colors: [Colors.red, Colors.white]),
    ));
  }

  Expanded menuBuilder({
    required List<Widget> menuChildren,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: MenuAnchor(
        menuChildren: menuChildren,
        builder: (context, controller, child) {
          return InkWell(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Colors.grey.shade900,
                ),
                Text(label)
              ],
            ),
          );
        },
      ),
    );
  }

  void showConfirmationDialog(
      {required String title,
      String? message,
      Widget? content,
      required VoidCallback onConfirm}) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(title),
          content: (message != null) ? Text(message) : content,
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                onConfirm();
              },
              child: Text("Confirm", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

String formatKey(String key) {
  String formattedKey = key.replaceAllMapped(
      RegExp(r'(?<!^)([A-Z])'), (Match match) => ' ${match.group(0)}');
  formattedKey =
      formattedKey.replaceFirst(formattedKey[0], formattedKey[0].toUpperCase());
  //formattedKey = formattedKey.replaceAll("from", "replace");
  return formattedKey;
}

class CustomNavBar extends StatelessWidget {
  CustomNavBar({super.key, required this.currentIndex});
  final int currentIndex;
  final pages = [HomeScreen(), ScreenIssues(), VolunteerAddScreen()];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (value) {
        if (currentIndex != value) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => pages[value],
          ));
        }
      },
      currentIndex: currentIndex,
      items: <BottomNavigationBarItem>[
        navBarItem("Home", icon: Icon(Icons.home)),
        navBarItem("Issue", icon: Icon(Icons.bug_report_outlined)),
        navBarItem("Profile", icon: Icon(Icons.person_2)),
      ],
    );
  }

  BottomNavigationBarItem navBarItem(String label, {required Widget icon}) {
    return BottomNavigationBarItem(
        icon: icon,
        label: label,
        backgroundColor: Color.fromARGB(255, 25, 6, 71));
  }
}
