import Array "mo:base/Array";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash } "mo:map/Map";

import Menu "Menu";
import R "Reciept";

module Cart {

    public type OrderType = {
        #OnTable;
        #Delivery;
        #TakeOut;
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
        itemId : Nat;
        quantity : Float;
        createdAt : Time.Time;
    };

    public type Order = {
        id : Nat;
        items : [CartItem];
        status : OrderStatus;
        orderBy : Principal;
        orderType : OrderType;
        totalAmount : Float;
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

    public func new(menuMap : Menu.MenuMap, cartMap : CartMap, p : Principal, orderType : Cart.OrderType, items : [CartItem]) : Nat {
        let id = Map.size(cartMap) + 1;

        let amount = calculateItemsAmount(menuMap, items);

        let newOrder : Cart.Order = {
            id = id;
            items = items;
            status = #Pending;
            orderBy = p;
            totalAmount = amount;
            stage = #Open;
            orderType = orderType;
            createdAt = Time.now();
            isPaid = false;
        };
        put(cartMap, id, newOrder);

        return newOrder.id;
    };

    public func hasOpenOrder(cartMap : CartMap, p : Principal) : ?Order {

        for (order in Map.vals(cartMap)) {
            if (order.orderBy == p) {
                if (order.stage == #Open) {
                    return ?order;
                };
            };
        };
        return null;
    };

    public func calculateItemsAmount(menuMap : Menu.MenuMap, items : [CartItem]) : Float {
        var totalAmount : Float = 0.0;

        for (element in items.vals()) {
            switch (Menu.get(menuMap, element.itemId)) {
                case (?menu) {
                    totalAmount += menu.price * element.quantity;
                };
                case (null) { return 0 };

            };
        };
        return totalAmount;
    };

    public func checkout(cartMap : CartMap, p : Principal) : [Order] {
        var filteredOrders : [Order] = [];
        for (order in Map.vals(cartMap)) {
            if (order.orderBy == p) {
                if (order.stage == #Finalized) {
                    filteredOrders := Array.append<Order>(filteredOrders, [order]);
                    return filteredOrders;
                };
            };
        };
        return [];
    };

    public func combineChekouts(cartMap : CartMap, p : Principal, method : R.PaymentMethod, orders : [Order]) : Order {
        var totalAmount : Float = 0.0;
        for (element in orders.vals()) {
            totalAmount += element.totalAmount;
        };
        var allItems : [CartItem] = [];
        for (element in orders.vals()) {
            switch (element.items) {
                case (is) {
                    for (element in is.vals()) {

                        allItems := Array.append<CartItem>(allItems, [element]);
                    };

                };
            };
        };

        let id = Map.size(cartMap) + 1;

        let newReciept : Order = {
            id = id;
            items = allItems;
            status = #Delivered;
            orderBy = p;
            totalAmount = totalAmount;
            stage = #Finalized;
            orderType = orders.orderType;
            createdAt = Time.now();
            isPaid = false;

        };

    };

};
