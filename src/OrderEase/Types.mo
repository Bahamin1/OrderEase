module {

    public type UserRole = {
        #Guest;
        #Customer;
        #Employee;
        #Manager;
        #Admin;
    };

    public type Operation = {
        #SendNotify;
        #ReserveTable;
        #UnreserveTable;
        #CanTakeAway;
        #PayTable;
        #MonitorLogs;
        #Hire;
        #Fire;
        #ModifyTable;
        #ModifyMenuItem;
        #ModifyMenuItemPoint;
        #ModifyEmployeePoints;
    };

};
