package br.com.prova.idempiere.factory;

import org.adempiere.base.AnnotationBasedColumnCalloutFactory;
import org.adempiere.base.IColumnCalloutFactory;
import org.osgi.service.component.annotations.Component;

@Component(immediate = true, service = IColumnCalloutFactory.class,
    property = { "service.ranking:Integer=10" })
public class ProvaCalloutFactory extends AnnotationBasedColumnCalloutFactory {

    @Override
    protected String[] getPackages() {
        return new String[] { "br.com.prova.idempiere.callout" };
    }
}

