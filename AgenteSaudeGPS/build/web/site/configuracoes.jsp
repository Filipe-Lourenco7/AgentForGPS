<%@ page contentType="text/html; charset=UTF-8" %>

<%
    /*
       ------------------------------------------------------------
       Página: Configurações
       Sistema: GPS for Agents
       Criado por: Filipe & Caio
       ------------------------------------------------------------

       Esta página permite que o usuário personalize preferências
       de uso, como tema visual e ativação de notificações.
       Todas as opções são salvas em sessão e cookies, mantendo
       a experiência consistente ao navegar pelo sistema.
       ------------------------------------------------------------
    */

    String ctx = request.getContextPath();

    // Verificação de autenticação.
    // Se não houver usuário logado, redireciono para a página de login.
    Integer idUsuario = (Integer) session.getAttribute("idUsuario");
    if (idUsuario == null) {
        response.sendRedirect(ctx + "/login/login.jsp");
        return;
    }

    // Leitura do tema armazenado no cookie.
    // O sistema funciona com tema "dark" como padrão.
    String temaCookie = "dark";
    javax.servlet.http.Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (javax.servlet.http.Cookie c : cookies) {
            if (c.getName().equals("temaGlobal")) temaCookie = c.getValue();
        }
    }

    // Recuperação do estado das notificações, salvo em sessão.
    String notificacoes = (String) session.getAttribute("notificacoes");
    if (notificacoes == null) notificacoes = "on";
%>

<!DOCTYPE html>
<html lang="pt-br">
<head>
<meta charset="UTF-8">
<title>Configurações - GPS for Agents</title>

<!-- CSS do Bootstrap para estilização e responsividade -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>

    /*
       Variáveis do tema escuro: cores padrão da interface.
       São redefinidas quando o tema claro está ativo.
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
       Sobrescrita das variáveis quando o modo claro é ativado.
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
       Estilos gerais da página:
       - plano de fundo dinâmico
       - fonte padrão
       - transição suave ao trocar tema
    */
    body {
        background: var(--bg);
        color: var(--text);
        font-family: 'Segoe UI';
        transition: .3s;
    }

    /*
       Botão responsável pela alternância de tema.
       Posicionado no topo direito da página.
    */
    #themeToggle {
        position: fixed;
        right: 15px;
        top: 15px;
        background: transparent;
        border: none;
        color: var(--text);
        font-size: 26px;
        cursor: pointer;
        transition: .2s;
    }

    #themeToggle:hover {
        transform: scale(1.15);
    }

    /*
       Container principal que agrupa as configurações.
       Utiliza bordas, fundo e espaçamento consistente.
    */
    .wrapper {
        max-width: 650px;
        margin: 80px auto;
        padding: 30px;
        background: var(--card);
        border-radius: 12px;
        border: 2px solid var(--border);
    }

    /*
       Título de cada seção dentro da área de configurações.
    */
    .section-title {
        font-size: 18px;
        margin-top: 25px;
        margin-bottom: 10px;
        font-weight: bold;
        color: var(--border);
    }

    /*
       Inputs personalizam-se automaticamente de acordo com o tema.
    */
    select, input[type="checkbox"] {
        background: var(--input-bg);
        color: var(--text);
        border: 1px solid var(--input-border);
    }

    /*
       Botão principal para salvar as configurações.
    */
    .btn-save {
        width: 100%;
        margin-top: 25px;
        background: var(--border);
        color: #000;
        padding: 12px;
        border-radius: 8px;
        border: none;
        font-weight: bold;
    }

    /*
       Botão para voltar ao mapa.
    */
    .btn-voltar {
        width: 100%;
        margin-top: 15px;
        background: var(--input-bg);
        border: 1px solid var(--input-border);
        padding: 12px;
        color: var(--text);
        border-radius: 8px;
    }

    .btn-voltar:hover {
        background: var(--input-border);
    }

</style>

</head>

<!-- O body recebe a classe de tema com base no cookie lido -->
<body class="<%= temaCookie %>">

<!-- Botão de alternância de tema -->
<button id="themeToggle">🌙</button>

<div class="wrapper">

    <!-- Título da página -->
    <h3 class="fw-bold text-center" style="color:var(--border);">Configurações</h3>

    <% 
        /* Exibe mensagem de sucesso vinda do controlador */
        String sucesso = (String) request.getAttribute("sucesso");
        if (sucesso != null) { 
    %>
        <div class="alert alert-success mt-3"><%= sucesso %></div>
    <% } %>

    <!-- Formulário de configurações -->
    <form method="post" action="<%= ctx %>/configuracoes">

        <!-- Escolha entre tema claro e escuro -->
        <div class="section-title">Tema do Sistema</div>
        <select name="tema" class="form-control">
            <option value="dark" <%= temaCookie.equals("dark") ? "selected" : "" %>>Modo Escuro</option>
            <option value="light" <%= temaCookie.equals("light") ? "selected" : "" %>>Modo Claro</option>
        </select>

        <!-- Ativar ou desativar notificações -->
        <div class="section-title">Notificações</div>
        <label style="display:flex;align-items:center;gap:10px;">
            <input type="checkbox" name="notificacoes" <%= notificacoes.equals("on") ? "checked" : "" %>>
            Ativar notificações
        </label>

        <!-- Botão que envia as configurações ao backend -->
        <button type="submit" class="btn-save">Salvar Configurações</button>
    </form>

    <!-- Voltar para home.jsp -->
    <button class="btn-voltar" onclick="window.location.href='<%= ctx %>/site/home.jsp'">
        Voltar ao Mapa
    </button>

</div>

<script>

    /*
       Leitura de cookies para identificar o tema salvo.
    */
    function getCookie(name) {
        const m = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
        return m ? m[2] : null;
    }

    /*
       Aplica o tema assim que a página é carregada,
       priorizando cookie > localStorage > padrão.
    */
    function applySavedTheme() {
        const tema = getCookie("temaGlobal") || localStorage.getItem("theme") || "dark";
        document.body.classList.toggle("light", tema === "light");
        updateIcon();
    }

    /*
       Alterna o tema ao clicar no botão.
       Também salva a opção para manter a escolha do usuário.
    */
    function toggleTheme() {
        document.body.classList.toggle("light");
        const tema = document.body.classList.contains("light") ? "light" : "dark";

        document.cookie = "temaGlobal=" + tema + "; path=/; max-age=31536000";
        localStorage.setItem("theme", tema);

        updateIcon();
    }

    /*
       Atualiza o ícone do botão conforme o tema atual.
    */
    function updateIcon() {
        document.getElementById("themeToggle").textContent =
            document.body.classList.contains("light") ? "🌞" : "🌙";
    }

    // Eventos iniciais
    document.getElementById("themeToggle").addEventListener("click", toggleTheme);
    applySavedTheme();

</script>

</body>
</html>
