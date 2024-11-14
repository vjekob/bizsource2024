namespace Vjeko.Demos.Test;

using Vjeko.Demos;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Comment;
using Microsoft.Sales.History;
using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Setup;
using Microsoft.Inventory.Item;

codeunit 60003 "Test - ProcessQuotes"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";

    local procedure CreateQuote(var SalesHeader: Record "Sales Header") OrderNo: Code[20]
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        LocationCode: Code[10];
    begin
        LibraryInventory.CreateItem(Item);
        LibraryInventory.CreateLocationWithInventory(LocationCode, '', Item."No.", 100);
        LibrarySales.CreateSalesQuoteForCustomerNo(SalesHeader, CreateCustomer());
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("Shipment Date", Today());
        SalesHeader.Modify();

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        LibrarySales.CreateCustomer(Customer);
        SalesSetup.Get();
        if SalesSetup."VDE Domestic Cust. Post. Group" = '' then begin
            SalesSetup."VDE Domestic Cust. Post. Group" := Customer."Customer Posting Group";
            SalesSetup.Modify();
        end;
        Customer.Validate("Customer Posting Group", SalesSetup."VDE Domestic Cust. Post. Group");
        Customer.Modify();
        exit(Customer."No.");
    end;

    [Test]
    procedure TestSuccessfulQuoteConversion()
    var
        SalesHeader: Record "Sales Header";
        ProcessQuotes: Codeunit ProcessQuotes;
        ShipmentNo: Code[20];
    begin
        // [GIVEN] A sales quote with sufficient inventory
        CreateQuote(SalesHeader);

        // [WHEN] Process quotes is run
        ProcessQuotes.ProcessQuotes();

        // [THEN] Quote is converted and shipment is posted
        ShipmentNo := FindPostedShipment(SalesHeader."No.");
        Assert.AreNotEqual('', ShipmentNo, 'Shipment should be posted');
    end;

    [Test]
    procedure TestInsufficientInventory()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ProcessQuotes: Codeunit ProcessQuotes;
        ShipmentNo: Code[20];
    begin
        // [GIVEN] A sales quote with insufficient inventory
        CreateQuote(SalesHeader);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        SalesLine.Validate(Quantity, 1000);
        SalesLine.Modify();

        // [WHEN] Process quotes is run
        ProcessQuotes.ProcessQuotes();

        // [THEN] No shipment is posted
        ShipmentNo := FindPostedShipment(SalesHeader."No.");
        Assert.AreEqual('', ShipmentNo, 'Shipment should not be posted');
    end;

    local procedure FindPostedShipment(QuoteNo: Code[20]): Code[20]
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        SalesShipmentHeader.SetRange("Order No.", GetOrderNo(QuoteNo));
        if SalesShipmentHeader.FindFirst() then
            exit(SalesShipmentHeader."No.");
    end;

    local procedure GetOrderNo(QuoteNo: Code[20]): Code[20]
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        SalesCommentLine.SetRange("Document Type", SalesCommentLine."Document Type"::Order);
        SalesCommentLine.SetRange("Quote No.", QuoteNo);
        if SalesCommentLine.FindFirst() then
            exit(SalesCommentLine."No.");
    end;
}
