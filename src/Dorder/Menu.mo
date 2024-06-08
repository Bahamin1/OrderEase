import Map "mo:map/Map";
import { nhash } "mo:map/Map";

module {

    public type MenuItem = {
        name : Text;
        price : Nat;
        discription : Text;
        point : Nat8;
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

    public func new(menuMap : MenuMap, menuId : Nat, newMenu : MenuItem) : MenuMap {
        put(menuMap, menuId, newMenu);
        return menuMap;
    };
};
