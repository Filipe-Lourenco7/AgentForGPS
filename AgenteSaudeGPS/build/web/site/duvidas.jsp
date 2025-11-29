    <%@ page contentType="text/html; charset=UTF-8" %>

<%
    /*
       ------------------------------------------------------------
       Página: Central de Dúvidas
       Sistema: GPS for Agents
       Criado por: Filipe & Caio
       ------------------------------------------------------------

       Esta página funciona como uma área de FAQ simples, exibindo
       ao usuário respostas rápidas sobre o uso geral do sistema.
       O tema visual é aplicado automaticamente via cookie ou
       localStorage, conforme as preferências definidas pelo usuário.
       ------------------------------------------------------------
    */

    String ctx = request.getContextPath();

    // Recupero o tema salvo no cookie.
    // Caso não exista, o modo escuro é utilizado como padrão.
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
<title>Dúvidas - GPS for Agents</title>

<!-- Bootstrap para layout e responsividade -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>

    /*
       ============================
       VARIÁVEIS DO TEMA ESCURO
       ============================
    */
    :root {
        --bg: #000;
        --text: #fff;
        --card: #111;
        --border: #4CAF50;
        --card2: #1a1a1a;
    }

    /*
       ============================
       VARIÁVEIS DO TEMA CLARO
       ============================
    */
    body.light {
        --bg: #fff;
        --text: #111;
        --card: #f2f2f2;
        --border: #4CAF50;
        --card2: #e6e6e6;
    }

    /*
       ============================
       ESTILOS GERAIS
       ============================
    */
    body {
        background: var(--bg);
        color: var(--text);
        font-family: "Segoe UI";
        transition: .3s;
    }

    /*
       Card principal que encapsula toda a área de dúvidas.
    */
    .container-box {
        background: var(--card);
        border: 1px solid var(--border);
        border-radius: 12px;
        padding: 25px;
        margin-top: 40px;
        box-shadow: 0 0 15px #0004;
    }

    /*
       Blocos individuais de perguntas e respostas.
    */
    .pergunta {
        background: var(--card2);
        padding: 15px;
        border-radius: 10px;
        border: 1px solid #3335;
        margin-bottom: 15px;
    }

    /*
       Títulos das perguntas.
    */
    h2, h5 {
        color: var(--border);
    }

    /*
       Linha divisória adaptada ao tema.
    */
    hr {
        border-color: #444;
    }
    body.light hr {
        border-color: #bbb;
    }

    /*
       Botão do modo claro/escuro.
       Fica fixado no topo direito da página.
    */
    #themeToggle {
        position: fixed;
        top: 20px;
        right: 20px;
        background: transparent;
        border: none;
        font-size: 30px;
        color: var(--text);
        cursor: pointer;
        transition: .25s;
        z-index: 999;
    }

    #themeToggle:hover {
        transform: scale(1.15);
    }
</style>
</head>

<!-- Aplica o tema inicial lido do cookie -->
<body class="<%= temaCookie %>">

<!-- Botão para alternar o tema -->
<button id="themeToggle">🌙</button>

<div class="container">
    <div class="container-box">

        <!-- Título principal da página -->
        <h2 class="fw-bold">Central de Dúvidas</h2>
        <p>Aqui você encontra respostas rápidas sobre o uso do GPS for Agents.</p>

        <hr>

        <!-- Cada bloco abaixo representa uma dúvida frequente. -->
        <div class="pergunta">
            <h5>📍 Como usar o mapa?</h5>
            <p>Use o mouse para arrastar, aplicar zoom e clicar em pontos para visualizar detalhes.</p>
        </div>

        <div class="pergunta">
            <h5>✏ Como adicionar anotações?</h5>
            <p>Ative o modo Edição no mapa e clique na área desejada para registrar informações.</p>
        </div>

        <div class="pergunta">
            <h5>🧭 O GPS funciona offline?</h5>
            <p>Você consegue visualizar o mapa após carregado, mas a primeira inicialização exige internet.</p>
        </div>

        <div class="pergunta">
            <h5>📄 Como gerar PDF ou imagem?</h5>
            <p>Use a função <strong>“Edição Avançada”</strong> e exporte o mapa como PNG ou PDF.</p>
        </div>

        <div class="pergunta">
            <h5>📱 Funciona no celular?</h5>
            <p>Sim! O sistema foi projetado para funcionar em celulares e tablets.</p>
        </div>

        <div class="pergunta">
            <h5>🎨 Como alterar para modo claro ou escuro?</h5>
            <p>Você pode mudar em <strong>Configurações → Tema</strong> ou pelo botão no canto superior.</p>
        </div>

        <div class="pergunta">
            <h5>🛟 Preciso de ajuda adicional</h5>
            <p>Entre em contato via WhatsApp ou pelo suporte disponível no menu principal.</p>
        </div>

        <hr>

        <!-- Retorno ao mapa principal -->
        <button class="btn btn-success w-100"
                onclick="window.location.href='<%= ctx %>/site/home.jsp'">
            Voltar ao Mapa
        </button>

    </div>
</div>

<script>

    /*
       =====================================================
       SISTEMA DE GESTÃO DE TEMA (COOKIE + localStorage)
       =====================================================
    */

    // Lê um cookie específico pelo nome.
    function getCookie(n) {
        const m = document.cookie.match(new RegExp('(^| )' + n + '=([^;]+)'));
        return m ? m[2] : null;
    }

    // Aplica o tema armazenado anteriormente.
    function applyTheme() {
        const tema = getCookie("temaGlobal") || localStorage.getItem("theme") || "dark";
        document.body.classList.toggle("light", tema === "light");
        updateThemeIcon();
    }

    // Alterna entre tema claro e escuro ao clicar.
    function toggleTheme() {
        document.body.classList.toggle("light");
        const tema = document.body.classList.contains("light") ? "light" : "dark";

        // Salva para as próximas visitas:
        document.cookie = "temaGlobal=" + tema + "; path=/; max-age=31536000";
        localStorage.setItem("theme", tema);

        updateThemeIcon();
    }

    // Atualiza o ícone do botão conforme o tema ativo.
    function updateThemeIcon() {
        document.getElementById("themeToggle").textContent =
            document.body.classList.contains("light") ? "🌞" : "🌙";
    }

    // Registrando evento
    document.getElementById("themeToggle").onclick = toggleTheme;

    // Aplicação inicial do tema configurado
    applyTheme();

</script>

</body>
</html>
