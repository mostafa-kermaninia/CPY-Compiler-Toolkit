package main.utils;

public enum DataType {
    INT,
    DOUBLE,
    FLOAT,
    CHAR,
    BOOL,
    STRING,
    VOID,
    UNDEFINED;

    /**
     * Converts a string to its corresponding DataType.
     */
    public static DataType fromString(String text) {
        if (text != null) {
            for (DataType dt : DataType.values()) {
                if (text.equalsIgnoreCase(dt.name())) {
                    return dt;
                }
            }
        }
        return DataType.UNDEFINED;
    }
}