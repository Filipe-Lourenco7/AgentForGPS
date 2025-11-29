    <%-- 
    ======================================================================
    Document   : upload-foto.jsp
    Created on : 27/11/2025
    Author     : Filipe & Caio
    Description:
        Tela destinada ao envio/alteração da foto de perfil do usuário.
        Inclui:
        - Pré-visualização da foto
        - Integração total com o tema global
        - Fallback automático quando não existe foto
        - Upload multipart para o servlet uploadFoto
    ======================================================================
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String ctx = request.getContextPath();
    String nome = (String) session.getAttribute("nomeUsuario");
    Integer idUsuario = (Integer) session.getAttribute("idUsuario");

    // Proteção: usuário não autenticado
    if (idUsuario == null) {
        response.sendRedirect(ctx + "/login/login.jsp");
        return;
    }

    // Tema via cookie
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
<title>Alterar Foto - GPS for Agents</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<style>

/* ================================================================
   VARIÁVEIS DE TEMA
================================================================ */
:root {
    --bg: #000;
    --text: #fff;
    --card: #111;
    --border: #4caf50;
    --btn-bg: #1a1a1a;
    --btn-text: #ddd;
}

body.light {
    --bg: #fff;
    --text: #111;
    --card: #f2f2f2;
    --border: #4caf50;
    --btn-bg: #ddd;
    --btn-text: #111;
}

/* ================================================================
   LAYOUT PRINCIPAL
================================================================ */
body {
    background: var(--bg);
    color: var(--text);
    font-family: "Segoe UI";
    transition: .3s;
}

.upload-wrapper {
    max-width: 500px;
    margin: 50px auto;
    background: var(--card);
    padding: 30px;
    border-radius: 14px;
    border: 1px solid var(--border);
    text-align: center;
    animation: fadeIn .4s ease;
}

/* animação entrada */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to   { opacity: 1; transform: translateY(0); }
}

/* ================================================================
   PREVIEW DA FOTO
================================================================ */
.preview-box {
    width: 160px;
    height: 160px;
    border-radius: 50%;
    background: #222;
    margin: auto;
    border: 3px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
}

.preview-box img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

/* ================================================================
   INPUT DE ARQUIVO (customizado)
================================================================ */
label.custom-file-upload {
    margin-top: 20px;
    padding: 12px;
    width: 100%;
    background: var(--btn-bg);
    color: var(--btn-text);
    border: 1px solid #333;
    border-radius: 8px;
    cursor: pointer;
    transition: .25s;
}

label.custom-file-upload:hover {
    background: var(--border);
    color: #000;
    transform: translateY(-2px);
}

input[type="file"] {
    display: none;
}

/* Botão salvar */
.btn-salvar {
    margin-top: 20px;
    width: 100%;
    padding: 12px;
    font-size: 16px;
    background: var(--border);
    border: none;
    border-radius: 8px;
    color: #000;
    font-weight: bold;
    transition: .25s;
}

.btn-salvar:hover {
    opacity: .9;
    transform: translateY(-2px);
}

/* Botão voltar */
.btn-voltar {
    margin-top: 15px;
    width: 100%;
    padding: 12px;
    background: var(--btn-bg);
    color: var(--btn-text);
    border: 1px solid #333;
    border-radius: 8px;
    transition: .25s;
}

.btn-voltar:hover {
    background: var(--border);
    color: #000;
    transform: translateY(-2px);
}

/* ================================================================
   BOTÃO DO TEMA GLOBAL
================================================================ */
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
}

#themeToggle:hover {
    transform: scale(1.15);
}

</style>
</head>

<body class="<%= temaCookie %>">

<!-- Botão Tema -->
<button id="themeToggle">🌙</button>

<!-- ================================================================
     CONTEÚDO PRINCIPAL
================================================================ -->
<div class="upload-wrapper">

    <h3 class="fw-bold" style="color:var(--border)">Alterar Foto de Perfil</h3>
    <p>Olá, <strong><%= nome %></strong>. Escolha sua nova foto:</p>

    <!-- Preview da foto atual -->
    <div class="preview-box" id="previewBox">
        <img 
            src="<%= ctx %>/foto?id=<%= idUsuario %>"
            onerror="this.style.display='none'; fallback.style.display='flex';">
        
        <!-- fallback quando não há foto -->
        <div id="fallback" style="display:none; width:100%; height:100%;
             align-items:center; justify-content:center;">
            <i class="bi bi-person" style="font-size:70px; color:var(--border);"></i>
        </div>
    </div>

    <!-- Erros de upload -->
    <% 
        String erro = (String) request.getAttribute("erro");
        if (erro != null) { 
    %>
        <div class="alert alert-danger mt-3"><%= erro %></div>
    <% } %>

    <!-- Formulário de upload -->
    <form action="<%= ctx %>/uploadFoto" 
          method="post" 
          enctype="multipart/form-data">

        <label for="fileInput" class="custom-file-upload">
            <i class="bi bi-cloud-arrow-up"></i> Selecionar Foto
        </label>

        <input type="file" id="fileInput" name="foto" accept="image/*">

        <button class="btn-salvar" type="submit">Salvar Foto</button>
    </form>

    <button class="btn-voltar"
            onclick="window.location.href='<%= ctx %>/site/perfil.jsp'">
        Voltar ao Perfil
    </button>

</div>

<!-- ================================================================
     JAVA SCRIPT – Tema + Preview
================================================================ -->
<script>
// Tema global
function getCookie(n) {
    const m = document.cookie.match(new RegExp('(^| )' + n + '=([^;]+)'));
    return m ? m[2] : null;
}

function applyTheme() {
    const tema = getCookie("temaGlobal") || localStorage.getItem("theme") || "dark";
    document.body.classList.toggle("light", tema === "light");
    updateThemeIcon();
}

function toggleTheme() {
    document.body.classList.toggle("light");
    const tema = document.body.classList.contains("light") ? "light" : "dark";
    document.cookie = "temaGlobal=" + tema + "; path=/; max-age=31536000";
    localStorage.setItem("theme", tema);
    updateThemeIcon();
}

function updateThemeIcon() {
    document.getElementById("themeToggle").textContent =
        document.body.classList.contains("light") ? "🌞" : "🌙";
}

document.getElementById("themeToggle").onclick = toggleTheme;
applyTheme();

// Preview da foto selecionada
const preview = document.getElementById("previewBox");
const fileInput = document.getElementById("fileInput");

fileInput.addEventListener("change", function () {
    if (!this.files || !this.files[0]) return;

    if (!this.files[0].type.startsWith("image/")) {
        alert("Selecione uma imagem válida.");
        return;
    }

    const reader = new FileReader();
    reader.onload = e => preview.innerHTML = `<img src="${e.target.result}">`;
    reader.readAsDataURL(this.files[0]);
});

</script>

</body>
</html>
