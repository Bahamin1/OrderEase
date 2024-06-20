import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash; phash } "mo:map/Map";

import Menu "Menu";
import Review "Review";

module Cart {

    public type CartMap = Map.Map<Principal, CartItem>;

    public type OrderType = {
        #OnTable;
        #TakeOut;
    };

    public type Items = {
        itemId : Nat;
        quantity : Nat;
    };

    public type CartItem = {
        items : [Items];
        status : OrderStatus;
        orderType : OrderType;
        createdAt : Time.Time;
    };

    public type OrderStatus = {
        #Pending;
        #Preparing;
        #Delivered;
        #Canceled;
    };

    public type Order = {
        orderId : Nat;
        orderType : OrderType;
        items : [Items];
        totalPrice : Float;
        status : OrderStatus;
        tableNumber : Nat;
        orderTime : Time.Time;
        finalized : Bool;
    };

};
