package br.com.prova.idempiere.model;

/** Nomes compartilhados entre o Java e o Application Dictionary. */
public final class RequestColumns {

    public static final String TABLE_NAME = "PROVA_Request";
    public static final String KEY = "PROVA_Request_ID";
    public static final String DOCUMENT_NO = "DocumentNo";
    public static final String DATE_DOC = "DateDoc";
    public static final String BUSINESS_PARTNER = "C_BPartner_ID";
    public static final String PRODUCT = "M_Product_ID";
    public static final String DESCRIPTION = "Description";
    public static final String QTY = "Qty";
    public static final String PRICE = "PriceEntered";
    public static final String GRAND_TOTAL = "GrandTotal";
    public static final String STATUS = "Status";
    public static final String PROCESSED = "Processed";

    public static final String STATUS_DRAFTED = "D";
    public static final String STATUS_APPROVED = "A";
    public static final String STATUS_REJECTED = "R";

    private RequestColumns() {
    }
}

