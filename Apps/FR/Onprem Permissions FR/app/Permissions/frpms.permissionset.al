permissionset 10800 "FR-PMS"
{
    Access = Public;
    Assignable = true;
    Caption = 'FR Payment Management System';

    Permissions = tabledata "Bank Account Buffer" = RIMD,
                  tabledata "Payment Address" = RIMD,
                  tabledata "Payment Class" = RIMD,
                  tabledata "Payment Header" = RIMD,
                  tabledata "Payment Header Archive" = RIMD,
                  tabledata "Payment Line" = RIMD,
                  tabledata "Payment Line Archive" = RIMD,
                  tabledata "Payment Post. Buffer" = RIMD,
                  tabledata "Payment Status" = RIMD,
                  tabledata "Payment Step" = RIMD,
                  tabledata "Payment Step Ledger" = RIMD,
                  tabledata "Unreal. CV Ledg. Entry Buffer" = RIMD;
}
