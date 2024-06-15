import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash } "mo:map/Map";

import Cart "Cart";
import Log "Log";
import Menu "Menu";
import Point "Point";
import Table "Table";
import Type "Types";
import User "User";

shared ({ caller = manager }) actor class Dorder() = this {

  // TODO: Replace this with Manager to anonymus role
  let guest : Principal = Principal.fromText("2vxsx-fae");

  //----------------- Log Functions -----------------//

  stable var logMap : Log.LogMap = Map.new<Nat, Log.Log>();

  public shared ({ caller }) func getLogs(logs : Log.Catagory) : async Result.Result<[Log.Log], Text> {
    if (User.canPerform(userMap, caller, #MonitorLogs) != true) {
      return #err("the caller " #Principal.toText(caller) # " dose not have permission Monitor Logs!");
    };
    return #ok(Log.getLogsByCategory(logMap, logs));
  };

  //----------------- Member Functions -----------------//

  stable var userMap : User.UserMap = Map.new<Principal, User.User>();
  User.new(userMap, guest, "ADMIN", #Admin, []);

  public shared ({ caller }) func registerMemberNew(name : Text, image : ?Blob) : async Result.Result<(), Text> {
    switch (User.get(userMap, caller)) {
      case (?user) {
        return #err("User " # Principal.toText(caller) # " Already Registered!");
      };
      case (null) {
        let allowedOperations = [
          #ReserveTable,
          #PayTable,
          #ModifyMenuItemPoint,
          #ModifyEmployeePoints,
        ];

        User.new(userMap, caller, name, #Customer, allowedOperations);
        Log.add(logMap, #Member, "Member " # Principal.toText(caller) # " has been Registered!");
        return #ok();
      };
    };
  };

  public shared ({ caller }) func addManager(principal : Principal, name : Text, allowedOperations : [Type.Operation]) : async Result.Result<(), Text> {
    if (User.canPerform(userMap, caller, #HireManager) != true) {
      return #err("The caller " # Principal.toText(caller) # " havent Opration for this func");
    };

    switch (User.get(userMap, principal)) {
      case (?is) {
        User.new(userMap, is.principal, is.name, #Manager, allowedOperations);
        Log.add(logMap, #Member, "Member " #Principal.toText(principal) # " updated to Manager By " # Principal.toText(caller) # "!");
        return #ok();
      };
      case (null) {
        User.new(userMap, principal, name, #Manager, allowedOperations);
        Log.add(logMap, #Member, "New Manager " # Principal.toText(principal) # " Added  By " # Principal.toText(caller) # "!");
        return #ok();
      };
    };
  };

  public shared ({ caller }) func addEmployee(principal : Principal, name : Text, allowedOperations : [Type.Operation]) : async Result.Result<(), Text> {
    if (User.canPerform(userMap, caller, #HireEmployee) != true) {
      return #err("The caller " # Principal.toText(caller) # " havent Opration for this func");
    };

    switch (User.get(userMap, principal)) {
      case (?is) {
        User.new(userMap, is.principal, is.name, #Employee, allowedOperations);
        Log.add(logMap, #Member, "Member " #Principal.toText(principal) # " updated to Employee By " # Principal.toText(caller) # "!");
        return #ok();
      };
      case (null) {
        User.new(userMap, principal, name, #Employee, allowedOperations);
        Log.add(logMap, #Member, "New Member " # Principal.toText(principal) # " Added By " # Principal.toText(caller) # "!");
        return #ok();
      };
    };
  };

  public shared func getMember(p : Principal) : async ?User.User {
    let member = User.get(userMap, p);
    return member;
  };

  public shared func getAllMembersNew() : async [User.User] {
    return Iter.toArray(Map.vals<Principal, User.User>(userMap));
  };

  //----------------- Table Functions -----------------//

  stable var tableMap : Table.TableMap = Map.new<Nat, Table.Table>();

  public shared ({ caller }) func addTableNew(tableNumber : Nat, capacity : Nat) : async Result.Result<(Text), Text> {
    if (User.canPerform(userMap, caller, #ModifyTable) != true) {
      return #err("The caller " #Principal.toText(caller) # " dose not have permission to add table!");
    };

    switch (Table.get(tableMap, tableNumber)) {
      case (?is) {
        return #err("This Table is Already added with this number");
      };
      case (null) {
        Table.new(tableMap, tableNumber, capacity);
        Log.add(logMap, #Table, "Table " #Nat.toText(tableNumber) # " was  Added by " #Principal.toText(caller) # "!");
        return #ok(" Table  " #Nat.toText(tableNumber) # "  was Added! ");
      };
    };
  };

  public shared query func getTables() : async [Table.Table] {
    return Iter.toArray(Map.vals<Nat, Table.Table>(tableMap));
  };

  public shared ({ caller }) func reserveTableNew(tableId : Nat) : async Result.Result<Text, Text> {
    if (User.canPerform(userMap, caller, #ReserveTable) != true) {
      return #err("The caller " #Principal.toText(caller) # " dose not have permission Reserve Table!");
    };
    switch (Table.reserve(tableMap, tableId, caller)) {
      case (#ok(updatedTable)) {
        Log.add(logMap, #Table, "Table " #Nat.toText(tableId) # " was Reserved by " #Principal.toText(caller) # "!");
        return #ok("Table reserved successfully.");
      };
      case (#err(errorMessage)) {
        return #err(errorMessage);
      };
    };
  };

  public shared ({ caller }) func unreserveTableNew(tableId : Nat) : async Result.Result<Text, Text> {
    if (Table.canUnreserveTable(userMap, tableMap, caller, tableId) != true) {
      return #err("can't unreserve table becuse caller didn't reserve any table !");
    };

    switch (Table.unreserve(tableMap, tableId)) {
      case (#ok(updatedTable)) {
        Log.add(logMap, #Table, "Table " #Nat.toText(tableId) # " was Unreserved by " #Principal.toText(caller) # "!");
        return #ok("Table " #Nat.toText(tableId) # " was Unreserved!");
      };
      case (#err(errorMessage)) {
        return #err(errorMessage);
      };
    };
  };

  //----------------- Menu Functions -----------------//

  stable var menuMap : Menu.MenuMap = Map.new<Nat, Menu.MenuItem>();

  public shared ({ caller }) func addMenuItem(newMenuItem : Menu.NewMenuItem) : async Result.Result<Text, Text> {
    if (User.canPerform(userMap, caller, #ModifyMenuItem) != true) {
      return #err("The caller " #Principal.toText(caller) # " dose not have permission to add menu item!");
    };
    Menu.new(menuMap, newMenuItem);
    Log.add(logMap, #Menu, "New Menu Added By " #Principal.toText(caller) # "!");
    return #ok("Menu Added Successfully");
  };

  public shared ({ caller }) func updateMenuItem(menuId : Nat, newMenuItem : Menu.NewMenuItem) : async Result.Result<Text, Text> {
    if (User.canPerform(userMap, caller, #ModifyMenuItem) != true) {
      return #err("The caller " #Principal.toText(caller) # " dose not have permission to update menu item!");
    };

    switch (Menu.update(menuMap, menuId, newMenuItem)) {
      case (#ok(msg)) {
        Log.add(logMap, #Menu, "Item with id " #Nat.toText(menuId) # " has been Updated by " #Principal.toText(caller) # ".");
        return #ok(msg);
      };
      case (#err(errorMessage)) {
        return #err(errorMessage);
      };
    };

  };

  public shared ({ caller }) func removeMenuItem(menuId : Nat) : async Result.Result<Text, Text> {
    if (User.canPerform(userMap, caller, #ModifyMenuItem) != true) {
      return #err("The caller " #Principal.toText(caller) # " dose not have permission to remove menu item!");
    };

    if (Menu.get(menuMap, menuId) == null) {
      return #err("The menu item with id " #Nat.toText(menuId) # " does not exist!");
    };

    Map.delete<Nat, Menu.MenuItem>(menuMap, nhash, menuId);
    Log.add(logMap, #Menu, "Item with id " #Nat.toText(menuId) # " has been removed from the menu by " #Principal.toText(caller) # ".");
    return #ok("The menu item with id " #Nat.toText(menuId) # " has been removed!");
  };

  public shared query func getAllMenuItems() : async [Menu.MenuItem] {
    return Iter.toArray(Map.vals<Nat, Menu.MenuItem>(menuMap));
  };

  public query func getItem(menuId : Nat) : async ?Menu.MenuItem {
    return Menu.get(menuMap, menuId);
  };

  //--------------------------- Point Functions ----------------------------\\

  public shared ({ caller }) func addPointToItem(menuId : Nat, point : Point.Numb, suggest : Bool, comment : ?Text, image : ?[Blob]) : async Result.Result<Text, Text> {
    if (User.canPerform(userMap, caller, #ModifyMenuItemPoint) != true) {
      return #err("The caller " #Principal.toText(caller) # " dose not have permission to Point an item!");
    };

    switch (Menu.get(menuMap, menuId)) {
      case null {
        return #err("The menu item with id " #Nat.toText(menuId) # " does not exist!");
      };

      case (?menuItem) {

        if (Menu.hasPoint(menuMap, menuId, caller) == true) {
          return #err("The caller " #Principal.toText(caller) # " has already pointed this item!");
        };

        let newMenuPoint = Buffer.fromArray<Point.MenuPoint>(menuItem.point);
        newMenuPoint.add({
          id = menuId;
          comment = comment;
          pointBy = caller;
          point = point;
          suggest = suggest;
          cratedAt = Time.now();
          image = image;
        });

        let newMenuItem : Menu.MenuItem = {
          id = menuItem.id;
          name = menuItem.name;
          price = menuItem.price;
          stock = menuItem.stock;
          description = menuItem.description;
          point = Buffer.toArray(newMenuPoint);
          image = menuItem.image;
        };

        Menu.put(menuMap, menuId, newMenuItem);
        Log.add(logMap, #MenuPoint, "The User " #Principal.toText(caller) # " added a point to the menu item with id " #Nat.toText(menuId));
        return #ok("Point added to menu item " #Nat.toText(menuId) # "!");
      };
    };
  };

  public shared ({ caller }) func updateMenuPoint(menuId : Nat, comment : ?Text, point : Point.Numb, suggest : Bool, image : ?[Blob]) : async Result.Result<Text, Text> {
    if (Menu.hasPoint(menuMap, menuId, caller) != true) {
      return #err("this member doesnt point this menu");
    };
    let newPoint : Point.MenuPoint = {
      id = menuId;
      comment = comment;
      pointBy = caller;
      point = point;
      suggest = suggest;
      cratedAt = Time.now();
      image = image;
    };
    let filteredPoint = Menu.replaceMenuPointByPrincipal(menuMap, menuId, caller, newPoint);
    switch (filteredPoint) {
      case (false) {
        return #err(" " #Principal.toText(caller) # " have not any Point in this Menu ID !");
      };
      case (true) {
        Log.add(logMap, #MenuPoint, "" #Principal.toText(caller) # " update their own Menu Point " #Nat.toText(menuId) # "!");

        return #ok("Update Success!");
      };
    };
  };

  public shared ({ caller }) func addPointToEmployee(employeeId : Principal, comment : ?Text, point : Point.Numb) : async Result.Result<Text, Text> {
    if (User.canPerform(userMap, caller, #ModifyEmployeePoints) != true) {
      return #err("the caller " #Principal.toText(caller) # " dose not have permission Point to Emoloyee");
    };
    if (User.hasPoint(userMap, caller, employeeId) == true) {
      return #err("Member " #Principal.toText(caller) # " already have a Point this employee!");
    };
    switch (User.get(userMap, employeeId)) {
      case (null) {
        return #err("The user with principal " #Principal.toText(employeeId) # " does not exist!");
      };
      case (?user) {
        let employeePoint = Buffer.fromArray<Point.EmployeePoint>(user.point);
        employeePoint.add({
          pointBy = caller;
          comment = comment;
          point = point;
          cratedAt = Time.now();
        });
        let updateEmployee : User.User = {
          name = user.name;
          principal = employeeId;
          role = user.role;
          allowedOperations = user.allowedOperations;
          id = user.id;
          image = user.image;
          buyingScore = user.buyingScore;
          point = Buffer.toArray(employeePoint);
        };
        User.put(userMap, employeeId, updateEmployee);
        Log.add(logMap, #EmployeePoint, "" #Principal.toText(caller) # " Gave Point to employee " #Principal.toText(employeeId) # "!");
        return #ok("Point added to employee " #Principal.toText(employeeId) # " successfully!");
      };
    };
  };

  public shared ({ caller }) func editPointEmployee(employeeId : Principal, point : Point.Numb, comment : ?Text, suggest : Bool) : async Result.Result<Text, Text> {
    if (User.hasPoint(userMap, caller, employeeId) != true) {
      return #err("This caller with principal " #Principal.toText(caller) # " does not have a point for Employee!");
    };

    let newPoint : Point.EmployeePoint = {
      pointBy = caller;
      comment = comment;
      point = point;
      cratedAt = Time.now();
    };
    let filteredPoint = User.replaceUserPointByPrincipal(userMap, employeeId, newPoint);
    switch (filteredPoint) {
      case (false) {
        return #err("" # Principal.toText(caller) # " have not any Point in this employee ID !");
      };
      case (true) {
        Log.add(logMap, #EmployeePoint, "" #Principal.toText(caller) # " Update their own point of employee  " #Principal.toText(employeeId) # "!");
        return #ok("Update Success!");
      };
    };

  };

  //-------------------------- Cart Functions------------------------------\\

  stable var tableCarts : Cart.TableCartMap = Map.new<Nat, Cart.CartItem>();

  public shared ({ caller }) func createTableCart(tableId : Nat, orderType : Cart.OrderType) : async Result.Result<Text, Text> {
    if (User.canPerform(userMap, caller, #ModifyTable)) {
      return #err("Table cart already exists for table " # Nat.toText(tableId));
    } else {
      let newCart : Cart.CartItem = {
        products = Buffer.Buffer<Menu.MenuItem>;
        orderType = orderType;
        createdAt = Time.now();
      };
      Cart.put(tableCarts, tableId, newCart);
      return #ok("Table cart created for table " # Nat.toText(tableId));
    };
  };

  public shared ({ caller }) func addToTableCart(tableId : Nat, menuItemId : Nat, quantity : Nat) : async Result.Result<Text, Text> {
    switch (Cart.get(tableCarts, tableId)) {
      case (null) {
        return #err("No cart found for table " # Nat.toText(tableId));
      };
      case (?cart) {
        let updatedProducts = cart.products;
        let currentQuantity = switch (HashMap.get(cart.products, menuItemId)) {
          case (?q) { q };
          case (null) { 0 };
        };
        updatedProducts.put(menuItemId, currentQuantity + quantity);
        let updatedCart = {
          products = updatedProducts;
          orderType = cart.orderType;
          createdAt = cart.createdAt;
        };
        HashMap.put(tableCarts, tableId, updatedCart);
        return #ok("Added to table cart for table " # Nat.toText(tableId));
      };
    };
  };

  public shared query func getTableCart(tableId : Nat) : async ?Cart.CartItem {
    return Cart.get(tableCarts, tableId);
  };

  // stable var cartMap = Map.new<Principal, Cart.Order>();

  // public func addToCart(cartMap : Cart.CartMap, caller : Principal, orderType : Types.OrderType) : Result.Result<(Text), Text> {
  //   switch (get(cartMap, caller)) {
  //     case (?cart) {
  //       return #err("This caller with principal " #Principal.toText(caller) # " already has a cart!");
  //     };
  //     case (null) {
  //       let newCart : Cart.Cart = {
  //         products = HashMap.empty;
  //         orderType = orderType;
  //         createdAt = Time.now();
  //       };
  //       put(cartMap, caller, newCart);
  //       return #ok("The cart for " #Principal.toText(caller) # " has been created!");
  //     };
  //   };
  // };

};

// //member
// //systeme ray giri baraye ezafe kardan va hazf kardane menu va khadamat
// //systeme emtiyaz dehi be karmandan
// //systeme emtiaz dehi be menu va item;
// // ezafe kardane map be factorhaye principal ... ya table
// // ezafe kardane reserve table baraye time moshakhas va time hodudi
