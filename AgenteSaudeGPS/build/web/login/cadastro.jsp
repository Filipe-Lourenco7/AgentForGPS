<!-- 
    Criado por: Filipe & Caio
-->
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    // Recupero o contexto da aplicação para montar rotas absolutas dentro do JSP.
    String ctx = request.getContextPath();

    // Aqui faço a leitura do cookie responsável por armazenar o tema global.
    // Caso o cookie não exista, o sistema adota o tema escuro como padrão.
    String temaCookie = "dark";
    javax.servlet.http.Cookie[] cookies = request.getCookies();

    if (cookies != null) {
        for (javax.servlet.http.Cookie c : cookies) {
            // Verifico se existe um cookie chamado "temaGlobal".
            // Se existir, este valor será utilizado para definir o tema da página.
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
    <title>Criar conta - GPS para Agentes</title>

    <style>
        /* 
           Nesta seção defino variáveis CSS para os dois temas da aplicação.
           O objetivo é garantir consistência visual e facilitar a troca entre claro e escuro.
        */
        :root {
            --bg: #0d0d0d;
            --text: #f1f1f1;
            --card: #151515;
            --accent: #4caf50;
            --highlight: #2e7dff;
        }

        /* 
           Quando a classe 'light' é aplicada ao body, as variáveis são sobrescritas, 
           alterando o tema de forma automática.
        */
        body.light {
            --bg: #ffffff;
            --text: #111111;
            --card: #f3f3f3;
            --accent: #2e7dff;
            --highlight: #4caf50;
        }

        /* 
           Estilos gerais da página: 
           centralização do card, transições de cor e comportamento responsivo.
        */
        body {
            background-color: var(--bg);
            color: var(--text);
            font-family: Arial, sans-serif;
            margin: 0;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            transition: background-color .4s ease, color .4s ease;
        }

        /* 
           Botão responsável pela troca de tema.
           Mantém posição fixa e aparência minimalista.
        */
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
           Estrutura principal do formulário de criação de conta.
           Card centralizado com sombras, bordas arredondadas e animação de entrada.
        */
        .card {
            background: var(--card);
            padding: 40px;
            width: 400px;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 4px 20px rgba(0,0,0,.3);
            transition: background .4s ease;
            animation: fadeIn .5s ease;
        }

        /* Animação suave do card ao carregar. */
        @keyframes fadeIn {
            from { opacity:0; transform: translateY(12px); }
            to   { opacity:1; transform: translateY(0); }
        }

        /* 
           Logo da aplicação, que muda conforme o tema.
        */
        .logo {
            width: 120px;
            margin-bottom: 15px;
        }

        /* 
           Estilização dos campos de entrada do formulário.
           Mudo também a aparência quando o tema claro está ativo.
        */
        input[type="text"],
        input[type="email"],
        input[type="password"],
        input[type="number"] {
            width: 100%;
            padding: 12px;
            border-radius: 6px;
            border: 1px solid #444;
            margin-bottom: 14px;
            background: #222;
            color: #fff;
            font-size: 14px;
        }

        body.light input {
            background: #fff;
            color: #000;
            border: 1px solid #ccc;
        }

        /* Estilos padronizados para o botão de cadastro. */
        button {
            width: 100%;
            background: var(--highlight);
            border: none;
            color: #fff;
            padding: 12px;
            border-radius: 6px;
            font-size: 15px;
            cursor: pointer;
            transition: .2s;
        }

        button:hover {
            transform: translateY(-2px);
            opacity: .9;
        }

        /* Link para redirecionamento ao login. */
        a {
            display: inline-block;
            margin-top: 15px;
            color: var(--accent);
            text-decoration: none;
            font-size: 14px;
        }

        /* Rodapé da tela de cadastro. */
        footer {
            margin-top: 20px;
            font-size: 12px;
            color: #aaa;
        }
    </style>
</head>

<!-- 
    Aqui aplico a classe inicial do body com base no cookie identificado no bloco JSP.
-->
<body class="<%= temaCookie %>">

<!-- 
    Botão de alternância de tema. 
    Ele apenas chama a função que troca entre claro e escuro.
-->
<button id="themeIcon" class="theme-toggle" onclick="toggleTheme()">🌙</button>

<div class="card">

    <!-- 
        A logo é fornecida dinamicamente pelo servlet de imagem.
        O ID varia conforme o tema para manter coerência visual.
    -->
    <img id="logo" class="logo" src="<%= ctx %>/imagem?id=7" alt="Logo">

    <h1>Criar conta</h1>
    <p>Preencha os campos abaixo para se cadastrar no GPS para Agentes</p>

    <!-- 
        Formulário de cadastro: envia os dados ao CadastroController via POST.
    -->
    <form action="<%= ctx %>/CadastroController" method="post">
        <input type="text" name="name" placeholder="Nome completo" required>
        <input type="email" name="email" placeholder="E-mail" required>
        <input type="text" name="cep" placeholder="CEP" required>
        <input type="password" name="senha" placeholder="Senha" required>
        <button type="submit">Cadastrar</button>
    </form>

    <!-- Link para caso o usuário já tenha cadastro. -->
    <a href="<%= ctx %>/login/login.jsp">Já tem uma conta? Faça login</a>

    <footer>© 2025 - Code Hunt</footer>
</div>

<script>

    // Função utilitária para recuperar o valor de um cookie específico.
    function getCookie(name) {
        const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
        return match ? match[2] : null;
    }

    /* 
       Função chamada ao iniciar a página.
       Ela define o tema utilizando, na ordem:
       1. Cookie global
       2. LocalStorage
       3. Tema escuro padrão
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

        updateLogo();
        updateIcon();
    }

    // Alterna entre claro e escuro ao clicar no botão.
    function toggleTheme() {
        document.body.classList.toggle("light");

        const tema = document.body.classList.contains("light") ? "light" : "dark";

        // Persisto a escolha no localStorage (tema local)
        localStorage.setItem("theme", tema);

        // Persisto também em cookie para manter tema consistente entre páginas
        document.cookie = "temaGlobal=" + tema + "; path=/; max-age=31536000";

        updateLogo();
        updateIcon();
    }

    // Troca a logo conforme o tema aplicado.
    function updateLogo() {
        const logo = document.getElementById("logo");
        if (document.body.classList.contains("light")) {
            logo.src = "<%= ctx %>/imagem?id=5"; 
        } else {
            logo.src = "<%= ctx %>/imagem?id=7"; 
        }
    }

    // Ajusta o ícone do botão de tema (sol ou lua).
    function updateIcon() {
        const icone = document.getElementById("themeIcon");
        icone.textContent = document.body.classList.contains("light") ? "🌞" : "🌙";
    }

    // Chamada automática quando a página é carregada.
    applySavedTheme();

</script>

</body>
</html>
