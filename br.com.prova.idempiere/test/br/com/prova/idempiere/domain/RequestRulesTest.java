package br.com.prova.idempiere.domain;

import java.math.BigDecimal;

/** Teste executavel sem JUnit para nao exigir dependencias externas. */
public final class RequestRulesTest {

    private RequestRulesTest() {
    }

    public static void main(String[] args) {
        assertDecimalEquals(new BigDecimal("25.00"), RequestRules.calculateTotal(
            new BigDecimal("2.5"), new BigDecimal("10.00")));
        assertEquals("0", RequestRules.calculateTotal(null, BigDecimal.TEN).toPlainString());
        assertNull(RequestRules.validate(BigDecimal.ONE, BigDecimal.ZERO));
        assertEquals("A quantidade deve ser maior que zero.",
            RequestRules.validate(BigDecimal.ZERO, BigDecimal.ONE));
        assertEquals("O preco unitario nao pode ser negativo.",
            RequestRules.validate(BigDecimal.ONE, new BigDecimal("-0.01")));
        System.out.println("RequestRulesTest: OK");
    }

    private static void assertEquals(String expected, String actual) {
        if (!expected.equals(actual)) {
            throw new AssertionError("Esperado '" + expected + "', obtido '" + actual + "'");
        }
    }

    private static void assertNull(Object value) {
        if (value != null) {
            throw new AssertionError("Esperado null, obtido '" + value + "'");
        }
    }

    private static void assertDecimalEquals(BigDecimal expected, BigDecimal actual) {
        if (expected.compareTo(actual) != 0) {
            throw new AssertionError("Esperado '" + expected + "', obtido '" + actual + "'");
        }
    }
}
