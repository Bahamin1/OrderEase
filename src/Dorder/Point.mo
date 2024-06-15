import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
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

};
