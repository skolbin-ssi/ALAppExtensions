permissionset 18359 "D365 Common Access - India GST"
{
    Access = Internal;
    Assignable = false;
    Caption = 'D365 Common Access - India GST';

    Permissions = tabledata "Applied Delivery Challan Entry" = RMID,
                  tabledata "Applied Delivery Challan" = RMID,
                  tabledata "Delivery Challan Header" = RIMD,
                  tabledata "Delivery Challan Line" = RIMD,
                  tabledata "GST Journal Template" = RMID,
                  tabledata "GST Journal Batch" = RMID,
                  tabledata "GST Journal Line" = RMID,
                  tabledata "GST Adjustment Buffer" = RMID,
                  tabledata "GST Liability Line" = RIMD,
                  tabledata "Multiple Subcon. Order Details" = RMID,
                  tabledata "Posted Applied DeliveryChallan" = RIMD,
                  tabledata "Posted GST Liability Line" = RMID,
                  tabledata "Sub. Comp. Rcpt. Header" = RMID,
                  tabledata "Sub. Comp. Rcpt. Line" = RMID,
                  tabledata "Subcon. Delivery Challan Line" = RMID,
                  tabledata "Subcontractor Delivery Challan" = RMID,
                  tabledata "Sub Order Comp. List Vend" = RMID,
                  tabledata "Sub Order Component List" = RMID,
                  tabledata "Bank Charge" = RIMD,
                  tabledata "Bank Charge Deemed Value Setup" = RIMD,
                  tabledata "Detailed Cr. Adjstmnt. Entry" = RIMD,
                  tabledata "Detailed GST Dist. Entry" = RIMD,
                  tabledata "Detailed GST Entry Buffer" = RIMD,
                  tabledata "Detailed GST Ledger Entry" = RIMD,
                  tabledata "Detailed GST Ledger Entry Info" = RIMD,
                  tabledata "Dist. Component Amount" = RIMD,
                  tabledata "E-Commerce Merchant" = RIMD,
                  tabledata "E-Comm. Merchant" = RIMD,
                  tabledata "GST Application Buffer" = RIMD,
                  tabledata "GST Claim Setoff" = RIMD,
                  tabledata "GST Component Distribution" = RIMD,
                  tabledata "GST Credit Adjustment Journal" = RIMD,
                  tabledata "GST Distribution Header" = RIMD,
                  tabledata "GST Distribution Line" = RIMD,
                  tabledata "GST Group" = RIMD,
                  tabledata "GST Ledger Entry" = RIMD,
                  tabledata "GST Liability Adjustment" = RIMD,
                  tabledata "GST Liability Buffer" = RIMD,
                  tabledata "GST Payment Buffer" = RIMD,
                  tabledata "GST Payment Buffer Details" = RIMD,
                  tabledata "GST Posting Buffer" = RIMD,
                  tabledata "GST Posting Setup" = RIMD,
                  tabledata "GST Recon. Mapping" = RIMD,
                  tabledata "GST Reconcilation" = RIMD,
                  tabledata "GST Reconcilation Line" = RIMD,
                  tabledata "GST Registration Nos." = RIMD,
                  tabledata "GST Setup" = RIMD,
                  tabledata "GST TDS/TCS Entry" = RIMD,
                  tabledata "GST Tracking Entry" = RIMD,
                  tabledata "HSN/SAC" = RIMD,
                  tabledata "ISD Ledger" = RIMD,
                  tabledata "Journal Bank Charges" = RIMD,
                  tabledata "Periodic GSTR-2A Data" = RIMD,
                  tabledata "Posted GST Distribution Header" = RIMD,
                  tabledata "Posted GST Distribution Line" = RIMD,
                  tabledata "Posted GST Liability Adj." = RIMD,
                  tabledata "Posted GST Reconciliation" = RIMD,
                  tabledata "Posted Jnl. Bank Charges" = RIMD,
                  tabledata "Posted Settlement Entries" = RIMD,
                  tabledata "Reference Invoice No." = RIMD,
                  tabledata "Retrun & Reco. Components" = RIMD,
                  tabledata "Service Transfer Header" = RIMD,
                  tabledata "Service Transfer Line" = RIMD,
                  tabledata "Service Transfer Rcpt. Header" = RIMD,
                  tabledata "Service Transfer Rcpt. Line" = RIMD,
                  tabledata "Service Transfer Shpt. Header" = RIMD,
                  tabledata "Service Transfer Shpt. Line" = RIMD,
                  tabledata "Transfer Buffer" = RIMD;
}

