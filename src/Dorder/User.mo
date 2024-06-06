import Array "mo:base/Array";
import Char "mo:base/Char";
import Error "mo:base/Error";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Map "mo:map/Map";
import { nhash; phash } "mo:map/Map";

// Define the enum for different operations
module {

    public type UserRole = {
        #Guest;
        #Customer;
        #Employee;
        #Manager;
        #Admin;
    };
    public type AdminOperation = {
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
        #ModifyEmployeePoints;
    };

    public type Operation = {
        #ReserveTable;
        #UnreserveTable;
        #PayTable;
        #HireEmployee;
        #FireEmployee;
        #AddMenuItem;
        #RemoveMenuItem;
        #UpdateMenuItem;
        #ViewReports;
        #ModifyEmployeePoints;
    };

    public type MenuItem = {
        id : Nat;
        name : Text;
        price : Nat;
    };

    public type User = {
        name : Text;
        principal : Principal;
        role : UserRole;
        allowedOperations : [Operation];
        id : Nat;
        image : ?Blob;
        points : Nat;
        cart : [MenuItem];
    };

    public type UserMap = Map.Map<Principal, User>;

    //// Get User
    public func get(users : UserMap, principal : Principal) : ?User {
        return Map.get(users, phash, principal);
    };

    //// put User
    public func put(users : UserMap, p : Principal, user : User) : () {
        return Map.set(users, phash, p, user);
    };

    ///// add New user specefic with oprations
    public func new(users : UserMap, principal : Principal, name : Text, role : UserRole, allowedOperations : [Operation]) : UserMap {
        let id = Map.size(users) +1;

        let user : User = {
            name = name;
            principal = principal;
            role = role;
            allowedOperations = allowedOperations;
            id = id;
            image = null;
            points = 0;
            cart = [];
        };

        Map.set(users, phash, principal, user);

        return users;
    };
    //// Check user can call function and have opration for that...
    public func canPerform(user : User, operation : AdminOperation) : Bool {
        if (user.role == #Admin) return true;

        for (o in user.allowedOperations.vals()) {
            if (operation == o) return true;
        };

        return false;
    };

};
