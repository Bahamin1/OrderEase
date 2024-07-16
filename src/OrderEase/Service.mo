import Types "Types";
module Service {

    public type Message = {
        message : Text;
        messageId : Nat;
        by : Principal;
        to : Types.UserRole;
    };

};
