import Nat "mo:base/Nat";
import Time "mo:base/Time";

module {
    public type MenuReview = {
        id : Nat;
        comment : ?Text;
        pointBy : Principal;
        star : Star;
        suggest : Bool;
        cratedAt : Time.Time;
        image : ?[Blob];
    };

    public type EmployeeReview = {
        pointBy : Principal;
        comment : ?Text;
        star : Star;
        cratedAt : Time.Time;
    };

    public type Star = {
        #One;
        #Two;
        #Three;
        #Four;
        #Five;
    };

};
