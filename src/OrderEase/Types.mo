module {

    public type UserRole = {
        #Guest;
        #Customer;
        #Employee;
        #Manager;
        #Admin;
    };

    public type Operation = {
        #ModifyReciept;
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
