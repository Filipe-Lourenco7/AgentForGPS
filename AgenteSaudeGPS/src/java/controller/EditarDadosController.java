package controller;

/* ============================================================================
 *  Servlet: EditarDadosController
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Atualiza nome, e-mail e CEP do usuário.
 *      - Valida sessão.
 *      - Persiste no banco e atualiza sessão.
 *
 *  Rota:
 *      POST /editarDados
 * ============================================================================ */

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import model.Cliente;
import modelDAO.ClientesDAO;

@WebServlet("/editarDados")
public class EditarDadosController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* ----------------------------------------------------------------------
         * 1) VALIDAR SESSÃO
         * ---------------------------------------------------------------------- */
        HttpSession sessao = request.getSession(false);

        if (sessao == null || sessao.getAttribute("idUsuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login/login.jsp");
            return;
        }

        /* ----------------------------------------------------------------------
         * 2) TRATAMENTO DO UPDATE
         * ---------------------------------------------------------------------- */
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String nome  = request.getParameter("nome");
            String email = request.getParameter("email");
            String cep   = request.getParameter("cep");

            /* Monta objeto do cliente com dados atualizados */
            Cliente cli = new Cliente();
            cli.setId(id);
            cli.setName(nome);
            cli.setEmail(email);
            cli.setCep(cep);

            /* Atualiza no banco */
            ClientesDAO dao = new ClientesDAO();
            dao.atualizarDados(cli);

            /* Atualiza os dados também na sessão */
            sessao.setAttribute("nomeUsuario", nome);
            sessao.setAttribute("emailUsuario", email);
            sessao.setAttribute("cepUsuario", cep);

            /* Mensagem de sucesso e retorno para a view */
            request.setAttribute("sucesso", "Dados atualizados com sucesso!");
            request.getRequestDispatcher("/site/editar-dados.jsp")
                   .forward(request, response);

        } catch (Exception e) {

            /* Caso ocorra falha */
            e.printStackTrace();
            request.setAttribute("erro", "Erro ao atualizar dados.");
            request.getRequestDispatcher("/site/editar-dados.jsp")
                   .forward(request, response);
        }
    }
}
