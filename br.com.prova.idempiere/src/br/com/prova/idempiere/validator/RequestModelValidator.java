package br.com.prova.idempiere.validator;

import java.math.BigDecimal;

import org.compiere.model.MClient;
import org.compiere.model.ModelValidationEngine;
import org.compiere.model.ModelValidator;
import org.compiere.model.PO;

import br.com.prova.idempiere.domain.RequestRules;
import br.com.prova.idempiere.model.RequestColumns;

public class RequestModelValidator implements ModelValidator {

    private int clientId = -1;

    @Override
    public void initialize(ModelValidationEngine engine, MClient client) {
        if (client != null) {
            clientId = client.getAD_Client_ID();
        }
        engine.addModelChange(RequestColumns.TABLE_NAME, this);
    }

    @Override
    public int getAD_Client_ID() {
        return clientId;
    }

    @Override
    public String login(int AD_Org_ID, int AD_Role_ID, int AD_User_ID) {
        return null;
    }

    @Override
    public String modelChange(PO po, int type) {
        if (!RequestColumns.TABLE_NAME.equals(po.get_TableName())) {
            return null;
        }

        if (type == TYPE_BEFORE_CHANGE && isYes(po.get_ValueOld(RequestColumns.PROCESSED))) {
            return "Solicitacoes aprovadas nao podem ser alteradas.";
        }

        if (type == TYPE_BEFORE_NEW || type == TYPE_BEFORE_CHANGE) {
            return RequestRules.validate(
                asBigDecimal(po.get_Value(RequestColumns.QTY)),
                asBigDecimal(po.get_Value(RequestColumns.PRICE)));
        }
        return null;
    }

    @Override
    public String docValidate(PO po, int timing) {
        return null;
    }

    private BigDecimal asBigDecimal(Object value) {
        return value instanceof BigDecimal decimal ? decimal : null;
    }

    private boolean isYes(Object value) {
        return Boolean.TRUE.equals(value) || "Y".equals(value);
    }
}

