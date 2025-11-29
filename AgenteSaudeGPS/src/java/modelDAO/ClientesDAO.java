package modelDAO;

import java.sql.*;
import config.ConectaDB;
import model.Cliente;

/* ============================================================================
 *  Classe: ClientesDAO
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Acessar e manipular dados da tabela "clientes"
 *      - Autenticação
 *      - Cadastro
 *      - Validação de e-mail
 *      - Atualização de dados gerais
 *      - Alteração de senha
 *      - Manipulação de foto criptografada
 * ============================================================================ */

public class ClientesDAO {

    /* =======================================================================
       AUTENTICAÇÃO SIMPLES (LEGADO)
       ======================================================================= */
    public boolean autenticar(Cliente cli) throws ClassNotFoundException {
        boolean autenticado = false;

        try (Connection conn = ConectaDB.conectar();
             PreparedStatement stmt = conn.prepareStatement(
                     "SELECT * FROM clientes WHERE email = ? AND senha = ?")) {

            stmt.setString(1, cli.getEmail());
            stmt.setString(2, cli.getSenha());

            ResultSet rs = stmt.executeQuery();
            autenticado = rs.next();
            rs.close();

        } catch (SQLException ex) {
            System.out.println("Erro ao autenticar: " + ex.getMessage());
        }

        return autenticado;
    }

    /* =======================================================================
       AUTENTICAÇÃO – RETORNA OBJETO COMPLETO
       ======================================================================= */
    public Cliente autenticarRetornandoCliente(String email, String senha) throws ClassNotFoundException {

        Cliente cli = null;

        try (Connection conn = ConectaDB.conectar();
             PreparedStatement stmt = conn.prepareStatement(
                     "SELECT * FROM clientes WHERE email = ? AND senha = ?")) {

            stmt.setString(1, email);
            stmt.setString(2, senha);

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                cli = new Cliente();
                cli.setId(rs.getInt("id"));
                cli.setName(rs.getString("name"));
                cli.setEmail(rs.getString("email"));
                cli.setSenha(rs.getString("senha"));
                cli.setCep(rs.getString("cep"));
            }

            rs.close();

        } catch (SQLException ex) {
            System.out.println("Erro ao autenticar (retornando cliente): " + ex.getMessage());
        }

        return cli;
    }

    /* =======================================================================
       CADASTRAR NOVO CLIENTE
       ======================================================================= */
    public boolean cadastrar(Cliente cli) throws ClassNotFoundException {

        boolean cadastrado = false;
        String sql = "INSERT INTO clientes (name, email, cep, senha) VALUES (?, ?, ?, ?)";

        try (Connection conn = ConectaDB.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, cli.getName());
            stmt.setString(2, cli.getEmail());
            stmt.setString(3, cli.getCep());
            stmt.setString(4, cli.getSenha());

            stmt.executeUpdate();
            cadastrado = true;

            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                cli.setId(rs.getInt(1));
            }
            rs.close();

        } catch (SQLException ex) {
            System.out.println("Erro ao cadastrar: " + ex.getMessage());
        }

        return cadastrado;
    }

    /* =======================================================================
       VERIFICAR SE EMAIL JÁ EXISTE
       ======================================================================= */
    public boolean emailExiste(String email) throws ClassNotFoundException {

        boolean existe = false;

        try (Connection conn = ConectaDB.conectar();
             PreparedStatement stmt = conn.prepareStatement(
                     "SELECT COUNT(*) FROM clientes WHERE email = ?")) {

            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                existe = rs.getInt(1) > 0;
            }

            rs.close();

        } catch (SQLException ex) {
            System.out.println("Erro ao verificar e-mail: " + ex.getMessage());
        }

        return existe;
    }

    /* =======================================================================
       ATUALIZAÇÃO DE FOTO (CRIPTOGRAFADA)
       ======================================================================= */
    public void atualizarFoto(int idCliente, byte[] fotoCriptografada, String contentType)
            throws ClassNotFoundException {

        String sql = "UPDATE clientes SET foto = ?, foto_content_type = ? WHERE id = ?";

        try (Connection conn = ConectaDB.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setBytes(1, fotoCriptografada);
            stmt.setString(2, contentType);
            stmt.setInt(3, idCliente);

            stmt.executeUpdate();

        } catch (SQLException ex) {
            System.out.println("Erro ao atualizar foto: " + ex.getMessage());
        }
    }

    public byte[] buscarFoto(int idCliente) throws ClassNotFoundException {

        byte[] foto = null;
        String sql = "SELECT foto FROM clientes WHERE id = ?";

        try (Connection conn = ConectaDB.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idCliente);

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                foto = rs.getBytes("foto");
            }

            rs.close();

        } catch (SQLException ex) {
            System.out.println("Erro ao buscar foto: " + ex.getMessage());
        }

        return foto;
    }

    public String buscarFotoContentType(int idCliente) throws ClassNotFoundException {

        String contentType = null;
        String sql = "SELECT foto_content_type FROM clientes WHERE id = ?";

        try (Connection conn = ConectaDB.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idCliente);

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                contentType = rs.getString("foto_content_type");
            }

            rs.close();

        } catch (SQLException ex) {
            System.out.println("Erro ao buscar content type: " + ex.getMessage());
        }

        return contentType;
    }

    /* =======================================================================
       ATUALIZAR DADOS DO CLIENTE (nome, email, cep)
       ======================================================================= */
    public void atualizarDados(Cliente cli) throws ClassNotFoundException {

        String sql = "UPDATE clientes SET name = ?, email = ?, cep = ? WHERE id = ?";

        try (Connection conn = ConectaDB.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, cli.getName());
            stmt.setString(2, cli.getEmail());
            stmt.setString(3, cli.getCep());
            stmt.setInt(4, cli.getId());

            stmt.executeUpdate();

        } catch (SQLException e) {
            System.out.println("Erro ao atualizar dados: " + e.getMessage());
        }
    }

    /* =======================================================================
       ALTERAR SENHA
       ======================================================================= */
    public void alterarSenha(int idCliente, String novaSenha) throws ClassNotFoundException {

        String sql = "UPDATE clientes SET senha = ? WHERE id = ?";

        try (Connection conn = ConectaDB.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, novaSenha);
            stmt.setInt(2, idCliente);
            stmt.executeUpdate();

        } catch (SQLException e) {
            System.out.println("Erro ao alterar senha: " + e.getMessage());
        }
    }
}
