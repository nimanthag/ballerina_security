import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/config;
import ballerina/mysql;

endpoint http:Listener listener {
    port: 8005 
};

@http:ServiceConfig {
    basePath: "/office"
}

service<http:Service> EmployeeService bind listener {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/employee/{employeeidVar}"
    }

    getEmployeeInformation(endpoint caller, http:Request request,string employeeidVar) {
        log:printInfo("Retrieving Employee Information...");
        http:Response response = new;
        int employeeId = check<int>employeeidVar;

        EmployeeInformationDetails empInfoData = new;
        match empInfoData.getEmployeeInformation(employeeId) {
            json result => {
                response.setJsonPayload(untaint result);
            }
        }

        caller->respond(response) but {
            error e => log:printError("Error when responding", err = e)
        };

    }

}