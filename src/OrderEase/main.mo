import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash; phash } "mo:map/Map";

import Cart "Cart";
import Employee "Employee";
import EvmRpc "EvmRpc";
import Log "Log";
import Menu "Menu";
import R "Reciept";
import Review "Review";
import Service "Service";
import Table "Table";
import Types "Types";
import User "User";

shared ({ caller = manager }) actor class OrderEase() = this {

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
    //////// must be return
    if (User.get(userMap, caller) == null) {
      Log.add(logMap, #Member, "Member " # Principal.toText(caller) # " has been Added SuccessFully!");
    } else {
      Log.add(logMap, #Member, "Member " # Principal.toText(caller) # " has been Updated SuccessFully!");
    };

    return "Wellcome!";

  };

  public shared ({ caller }) func hireOrUpdateEmployee(principal : Principal, role : Types.UserRole, allowedOperations : [Types.Operation]) : async Result.Result<(Text), Text> {
    if (User.employeeCanPerform(employeeMap, caller, #Hire) != true) {
      return #err("The caller " # Principal.toText(caller) # " havent Opration for this func");
    };
    //check if principal is a user or not ! must first user add to system first;
    switch (Map.get(userMap, phash, principal)) {
      case (null) {
        Log.add(logMap, #Personnel, "" #Principal.toText(caller) # " couldn't hire " # Principal.toText(principal) # " becuse didn't have an account in system!");
        return #err("" #Principal.toText(principal) # " Must create an account on the system !");
      };
      case (?is) {

        User.hire(employeeMap, principal, role, is.name, is.email, is.number, is.image, allowedOperations);
        Log.add(logMap, #Personnel, "" #Principal.toText(caller) # " hire or updated new Employee by  " # Principal.toText(principal) # "!");
        return #ok("Success");
      };
    };
  };

  public shared ({ caller }) func fireEmployee(employeeId : Principal) : async Result.Result<(), Text> {
    if (User.employeeCanPerform(employeeMap, caller, #Fire) != true) {
      return #err("The caller " # Principal.toText(caller) # " havent Opration for this func");
    };
    switch (Map.get(employeeMap, phash, employeeId)) {
      case (null) {
        return #err("Employee " #Principal.toText(caller) # "Doesnt exist");
      };
      case (?user) {
        Map.delete(employeeMap, phash, employeeId);
        return #ok();
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
  public shared ({ caller }) func reserveTable(tableId : Nat) : async Result.Result<Text, Text> {
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

  public shared ({ caller }) func unreserveTable(tableId : Nat) : async Result.Result<Text, Text> {
    if (Table.canUnreserveTable(employeeMap, tableMap, caller, tableId) != true) {
      return #err("can't unreserve table becuse caller didn't reserve any table or have finalized order ,must pay first!");
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

  public shared ({ caller }) func seatOnTable(tableId : Nat) : async Result.Result<Text, Text> {
    if (Table.isReserved(tableMap, tableId) != true) {
      return #err("This table already open for Reserve");
    };

    if (Table.hasSeat(tableMap, tableId, caller) == true) {
      return #err("Caller already seat !");
    };

    Table.requestToJoinTable(tableMap, tableId, caller);
    return #ok("requst sent ! wait for Reserver response");

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
        return #err("there is no request");
      };
    };
  };

  public shared ({ caller }) func handleGustRequest(tableId : Nat, p : Principal, canSeat : Bool) : async Result.Result<[Principal], Text> {
    if (Table.canUnreserveTable(employeeMap, tableMap, caller, tableId) != true) {
      return #err("this member " #Principal.toText(caller) # " didnt Reserve the table " #Nat.toText(tableId) # "!");
    };

    if (canSeat == true) {

      return #ok(Table.addGustToTable(tableMap, tableId, p))

    } else {
      switch (Table.get(tableMap, tableId)) {
        case (null) {
          return #err("tableNotFound");
        };
        case (?table) {
          let removedPrincipal = Array.filter<Principal>(
            table.userWantsToJoin,
            func(x) {
              x != p;
            },
          );
          let newUsers = { table with userWantsToJoin = removedPrincipal };
          Table.put(tableMap, tableId, newUsers);
          return #ok(removedPrincipal);
        };
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

  ///// must correct
  public shared ({ caller }) func removeMenuItem(menuId : Nat) : async Result.Result<Text, Text> {
    if (User.employeeCanPerform(employeeMap, caller, #ModifyMenuItem) != true) {
      return #err("The caller " #Principal.toText(caller) # " dose not have permission to remove menu item!");
    };

    if (Menu.get(menuMap, menuId) == null) {
      return #err("The menu item with id " #Nat.toText(menuId) # " does not exist!");
    };

    Map.delete(menuMap, nhash, menuId);
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

  public shared ({ caller }) func addOrUpdateMenuItemScore(menuId : Nat, star : Review.Star, suggest : Bool, comment : ?Text, image : ?[Blob]) : async Result.Result<Text, Text> {
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

  public shared ({ caller }) func addOrUpdateEmployeeScore(employeeId : Principal, star : Review.Star, comment : ?Text) : async Result.Result<Text, Text> {
    if (User.userCanPerform(userMap, caller, #ModifyEmployeePoints) != true) {
      return #err("the caller " #Principal.toText(caller) # " dose not have permission Review to Emoloyee,  create an account first !");
    };
    if (User.hasPoint(employeeMap, caller, employeeId) == true) {

      let newPoint : Review.EmployeeReview = {
        pointBy = caller;
        comment = comment;
        star = star;
        cratedAt = Time.now();
      };

      switch (User.replaceUserPointByPrincipal(employeeMap, employeeId, newPoint)) {
        case (false) {
          return #err("employee" # Principal.toText(employeeId) # " does not exist !");
        };
        case (true) {
          Log.add(logMap, #EmployeeReview, "" #Principal.toText(caller) # " Update their own Score employee  " #Principal.toText(employeeId) # "!");
          return #ok("Update Success!");
        };
      };

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

  //-----------------------------Cart Functions-------------------------------\\

  stable let cartMap = Map.new<Nat, Cart.Order>();

  public shared ({ caller }) func openOrEditCart(orderType : Cart.OrderType, items : [Cart.CartItem]) : async Result.Result<Nat, Text> {
    //check caller has Order or not ! if order is open add the order
    switch (Cart.hasOpenOrder(cartMap, caller)) {
      case (?order) {
        let amount = Cart.calculateItemsAmount(menuMap, items);
        let updateOrder : Cart.Order = {
          id = order.id;
          items = items;
          status = #Pending;
          orderBy = order.orderBy;
          totalAmount = ?amount;
          stage = #Open;
          orderType = orderType;
          createdAt = Time.now();
          isPaid = false;
        };
        Cart.put(cartMap, order.id, updateOrder);
        return #ok(order.id);
      };
      case (null) {};
    };

    let newOrder = Cart.new(menuMap, cartMap, caller, orderType, items);
    return #ok(newOrder);
  };

  public shared query ({ caller }) func getOpenCart() : async ?Cart.Order {
    return Cart.hasOpenOrder(cartMap, caller);
  };

  public shared ({ caller }) func finalizedCart(orderId : Nat) : async Result.Result<Text, Text> {

    switch (Cart.get(cartMap, orderId)) {
      case (null) {
        return #err("Order not found");
      };
      case (?cart) {
        if (cart.orderBy != caller) {
          return #err("this order is not for this caller!");
        };
        if (cart.stage == #Finalized) {
          return #err("Order is already finalized");
        };

        for (element in cart.items.vals()) {
          switch (Menu.get(menuMap, element.itemId)) {
            case (?is) {
              if (is.stock != true) {
                return #err("Item " #is.name # " is out of stock");
              };
            };
            case (null) {
              return #err("Item not found");
            };

          };

        };

        let newReciept : R.Reciept = {
          txId = next_receipt_id;
          amount : Nat;
          createdAt : Int;
          buyer : Principal;
          address : Text;
          txHash : Text;
          processed : Bool;
          payWith : ?PaymentMethod;
        };

        let finalizedOrder = { cart with stage = #Finalized };

        R.put(recieptMap, next_receipt_id) Cart.put(cartMap, orderId, finalizedOrder);
        return #ok("order was finalized");
      };
    };
  };

  ///////////////////////// Notification \\\\\\\\\\\\\\\\\\\\\

  stable var messages : [Service.Message] = [];
  stable var notifyId : Nat = 0;

  public shared ({ caller }) func sendNotify(notifyTo : Types.UserRole, msg : Text) : async Result.Result<Nat, Text> {
    if (User.employeeCanPerform(employeeMap, caller, #SendNotify) != true) {
      return #err("Caller have not opration ");
    };

    messages := Array.append<Service.Message>(messages, [{ message = msg; messageId = notifyId; by = caller; to = notifyTo }]);

    Log.add(logMap, #Message, "Notification " #Nat.toText(notifyId) # " Sent To " #Log.userRoleToText(notifyTo) # " By " # Log.memberNameAndRoleToText(userMap, caller) # ".");
    notifyId += 1;
    return #ok(notifyId -1);

  };

  public shared query ({ caller }) func getMessage() : async [Service.Message] {
    var msg : [Service.Message] = [];
    switch (User.get(userMap, caller)) {
      case (null) {
        return [];
      };
      case (?user) {
        switch (user.role) {
          case (role) {
            for (element in messages.vals()) {
              if (element.to == role) {
                msg := Array.append<Service.Message>(msg, [element]);
              };
            };
          };
        };

        return msg;
      };
    };
  };

  public shared ({ caller }) func removeMessageById(id : Nat) : async Text {
    if (User.employeeCanPerform(employeeMap, caller, #SendNotify)) {
      return ("Caller have not opration");
    };
    for (element in messages.vals()) {
      if (element.messageId == id) {
        messages := Array.filter<Service.Message>(messages, func(message : Service.Message) { element.messageId != id });
      };
    };
    Log.add(logMap, #Message, "Notification " #Nat.toText(id) # " Removed By " # Log.memberNameAndRoleToText(userMap, caller) # ".");
    return ("message Deleted");
  };

  ////////////////// Reciept \\\\\\\\\\\\\\\\\\
  stable var recieptMap = Map.new<Nat, R.Receipt>();
  private stable var next_reciept_id : Nat = 0;

  public func getReceipt(txId : Nat) : async ?R.Receipt {
    return R.recieptGet(recieptMap, txId);
  };

  public shared ({ caller }) func getReciepts() : async [R.Receipt] {

    assert (User.employeeCanPerform(employeeMap, caller, #ModifyReciept) != true);
    /// test
    if (User.employeeCanPerform(employeeMap, caller, #ModifyReciept) != true) {
      Debug.trap("caller havent opration");
    };
    return Iter.toArray(Map.vals<Nat, R.Receipt>(recieptMap));
  };

  public shared func getTransactionReceipt(txHash : Text) : async ?EvmRpc.TransactionReceipt {
    return await EvmRpc.getTransactionReceipt(txHash);
  };

  // Verify reciept
  private stable var next_receipt_id : Nat = 0;
  public shared ({ caller }) func verifyTransaction(txHash : Text) : async Result.Result<(Nat, Text, Nat, Nat), Text> {
    let cart = R.get(cartMap, caller);

    if (processed_transaction_exists(txHash)) {
      return #err("Transaction already processed");
    };

    let receipt = await getTransactionReceipt(txHash);

    processed_transaction_put(txHash);

    switch (receipt) {
      case (null) {
        return #err("Transaction not found");
      };
      case (?receipt) {
        if (receipt.to != EthUtils.MINTER_ADDRESS) {
          Debug.trap("Transaction to wrong address");
        };

        let log = receipt.logs[0];

        if (log.address != EthUtils.MINTER_ADDRESS) {
          Debug.trap("Log from wrong address");
        };

        let principal = await canisterDepositPrincipal();
        let log_principal = Text.toLowercase(log.topics[2]);

        if (log_principal != principal) {
          Debug.trap("Principal does not match");
        };

        let txId = next_receipt_id;
        next_receipt_id += 1;

        let status = receipt.status;
        let amount = EthUtils.hexToNat(log.data);
        let address = EthUtils.hexToEthAddress(log.topics[1]);

        return #ok(status, address, amount, txId);

        let reciept : T.Receipt = {
          txId = txId;
          txHash = txHash;
          address = address;
          buyer = caller;
          amount = amount;
          createdAt = Time.now();
        };

        recieptPut(txId, reciept);

        return #ok(status, address, amount, txId);
      };
    };
  };

  // Pay for the cart
  public shared ({ caller }) func pay(hash : Text) : async Result.Result<Nat, Text> {
    let cart = Cart.get(cartmap, caller);

    switch (cart) {
      case (null) {
        return #err("No cart found");
      };
      case (?cart) {
        var total : Nat = 0;

        for (cart_product in cart.products.vals()) {
          let product = productGet(cart_product.product_id);
          switch (product) {
            case (null) {
              return #err("Product not found");
            };
            case (?product) {
              total += product.price * cart_product.quantity;
            };
          };
        };

        let result = await verifyTransaction(hash);

        switch (result) {
          case (#err(err)) {
            return #err(err);
          };
          case (#ok(status, address, amount, txId)) {
            if (status != 1) {
              return #err("Transaction failed");
            };

            if (amount < total) {
              return #err("Insufficient amount");
            };

            let txId = next_receipt_id;
            next_receipt_id += 1;

            let reciept : T.Receipt = {
              txId = txId;
              txHash = hash;
              address = address;
              buyer = caller;
              amount = amount;
              createdAt = Time.now();
            };

            recieptPut(txId, reciept);

            return #ok(txId);
          };
        };
      };
    };
  };

  ///////Get the canister id as bytes\\\\\\\
  public shared func canisterDepositPrincipal() : async Text {
    let account = Principal.fromActor(this);

    let id = E.principalToBytes32(account);

    return Text.toLowercase(id);
  };

};

// //member
// //systeme ray giri baraye ezafe kardan va hazf kardane menu va khadamat
// //systeme emtiyaz dehi be karmandan
// //systeme emtiaz dehi be menu va item;
// // ezafe kardane map be factorhaye principal ... ya table
// // ezafe kardane reserve table baraye time moshakhas va time hodudi
