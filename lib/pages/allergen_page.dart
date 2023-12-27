import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fit_allergy_check/component/my_dialog.dart';
import 'package:fit_allergy_check/controller/allergen_controller.dart';
import 'package:fit_allergy_check/controller/auth_controller.dart';
import 'package:fit_allergy_check/model/allergen.dart';
import 'package:fit_allergy_check/pages/add_allergen_page.dart';
import 'package:fit_allergy_check/pages/edit_allergen_page.dart';
import 'package:fit_allergy_check/pages/scan_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllergenPage extends StatefulWidget {
  final List<Allergen> allergenList;

  const AllergenPage({Key? key, required this.allergenList}) : super(key: key);

  @override
  State<AllergenPage> createState() => _AllergenPageState();
}

class _AllergenPageState extends State<AllergenPage> {
  final authController = Get.put(AuthController());
  final allergenController = Get.put(AllergenController());

  String searchQuery = "";
  String uid = "";

  List<ListAllergen> updatedAllerList = [];

  bool isDescriptionVisible = false;

  Allergen selectedAllergen = Allergen(
    allerID: 0,
    allerName: '',
    desc: '',
    isSelected: false,
    status: 0,
  );

  @override
  void initState() {
    super.initState();
    uid = authController.uid.value;

    print("uid: $uid");
  }

  int getIndex() {
    if (widget.allergenList.isNotEmpty) {
      int maxAllerID = 0;
      for (final allergen in widget.allergenList) {
        if (allergen.allerID > maxAllerID) {
          maxAllerID = allergen.allerID;
        }
      }
      return maxAllerID;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Allergen - Avoid For',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(AddAllergenPage(index: getIndex()))?.then((result) {
                  if (result != null && result) {
                    allergenController.fetchAllergens(uid);
                  }
                });
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                    // final allergenController = Get.find<AllergenController>();

                    final filteredAllergenList =
                        widget.allergenList.where((allergen) {
                      return allergen.allerName
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase());
                    }).toList();

                    filteredAllergenList.sort((a, b) {
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
                        itemCount: filteredAllergenList.length,
                        itemBuilder: (context, index) {
                          final allergen = filteredAllergenList[index];
                          return ListAllergen(
                            uid: uid,
                            allergen: allergen,
                            onCheckboxChanged: (value) {
                              setState(() {
                                allergen.isSelected = value;
                              });
                            },
                            onAllergenEdited: refreshAllergenList,
                            onAllergenDeleted: refreshAllergenList,
                            onTap: () {
                              setState(() {
                                selectedAllergen = allergen;
                                isDescriptionVisible = true;
                              });
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            if (isDescriptionVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isDescriptionVisible = false;
                    });
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: AllergenDescriptionCard(
                        allergen: selectedAllergen,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await allergenController.updateAllergen(uid, widget.allergenList);
          Get.to(ScanPage(
            title: "Allergen",
            allerLists: widget.allergenList,
          ));
        },
        child: const Icon(Icons.navigate_next),
      ),
    );
  }

  void refreshAllergenList() {
    allergenController.fetchAllergens(uid);
  }
}

class ListAllergen extends StatefulWidget {
  final String uid;
  final Allergen allergen;
  final Function(bool) onCheckboxChanged;
  final Function() onAllergenEdited;
  final Function() onAllergenDeleted;
  final Function() onTap;

  ListAllergen({
    required this.uid,
    required this.allergen,
    required this.onCheckboxChanged,
    required this.onAllergenEdited,
    required this.onAllergenDeleted,
    required this.onTap,
  });

  @override
  State<ListAllergen> createState() => _ListAllergenState();
}

class _ListAllergenState extends State<ListAllergen> {
  final allergenController = Get.put(AllergenController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
      child: Row(
        children: [
          Checkbox(
            value: widget.allergen.isSelected,
            onChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  widget.onCheckboxChanged(value);
                });
              }
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: widget.onTap,
              child: Text(widget.allergen.allerName),
            ),
          ),
          widget.allergen.status == 1
              ? GestureDetector(
                  child: Icon(Icons.edit),
                  onTap: () {
                    Get.to(EditAllergenPage(allergen: widget.allergen))
                        ?.then((result) {
                      if (result != null && result) {
                        widget.onAllergenEdited();
                      }
                    });
                  },
                )
              : Container(),
          widget.allergen.status == 1
              ? SizedBox(
                  width: 17,
                )
              : Container(),
          widget.allergen.status == 1
              ? GestureDetector(
                  child: Icon(Icons.delete),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return MyDialog(
                          title: "Delete Allergen",
                          message:
                              "Are you sure you want to delete this allergen?",
                          dialogType: DialogType.info,
                          withBtn: true,
                          okPressed: () async {
                            Get.back();
                            await allergenController.deleteAllergen(
                                widget.uid, widget.allergen.allerID);
                            widget.onAllergenDeleted();
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

class AllergenDescriptionCard extends StatelessWidget {
  final Allergen allergen;

  const AllergenDescriptionCard({
    Key? key,
    required this.allergen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "${allergen.allerName.toUpperCase()}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10,),
            Text(
              allergen.desc != "" ? "${allergen.desc}" : "No description.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

