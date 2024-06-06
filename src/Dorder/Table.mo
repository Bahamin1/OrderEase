import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Map "mo:map/Map";
import { nhash } "mo:map/Map";

import User "User";

module {
    // Table type definition
    public type Table = {
        id : Nat;
        capacity : Nat;
        isReserved : Bool;
        reservedBy : ?Principal;
        reserveTime : ?Time.Time;
        seatedCustomers : [Principal]
    };

    public type Reservation = {
        user : User.User;
        tableId : Nat;
        reserveAt : Time.Time
    };

    public type TableMap = Map.Map<Nat, Table>;

    /////table get from map

    public func get(tables : TableMap, key : Nat) : ?Table {
        return Map.get<Nat, Table>(tables, nhash, key)
    };

    // table put to map
    public func put(tables : TableMap, key : Nat, value : Table) : () {
        return Map.set<Nat, Table>(tables, nhash, key, value)
    };

    // Initialize tables
    public func new(tables : TableMap, tableNumber : Nat, capacity : Nat) : () {

        let table = {
            id = tableNumber;
            capacity = capacity;
            isReserved = false;
            reservedBy = null;
            reserveTime = null;
            seatedCustomers = []
        };

        put(tables, tableNumber, table);

        Debug.print("Tables::" #Nat.toText(tableNumber) # ":: initialized ");
        Debug.print(debug_show (tables))
    };

    // Function to reserve a table
    public func reserve(tables : TableMap, tableId : Nat, reservedBy : Principal) : Result.Result<TableMap, Text> {
        switch (get(tables, tableId)) {
            case (?table) {
                if (table.isReserved != true) {
                    let updatedTable : Table = {
                        id = table.id;
                        capacity = table.capacity;
                        isReserved = true;
                        reservedBy = ?reservedBy;
                        reserveTime = ?Time.now();
                        seatedCustomers = []
                    };
                    put(tables, tableId, updatedTable);
                    Debug.print("Table reserved: ");
                    Debug.print(debug_show (tables));
                    return #ok(tables)
                } else {
                    Debug.print("Table already reserved.");
                    return #err("Table already reserved.")
                }
            };
            case null {
                Debug.print("Table ID out of range.");
                return #err("Table ID out of range.")
            }
        }
    };

    // Function to unreserve a table
    public func unreserve(tables : TableMap, tableId : Nat) : Result.Result<TableMap, Text> {
        switch (get(tables, tableId)) {
            case (?table) {
                if (table.isReserved != false) {
                    let updatedTable : Table = {
                        id = table.id;
                        capacity = table.capacity;
                        isReserved = false;
                        reservedBy = null;
                        reserveTime = null;
                        seatedCustomers = []
                    };
                    put(tables, tableId, updatedTable);
                    Debug.print("Table unreserved: ");
                    Debug.print(debug_show (tables));
                    return #ok(tables)
                } else {
                    Debug.print("Table was not reserved.");
                    return #err("Table was not reserved.")
                }
            };
            case null {
                Debug.print("Table ID out of range.");
                return #err("Table ID out of range.")
            }
        }
    };

    // Function to check if a table is isReserved
    public func isReserved(tables : TableMap, tableId : Nat) : Bool {
        switch (get(tables, tableId)) {
            case (?table) {
                return table.isReserved
            };
            case (null) {
                return false
            }
        }
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
                case (?p) {
                    if (p == principal) {
                        reservedTables.add(tableId)
                    }
                };
                case (null) {
                    return Buffer.Buffer<Nat>(0)
                }
            }
        };

        return reservedTables
    };

    // Check if the table exists and is reserved by the specified principal.
    public func canUnreserveTable(tables : TableMap, userMap : User.UserMap, p : Principal, tableId : Nat) : Bool {
        if (User.canPerformByPrincipal(userMap, p, #UnreserveTable) == true) {
            return true
        } else {
            switch (isReserved(tables, tableId)) {
                case (true) {
                    switch (get(tables, tableId)) {
                        case (?table) {
                            switch (table.reservedBy) {
                                case (?reservedBy) {

                                    if (reservedBy == p) {
                                        return true
                                    } else {
                                        return false
                                    }
                                };
                                case (null) { return false }
                            }
                        };
                        case (null) { return false }
                    }
                };

                case (false) { return false };

            }
        }
    };

}
