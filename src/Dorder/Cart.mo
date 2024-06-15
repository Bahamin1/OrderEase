import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash; phash } "mo:map/Map";

module Cart {

    public type TableCartMap = Map.Map<Nat, CartItem>;

    public type OrderType = {
        #OnTable;
        #TakeOut;
    };

    public type CartItem = {
        quantity : Nat;
        itemId : Nat;
        createdAt : Time.Time;
    };

    public type Order = {
        items : HashMap.HashMap<Nat, CartItem>;
        orderType : OrderType;
        createdAt : Time.Time;
    };

    public func get(cartMap : TableCartMap, tableId : Nat) : ?CartItem {
        return Map.get(cartMap, nhash, tableId);
    };

    public func put(cartMap : TableCartMap, tableId : Nat, order : CartItem) : () {
        return Map.set(cartMap, nhash, tableId, order);
    };

};
