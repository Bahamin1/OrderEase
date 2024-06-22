import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash; phash } "mo:map/Map";

import Menu "Menu";
import Review "Review";

module Cart {

    public type CartMap = Map.Map<Nat, Order>;

    public type OrderType = {
        #OnTable;
        #TakeOut;
    };

    public type Items = {
        itemId : Nat;
        quantity : Nat;
    };

    public type OrderStatus = {
        #Pending;
        #Preparing;
        #Delivered;
        #Canceled;
    };

    public type Order = {
        orderedBy : Principal;
        orderType : OrderType;
        items : [Items];
        totalPrice : Float;
        status : OrderStatus;
        tableNumber : Nat;
        orderTime : Time.Time;
        isPaid : Bool;
    };

    public func openOrder(cartMap : CartMap, p : Principal, tableId : Nat, orderType : Cart.OrderType) : () {
        let key = Map.size(cartMap) + 1;

        let newOrder : Cart.Order = {
            orderedBy = p;
            orderType = orderType;
            items = [];
            totalPrice = 0;
            status = #Pending;
            tableNumber = tableId;
            orderTime = Time.now();
            isPaid = false;
        };
        Map.set(cartMap, nhash, key, newOrder);
    };

};
