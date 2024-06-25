import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Time "mo:base/Time";

import Menu "Menu";

module {

    public type CartItem = {
        item : Menu.MenuItem;
        quantity : Nat;
        createdTime : Time.Time;
    };

    type OrderStatus = {
        #Pending;
        #Preparing;
        #Delivered;
        #Canceled;
    };

    type OrderType = {
        onTable : OnTable;
        delivery : Delivery;
        takeOut : TakeOut;
    };

    type OnTable = {
        tableId : Nat;
    };

    type Delivery = {
        address : Text;
        phoneNumber : Nat;
    };

    type TakeOut = {
        phoneNumber : Nat;
    };

    type Order = {
        id : Nat;
        items : [CartItem];
        status : OrderStatus;
        orderBy : Principal;
        orderType : OrderType;
        createdAt : Time.Time;
        isPaid : Bool;
    };

};
