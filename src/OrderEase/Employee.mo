import Map "mo:map/Map";
import { phash } "mo:map/Map";

import Review "Review";

module {

    public type UserRole = {
        #Guest;
        #Customer;
        #Employee;
        #Manager;
        #Admin;
    };

    public type Operation = {
        #ReserveTable;
        #UnreserveTable;
        #PayTable;
        #MonitorLogs;
        #HireManager;
        #FireManager;
        #HireEmployee;
        #FireEmployee;
        #ModifyTable;
        #ModifyMenuItem;
        #ModifyMenuItemPoint;
        #ModifyEmployeePoints;
    };

    public type Employee = {
        name : Text;
        principal : Principal;
        role : UserRole;
        allowedOperations : [Operation];
        id : Nat;
        image : ?Blob;
        review : [Review.EmployeeReview]

    };

    public type EmployeeMap = Map.Map<Principal, Employee>;

    public func get(userMap : EmployeeMap, principal : Principal) : ?Employee {
        return Map.get(userMap, phash, principal);
    };

    // put Employee
    public func put(userMap : EmployeeMap, p : Principal, user : Employee) : () {
        return Map.set(userMap, phash, p, user);
    };

    // add New user specefic with oprations
    public func new(userMap : EmployeeMap, principal : Principal, name : Text, role : UserRole, allowedOperations : [Operation]) : () {
        let id = Map.size(userMap) +1;

        let user : Employee = {
            name = name;
            principal = principal;
            role = role;
            allowedOperations = allowedOperations;
            id = id;
            image = null;
            buyingScore = 0;
            review = [];
            order = null;
        };

        put(userMap, principal, user);

        return;
    };

    public func canPerform(userMap : EmployeeMap, p : Principal, operation : Operation) : Bool {
        let user = get(userMap, p);

        switch (user) {
            case (null) {
                return false;
            };
            case (?user) {
                if (user.role == #Admin) return true;

                for (o in user.allowedOperations.vals()) {
                    if (operation == o) return true;
                };

                return false;
            };
        };
    };

};
