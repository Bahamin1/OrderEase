import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash } "mo:map/Map";

import Review "Review";

module {

    public type MenuItem = {
        id : Nat;
        name : Text;
        price : Nat;
        stock : Bool;
        description : Text;
        score : [Review.MenuReview];
        image : ?Blob;
    };

    public type NewMenuItem = {
        name : Text;
        price : Nat;
        stock : Bool;
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

    public func new(menuMap : MenuMap, newMenuItem : NewMenuItem) : () {
        let itemId = Map.size(menuMap) +1;

        let newMenu : MenuItem = {
            id = itemId;
            name = newMenuItem.name;
            price = newMenuItem.price;
            stock = newMenuItem.stock;
            description = newMenuItem.description;
            score = [];
            image = newMenuItem.image;
        };

        put(menuMap, itemId, newMenu);
        return;
    };

    public func update(menuMap : MenuMap, menuId : Nat, newMenuItem : NewMenuItem) : Result.Result<Text, Text> {
        switch (get(menuMap, menuId)) {
            case (null) {
                return #err("The menu item with id " #Nat.toText(menuId) # " does not exist!");
            };
            case (?item) {
                let updateItem : MenuItem = {

                    id = menuId;
                    name = newMenuItem.name;
                    price = newMenuItem.price;
                    stock = newMenuItem.stock;
                    description = newMenuItem.description;
                    score = item.score;
                    image = newMenuItem.image;
                };

                put(menuMap, menuId, updateItem);
                return #ok("The menu item with id " #Nat.toText(menuId) # " has been updated!");

            };
        };

    };

    public func hasPoint(menuMap : MenuMap, menuId : Nat, p : Principal) : Bool {
        let menu = get(menuMap, menuId);
        switch (menu) {
            case (null) {
                return false;
            };
            case (?menu) {
                for (star in menu.score.vals()) {
                    if (star.pointBy == p) {
                        return true;
                    };
                };
            };

        };
        return false;
    };

    public func replaceNewItemScore(menuItem : MenuItem, menuId : Nat, principal : Principal, newPoint : Review.MenuReview) : MenuItem {
        switch (menuItem) {
            case (item) {
                // Filter out the specific MenuReview
                let updatedPoints = Array.filter<Review.MenuReview>(
                    item.score,
                    func(score) {
                        score.pointBy != principal;
                    },
                );
                // Add the new MenuReview
                let newPoints = Array.append<Review.MenuReview>(updatedPoints, [newPoint]);
                // Update the MenuItem with the new points array
                let updatedItem : MenuItem = {
                    id = menuId;
                    name = item.name;
                    price = item.price;
                    stock = item.stock;
                    description = item.description;
                    score = newPoints;
                    image = item.image;
                };
                return updatedItem;
            };
        };
    };
};
