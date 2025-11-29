<%@ page contentType="text/html; charset=UTF-8" %>

<%
    /*
       ------------------------------------------------------------
       Página: Minhas Anotações
       Sistema: GPS for Agents
       Criado por: Filipe & Caio
       ------------------------------------------------------------

       Esta página é responsável por exibir todas as anotações
       cadastradas pelo usuário no mapa. Ela permite visualizar,
       editar, excluir e navegar até o local da anotação.
       ------------------------------------------------------------
    */

    String ctx = request.getContextPath();

    // Verifico se o usuário está autenticado.
    // Caso contrário, redireciono para o login.
    Integer idUsuario = (Integer) session.getAttribute("idUsuario");
    if (idUsuario == null) {
        response.sendRedirect(ctx + "/login/login.jsp");
        return;
    }

    // Carrego o tema salvo pelo usuário através de cookies.
    // O tema padrão é o escuro.
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
<title>Minhas Anotações - GPS for Agents</title>

<!-- Bootstrap (estrutura, espaçamento e utilitários) -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Ícones do Bootstrap para botões e ações -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<style>
    /*
       O sistema alterna entre os temas claro e escuro.
       Cada tema redefine o layout principal do body.
    */
    body.dark {
        background: #000;
        color: #fff;
    }

    body.light {
        background: #fff;
        color: #111;
    }

    /*
       Container principal da página.
       Mantém o conteúdo centralizado e organizado.
    */
    .wrapper {
        max-width: 800px;
        margin: 40px auto;
        background: #111;
        padding: 25px;
        border-radius: 14px;
        border: 1px solid #4CAF50;
    }

    body.light .wrapper {
        background: #f2f2f2;
        border-color: #2e7dff;
    }

    /*
       Card individual de cada anotação.
       Mostra a nota, latitude, longitude e ações.
    */
    .nota-card {
        background: #1a1a1a;
        padding: 18px;
        border-radius: 10px;
        border: 1px solid #333;
        margin-bottom: 15px;
        transition: .2s;
    }

    body.light .nota-card {
        background: #e7e7e7;
        border-color: #bbb;
    }

    .nota-card p {
        white-space: pre-wrap; /* Mantém quebra de linha original */
    }

    /*
       Botão de "Voltar ao mapa".
       Colocado ao final da página para retornar ao home.jsp.
    */
    .btn-voltar {
        width: 100%;
        background: #4CAF50;
        color: #000;
        padding: 12px;
        border-radius: 8px;
        border: none;
        margin-top: 20px;
        font-weight: bold;
    }

    /*
       Botão de Selecionar Todos.
       Ajustado para combinar com sistema de bordas.
    */
    .btn-select {
        border: 1px solid var(--border);
        color: var(--border);
        background: transparent;
        padding: 6px 12px;
        border-radius: 6px;
        font-weight: 500;
        transition: .3s;
    }

    .btn-select:hover {
        background: var(--border);
        color: #000;
    }
</style>
</head>

<body class="<%= temaCookie %>">

<div class="wrapper">

    <!-- Título principal -->
    <h3 class="text-success text-center fw-bold">Minhas Anotações</h3>

    <!-- Linha de ações superiores -->
    <div class="d-flex justify-content-between mt-3 mb-3">
        <button class="btn-select btn-sm" onclick="toggleSelecionarTodos()">
            <i class="bi bi-check2-square"></i> Selecionar Todos
        </button>

        <button class="btn btn-danger btn-sm" onclick="excluirSelecionados()">
            <i class="bi bi-trash3"></i> Excluir Selecionados
        </button>
    </div>

    <!-- Local onde as anotações são renderizadas dinamicamente -->
    <div id="listaNotas"></div>

    <!-- Voltar ao mapa -->
    <button class="btn-voltar" onclick="window.location.href='<%= ctx %>/site/home.jsp'">
        Voltar ao Mapa
    </button>
</div>

<script>
const BASE = "<%= ctx %>";
let selecionarTodosAtivo = false;

/*
    Esta função evita falhas de renderização ou quebras
    de página caso o usuário digite caracteres especiais.
*/
function escapeHTML(str) {
    if (!str) return "";
    return str
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

/*
    Função principal para carregar todas as anotações
    salvas no banco e retornadas pelo servlet /marcador.
*/
function carregarNotas() {
    fetch(BASE + "/marcador?action=list")
        .then(r => r.json())
        .then(lista => {
            const container = document.getElementById("listaNotas");
            container.innerHTML = "";

            if (!lista || lista.length === 0) {
                container.innerHTML = "<p class='text-center mt-3'>Nenhuma anotação cadastrada.</p>";
                return;
            }

            // Renderiza dinamicamente cada anotação recebida
            lista.forEach(m => {
                let notaSafe = escapeHTML(m.nota || "Sem anotação");

                const html =
                "<div class='nota-card'>" +
                    "<div class='d-flex justify-content-between'>" +
                        "<h5 class='text-success'>Anotação</h5>" +
                        "<input type='checkbox' class='chk' value='" + m.id + "'>" +
                    "</div>" +

                    "<p>" + notaSafe + "</p>" +

                    "<p class='text-secondary'>" +
                        "<strong>Latitude:</strong> " + m.lat + "<br>" +
                        "<strong>Longitude:</strong> " + m.lng +
                    "</p>" +

                    "<button class='btn btn-primary btn-sm' onclick='editar(" + m.id + ", \"" + notaSafe + "\")'>" +
                        "<i class='bi bi-pencil-square'></i> Editar" +
                    "</button> " +

                    "<button class='btn btn-danger btn-sm' onclick='excluir(" + m.id + ")'>" +
                        "<i class='bi bi-trash'></i> Excluir" +
                    "</button> " +

                    "<button class='btn btn-success btn-sm' onclick='irParaMapa(" + m.lat + ", " + m.lng + ")'>" +
                        "<i class='bi bi-geo-alt'></i> Ver no mapa" +
                    "</button>" +
                "</div>";

                container.innerHTML += html;
            });
        })
        .catch(err => {
            document.getElementById("listaNotas").innerHTML =
                "<p class='text-center text-danger mt-3'>Erro ao carregar anotações.</p>";
        });
}

/*
    Alterna entre selecionar e desmarcar todos os checkboxes.
*/
function toggleSelecionarTodos() {
    selecionarTodosAtivo = !selecionarTodosAtivo;
    document.querySelectorAll(".chk").forEach(c => c.checked = selecionarTodosAtivo);
}

/*
    Exclui apenas um item.
*/
function excluir(id) {
    if (!confirm("Deseja excluir esta anotação?")) return;
    excluirVarios([id]);
}

/*
    Coleta os IDs marcados e exclui todos de uma vez.
*/
function excluirSelecionados() {
    const ids = [...document.querySelectorAll(".chk:checked")].map(c => c.value);
    if (ids.length === 0) return alert("Nenhuma anotação selecionada.");
    if (!confirm("Excluir " + ids.length + " anotações?")) return;
    excluirVarios(ids);
}

/*
    Comunicação com o backend para exclusão múltipla.
*/
function excluirVarios(lista) {
    fetch(BASE + "/marcador", {
        method: "POST",
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: "action=deleteMany&ids=" + encodeURIComponent(lista.join(","))
    }).then(() => carregarNotas());
}

/*
    Permite editar o conteúdo da anotação diretamente pelo prompt.
*/
function editar(id, notaAtual) {
    const nova = prompt("Editar anotação:", notaAtual);
    if (!nova) return;

    fetch(BASE + "/marcador", {
        method: "POST",
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: "action=edit&id=" + id + "&nota=" + encodeURIComponent(nova)
    }).then(() => carregarNotas());
}

/*
    Salva coordenadas no localStorage para focar o mapa
    no ponto desejado ao retornar para home.jsp.
*/
function irParaMapa(lat, lng) {
    localStorage.setItem("gps_lat", lat);
    localStorage.setItem("gps_lng", lng);
    localStorage.setItem("gps_zoom", 18);
    window.location.href = BASE + "/site/home.jsp";
}

// Carregamento inicial das anotações
carregarNotas();
</script>

</body>
</html>
