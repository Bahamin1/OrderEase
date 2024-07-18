import Time "mo:base/Time";
import Map "mo:map/Map";
import { nhash } "mo:map/Map";

module Receipt {

    public type Receipt = {
        txId : Nat;
        amount : Nat;
        createdAt : Time.Time;
        buyer : Principal;
        address : Text;
        txHash : Text;
        processed : Bool;
        payWith : ?PaymentMethod;
    };

    public type PaymentMethod = {
        #Cash;
        #POS;
        #ETH;
        #BTC;
        #ICP;
    };

    public type ReceiptMap = Map.Map<Nat, Receipt>;

    public func get(recieptMap : ReceiptMap, txId : Nat) : ?Receipt {
        return Map.get(recieptMap, nhash, txId);
    };

    public func put(recieptMap : ReceiptMap, txId : Nat, reciept : Receipt) : () {
        return Map.set(recieptMap, nhash, txId, reciept);
    };
};
