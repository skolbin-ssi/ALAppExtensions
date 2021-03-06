pageextension 31114 "Posted Service Shipments CZL" extends "Posted Service Shipments"
{
    layout
    {
        addlast(Control1)
        {
            field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
                Visible = false;
            }
            field("Physical Transfer CZL"; Rec."Physical Transfer CZL")
            {
                ApplicationArea = SalesReturnOrder;
                ToolTip = 'Specifies if there is physical transfer of the item.';
                Visible = false;
            }
        }
    }
}