import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Time "mo:base/Time";

import Menu "Menu";

module Types {
    public type Operation = {
        #ReserveTable;
        #UnreserveTable;
        #PayTable;
        #HireManager;
        #FireManager;
        #HireEmployee;
        #FireEmployee;
        #ModifyTable;
        #ModifyMenuItem;
        #ModifyMenuItemPoint;
        #ViewReports;
        #ModifyEmployeePoints;
    };

    public type OrderType = {
        #OnTable;
        #TakeOut;
    };

    public type Order = {
        orderType : OrderType;
        items : [Menu.MenuItem];
    };

    //cart map

    public type Cart = {
        products : HashMap.HashMap<Nat, CartProduct>;
        createdAt : Int;
    };
    public type CartProduct = {
        quantity : Nat;
        productId : Nat;
        createdAt : Int;
    };

};
