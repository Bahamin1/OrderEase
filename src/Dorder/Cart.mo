import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash; phash } "mo:map/Map";

import Menu "Menu";
import Review "Review";
import Types "Types";
import User "User";

module Cart {

    public type OrderType = {
        #OnTable;
        #TakeOut;
        #Delivery;
    };

    public type Cart = {
        item : Menu.MenuItem;
        quantity : Nat;
        createdTime : Time.Time;
    };

    public type OrderStatus = {
        #Pending;
        #Preparing;
        #Delivered;
        #Canceled;
    };

    public type Order = {
        orderId : Nat;
        orderedBy : Principal;
        orderType : OrderType;
        address : ?Text;
        phoneNumber : ?Nat;
        items : [Cart];
        totalPrice : Float;
        status : OrderStatus;
        tableNumber : Nat;
        orderTime : Time.Time;
        isPaid : Bool;
    };

    public type CartMap = Map.Map<Nat, Order>;

    public func get(carts : CartMap, key : Nat) : ?Order {
        return Map.get<Nat, Order>(carts, nhash, key);
    };

    public func put(carts : CartMap, key : Nat, value : Order) : () {
        return Map.set<Nat, Order>(carts, nhash, key, value);
    };

    public func new(cartMap : CartMap, p : Principal, tableId : Nat, orderType : Cart.OrderType) : () {
        let id = Map.size(cartMap) + 1;

        let newOrder : Cart.Order = {
            orderId = id;
            orderedBy = p;
            orderType = orderType;
            address = null;
            phoneNumber = null;
            items = [];
            totalPrice = 0;
            status = #Pending;
            tableNumber = tableId;
            orderTime = Time.now();
            isPaid = false;
        };
        put(cartMap, id, newOrder);
    };

};
