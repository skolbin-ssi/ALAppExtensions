codeunit 11755 "Registration Log Mgt. CZL"
{
    var
        RegistrationLogCZL: Record "Registration Log CZL";
        ServiceConditionsURLTok: Label 'http://wwwinfo.mfcr.cz/ares/ares_podminky.html.cz', Locked = true;
        ValidRegNoQst: Label 'The  registration number is valid. Do you want to update information on the card?';
        InvalidRegNoMsg: Label 'We didn''t find a match for this number. Verify that you entered the correct number.';
        NotVerifiedRegNoMsg: Label 'We couldn''t verify the registration number. Try again later.';
        DescriptionLbl: Label 'Registration No. Validation Service Setup';

    procedure LogCustomer(Customer: Record Customer)
    begin
        InsertLogRegistration(Customer."Registration No. CZL", RegistrationLogCZL."Account Type"::Customer, Customer."No.");
    end;

    procedure LogVendor(Vendor: Record Vendor)
    begin
        InsertLogRegistration(Vendor."Registration No. CZL", RegistrationLogCZL."Account Type"::Vendor, Vendor."No.");
    end;

    procedure LogContact(Contact: Record Contact)
    begin
        InsertLogRegistration(Contact."Registration No. CZL", RegistrationLogCZL."Account Type"::Contact, Contact."No.");
    end;

    local procedure InsertLogRegistration(RegNo: Text[20]; AccType: Option; AccNo: Code[20])
    var
        NewRegistrationLogCZL: Record "Registration Log CZL";
    begin
        NewRegistrationLogCZL.Init();
        NewRegistrationLogCZL."Registration No." := RegNo;
        NewRegistrationLogCZL."Account Type" := AccType;
        NewRegistrationLogCZL."Account No." := AccNo;
        NewRegistrationLogCZL."User ID" := CopyStr(UserId(), 1, MaxStrLen(NewRegistrationLogCZL."User ID"));
        NewRegistrationLogCZL.Insert(true);
    end;

    procedure LogVerification(var NewRegistrationLogCZL: Record "Registration Log CZL"; XmlDoc: XmlDocument; Namespace: Text)
    var
        Address: array[10] of Text;
        AddressText: Text;
        Error: Text;
    begin
        if ExtractValue('//D:VBAS', XmlDoc, Namespace) <> '' then begin
            NewRegistrationLogCZL."Entry No." := 0;
            NewRegistrationLogCZL.Status := NewRegistrationLogCZL.Status::Valid;
            NewRegistrationLogCZL."Verified Date" := CurrentDateTime;
            NewRegistrationLogCZL."User ID" := CopyStr(UserId(), 1, MaxStrLen(NewRegistrationLogCZL."User ID"));

            // VAT Registration No.
            NewRegistrationLogCZL."Verified VAT Registration No." :=
              CopyStr(ExtractValue('//D:DIC', XmlDoc, Namespace), 1, MaxStrLen(NewRegistrationLogCZL."Verified VAT Registration No."));

            // Name
            NewRegistrationLogCZL."Verified Name" :=
              CopyStr(ExtractValue('//D:OF', XmlDoc, Namespace), 1, MaxStrLen(NewRegistrationLogCZL."Verified Name"));

            // Address information
            if ExtractValue('//D:AA', XmlDoc, Namespace) <> '' then begin
                // City
                NewRegistrationLogCZL."Verified City" :=
                  CopyStr(ExtractValue('//D:N', XmlDoc, Namespace), 1, MaxStrLen(NewRegistrationLogCZL."Verified City"));

                // Post Code
                NewRegistrationLogCZL."Verified Post Code" :=
                  CopyStr(ExtractValue('//D:PSC', XmlDoc, Namespace), 1, MaxStrLen(NewRegistrationLogCZL."Verified Post Code"));

                Address[1] := ExtractValue('//D:NU', XmlDoc, Namespace);  // Street
                Address[2] := ExtractValue('//D:NCO', XmlDoc, Namespace); // Quarter
                Address[3] := ExtractValue('//D:CD', XmlDoc, Namespace);  // Descriptive No.
                Address[4] := ExtractValue('//D:CO', XmlDoc, Namespace);  // House No.
                AddressText := ExtractValue('//D:AT', XmlDoc, Namespace); // Address Text
            end;

            NewRegistrationLogCZL."Verified Address" := CopyStr(FormatAddress(Address), 1, MaxStrLen(NewRegistrationLogCZL."Verified Address"));
            if NewRegistrationLogCZL."Verified Address" = '' then
                NewRegistrationLogCZL."Verified Address" := CopyStr(AddressText, 1, MaxStrLen(NewRegistrationLogCZL."Verified Address"));
            NewRegistrationLogCZL.Insert(true);
        end else begin
            if ExtractValue('//D:E', XmlDoc, Namespace) <> '' then
                Error := ExtractValue('//D:ET', XmlDoc, Namespace);

            NewRegistrationLogCZL."Entry No." := 0;
            NewRegistrationLogCZL."Verified Date" := CurrentDateTime;
            NewRegistrationLogCZL.Status := NewRegistrationLogCZL.Status::Invalid;
            NewRegistrationLogCZL."User ID" := CopyStr(UserId(), 1, MaxStrLen(NewRegistrationLogCZL."User ID"));
            NewRegistrationLogCZL."Verified Result" := CopyStr(Error, 1, MaxStrLen(NewRegistrationLogCZL."Verified Result"));
            NewRegistrationLogCZL."Verified Name" := '';
            NewRegistrationLogCZL."Verified Address" := '';
            NewRegistrationLogCZL."Verified City" := '';
            NewRegistrationLogCZL."Verified Post Code" := '';
            NewRegistrationLogCZL."Verified VAT Registration No." := '';
            NewRegistrationLogCZL.Insert(true);
        end;
    end;

    local procedure FormatAddress(Address: array[10] of Text): Text
    var
        FormatedAddress: Text;
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;
        ThreePlaceholdersTok: Label '%1 %2/%3', Locked = true;
    begin
        FormatedAddress := Address[1];
        if FormatedAddress = '' then
            FormatedAddress := Address[2];
        if (Address[3] <> '') and (Address[4] <> '') then
            FormatedAddress := CopyStr(StrSubstNo(ThreePlaceholdersTok, FormatedAddress, Address[3], Address[4]), 1, MaxStrLen(RegistrationLogCZL."Verified Address"));
        if (Address[3] <> '') xor (Address[4] <> '') then begin
            if Address[3] = '' then
                Address[3] := Address[4];
            FormatedAddress := CopyStr(StrSubstNo(TwoPlaceholdersTok, FormatedAddress, Address[3]), 1, MaxStrLen(RegistrationLogCZL."Verified Address"));
        end;
        exit(DelChr(FormatedAddress, '<>', ' '));
    end;

    local procedure LogUnloggedRegistrationNumbers(AccountType: Option; AccountNo: Code[20])
    var
        NewRegistrationLogCZL: Record "Registration Log CZL";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
    begin
        case AccountType of
            NewRegistrationLogCZL."Account Type"::Customer:
                if Customer.Get(AccountNo) then begin
                    NewRegistrationLogCZL.SetRange("Registration No.", Customer."Registration No. CZL");
                    if NewRegistrationLogCZL.IsEmpty() then
                        LogCustomer(Customer);
                end;
            NewRegistrationLogCZL."Account Type"::Vendor:
                if Vendor.Get(AccountNo) then begin
                    NewRegistrationLogCZL.SetRange("Registration No.", Vendor."Registration No. CZL");
                    if NewRegistrationLogCZL.IsEmpty() then
                        LogVendor(Vendor);
                end;
            NewRegistrationLogCZL."Account Type"::Contact:
                if Contact.Get(AccountNo) then begin
                    NewRegistrationLogCZL.SetRange("Registration No.", Contact."Registration No. CZL");
                    if NewRegistrationLogCZL.IsEmpty() then
                        LogContact(Contact);
                end;
        end;
    end;

    procedure DeleteCustomerLog(Customer: Record Customer)
    begin
        DeleteLogRegistration(RegistrationLogCZL."Account Type"::Customer, Customer."No.");
    end;

    procedure DeleteVendorLog(Vendor: Record Vendor)
    begin
        DeleteLogRegistration(RegistrationLogCZL."Account Type"::Vendor, Vendor."No.");
    end;

    procedure DeleteContactLog(Contact: Record Contact)
    begin
        DeleteLogRegistration(RegistrationLogCZL."Account Type"::Contact, Contact."No.");
    end;

    local procedure DeleteLogRegistration(AccountType: Option; AccountNo: Code[20])
    var
        DeletedRegistrationLogCZL: Record "Registration Log CZL";
    begin
        DeletedRegistrationLogCZL.SetRange(DeletedRegistrationLogCZL."Account Type", AccountType);
        DeletedRegistrationLogCZL.SetRange(DeletedRegistrationLogCZL."Account No.", AccountNo);
        DeletedRegistrationLogCZL.DeleteAll();
    end;

    procedure AssistEditCustomerRegNo(Customer: Record Customer)
    begin
        AssistEditRegNo(RegistrationLogCZL."Account Type"::Customer, Customer."No.");
    end;

    procedure AssistEditVendorRegNo(Vendor: Record Vendor)
    begin
        AssistEditRegNo(RegistrationLogCZL."Account Type"::Vendor, Vendor."No.");
    end;

    procedure AssistEditContactRegNo(Contact: Record Contact)
    begin
        AssistEditRegNo(RegistrationLogCZL."Account Type"::Contact, Contact."No.");
    end;

    local procedure AssistEditRegNo(AccountType: Option; AccountNo: Code[20])
    var
        AssistedRegistrationLogCZL: Record "Registration Log CZL";
    begin
        LogUnloggedRegistrationNumbers(AccountType, AccountNo);
        Commit();
        AssistedRegistrationLogCZL.SetRange(AssistedRegistrationLogCZL."Account Type", AccountType);
        AssistedRegistrationLogCZL.SetRange(AssistedRegistrationLogCZL."Account No.", AccountNo);
        Page.RunModal(Page::"Registration Log CZL", AssistedRegistrationLogCZL);
    end;

    procedure InitServiceSetup()
    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        RegLookupExtDataCZL: Codeunit "Reg. Lookup Ext. Data CZL";
    begin
        if not RegNoServiceConfigCZL.FindFirst() then begin
            RegNoServiceConfigCZL.Init();
            RegNoServiceConfigCZL.Insert();
        end;
        RegNoServiceConfigCZL."Service Endpoint" := RegLookupExtDataCZL.GetRegistrationNoValidationWebServiceURL();
        RegNoServiceConfigCZL.Enabled := false;
        RegNoServiceConfigCZL.Modify();
    end;

    procedure SetupService()
    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
    begin
        if not RegNoServiceConfigCZL.IsEmpty() then
            exit;
        InitServiceSetup();
    end;

    local procedure ExtractValue(Xpath: Text; XMLDoc: XmlDocument; Namespace: Text): Text
    var
        XMLNamespaceManager: XmlNamespaceManager;
        FoundXMLNode: XmlNode;
    begin
        XmlNamespaceManager.AddNamespace('D', Namespace);
        if XmlDoc.SelectSingleNode(XPath, XmlNamespaceManager, FoundXMLNode) then
            exit(FoundXMLNode.AsXmlElement().InnerXml());
    end;

    procedure CheckARESForRegNo(var RecordRef: RecordRef; var RegistrationLogCZL: Record "Registration Log CZL"; RecordVariant: Variant; EntryNo: Code[20]; AccountType: Option)
    var
        Contact: Record Contact;
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        DataTypeManagement: Codeunit "Data Type Management";
        RegNoFieldRef: FieldRef;
        RegNo: Text[20];
    begin
        DataTypeManagement.GetRecordRef(RecordVariant, RecordRef);
        if RegNoServiceConfigCZL.RegNoSrvIsEnabled() then begin
            if not DataTypeManagement.FindFieldByName(RecordRef, RegNoFieldRef, Contact.FieldName("Registration No. CZL")) then
                exit;
            RegNo := RegNoFieldRef.Value;
            RegistrationLogCZL.InitRegLog(RegistrationLogCZL, AccountType, EntryNo, RegNo);
            Codeunit.Run(Codeunit::"Reg. Lookup Ext. Data CZL", RegistrationLogCZL);
        end;
    end;

    procedure UpdateRecordFromRegLog(var RecordRef: RecordRef; RecordVariant: Variant; RegistrationLogCZL: Record "Registration Log CZL")
    var
        DataTypeManagement: Codeunit "Data Type Management";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        DataTypeManagement.GetRecordRef(RecordVariant, RecordRef);
        case RegistrationLogCZL.Status of
            RegistrationLogCZL.Status::Valid:
                if ConfirmManagement.GetResponse(ValidRegNoQst, false) then
                    RunARESUpdate(RecordRef, RecordVariant, RegistrationLogCZL);
            RegistrationLogCZL.Status::Invalid:
                Message(InvalidRegNoMsg);
            else
                Message(NotVerifiedRegNoMsg);
        end;
    end;

    procedure RunARESUpdate(var RecordRef: RecordRef; RecordVariant: Variant; RegistrationLogCZL: Record "Registration Log CZL")
    var
        AresUpdateCZL: Report "Ares Update CZL";
    begin
        AresUpdateCZL.InitializeReport(RecordVariant, RegistrationLogCZL);
        AresUpdateCZL.UseRequestPage(true);
        AresUpdateCZL.RunModal();
        AresUpdateCZL.GetRecord(RecordRef);
    end;

    procedure ValidateRegNoWithARES(var RecordRef: RecordRef; RecordVariant: Variant; EntryNo: Code[20]; AccountType: Option)
    var
        UpdatedRegistrationLogCZL: Record "Registration Log CZL";
    begin
        CheckARESForRegNo(RecordRef, UpdatedRegistrationLogCZL, RecordVariant, EntryNo, AccountType);
        if UpdatedRegistrationLogCZL.Find() then // Only update if the log was created
            UpdateRecordFromRegLog(RecordRef, RecordVariant, UpdatedRegistrationLogCZL);
    end;

    procedure GetServiceConditionsURL(): Text
    begin
        exit(ServiceConditionsURLTok);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure HandleAresRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        ServiceConfigRecordRef: RecordRef;
    begin
        SetupService();
        RegNoServiceConfigCZL.FindFirst();
        ServiceConfigRecordRef.GetTable(RegNoServiceConfigCZL);

        if RegNoServiceConfigCZL.Enabled then
            ServiceConnection.Status := ServiceConnection.Status::Enabled
        else
            ServiceConnection.Status := ServiceConnection.Status::Disabled;
        ServiceConnection.InsertServiceConnection(
              ServiceConnection, ServiceConfigRecordRef.RecordId, DescriptionLbl, RegNoServiceConfigCZL."Service Endpoint", Page::"Reg. No. Service Config CZL");
    end;
}
