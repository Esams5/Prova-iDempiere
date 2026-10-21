package br.com.prova.idempiere.factory;

import org.adempiere.base.AnnotationBasedEventManager;

/** Registra os delegates de evento somente quando o servico OSGi esta pronto. */
public class ProvaEventManager extends AnnotationBasedEventManager {

    @Override
    public String[] getPackages() {
        return new String[] { "br.com.prova.idempiere.event" };
    }
}
