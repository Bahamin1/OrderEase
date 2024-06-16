import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash; phash } "mo:map/Map";

import Menu "Menu";
import Point "Point";

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

    public type OrderStatus = {
        #Pending;
        #Preparing;
        #Delivered;
        #Canceled;
    };

    public type Order = {
        orderId : Nat;
        orderType : OrderType;
        items : [Menu.MenuItem];
        totalPrice : Float;
        status : OrderStatus;
        tableNumber : Nat;
        orderTime : Time.Time;
    };

};
