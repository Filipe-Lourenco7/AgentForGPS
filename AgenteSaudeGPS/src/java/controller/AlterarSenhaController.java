package controller;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import modelDAO.ClientesDAO;
import model.Cliente;

/**
 * ============================================================================
 *  Controller: AlterarSenhaController
 *  Autor     : Filipe & Caio
 *  Função    :
 *      - Recebe a requisição do formulário de alteração de senha.
 *      - Valida a senha atual do usuário.
 *      - Confere se a nova senha coincide com a confirmação.
 *      - Atualiza a senha no banco usando ClientesDAO.
 *
 *  Fluxo:
 *      1) Verifica sessão e login
 *      2) Valida senha atual
 *      3) Valida nova senha = confirmar senha
 *      4) Atualiza no banco
 *      5) Retorna mensagem para a tela
 * ============================================================================
 */
@WebServlet("/alterarSenha")
public class AlterarSenhaController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* ------------------------------------------------------------------
         * 1) VALIDAR SESSÃO
         * ------------------------------------------------------------------ */
        HttpSession sessao = request.getSession(false);

        if (sessao == null || sessao.getAttribute("idUsuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login/login.jsp");
            return;
        }

        int id = (Integer) sessao.getAttribute("idUsuario");
        String email = (String) sessao.getAttribute("emailUsuario");

        /* ------------------------------------------------------------------
         * 2) RECEBER CAMPOS DO FORMULÁRIO
         * ------------------------------------------------------------------ */
        String senhaAtual = request.getParameter("senhaAtual");
        String novaSenha = request.getParameter("novaSenha");
        String confirmarSenha = request.getParameter("confirmarSenha");

        try {
            ClientesDAO dao = new ClientesDAO();

            /* ------------------------------------------------------------------
             * 3) VALIDAR SENHA ATUAL
             * ------------------------------------------------------------------ */
            Cliente cli = dao.autenticarRetornandoCliente(email, senhaAtual);

            if (cli == null) {
                request.setAttribute("erro", "Senha atual está incorreta.");
                request.getRequestDispatcher("/site/alterar-senha.jsp").forward(request, response);
                return;
            }

            /* ------------------------------------------------------------------
             * 4) VALIDAR NOVA SENHA = CONFIRMAÇÃO
             * ------------------------------------------------------------------ */
            if (!novaSenha.equals(confirmarSenha)) {
                request.setAttribute("erro", "A nova senha e a confirmação não coincidem.");
                request.getRequestDispatcher("/site/alterar-senha.jsp").forward(request, response);
                return;
            }

            /* ------------------------------------------------------------------
             * 5) ATUALIZAR SENHA NO BANCO
             * ------------------------------------------------------------------ */
            dao.alterarSenha(id, novaSenha);

            request.setAttribute("sucesso", "Senha alterada com sucesso!");
            request.getRequestDispatcher("/site/alterar-senha.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();

            /* ------------------------------------------------------------------
             * ERRO GERAL
             * ------------------------------------------------------------------ */
            request.setAttribute("erro", "Erro ao alterar senha.");
            request.getRequestDispatcher("/site/alterar-senha.jsp").forward(request, response);
        }
    }
}
