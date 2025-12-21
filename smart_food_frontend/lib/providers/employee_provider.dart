import 'dart:io';
import 'package:flutter/material.dart';

import 'package:smart_food_frontend/data/models/employee_model.dart';
import 'package:smart_food_frontend/data/services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  List<EmployeeModel> _employees = [];
  EmployeeModel? _selectedEmployee;

  List<EmployeeModel> get employees => _employees;
  EmployeeModel? get selectedEmployee => _selectedEmployee;

  bool isLoading = false;

  // ======================================================
  // LOAD ALL EMPLOYEES OF STORE
  // ======================================================
  Future<void> loadEmployees() async {
    isLoading = true;
    notifyListeners();

    _employees = await EmployeeService.fetchEmployees();

    isLoading = false;
    notifyListeners();
  }

  // ======================================================
  // GET SINGLE EMPLOYEE
  // ======================================================
  Future<void> loadEmployee(int id) async {
    _selectedEmployee = await EmployeeService.fetchEmployee(id);
    notifyListeners();
  }

  // ======================================================
  // CREATE EMPLOYEE
  // ======================================================
  Future<bool> addEmployee({
    required Map<String, String> fields,
    File? avatarImage,
  }) async {
    final ok = await EmployeeService.createEmployee(
      fields: fields,
      avatarImage: avatarImage,
    );

    if (ok) {
      await loadEmployees(); // refresh danh sách
    }

    return ok;
  }

  // ======================================================
  // UPDATE EMPLOYEE
  // ======================================================
  Future<bool> updateEmployee({
    required int id,
    required Map<String, String> fields,
    File? avatarImage,
  }) async {
    final ok = await EmployeeService.updateEmployee(
      id: id,
      fields: fields,
      avatarImage: avatarImage,
    );

    if (ok) {
      await loadEmployees(); // refresh danh sách
    }

    return ok;
  }

  // ======================================================
  // DELETE EMPLOYEE
  // ======================================================
  Future<bool> deleteEmployee(int id) async {
    final ok = await EmployeeService.deleteEmployee(id);

    if (ok) {
      _employees.removeWhere((e) => e.id == id);
      notifyListeners();
    }

    return ok;
  }
}
