PermissionSet 1432 "Satisfaction Survey - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Upgrade Tags - Read";

    Permissions = tabledata "Add-in" = r,
                  tabledata "Net Promoter Score" = r,
                  tabledata "Net Promoter Score Setup" = r,
                  tabledata "User Property" = r;
}
