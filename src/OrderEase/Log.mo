import Array "mo:base/Array";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash } "mo:map/Map";

import Types "Types";
import User "User";

module {

    public type Log = {
        id : Nat;
        message : Text;
        createdAt : Time.Time;
        catagory : Catagory;
    };

    public type Catagory = {
        #Message;
        #Member;
        #Table;
        #Menu;
        #Order;
        #EmployeeReview;
        #MenuReview;
        #Personnel;
    };

    public type LogMap = Map.Map<Nat, Log>;

    public func put(logMap : LogMap, key : Nat, value : Log) : () {
        return Map.set(logMap, nhash, key, value);
    };

    public func add(logMap : LogMap, catagory : Catagory, message : Text) : () {
        let id = Map.size(logMap) +1;

        let newLog : Log = {
            id = id;
            message = message;
            createdAt = Time.now();
            catagory = catagory;
        };

        put(logMap, id, newLog);

        return;
    };

    public func getLogsByCategory(logMap : LogMap, per : Catagory) : [Log] {

        var filteredLogs : [Log] = [];

        for (cata in Map.vals(logMap)) {
            switch (cata.catagory) {
                case (is) {

                    if (is == per) {
                        filteredLogs := Array.append<Log>(filteredLogs, [cata]);
                    };
                };
            };
        };
        return filteredLogs;

    };

    public func userRoleToText(role : Types.UserRole) : Text {
        switch (role) {
            case (#Guest) { "Guest" };
            case (#Customer) { "Customer" };
            case (#Employee) { "Employee" };
            case (#Manager) { "Manager" };
            case (#Admin) { "Admin" };
        };
    };

    public func catagoryToText(cat : Catagory) : Text {
        switch (cat) {
            case (#Message) { "Message" };
            case (#Member) { "Member" };
            case (#Table) { "Table" };
            case (#Menu) { "Menu" };
            case (#Order) { "Order" };
            case (#EmployeeReview) { "EmployeeReview" };
            case (#MenuReview) { "MenuReview" };
            case (#Personnel) { "Personnel" };
        };
    };

    public func memberNameAndRoleToText(userMap : User.UserMap, member : Principal) : Text {
        switch (User.get(userMap, member)) {
            case (?user) {
                "Name " #user.name # " with role " #userRoleToText(user.role) # "";
            };
            case (null) { "" };
        };
    };

};
