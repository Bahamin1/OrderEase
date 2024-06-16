import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Map "mo:map/Map";
import { phash } "mo:map/Map";

import Cart "Cart";
import Point "Point";

// Define the enum for different operations
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

    public type User = {
        name : Text;
        principal : Principal;
        role : UserRole;
        allowedOperations : [Operation];
        id : Nat;
        image : ?Blob;
        buyingScore : Nat8;
        point : [Point.EmployeePoint];
        order : ?Cart.Order;
    };

    public type UserMap = Map.Map<Principal, User>;

    //// Get User
    public func get(userMap : UserMap, principal : Principal) : ?User {
        return Map.get(userMap, phash, principal);
    };

    //// put User
    public func put(userMap : UserMap, p : Principal, user : User) : () {
        return Map.set(userMap, phash, p, user);
    };

    ///// add New user specefic with oprations
    public func new(userMap : UserMap, principal : Principal, name : Text, role : UserRole, allowedOperations : [Operation]) : () {
        let id = Map.size(userMap) +1;

        let user : User = {
            name = name;
            principal = principal;
            role = role;
            allowedOperations = allowedOperations;
            id = id;
            image = null;
            buyingScore = 0;
            point = [];
            order = null;
        };

        put(userMap, principal, user);

        return;
    };

    public func canPerform(userMap : UserMap, p : Principal, operation : Operation) : Bool {
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

    public func hasPoint(userMap : UserMap, caller : Principal, employeeId : Principal) : Bool {
        let user = get(userMap, employeeId);

        switch (user) {
            case (null) {
                return false;
            };
            case (?user) {
                for (point in user.point.vals()) {
                    if (point.pointBy == caller) {
                        return true;
                    };
                };
            };

        };
        return false;
    };

    public func replaceUserPointByPrincipal(userMap : UserMap, employeeId : Principal, newPoint : Point.EmployeePoint) : Bool {
        switch (get(userMap, employeeId)) {
            case (?user) {
                // Filter out the specific MenuPoint
                let updatedPoints = Array.filter<Point.EmployeePoint>(
                    user.point,
                    func(point) {
                        point.pointBy != employeeId;
                    },
                );

                // Add the new MenuPoint
                let newPoints = Array.append<Point.EmployeePoint>(updatedPoints, [newPoint]);

                // Update the Menuuser with the new points array

                let updateduser : User = {
                    name = user.name;
                    principal = user.principal;
                    role = user.role;
                    allowedOperations = user.allowedOperations;
                    id = user.id;
                    image = user.image;
                    buyingScore = user.buyingScore;
                    point = newPoints;
                    order = null;

                };
                put(userMap, employeeId, updateduser);
                return true;
            };
            case null { return false };
        };
    };
};
