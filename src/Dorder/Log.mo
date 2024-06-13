import Array "mo:base/Array";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash; phash } "mo:map/Map";

module {

    public type Log = {
        id : Nat;
        message : Text;
        createdAt : Time.Time;
        catagory : Catagory;
    };

    public type Catagory = {
        #Member;
        #Table;
        #Menu;
        #Order;
        #EmployeePoint;
        #MenuPoint;
    };

    public type LogMap = Map.Map<Nat, Log>;

    public func get(logMap : LogMap, key : Nat) : ?Log {
        return Map.get(logMap, nhash, key);
    };

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

    public func getByCatagory(logMap : LogMap, catagory : Catagory) : async [Log] {
        var filteredLogs : [Log] = [];
        for ((_, log) in Map.entries(logMap)) {
            switch (log.catagory == catagory) {
                case (catagory) {
                    filteredLogs := Array.append<Log>(filteredLogs, [log]);
                };
            };
        };
        return filteredLogs;
    };

};
