import Principal "mo:base/Principal";
import Map "mo:map/Map";
import { phash } "mo:map/Map";
import T "Types";

// Define the enum for different operations
module {
    public type UserRole = {
        #Guest;
        #Customer;
        #Employee;
        #Manager;
        #Admin
    };

    public type User = {
        name : Text;
        principal : Principal;
        role : UserRole;
        allowedOperations : [T.Operation];
        id : Nat;
        image : ?Blob;
        points : Nat;
        orders : [T.Order]
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
    public func new(userMap : UserMap, principal : Principal, name : Text, role : UserRole, allowedOperations : [T.Operation]) : UserMap {
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

    public func canPerform(userMap : UserMap, p : Principal, operation : T.Operation) : Bool {
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
