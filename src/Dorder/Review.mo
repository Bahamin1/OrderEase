import Time "mo:base/Time";
import Nat "mo:base/Nat";

module {
    public type MenuReview = {
        id : Nat;
        comment : ?Text;
        pointBy : Principal;
        star : Star;
        suggest : Bool;
        cratedAt : Time.Time;
        image : ?[Blob]
    };

    public type Star = {
        #One;
        #Two;
        #Three;
        #Four;
        #Five
    };

    public type EmployeeReview = {
        pointBy : Principal;
        comment : ?Text;
        star : Star;
        cratedAt : Time.Time
    };

    public type Point = Nat;

    public type UserPoint = Point;

    // let nextPointId : Nat = 0;
    // public func addMenuPoint(menuMap : Menu.MenuMap, menuId : Nat, p : Principal, cm : ?Text, star : Star, suggest : Bool, image : [Blob]) : Result.Result<(Text), Text> {

    //     switch (M.get(menuMap, id)) {
    //         case (null) {
    //             return #err("The menu item with id " #Nat.toText(menuId) # " does not exist!");
    //         };
    //         case (?menu) {
    //             let newMenuPoint = Buffer.fromArray<MenuReview>(menu.star);
    //             newMenuPoint.add({
    //                 comment = cm;
    //                 pointBy = p;
    //                 star = star;
    //                 suggest = suggest;
    //                 cratedAt = Time.now();
    //                 image = [image];
    //             });

    //             nextPointId += 1;

    //             let newMenuPoint : M.MenuItem = {
    //                 name = menu.name;
    //                 price = menu.price;
    //                 description = menu.description;
    //                 star = Buffer.toArray(newMenuPoint);
    //                 image = ?Blob;
    //             };
    //         };
    //     };

    // };

}
