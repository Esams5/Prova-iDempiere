package br.com.prova.idempiere.event;

import org.adempiere.base.annotation.EventTopicDelegate;
import org.adempiere.base.annotation.ModelEventTopic;
import org.adempiere.base.event.annotations.ModelEventDelegate;
import org.adempiere.base.event.annotations.po.AfterChange;
import org.compiere.util.CLogger;
import org.osgi.service.event.Event;

import br.com.prova.idempiere.model.MProvaRequest;
import br.com.prova.idempiere.model.RequestColumns;

/** observer OSGi para aprovacoes. */
@EventTopicDelegate
@ModelEventTopic(modelClass = MProvaRequest.class)
public class RequestApprovalEventHandler extends ModelEventDelegate<MProvaRequest> {

    private static final CLogger LOG = CLogger.getCLogger(RequestApprovalEventHandler.class);

    public RequestApprovalEventHandler(MProvaRequest request, Event event) {
        super(request, event);
    }

    @AfterChange
    public void afterChange() {
        MProvaRequest request = getModel();
        if (RequestColumns.STATUS_APPROVED.equals(request.getStatus())) {
            LOG.warning("Solicitacao aprovada via evento OSGi: " + request.getDocumentNo());
        }
    }
}
