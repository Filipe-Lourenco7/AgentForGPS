<!-- Criado por: Filipe & Caio -->
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // Recupero o contexto da aplicação para facilitar a criação de URLs absolutas.
    String ctx = request.getContextPath();

    // Nesta parte, faço a leitura do cookie que armazena o tema global.
    // Caso ele não exista, assumo o tema escuro como padrão.
    String temaCookie = null;
    javax.servlet.http.Cookie[] cookies = request.getCookies();

    if (cookies != null) {
        for (javax.servlet.http.Cookie c : cookies) {
            if (c.getName().equals("temaGlobal")) {
                temaCookie = c.getValue();
            }
        }
    }

    if (temaCookie == null) temaCookie = "dark";
%>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">

    <!-- Utilizo <base> para garantir que links relativos funcionem dentro da pasta /login -->
    <base href="<%= ctx %>/login/">

    <title>GPS para Agentes - Login</title>

    <style>
        /*
           Defino aqui as variáveis de cor para o tema escuro, que é o padrão do sistema.
           Esses valores são usados em toda a interface para manter consistência visual.
        */
        :root {
            --bg: #0d0d0d;
            --text: #f1f1f1;
            --card: #151515;
            --accent: #4caf50;
            --highlight: #2e7dff;
        }

        /*
           Caso a classe 'light' seja adicionada ao body, as variáveis são substituídas,
           resultando na mudança para o tema claro.
        */
        body.light {
            --bg: #ffffff;
            --text: #111111;
            --card: #f2f2f2;
            --accent: #2e7dff;
            --highlight: #4caf50;
        }

        /*
           Configuração geral da página:
           - centraliza o card
           - aplica transição suave ao trocar de tema
           - ocupa toda a altura da janela
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

        /*
           Container central que contém toda a experiência de login.
           Inclui sombra, bordas arredondadas e animação de entrada.
        */
        .container {
            background: var(--card);
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,.3);
            width: 350px;
            text-align: center;
            transition: background .4s ease;
            animation: fadeIn .5s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Logo exibida no topo do card */
        img.logo {
            width: 140px;
            margin-bottom: 15px;
            border-radius: 10px;
        }

        /*
           Campos de entrada: email e senha.
           Ambos seguem o tema atual, alternando entre claro e escuro.
        */
        input[type="text"],
        input[type="password"],
        input[type="email"] {
            width: 100%;
            padding: 10px;
            margin-top: 8px;
            border-radius: 6px;
            border: 1px solid #444;
            background: #222;
            color: #fff;
            font-size: 14px;
        }

        body.light input {
            background: #fff;
            color: #000;
            border: 1px solid #ccc;
        }

        /* Botão principal de login */
        button {
            width: 100%;
            margin-top: 12px;
            background-color: var(--highlight);
            color: white;
            border: none;
            padding: 10px;
            border-radius: 6px;
            font-size: 15px;
            cursor: pointer;
            transition: .2s;
        }

        button:hover {
            transform: translateY(-2px);
            opacity: .9;
        }

        /* Área do Captcha e recarregamento */
        .captcha-area {
            margin-top: 18px;
            margin-bottom: 10px;
        }

        .captcha-area img {
            width: 150px;
            height: 50px;
            border-radius: 6px;
            border: 1px solid #666;
        }

        .refresh-btn {
            margin-top: 10px;
            margin-bottom: 18px;
            width: 100%;
            padding: 8px;
            background: #2563eb;
            color: #fff;
            font-size: 14px;
            border-radius: 6px;
            border: none;
            cursor: pointer;
        }

        body.light .refresh-btn {
            background: #2e7dff;
        }

        /* Links de navegação (esqueci senha / cadastro) */
        a {
            color: var(--accent);
            text-decoration: none;
            font-size: 14px;
        }

        /*
           Botão de alternância de tema.
           Fica no canto superior direito da tela.
        */
        .theme-toggle {
            position: absolute;
            top: 15px;
            right: 15px;
            background: transparent;
            color: var(--text);
            font-size: 26px;
            border: none;
            cursor: pointer;
            transition: .3s;
        }

        .theme-toggle:hover {
            transform: scale(1.15);
        }
    </style>
</head>

<!-- O tema inicial do body é determinado com base no cookie lido -->
<body class="<%= temaCookie %>">

    <!-- Botão de alternância de tema -->
    <button id="themeIcon" class="theme-toggle" onclick="toggleTheme()">🌙</button>

    <div class="container">

        <!-- A logo muda conforme o tema; isso é tratado no JS -->
        <img id="logo" class="logo" src="<%= ctx %>/imagem?id=7" alt="Logo">

        <h1>GPS para Agentes</h1>
        <p>Por favor, faça login para continuar</p>

        <% 
            // Se o LoginController enviar mensagem de erro, ela é exibida aqui.
            String erro = (String) request.getAttribute("erro");
            if (erro != null) { %>
            <div style="color:#ff4b4b; font-weight:bold; margin-bottom:10px;">
                <%= erro %>
            </div>
        <% } %>

        <!-- Formulário de autenticação -->
        <form action="<%= ctx %>/LoginController" method="post">

            <input type="text" name="email" placeholder="E-mail" required>
            <input type="password" name="senha" placeholder="Senha" required>

            <!-- Área do Captcha para validação antifraude -->
            <div class="captcha-area">
                <img id="captcha-img" src="<%= ctx %>/captcha">
            </div>

            <!-- Botão para recarregar o captcha -->
            <button type="button" class="refresh-btn" onclick="atualizarCaptcha()">🔄 Atualizar</button>

            <input type="text" name="captcha_input" placeholder="Digite o código acima" required>

            <!-- Opção de lembrar login -->
            <label style="display:flex; align-items:center; gap:5px; font-size:14px;">
                <input type="checkbox" name="lembrar"> Lembrar de mim
            </label>

            <button type="submit">Entrar</button>

        </form>

        <!-- Links adicionais -->
        <div class="links" style="margin-top:15px;">
            <a href="<%= ctx %>/login/esqueci-senha.jsp">Esqueci a senha</a> •
            <a href="<%= ctx %>/login/cadastro.jsp">Cadastrar</a>
        </div>

        <footer style="margin-top:15px; font-size:12px; color:#999;">
            © 2025 - Code Hunt
        </footer>
    </div>

<script>
    // Função utilitária para leitura de cookies
    function getCookie(name) {
        const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
        return match ? match[2] : null;
    }

    /*
       Aplica o tema salvo no cookie ou localStorage.
       Se nenhum existir, mantém o tema escuro como padrão.
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

        atualizarLogo();
        atualizarIcone();
    }

    // Função que alterna o tema
    function toggleTheme() {
        document.body.classList.toggle("light");

        const tema = document.body.classList.contains("light") ? "light" : "dark";

        // Salva tema no localStorage
        localStorage.setItem("theme", tema);

        // Salva no cookie para manter tema entre páginas
        document.cookie = "temaGlobal=" + tema + "; path=/; max-age=31536000";

        atualizarLogo();
        atualizarIcone();
    }

    // Atualiza a imagem da logo conforme o tema ativo
    function atualizarLogo() {
        const logo = document.getElementById("logo");

        if (document.body.classList.contains("light")) {
            logo.src = "<%= ctx %>/imagem?id=5"; 
        } else {
            logo.src = "<%= ctx %>/imagem?id=7"; 
        }
    }

    // Atualiza o ícone do botão de tema
    function atualizarIcone() {
        const icone = document.getElementById("themeIcon");
        icone.textContent = document.body.classList.contains("light") ? "☀️" : "🌙";
    }

    // Atualiza o captcha, forçando recarregamento
    function atualizarCaptcha() {
        document.getElementById("captcha-img").src =
            "<%= ctx %>/captcha?ts=" + new Date().getTime();
    }

    // Chamada inicial ao abrir a página
    applySavedTheme();

</script>

</body>
</html>
