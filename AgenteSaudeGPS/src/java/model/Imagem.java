package model;

/* ============================================================================
 *  Classe: Imagem
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Representa uma imagem salva no banco
 *      - Pode ser usada para logos, banners, prints, etc.
 * ============================================================================ */

public class Imagem {

    private int id;
    private int idUsuario;
    private String nome;
    private String tipo;
    private byte[] dados;

    // ID
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }

    // Usuário dono (0 para imagem pública)
    public int getIdUsuario() {
        return idUsuario;
    }
    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    // Nome do arquivo original
    public String getNome() {
        return nome;
    }
    public void setNome(String nome) {
        this.nome = nome;
    }

    // ContentType (image/png, image/jpeg, etc.)
    public String getTipo() {
        return tipo;
    }
    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    // Binário da imagem
    public byte[] getDados() {
        return dados;
    }
    public void setDados(byte[] dados) {
        this.dados = dados;
    }
}
