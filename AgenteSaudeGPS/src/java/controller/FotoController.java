package controller;

/* ============================================================================
 *  FotoController
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Servir a foto de perfil do usuário
 *      - A foto é armazenada criptografada no banco
 *      - Aqui ocorre a descriptografia e envio como resposta HTTP
 * ============================================================================ */

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import modelDAO.ClientesDAO;
import util.CryptoUtil;

@WebServlet("/foto")
public class FotoController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* ---------------------------------------------------------------------
           VALIDAR ID RECEBIDO
        --------------------------------------------------------------------- */
        String idParam = request.getParameter("id");

        if (idParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID não informado");
            return;
        }

        int idUsuario;

        try {
            idUsuario = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID inválido");
            return;
        }

        /* ---------------------------------------------------------------------
           BUSCAR IMAGEM NO BANCO
        --------------------------------------------------------------------- */
        try {
            ClientesDAO dao = new ClientesDAO();
            byte[] fotoCriptografada = dao.buscarFoto(idUsuario);

            if (fotoCriptografada == null) {
                // Sem foto: retorna 404 (o frontend já tem fallback bonito)
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            String contentType = dao.buscarFotoContentType(idUsuario);
            if (contentType == null) {
                contentType = "image/jpeg";
            }

            /* -----------------------------------------------------------------
               DESCRIPTOGRAFAR A IMAGEM
            ----------------------------------------------------------------- */
            byte[] fotoBytes = CryptoUtil.decrypt(fotoCriptografada);

            /* -----------------------------------------------------------------
               ENVIAR IMAGEM PARA O NAVEGADOR
            ----------------------------------------------------------------- */
            response.setContentType(contentType);
            response.setContentLength(fotoBytes.length);
            response.getOutputStream().write(fotoBytes);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Erro ao carregar foto"
            );
        }
    }
}
