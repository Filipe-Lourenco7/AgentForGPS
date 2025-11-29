<!-- Criado por: Filipe & Caio-->
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // Recupero o contexto da aplicação para construção de URLs absolutas.
    String ctx = request.getContextPath();

    // Verifico se o usuário está autenticado.
    // Caso não esteja, faço o redirecionamento imediato para a tela de login.
    Integer idUsuario = (Integer) session.getAttribute("idUsuario");
    if (idUsuario == null) {
        response.sendRedirect(ctx + "/login/login.jsp");
        return;
    }

    // Aqui realizo a leitura do cookie responsável por armazenar o tema global.
    // Se ele não existir, o tema escuro é adotado como padrão.
    String temaCookie = "dark";
    javax.servlet.http.Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (javax.servlet.http.Cookie c : cookies) {
            if (c.getName().equals("temaGlobal")) {
                temaCookie = c.getValue();
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="pt-br">
<head>
<meta charset="UTF-8">
<title>Alterar Senha - GPS for Agents</title>

<!-- Bibliotecas externas utilizadas no layout do formulário -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<style>

    /*
       O sistema utiliza variáveis CSS para facilitar a troca entre os temas 
       claro e escuro. Aqui defino os valores padrão do tema escuro.
    */
    :root {
        --bg: #000;
        --text: #fff;
        --card: #111;
        --border: #4CAF50;
        --input-bg: #222;
        --input-border: #333;
        --btn-save: #4CAF50;
        --btn-back: #1a1a1a;
    }

    /*
       Quando a classe "light" é atribuída ao body, 
       as variáveis abaixo passam a ser utilizadas.
    */
    body.light {
        --bg: #ffffff;
        --text: #111;
        --card: #f3f3f3;
        --border: #2e7dff;
        --input-bg: #fff;
        --input-border: #ccc;
        --btn-save: #2e7dff;
        --btn-back: #ddd;
    }

    /*
       Estilização geral da página:
       - plano de fundo definido pelo tema
       - transição suave entre temas
    */
    body {
        background: var(--bg);
        color: var(--text);
        font-family: 'Segoe UI';
        transition: .3s;
    }

    /*
       Botão de alternância de tema, fixado no canto superior direito.
       Utiliza ícone representando sol/lua, alterado dinamicamente via JS.
    */
    #themeToggle {
        position: fixed;
        right: 15px;
        top: 15px;
        font-size: 28px;
        background: transparent;
        border: none;
        color: var(--text);
        cursor: pointer;
        transition: .2s;
    }

    #themeToggle:hover {
        transform: scale(1.15);
    }

    /*
       Estrutura principal da página.
       O formulário fica centralizado e encapsulado em um card estilizado.
    */
    .wrapper {
        max-width: 500px;
        margin: 80px auto;
        background: var(--card);
        padding: 30px;
        border-radius: 12px;
        border: 2px solid var(--border);
        transition: .3s;
    }

    /*
       Campos de entrada personalizados de acordo com o tema.
       O uso de "!important" garante que o Bootstrap não sobreponha o estilo.
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

    /* Botão principal para salvar nova senha */
    .btn-save {
        width: 100%;
        margin-top: 20px;
        background: var(--btn-save);
        color: #000;
        padding: 12px;
        border-radius: 8px;
        border: none;
        font-weight: bold;
    }

    .btn-save:hover {
        opacity: .9;
    }

    /* Botão secundário para voltar ao perfil */
    .btn-voltar {
        width: 100%;
        margin-top: 10px;
        background: var(--btn-back);
        border: 1px solid var(--input-border);
        padding: 10px;
        color: var(--text);
        border-radius: 8px;
    }

    .btn-voltar:hover {
        background: var(--input-border);
    }
</style>

</head>
<body class="<%= temaCookie %>">

<!-- Botão de alternância de tema -->
<button id="themeToggle">🌙</button>

<div class="wrapper">

    <h3 class="text-center fw-bold" style="color: var(--border)">Alterar Senha</h3>

    <%
        /*
           Aqui verifico se o controlador enviou mensagens de sucesso ou erro.
           Essas mensagens são exibidas ao usuário dentro de alertas do Bootstrap.
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

    <!-- 
        Formulário de alteração de senha.
        Ele envia ao controlador três campos:
        - senha atual
        - nova senha
        - confirmação da nova senha
     -->
    <form action="<%= ctx %>/alterarSenha" method="post">

        <label class="mt-3">Senha atual:</label>
        <input type="password" name="senhaAtual" class="form-control" required>

        <label class="mt-3">Nova senha:</label>
        <input type="password" name="novaSenha" class="form-control" required>

        <label class="mt-3">Confirmar nova senha:</label>
        <input type="password" name="confirmarSenha" class="form-control" required>

        <button class="btn-save" type="submit">Salvar nova senha</button>

    </form>

    <!-- Botão para retornar ao perfil -->
    <button class="btn-voltar" onclick="window.location.href='<%= ctx %>/site/perfil.jsp'">
        Voltar ao Perfil
    </button>

</div>

<script>
    /*
       Função utilitária para leitura de cookies.
       É utilizada para detectar o tema salvo anteriormente.
    */
    function getCookie(name) {
        const m = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
        return m ? m[2] : null;
    }

    /*
       Aplica o tema assim que a página é carregada.
       Se houver cookie, ele é priorizado. Se não houver, utilizo localStorage.
    */
    function applySavedTheme() {
        const tema = getCookie("temaGlobal") || localStorage.getItem("theme") || "dark";

        if (tema === "light") document.body.classList.add("light");
        else document.body.classList.remove("light");

        updateIcon();
    }

    /*
       Alterna entre tema claro e escuro e salva a escolha em cookie e localStorage.
    */
    function toggleTheme() {
        document.body.classList.toggle("light");
        const tema = document.body.classList.contains("light") ? "light" : "dark";

        document.cookie = "temaGlobal=" + tema + "; path=/; max-age=31536000";
        localStorage.setItem("theme", tema);

        updateIcon();
    }

    /*
       Atualiza o ícone do botão conforme o tema ativo.
    */
    function updateIcon() {
        document.getElementById("themeToggle").textContent =
            document.body.classList.contains("light") ? "🌞" : "🌙";
    }

    // Ações vinculadas ao botão e ao carregamento inicial
    document.getElementById("themeToggle").addEventListener("click", toggleTheme);
    applySavedTheme();
</script>

</body>
</html>
