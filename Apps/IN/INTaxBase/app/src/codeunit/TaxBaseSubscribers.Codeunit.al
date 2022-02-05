codeunit 18544 "Tax Base Subscribers"
{
    procedure GetTCSAmount(Amount: Decimal)
    begin
        OnAfterGetTCSAmount(Amount);
    end;

    procedure GetTCSAmountFromTransNo(TransactionNo: Integer; var Amount: Decimal)
    begin
        OnAfterGetTCSAmountFromTransNo(TransactionNo, Amount);
    end;

    procedure GetTDSAmount(Amount: Decimal)
    begin
        OnAfterGetTDSAmount(Amount);
    end;

    procedure GetTDSAmountFromTransNo(TransactionNo: Integer; var Amount: Decimal)
    begin
        OnAfterGetTDSAmountFromTransNo(TransactionNo, Amount);
    end;

    procedure GetGSTAmountFromTransNo(TransactionNo: Integer; DocumentNo: Code[20]; var GSTAmount: Decimal)
    begin
        OnAfterGetGSTAmountFromTransNo(TransactionNo, DocumentNo, GSTAmount);
    end;

    local procedure GetTaxComponentValuesFromRecID(
        RecID: RecordId;
        TaxTypeCode: Code[20];
        ComponentID: Integer;
        var ComponentRate: Decimal;
        var ComponentAmount: Decimal)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        if TaxTypeCode = '' then
            exit;

        TaxTransactionValue.SetRange("Tax Record ID", RecID);
        TaxTransactionValue.SetRange("Tax Type", TaxTypeCode);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        TaxTransactionValue.SetRange("Value ID", ComponentID);
        if TaxTransactionValue.FindFirst() then begin
            ComponentRate := TaxTransactionValue.Percent;
            ComponentAmount := TaxTransactionValue.Amount;
        end;
    end;

    procedure GetGSTAmountForSalesInvLines(SalesInvoiceLine: Record "Sales Invoice Line"; var GSTBaseAmount: Decimal; var GSTAmount: Decimal)
    begin
        OnAfterGetGSTAmountForSalesInvLines(SalesInvoiceLine, GSTBaseAmount, GSTAmount);
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeGetTaxComponentValuesFromRecID(RecID: RecordId; TaxTypeCode: Code[20]; ComponentID: Integer; var ComponentRate: Decimal; var ComponentAmount: Decimal)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Subscribers", 'OnBeforeGetTaxComponentValuesFromRecID', '', false, false)]
    local procedure TaxComponentValuesFromRecID(RecID: RecordId; TaxTypeCode: Code[20]; ComponentID: Integer; var ComponentRate: Decimal; var ComponentAmount: Decimal)
    begin
        GetTaxComponentValuesFromRecID(RecID, TaxTypeCode, ComponentID, ComponentRate, ComponentAmount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Applies-to Doc. No.', false, false)]
    local procedure OnAfterValidateEventAppliesToDocNo(var Rec: Record "Purchase Header")
    begin
        CallTaxEngineForPurchaseLines(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterAppliesToDocNoOnLookup', '', false, false)]
    local procedure OnAfterAppliesToDocNoOnLookup(var PurchaseHeader: Record "Purchase Header")
    begin
        CallTaxEngineForPurchaseLines(PurchaseHeader);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Applies-to ID', false, false)]
    local procedure OnAfterValidateEventPurchHeaderAppliesToID(var Rec: Record "Purchase Header")
    begin
        CallTaxEngineForPurchaseLines(Rec);
    end;

    [EventSubscriber(ObjectType::Table, database::"Sales Header", 'OnAfterValidateEvent', 'Applies-to Doc. No.', false, false)]
    local procedure OnAfterValidateAppliesToDoc(var Rec: Record "Sales Header")
    begin
        UpdateTaxAmount(Rec);
    end;

    [EventSubscriber(ObjectType::Table, database::"Sales Header", 'OnAfterAppliesToDocNoOnLookup', '', false, false)]
    local procedure OnAfterAppliesToDocNoOnLookupSales(var SalesHeader: Record "Sales Header")
    begin
        UpdateTaxAmount(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Applies-to Doc. No.', false, false)]
    local procedure OnAfterValidateAppliesToDocGeneral(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Apply", 'OnAfterRun', '', false, false)]
    local procedure OnAfterValidateAppliesToID(var GenJnlLine: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        OnBeforeCallingTaxEngineFromGenJnlLine(GenJnlLine);
        CalculateTax.CallTaxEngineOnGenJnlLine(GenJnlLine, GenJnlLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnLookUpAppliesToDocVendOnAfterUpdateDocumentTypeAndAppliesTo', '', false, false)]
    local procedure OnLookUpAppliesToDocVendOnAfterUpdateDocumentTypeAndAppliesTo(var GenJournalLine: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(GenJournalLine, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnLookUpAppliesToDocCustOnAfterUpdateDocumentTypeAndAppliesTo', '', false, false)]
    local procedure OnLookUpAppliesToDocCustOnAfterUpdateDocumentTypeAndAppliesTo(var GenJournalLine: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(GenJournalLine, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnIsRunningPreview', '', false, false)]
    local procedure OnIsPreviewNotification(var isPreview: Boolean)
    begin
        isPreview := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Thirty Day Trial Dialog", 'OnIsRunningPreview', '', false, false)]
    local procedure OnIsPreviewTrialDialog(var isPreview: Boolean)
    begin
        isPreview := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Extend Trial Wizard", 'OnIsRunningPreview', '', false, false)]
    local procedure OnIsPreviewExtendTrialDialog(var isPreview: Boolean)
    begin
        isPreview := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInitVAT', '', false, false)]
    local procedure OnBeforeInitVAT(var IsHandled: Boolean; var GenJournalLine: Record "Gen. Journal Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not VATPostingSetup.Get(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group") then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateVATProdPostingGroup', '', false, false)]
    local procedure OnBeforeValidateVATProdPostingGroupSalesLine(var IsHandled: Boolean; sender: Record "Sales Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not VATPostingSetup.Get(sender."VAT Bus. Posting Group", sender."VAT Prod. Posting Group") then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateVATProdPostingGroup', '', false, false)]
    local procedure OnBeforeValidateVATProdPostingGroupPurchaseLine(var IsHandled: Boolean; var PurchaseLine: Record "Purchase Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not VATPostingSetup.Get(PurchaseLine."VAT Bus. Posting Group", PurchaseLine."VAT Prod. Posting Group") then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnBeforeValidateVATProdPostingGroup', '', false, false)]
    local procedure OnBeforeValidateVATProdPostingGroupServiceLine(var IsHandled: Boolean; var ServiceLine: Record "Service Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not VATPostingSetup.Get(ServiceLine."VAT Bus. Posting Group", ServiceLine."VAT Prod. Posting Group") then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Line", 'OnValidateVATProdPostingGroupOnBeforeVATPostingSetupGet', '', false, false)]
    local procedure OnValidateVATProdPostingGroupOnBeforeVATPostingSetupGet(var IsHandled: Boolean; var FinanceChargeMemoLine: Record "Finance Charge Memo Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
    begin
        if FinanceChargeMemoHeader.Get(FinanceChargeMemoLine."Finance Charge Memo No.") then
            if not VATPostingSetup.Get(FinanceChargeMemoHeader."VAT Bus. Posting Group", FinanceChargeMemoLine."VAT Prod. Posting Group") then
                IsHandled := true;
    end;

    local procedure CallTaxEngineForPurchaseLines(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        PurchaseHeader.Modify();
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                OnBeforeCallingTaxEngineFromPurchLine(PurchaseHeader, PurchaseLine);
                CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, PurchaseLine);
            until PurchaseLine.Next() = 0;
    end;

    local procedure UpdateTaxAmount(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then begin
            SalesHeader.Modify();
            repeat
                CalculateTax.CallTaxEngineOnSalesLine(SalesLine, SalesLine);
            until SalesLine.Next() = 0;
        end;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCallingTaxEngineFromPurchLine(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCallingTaxEngineFromGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetTCSAmount(Amount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetTCSAmountFromTransNo(TransactionNo: Integer; var Amount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetTDSAmount(Amount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetTDSAmountFromTransNo(TransactionNo: Integer; var Amount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetGSTAmountFromTransNo(TransactionNo: Integer; DocumentNo: Code[20]; var GSTAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetGSTAmountForSalesInvLines(SalesInvoiceLine: Record "Sales Invoice Line"; var GSTBaseAmount: Decimal; var GSTAmount: Decimal)
    begin
    end;
}