import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Time "mo:base/Time";

module {
    public type Member = {
        name : Text;
        identity : Principal;
        role : Role;
        image : [Blob];
        joined : Time.Time;
        point : [PointForEmployee]
    };

    public type Role = {
        #Admin;
        #Manager;
        #Employee;
        #Customer;
        #VIP;
        #Anonymus
    };

    public type Permission = {
        #VeryHigh;
        #High;
        #Medium;
        #Low
    };

    public type Product = {
        productID : Nat;
        name : Text;
        stock : Bool;
        info : Text;
        fee : Nat;
        image : [Blob];
        rating : [Point]
    };

    public type NewProduct = {
        name : Text;
        stock : Bool;
        fee : Nat;
        info : Text;
        image : [Blob]
    };

    public type Point = {
        pointId : Nat;
        userId : Principal;
        comment : ?Text;
        point : Nat8;
        suggest : Bool;
        cratedAt : Time.Time;
        image : [Blob]
    };

    public type NewPoint = {
        suggest : Bool;
        addPoint : Nat8;
        comment : ?Text;
        image : ?Blob
    };

    public type PointForEmployee = {
        userId : Principal;
        point : Nat;
        cratedAt : Time.Time;

    };

    public type Table = {
        tableNumber : Nat;
        capacity : Nat;
        avability : Bool;
        reservedBy : ?Principal;
        cart : ?CartProduct;
        comment : ?Text;
        reserveTime : ?Time.Time
    };

    //cart map
    public type CartMap = HashMap.HashMap<Principal, Cart>;
    public type ProductsCartMap = HashMap.HashMap<Nat, CartProduct>;

    public type Cart = {
        products : HashMap.HashMap<Nat, CartProduct>;
        createdAt : Int
    };
    public type CartProduct = {
        quantity : Nat;
        productId : Nat;
        createdAt : Int
    };

}
