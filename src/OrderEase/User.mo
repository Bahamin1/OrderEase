import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Map "mo:map/Map";
import { phash } "mo:map/Map";

import Review "Review";
import Types "Types";

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
        #CanTakeAway;
        #PayTable;
        #MonitorLogs;
        #Hire;
        #Fire;
        #ModifyTable;
        #ModifyMenuItem;
        #ModifyMenuItemPoint;
        #ModifyEmployeePoints;
    };

    public type User = {
        //must added address for user
        id : Nat;
        name : Text;
        number : Nat;
        email : Text;
        allowedOperations : [Operation];
        role : UserRole;
        reviewPoint : Nat;
        buyingScore : Nat;
        image : ?Blob;
        order : [Types.CartItem];
    };

    public type Employee = {
        id : Nat;
        identity : Principal;
        name : Text;
        number : Nat;
        email : Text;
        role : UserRole;
        allowedOperations : [Operation];
        image : ?Blob;
        review : [Review.EmployeeReview];
    };

    public type UserMap = Map.Map<Principal, User>;
    public type EmployeeMap = Map.Map<Principal, Employee>;

    // Get Employee
    public func get(userMap : UserMap, principal : Principal) : ?User {
        return Map.get(userMap, phash, principal);
    };

    // put Employee
    public func put(userMap : UserMap, p : Principal, user : User) : () {
        return Map.set(userMap, phash, p, user);
    };

    // add New user specefic with oprations
    public func new(userMap : UserMap, principal : Principal, name : Text, email : Text, role : UserRole, number : Nat, image : ?Blob, allowedOperations : [Operation]) : () {
        let id = Map.size(userMap) +1;
        switch (get(userMap, principal)) {
            case (null) {

                let user : User = {
                    id = id;
                    name = name;
                    email = email;
                    number = number;
                    allowedOperations = allowedOperations;
                    role = role;
                    image = image;
                    reviewPoint = 0;
                    buyingScore = 0;
                    order = [];
                };

                put(userMap, principal, user);

                return;

            };
            case (?user) {

                let updateUser : User = {
                    id = user.id;
                    name = name;
                    number = number;
                    email = email;
                    image = image;
                    allowedOperations = user.allowedOperations;
                    role = user.role;
                    reviewPoint = user.reviewPoint;
                    buyingScore = user.buyingScore;
                    order = user.order;
                };

                put(userMap, principal, updateUser);
                return;
            };
        };

    };

    public func hire(employeeMap : EmployeeMap, p : Principal, role : UserRole, name : Text, email : Text, number : Nat, image : ?Blob, allowedOperations : [Operation]) : () {
        let employee = Map.get(employeeMap, phash, p);
        let id = Map.size(employeeMap) +1;
        switch (employee) {
            case (null) {
                let newEmployee : Employee = {
                    id = id;
                    identity = p;
                    name = name;
                    number = number;
                    email = email;
                    role = role;
                    allowedOperations = allowedOperations;
                    image = image;
                    review = [];
                };
                Map.set(employeeMap, phash, p, newEmployee);
                return;
            };
            case (?is) {

                let updateUser : Employee = {
                    id = is.id;
                    identity = is.identity;
                    name = is.name;
                    number = is.number;
                    email = is.email;
                    role = role;
                    allowedOperations = allowedOperations;
                    image = image;
                    review = is.review;
                };
                Map.set(employeeMap, phash, p, updateUser);
                return;
            };
        };

    };

    public func employeeCanPerform(employeeMap : EmployeeMap, p : Principal, operation : Operation) : Bool {
        let user = Map.get(employeeMap, phash, p);

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

    public func userCanPerform(userMap : UserMap, p : Principal, operation : Operation) : Bool {
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

    public func hasPoint(employeeMap : EmployeeMap, caller : Principal, employeeId : Principal) : Bool {
        let user = Map.get(employeeMap, phash, employeeId);

        switch (user) {
            case (null) {
                return false;
            };
            case (?user) {
                for (review in user.review.vals()) {
                    if (review.pointBy == caller) {
                        return true;
                    };
                };
            };

        };
        return false;
    };

    public func replaceUserPointByPrincipal(employeeMap : EmployeeMap, employeeId : Principal, newPoint : Review.EmployeeReview) : Bool {
        switch (Map.get(employeeMap, phash, employeeId)) {
            case (?employee) {
                // Filter out the specific MenuPoint
                let updatedPoints = Array.filter<Review.EmployeeReview>(
                    employee.review,
                    func(review) {
                        review.pointBy != employeeId;
                    },
                );

                // Add the new MenuPoint
                let newPoints = Array.append<Review.EmployeeReview>(updatedPoints, [newPoint]);

                // Update the new points array

                let updatedemployee : Employee = {
                    name = employee.name;
                    number = employee.number;
                    email = employee.email;
                    identity = employeeId;
                    role = employee.role;
                    allowedOperations = employee.allowedOperations;
                    id = employee.id;
                    image = employee.image;
                    review = newPoints;
                    order = null;

                };
                Map.set(employeeMap, phash, employeeId, updatedemployee);
                return true;
            };
            case null { return false };
        };
    };

};
