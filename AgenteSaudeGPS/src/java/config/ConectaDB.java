package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * ======================================================================
 *  Classe: ConectaDB
 *  Autor : Filipe & Caio
 *  Descrição:
 *      Fornece conexão com o MySQL utilizando o driver JDBC moderno
 *      com suporte a UTF-8 e timezone configurado.
 * ======================================================================
 */
public class ConectaDB {

    public static Connection conectar() throws ClassNotFoundException {

        Connection conn = null;

        try {
            // Driver JDBC do MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");

            // URL com parâmetros para evitar problemas de charset e timezone
            String url =
                    "jdbc:mysql://localhost:3306/GPSforAgent"
                    + "?useUnicode=true"
                    + "&characterEncoding=UTF-8"
                    + "&characterSetResults=UTF-8"
                    + "&connectionCollation=utf8_general_ci"
                    + "&serverTimezone=America/Sao_Paulo";

            // Conexão (usuário e senha)
            conn = DriverManager.getConnection(url, "root", "");

        } catch (SQLException ex) {
            System.out.println("Erro de conexão com o banco: " + ex.getMessage());
        }

        return conn;
    }
}
