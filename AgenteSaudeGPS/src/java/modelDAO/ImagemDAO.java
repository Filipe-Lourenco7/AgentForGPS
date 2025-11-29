package modelDAO;

import config.ConectaDB;
import model.Imagem;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/* ============================================================================
 *  Classe: ImagemDAO
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Inserir imagens no banco
 *      - Buscar imagem por ID
 *      - Listar imagens pertencentes a um usuário
 *
 *  Tabela relacionada: imagens
 * ============================================================================ */

public class ImagemDAO {

    /* =======================================================================
       SALVAR NOVA IMAGEM
       ======================================================================= */
    public void salvar(Imagem img) throws Exception {

        String sql = "INSERT INTO imagens (id_usuario, nome, tipo, dados) VALUES (?, ?, ?, ?)";

        try (Connection conn = ConectaDB.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, img.getIdUsuario());
            ps.setString(2, img.getNome());
            ps.setString(3, img.getTipo());
            ps.setBytes(4, img.getDados());

            ps.executeUpdate();
        }
    }

    /* =======================================================================
       BUSCAR IMAGEM POR ID
       ======================================================================= */
    public Imagem buscarPorId(int id) throws Exception {

        String sql = "SELECT * FROM imagens WHERE id = ?";

        try (Connection conn = ConectaDB.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Imagem img = new Imagem();

                img.setId(rs.getInt("id"));
                img.setIdUsuario(rs.getInt("id_usuario"));
                img.setNome(rs.getString("nome"));
                img.setTipo(rs.getString("tipo"));
                img.setDados(rs.getBytes("dados"));

                return img;
            }
        }

        return null;
    }

    /* =======================================================================
       LISTAR TODAS AS IMAGENS DE UM USUÁRIO
       ======================================================================= */
    public List<Imagem> listarPorUsuario(int idUsuario) throws Exception {

        List<Imagem> lista = new ArrayList<>();

        String sql = "SELECT id, nome FROM imagens WHERE id_usuario = ?";

        try (Connection conn = ConectaDB.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Imagem img = new Imagem();

                img.setId(rs.getInt("id"));
                img.setNome(rs.getString("nome"));

                lista.add(img);
            }
        }

        return lista;
    }
}
