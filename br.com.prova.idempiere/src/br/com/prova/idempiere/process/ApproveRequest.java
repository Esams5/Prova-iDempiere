package br.com.prova.idempiere.process;

import org.adempiere.base.annotation.Process;
import org.adempiere.exceptions.AdempiereException;
import org.compiere.process.SvrProcess;

import br.com.prova.idempiere.domain.RequestRules;
import br.com.prova.idempiere.model.MProvaRequest;
import br.com.prova.idempiere.model.RequestColumns;

@Process
public class ApproveRequest extends SvrProcess {

    @Override
    protected void prepare() {
        // O processo usa o registro corrente da janela; nao possui parametros proprios.
    }

    @Override
    protected String doIt() {
        if (getRecord_ID() <= 0) {
            throw new AdempiereException("Selecione uma solicitacao para aprovar.");
        }

        MProvaRequest request = new MProvaRequest(getCtx(), getRecord_ID(), get_TrxName());
        if (request.get_ID() <= 0) {
            throw new AdempiereException("Solicitacao nao encontrada.");
        }
        if (RequestColumns.STATUS_APPROVED.equals(request.getStatus())) {
            return "Solicitacao ja estava aprovada: " + request.getDocumentNo();
        }

        String validation = RequestRules.validate(request.getQty(), request.getPriceEntered());
        if (validation != null) {
            throw new AdempiereException(validation);
        }

        request.setGrandTotal(RequestRules.calculateTotal(request.getQty(), request.getPriceEntered()));
        request.approve();
        request.saveEx();
        return "Solicitacao " + request.getDocumentNo() + " aprovada. Total: "
            + request.getGrandTotal();
    }
}

