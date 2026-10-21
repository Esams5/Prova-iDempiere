package br.com.prova.idempiere.callout;

import java.math.BigDecimal;
import java.util.Properties;

import org.adempiere.base.IColumnCallout;
import org.adempiere.base.annotation.Callout;
import org.compiere.model.GridField;
import org.compiere.model.GridTab;

import br.com.prova.idempiere.domain.RequestRules;
import br.com.prova.idempiere.model.RequestColumns;

@Callout(
    tableName = RequestColumns.TABLE_NAME,
    columnName = { RequestColumns.QTY, RequestColumns.PRICE }
)
public class CalculateTotalCallout implements IColumnCallout {

    @Override
    public String start(Properties ctx, int windowNo, GridTab tab, GridField field,
            Object value, Object oldValue) {
        BigDecimal qty = asBigDecimal(tab.getValue(RequestColumns.QTY));
        BigDecimal price = asBigDecimal(tab.getValue(RequestColumns.PRICE));
        tab.setValue(RequestColumns.GRAND_TOTAL, RequestRules.calculateTotal(qty, price));
        return null;
    }

    private BigDecimal asBigDecimal(Object value) {
        if (value == null) {
            return BigDecimal.ZERO;
        }
        if (value instanceof BigDecimal decimal) {
            return decimal;
        }
        return new BigDecimal(value.toString());
    }
}

