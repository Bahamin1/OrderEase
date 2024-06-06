import Blob "mo:base/Blob";
import Result "mo:base/Result";
import Map "mo:map/Map";
import { nhash; phash } "mo:map/Map";

import User "User";

module {
    public type Order = {
        user : User.User;
        orderType : OrderType;
        items : [Menu];
    };

    public type OrderType = {
        #InPerson;
        #OnTable;
        #TakeOut;
    };

    public type Menu = {
        name : Text;
        price : Nat;
        discription : Text;
        image : ?Blob;
    };

    public type MenuMap = Map.Map<Nat, Menu>;

    public func get(menu : MenuMap, key : Nat) : ?Menu {
        return Map.get<Nat, Menu>(menu, nhash, key);
    };

    // Menu put to map
    public func put(menu : MenuMap, key : Nat, value : Menu) : () {
        return Map.set<Nat, Menu>(menu, nhash, key, value);
    };

    public func new(menuMap : MenuMap, p : Principal, menuId : Nat, newMenu : Menu) : MenuMap {

        put(menuMap, menuId, newMenu);
        return menuMap;
    };
};
