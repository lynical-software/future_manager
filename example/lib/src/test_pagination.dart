import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:future_manager/future_manager.dart';
import 'package:sura_flutter/sura_flutter.dart';

class SuraManagerWithPagination extends StatefulWidget {
  final FutureManager<int> dataManager;
  const SuraManagerWithPagination({Key? key, required this.dataManager}) : super(key: key);

  @override
  _SuraManagerWithPaginationState createState() => _SuraManagerWithPaginationState();
}

class _SuraManagerWithPaginationState extends State<SuraManagerWithPagination> {
  late FutureManager<UserResponse> userManager = FutureManager(
    reloading: false,
    onSuccess: (response) {
      if (userManager.hasData) {
        response.users = [...userManager.data!.users, ...response.users];
      }
      currentPage += 1;
      return response;
    },
  );
  int currentPage = 1;
  int maxTimeToShowError = 0;

  Future fetchData([bool reload = false]) async {
    if (reload) {
      currentPage = 1;
    }
    await userManager.execute(
      () async {
        await Future.delayed(const Duration(seconds: 1));
        // throw "Expected error thrown";
        if (currentPage > 2 && maxTimeToShowError < 2) {
          maxTimeToShowError++;
          throw "Expected error thrown from execute";
        }

        log("current page: $currentPage");
        final response = await Dio().get(
          "https://express-boilerplate-dev.lynical.com/api/user/all",
          queryParameters: {
            "page": currentPage,
            "count": 10,
          },
        );
        return UserResponse.fromJson(response.data);
      },
      reloading: reload,
    );
  }

  @override
  void initState() {
    fetchData();
    widget.dataManager.addListener(() {
      infoLog("Data manager:", context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fetch all users with pagination")),
      body: FutureManagerBuilder<UserResponse>(
        futureManager: userManager,
        // onRefreshing: () => const RefreshProgressIndicator(),
        ready: (context, UserResponse response) {
          return SuraPaginatedList(
            itemCount: response.users.length,
            hasMoreData: response.hasMoreData,
            padding: EdgeInsets.zero,
            hasError: userManager.hasError,
            // loadingWidget: emptySizedBox,
            itemBuilder: (context, index) {
              final user = response.users[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                onTap: () {},
                title: Text("${index + 1}: ${user.firstName} ${user.lastName}"),
                subtitle: Text(user.email!),
              );
            },
            dataLoader: fetchData,
            errorWidget: Column(
              children: [
                Text(userManager.error.toString()),
                IconButton(
                  onPressed: () {
                    userManager.clearError();
                    userManager.refresh();
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class UserResponse {
  List<UserModel> users;
  final Pagination? pagination;

  UserResponse({this.pagination, required this.users});

  bool get hasMoreData => pagination != null ? users.length < pagination!.totalItems : false;

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        users: json["data"] == null ? [] : List<UserModel>.from(json["data"].map((x) => UserModel.fromJson(x))),
        pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
      );
}

class UserModel {
  UserModel({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.avatar,
  });

  String? id;
  String? email;
  String? firstName;
  String? lastName;
  String? avatar;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["_id"],
        email: json["email"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        avatar: json["profile_img"],
      );
}

class Pagination {
  Pagination({
    required this.page,
    required this.totalItems,
    required this.totalPage,
  });

  num page;
  num totalItems;
  num totalPage;

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json["page"] ?? 0,
        totalItems: json["total_items"] ?? 0,
        totalPage: json["total_page"] ?? 0,
      );
}
