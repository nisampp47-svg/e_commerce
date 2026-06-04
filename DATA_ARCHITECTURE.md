# E-Commerce Application - Data Flow Architecture

## 📋 Executive Summary

This Flutter e-commerce application (LUXE) implements a multi-layered data architecture with clear separation between user authentication, product catalog management, and shopping cart operations. Data flows through well-defined channels from external services (Supabase) through repositories to UI providers.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER (UI)                     │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐   │
│  │   Home      │   Catalog    │    Cart      │   Profile    │   │
│  │   Screen    │   Screen     │   Screen     │   Screen     │   │
│  └──────────────┴──────────────┴──────────────┴──────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                ↕
┌─────────────────────────────────────────────────────────────────┐
│                    STATE MANAGEMENT LAYER                        │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐   │
│  │AuthController│CartProvider  │CatalogProvider │Navigation  │   │
│  │   (Provider) │   (Provider) │   (Provider) │  ViewModel  │   │
│  └──────────────┴──────────────┴──────────────┴──────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                ↕
┌─────────────────────────────────────────────────────────────────┐
│                      REPOSITORY LAYER                            │
│  ┌────────────────┬────────────────┬────────────────────────┐    │
│  │  AuthRepository│  CartRepository│  CatalogRepository    │    │
│  │   (Interface)  │   (Interface)  │   (Interface)         │    │
│  └────────────────┴────────────────┴────────────────────────┘    │
│  ┌────────────────┬────────────────┬────────────────────────┐    │
│  │  AuthRepoImpl   │  CartRepoImpl   │  CatalogRepoImpl       │    │
│  │ (Supabase)     │  (SQLite)      │  (Static Data)        │    │
│  └────────────────┴────────────────┴────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                ↕
┌─────────────────────────────────────────────────────────────────┐
│                      DATA/SERVICE LAYER                          │
│  ┌─────────���──────────┬─────────────────┬─────────────────────┐  │
│  │SupabaseAuthService │CartDatabaseHelper │ProductData        │  │
│  │                    │(SQLite)           │(Local Array)      │  │
│  │Supabase Client     │  cart.db          │CategoryData       │  │
│  └────────────────────┴─────────────────┴─────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                ↕
┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL DEPENDENCIES                         │
│  ┌────────────────────┬─────────────────┬──────────────────┐    │
│  │  Supabase Cloud    │   SQLite Local  │  PhonePe Payment │    │
│  │  - Authentication  │   Database      │  Gateway         │    │
│  │  - User Management │   cart.db       │                  │    │
│  └────────────────────┴─────────────────┴──────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Detailed Data Flow Paths

### 1️⃣ AUTHENTICATION FLOW

**Path:** User Input → AuthController → AuthRepository → SupabaseAuthService → Supabase Cloud

```
┌─────────────────────┐
│   User Input Form   │
│  (email, password)  │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ AuthController      │
│ (State Management)  │
├─────────────────────┤
│ • login()           │
│ • register()        │
│ • logout()          │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ AuthRepository      │
│ (Interface)         │
├─────────────────────┤
│ • signIn()          │
│ • signUp()          │
│ • signOut()         │
└──────────┬──────────┘
           ↓
┌─────────────────────────────┐
│ AuthRepositoryImpl           │
│ (Supabase Integration)      │
└──────────┬──────────────────┘
           ↓
┌──────────────────────────────────────┐
│ SupabaseAuthService                  │
│ - currentUser (User object)          │
│ - authStateChanges (Stream<Session>) │
│ - Credential validation              │
└──────────┬───────────────────────────┘
           ↓
┌──────────────────────────────────────┐
│ Supabase Backend                     │
│ - User table                         │
│ - Session management                 │
│ - JWT token generation               │
└──────────────────────────────────────┘
           ↓
┌──────────────────────────────────────┐
│ AuthController (Listener Callback)   │
│ user = _authService.currentUser      │
│ notifyListeners() → Triggers rebuild │
└──────────────────────────────────────┘
           ↓
┌──────────────────────────────────────┐
│ GoRouter (Route Guard)               │
│ - Validates Supabase session         │
│ - Redirects unauthenticated users    │
│ - Grants access to app routes        │
└──────────────────────────────────────┘
```

**Data Model:**
```dart
User {
  id: String (UUID from Supabase)
  email: String
  userMetadata: {
    name: String
  }
}
```

**Status:** ✅ **ACTIVE** - Core authentication pathway

---

### 2️⃣ PRODUCT CATALOG FLOW

**Path:** Static Data → ProductData → CatalogProvider → UI Components

```
┌────────────────────────────────┐
│ lib/data/repositories/         │
│ product_data.dart              │
│                                │
│ Hardcoded Products Array:      │
│ - 18 furniture items           │
│ - Categories: chair, sofa,     │
│            table, bed          │
│ - Pricing & ratings included   │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ lib/data/repositories/         │
│ category_data.dart             │
│                                │
│ Dummy Categories Array:        │
│ - Sofas, Chairs, Tables, Beds  │
│ - Material Design icons        │
│ - Category IDs for filtering   │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ CatalogRepository (Interface)  │
│                                │
│ • getProducts()                │
│ • getCategories()              │
│ • filterByCategory()           │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ CatalogRepositoryImpl           │
│ (Static in-memory access)      │
│                                │
│ Returns: List<ProductModel>    │
│ Returns: List<CategoryModel>   │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ CatalogProvider                │
│ (State Management)             │
│                                │
│ • _categories                  │
│ • _products                    │
│ • _filteredProducts            │
│ • _isLoading                   │
│                                │
│ Methods:                       │
│ • loadCategories()             │
│ • loadProducts()               │
│ • filterByCategory(id)         │
│ • searchProducts(query)        │
└──────���───────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ UI Consumers                   │
│                                │
│ • HomeScreen                   │
│ • CatalogScreen                │
│ • ProductScreen (Detail)       │
│ • ProductGridView              │
└────────────────────────────────┘
```

**Data Models:**
```dart
ProductModel {
  id: String (p1-p18)
  name: String
  price: double
  image: String (filename)
  categoryId: String
  isRecommended: bool
  rating: double?
  description: String?
  reviews: List<String>?
  specifications: Map<String, String>?
}

CategoryModel {
  categoryId: String
  categoryTitle: String
  icon: IconData?
}
```

**Status:** ✅ **ACTIVE** - All product data accessed via this flow

---

### 3️⃣ SHOPPING CART FLOW (LOCAL STORAGE)

**Path:** ProductModel → CartProvider → CartRepository → CartDatabaseHelper → SQLite

```
┌────────────────────────────────┐
│ User Action                    │
│ (Add to Cart)                  │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ ProductScreen / ProductGrid    │
│ UI Component                   │
│                                │
│ context.read<CartProvider>     │
│   .addToCart(product)          │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ CartProvider (ChangeNotifier)  │
│                                │
│ State:                         │
│ • _items: List<CartItem>       │
│ • _isLoading: bool             │
│                                │
│ Getters:                       │
│ • items (unmodifiable list)    │
│ • totalItems (count)           │
│ • totalPrice (sum)             │
│ • isLoading                    │
│                                │
│ Operations:                    │
│ • addToCart(product)           │
│ • removeFromCart(id)           │
│ • incrementQuantity(id)        │
│ • decrementQuantity(id)        │
│ • clear()                      │
│ • loadCart() [on app start]    │
│ • quantityOf(id)               │
│ • isInCart(id)                 │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ CartRepository (Interface)     │
│                                │
│ • fetchAllItems()              │
│ • addItem()                    │
│ • updateQuantity()             │
│ • deleteItem()                 │
│ • clearAll()                   │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ CartRepositoryImpl              │
│ (SQLite Wrapper)               │
│                                │
│ Delegates to:                  │
│ CartDatabaseHelper.instance    │
└──────────────┬─────────────────┘
               ↓
┌─────���──────────────────────────┐
│ CartDatabaseHelper             │
│ (Database Access Object)       │
│                                │
│ SQLite Operations:             │
│ • upsertItem()                 │
│ • updateQuantity()             │
│ • deleteItem()                 │
│ • clearAll()                   │
│ • fetchAllItems()              │
│ • close()                      │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ SQLite Database: cart.db       │
│                                │
│ Table: cart_items              │
│ ├─ id (TEXT, PRIMARY KEY)      │
│ ├─ name (TEXT)                 │
│ ├─ price (REAL)                │
│ ├─ image (TEXT)                │
│ ├─ categoryId (TEXT)           │
│ ├─ rating (REAL)               │
│ ├─ quantity (INTEGER)          │
│ └─ description (TEXT) [v3]     │
│                                │
│ Schema Versions:               │
│ v1: Basic fields               │
│ v2: Added categoryId           │
│ v3: Added description          │
└────────────────────────────────┘
```

**Data Model:**
```dart
CartItem {
  product: ProductModel
  quantity: int
}

// Stored in database as:
{
  'id': String,
  'name': String,
  'price': double,
  'image': String,
  'categoryId': String,
  'rating': double?,
  'quantity': int,
  'description': String?
}
```

**Lifecycle:**
1. **App Start:** `CartProvider.loadCart()` called → fetches all items from SQLite → populates `_items` list
2. **Add Item:** Item inserted/upserted into cart_items table → CartProvider notifies listeners
3. **Modify Quantity:** Update SQL query for specific item → CartProvider notifies listeners
4. **Remove Item:** Delete SQL query → CartProvider cleans up memory → notifies listeners
5. **Checkout:** Items remain in cart for order processing

**Status:** ✅ **ACTIVE** - All cart data flows through this pathway

---

### 4️⃣ PAYMENT FLOW (PhonePe Integration)

**Path:** CartScreen → PhonePePaymentService → PhonePe Gateway → Payment Response

```
┌────────────────────────────────┐
│ CartScreen                     │
│ User clicks "Pay" button       │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ _handlePayment() method        │
│                                │
│ Prepares payment data:         │
│ • totalPrice (from provider)   │
│ • totalItems (from provider)   │
│ • transaction ID (UUID)        │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ PhonePePaymentService          │
│ (Payment Service Wrapper)      │
│                                │
│ • startPayment()               │
│ • Initializes PhonePe SDK      │
│ • Sends order details          │
│ • Handles callbacks            │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ phonepe_payment_sdk plugin     │
│ (Third-party payment gateway)  │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ PhonePe Payment Gateway        │
│ (External Service)             │
│                                │
│ • Authentication               │
│ • Payment processing           │
│ • Merchant verification        │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ Payment Result Callback        │
│                                │
│ Success / Failure / Cancelled  │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ CartScreen handles response:   │
│                                │
│ • Show success dialog          │
│ • Clear cart if successful     │
│ • Navigate to home/orders      │
└────────────────────────────────┘
```

**Status:** ✅ **ACTIVE** - Payment integration available in CartScreen

---

### 5️⃣ NAVIGATION & ROUTING FLOW

**Path:** User Action → GoRouter → Route Guard → Screen Rendering

```
┌────────────────────────────────┐
│ App Initialization             │
│ main.dart                      │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ Setup Flow:                    │
│                                │
│ 1. Load .env file              │
│ 2. Initialize Supabase         │
│ 3. Load theme preference       │
│ 4. Initialize AuthController   │
│ 5. Create AppRouter instance   │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ AppRouter.router()             │
│ (GoRouter Configuration)       │
│                                │
│ Redirect Logic:                │
│ ├─ Check Supabase session      │
│ ├─ No session → /auth          │
│ ├─ Has session → allow routes  │
│ └─ Already at /auth → home (/) │
└──────────────┬─────────────────┘
               ↓
┌────────────────────────────────┐
│ Route Structure:               │
│                                │
│ /auth (LoginRegister)          │
│                                │
│ / (Shell Route)                │
│ ├─ / (Home)                    │
│ ├─ /catalog (Catalog)          │
│ ├─ /cart (Cart)                │
│ └─ /profile (Profile)          │
│                                │
│ /product/:id (Product Detail)  │
└────────────────────────────────┘
```

**Status:** ✅ **ACTIVE** - Central navigation control

---

## 🗄️ Storage & Database Architecture

### Supabase Cloud (Authentication)
- **Location:** Remote cloud service
- **Purpose:** User authentication and session management
- **Accessed Via:** SupabaseAuthService
- **Data Stored:**
  - User credentials
  - Authentication tokens (JWT)
  - Session information
  - User metadata (name, etc.)

### SQLite Local Database (cart.db)
- **Location:** Device local storage (`getDatabasesPath()`)
- **Purpose:** Persist shopping cart items
- **File Size:** Small (only cart items)
- **Table Schema:**
  ```sql
  CREATE TABLE cart_items (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    price       REAL NOT NULL,
    image       TEXT NOT NULL,
    categoryId  TEXT NOT NULL,
    rating      REAL,
    quantity    INTEGER NOT NULL DEFAULT 1,
    description TEXT
  )
  ```
- **Lifecycle:** Created on first app launch, persists until user clears app data
- **Accessed Via:** CartDatabaseHelper (Singleton pattern)

### SharedPreferences
- **Location:** Device local storage
- **Purpose:** Store theme preference (light/dark mode)
- **Data Stored:** `theme_mode` (String: "dark" | "light")
- **Accessed Via:** Direct SharedPreferences API in main.dart

### In-Memory Static Data
- **ProductData:** `lib/data/repositories/product_data.dart`
  - 18 hardcoded product objects
  - Loaded once at app start
  - Never modified
- **CategoryData:** `lib/data/repositories/category_data.dart`
  - 5 hardcoded category objects
  - Includes Material Design icons
  - Loaded once at app start

---

## 🔄 Key Data Transformations

### 1. Product → CartItem
```dart
// Input: ProductModel (from catalog)
ProductModel {
  id: "p1"
  name: "Black Simple Chair"
  price: 249.99
  // ... other fields
}

↓ TRANSFORMATION ↓

// Output: Stored in SQLite and wrapped in CartItem
CartItem {
  product: ProductModel(...),
  quantity: 1
}

// SQLite Row:
{
  'id': 'p1',
  'name': 'Black Simple Chair',
  'price': 249.99,
  'quantity': 1,
  // ...
}
```

### 2. SQLite Row → ProductModel → CartItem
```dart
// SQLite Query Result
final rows = await db.query('cart_items')
// Result: List<Map<String, dynamic>>

↓ MAPPING ↓

for (final row in rows) {
  final product = ProductModel(
    id: row['id'] as String,
    name: row['name'] as String,
    price: (row['price'] as num).toDouble(),
    // ...
  );
  _items.add(CartItem(
    product: product,
    quantity: row['quantity'] as int
  ));
}
```

### 3. Auth Response → User Object
```dart
// Supabase Response
{
  "session": {
    "user": {
      "id": "uuid-string",
      "email": "user@example.com",
      "user_metadata": {
        "name": "John Doe"
      }
    }
  }
}

↓ TRANSFORMATION ↓

// AuthController State
User user = session.user
```

---

## 📱 Data Flow by Feature

### Feature: Browse Products
```
CatalogScreen
  ↓ (reads state)
CatalogProvider
  ↓ (calls)
CatalogRepository.getProducts()
  ↓ (returns)
ProductData.products (static List)
  ↓ (maps to)
List<ProductModel>
  ↓ (renders in)
ProductGridView Widget
```

### Feature: Add to Cart
```
ProductGrid/ProductScreen
  ↓ (user tap "Add")
context.read<CartProvider>().addToCart(product)
  ↓ (in-memory add)
CartProvider._items.add(CartItem)
  ↓ (persist to DB)
CartRepository.addItem()
  ↓ (SQL insert)
CartDatabaseHelper.upsertItem()
  ↓ (SQLite)
cart_items table
  ↓ (notify)
CartProvider notifyListeners()
  ↓ (UI update)
CartScreen/Badge
```

### Feature: Checkout & Pay
```
CartScreen displays cart items
  ↓ (user tap "Proceed to Payment")
_handlePayment()
  ↓ (gather order data)
totalPrice, totalItems from CartProvider
  ↓ (initiate payment)
PhonePePaymentService.startPayment()
  ↓ (external gateway)
PhonePe SDK
  ↓ (process payment)
Payment Result
  ↓ (if successful)
CartDatabaseHelper.clearAll()
  ↓ (clear local cart)
Show success dialog
```

---

## 🎯 Data Flow Entry/Exit Points

| Entry Point | Source | Format | Target |
|-------------|--------|--------|--------|
| **Authentication** | User form input | Email, Password (strings) | AuthController |
| **Product Browsing** | Static data file | Dart const array | CatalogProvider |
| **Add to Cart** | UI button tap | ProductModel object | CartProvider |
| **Payment** | Cart data | Order summary object | PhonePePaymentService |
| **.env File** | Environment variables | SUPABASE_URL, SUPABASE_ANON_KEY | main.dart |

| Exit Point | Target | Format | Purpose |
|------------|--------|--------|---------|
| **Auth Response** | GoRouter | User session object | Route guarding |
| **Cart Display** | CartScreen UI | List<CartItem> | Show cart items |
| **Product List** | GridView widget | List<ProductModel> | Display products |
| **Payment Result** | Dialog/Screen | Success/Failure string | User feedback |
| **Theme Setting** | SharedPreferences | String (dark/light) | Theme persistence |

---

## ⚠️ Unused/Incomplete Files & Directories

### 🔴 **UNUSED - Platform-Specific Directories (Empty Shells)**

These directories are Flutter project templates for multi-platform deployment but contain no custom implementation:

```
android/          ← Android platform files (not customized)
ios/              ← iOS platform files (not customized)
linux/            ← Linux platform files (not customized)
macos/            ← macOS platform files (not customized)
windows/          ← Windows platform files (not customized)
web/              ← Web platform files (not customized)
```

**Status:** These are boilerplate-only and not actively used in the data flow. The app is Flutter-native with no custom platform channel implementations.

---

### 🔴 **UNUSED/INCOMPLETE WIDGETS**

**File:** `lib/widget/my_drawer.dart`

```dart
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // ... basic structure
      SizedBox(
        height: 90,
        child: ListView(
          scrollDirection: Axis.horizontal,
        ),  // ← EMPTY - No children!
      ),
      // ... rest of drawer
    );
  }
}
```

**Issue:** 
- The drawer is rendered but the horizontal categories ListView is empty (no items)
- The drawer appears to be initialized but incomplete
- **Not referenced** in active screens (HomeScreen, CatalogScreen use other layouts)

**Impact:** Medium - Feature not critical, user experience relies on CatalogScreen instead

---

### ⚠️ **INCOMPLETE/STUB FILES**

**File:** `lib/model/app_user.dart`

```dart
class AppUser {
  final String uid;
  final String? email;
  final String? name;
  final String? photoUrl;
  
  // Conversion methods present but not used
  factory AppUser.fromMap(...)
  Map<String, dynamic> toMap()
}
```

**Issue:**
- Defined but **never instantiated** anywhere in the codebase
- Auth system uses Supabase's `User` object directly instead
- Redundant with Supabase integration
- Model exists for Firebase integration (code comments reference Firestore)

**Impact:** Low - Dead code, no runtime effect

---

### ⚠️ **FRAMEWORK/TEST DIRECTORIES**

**Directory:** `test/`

**Status:** Empty - No unit tests or integration tests present

**Impact:** Low - Not part of data flow, development artifact

---

## 📊 Data Flow Summary Matrix

| Component | Data Type | Storage | Access Pattern | Status |
|-----------|-----------|---------|-----------------|--------|
| **Authentication** | User credentials | Supabase | Remote REST API | ✅ Active |
| **Products** | ProductModel list | Static (const) | In-memory array | ✅ Active |
| **Categories** | CategoryModel list | Static (const) | In-memory array | ✅ Active |
| **Cart Items** | CartItem list | SQLite (cart.db) | Local database | ✅ Active |
| **Theme Preference** | String (light/dark) | SharedPreferences | Local storage | ✅ Active |
| **Payment** | Order summary | PhonePe gateway | External API | ✅ Active |
| **User Metadata** | User object | Supabase session | In-memory (listener) | ✅ Active |

---

## 🔗 Service Locator & Dependency Injection

**File:** `lib/core/service_locator.dart`

```dart
final getIt = GetIt.instance;

void setupServiceLocator() {
  // These are registered at app initialization
  getIt.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );
}
```

**Note:** `setupServiceLocator()` is defined but **not called** in main.dart. Service locator is NOT actively used in providers. Instead, repositories are instantiated directly in providers:

```dart
// Current (Direct instantiation):
class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepository = getIt<CartRepository>();
  // This works because getIt is imported globally
}
```

**Issue:** Mixed pattern - some code uses getIt, but setupServiceLocator() never called

---

## 🚀 Critical Data Flow Paths (Priority Order)

1. **Authentication** - Controls all app access
2. **Product Load** - Enables browsing (static data)
3. **Add to Cart** - Core shopping feature
4. **Cart Persistence** - SQLite ensures data survives app restart
5. **Payment Processing** - Completes user transaction
6. **Theme Management** - User preference persistence

---

## 💾 Database Schema Details

### SQLite: cart.db

```sql
-- Version 1 (Initial)
CREATE TABLE cart_items (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  price       REAL NOT NULL,
  image       TEXT NOT NULL,
  categoryId  TEXT NOT NULL,
  rating      REAL,
  quantity    INTEGER NOT NULL DEFAULT 1
);

-- Version 2 Upgrade
-- ALTER TABLE cart_items ADD COLUMN categoryId TEXT NOT NULL DEFAULT "";

-- Version 3 Upgrade
-- ALTER TABLE cart_items ADD COLUMN description TEXT;
-- ALTER TABLE cart_items ADD COLUMN isRecommended INTEGER;
```

**Sample Data:**
```json
{
  "id": "p1",
  "name": "Black Simple Chair",
  "price": 249.99,
  "image": "black_chair.jpg",
  "categoryId": "chair",
  "rating": 4.7,
  "quantity": 2,
  "description": null,
  "isRecommended": 1
}
```

---

## 🔐 Security Considerations

| Layer | Mechanism | Implementation |
|-------|-----------|-----------------|
| **Auth** | JWT Tokens | Supabase session management |
| **API** | Anonymous Key | Stored in `.env` (exposed - ⚠️ should use auth token) |
| **Database** | SQLite encryption | Not implemented (local only) |
| **Payment** | Third-party gateway | PhonePe SDK handles encryption |

---

## 🎯 Bottlenecks & Potential Issues

| Issue | Location | Severity | Solution |
|-------|----------|----------|----------|
| **No backend persistence** | Cart only in SQLite | Medium | Add order table + API sync |
| **Hardcoded products** | product_data.dart | Medium | Fetch from Supabase |
| **No error handling** | cart_provider.dart | Medium | Add try-catch blocks |
| **Unused drawer** | my_drawer.dart | Low | Remove or complete |
| **Dead code** | app_user.dart | Low | Remove unused model |
| **No pagination** | Products list | Medium | Implement pagination for scalability |
| **Payment not persisted** | No order tracking | High | Store orders in database |

---

## 📝 Configuration Files

### .env (Environment Variables)
```env
SUPABASE_URL=https://kdudyqnqoisngtyklixj.supabase.co
SUPABASE_ANON_KEY=sb_publishable_Yh95ta_K8Yi-Q4iG9badtQ_VVhfvqlr
```

**⚠️ Security Issue:** Anonymous key publicly exposed (fine for development, unsafe for production)

### pubspec.yaml (Dependencies)
```yaml
dependencies:
  supabase_flutter:        # Authentication & backend
  provider:                 # State management
  sqflite:                  # Local database
  go_router:                # Navigation routing
  phonepe_payment_sdk:      # Payment gateway
  flutter_dotenv:           # Environment variables
  cached_network_image:     # Image caching
  get_it:                   # Service locator (partially used)
  shared_preferences:       # Local preferences
  # ... additional UI libraries
```

---

## 🎓 Conclusion

The e-commerce app implements a **clean three-tier architecture** with:

- ✅ **Clear separation of concerns** (providers, repositories, services)
- ✅ **Multiple data sources** (Supabase for auth, SQLite for cart, static for products)
- ✅ **Proper state management** (Provider pattern with ChangeNotifier)
- ✅ **Persistence** (SQLite for cart, SharedPreferences for theme)
- ✅ **External integrations** (Supabase, PhonePe)

**Main areas for improvement:**
1. Implement backend product synchronization
2. Add comprehensive error handling
3. Remove unused code (app_user.dart, my_drawer.dart)
4. Add order persistence and tracking
5. Implement pagination for scalability

---

**Document Generated:** June 4, 2026
**Repository:** nisampp47-svg/e_commerce
**App Name:** LUXE E-Commerce
**Platform:** Flutter (Multi-platform)
