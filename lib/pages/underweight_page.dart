import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fit_allergy_check/component/my_dialog.dart';
import 'package:fit_allergy_check/controller/auth_controller.dart';
import 'package:fit_allergy_check/controller/underweight_controller.dart';
import 'package:fit_allergy_check/model/underweight.dart';
import 'package:fit_allergy_check/pages/add_underweight_page.dart';
import 'package:fit_allergy_check/pages/edit_underweight_page.dart';
import 'package:fit_allergy_check/pages/scan_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UnderweightPage extends StatefulWidget {
  final List<Underweight> underweightList;

  const UnderweightPage({Key? key, required this.underweightList})
      : super(key: key);

  @override
  State<UnderweightPage> createState() => _UnderweightPageState();
}

class _UnderweightPageState extends State<UnderweightPage> {
  final authController = Get.put(AuthController());
  final underwController = Get.put(UnderweightController());

  String searchQuery = "";
  String uid = "";

  List<ListUnderweight> updatedUnderwList = [];

  @override
  void initState() {
    super.initState();
    uid = authController.uid.value;

    print("uid: $uid");
  }

  int getIndex() {
    if (widget.underweightList.isNotEmpty) {
      int maxUnderwID = 0;
      for (final underweight in widget.underweightList) {
        if (underweight.underwID > maxUnderwID) {
          maxUnderwID = underweight.underwID;
        }
      }
      return maxUnderwID;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Underweight - Avoid For',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(AddUnderweightPage(index: getIndex()))?.then((result) {
                  if (result != null && result) {
                    underwController.fetchUnderweights(uid);
                  }
                });
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search',
                ),
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                },
              ),
            ),
            Obx(
              () {
                // final underwController = Get.find<UnderweightController>();

                final filteredUnderweightList =
                    widget.underweightList.where((underweight) {
                  return underweight.underwName
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();

                filteredUnderweightList.sort((a, b) {
                  if (a.isSelected && !b.isSelected) {
                    return -1;
                  } else if (!a.isSelected && b.isSelected) {
                    return 1;
                  } else {
                    return b.status.compareTo(a.status);
                  }
                });

                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredUnderweightList.length,
                    itemBuilder: (context, index) {
                      final underweight = filteredUnderweightList[index];
                      return ListUnderweight(
                        uid: uid,
                        underweight: underweight,
                        onCheckboxChanged: (value) {
                          setState(() {
                            underweight.isSelected = value;
                          });
                        },
                        onUnderweightEdited: refreshUnderweightList,
                        onUnderweightDeleted: refreshUnderweightList,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await underwController.updateUnderweight(uid, widget.underweightList);
          Get.to(ScanPage(
            title: "Underweight",
            underwLists: widget.underweightList,
          ));
        },
        child: const Icon(Icons.navigate_next),
      ),
    );
  }

  void refreshUnderweightList() {
    underwController.fetchUnderweights(uid);
  }
}

class ListUnderweight extends StatefulWidget {
  final String uid;
  final Underweight underweight;
  final Function(bool) onCheckboxChanged;
  final Function() onUnderweightEdited;
  final Function() onUnderweightDeleted;

  ListUnderweight({
    required this.uid,
    required this.underweight,
    required this.onCheckboxChanged,
    required this.onUnderweightEdited,
    required this.onUnderweightDeleted,
  });

  @override
  State<ListUnderweight> createState() => _ListUnderweightState();
}

class _ListUnderweightState extends State<ListUnderweight> {
  final underwController = Get.put(UnderweightController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
      child: Row(
        children: [
          Checkbox(
            value: widget.underweight.isSelected,
            onChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  widget.onCheckboxChanged(value);
                });
              }
            },
          ),
          Expanded(child: Text(widget.underweight.underwName)),
          widget.underweight.status == 1
              ? GestureDetector(
                  child: Icon(Icons.edit),
                  onTap: () {
                    Get.to(EditUnderweightPage(underweight: widget.underweight))
                        ?.then((result) {
                      if (result != null && result) {
                        widget.onUnderweightEdited();
                      }
                    });
                  },
                )
              : Container(),
          widget.underweight.status == 1
              ? SizedBox(
                  width: 17,
                )
              : Container(),
          widget.underweight.status == 1
              ? GestureDetector(
                  child: Icon(Icons.delete),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return MyDialog(
                          title: "Delete Ingredient",
                          message:
                              "Are you sure you want to delete this ingredient?",
                          dialogType: DialogType.info,
                          withBtn: true,
                          okPressed: () async {
                            Get.back();
                            await underwController.deleteUnderweight(
                                widget.uid, widget.underweight.underwID);
                            widget.onUnderweightDeleted();
                            Get.back();
                          },
                          cancelPressed: () {
                            Get.back();
                          },
                          okText: "Delete",
                          cancelText: "Cancel",
                        );
                      },
                    );
                  },
                )
              : Container(),
        ],
      ),
    );
  }
}
