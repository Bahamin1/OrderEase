import Time "mo:base/Time";

module {

    public type MenuPoint = {
        id : Nat;
        comment : ?Text;
        pointBy : Principal;
        point : Numb;
        suggest : Bool;
        cratedAt : Time.Time;
        image : ?[Blob];
    };

    public type Numb = {
        #One;
        #Two;
        #Three;
        #Four;
        #Five;
    };

    public type EmployeePoint = {
        pointBy : Principal;
        comment : ?Text;
        point : Numb;
        cratedAt : Time.Time;
    };

    // let nextPointId : Nat = 0;
    // public func addMenuPoint(menuMap : Menu.MenuMap, menuId : Nat, p : Principal, cm : ?Text, point : Numb, suggest : Bool, image : [Blob]) : Result.Result<(Text), Text> {

    //     switch (M.get(menuMap, id)) {
    //         case (null) {
    //             return #err("The menu item with id " #Nat.toText(menuId) # " does not exist!");
    //         };
    //         case (?menu) {
    //             let newMenuPoint = Buffer.fromArray<MenuPoint>(menu.point);
    //             newMenuPoint.add({
    //                 comment = cm;
    //                 pointBy = p;
    //                 point = point;
    //                 suggest = suggest;
    //                 cratedAt = Time.now();
    //                 image = [image];
    //             });

    //             nextPointId += 1;

    //             let newMenuPoint : M.MenuItem = {
    //                 name = menu.name;
    //                 price = menu.price;
    //                 description = menu.description;
    //                 point = Buffer.toArray(newMenuPoint);
    //                 image = ?Blob;
    //             };
    //         };
    //     };

    // };

};
