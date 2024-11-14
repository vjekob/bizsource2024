namespace Vjeko.Demos.Test;

using Vjeko.Demos;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Customer;

codeunit 60001 "Test - Demo"
{
    Subtype = Test;

    var
        Demo: Codeunit Demo;
        Assert: Codeunit "Library Assert";

    [Test]
    procedure CreateCustomer()
    var
        Customer: Record Customer;
    begin
        // [WHEN] Invoking CreateCustomer
        Demo.CreateCustomer();

        // [THEN] Customer is created
        Customer.Get('DUMMY');
        Assert.AreEqual('Dummy Customer', Customer.Name, 'Customer name is not as expected');
    end;

}
