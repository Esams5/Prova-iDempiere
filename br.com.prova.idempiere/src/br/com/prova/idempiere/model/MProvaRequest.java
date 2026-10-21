package br.com.prova.idempiere.model;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.util.Properties;

import org.compiere.model.PO;
import org.compiere.model.POInfo;
import org.compiere.model.MTable;

/** Modelo leve escrito a mao para manter o exemplo autocontido. */
public class MProvaRequest extends PO {

    private static final long serialVersionUID = 1L;
    public static final String Table_Name = RequestColumns.TABLE_NAME;
    private static final int ACCESS_LEVEL = 3;

    public MProvaRequest(Properties ctx, int PROVA_Request_ID, String trxName) {
        super(ctx, PROVA_Request_ID, trxName);
    }

    public MProvaRequest(Properties ctx, ResultSet rs, String trxName) {
        super(ctx, rs, trxName);
    }

    @Override
    protected POInfo initPO(Properties ctx) {
        int tableId = MTable.getTable_ID(RequestColumns.TABLE_NAME, get_TrxName());
        return POInfo.getPOInfo(ctx, tableId, get_TrxName());
    }

    @Override
    protected int get_AccessLevel() {
        return ACCESS_LEVEL;
    }

    @Override
    public String toString() {
        return "MProvaRequest[" + get_ID() + "," + getDocumentNo() + "]";
    }

    public String getDocumentNo() {
        return get_ValueAsString(RequestColumns.DOCUMENT_NO);
    }

    public BigDecimal getQty() {
        return asBigDecimal(get_Value(RequestColumns.QTY));
    }

    public BigDecimal getPriceEntered() {
        return asBigDecimal(get_Value(RequestColumns.PRICE));
    }

    public BigDecimal getGrandTotal() {
        return asBigDecimal(get_Value(RequestColumns.GRAND_TOTAL));
    }

    public String getStatus() {
        return get_ValueAsString(RequestColumns.STATUS);
    }

    public void setGrandTotal(BigDecimal value) {
        // Campos calculados e de estado sao somente leitura na janela, mas o
        // processo do servidor precisa atualiza-los explicitamente.
        set_ValueNoCheck(RequestColumns.GRAND_TOTAL, value);
    }

    public void approve() {
        set_ValueNoCheck(RequestColumns.STATUS, RequestColumns.STATUS_APPROVED);
        set_ValueNoCheck(RequestColumns.PROCESSED, true);
    }

    private BigDecimal asBigDecimal(Object value) {
        return value instanceof BigDecimal decimal ? decimal : BigDecimal.ZERO;
    }
}

