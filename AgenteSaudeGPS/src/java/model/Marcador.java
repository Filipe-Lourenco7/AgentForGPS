package model;

/* ============================================================================
 *  Classe: Marcador
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Representa um marcador no mapa
 *      - Contém posição (lat/lng), tipo (pin/casa/etc.) e anotação
 *      - Associado a um usuário específico
 * ============================================================================ */

public class Marcador {

    private int id;
    private int idUsuario;
    private double lat;
    private double lng;
    private String nota;
    private String tipo;

    // ID do marcador
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }

    // ID do usuário dono deste marcador
    public int getIdUsuario() {
        return idUsuario;
    }
    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    // Latitude
    public double getLat() {
        return lat;
    }
    public void setLat(double lat) {
        this.lat = lat;
    }

    // Longitude
    public double getLng() {
        return lng;
    }
    public void setLng(double lng) {
        this.lng = lng;
    }

    // Anotação vinculada ao marcador
    public String getNota() {
        return nota;
    }
    public void setNota(String nota) {
        this.nota = nota;
    }

    // Tipo visual do marcador (ex: "pin", "casa")
    public String getTipo() {
        return tipo;
    }
    public void setTipo(String tipo) {
        this.tipo = tipo;
    }
}
