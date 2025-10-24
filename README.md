# 🏥 Dart Hospital Management System

A console-based application for managing hospital operations, built with Dart. This project demonstrates Object-Oriented Programming (OOP) principles and a clean, 3-layer architecture (Data, Domain, UI).

The application features a colorful, table-based console interface for easy navigation and management of patients, doctors, and appointments.

---

## ✨ Features

* **Patient Management:** Full CRUD (Create, Read, Update, Delete) for patient records.
* **Doctor Management:** Full CRUD (Create, Read, Update, Delete) for doctor records.
* **Appointment Management:** Schedule new appointments, view all appointments, and cancel existing appointments.
* **Smart Business Logic:** Automatically cancels all of a patient's or doctor's scheduled appointments upon their deletion from the system.
* **Clean Console UI:** A user-friendly, color-coded, and table-based interface for all interactions.
* **Layered Architecture:** Follows a strict separation of concerns between Data, Domain (business logic), and UI (presentation).

---

## 📂 Project Structure

This project follows a 3-layer architecture:

* `📂 lib/data`: Manages data storage (currently in-memory) and retrieval.
* `📂 lib/domain`: Contains the core business logic, models (Patient, Doctor, Appointment), and services.
* `📂 lib/ui`: Handles all user interaction (console menus, color-coded output, and input reading).

---

## 🚀 How to Run

To run this project on your local machine, follow these steps.

1.  **Navigate to the `apps` Directory**
    Open your terminal and change to the `apps` directory (the one that contains the `pubspec.yaml` file).
    ```sh
    # Example:
    cd path/to/Dart-Hospital-Management-system-ba0d89209351ff8846e8f69f64e5ef26f977c9f6/apps
    ```

2.  **Get Dependencies**
    Run `dart pub get` to install the project's dependencies (like `path` and `test`).
    ```sh
    dart pub get
    ```

3.  **Run the Application**
    Use the `dart run` command to execute the main application file.
    ```sh
    dart run bin/apps.dart
    ```

4.  **Use the App**
    The main menu will appear in your console. You can now use the application.

    ```
    ============================================
             HOSPITAL MANAGEMENT SYSTEM
    ============================================
    1. Manage Appointments
    2. Manage Patients
    3. Manage Doctors
    4. Exit
    Enter your choice:
    ```

---

## 🧪 How to Run Tests

Unit tests are included for the domain layer (e.g., in `test/appointment_service_test.dart`).

1.  **Make sure you are in the `apps` directory.**
2.  **Run the test command:**
    ```sh
    dart test
    ```
    You will see the output of the tests in your console.