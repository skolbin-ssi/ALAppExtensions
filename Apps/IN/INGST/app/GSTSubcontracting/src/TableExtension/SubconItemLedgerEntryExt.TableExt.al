﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Ledger;

tableextension 18467 "Subcon Item Ledger Entry Ext" extends "Item Ledger Entry"
{
    fields
    {
        field(18451; "Subcon Order No."; Code[20])
        {
            Caption = 'Subcon Order No.';
            DataClassification = EndUserIdentifiableInformation;
        }

    }

}
