package controller;

/* ============================================================================
 *  ImagemController
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Servir imagens do banco (logos, prints, screenshots, etc.)
 * ============================================================================ */

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.OutputStream;

import modelDAO.ImagemDAO;
import model.Imagem;

@WebServlet("/imagem")
public class ImagemController extends HttpServlet {

    private final ImagemDAO dao = new ImagemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* ---------------------------------------------------------------------
           VALIDAR ID DO PARÂMETRO
        --------------------------------------------------------------------- */
        String idParam = request.getParameter("id");

        if (idParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID não informado.");
            return;
        }

        int id;

        try {
            id = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID inválido.");
            return;
        }

        /* ---------------------------------------------------------------------
           CARREGAR IMAGEM DO BANCO
        --------------------------------------------------------------------- */
        try {
            Imagem img = dao.buscarPorId(id);

            if (img == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Imagem não encontrada.");
                return;
            }

            /* -----------------------------------------------------------------
               ENVIAR AO NAVEGADOR
            ----------------------------------------------------------------- */
            response.setContentType(img.getTipo());
            response.setContentLength(img.getDados().length);

            OutputStream out = response.getOutputStream();
            out.write(img.getDados());
            out.flush();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Erro ao carregar a imagem."
            );
        }
    }
}
