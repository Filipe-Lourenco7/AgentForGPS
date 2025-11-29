package controller;

/* ============================================================================
 *  RecuperarSenhaController
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Verifica se o e-mail existe
 *      - Envia e-mail de redefinição
 *      - Retorna mensagem amigável
 * ============================================================================ */

import java.io.IOException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import modelDAO.ClientesDAO;

public class RecuperarSenhaController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        ClientesDAO dao = new ClientesDAO();

        try {
            boolean existe = dao.emailExiste(email);

            if (existe) {

                String assunto = "Redefinição de Senha - GPS para Agentes";

                String mensagemHtml =
                        "<h2>Olá!</h2>"
                        + "<p>Recebemos um pedido para redefinir sua senha.</p>"
                        + "<p><a href='http://localhost:8080/AgenteSaudeGPS/login/redefinir-senha.jsp'>"
                        + "Clique aqui para redefinir sua senha</a></p>"
                        + "<p>Se você não fez este pedido, ignore este e-mail.</p>";

                EmailSender.enviarEmail(email, assunto, mensagemHtml);

                request.setAttribute(
                    "mensagemSucesso",
                    "E-mail encontrado! Um link de redefinição foi enviado."
                );

            } else {
                request.setAttribute(
                    "mensagemErro",
                    "E-mail não encontrado em nosso sistema."
                );
            }

            RequestDispatcher rd =
                request.getRequestDispatcher("login/esqueci-senha.jsp");
            rd.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
}
