package br.edu.ufabc.compilador.definitions;

public class Variables {

    public static final String NUMBER = "TYPE__number";

    private String name;
    private String value;
    private DataTypes type;

    public Variables(String name, String value, DataTypes type)
    {
        this.type = type;
        this.value = value;
        this.name = name;
    }

    public Variables(String name)
    {
        this.name = name;
        this.type = DataTypes.TYPE_STRING;
        this.value = "";
    }

    @Override
    public String toString()
    {
        return this.name;
    }

    // TODO realizar o cast de acordo com o tipo da variavel
    public String getValue() {

        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String getType() {
        String[] array = type.toString().split("_");
        if(array[1] != null)
            if(!array[1].equals("STRING"))
                return array[1].toLowerCase();
            else
                return "String";
        return "TYPE_NOT_SET";
    }

    public void setType(DataTypes type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Variables getCopy() { return new Variables(this.name, this.value, this.type); }
}
