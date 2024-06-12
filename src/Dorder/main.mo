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

import Menu "Menu";
import Point "Point";
import Table "Table";
import Type "Types";
import User "User";

shared ({ caller = manager }) actor class Dorder() = this {

  // Users FuncTion
  stable var userMap : User.UserMap = Map.new<Principal, User.User>();

  // TODO: Replace this with Manager
  let guest : Principal = Principal.fromText("2vxsx-fae");

  User.new(userMap, guest, "ADMIN", #Admin, []);

  // Buffer loG OF Members
  var logOfMembers = Buffer.Buffer<Text>(0);
  public query func getMemberLogNew() : async [Text] {
    return Buffer.toArray(logOfMembers);
  };

  // Register User
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
        logOfMembers.add("Member with Principal " # Principal.toText(caller) # " Registered!");
        return #ok();
      };
    };
  };

  // Add manager just admin can do ....
  public shared ({ caller }) func addManager(principal : Principal, name : Text, allowedOperations : [Type.Operation]) : async Result.Result<(), Text> {
    if (User.canPerform(userMap, caller, #HireManager) != true) {
      return #err("The caller " # Principal.toText(caller) # " havent Opration for this func");
    };

    switch (User.get(userMap, principal)) {
      case (?is) {
        User.new(userMap, is.principal, is.name, #Manager, allowedOperations);
        logOfMembers.add("Member " #Principal.toText(principal) # " updated to Manager By " # Principal.toText(caller) # "!");
        return #ok();
      };
      case (null) {
        User.new(userMap, principal, name, #Manager, allowedOperations);
        logOfMembers.add("New Manager " # Principal.toText(principal) # " Added  By " # Principal.toText(caller) # "!");
        return #ok();
      };
    };
  };

  // Add employee function for anyone have opration #HireEmployee
  public shared ({ caller }) func addEmployee(principal : Principal, name : Text, allowedOperations : [Type.Operation]) : async Result.Result<(), Text> {
    if (User.canPerform(userMap, caller, #HireEmployee) != true) {
      return #err("The caller " # Principal.toText(caller) # " havent Opration for this func");
    };

    switch (User.get(userMap, principal)) {
      case (?is) {
        User.new(userMap, is.principal, is.name, #Employee, allowedOperations);
        logOfMembers.add("Member " #Principal.toText(principal) # " updated to Employee By " # Principal.toText(caller) # "!");
        return #ok();
      };
      case (null) {
        User.new(userMap, principal, name, #Employee, allowedOperations);
        logOfMembers.add("New Member " # Principal.toText(principal) # " Added By " # Principal.toText(caller) # "!");
        return #ok();
      };
    };
  };

  //Get member
  public query func getMember(p : Principal) : async ?User.User {
    let member = User.get(userMap, p);
    return member;
  };

  // Get all Members
  public query func getAllMembersNew() : async [User.User] {
    return Iter.toArray(Map.vals<Principal, User.User>(userMap));
  };

  //----------------- Table Functions -----------------//

  stable var tableMap : Table.TableMap = Map.new<Nat, Table.Table>();
  var logOfTable : Buffer.Buffer<Text> = Buffer.Buffer<Text>(0);

  // Get log Of Tables
  public shared query ({ caller }) func getTableLogs() : async [Text] {
    return Buffer.toArray(logOfTable);
  };

  // Add Tables
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
        logOfTable.add("Table " #Nat.toText(tableNumber) # " was  Added by " #Principal.toText(caller) # "!");
        return #ok(" Table  " #Nat.toText(tableNumber) # "  was Added! ");
      };
    };
  };

  // get all Table
  public shared query func getTables() : async [Table.Table] {
    return Iter.toArray(Map.vals<Nat, Table.Table>(tableMap));
  };

  // Reserve Table

  public shared ({ caller }) func reserveTableNew(tableId : Nat) : async Result.Result<Text, Text> {
    switch (Table.reserve(tableMap, tableId, caller)) {
      case (#ok(updatedTable)) {
        logOfTable.add("Table " #Nat.toText(tableId) # " was Reserved by " #Principal.toText(caller) # "!");
        return #ok("Table reserved successfully.");
      };
      case (#err(errorMessage)) {
        return #err(errorMessage);
      };
    };
  };

  public shared ({ caller }) func unreserveTableNew(tableId : Nat) : async Result.Result<Text, Text> {
    if (User.canPerform(userMap, caller, #UnreserveTable) != true) {
      return #err("The caller " #Principal.toText(caller) # " dose not Reserved this table!");
    };

    switch (Table.unreserve(tableMap, tableId)) {
      case (#ok(updatedTable)) {
        logOfTable.add("Table " #Nat.toText(tableId) # " was Unreserved by " #Principal.toText(caller) # "!");
        return #ok("Table " #Nat.toText(tableId) # " was Unreserved!");
      };
      case (#err(errorMessage)) {
        return #err(errorMessage);
      };
    };
  };

  //----------------- Menu Functions -----------------//

  var logOfMenu = Buffer.Buffer<Text>(0);
  stable var menuMap : Menu.MenuMap = Map.new<Nat, Menu.MenuItem>();

  public shared ({ caller }) func getMenuLog() : async [Text] {
    return Buffer.toArray(logOfMenu);
  };

  public shared ({ caller }) func addMenuItem(newMenuItem : Menu.NewMenuItem) : async Result.Result<Nat, Text> {
    if (User.canPerform(userMap, caller, #ModifyMenuItem) != true) {
      return #err("The caller " #Principal.toText(caller) # " dose not have permission to add menu item!");
    };
    Menu.new(menuMap, newMenuItem);
    return #ok(Map.size(menuMap));
  };

  public shared ({ caller }) func updateMenuItem(menuId : Nat, newMenuItem : Menu.NewMenuItem) : async Result.Result<Text, Text> {
    if (User.canPerform(userMap, caller, #ModifyMenuItem) != true) {
      return #err("The caller " #Principal.toText(caller) # " dose not have permission to update menu item!");
    };

    switch (Menu.update(menuMap, menuId, newMenuItem)) {
      case (#ok(msg)) {
        logOfMenu.add("Item with id " #Nat.toText(menuId) # " has been updated by " #Principal.toText(caller) # ".");
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
    logOfMenu.add("Item with id " #Nat.toText(menuId) # " has been removed from the menu by " #Principal.toText(caller) # ".");
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
        logOfMenu.add("The User " #Principal.toText(caller) # " added a point to the menu item with id " #Nat.toText(menuId));
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
          orders = user.orders;
        };
        User.put(userMap, employeeId, updateEmployee);
        logOfMembers.add("Point added to employee " #Principal.toText(employeeId) # " successfully by " #Principal.toText(caller) # ". ");
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
        return #err("" #Principal.toText(caller) # " have not any Point in this employee ID !");
      };
      case (true) {
        return #ok("Update Success!");
      };
    };

  };

  // public shared ({ caller }) func editPointItem(menuId : Nat, point : Point.Numb, comment : ?Text, suggest : Bool, image : ?[Blob]) : async Result.Result<Text, Text> {
  //   let item = Menu.get(menuMap, menuId);
  //   switch (item) {
  //     case (null) {
  //       return #err("The menu item with id " #Nat.toText(menuId) # " does not exist!");
  //     };
  //     case (?Item) {
  //       if (Menu.hasPoint(menuMap, menuId, caller) == true) {
  //         let itemUpdate : Point.MenuPoint = {
  //           id = menuId;
  //           comment = comment;
  //           pointBy = caller;
  //           point = point;
  //           suggest = suggest;
  //           cratedAt = Time.now();
  //           image = image;
  //         };
  //         Menu.updateMenuPoint(menuMap, menuId, caller, itemUpdate);
  //       };
  //       return #ok("d");

  //     };
  //   };
  // };

  /////////////////////////////////////
  ////////////////////////////////////
  ///////////////////////////////////
  //////////////////////////////////
  /////////////////////////////first manager and one employee for test ////////////
  //   stable let firstManager : Principal = Principal.fromText(" 2 vxsx -fae ");
  //   stable var firstManagerType : T.Member = {
  //     name = "Bahamin Dehpour ";
  //     identity = firstManager;
  //     role = #Admin;
  //     image = [];
  //     joined = Time.now();
  //     point = [];
  //   };

  //   stable let firstEmployee : Principal = Principal.fromText(" 7 oucc -sv7di -xco3s -ci7vx -fswgr -zq3oh -u72l5 -ivud7 -zaf46 -atexo -7 ae ");
  //   stable var firstEmployeeType : T.Member = {
  //     name = "First Employee ";
  //     identity = firstEmployee;
  //     role = #Employee;
  //     image = [];
  //     joined = Time.now();
  //     point = [];
  //   };

  //   //////////////////////////////////////////////////////////////////////////////////////
  //   stable var master = manager;
  //   //Map for product
  //   stable let productMap = Map.new<Nat, T.Product>();

  //   private stable var next_product_id : Nat = 1;

  //   func productGet(productId : Nat) : ?T.Product {
  //     return Map.get(productMap, nhash, productId);
  //   };

  //   func productPut(productId : Nat, product : T.Product) : () {
  //     return Map.set(productMap, nhash, productId, product);
  //   };

  //   // Func add products

  //   public shared ({ caller }) func addProduct(product : T.NewProduct) : async T.Product {
  //     // assert (caller == master);

  //     let newProduct : T.Product = {
  //       productID = next_product_id;
  //       name = product.name;
  //       stock = product.stock;
  //       info = product.info;
  //       fee = product.fee;
  //       image = product.image;
  //       rating = [];

  //     };
  //     productPut(next_product_id, newProduct);
  //     next_product_id += 1;
  //     return (newProduct);
  //   };

  //   //Get Product

  //   public shared query func getProducts() : async [T.Product] {
  //     return Iter.toArray(Map.vals<Nat, T.Product>(productMap));
  //   };

  //   //Edit a Product
  //   public shared ({ caller }) func editProduct(productId : Nat, updateProduct : T.NewProduct) : async Result.Result<(), Text> {
  //     // assert (caller == master);
  //     let getProduct = productGet(productId);
  //     switch (getProduct) {
  //       case (null) {
  //         return #err("Product Not Found! ");
  //       };
  //       case (?product) {
  //         let newProduct : T.Product = {
  //           productID = productId;
  //           name = updateProduct.name;
  //           stock = updateProduct.stock;
  //           info = updateProduct.info;
  //           fee = updateProduct.fee;
  //           image = updateProduct.image;
  //           rating = product.rating;

  //         };
  //         productPut(productId, newProduct);
  //         return #ok();
  //       };
  //     };
  //   };

  //   // Change Stock true or false

  //   public shared ({ caller }) func statusProduct(productId : Nat, stocked : Bool) : async Result.Result<(), Text> {
  //     // assert (caller == master);
  //     let getProduct = productGet(productId);
  //     switch (getProduct) {
  //       case (null) {
  //         return #err("Product Not Found! ");
  //       };
  //       case (?product) {
  //         let newProduct : T.Product = {
  //           productID = productId;
  //           name = product.name;
  //           stock = stocked;
  //           info = product.info;
  //           fee = product.fee;
  //           image = product.image;
  //           rating = product.rating;
  //         };
  //         productPut(productId, newProduct);
  //         return #ok();
  //       };
  //     };
  //   };

  //   //remove a Product
  //   public shared ({ caller }) func removeProduct(productId : Nat) : async Result.Result<(), Text> {
  //     // assert (caller == master);
  //     let getProduct = productGet(productId);
  //     switch (getProduct) {
  //       case (null) {
  //         return #err("Product Not Found! ");

  //       };
  //       case (?product) {

  //         Map.delete(productMap, nhash, productId);
  //         return #ok();
  //       };
  //     };
  //   };

  //   ///////////// map for accounting \\\\\\\\\\\\\\

  //   var logOfMember = Buffer.Buffer<Text>(0);

  //   stable var numberOfMember : Nat = 0;

  //   stable let membersMap = Map.new<Principal, T.Member>();

  //   func membersGet(principal : Principal) : ?T.Member {
  //     return Map.get(membersMap, phash, principal);
  //   };

  //   func membersPut(principal : Principal, member : T.Member) : () {
  //     return Map.set(membersMap, phash, principal, member);
  //   };

  //   let firstManagerAdd = membersPut(firstManager, firstManagerType);
  //   let firstEmployeeAdd = membersPut(firstEmployee, firstEmployeeType);

  //   //members Register

  //   public shared ({ caller }) func registerMember(name : Text, image : Blob) : async Result.Result<(), Text> {
  //     let member = membersGet(caller);
  //     switch (member) {
  //       case (?member) {
  //         return #err("caller already a Member! ");
  //       };
  //       case (null) {
  //         let newMember : T.Member = {
  //           name = name;
  //           identity = caller;
  //           role = #Customer;
  //           image = [image];
  //           joined = Time.now();
  //           point = [];

  //         };
  //         membersPut(caller, newMember);
  //         numberOfMember += 1;
  //         logOfMember.add("New Member  registered : " #Principal.toText(caller) # " with name : " #newMember.name # "! ");
  //         Debug.print("member successfully set ");
  //         return #ok();
  //       };

  //     };
  //   };

  //   //get all members (Admin only can call this function)
  //   public query ({ caller }) func getAllMembers() : async [T.Member] {
  //     // assert (caller == master);
  //     return Iter.toArray(Map.vals<Principal, T.Member>(membersMap));
  //   };

  //   //get Your account
  //   public shared query func getMember(p : Principal) : async Result.Result<(T.Member), Text> {
  //     switch (membersGet(p)) {
  //       case (null) {
  //         return #err("Member Not Found! ");
  //       };
  //       case (?member) {
  //         return #ok(member);
  //       };
  //     };
  //   };

  //   //update Member or change image and name

  //   public shared ({ caller }) func updateMember(name : Text, image : Blob) : async Result.Result<(), Text> {
  //     let member = membersGet(caller);

  //     switch (member) {
  //       case (null) {
  //         return #err("member not Found ");
  //       };
  //       case (?member) {
  //         let newMember : T.Member = {
  //           name = name;
  //           identity = caller;
  //           role = member.role;
  //           image = [image];
  //           joined = member.joined;
  //           point = member.point;

  //         };
  //         membersPut(caller, newMember);
  //         logOfMember.add("Member  Changed Name : " #Principal.toText(caller) # " to : " #newMember.name # "! ");
  //         Debug.print("Member Updated! ");
  //         return #ok();

  //       };
  //     };
  //   };

  //   //change rank of member only manager can call this func

  //   public shared ({ caller }) func memberRole(principal : Principal, role : T.Role) : async Result.Result<(), Text> {
  //     let getMember = membersGet(principal);
  //     let getCaller = membersGet(caller);
  //     switch (getCaller) {
  //       case (null) {
  //         return #err("caller is not a manager ");
  //       };
  //       case (?getCaller) {
  //         switch (getCaller.role) {
  //           case (#Admin) {
  //             return #ok();
  //           };
  //           case (#Manager) {
  //             return #ok();
  //           };
  //           case (#Employee) {
  //             return #err("only manager can change role ");
  //           };
  //           case (#Customer) {
  //             return #err(" only manager can change role ");
  //           };
  //           case (#VIP) {
  //             return #err(" only manager can change role ");
  //           };
  //           case (#Anonymus) {
  //             return #err(" only manager can change role ");
  //           };
  //         };
  //       };
  //     };
  //     switch (getMember) {
  //       case (null) {
  //         return #err(" member not found! ");
  //       };
  //       case (?member) {
  //         switch (member.role) {
  //           case (#Admin) {
  //             return #err("this principal is Admin ");
  //           };
  //           case (#Manager) {
  //             return #err(" This Principal is Manager! ");
  //           };
  //           case (#Employee) {
  //             return #ok();
  //           };
  //           case (#Customer) {
  //             return #ok();
  //           };
  //           case (#VIP) {
  //             return #ok();
  //           };
  //           case (#Anonymus) {
  //             return #ok();
  //           };
  //         };

  //         let updatedMember : T.Member = {
  //           name = member.name;
  //           identity = principal;
  //           role = role;
  //           image = member.image;
  //           joined = member.joined;
  //           point = member.point;
  //         };

  //         membersPut(principal, updatedMember);
  //         logOfMember.add(" : Role Changed : " # Principal.toText(principal) # " by : " #Principal.toText(caller));
  //         Debug.print("Member role changed successfully ");
  //         return #ok();
  //       };
  //     };
  //   };

  //   public query func getMembersLog() : async [Text] {
  //     return Buffer.toArray(logOfMember);
  //   };
  //   public query func getTableLog() : async [Text] {
  //     return Buffer.toArray(logOfTable);
  //   };

  //   //map for Point raiting

  //   stable var nextpointId : Nat = 1;

  //   stable let pointMap = Map.new<Principal, T.Point>();

  //   func pointGet(p : Principal) : ?T.Point {
  //     return Map.get(pointMap, phash, p);
  //   };

  //   func pointPut(p : Principal, point : T.Point) : () {
  //     return Map.set(pointMap, phash, p, point);
  //   };

  //   //member add comment and point to product , addPoint should be 1-5 stars
  //   public shared ({ caller }) func addPoint(productId : Nat, point : T.NewPoint) : async Result.Result<(), Text> {
  //     let member = membersGet(caller);
  //     let product = productGet(productId);
  //     switch (member) {
  //       case (null) {
  //         return #err("caller is not a Member! ");
  //       };
  //       case (?member) {

  //         switch (product) {

  //           case (null) {
  //             return #err(" Product Not found! ");
  //           };

  //           case (?product) {

  //             if (_hasPoint(product, caller) == true) {
  //               return #err(" this member already Commented on this product ");
  //             };

  //             let newPoint = Buffer.fromArray<T.Point>(product.rating);
  //             newPoint.add({
  //               pointId = nextpointId;
  //               userId = caller;
  //               comment = point.comment;
  //               point = point.addPoint;
  //               suggest = point.suggest;
  //               cratedAt = Time.now();
  //               image = [];
  //             });

  //             nextpointId += 1;

  //             let newProduct : T.Product = {
  //               productID = product.productID;
  //               name = product.name;
  //               stock = product.stock;
  //               info = product.info;
  //               fee = product.fee;
  //               image = product.image;
  //               rating = Buffer.toArray(newPoint);
  //             };
  //             productPut(productId, newProduct);
  //             return #ok();
  //           };
  //         };
  //       };
  //     };
  //   };
  //   ///get point for each product
  //   public query func getProductPoint(productId : Nat) : async [T.Point] {
  //     let product = productGet(productId);
  //     switch (product) {
  //       case (null) {
  //         return [];
  //       };
  //       case (?product) {
  //         return Iter.toArray<T.Point>(product.rating.vals());
  //       };
  //     };

  //   };

  //   // check member has point or not !

  //   func _hasPoint(product : T.Product, p : Principal) : Bool {
  //     for (point in product.rating.vals()) {
  //       if (point.userId == p) {
  //         return true;
  //       };
  //     };
  //     return false;
  //   };

  //   func _hasPointEmployee(member : T.Member, p : Principal) : Bool {
  //     for (point in member.point.vals()) {
  //       if (point.userId == p) {
  //         return true;
  //       };
  //     };
  //     return false;

  //   };

  //   //list of Members Pre Role

  //   public query func sortPerRole(role : T.Role) : async [T.Member] {
  //     var sort : [T.Member] = [];
  //     for (entry in Map.entries(membersMap)) do {
  //       let (_, member) = entry;
  //       if (member.role == role) {
  //         sort := [member];
  //       };
  //     };
  //     return sort;
  //   };

  //   ////////// Employee Point Map

  //   stable let employeePointMap = Map.new<Principal, T.PointForEmployee>();

  //   func employeePointGet(p : Principal) : ?T.PointForEmployee {
  //     return Map.get(employeePointMap, phash, p);
  //   };

  //   func employeePointSet(p : Principal, point : T.PointForEmployee) : () {
  //     return Map.set(employeePointMap, phash, p, point);
  //   };

  //   // list of all employee
  //   public query func listOfEmployee() : async [T.Member] {
  //     var employees : [T.Member] = [];

  //     for (entry in Map.entries(membersMap)) do {
  //       let (_, member) = entry;
  //       if (member.role == #Employee) {
  //         employees := [member];
  //       };
  //     };
  //     return employees;
  //   };
  //   /// point to employee
  //   public shared ({ caller }) func rateToEmployee(employeeId : Principal, point : Nat) : async Result.Result<(), Text> {
  //     let employee = membersGet(employeeId);
  //     switch (employee) {
  //       case (null) {
  //         return #err("Employee with this Principal not found! ");
  //       };
  //       case (?employee) {
  //         if (_hasPointEmployee(employee, caller) == true) {
  //           return #err(" member already voted this employee ");
  //         };
  //         switch (employee.role == #Employee) {
  //           case (false) {
  //             return #err("this member is not Employee ");
  //           };
  //           case (true) {
  //             let newPoint = Buffer.fromArray<T.PointForEmployee>(employee.point);
  //             newPoint.add({
  //               userId = caller;
  //               point = point;
  //               cratedAt = Time.now();
  //             });

  //             let updateMember : T.Member = {
  //               name = employee.name;
  //               identity = employee.identity;
  //               role = employee.role;
  //               image = employee.image;
  //               joined = employee.joined;
  //               point = Buffer.toArray(newPoint);
  //             };
  //             membersPut(employeeId, updateMember);
  //             return #ok();
  //           };
  //         };
  //       };
  //     };
  //   };

  //   public query func pointsOfEmployee(employeeId : Principal) : async [T.PointForEmployee] {
  //     let id = membersGet(employeeId);
  //     switch (id) {
  //       case (null) {
  //         return [];
  //       };
  //       case (?id) {
  //         return Iter.toArray<T.PointForEmployee>(id.point.vals());
  //       };
  //     };
  //   };
  //   public query func calculatePointsOfEmployee(p : Principal) : async (Nat, Float) {
  //     let id = membersGet(p);
  //     var employee : [T.PointForEmployee] = [];
  //     var sum : Nat = 0;
  //     var count : Nat = 0;
  //     var avg : Float = 0.0;

  //     for (entry in Map.entries(membersMap)) {
  //       let (_, id) = entry;
  //       for (point in id.point.vals()) {
  //         sum += point.point;
  //         count += 1;
  //       };
  //     };
  //     if (count != 0) {
  //       avg := Float.fromInt(sum) / Float.fromInt(count);
  //     };
  //     return (sum, avg);
  //   };

  //   /////////////// Map For Table ////////////
  //   stable let table = Map.new<Nat, T.Table>();

  //   func tableGet(n : Nat) : ?T.Table {
  //     return Map.get(table, nhash, n);
  //   };

  //   func tablePut(n : Nat, t : T.Table) : () {
  //     return Map.set<Nat, T.Table>(table, nhash, n, t);
  //   };

  //   //////////////////////////////////////////////
  //   ////////////////Add Table Admin Function /////////////
  //   public shared ({ caller }) func addTable(tableNumber : Nat, capacity : Nat) : async Result.Result<(), Text> {
  //     // assert (caller == master);
  //     switch (tableGet(tableNumber)) {
  //       case (?table) {
  //         return #err("This Table Already Added ");
  //       };
  //       case (null) {

  //         let newTable : T.Table = {
  //           tableNumber = tableNumber;
  //           capacity = capacity;
  //           avability = true;
  //           reservedBy = null;
  //           comment = null;
  //           reserveTime = null;
  //           cart = null;
  //         };

  //         tablePut(tableNumber, newTable);
  //         logOfTable.add("the Table " # Nat.toText(tableNumber) # " was added by " # Principal.toText(caller) # " ");
  //         return #ok();
  //       };
  //     };

  //   };

  //   public shared query func getTables() : async [T.Table] {
  //     return Iter.toArray(Map.vals(table));
  //   };

  //   public shared ({ caller }) func removeTable(n : Nat) : async () {
  //     switch (tableGet(n)) {
  //       case (null) {
  //         return;

  //       };
  //       case (?is) {
  //         return Map.delete<Nat, T.Table>(table, nhash, n);
  //       };
  //     };
  //   };

  //   var logOfTable = Buffer.Buffer<Text>(0);

  //   public shared ({ caller }) func reserveTable(n : Nat, cm : ?Text) : async Result.Result<(), Text> {
  //     let member = membersGet(caller);
  //     let table = tableGet(n);
  //     switch (member) {
  //       case (null) {
  //         return #err("Member not found! ");
  //       };
  //       case (?member) {
  //         if (member.role == #Anonymus) {
  //           return #err("anonymus members cant reserve tableMap ");
  //         } else {
  //           switch (table) {
  //             case (null) {
  //               return #err(" Table Not Found! ");
  //             };
  //             case (?table) {
  //               if (table.avability != true) {
  //                 return #err("this table already Reserved ");
  //               } else {
  //                 let updateTable : T.Table = {
  //                   tableNumber = n;
  //                   capacity = table.capacity;
  //                   avability = false;
  //                   reservedBy = ?caller;
  //                   comment = cm;
  //                   reserveTime = ?Time.now();
  //                   cart = null;
  //                 };
  //                 tablePut(n, updateTable);
  //                 logOfTable.add("Table " # Nat.toText(n) # " Reserved by id " # Principal.toText(caller) # " ");

  //                 return #ok();

  //               };

  //             };
  //           };
  //         };
  //       };
  //     };
  //   };

  //   public shared ({ caller }) func removeReserve(n : Nat) : async Result.Result<(), Text> {
  //     let member = membersGet(caller);
  //     let table = tableGet(n);
  //     switch (table) {
  //       case (null) {
  //         return #err("this Table not exist! ");
  //       };
  //       case (?is) {
  //         if (is.avability == true) {
  //           return #err("table already available ");
  //         };
  //         if (is.reservedBy != ?caller) {
  //           switch (member) {
  //             case (null) {
  //               return #err("member dosen 't exist! ");
  //             };
  //             case (?member) {
  //               if (member.role != #Manager) {

  //                 return #err("only reserver and Manager can change this ");
  //               };
  //             };
  //           };
  //         };
  //         let updateTable : T.Table = {
  //           tableNumber = n;
  //           capacity = is.capacity;
  //           avability = true;
  //           reservedBy = null;
  //           comment = null;
  //           reserveTime = null;
  //           cart = null;
  //         };
  //         tablePut(n, updateTable);
  //         logOfTable.add("Table " # Nat.toText(n) # " removed Reserve by id " # Principal.toText(caller) # " from Reserve ");
  //         return #ok();

  //       };
  //     };
  //   };

  //   ///////////////////////// CART Functions //////////////

  //   //////////////// cart Map //////////
  //   let productCartMap : T.ProductsCartMap = HashMap.HashMap<Nat, T.CartProduct>(0, Nat.equal, Hash.hash);
  //   let cartMap : T.CartMap = HashMap.HashMap<Principal, T.Cart>(0, Principal.equal, Principal.hash);

  //   func cartGet(buyer : Principal) : ?T.Cart {
  //     return cartMap.get(buyer);
  //   };

  //   func cartPut(buyer : Principal, cart : T.Cart) : () {
  //     cartMap.put(buyer, cart);
  //   };

  //   func cartGetProducts(buyer : Principal) : Iter.Iter<T.CartProduct> {
  //     let cart = cartGet(buyer);
  //     switch (cart) {
  //       case (null) {
  //         return Buffer.Buffer<T.CartProduct>(0).vals();
  //       };
  //       case (?cart) {
  //         return cart.products.vals();
  //       };
  //     };
  //   };

  //   func cartAddProduct(buyer : Principal, product_id : Nat, quantity : Nat) : () {
  //     let cart = cartGet(buyer);

  //     switch (cart) {
  //       case (null) {
  //         return;
  //       };
  //       case (?cart) {
  //         let cartProduct : T.CartProduct = {
  //           productId = product_id;
  //           quantity = quantity;
  //           createdAt = Time.now();
  //         };

  //         cart.products.put(product_id, cartProduct);

  //         cartPut(buyer, cart);
  //       };
  //     };
  //   };

  //   public shared ({ caller }) func addToCart(tableNumber : Nat, productId : Nat, quantity : Nat) : async Result.Result<Nat, Text> {
  //     let product = productGet(productId);
  //     // switch (await reserveTable(tableNumber, ?"In Person ")) {
  //     //   case () {};
  //     //   case () {};
  //     // };

  //     switch (product) {
  //       case (null) {
  //         return #err(" Product not found ");
  //       };
  //       case (?product) {
  //         if (product.stock != true) {
  //           return #err("Product Not Available ");
  //         };

  //         let tableCart = cartGet(caller);

  //         switch (tableCart) {
  //           case (null) {
  //             let cart : T.Cart = {
  //               products = HashMap.HashMap<Nat, T.CartProduct>(1, Nat.equal, Hash.hash);
  //               createdAt = Time.now();
  //             };

  //             cartPut(caller, cart);

  //             cartAddProduct(caller, productId, quantity);

  //             return #ok(productId);
  //           };
  //           case (?cart) {
  //             cartAddProduct(caller, productId, quantity);

  //             return #ok(productId);
  //           };
  //         };
  //       };
  //     };
  //   };

  //   ////////////////////////primision  Map

  //   let rolePermissions : [(T.Role, T.Permission)] = [
  //     (#Admin, #VeryHigh),
  //     (#Manager, #High),
  //     (#Employee, #Medium),
  //     (#Customer, #Low),
  //     (#VIP, #High),
  //   ];

  //   // Function to get the role of a principal
  //   func getRole(principal : Principal) : async ?T.Role {
  //     let member = membersGet(principal);
  //     switch (member) {
  //       case (null) {
  //         return null;
  //       };
  //       case (?member) {

  //         return ?member.role;

  //       };
  //     };
  //   };

  //   // Function to get the permission level of a role
  //   func getPermission(role : T.Role) : async ?T.Permission {
  //     for ((r, permission) in rolePermissions.vals()) {
  //       if (r == role) return ?permission;
  //     };
  //     return null;
  //   };

  //   // Check if the principal has the required permission level
  //   public func hasPermission(principal : Principal, requiredPermission : T.Permission) : async Bool {
  //     switch (await getRole(principal)) {
  //       case (?role) {
  //         switch (await getPermission(role)) {
  //           case (?permission) {
  //             switch (permission, requiredPermission) {
  //               case (#High, _) { return true };
  //               case (#Medium, #Low) { return true };
  //               case (#Medium, #Medium) { return true };
  //               case (#Low, #Low) { return true };
  //               case _ { return false };
  //             };
  //           };
  //           case null { return false };
  //         };
  //       };
  //       case null { return false };
  //     };
  //   };

  //   // Example function that requires High permission level
  //   func highLevel() : async Bool {
  //     let caller = Principal.fromActor(this);
  //     if (await hasPermission(caller, #High)) {
  //       return true;
  //     } else {
  //       return false;
  //     };
  //   };

  //   // Example function that requires Medium permission level
  //   func mediumLevel() : async Text {
  //     let caller = Principal.fromActor(this);
  //     if (await hasPermission(caller, #Medium)) {
  //       return "Medium level access granted! ";
  //     } else {
  //       return " Access denied! ";
  //     };
  //   };

  //   // Example function that requires Low permission level
  //   func lowLevel() : async Text {
  //     let caller = Principal.fromActor(this);
  //     if (await hasPermission(caller, #Low)) {
  //       return "Low level access granted! ";
  //     } else {
  //       return " Access denied! ";
  //     };
  //   };

};

// //member
// //systeme ray giri baraye ezafe kardan va hazf kardane menu va khadamat
// //systeme emtiyaz dehi be karmandan
// //systeme emtiaz dehi be menu va item;
// // ezafe kardane map be factorhaye principal ... ya table
// // ezafe kardane reserve table baraye time moshakhas va time hodudi
