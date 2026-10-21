package br.com.prova.idempiere.factory;

import org.adempiere.base.AnnotationBasedProcessFactory;
import org.adempiere.base.IProcessFactory;
import org.osgi.service.component.annotations.Component;

@Component(immediate = true, service = IProcessFactory.class,
    property = { "service.ranking:Integer=10" })
public class ProvaProcessFactory extends AnnotationBasedProcessFactory {

    @Override
    protected String[] getPackages() {
        return new String[] { "br.com.prova.idempiere.process" };
    }
}

