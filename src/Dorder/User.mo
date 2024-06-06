import Principal "mo:base/Principal";
import Map "mo:map/Map";
import { phash } "mo:map/Map";
import Menu "Menu";

// Define the enum for different operations
module {
    public type Operation = {
        #ReserveTable;
        #UnreserveTable;
        #PayTable;
        #HireManager;
        #FireManager;
        #HireEmployee;
        #FireEmployee;
        #AddMenuItem;
        #RemoveMenuItem;
        #UpdateMenuItem;
        #ViewReports;
        #ModifyEmployeePoints
    };

    public type UserRole = {
        #Guest;
        #Customer;
        #Employee;
        #Manager;
        #Admin
    };

    public type OrderType = {
        #OnTable;
        #TakeOut
    };

    public type Order = {
        orderType : OrderType;
        items : [Menu.MenuItem]
    };

    public type User = {
        name : Text;
        principal : Principal;
        role : UserRole;
        allowedOperations : [Operation];
        id : Nat;
        image : ?Blob;
        points : Nat;
        orders : [Order]
    };

    public type UserMap = Map.Map<Principal, User>;

    //// Get User
    public func get(userMap : UserMap, principal : Principal) : ?User {
        return Map.get(userMap, phash, principal)
    };

    //// put User
    public func put(userMap : UserMap, p : Principal, user : User) : () {
        return Map.set(userMap, phash, p, user)
    };

    ///// add New user specefic with oprations
    public func new(userMap : UserMap, principal : Principal, name : Text, role : UserRole, allowedOperations : [Operation]) : UserMap {
        let id = Map.size(userMap) +1;

        let user : User = {
            name = name;
            principal = principal;
            role = role;
            allowedOperations = allowedOperations;
            id = id;
            image = null;
            points = 0;
            orders = []
        };

        Map.set(userMap, phash, principal, user);

        return userMap
    };
    //// Check user can call function and have opration for that...
    public func canPerform(user : User, operation : Operation) : Bool {
        if (user.role == #Admin) return true;

        for (o in user.allowedOperations.vals()) {
            if (operation == o) return true
        };

        return false
    };

    public func canPerformByPrincipal(userMap : UserMap, p : Principal, operation : Operation) : Bool {
        let user = get(userMap, p);

        switch user {
            case (null) {
                return false
            };
            case (?user) {
                if (user.role == #Admin) return true;

                for (o in user.allowedOperations.vals()) {
                    if (operation == o) return true
                };

                return false
            }
        }
    };

}
