package model;

/**
 * @author Filipe & Caio
 */
public class Cliente {
    private int id;
    private String name;
    private String email;
    private String cep;
    private String senha;

    // SETTERS
    public void setId(int p_id) { this.id = p_id; }
    public void setName(String p_name) { this.name = p_name; }
    public void setEmail(String p_email) { this.email = p_email; }
    public void setCep(String p_cep) { this.cep = p_cep; }
    public void setSenha(String p_senha) { this.senha = p_senha; }

    // GETTERS
    public int getId() { return this.id; }
    public String getName() { return this.name; }
    public String getEmail() { return this.email; }
    public String getCep() { return this.cep; }
    public String getSenha() { return this.senha; }
}
