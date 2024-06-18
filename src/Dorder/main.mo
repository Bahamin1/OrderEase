import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash; phash } "mo:map/Map";

import Cart "Cart";
import Log "Log";
import Menu "Menu";
import Review "Review";
import Table "Table";
import Type "Types";
import User "User";

shared ({ caller = manager }) actor class Dorder() = this {

  // TODO: Replace this with Manager to anonymus role
  let guest : Principal = Principal.fromText("2vxsx-fae");

  //----------------- Log Functions -----------------//

  stable var logMap : Log.LogMap = Map.new<Nat, Log.Log>();

  public shared ({ caller }) func getLogs(logs : Log.Catagory) : async Result.Result<[Log.Log], Text> {
    if (User.employeeCanPerform(employeeMap, caller, #MonitorLogs) != true) {
      return #err("the caller " #Principal.toText(caller) # " dose not have permission Monitor Logs!");
    };
    return #ok(Log.getLogsByCategory(logMap, logs));
  };

  //----------------- Member Functions -----------------//

  stable var userMap : User.UserMap = Map.new<Principal, User.User>();

  stable var employeeMap : User.EmployeeMap = Map.new<Principal, User.Employee>();
  User.new(userMap, guest, "bahamin", "bahamindehpour@gmail.com", #Admin, 09354706897, null, []);
  User.hire(employeeMap, guest, #Admin, "Bahamin", "bahamindehpour@gmail.com", 09354706897, null, []);

  public shared ({ caller }) func registerAndUpdateMember(name : Text, email : Text, number : Nat, image : ?Blob) : async (Text) {

    let allowedOperations = [
      #ReserveTable,
      #PayTable,
      #CanTakeAway,
      #ModifyMenuItemPoint,
      #ModifyEmployeePoints,
    ];

    User.new(userMap, caller, name, email, #Customer, number, image, allowedOperations);

    if (User.get(userMap, caller) == null) {
      Log.add(logMap, #Member, "Member " # Principal.toText(caller) # " has been Added SuccessFully!");
    } else {
      Log.add(logMap, #Member, "Member " # Principal.toText(caller) # " has been Updated SuccessFully!");
    };

    return "Wellcome!";

  };

  public shared ({ caller }) func hireOrUpdateEmployee(principal : Principal, role : User.UserRole, allowedOperations : [User.Operation]) : async Result.Result<(Text), Text> {
    if (User.employeeCanPerform(employeeMap, caller, #Hire) != true) {
      return #err("The caller " # Principal.toText(caller) # " havent Opration for this func");
    };
    //check if principal is a user or not ! must first user add to system first;
    switch (Map.get(userMap, phash, principal)) {
      case (null) {
        Log.add(logMap, #Personnel, "" #Principal.toText(caller) # " couldn't hire " # Principal.toText(principal) # " becuse didn't have an account in the system!");
        return #err("" #Principal.toText(principal) # " Must create an account on the system !");
      };
      case (?is) {

        User.hire(employeeMap, principal, role, is.name, is.email, is.number, is.image, allowedOperations);
        Log.add(logMap, #Personnel, "" #Principal.toText(caller) # " hire or updated new Employee by  " # Principal.toText(principal) # "!");
        return #ok("Success");
      };
    };
  };

  public shared query func getUser(p : Principal) : async ?User.User {
    return User.get(userMap, p);
  };

  public shared query func getAllUser() : async [User.User] {
    return Iter.toArray(Map.vals<Principal, User.User>(userMap));
  };

  public shared query func getEmployee(p : Principal) : async ?User.Employee {
    return Map.get(employeeMap, phash, p);
  };

  public shared query func getAllEmployee() : async [User.Employee] {
    return Iter.toArray(Map.vals<Principal, User.Employee>(employeeMap));
  };

  //----------------- Table Functions -----------------//

  stable var tableMap : Table.TableMap = Map.new<Nat, Table.Table>();

  public shared ({ caller }) func addTableNew(tableNumber : Nat, capacity : Nat) : async Result.Result<(Text), Text> {
    if (User.employeeCanPerform(employeeMap, caller, #ModifyTable) != true) {
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

  ////_________________________NOTE______________________\\\\
  // When this function is called and results in an error, the employee must be notified.
  // The table you're trying to access is reserved.
  // Do you want to request to join this table? This will call the SeatOnTable function.
  public shared ({ caller }) func reserveTableNew(tableId : Nat) : async Result.Result<Text, Text> {
    if (User.userCanPerform(userMap, caller, #ReserveTable) != true) {
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

  public shared ({ caller }) func seatOnTable(tableId : Nat) : async Result.Result<Text, Text> {
    if (Table.isReserved(tableMap, tableId) != true) {
      return #err("This table already open for Reserve");
    };

    Table.requestToJoinTable(tableMap, tableId, caller);
    return #ok("requst sent ! wait for Reserver response");

  };

  public shared ({ caller }) func unreserveTableNew(tableId : Nat) : async Result.Result<Text, Text> {
    if (Table.canUnreserveTable(employeeMap, tableMap, caller, tableId) != true) {
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

  public shared query ({ caller }) func getRequstesJoinToTable(tableId : Nat) : async Result.Result<[Principal], Text> {
    if (Table.canUnreserveTable(employeeMap, tableMap, caller, tableId) != true) {
      return #err("this member " #Principal.toText(caller) # " didnt Reserve table " #Nat.toText(tableId) # "!");
    };
    var users : [Principal] = [];
    switch (Table.get(tableMap, tableId)) {
      case (?table) {
        switch (table.userWantsToJoin) {
          case (is) {
            users := is;
            return #ok(users);
          };
        };
      };
      case (null) {
        return #err("there is no request item");
      };
    };
  };

  public shared ({ caller }) func addguestTotable(tableId : Nat, p : Principal, yesOrNo : Bool) : async Result.Result<[Principal], Text> {
    if (Table.canUnreserveTable(employeeMap, tableMap, caller, tableId) != true) {
      return #err("this member " #Principal.toText(caller) # " didnt Reserve the table " #Nat.toText(tableId) # "!");
    };
    switch (Table.addGustToTable(tableMap, tableId, p)) {
      case (seatedUsers) {
        return #ok(seatedUsers);
      };
    };

  };

  //----------------- Menu Functions -----------------//

  stable var menuMap : Menu.MenuMap = Map.new<Nat, Menu.MenuItem>();

  public shared ({ caller }) func addMenuItem(newMenuItem : Menu.NewMenuItem) : async Result.Result<Text, Text> {
    if (User.employeeCanPerform(employeeMap, caller, #ModifyMenuItem) != true) {
      return #err("The caller " #Principal.toText(caller) # " dose not have permission to add menu item!");
    };
    Menu.new(menuMap, newMenuItem);
    Log.add(logMap, #Menu, "New Menu with id " #Nat.toText(Map.size(menuMap)) # " Added By " #Principal.toText(caller) # "!");
    return #ok("Menu Added Successfully");
  };

  public shared ({ caller }) func updateMenuItem(menuId : Nat, newMenuItem : Menu.NewMenuItem) : async Result.Result<Text, Text> {
    if (User.employeeCanPerform(employeeMap, caller, #ModifyMenuItem) != true) {
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
    if (User.employeeCanPerform(employeeMap, caller, #ModifyMenuItem) != true) {
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

  //--------------------------- Review Functions ----------------------------\\

  public shared ({ caller }) func addOrUpdateItemScore(menuId : Nat, star : Review.Star, suggest : Bool, comment : ?Text, image : ?[Blob]) : async Result.Result<Text, Text> {
    if (User.userCanPerform(userMap, caller, #ModifyMenuItemPoint) != true) {
      return #err("The caller " #Principal.toText(caller) # " dose not have permission to Review an item create a account first or login to your account!");
    };

    switch (Menu.get(menuMap, menuId)) {
      case null {
        return #err("The menu item  " #Nat.toText(menuId) # " does not exist!");
      };

      case (?menuItem) {

        if (Menu.hasPoint(menuMap, menuId, caller) == true) {
          let newPoint : Review.MenuReview = {
            id = menuId;
            comment = comment;
            pointBy = caller;
            star = star;
            suggest = suggest;
            cratedAt = Time.now();
            image = image;
          };
          let newItemScore = Menu.replaceNewItemScore(menuItem, menuId, caller, newPoint);
          Map.set(menuMap, nhash, menuId, newItemScore);
          Log.add(logMap, #MenuReview, "" #Principal.toText(caller) # " updated own Menu Review " #Nat.toText(menuId) # "!");
          return #ok("Update Success!");

        } else {

          let newMenuPoint = Buffer.fromArray<Review.MenuReview>(menuItem.score);
          newMenuPoint.add({
            id = menuId;
            comment = comment;
            pointBy = caller;
            star = star;
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
            score = Buffer.toArray(newMenuPoint);
            image = menuItem.image;
          };

          Map.set(menuMap, nhash, menuId, newMenuItem);
          Log.add(logMap, #MenuReview, "The User " #Principal.toText(caller) # " added a star to the menu item with id " #Nat.toText(menuId));
          return #ok("Review added to menu item " #Nat.toText(menuId) # "!");
        };
      };
    };
  };

  public shared ({ caller }) func addPointToEmployee(employeeId : Principal, star : Review.Star, comment : ?Text) : async Result.Result<Text, Text> {
    if (User.userCanPerform(userMap, caller, #ModifyEmployeePoints) != true) {
      return #err("the caller " #Principal.toText(caller) # " dose not have permission Review to Emoloyee,  create an account first !");
    };
    if (User.hasPoint(employeeMap, caller, employeeId) == true) {

      return #err("Member " #Principal.toText(caller) # " already have a Review this employee!");
    };
    switch (Map.get(employeeMap, phash, employeeId)) {
      case (null) {
        return #err("The employee with principal " #Principal.toText(employeeId) # " does not exist!");
      };
      case (?employee) {
        let employeeReview = Buffer.fromArray<Review.EmployeeReview>(employee.review);
        employeeReview.add({
          pointBy = caller;
          comment = comment;
          star = star;
          cratedAt = Time.now();
        });
        let updateEmployee : User.Employee = {
          name = employee.name;
          email = employee.email;
          identity = employeeId;
          number = employee.number;
          role = employee.role;
          allowedOperations = employee.allowedOperations;
          id = employee.id;
          image = employee.image;
          review = Buffer.toArray(employeeReview);
        };

        Map.set(employeeMap, phash, employeeId, updateEmployee);
        Log.add(logMap, #EmployeeReview, "" #Principal.toText(caller) # " Gave Review to employee " #Principal.toText(employeeId) # "!");

        return #ok("Review added to employee " #Principal.toText(employeeId) # " successfully!");
      };
    };
  };

  public shared ({ caller }) func editPointEmployee(employeeId : Principal, star : Review.Star, comment : ?Text, suggest : Bool) : async Result.Result<Text, Text> {
    if (User.hasPoint(employeeMap, caller, employeeId) != true) {
      return #err("This caller with principal " #Principal.toText(caller) # " does not have a star for Employee!");
    };

    let newPoint : Review.EmployeeReview = {
      pointBy = caller;
      comment = comment;
      star = star;
      cratedAt = Time.now();
    };
    let filteredPoint = User.replaceUserPointByPrincipal(employeeMap, employeeId, newPoint);
    switch (filteredPoint) {
      case (false) {
        return #err("" # Principal.toText(caller) # " have not any Review in this employee ID !");
      };
      case (true) {
        Log.add(logMap, #EmployeeReview, "" #Principal.toText(caller) # " Update their own star of employee  " #Principal.toText(employeeId) # "!");
        return #ok("Update Success!");
      };
    };

  };

  public shared ({ caller }) func iterateToEployeeByAdmin(point : Review.Star) : async Result.Result<(), Text> {
    if (User.employeeCanPerform(employeeMap, caller, #ModifyEmployeePoints) != true) {
      return #err("the caller " #Principal.toText(caller) # " dose not have permission Review to Emoloyee");
    };

    let allMembers = Map.vals<Principal, User.Employee>(employeeMap);
    for (member in allMembers) {
      let newPoint : Review.EmployeeReview = {
        pointBy = caller;
        comment = null;
        star = point;
        cratedAt = Time.now();
      };

      let employeeReview = Buffer.fromArray<Review.EmployeeReview>(member.review);
      employeeReview.add(newPoint);

      let updateEmployee : User.Employee = {
        name = member.name;
        identity = member.identity;
        email = member.email;
        number = member.number;
        role = member.role;
        allowedOperations = member.allowedOperations;
        id = member.id;
        image = member.image;
        review = Buffer.toArray(employeeReview);
      };

      Map.set(employeeMap, phash, member.identity, updateEmployee);
    };

    return #ok();
  };
};

// //member
// //systeme ray giri baraye ezafe kardan va hazf kardane menu va khadamat
// //systeme emtiyaz dehi be karmandan
// //systeme emtiaz dehi be menu va item;
// // ezafe kardane map be factorhaye principal ... ya table
// // ezafe kardane reserve table baraye time moshakhas va time hodudi
