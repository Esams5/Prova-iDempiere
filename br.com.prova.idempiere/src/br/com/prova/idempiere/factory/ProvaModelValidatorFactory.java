package br.com.prova.idempiere.factory;

import org.adempiere.base.IModelValidatorFactory;
import org.compiere.model.ModelValidator;

import br.com.prova.idempiere.validator.RequestModelValidator;

/** Disponibiliza o Model Validator ao class loader OSGi do iDempiere. */
public class ProvaModelValidatorFactory implements IModelValidatorFactory {

    private static final String VALIDATOR_CLASS = RequestModelValidator.class.getName();

    @Override
    public ModelValidator newModelValidatorInstance(String className) {
        return VALIDATOR_CLASS.equals(className) ? new RequestModelValidator() : null;
    }
}
