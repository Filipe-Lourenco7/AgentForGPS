package controller;

/* ============================================================================
 *  Servlet: ConfiguracoesController
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Processa a alteração de configurações do usuário.
 *      - Atualiza sessão e cookie de tema.
 *      - Redireciona com mensagem de sucesso.
 *
 *  Rotas:
 *      POST /configuracoes
 * ============================================================================ */

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/configuracoes")
public class ConfiguracoesController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* ----------------------------------------------------------------------
         * 1) DEFINIR SESSÃO DO USUÁRIO
         * ---------------------------------------------------------------------- */
        HttpSession session = request.getSession();

        /* ----------------------------------------------------------------------
         * 2) CAPTURAR DADOS DO FORMULÁRIO
         * ---------------------------------------------------------------------- */
        String tema = request.getParameter("tema");
        String notificacoes = request.getParameter("notificacoes") != null ? "on" : "off";

        /* ----------------------------------------------------------------------
         * 3) ATUALIZAR VALORES NA SESSÃO
         * ---------------------------------------------------------------------- */
        session.setAttribute("tema", tema);
        session.setAttribute("notificacoes", notificacoes);

        /* ----------------------------------------------------------------------
         * 4) ATUALIZAR COOKIE GLOBAL DO TEMA
         * ---------------------------------------------------------------------- */
        Cookie cookieTema = new Cookie("temaGlobal", tema);
        cookieTema.setMaxAge(60 * 60 * 24 * 365);   // dura 1 ano
        cookieTema.setPath("/");                    // acessível no projeto inteiro
        response.addCookie(cookieTema);

        /* ----------------------------------------------------------------------
         * 5) MENSAGEM DE SUCESSO PARA A VIEW
         * ---------------------------------------------------------------------- */
        request.setAttribute("sucesso", "Configurações atualizadas com sucesso!");

        /* ----------------------------------------------------------------------
         * 6) VOLTAR PARA A PÁGINA DE CONFIGURAÇÕES
         * ---------------------------------------------------------------------- */
        request.getRequestDispatcher("/site/configuracoes.jsp").forward(request, response);
    }
}
