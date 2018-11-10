import ballerina/config;
import ballerina/io;
import ballerina/log;
import ballerina/mysql;

@final string QUERY_GET_EMPLOYEE_INFORMATION ="SELECT emp_no,birth_date,first_name,last_name,gender,hire_date FROM employees WHERE  emp_no= ?";
// sql statement to retreive data
public type EmployeeInformation record { //Record which match columns in the table

    int emp_no;
    string birth_date;
    string first_name;
    string last_name;
    string gender;
    string hire_date;
};

endpoint mysql:Client employeeDBEndpoint { // mysql endpoint 
    host: config:getAsString("HOST"),  // read database host
    port: config:getAsInt("PORT"), // read database port
    name: config:getAsString("DB_NAME"), // name of database schema 
    username: config:getAsString("USERNAME"), // Credential to access database
    password: config:getAsString("PASSWORD"),
    dbOptions: { "useSSL": false },
    poolOptions: { maximumPoolSize: config:getAsInt("POOL_SIZE")}
};

public type EmployeeInformationDetails object {
    public function getEmployeeInformation(int employeeid) returns json;

};

function EmployeeInformationDetails::getEmployeeInformation(int employeeid) returns json {

    log:printInfo("Getting Employee information from Database");
    var empInfo = employeeDBEndpoint->select(QUERY_GET_EMPLOYEE_INFORMATION, EmployeeInformation, employeeid); // This will execute the query and 
                                                                                                               // return a EmployeeInformation record
    json err;
    match empInfo {
        table result => { // result will be a table type
            match <json>result{ // cast it to json
                json details => {
                    return details;
                }
                error e => {
                    err = getJsonError(e);  // return json type error if error occur in converting                  
                }
            }
        }
        error e => {
            err = getJsonError(e);  
        }
    }
    return err;
}

function getJsonError(error e) returns json { // error to json converter. 
    json err = {
        message: e.message
    };
    return err;
}
