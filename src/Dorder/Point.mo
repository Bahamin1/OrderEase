import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Time "mo:base/Time";

module Point {

    public type MenuPoint = {
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
        comment : ?Text;
        point : Numb;
        cratedAt : Time.Time;
    };

};
