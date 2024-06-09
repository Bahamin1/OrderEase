import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash } "mo:map/Map";

import Point "Point";

module {

    public type MenuItem = {
        id : Nat;
        name : Text;
        price : Nat;
        stock : [Bool];
        description : Text;
        point : [Point.MenuPoint];
        image : ?Blob;
    };

    public type NewMenuItem = {
        name : Text;
        price : Nat;
        stock : [Bool];
        description : Text;
        image : ?Blob;

    };

    public type MenuMap = Map.Map<Nat, MenuItem>;

    public func get(menuMap : MenuMap, key : Nat) : ?MenuItem {
        return Map.get<Nat, MenuItem>(menuMap, nhash, key);
    };

    // MenuItem put to map
    public func put(menuMap : MenuMap, key : Nat, value : MenuItem) : () {
        return Map.set<Nat, MenuItem>(menuMap, nhash, key, value);
    };

    public func new(menuMap : MenuMap, menuId : Nat, newMenuItem : NewMenuItem) : MenuMap {

        let newMenu : MenuItem = {
            id = menuId;
            name = newMenuItem.name;
            price = newMenuItem.price;
            stock = newMenuItem.stock;
            description = newMenuItem.description;
            point = [];
            image = newMenuItem.image;
        };

        put(menuMap, menuId, newMenu);
        return menuMap;
    };

};
