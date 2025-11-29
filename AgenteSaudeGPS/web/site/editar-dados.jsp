<%@ page contentType="text/html; charset=UTF-8" %>

<%
    /*
       ------------------------------------------------------------
       Página: Editar Dados do Usuário
       Sistema: GPS for Agents
       Criado por: Filipe & Caio
       ------------------------------------------------------------

       Esta página permite ao usuário alterar seus dados cadastrais:
       nome, e-mail e CEP. As informações carregadas vêm diretamente
       da sessão. O tema visual é aplicado através de cookies, sendo
       herdado do restante do sistema.
       ------------------------------------------------------------
    */

    String ctx = request.getContextPath();

    // Garantia de que apenas usuários autenticados acessem esta área.
    Integer idUsuario = (Integer) session.getAttribute("idUsuario");
    if (idUsuario == null) {
        response.sendRedirect(ctx + "/login/login.jsp");
        return;
    }

    // Dados atuais do usuário, carregados da sessão.
    String nome = (String) session.getAttribute("nomeUsuario");
    String email = (String) session.getAttribute("emailUsuario");
    String cep = (String) session.getAttribute("cepUsuario");

    // Leitura do tema salvo no cookie global.
    String temaCookie = "dark";
    javax.servlet.http.Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (javax.servlet.http.Cookie c : cookies) {
            if (c.getName().equals("temaGlobal")) temaCookie = c.getValue();
        }
    }
%>

<!DOCTYPE html>
<html lang="pt-br">
<head>
<meta charset="UTF-8">
<title>Editar Dados - GPS for Agents</title>

<!-- Bootstrap para estilização e layout -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>

    /*
       Variáveis de cor do tema escuro (padrão).
    */
    :root {
        --bg: #000;
        --text: #fff;
        --card: #111;
        --border: #4CAF50;
        --input-bg: #222;
        --input-border: #333;
    }

    /*
       Sobrescrita para o tema claro.
    */
    body.light {
        --bg: #ffffff;
        --text: #111111;
        --card: #f3f3f3;
        --border: #2e7dff;
        --input-bg: #fff;
        --input-border: #ccc;
    }

    /*
       Estilos principais da página.
    */
    body {
        background: var(--bg);
        color: var(--text);
        font-family: 'Segoe UI';
        transition: .3s;
    }

    /*
       Botão global de tema.
    */
    #themeToggle {
        position: fixed;
        right: 15px;
        top: 15px;
        background: transparent;
        border: none;
        font-size: 26px;
        color: var(--text);
        cursor: pointer;
        transition: .25s;
    }

    #themeToggle:hover {
        transform: scale(1.15);
    }

    /*
       Card central onde ficam os dados do formulário.
    */
    .wrapper {
        max-width: 550px;
        margin: 80px auto;
        padding: 30px;
        background: var(--card);
        border-radius: 14px;
        border: 2px solid var(--border);
    }

    /*
       Campos do formulário adaptados ao tema.
    */
    input {
        background: var(--input-bg) !important;
        color: var(--text) !important;
        border: 1px solid var(--input-border) !important;
    }

    input:focus {
        border-color: var(--border) !important;
        box-shadow: none !important;
    }

    /*
       Botão principal para salvar alterações.
    */
    .btn-save {
        width: 100%;
        padding: 12px;
        background: var(--border);
        color: #000;
        border: none;
        border-radius: 8px;
        margin-top: 15px;
        font-weight: bold;
    }

    /*
       Botão secundário para retornar ao perfil.
    */
    .btn-voltar {
        width: 100%;
        margin-top: 10px;
        padding: 12px;
        background: var(--input-bg);
        color: var(--text);
        border: 1px solid var(--input-border);
        border-radius: 8px;
    }

    .btn-voltar:hover {
        background: var(--input-border);
    }

</style>

</head>

<!-- Classe dinamicamente definida com base no cookie de tema -->
<body class="<%= temaCookie %>">

<!-- BOTÃO DE TEMA GLOBAL -->
<button id="themeToggle">🌙</button>

<div class="wrapper">

    <h3 class="fw-bold text-center" style="color:var(--border);">Editar Dados</h3>

    <% 
        /*
           Exibição de mensagens vindas do controlador:
           - erro: algo inválido (email já usado, CEP incorreto etc.)
           - sucesso: alteração realizada com êxito
        */
        String erro = (String) request.getAttribute("erro");
        String sucesso = (String) request.getAttribute("sucesso");

        if (erro != null) {
    %>
        <div class="alert alert-danger mt-3"><%= erro %></div>
    <% } %>

    <% if (sucesso != null) { %>
        <div class="alert alert-success mt-3"><%= sucesso %></div>
    <% } %>

    <!-- Formulário de edição de dados pessoais -->
    <form action="<%= ctx %>/editarDados" method="post">

        <!-- ID do usuário enviado de forma oculta -->
        <input type="hidden" name="id" value="<%= idUsuario %>">

        <label class="mt-3">Nome:</label>
        <input type="text" class="form-control" name="nome" value="<%= nome %>" required>

        <label class="mt-3">E-mail:</label>
        <input type="email" class="form-control" name="email" value="<%= email %>" required>

        <label class="mt-3">CEP:</label>
        <input type="text" class="form-control" name="cep" maxlength="8" value="<%= cep %>" required>

        <button type="submit" class="btn-save">Salvar Alterações</button>
    </form>

    <!-- Voltar ao perfil -->
    <button class="btn-voltar" onclick="window.location.href='<%= ctx %>/site/perfil.jsp'">
        Voltar ao Perfil
    </button>

</div>

<script>

    // Recupera cookie do tema
    function getCookie(name) {
        const m = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
        return m ? m[2] : null;
    }

    // Aplica o tema salvo
    function applySavedTheme() {
        const tema = getCookie("temaGlobal") || localStorage.getItem("theme") || "dark";
        document.body.classList.toggle("light", tema === "light");
        updateIcon();
    }

    // Alterna entre claro e escuro
    function toggleTheme() {
        document.body.classList.toggle("light");
        const tema = document.body.classList.contains("light") ? "light" : "dark";

        document.cookie = "temaGlobal=" + tema + "; path=/; max-age=31536000";
        localStorage.setItem("theme", tema);

        updateIcon();
    }

    // Atualiza o ícone do botão
    function updateIcon() {
        document.getElementById("themeToggle").textContent =
            document.body.classList.contains("light") ? "🌞" : "🌙";
    }

    // Eventos
    document.getElementById("themeToggle").addEventListener("click", toggleTheme);

    // Inicialização do tema ao carregar a página
    applySavedTheme();

</script>

</body>
</html>
