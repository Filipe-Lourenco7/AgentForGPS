package controller;

/* ============================================================================
 *  UploadImagemController
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Recebe upload de imagens públicas
 *      - Salva no banco (ImagemDAO)
 *      - Redireciona para a landing page com mensagem de sucesso
 * ============================================================================ */

import java.io.IOException;
import java.io.InputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import model.Imagem;
import modelDAO.ImagemDAO;

@WebServlet("/uploadImagem")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 10 * 1024 * 1024,       // 10MB
    maxRequestSize = 15 * 1024 * 1024
)
public class UploadImagemController extends HttpServlet {

    private final ImagemDAO dao = new ImagemDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int idUsuario = 0; // imagens públicas

        Part arquivo = request.getPart("imagem");
        if (arquivo == null || arquivo.getSize() == 0) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?erro=1");
            return;
        }

        String nome = arquivo.getSubmittedFileName();
        String tipo = arquivo.getContentType();

        byte[] dados;
        try (InputStream is = arquivo.getInputStream()) {
            dados = is.readAllBytes();
        }

        Imagem img = new Imagem();
        img.setIdUsuario(idUsuario);
        img.setNome(nome);
        img.setTipo(tipo);
        img.setDados(dados);

        try {
            dao.salvar(img);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/index.jsp?erro=1");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/index.jsp?ok=1");
    }
}
