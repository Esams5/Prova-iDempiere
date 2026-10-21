package br.com.prova.idempiere.domain;

import java.math.BigDecimal;


public final class RequestRules {

    private RequestRules() {
    }

    public static BigDecimal calculateTotal(BigDecimal qty, BigDecimal price) {
        BigDecimal safeQty = qty == null ? BigDecimal.ZERO : qty;
        BigDecimal safePrice = price == null ? BigDecimal.ZERO : price;
        return safeQty.multiply(safePrice);
    }

    public static String validate(BigDecimal qty, BigDecimal price) {
        if (qty == null || qty.signum() <= 0) {
            return "A quantidade deve ser maior que zero.";
        }
        if (price == null || price.signum() < 0) {
            return "O preco unitario nao pode ser negativo.";
        }
        return null;
    }
}

