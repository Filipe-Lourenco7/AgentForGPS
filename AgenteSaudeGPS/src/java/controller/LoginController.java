package controller;

/* ============================================================================
 *  LoginController
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Validar CAPTCHA
 *      - Autenticar usuário
 *      - Criar sessão
 *      - Aplicar “lembrar login”
 * ============================================================================ */

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.*;

import model.Cliente;
import modelDAO.ClientesDAO;

public class LoginController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* ---------------------------------------------------------------------
           VALIDAR CAPTCHA
        --------------------------------------------------------------------- */
        String captchaInput = request.getParameter("captcha_input");
        String captchaSession = (String) request.getSession().getAttribute("captcha");

        if (captchaSession == null || !captchaSession.equalsIgnoreCase(captchaInput)) {
            request.setAttribute("erro", "Captcha incorreto. Tente novamente.");
            request.getRequestDispatcher("login/login.jsp").forward(request, response);
            return;
        }

        /* ---------------------------------------------------------------------
           COLETAR CREDENCIAIS DO USUÁRIO
        --------------------------------------------------------------------- */
        String email = request.getParameter("email");
        String senha = request.getParameter("senha");

        ClientesDAO dao = new ClientesDAO();

        try {
            /* -----------------------------------------------------------------
               TENTAR AUTENTICAR
            ----------------------------------------------------------------- */
            Cliente cli = dao.autenticarRetornandoCliente(email, senha);

            if (cli == null) {
                request.setAttribute("erro", "E-mail ou senha inválidos!");
                request.getRequestDispatcher("login/login.jsp").forward(request, response);
                return;
            }

            /* -----------------------------------------------------------------
               LOGIN BEM-SUCEDIDO → CRIA SESSÃO
            ----------------------------------------------------------------- */
            HttpSession sessao = request.getSession();
            sessao.setAttribute("usuarioLogado", cli);
            sessao.setAttribute("cepUsuario", cli.getCep());
            sessao.setAttribute("idUsuario", cli.getId());
            sessao.setAttribute("nomeUsuario", cli.getName());
            sessao.setAttribute("emailUsuario", cli.getEmail());

            /* -----------------------------------------------------------------
               LEMBRAR LOGIN (COOKIE OPCIONAL)
            ----------------------------------------------------------------- */
            String lembrar = request.getParameter("lembrar");

            if ("true".equals(lembrar)) {
                Cookie cookie = new Cookie("usuarioLembrado", email);
                cookie.setMaxAge(60 * 60 * 24 * 7); // 7 dias
                cookie.setPath("/");
                response.addCookie(cookie);
            } else {
                Cookie cookie = new Cookie("usuarioLembrado", "");
                cookie.setMaxAge(0);
                cookie.setPath("/");
                response.addCookie(cookie);
            }

            /* -----------------------------------------------------------------
               REDIRECIONAR PARA O HOME
            ----------------------------------------------------------------- */
            response.sendRedirect(request.getContextPath() + "/site/home.jsp");

        } catch (ClassNotFoundException ex) {
            throw new ServletException(ex);
        }
    }
}
