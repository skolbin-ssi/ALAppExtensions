codeunit 20601 "Basic Financials Mgmt BF"
{
    Access = Internal;

    var
        AzureADLicensing: codeunit "Azure AD Licensing";
        NotSupportedLicenseErr: Label 'To deploy the Basic Financials extension the Basic Financials license must be assigned to at least one user.';
        NotSupportedLocalesErr: Label 'The Basic Financials Extension can only available in Denmark and Iceland.';
        NotSupportedUserErr: Label 'The user who deploys the Basic Financials extension must have the Super User permission set.';
        NotSupportedCompanyErr: Label 'The Basic Financials extension can only be deployed when exactly one company exists in the environment.';
        AllProfileFilterTxt: Label 'MANUFACTURING|PROJECTS|SERVICES|WAREHOUSE|SHIPPING AND RECEIVING - WMS|SHIPPING AND RECEIVING|WAREHOUSE WORKER - WMS|PRODUCTION PLANNER|PROJECT MANAGER|DISPATCHER|SALES AND RELATIONSHIP MANAGER', Locked = true;
        BFSKUIdTxt: Label '{66CAD104-64F9-476E-9682-3C3518B9B6ED}', Locked = true, Comment = 'Dynamics 365 Business Central Basic Financials';
        BFC5SPLASKUIdTxt: Label '{4dCE07FD-7B07-4FB5-8FB7-D49653F7BF30}', Locked = true, Comment = 'Dynamics 365 Business Central Basic Financials from C5 SPLA (Qualified Offer)';
        UserSecurityIdTxt: Label '{00000000-0000-0000-0000-000000000001}', Locked = true, Comment = 'System user';
        NotSupportedSystemUserErr: Label 'The current user is the Microsoft System User. The Basic Financials Extension can only be deployed with a user that exist in the user table.';
        UnknowUserErr: Label 'The current user is unknown. The user who deploys the Basic Financials extension must exist in the user table.';

    internal procedure IsSupportedLicense(): Boolean // Microsoft requirements: The Basic Financials Assisted Setup checks for the Basic Financials license on the AAD tenant, at least one user has been assigned to this license.
    var
    begin
        AzureADLicensing.ResetSubscribedSKU();
        while AzureADLicensing.NextSubscribedSKU() do
            case UpperCase(AzureADLicensing.SubscribedSKUId()) of
                BFSKUIdTxt:
                    exit(true);
                BFC5SPLASKUIdTxt:
                    exit(true);
            end;
        exit(false);
    end;

    internal procedure TestSupportedLicenses() // Microsoft requirements: The extension checks for the Basic Financials license on the AAD tenant, at least one user has been assigned to this license. 
    var
    begin
        AzureADLicensing.ResetSubscribedSKU();
        while AzureADLicensing.NextSubscribedSKU() do
            case UpperCase(AzureADLicensing.SubscribedSKUId()) of
                BFSKUIdTxt:
                    exit;
                BFC5SPLASKUIdTxt:
                    exit;
            end;
        Error(NotSupportedLicenseErr);
    end;

    internal procedure TestSupportedLocales() // Microsoft requirements: The extension checks for the country availability. The extension is only available in Denmark and Iceland.;
    var
        TempApplicationAreaSetup: Record "Application Area Setup";
        AppAreaMgmt: Codeunit "App Area Mgmt BF";

    begin
        Clear(TempApplicationAreaSetup);
        AppAreaMgmt.GetEssentialExperienceAppAreas(TempApplicationAreaSetup);
        if TempApplicationAreaSetup."Basic DK" or TempApplicationAreaSetup."Basic IS" then
            exit;

        Error(NotSupportedLocalesErr);
    end;

    internal procedure TestSupportedUser() // Microsoft requirements: The extension checks whether the Super User permission set is assigned to the user who is installing the extension.
    var
        User: Record User;
        UserPermissions: Codeunit "User Permissions";
    begin
        if UserSecurityId() = UserSecurityIdTxt then
            Error(NotSupportedSystemUserErr);

        if User.Get(UserSecurityId()) then
            Error(UnknowUserErr);

        if UserPermissions.IsSuper(UserSecurityId()) then
            exit;

        Error(NotSupportedUserErr);
    end;

    internal procedure TestSupportedCompanies() // Microsoft requirements: The extension checks whether the tenant contains more than one company during installation, but allows additional companies to be added afterward.
    var
        Company: Record Company;
    begin
        Clear(Company);
        if Company.count() = 1 then
            exit;
        Error(NotSupportedCompanyErr);
    end;

    internal procedure TryDisableRoleCenter() // Microsoft requirement: The extensions aligns the user experience with the license limitations by disabling certain Role Centers that are not assigned to groups or users.
    var
        AllProfile: Record "All Profile";
    begin
        Clear(AllProfile);
        AllProfile.SetRange(Enabled, true);
        AllProfile.SetFilter("Profile ID", AllProfileFilterTxt);

        if AllProfile.FindSet(true, false) then
            repeat
                if not IsAssignedToGroupsOrUsers(AllProfile) then begin // Disable Role Center, which is not assigned to Groups Or Users. It is not possible to disable Role Center which is in use.
                    AllProfile.Enabled := false;
                    AllProfile.Promoted := false;
                    AllProfile.Modify();
                end;
            until AllProfile.Next() = 0;
    end;

    internal procedure IsAssignedToGroupsOrUsers(AllProfile: Record "All Profile"): Boolean
    var
        UserPersonalization: Record "User Personalization";
        UserGroup: Record "User Group";
    begin
        if AllProfile."Default Role Center" then
            exit(true);

        UserGroup.SetRange("Default Profile ID", AllProfile."Profile ID");
        UserGroup.SetRange("Default Profile App ID", AllProfile."App ID");
        if not UserGroup.IsEmpty() then
            exit(true);

        UserPersonalization.SetRange("Profile ID", AllProfile."Profile ID");
        UserPersonalization.SetRange("App ID", AllProfile."App ID");
        if not UserPersonalization.IsEmpty() then
            exit(true);

        exit(false);
    end;
}