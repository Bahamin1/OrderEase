import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Time "mo:base/Time";

import Menu "Menu";

module {
    public type Operation = {
        #ReserveTable;
        #UnreserveTable;
        #PayTable;
        #MonitorLogs;
        #HireManager;
        #FireManager;
        #HireEmployee;
        #FireEmployee;
        #ModifyTable;
        #ModifyMenuItem;
        #ModifyMenuItemPoint;
        #ModifyEmployeePoints;
    };

};
