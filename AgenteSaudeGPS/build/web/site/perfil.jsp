<%-- 
    ======================================================================
    Document   : perfil.jsp
    Created on : 27/11/2025
    Author     : Filipe & Caio
    Description:
        Página de exibição do perfil do usuário logado, contendo:
        - Foto de perfil (com fallback)
        - Dados principais (nome, email, CEP)
        - Links para editar dados, alterar senha, configurações e dúvidas
        - Integração com o sistema de tema global
    ======================================================================
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String ctx = request.getContextPath();
    Integer idUsuario = (Integer) session.getAttribute("idUsuario");

    if (idUsuario == null) {
        response.sendRedirect(ctx + "/login/login.jsp");
        return;
    }

    String nome  = (String) session.getAttribute("nomeUsuario");
    String email = (String) session.getAttribute("emailUsuario");
    String cep   = (String) session.getAttribute("cepUsuario");

    // Tema global via cookie
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
<title>Meu Perfil - GPS for Agents</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<style>

/* -------------------------------------------------------------
   VARIÁVEIS DE TEMA
------------------------------------------------------------- */
:root {
    --bg: #000;
    --text: #fff;
    --card: #111;
    --card2: #181818;
    --border: #4CAF50;
    --btn-bg: #1f1f1f;
    --btn-text: #ddd;
    --input-bg: #222;
}

body.light {
    --bg: #f9f9f9;
    --text: #111;
    --card: #ffffff;
    --card2: #efefef;
    --border: #2e7dff;
    --btn-bg: #e7e7e7;
    --btn-text: #111;
    --input-bg: #fff;
}

body {
    background: var(--bg);
    color: var(--text);
    font-family: 'Segoe UI';
    transition: .3s;
}

/* -------------------------------------------------------------
   BOTÃO DE TEMA
------------------------------------------------------------- */
#themeToggle {
    position: fixed;
    right: 20px;
    top: 20px;
    background: transparent;
    border: none;
    font-size: 28px;
    color: var(--text);
    cursor: pointer;
    transition: .25s;
    z-index: 999999;
}

#themeToggle:hover {
    transform: scale(1.15);
}

/* -------------------------------------------------------------
   CONTAINER PRINCIPAL
------------------------------------------------------------- */
.perfil-wrapper {
    max-width: 650px;
    margin: 85px auto;
    padding: 30px;
    background: var(--card);
    border-radius: 14px;
    border: 2px solid var(--border);
}

/* -------------------------------------------------------------
   FOTO / AVATAR
------------------------------------------------------------- */
.perfil-foto {
    width: 150px;
    height: 150px;
    border-radius: 50%;
    background: var(--input-bg);
    border: 3px solid var(--border);
    margin: auto;
    position: relative;
    overflow: hidden;
    display: flex;
    justify-content: center;
    align-items: center;
}

.perfil-foto img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

/* botão de alterar foto */
.btn-foto {
    position: absolute;
    bottom: -3px;
    right: -3px;
    background: var(--border);
    border-radius: 50%;
    padding: 10px;
    cursor: pointer;
    font-size: 18px;
    border: none;
    color: #000;
    transition: .2s;
}

.btn-foto:hover {
    transform: scale(1.12);
}

/* -------------------------------------------------------------
   BOX DE DADOS
------------------------------------------------------------- */
.dados-box {
    margin-top: 25px;
    background: var(--card2);
    padding: 22px;
    border-radius: 10px;
    border: 1px solid #3333;
}

/* -------------------------------------------------------------
   BOTÕES DE AÇÃO
------------------------------------------------------------- */
.btn-action {
    width: 100%;
    margin-top: 12px;
    padding: 12px;
    border-radius: 8px;
    background: var(--btn-bg);
    border: 1px solid #333;
    color: var(--btn-text);
    transition: .3s;
    font-weight: 500;
}

.btn-action:hover {
    background: var(--border);
    color: #000;
    transform: translateY(-2px);
}

.btn-sair {
    width: 100%;
    margin-top: 18px;
    padding: 12px;
    border-radius: 8px;
}

.btn-voltar {
    width: 100%;
    margin-top: 15px;
    background: var(--border);
    color: #000;
    padding: 12px;
    border-radius: 8px;
    font-weight: bold;
}

</style>
</head>

<body class="<%= temaCookie %>">

<!-- BOTÃO DO TEMA GLOBAL -->
<button id="themeToggle">🌙</button>

<!-- ==============================================================
     CONTEÚDO PRINCIPAL DO PERFIL
============================================================== -->
<div class="perfil-wrapper">

    <!-- FOTO DO PERFIL COM FALLBACK -->
    <div class="perfil-foto">
        <img 
            src="<%= ctx %>/foto?id=<%= idUsuario %>"
            onerror="
                this.onerror=null;
                this.style.display='none';
                document.getElementById('fallbackIcon').style.display='flex';
            "
        />

        <div id="fallbackIcon"
             style="display:none;width:100%;height:100%;align-items:center;justify-content:center;">
            <i class="bi bi-person" style="font-size:80px;color:var(--border);"></i>
        </div>

        <button class="btn-foto"
                onclick="window.location.href='<%= ctx %>/site/upload-foto.jsp'">
            <i class="bi bi-camera-fill"></i>
        </button>
    </div>

    <!-- TÍTULO -->
    <h3 class="text-center fw-bold mt-3" style="color:var(--border);">Meu Perfil</h3>

    <!-- DADOS DO USUÁRIO -->
    <div class="dados-box">
        <p><strong>Nome:</strong> <%= nome %></p>
        <p><strong>E-mail:</strong> <%= email %></p>
        <p><strong>CEP:</strong> <%= cep %></p>
    </div>

    <!-- BOTÕES DE NAVEGAÇÃO -->
    <button class="btn-action" onclick="window.location.href='<%= ctx %>/site/editar-dados.jsp'">
        <i class="bi bi-pencil-square"></i> Editar Dados
    </button>

    <button class="btn-action" onclick="window.location.href='<%= ctx %>/site/alterar-senha.jsp'">
        <i class="bi bi-shield-lock"></i> Alterar Senha
    </button>

    <button class="btn-action" onclick="window.location.href='<%= ctx %>/site/configuracoes.jsp'">
        <i class="bi bi-gear"></i> Configurações
    </button>

    <button class="btn-action" onclick="window.location.href='<%= ctx %>/site/duvidas.jsp'">
        <i class="bi bi-question-circle"></i> Dúvidas / Ajuda
    </button>

    <button class="btn btn-danger btn-sair"
            onclick="window.location.href='<%= ctx %>/index.jsp'">
        <i class="bi bi-box-arrow-right"></i> Sair
    </button>

    <button class="btn-voltar" onclick="window.location.href='<%= ctx %>/site/home.jsp'">
        Voltar ao Mapa
    </button>

</div>

<!-- ==============================================================
     SISTEMA DE TEMA GLOBAL
============================================================== -->
<script>
function getCookie(name) {
    const m = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
    return m ? m[2] : null;
}

function applySavedTheme() {
    const tema = getCookie("temaGlobal") || localStorage.getItem("theme") || "dark";
    document.body.classList.toggle("light", tema === "light");
    updateIcon();
}

function toggleTheme() {
    document.body.classList.toggle("light");
    const tema = document.body.classList.contains("light") ? "light" : "dark";
    document.cookie = "temaGlobal=" + tema + "; path=/; max-age=31536000";
    localStorage.setItem("theme", tema);
    updateIcon();
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
