import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash } "mo:map/Map";

import User "User";

module Table {
    // Table type definition
    public type Table = {
        id : Nat;
        capacity : Nat;
        reservedBy : ?Principal;
        reserveTime : ?Time.Time;
        seatedCustomers : [Principal];
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
            isReserved = false;
            reservedBy = null;
            reserveTime = null;
            seatedCustomers = [];
        };

        put(tables, tableNumber, table);

        Debug.print("Tables::" #Nat.toText(tableNumber) # ":: initialized ");
        Debug.print(debug_show (tables));
        return;
    };

    // Function to reserve a table
    public func reserve(tables : TableMap, tableId : Nat, reservedBy : Principal) : Result.Result<TableMap, Text> {
        switch (get(tables, tableId)) {
            case null {
                Debug.print("Table ID out of range.");
                return #err("Table ID out of range.");
            };
            case (?table) {
                switch (table.reservedBy) {
                    case (?reservedBy) {
                        Debug.print("Table already reserved.");
                        return #err("Table already reserved.");
                    };
                    case (null) {
                        let updatedTable : Table = {
                            id = table.id;
                            capacity = table.capacity;
                            reservedBy = ?reservedBy;
                            reserveTime = ?Time.now();
                            seatedCustomers = [];
                        };
                        put(tables, tableId, updatedTable);
                        Debug.print("Table reserved: ");
                        Debug.print(debug_show (tables));
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
                Debug.print("Table ID out of range.");
                return #err("Table ID out of range.");
            };
            case (?table) {
                switch (table.reservedBy) {
                    case (?reservedBy) {
                        Debug.print("Table already reserved.");
                        return #err("Table already reserved.");
                    };
                    case (null) {
                        let updatedTable : Table = {
                            id = table.id;
                            capacity = table.capacity;
                            isReserved = false;
                            reservedBy = null;
                            reserveTime = null;
                            seatedCustomers = [];
                        };
                        put(tables, tableId, updatedTable);
                        Debug.print("Table unreserved: ");
                        Debug.print(debug_show (tables));
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
    public func canUnreserveTable(tables : TableMap, p : Principal, tableId : Nat) : Bool {
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
        return false;
    };
};
