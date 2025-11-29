package modelDAO;

import config.ConectaDB;
import model.Marcador;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/* ============================================================================
 *  Classe: MarcadorDAO
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - CRUD completo dos marcadores no mapa
 *      - Suporte a múltiplos tipos de marcador (pin, casa, etc.)
 *      - Exclusão múltipla
 *
 *  Tabela relacionada: marcadores
 * ============================================================================ */

public class MarcadorDAO {

    /* =======================================================================
       OBTÉM CONEXÃO
       ======================================================================= */
    private Connection obterConexao() throws SQLException, ClassNotFoundException {
        return ConectaDB.conectar();
    }

    /* =======================================================================
       LISTAR MARCADORES POR USUÁRIO
       ======================================================================= */
    public List<Marcador> listarPorUsuario(int idUsuario) {

        List<Marcador> lista = new ArrayList<>();

        String sql = "SELECT id, id_usuario, lat, lng, nota, tipo "
                   + "FROM marcadores WHERE id_usuario = ?";

        try (Connection conn = obterConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Marcador m = new Marcador();
                m.setId(rs.getInt("id"));
                m.setIdUsuario(rs.getInt("id_usuario"));
                m.setLat(rs.getDouble("lat"));
                m.setLng(rs.getDouble("lng"));
                m.setNota(rs.getString("nota"));
                m.setTipo(rs.getString("tipo"));

                lista.add(m);
            }

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }

        return lista;
    }

    /* =======================================================================
       INSERIR MARCADOR
       ======================================================================= */
    public int inserir(Marcador m) {

        String sql = "INSERT INTO marcadores (id_usuario, lat, lng, nota, tipo) "
                   + "VALUES (?, ?, ?, ?, ?)";

        int idGerado = 0;

        try (Connection conn = obterConexao();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, m.getIdUsuario());
            ps.setDouble(2, m.getLat());
            ps.setDouble(3, m.getLng());
            ps.setString(4, m.getNota());
            ps.setString(5, m.getTipo());

            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                idGerado = rs.getInt(1);
            }

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }

        return idGerado;
    }

    /* =======================================================================
       EXCLUIR MARCADOR ÚNICO
       ======================================================================= */
    public boolean excluir(int idMarcador, int idUsuario) {

        String sql = "DELETE FROM marcadores WHERE id = ? AND id_usuario = ?";

        try (Connection conn = obterConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idMarcador);
            ps.setInt(2, idUsuario);

            return ps.executeUpdate() > 0;

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    /* =======================================================================
       EXCLUSÃO MÚLTIPLA
       ======================================================================= */
    public boolean excluirVarios(List<Integer> ids, int idUsuario) {

        if (ids == null || ids.isEmpty()) {
            return false;
        }

        String placeholders = ids.stream()
                .map(i -> "?")
                .collect(Collectors.joining(","));

        String sql = "DELETE FROM marcadores "
                   + "WHERE id_usuario = ? AND id IN (" + placeholders + ")";

        try (Connection conn = obterConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idUsuario);

            int index = 2;
            for (Integer id : ids) {
                ps.setInt(index++, id);
            }

            return ps.executeUpdate() > 0;

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    /* =======================================================================
       ATUALIZAR POSIÇÃO DO MARCADOR
       ======================================================================= */
    public boolean atualizarPosicao(int idMarcador, int idUsuario, double novaLat, double novaLng) {

        String sql = "UPDATE marcadores SET lat = ?, lng = ? "
                   + "WHERE id = ? AND id_usuario = ?";

        try (Connection conn = obterConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDouble(1, novaLat);
            ps.setDouble(2, novaLng);
            ps.setInt(3, idMarcador);
            ps.setInt(4, idUsuario);

            return ps.executeUpdate() > 0;

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    /* =======================================================================
       ATUALIZAR NOTA DO MARCADOR
       ======================================================================= */
    public boolean atualizarNota(int idMarcador, int idUsuario, String novaNota) {

        String sql = "UPDATE marcadores SET nota = ? "
                   + "WHERE id = ? AND id_usuario = ?";

        try (Connection conn = obterConexao();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, novaNota);
            ps.setInt(2, idMarcador);
            ps.setInt(3, idUsuario);

            return ps.executeUpdate() > 0;

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }
}
