<!-- 
    Criado por: Caio & Filipe
-->
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // Recupero o contexto da aplicação para montar URLs absolutas.
    String ctx = request.getContextPath();

    // A lógica abaixo faz a leitura do cookie responsável pelo tema global da aplicação.
    // Caso o cookie não exista, o tema escuro é utilizado como padrão.
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
    <title>Recuperar Senha - GPS para Agentes</title>

    <style>
        /*
           O sistema trabalha com duas variações de tema: claro e escuro.
           Aqui defino as variáveis padrão que pertencem ao tema escuro.
        */
        :root {
            --bg: #0d0d0d;
            --text: #f1f1f1;
            --card: #151515;
            --accent: #4caf50;
            --highlight: #2e7dff;
        }

        /*
           Quando o body recebe a classe 'light', essas variáveis substituem as anteriores
           e a interface passa automaticamente para o tema claro.
        */
        body.light {
            --bg: #ffffff;
            --text: #111111;
            --card: #f3f3f3;
            --accent: #2e7dff;
            --highlight: #4caf50;
        }

        /*
           Estilos gerais do layout desta página.
           Centralizo o conteúdo e aplico a transição suave entre temas.
        */
        body {
            background-color: var(--bg);
            color: var(--text);
            font-family: Arial, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            transition: background .4s ease, color .4s ease;
        }

        /* Botão de alternância de tema, fixado no topo direito. */
        .theme-toggle {
            position: absolute;
            top: 15px;
            right: 15px;
            background: transparent;
            border: none;
            font-size: 26px;
            color: var(--text);
            cursor: pointer;
            transition: .3s;
        }

        .theme-toggle:hover {
            transform: scale(1.14);
        }

        /*
           Card central que contém todos os elementos da página:
           título, mensagens e formulário.
        */
        .container {
            background: var(--card);
            padding: 40px;
            width: 350px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,.3);
            text-align: center;
            transition: background .4s ease;
            animation: fadeIn .5s ease;
        }

        /* Animação de entrada suave do card. */
        @keyframes fadeIn {
            from { opacity:0; transform: translateY(12px); }
            to   { opacity:1; transform: translateY(0); }
        }

        /* Campo de e-mail com estilos para os dois temas. */
        input[type="email"] {
            width: 100%;
            padding: 10px;
            border-radius: 6px;
            border: 1px solid #444;
            background: #222;
            color: #fff;
            margin-top: 8px;
            font-size: 14px;
        }

        body.light input {
            background: #fff;
            color: #000;
            border: 1px solid #ccc;
        }

        /* Estilo do botão de envio. */
        button {
            width: 100%;
            margin-top: 15px;
            background: var(--highlight);
            color: #fff;
            padding: 10px;
            border: none;
            border-radius: 6px;
            font-size: 15px;
            cursor: pointer;
            transition: .2s;
        }

        button:hover {
            transform: translateY(-2px);
            opacity: .92;
        }

        /* Link de retorno ao login. */
        a {
            margin-top: 16px;
            display: inline-block;
            color: var(--accent);
            font-size: 14px;
            text-decoration: none;
        }

        /* Classes usadas para exibir mensagens de feedback. */
        .mensagem-sucesso {
            color: #4caf50;
            margin-bottom: 10px;
            font-weight: bold;
        }

        .mensagem-erro {
            color: #ff4b4b;
            margin-bottom: 10px;
            font-weight: bold;
        }
    </style>
</head>

<!-- A classe aplicada ao body depende do valor do cookie lido no início do JSP. -->
<body class="<%= temaCookie %>">

<!-- Botão para alternância de tema (tema claro/escuro). -->
<button class="theme-toggle" id="themeIcon" onclick="toggleTheme()">🌙</button>

<div class="container">

    <h1>Esqueci minha senha</h1>
    <p>Informe seu e-mail e enviaremos instruções para redefinir sua senha.</p>

    <%
        /*
           Essas variáveis recebem, quando existentes, mensagens vindas do controlador.
           São utilizadas para informar se a operação foi bem-sucedida ou se ocorreu algum erro.
        */
        String msgSucesso = (String) request.getAttribute("mensagemSucesso");
        String msgErro = (String) request.getAttribute("mensagemErro");
    %>

    <% if (msgSucesso != null) { %>
        <div class="mensagem-sucesso"><%= msgSucesso %></div>
    <% } else if (msgErro != null) { %>
        <div class="mensagem-erro"><%= msgErro %></div>
    <% } %>

    <!-- Formulário simples com campo de e-mail que envia a solicitação ao controlador responsável. -->
    <form action="<%= ctx %>/RecuperarSenhaController" method="post">
        <input type="email" name="email" placeholder="Seu e-mail" required>
        <button type="submit">Enviar instruções</button>
    </form>

    <a href="<%= ctx %>/login/login.jsp">Voltar para o Login</a>
</div>

<script>
    // Função utilitária para recuperar um cookie específico.
    function getCookie(name) {
        const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
        return match ? match[2] : null;
    }

    /*
       Esta função é chamada ao carregar a página.
       Ela aplica o tema salvo, priorizando:
       1. tema do cookie global,
       2. tema do localStorage,
       3. tema escuro por padrão.
    */
    function applySavedTheme() {
        let tema = getCookie("temaGlobal");

        if (!tema) {
            tema = localStorage.getItem("theme");
        }

        if (tema === "light") {
            document.body.classList.add("light");
        } else {
            document.body.classList.remove("light");
        }

        atualizarIcone();
    }

    // Alternância entre os temas claro e escuro.
    function toggleTheme() {
        document.body.classList.toggle("light");

        const tema = document.body.classList.contains("light") ? "light" : "dark";

        // Salvo tema no localStorage.
        localStorage.setItem("theme", tema);

        // Salvo também no cookie, para manter consistência entre todas as páginas.
        document.cookie = "temaGlobal=" + tema + "; path=/; max-age=31536000";

        atualizarIcone();
    }

    // Atualiza o ícone do botão de tema (sol ou lua).
    function atualizarIcone() {
        const icone = document.getElementById("themeIcon");
        icone.textContent = document.body.classList.contains("light") ? "🌞" : "🌙";
    }

    // Executa ao carregar a página.
    applySavedTheme();

</script>

</body>
</html>
