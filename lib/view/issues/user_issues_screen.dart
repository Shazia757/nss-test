import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'package:nss/database/local_storage.dart';
import 'package:nss/view/common_pages/custom_decorations.dart';

import '../../controller/issues_controller.dart';
import '../../model/issues_model.dart';
import 'admin_issues_screen.dart';

class ScreenIssues extends StatelessWidget {
  const ScreenIssues({super.key});

  @override
  Widget build(BuildContext context) {
    if (LocalStorage().readUser().role != "vol") {
      return ScreenAdminIssues();
    } else {
      return ScreenUserIssues();
    }
  }
}

class ScreenUserIssues extends StatelessWidget {
  final IssuesController c = Get.put(IssuesController());

  ScreenUserIssues({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Issues"),
          backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          foregroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 50),
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: c.tabController,
                tabs: [
                  Tab(child: Text("Report an issue")),
                  Tab(child: Text("Issues Reported")),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () => c.getAdminIssues(), icon: Icon(Icons.refresh))
          ],
        ),
        bottomNavigationBar: CustomNavBar(currentIndex: 1),
        body: TabBarView(
          controller: c.tabController,
          children: [
            reportIssueView(context),
            reportedIssueView(Theme.of(context)),
          ],
        ),
      ),
    );
  }

  Widget reportedIssueView(ThemeData theme) {
    return Column(
      children: [
        SizedBox(height: 12),
        TabBar.secondary(
          dividerColor: Colors.transparent,
          padding: EdgeInsets.all(10),
          indicator: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(12)),
            color: theme.colorScheme.surfaceDim,
          ),
          tabs: [Tab(text: "Opened"), Tab(text: "Closed")],
          onTap: (_) => c.getVolIssues(),
        ),
        Expanded(
          child: Obx(() {
            return TabBarView(children: [
              RefreshIndicator.adaptive(
                  onRefresh: () async => c.getVolIssues(),
                  child: c.isLoading.isTrue
                      ? Center(child: CircularProgressIndicator())
                      : c.closedList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset('assets/empty_list.json',
                                      height: 200),
                                  SizedBox(height: 20),
                                  Text(
                                    'No data available',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'There’s nothing to show here at the moment.',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (context, index) => listTileView(
                                  c.openedList[index],
                                  count: "${index + 1}"),
                              itemCount: c.openedList.length,
                            )),
              RefreshIndicator.adaptive(
                  onRefresh: () async => c.getVolIssues(),
                  child: Center(
                    child: c.isLoading.isTrue
                        ? CircularProgressIndicator()
                        : c.closedList.isEmpty
                            ? Text('No resolved issues.')
                            : ListView.builder(
                                padding: EdgeInsets.all(10),
                                itemBuilder: (context, index) {
                                  return listTileView(c.closedList[index],
                                      count: "${index + 1}");
                                },
                                itemCount: c.closedList.length,
                              ),
                  )),
            ]);
          }),
        )
      ],
    );
  }

  Widget reportIssueView(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() => DropdownButton<String>(
                value: c.submittedTo.value,
                onChanged: (value) => c.submittedTo.value = value!,
                items: [
                  DropdownMenuItem(value: 'sec', child: Text("Secretary")),
                  DropdownMenuItem(value: 'po', child: Text("Program Officer")),
                ],
              )),
        ),
        CustomWidgets()
            .textField(controller: c.subjectController, label: "Subject"),
        CustomWidgets().textField(
            controller: c.desController,
          maxlines: 12,
          label: "Description",
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() => c.isLoading.value
                ? CircularProgressIndicator()
                : FilledButton(
                    onPressed: () {
                      if (c.onSubmitIssueValidation()) {
                        CustomWidgets().showConfirmationDialog(
                            title: "Report Issue",
                            message:
                                "Are you sure you want to report the issue?",
                            onConfirm: () {
                              c.reportIssue();
                            });
                      }
                    },
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.red[900]),
                    child: Text("Report"),
                  ))),
      ],
    );
  }

  Widget listTileView(Issues data, {required String count}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          data.subject ?? "N/A",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              "To: ${data.to}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        leading: CircleAvatar(
          radius: 20,
          child: Text(
            count,
          ),
        ),
        trailing: data.createdDate != null
            ? Text(
                DateFormat.yMMMd().format(data.createdDate!),
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              )
            : Text(''),
        onTap: () {
          Get.defaultDialog(
            title: data.subject ?? "N/A",
            middleText: data.description ?? "N/A",
            barrierDismissible: true,
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text("Close"),
              ),
            ],
          );
        },
      ),
    );
  }
}
