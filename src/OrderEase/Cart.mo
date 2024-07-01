import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash } "mo:map/Map";

import Menu "Menu";

module Cart {

    public type OrderType = {
        onTable : OnTable;
        delivery : Delivery;
        takeOut : TakeOut;
    };

    public type OnTable = {
        tableId : Nat;
    };

    public type Delivery = {
        address : Text;
        phoneNumber : Nat;
    };

    public type TakeOut = {
        phoneNumber : Nat;
    };

    public type OrderStatus = {
        #Pending;
        #Preparing;
        #Delivered;
        #Canceled;
    };

    public type OrderStage = {
        #Open;
        #Finalized;
    };

    public type CartItem = {
        item : Menu.MenuItem;
        quantity : Nat;
        createdAt : Time.Time;
    };

    public type Order = {
        id : Nat;
        items : [CartItem];
        status : OrderStatus;
        orderBy : Principal;
        orderType : OrderType;
        totalAmount : ?Nat;
        stage : OrderStage;
        createdAt : Time.Time;
        isPaid : Bool;
    };

    public type CartMap = Map.Map<Nat, Order>;

    public func get(carts : CartMap, key : Nat) : ?Order {
        return Map.get<Nat, Order>(carts, nhash, key);
    };

    public func put(carts : CartMap, key : Nat, value : Order) : () {
        return Map.set<Nat, Order>(carts, nhash, key, value);
    };

    public func new(cartMap : CartMap, p : Principal, orderType : Cart.OrderType, items : [CartItem]) : Order {
        let id = Map.size(cartMap) + 1;

        let newOrder : Cart.Order = {
            id = id;
            items = items;
            status = #Pending;
            orderBy = p;
            totalAmount = null;
            stage = #Open;
            orderType = orderType;
            createdAt = Time.now();
            isPaid = false;
        };
        put(cartMap, id, newOrder);

        return newOrder;
    };

    public func hasOrder(order : Order, p : Principal) : Bool {

        switch (order) {
            case (order) {

                if (order.orderBy == p) {
                    return true;
                } else {
                    return false;
                };
            };

        };

    };

};
