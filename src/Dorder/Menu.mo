import Blob "mo:base/Blob";
import Result "mo:base/Result";
import Map "mo:map/Map";
import { nhash; phash } "mo:map/Map";

module {
    public type MenuItem = {
        name : Text;
        price : Nat;
        discription : Text;
        image : ?Blob
    };

    public type MenuMap = Map.Map<Nat, MenuItem>;

    public func get(menu : MenuMap, key : Nat) : ?MenuItem {
        return Map.get<Nat, MenuItem>(menu, nhash, key)
    };

    // MenuItem put to map
    public func put(menu : MenuMap, key : Nat, value : MenuItem) : () {
        return Map.set<Nat, MenuItem>(menu, nhash, key, value)
    };

    public func new(menuMap : MenuMap, menuId : Nat, newMenu : MenuItem) : MenuMap {
        put(menuMap, menuId, newMenu);
        return menuMap
    }
}
