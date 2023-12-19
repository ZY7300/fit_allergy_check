import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fit_allergy_check/component/my_dialog.dart';
import 'package:fit_allergy_check/controller/auth_controller.dart';
import 'package:fit_allergy_check/controller/overweight_controller.dart';
import 'package:fit_allergy_check/model/overweight.dart';
import 'package:fit_allergy_check/pages/add_overweight_page.dart';
import 'package:fit_allergy_check/pages/edit_overweight_page.dart';
import 'package:fit_allergy_check/pages/scan_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverweightPage extends StatefulWidget {
  final List<Overweight> overweightList;

  const OverweightPage({Key? key, required this.overweightList})
      : super(key: key);

  @override
  State<OverweightPage> createState() => _OverweightPageState();
}

class _OverweightPageState extends State<OverweightPage> {
  final authController = Get.put(AuthController());
  final overwController = Get.put(OverweightController());

  String searchQuery = "";
  String uid = "";

  List<ListOverweight> updatedOverwList = [];

  @override
  void initState() {
    super.initState();
    uid = authController.uid.value;

    print("uid: $uid");
  }

  int getIndex() {
    if (widget.overweightList.isNotEmpty) {
      int maxOverwID = 0;
      for (final overweight in widget.overweightList) {
        if (overweight.overwID > maxOverwID) {
          maxOverwID = overweight.overwID;
        }
      }
      return maxOverwID;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Overweight - Avoid For',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(AddOverweightPage(index: getIndex()))?.then((result) {
                  if (result != null && result) {
                    overwController.fetchOverweights(uid);
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
                final filteredOverweightList =
                    widget.overweightList.where((overweight) {
                  return overweight.overwName
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();

                filteredOverweightList.sort((a, b) {
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
                    itemCount: filteredOverweightList.length,
                    itemBuilder: (context, index) {
                      final overweight = filteredOverweightList[index];
                      return ListOverweight(
                        uid: uid,
                        overweight: overweight,
                        onCheckboxChanged: (value) {
                          setState(() {
                            overweight.isSelected = value;
                          });
                        },
                        onOverweightEdited: refreshOverweightList,
                        onOverweightDeleted: refreshOverweightList,
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
          await overwController.updateOverweight(uid, widget.overweightList);
          Get.to(ScanPage(
            title: "Overweight",
            overwLists: widget.overweightList,
          ));
        },
        child: const Icon(Icons.navigate_next),
      ),
    );
  }

  void refreshOverweightList() {
    overwController.fetchOverweights(uid);
  }
}

class ListOverweight extends StatefulWidget {
  final String uid;
  final Overweight overweight;
  final Function(bool) onCheckboxChanged;
  final Function() onOverweightEdited;
  final Function() onOverweightDeleted;

  ListOverweight({
    required this.uid,
    required this.overweight,
    required this.onCheckboxChanged,
    required this.onOverweightEdited,
    required this.onOverweightDeleted,
  });

  @override
  State<ListOverweight> createState() => _ListOverweightState();
}

class _ListOverweightState extends State<ListOverweight> {
  final overwController = Get.put(OverweightController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
      child: Row(
        children: [
          Checkbox(
            value: widget.overweight.isSelected,
            onChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  widget.onCheckboxChanged(value);
                });
              }
            },
          ),
          Expanded(child: Text(widget.overweight.overwName)),
          widget.overweight.status == 1
              ? GestureDetector(
                  child: Icon(Icons.edit),
                  onTap: () {
                    Get.to(EditOverweightPage(overweight: widget.overweight))
                        ?.then((result) {
                      if (result != null && result) {
                        widget.onOverweightEdited();
                      }
                    });
                  },
                )
              : Container(),
          widget.overweight.status == 1
              ? SizedBox(
                  width: 17,
                )
              : Container(),
          widget.overweight.status == 1
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
                            await overwController.deleteOverweight(
                                widget.uid, widget.overweight.overwID);
                            widget.onOverweightDeleted();
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
