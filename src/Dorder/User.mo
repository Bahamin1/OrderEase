import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Map "mo:map/Map";
import { phash } "mo:map/Map";

import Cart "Cart";
import Review "Review";

// Define the enum for different operations
module {

    public type UserRole = {
        #Guest;
        #Customer;
        #Employee;
        #Manager;
        #Admin
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
        #ModifyEmployeePoints
    };

    public type User = {
        name : Text;
        email : Text;
        reviewPoint : Review.UserPoint;
        point : Review.Point;
        order : ?Cart.Order
    };

    public type UserMap = Map.Map<Principal, User>;

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

    // Get Employee
    public func get(userMap : EmployeeMap, principal : Principal) : ?Employee {
        return Map.get(userMap, phash, principal)
    };

    // put Employee
    public func put(userMap : EmployeeMap, p : Principal, user : Employee) : () {
        return Map.set(userMap, phash, p, user)
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
            order = null
        };

        put(userMap, principal, user);

        return
    };

    public func canPerform(userMap : EmployeeMap, p : Principal, operation : Operation) : Bool {
        let user = get(userMap, p);

        switch (user) {
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

    public func hasPoint(userMap : EmployeeMap, caller : Principal, employeeId : Principal) : Bool {
        let user = get(userMap, employeeId);

        switch (user) {
            case (null) {
                return false
            };
            case (?user) {
                for (review in user.review.vals()) {
                    if (review.pointBy == caller) {
                        return true
                    }
                }
            };

        };
        return false
    };

    public func replaceUserPointByPrincipal(userMap : EmployeeMap, employeeId : Principal, newPoint : Review.EmployeeReview) : Bool {
        switch (get(userMap, employeeId)) {
            case (?user) {
                // Filter out the specific MenuPoint
                let updatedPoints = Array.filter<Review.EmployeeReview>(
                    user.review,
                    func(review) {
                        review.pointBy != employeeId
                    },
                );

                // Add the new MenuPoint
                let newPoints = Array.append<Review.EmployeeReview>(updatedPoints, [newPoint]);

                // Update the Menuuser with the new points array

                let updateduser : Employee = {
                    name = user.name;
                    principal = user.principal;
                    role = user.role;
                    allowedOperations = user.allowedOperations;
                    id = user.id;
                    image = user.image;
                    review = newPoints;
                    order = null;

                };
                put(userMap, employeeId, updateduser);
                return true
            };
            case null { return false }
        }
    }
}
