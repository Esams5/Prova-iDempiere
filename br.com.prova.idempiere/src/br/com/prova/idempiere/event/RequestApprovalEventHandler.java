package br.com.prova.idempiere.event;

import java.util.logging.Level;

import org.adempiere.base.event.AbstractEventHandler;
import org.adempiere.base.event.IEventTopics;
import org.compiere.model.PO;
import org.compiere.util.CLogger;
import org.osgi.service.event.Event;

import br.com.prova.idempiere.model.RequestColumns;

/** observer OSGi para aprovacoes. */
public class RequestApprovalEventHandler extends AbstractEventHandler {

    private static final CLogger LOG = CLogger.getCLogger(RequestApprovalEventHandler.class);

    @Override
    protected void initialize() {
        registerTableEvent(IEventTopics.PO_AFTER_CHANGE, RequestColumns.TABLE_NAME);
    }

    @Override
    protected void doHandleEvent(Event event) {
        PO request = getPO(event);
        if (request != null
                && request.is_ValueChanged(RequestColumns.STATUS)
                && RequestColumns.STATUS_APPROVED.equals(
                    request.get_ValueAsString(RequestColumns.STATUS))) {
            LOG.log(Level.INFO, "Solicitacao aprovada via evento OSGi: {0}",
                request.get_ValueAsString(RequestColumns.DOCUMENT_NO));
        }
    }
}
