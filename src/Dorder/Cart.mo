import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { phash } "mo:map/Map";

import Types "Types";

module Cart {

    public type CartMap = Map.Map<Principal, Order>;

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

    //     public func get(cartMap : CartMap, principal : Principal) : ?Order {
    //         return Map.get(cartMap, phash, principal);
    //     };

    //     //// put User
    //     public func put(cartMap : CartMap, p : Principal, order : Order) : () {
    //         return Map.set(cartMap, phash, p, order);
    //     };

    //     /// add new order
    //     public func new(cartMap : CartMap, caller : Principal, orderType : OrderType) {
    //         let cartItem = [];
    //         let order = {
    //             items = cartItem;
    //             orderType = orderType;
    //             createdAt = Time.now();
    //         };
    //         put(cartMap, caller, order);
    //     };

};
