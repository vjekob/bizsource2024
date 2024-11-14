namespace Vjeko.Demos.Test;

using Vjeko.Demos;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Setup;

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
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        // [GIVEN] Default Customer Posting Group
        SalesSetup.Get;
        SalesSetup."Default Cust. Posting Group" := 'DUMMYGRP';
        SalesSetup.Modify(false);

        // [WHEN] Invoking CreateCustomer
        Demo.CreateCustomer('DUMMY', 'Dummy Customer');

        // [THEN] Customer is created
        Customer.Get('DUMMY');
        Assert.AreEqual('Dummy Customer', Customer.Name, 'Customer name is not as expected');
        Assert.AreEqual('DUMMYGRP', Customer."Customer Posting Group", 'Customer Posting Group is not as expected');
    end;

}
