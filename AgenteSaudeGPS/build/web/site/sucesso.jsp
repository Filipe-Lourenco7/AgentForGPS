<%-- 
    ======================================================================
    Document   : cadastro-concluido.jsp
    Created on : 27/11/2025
    Author     : Filipe & Caio
    Description:
        Tela exibida após o cadastro ser finalizado com sucesso.
        Exibe confirmação, permite ir ao login e mantém integração com:
        - Tema global (via cookie + localStorage)
        - Logos dinâmicos para claro/escuro
    ======================================================================
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String ctx = request.getContextPath();

    // Tema via cookie global
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
<title>Cadastro Concluído - GPS for Agents</title>

<style>

/* -------------------------------------------------------------
   VARIÁVEIS DE TEMA
------------------------------------------------------------- */
:root {
    --bg: #000;
    --text: #fff;
    --card: #111;
    --accent: #4caf50;
    --highlight: #2e7dff;
}

body.light {
    --bg: #ffffff;
    --text: #111;
    --card: #f2f2f2;
    --accent: #2e7dff;
    --highlight: #4caf50;
}

/* -------------------------------------------------------------
   LAYOUT PRINCIPAL
------------------------------------------------------------- */
body {
    background: var(--bg);
    color: var(--text);
    font-family: Arial, sans-serif;
    margin: 0;
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background .4s ease, color .4s ease;
}

/* -------------------------------------------------------------
   CONTAINER CENTRAL
------------------------------------------------------------- */
.container {
    background: var(--card);
    padding: 40px;
    width: 380px;
    border-radius: 14px;
    text-align: center;
    box-shadow: 0 4px 22px rgba(0,0,0,.35);
    animation: fadeIn .5s ease;
}

/* animação */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to   { opacity: 1; transform: translateY(0); }
}

/* logo dinâmico */
.logo {
    width: 120px;
    margin-bottom: 10px;
}

/* ícone grande */
.icon {
    font-size: 75px;
    color: var(--accent);
    margin-bottom: 10px;
}

/* botão de continuar */
a.btn {
    display: block;
    width: 100%;
    padding: 12px;
    margin-top: 20px;
    background: var(--highlight);
    color: #fff;
    text-decoration: none;
    font-weight: bold;
    border-radius: 8px;
    transition: .2s;
}

a.btn:hover {
    opacity: .9;
    transform: translateY(-2px);
}

footer {
    margin-top: 18px;
    font-size: 12px;
    color: #999;
}

/* -------------------------------------------------------------
   BOTÃO DE TEMA GLOBAL
------------------------------------------------------------- */
#themeToggle {
    position: fixed;
    top: 20px;
    right: 20px;
    background: transparent;
    border: none;
    font-size: 30px;
    cursor: pointer;
    color: var(--text);
    transition: .25s;
}

#themeToggle:hover {
    transform: scale(1.15);
}

</style>

</head>

<body class="<%= temaCookie %>">

<!-- BOTÃO TEMA -->
<button id="themeToggle">🌙</button>

<!-- -------------------------------------------------------------
     CAIXA PRINCIPAL DA TELA
------------------------------------------------------------- -->
<div class="container">

    <!-- Logo dinâmica -->
    <img id="logo" class="logo" src="<%= ctx %>/imagem?id=7">

    <div class="icon">✅</div>

    <h1>Cadastro concluído!</h1>
    <p>Agora você já pode acessar o sistema.</p>

    <a class="btn" href="<%= ctx %>/login/login.jsp">Ir para o Login</a>

    <footer>© 2025 - Code Hunt Technology</footer>
</div>

<!-- -------------------------------------------------------------
     SISTEMA DE TEMA GLOBAL
------------------------------------------------------------- -->
<script>
function getCookie(name) {
    const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
    return match ? match[2] : null;
}

function applySavedTheme() {
    const tema = getCookie("temaGlobal") || localStorage.getItem("theme") || "dark";
    document.body.classList.toggle("light", tema === "light");
    updateLogo();
    updateIcon();
}

function toggleTheme() {
    document.body.classList.toggle("light");

    const tema = document.body.classList.contains("light") ? "light" : "dark";

    document.cookie = "temaGlobal=" + tema + "; path=/; max-age=31536000";
    localStorage.setItem("theme", tema);

    updateLogo();
    updateIcon();
}

function updateLogo() {
    const logo = document.getElementById("logo");
    logo.src = document.body.classList.contains("light")
        ? "<%= ctx %>/imagem?id=5"
        : "<%= ctx %>/imagem?id=7";
}

function updateIcon() {
    document.getElementById("themeToggle").textContent =
        document.body.classList.contains("light") ? "🌞" : "🌙";
}

document.getElementById("themeToggle").addEventListener("click", toggleTheme);

applySavedTheme();
</script>

</body>
</html>
