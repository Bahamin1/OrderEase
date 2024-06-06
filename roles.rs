// Define the enum for different user roles
enum UserRole {
    Guest,
    Employee,
    Manager,
    Admin,
}

// Define the enum for different operations
enum Operation {
    ReserveTable,
    UnreserveTable,
    PayTable,
    HireEmployee,
    FireEmployee,
    AddMenuItem,
    RemoveMenuItem,
    UpdateMenuItem,
    ViewReports,
    ModifyEmployeePoints,
}

// Define a struct for User, which includes a role, a list of allowed operations, an id, and points
#[derive(Clone)]
struct User {
    role: UserRole,
    allowed_operations: Vec<Operation>,
    id: u32,
    points: i32, // Points attribute for the employee
}

// Define a struct for Table, representing a table in the restaurant
struct Table {
    id: u32,
    is_reserved: bool,
    reserved_by: Option<u32>,
}

// Define a struct for Reservation, representing a table reservation
struct Reservation {
    user: User,
    table_id: u32,
    time_slot: String,
}

// Define a struct for MenuItem, representing an item in the restaurant menu
#[derive(Clone)]
struct MenuItem {
    id: u32,
    name: String,
    price: f64,
}

// Define a struct for Order, representing an order made by a user
struct Order {
    user: User,
    items: Vec<MenuItem>,
}

// Implement the logic to check if a user is allowed to perform a specific operation
impl User {
    fn can_perform(&self, operation: &Operation) -> bool {
        self.allowed_operations.contains(operation)
    }
}

// Function to reserve a table
fn reserve_table(user: &User, table_id: u32, time_slot: &str, tables: &mut Vec<Table>) -> Result<Reservation, String> {
    if user.can_perform(&Operation::ReserveTable) {
        for table in tables.iter_mut() {
            if table.id == table_id {
                if table.is_reserved {
                    return Err("Table is already reserved".to_string());
                } else {
                    table.is_reserved = true;
                    table.reserved_by = Some(user.id);
                    return Ok(Reservation {
                        user: user.clone(),
                        table_id,
                        time_slot: time_slot.to_string(),
                    });
                }
            }
        }
        Err("Table not found".to_string())
    } else {
        Err("User is not allowed to reserve tables".to_string())
    }
}

// Function to remove a table reservation
fn remove_reserve_table(user: &User, table_id: u32, tables: &mut Vec<Table>) -> Result<String, String> {
    if user.can_perform(&Operation::UnreserveTable) {
        for table in tables.iter_mut() {
            if table.id == table_id {
                if !table.is_reserved {
                    return Err("Table is not currently reserved".to_string());
                } else if table.reserved_by != Some(user.id) {
                    return Err("User did not reserve this table".to_string());
                } else {
                    table.is_reserved = false;
                    table.reserved_by = None;
                    return Ok(format!("Reservation for table {} has been removed", table_id));
                }
            }
        }
        Err("Table not found".to_string())
    } else {
        Err("User is not allowed to unreserve tables".to_string())
    }
}

// Function to select a menu item
fn select_menu_item(user: &User, item_id: u32, menu: &Vec<MenuItem>, orders: &mut Vec<Order>) -> Result<String, String> {
    for item in menu.iter() {
        if item.id == item_id {
            for order in orders.iter_mut() {
                if order.user.id == user.id {
                    order.items.push(item.clone());
                    return Ok(format!("Item {} has been added to your order", item.name));
                }
            }
            // If no order exists for the user, create a new one
            let new_order = Order {
                user: user.clone(),
                items: vec![item.clone()],
            };
            orders.push(new_order);
            return Ok(format!("Item {} has been added to your order", item.name));
        }
    }
    Err("Menu item not found".to_string())
}

// Function to view user's order
fn view_order(user: &User, orders: &Vec<Order>) -> Result<Vec<MenuItem>, String> {
    for order in orders.iter() {
        if order.user.id == user.id {
            return Ok(order.items.clone());
        }
    }
    Err("No order found for the user".to_string())
}

// Function to add points to an employee
fn add_points(user: &User, employee_id: u32, points: i32, employees: &mut Vec<User>) -> Result<String, String> {
    if user.can_perform(&Operation::ModifyEmployeePoints) {
        for employee in employees.iter_mut() {
            if employee.id == employee_id {
                employee.points += points;
                return Ok(format!("{} points have been added to employee {}", points, employee_id));
            }
        }
        Err("Employee not found".to_string())
    } else {
        Err("User is not allowed to modify employee points".to_string())
    }
}

// Function to subtract points from an employee
fn subtract_points(user: &User, employee_id: u32, points: i32, employees: &mut Vec<User>) -> Result<String, String> {
    if user.can_perform(&Operation::ModifyEmployeePoints) {
        for employee in employees.iter_mut() {
            if employee.id == employee_id {
                employee.points -= points;
                return Ok(format!("{} points have been subtracted from employee {}", points, employee_id));
            }
        }
        Err("Employee not found".to_string())
    } else {
        Err("User is not allowed to modify employee points".to_string())
    }
}

// Example usage
fn main() {
    // Create a list of tables in the restaurant
    let mut tables = vec![
        Table { id: 1, is_reserved: false, reserved_by: None },
        Table { id: 2, is_reserved: false, reserved_by: None },
        Table { id: 3, is_reserved: false, reserved_by: None },
    ];

    // Create a menu for the restaurant
    let menu = vec![
        MenuItem { id: 1, name: "Pizza".to_string(), price: 12.5 },
        MenuItem { id: 2, name: "Pasta".to_string(), price: 10.0 },
        MenuItem { id: 3, name: "Salad".to_string(), price: 8.0 },
    ];

    // Create an empty list to store orders
    let mut orders = vec![];

    // Create a list of employees
    let mut employees = vec![
        User {
            role: UserRole::Employee,
            allowed_operations: vec![Operation::PayTable],
            id: 1,
            points: 0,
        },
        User {
            role: UserRole::Employee,
            allowed_operations: vec![Operation::PayTable],
            id: 2,
            points: 0,
        },
    ];

    // Create a new User with the role of Manager and allowed operations
    let manager = User {
        role: UserRole::Manager,
        allowed_operations: vec![
            Operation::ReserveTable,
            Operation::UnreserveTable,
            Operation::PayTable,
            Operation::HireEmployee,
            Operation::FireEmployee,
            Operation::ViewReports,
            Operation::ModifyEmployeePoints,
        ],
        id: 3,
        points: 0,
    };

    // Create a new User with the role of Guest and allowed operations
    let guest = User {
        role: UserRole::Guest,
        allowed_operations: vec![
            Operation::ReserveTable,
            Operation::UnreserveTable,
            Operation::PayTable,
        ],
        id: 4,
        points: 0,
    };

    // Example of reserving a table by a guest
    match reserve_table(&guest, 1, "18:00-20:00", &mut tables) {
        Ok(reservation) => println!("Reservation successful: Table {} reserved by Guest", reservation.table_id),
        Err(e) => println!("Reservation failed: {}", e),
    }

    // Example of selecting menu items by the guest
    match select_menu_item(&guest, 1, &menu, &mut orders) {
        Ok(message) => println!("{}", message),
        Err(e) => println!("Failed to select menu item: {}", e),
    }

    match select_menu_item(&guest, 2, &menu, &mut orders) {
        Ok(message) => println!("{}", message),
        Err(e) => println!("Failed to select menu item: {}", e),
    }

    // Example of viewing the order by the guest
    match view_order(&guest, &orders) {
        Ok(items) => {
            println!("Guest's order:");
            for item in items {
                println!("{} - ${}", item.name, item.price);
            }
        }
        Err(e) => println!("Failed to view order: {}", e),
    }

    // Example of removing a reservation by the guest
    match remove_reserve_table(&guest, 1, &mut tables) {
        Ok(message) => println!("{}", message),
        Err(e) => println!("Failed to remove reservation: {}", e),
    }

    // Example of adding points to an employee by the manager
    match add_points(&manager, 1, 10, &mut employees) {
        Ok(message) => println!("{}", message),
        Err(e) => println!("Failed to add points: {}", e),
    }

    // Example of subtracting points from an employee by the manager
    match subtract_points(&manager, 1, 5, &mut employees) {
        Ok(message) => println!("{}", message),
        Err(e) => println!("Failed to subtract points: {}", e),
    }

    // Print employee points
    for employee in employees {
        println!("Employee {}: {} points", employee.id, employee.points);
    }
}
