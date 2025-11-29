package controller;

/* ============================================================================
 *  UploadFotoController
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Recebe upload de foto do usuário
 *      - Valida tipo e tamanho
 *      - Criptografa e salva no banco
 * ============================================================================ */

import java.io.IOException;
import java.io.InputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import modelDAO.ClientesDAO;
import util.CryptoUtil;

@WebServlet("/uploadFoto")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class UploadFotoController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sessao = request.getSession(false);

        if (sessao == null || sessao.getAttribute("idUsuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login/login.jsp");
            return;
        }

        int idUsuario = (Integer) sessao.getAttribute("idUsuario");

        Part filePart = request.getPart("foto");
        if (filePart == null || filePart.getSize() == 0) {
            request.setAttribute("erro", "Nenhum arquivo selecionado.");
            request.getRequestDispatcher("/site/upload-foto.jsp").forward(request, response);
            return;
        }

        String contentType = filePart.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            request.setAttribute("erro", "O arquivo precisa ser uma imagem.");
            request.getRequestDispatcher("/site/upload-foto.jsp").forward(request, response);
            return;
        }

        byte[] bytesFoto;
        try (InputStream is = filePart.getInputStream()) {
            bytesFoto = is.readAllBytes();
        }

        try {
            byte[] fotoCriptografada = CryptoUtil.encrypt(bytesFoto);

            ClientesDAO dao = new ClientesDAO();
            dao.atualizarFoto(idUsuario, fotoCriptografada, contentType);

            response.sendRedirect(request.getContextPath() + "/site/perfil.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("erro", "Erro ao salvar foto.");
            request.getRequestDispatcher("/site/upload-foto.jsp").forward(request, response);
        }
    }
}
