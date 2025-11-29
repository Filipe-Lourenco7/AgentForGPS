package controller;

/* ============================================================================
 *  Controller: CadastroController
 *  Autores   : Filipe & Caio
 *
 *  Função:
 *      - Receber dados do formulário de cadastro.
 *      - Validar campos essenciais (CEP, senha, etc.).
 *      - Inserir o cliente no banco via ClientesDAO.
 *      - Criar sessão após cadastro bem-sucedido.
 *      - Redirecionar para o painel (home.jsp).
 *
 *  Fluxo:
 *      1) Recebe dados do formulário
 *      2) Valida CEP (string, 8 dígitos, sem perder zeros)
 *      3) Monta objeto Cliente
 *      4) Tenta cadastrar no banco
 *      5) Cria sessão
 *      6) Redireciona para /site/home.jsp
 *      7) Caso erro → volta para cadastro.jsp
 * ============================================================================ */

import java.io.IOException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import model.Cliente;
import modelDAO.ClientesDAO;

public class CadastroController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* ------------------------------------------------------------------
         * 1) COLETAR DADOS DO FORMULÁRIO
         * ------------------------------------------------------------------ */
        Cliente cli = new Cliente();
        cli.setName(request.getParameter("name"));
        cli.setEmail(request.getParameter("email"));

        /* ------------------------------------------------------------------
         * 2) VALIDAR CEP COMO STRING (NÃO PERDE ZERO)
         * ------------------------------------------------------------------ */
        String cep = request.getParameter("cep");

        if (cep == null || cep.trim().isEmpty()) {
            request.setAttribute("erro", "CEP inválido. Digite apenas números.");
            RequestDispatcher rd = request.getRequestDispatcher("login/cadastro.jsp");
            rd.forward(request, response);
            return;
        }

        // Apenas números
        cep = cep.replaceAll("\\D", "");

        if (cep.length() != 8) {
            request.setAttribute("erro", "CEP deve ter 8 dígitos.");
            RequestDispatcher rd = request.getRequestDispatcher("login/cadastro.jsp");
            rd.forward(request, response);
            return;
        }

        cli.setCep(cep);

        /* ------------------------------------------------------------------
         * 3) SENHA
         * ------------------------------------------------------------------ */
        cli.setSenha(request.getParameter("senha"));

        ClientesDAO dao = new ClientesDAO();

        try {

            /* ------------------------------------------------------------------
             * 4) TENTAR CADASTRAR NO BANCO
             * ------------------------------------------------------------------ */
            if (dao.cadastrar(cli)) {

                /* --------------------------------------------------------------
                 * 5) CRIAR SESSÃO APÓS CADASTRO
                 * -------------------------------------------------------------- */
                HttpSession sessao = request.getSession();
                sessao.setAttribute("usuarioLogado", cli);
                sessao.setAttribute("cepUsuario", cep);
                sessao.setAttribute("idUsuario", cli.getId());

                /* --------------------------------------------------------------
                 * 6) REDIRECIONAR PARA PAINEL
                 * -------------------------------------------------------------- */
                response.sendRedirect(request.getContextPath() + "/site/home.jsp");
                return;

            } else {
                // Falha no DAO (cliente não inserido)
                request.setAttribute("erro", "Erro ao cadastrar. Tente novamente.");
                RequestDispatcher rd = request.getRequestDispatcher("login/cadastro.jsp");
                rd.forward(request, response);
            }

        } catch (ClassNotFoundException ex) {
            // Erro no Driver JDBC
            throw new ServletException(ex);
        }
    }
}
