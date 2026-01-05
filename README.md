# 🍔 Pushan Food App

Pushan Food is a cross-platform food delivery application (Android / iOS) built with a Flutter frontend and a Django REST backend. The project demonstrates a multi-role food delivery ecosystem with four main roles: User (customer), Merchant (store owner), Shipper (delivery), and Admin (system administrator).

Status: Work in progress  
Purpose: Demo of a full food ordering and delivery workflow with role-based features.

---

## 📌 Key Features
- Multi-role support: User / Merchant / Shipper / Admin  
- Browse stores and menus  
- Add items to cart and place orders  
- Order lifecycle and status tracking (ordered → preparing → delivering → completed)  
- Merchant: manage store profile, categories, menu items, and orders  
- Shipper: view available delivery tasks, accept jobs, view delivery route (Here Maps demo), update delivery status  
- Admin: manage users, merchants, shippers, stores, orders, and categories  
- Authentication via JWT (SimpleJWT)  
- Demo payment flow (not production-ready)

---

## 👥 Roles & Responsibilities

- User (Customer)
  - Register and log in
  - Browse stores and menus
  - Add items to cart and place orders
  - View order history and order statuses
  - Manage profile and delivery addresses

- Merchant (Store Owner)
  - Create and update store profile
  - Manage categories and menu items
  - Receive, confirm, and update order preparations

- Shipper (Delivery)
  - View available deliveries
  - Accept delivery assignments
  - Use map demo (Here Maps) to view routes
  - Update delivery progress and status

- Admin
  - Manage users, merchants, and shippers
  - Approve and manage stores
  - Monitor orders and system activity
  - Manage global categories and system data

---

## 🧭 Architecture
- Frontend: Flutter mobile app (Dart) — includes interfaces for all roles  
- Backend: Django + Django REST Framework — exposes RESTful APIs, role-based permissions, business logic  
- Database: PostgreSQL  
- Maps: Here Maps API (demo route visualization)  
- Authentication: JWT (SimpleJWT)

Typical flow:
1. Customer places an order in the Flutter app.  
2. Backend stores the order in PostgreSQL.  
3. Merchant confirms and prepares the order.  
4. Shipper accepts the delivery, follows route, and marks delivery updates.  
5. Order status is updated and synchronized across roles.

---

## 🛠 Tech Stack
- Frontend: Flutter (Dart)  
- Backend: Python, Django, Django REST Framework  
- Authentication: SimpleJWT (JWT)  
- Database: PostgreSQL  
- Maps: Here Maps API (demo)  
- Tools: Android Studio, Flutter SDK, Python virtual environment

---

## 📁 Repository Structure (overview)
- smart_food_backend/ — Django REST backend source code  
- smart_food_frontend/ — Flutter mobile application source code  
- docs/ — screenshots, UI mockups, and design assets  
- README.md, LICENSE, requirements.txt, pubspec.yaml, etc.

---

## ▶️ Quick Setup & Run

Note: These instructions are for development environments.

### Backend (Django)
1. Change to backend folder:
   ```bash
   cd smart_food_backend
   ```
2. Create and activate a virtual environment:
   - macOS / Linux:
     ```bash
     python -m venv venv
     source venv/bin/activate
     ```
   - Windows (PowerShell):
     ```powershell
     python -m venv venv
     .\venv\Scripts\Activate.ps1
     ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Configure environment variables (example):
   - Create a `.env` (or set environment variables) with keys for:
     - DATABASE (Postgres connection or Django DATABASES settings)
     - SECRET_KEY
     - DEBUG
     - SIMPLE_JWT settings (if needed)
     - HERE_MAPS_API_KEY (for map demo)
5. Apply database migrations:
   ```bash
   python manage.py migrate
   ```
6. Create a superuser:
   ```bash
   python manage.py createsuperuser
   ```
7. Run development server:
   ```bash
   python manage.py runserver
   ```

### Frontend (Flutter)
1. Change to frontend folder:
   ```bash
   cd smart_food_frontend
   ```
2. Get packages:
   ```bash
   flutter pub get
   ```
3. Analyze:
   ```bash
   flutter analyze
   ```
4. Run on an emulator or device:
   ```bash
   flutter run
   ```
5. Build release APK (Android):
   ```bash
   flutter build apk --release
   ```

---

## 🗄 Database
PostgreSQL is used for persistent storage. The backend models include users, roles, stores, menus, orders, and delivery records. Use Django admin or migrations to manage schema.

---

## 💳 Payments
Payment flows are demo only and not integrated with real payment gateways. Do not use demo payment logic in production.

---

## ⚠️ Notes & Limitations
- This project is a work-in-progress and intended primarily as a demo/prototype.  
- Do not use demo configurations or payment flows in production.  
- Proper secrets management, HTTPS, production settings, and secure deployment are required for production use.

---

## 📫 Contact
- GitHub: [ancoldly](https://github.com/ancoldly)  
- Email: hongan.dev@gmail.com
