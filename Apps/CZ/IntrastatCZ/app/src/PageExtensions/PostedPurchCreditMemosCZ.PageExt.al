// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Purchases.History;

pageextension 31348 "Posted Purch. Credit Memos CZ" extends "Posted Purchase Credit Memos"
{
    layout
    {
        addlast(Control1)
        {
            field("Intrastat Exclude CZ"; Rec."Intrastat Exclude CZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Exclude';
                Visible = false;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
            }
            field("Physical Transfer CZ"; Rec."Physical Transfer CZ")
            {
                ApplicationArea = SalesReturnOrder;
                Caption = 'Physical Transfer';
                ToolTip = 'Specifies if there is physical transfer of the item.';
                Visible = false;
            }
        }
    }
}