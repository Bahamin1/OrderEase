import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash } "mo:map/Map";

import Cart "Cart";
import User "User";

module {

    // Table type definition
    public type Table = {
        id : Nat;
        capacity : Nat;
        reservedBy : ?Principal;
        reserveTime : ?Time.Time;
        userWantsToJoin : [Principal];
        seatedCustomers : [Principal];
        status : TableStatus;
        order : [Cart.CartItem];
    };

    public type TableStatus = {
        #Open;
        #OnOrder;
        #Finalized;
    };

    public type TableMap = Map.Map<Nat, Table>;

    /////table get from map

    public func get(tables : TableMap, key : Nat) : ?Table {
        return Map.get<Nat, Table>(tables, nhash, key);
    };

    // table put to map
    public func put(tables : TableMap, key : Nat, value : Table) : () {
        return Map.set<Nat, Table>(tables, nhash, key, value);
    };

    // Initialize tables
    public func new(tables : TableMap, tableNumber : Nat, capacity : Nat) : () {

        let table = {
            id = tableNumber;
            capacity = capacity;
            reservedBy = null;
            reserveTime = null;
            status = #Open;
            userWantsToJoin = [];
            seatedCustomers = [];
            order = [];

        };

        put(tables, tableNumber, table);

    };

    // Function to reserve a table
    public func reserve(tables : TableMap, tableId : Nat, reservedBy : Principal) : Result.Result<TableMap, Text> {
        switch (get(tables, tableId)) {
            case null {
                return #err("Table ID out of range.");
            };
            case (?table) {
                switch (table.reservedBy) {
                    case (?reservedBy) {
                        return #err("Table already reserved.");
                    };
                    case (null) {
                        let updatedTable : Table = {
                            id = table.id;
                            capacity = table.capacity;
                            reservedBy = ?reservedBy;
                            reserveTime = ?Time.now();
                            status = #OnOrder;
                            userWantsToJoin = [];
                            seatedCustomers = [];
                            order = [];
                        };
                        put(tables, tableId, updatedTable);
                        return #ok(tables);
                    };
                };
            };

        };
    };

    // Function to unreserve a table
    public func unreserve(tables : TableMap, tableId : Nat) : Result.Result<TableMap, Text> {
        switch (get(tables, tableId)) {
            case null {
                return #err("Table ID out of range.");
            };
            case (?table) {
                switch (table.reservedBy) {
                    case (null) {
                        return #err("Table already Free.");
                    };
                    case (?reservedBy) {
                        let updatedTable : Table = {
                            id = table.id;
                            capacity = table.capacity;
                            reservedBy = null;
                            reserveTime = null;
                            status = #Open;
                            userWantsToJoin = [];
                            seatedCustomers = [];
                            order = [];

                        };
                        put(tables, tableId, updatedTable);
                        return #ok(tables);
                    };
                };
            };

        };
    };

    // Function to check if a table is isReserved
    public func isReserved(tables : TableMap, tableId : Nat) : Bool {
        switch (get(tables, tableId)) {
            case (null) {
                return false;
            };
            case (?table) {
                switch (table.reservedBy) {
                    case (null) {
                        return false;
                    };
                    case (?reservedBy) {
                        return true;
                    };

                };
            };
        };
    };

    /**
     * Returns a list of table IDs reserved by the specified principal.
     *
     * @param {TableMap} tables - The map of tables.
     * @param {Principal} principal - The principal to check reservations for.
     * @return {[Nat]} - An array of table IDs reserved by the principal.
     */
    public func reservedByPrincipal(tables : TableMap, principal : Principal) : Buffer.Buffer<Nat> {
        var reservedTables = Buffer.Buffer<Nat>(0);

        for ((tableId, table) in Map.entries(tables)) {
            switch (table.reservedBy) {
                case (null) {
                    return Buffer.Buffer<Nat>(0);
                };
                case (?p) {
                    if (p == principal) {
                        reservedTables.add(tableId);
                    };
                };
            };
        };

        return reservedTables;
    };

    // Check if the table exists and is reserved by the specified principal.
    public func canUnreserveTable(employeeMap : User.EmployeeMap, tables : TableMap, p : Principal, tableId : Nat) : Bool {
        switch (User.employeeCanPerform(employeeMap, p, #UnreserveTable)) {
            case (true) {
                return true;
            };
            case (false) {
                if (isReserved(tables, tableId)) {
                    switch (get(tables, tableId)) {
                        case (null) { return false };
                        case (?table) {
                            switch (table.reservedBy) {
                                case (null) { return false };
                                case (?reservedBy) {
                                    if (reservedBy == p) {
                                        return true;
                                    } else {
                                        return false;
                                    };
                                };
                            };
                        };
                    };

                };

            };
        };
        return false;
    };

    public func requestToJoinTable(tableMap : TableMap, tableId : Nat, p : Principal) : () {
        switch (get(tableMap, tableId)) {
            case (?table) {

                let addrequest = Array.append<Principal>(table.userWantsToJoin, [p]);

                let updatedTable : Table = {
                    id = tableId;
                    capacity = table.capacity;
                    reservedBy = table.reservedBy;
                    reserveTime = table.reserveTime;
                    userWantsToJoin = addrequest;
                    seatedCustomers = table.seatedCustomers;
                    order = table.order;
                };
                put(tableMap, tableId, updatedTable);
                return;

            };
            case (null) { return };

        };

    };

    public func addGustToTable(tableMap : TableMap, tableId : Nat, p : Principal) : [Principal] {
        switch (get(tableMap, tableId)) {
            case null { return [] };
            case (?table) {

                let removedPrincipal = Array.filter<Principal>(
                    table.userWantsToJoin,
                    func(x) {
                        x != p;
                    },
                );
                let newSeated = Array.append<Principal>(table.seatedCustomers, [p]);

                let updatedSeatedCustomers : Table = {
                    id = tableId;
                    capacity = table.capacity;
                    reservedBy = table.reservedBy;
                    reserveTime = table.reserveTime;
                    userWantsToJoin = removedPrincipal;
                    seatedCustomers = newSeated;
                    order = table.order;
                };
                put(tableMap, tableId, updatedSeatedCustomers);

                return removedPrincipal;
            };
        };
    };

    public func hasSeat(tableMap : TableMap, tableId : Nat, p : Principal) : Bool {
        switch (get(tableMap, tableId)) {
            case (null) {
                return false;
            };
            case (?table) {
                for (element in table.seatedCustomers.vals()) {
                    if (p == element) {
                        return true;
                    };
                };

                return false;
            };
        };

    };

};
