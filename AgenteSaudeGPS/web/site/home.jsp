<%@ page contentType="text/html; charset=UTF-8" %>

<%
    /*
       ------------------------------------------------------------
       Página: Home (Mapa Principal)
       Sistema: GPS for Agents
       Criado por: Filipe & Caio
       ------------------------------------------------------------

       Esta é a página central do sistema. Aqui o usuário visualiza
       o mapa interativo, seus marcadores pessoais, ferramentas de
       edição, desenho e exportação. Também contém o menu lateral
       que permite navegar por todas as outras áreas do sistema.

       O tema é aplicado dinamicamente por cookie/localStorage,
       garantindo consistência visual em toda a experiência.
       ------------------------------------------------------------
    */

    String ctx = request.getContextPath();
    String cepUsuario = (String) session.getAttribute("cepUsuario");

    // Recupera o tema salvo no cookie global
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
<title>GPS for Agents - Home</title>

<!-- BOOTSTRAP -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<style>

    /*
       ------------------------------------------------------------
       VARIÁVEIS DE TEMA ESCURO
       ------------------------------------------------------------
    */
    :root {
        --bg: #000;
        --text: #fff;
        --sidebar: #0c0c0c;
        --card: #111;
        --accent: #4caf50;
    }

    /*
       ------------------------------------------------------------
       TEMA CLARO (sobrescrita das variáveis)
       ------------------------------------------------------------
    */
    body.light {
        --bg: #ffffff;
        --text: #111111;
        --sidebar: #e7e7e7;
        --card: #f4f4f4;
        --accent: #2e7dff;
    }

    /*
       ------------------------------------------------------------
       ESTILO GERAL
       ------------------------------------------------------------
    */
    body, html {
        margin: 0;
        padding: 0;
        height: 100%;
        overflow: hidden;
        background: var(--bg);
        font-family: 'Segoe UI', sans-serif;
        color: var(--text);
        transition: background .4s ease, color .4s ease;
    }

    /*
       ------------------------------------------------------------
       MENU LATERAL (SIDEBAR)
       ------------------------------------------------------------
    */
    #sidebar {
        width: 260px;
        height: 100vh;
        background: var(--sidebar);
        color: var(--text);
        position: fixed;
        top: 0;
        left: 0;
        padding: 22px;
        border-right: 3px solid var(--accent);
        z-index: 20;
        overflow-y: auto;
        transition: background .4s ease, color .4s ease;
    }

    /*
       ------------------------------------------------------------
       ÁREA PRINCIPAL DO MAPA
       ------------------------------------------------------------
    */
    #map {
        position: absolute;
        left: 260px;
        top: 0;
        width: calc(100% - 260px);
        height: 100vh;
    }

    /*
       ------------------------------------------------------------
       BOTÕES DO MENU LATERAL
       ------------------------------------------------------------
    */
    .btn-menu {
        width: 100%;
        background: var(--card);
        border: 1px solid #333;
        color: var(--text);
        margin-bottom: 12px;
        border-radius: 8px;
        padding: 12px;
        font-size: 15px;
        cursor: pointer;
        transition: 0.3s;
    }

    body.light .btn-menu {
        border: 1px solid #bbb;
    }

    .btn-menu:hover {
        background: var(--accent);
        color: #fff;
        transform: translateY(-2px);
    }

    /*
       ------------------------------------------------------------
       BOTÃO DO TEMA
       ------------------------------------------------------------
    */
    #themeToggle {
        background: transparent;
        border: none;
        font-size: 26px;
        cursor: pointer;
        color: var(--text);
        transition: .25s;
        float: right;
        margin-top: -10px;
    }

    #themeToggle:hover {
        transform: scale(1.15);
    }

    /*
       ------------------------------------------------------------
       BOTÃO DE MODO EDIÇÃO
       ------------------------------------------------------------
    */
    #btnToggleEdicao {
        width: 100%;
        padding: 10px;
        border-radius: 8px;
        font-size: 15px;
        background: #111;
        color: #FFC107;
        border: 2px solid #FFC107;
        font-weight: bold;
        transition: .2s;
    }

    body.light #btnToggleEdicao {
        background: #fff6d2;
        color: #8a6d00;
    }

    #btnToggleEdicao.active {
        background: #FFC107;
        color: #000;
    }

    /*
       ------------------------------------------------------------
       INFOWINDOW DO GOOGLE MAPS
       ------------------------------------------------------------
    */
    .gm-style .gm-style-iw-c {
        color: #000 !important;
    }

</style>
</head>

<!-- Body com o tema carregado do cookie -->
<body class="<%= temaCookie %>">

<!-- ============================================================
===================== SIDEBAR / MENU LATERAL ====================
=============================================================== -->
<div id="sidebar">

    <!-- Logo + botão de tema -->
    <div style="display:flex; justify-content:space-between; align-items:center;">
        <img id="logoSidebar" src="<%= ctx %>/imagem?id=7"
             style="width:140px; height:auto; border-radius:10px; cursor:pointer;">
        <button id="themeToggle">🌙</button>
    </div>

    <!-- Menu -->
    <button class="btn-menu"><i class="bi bi-geo-alt"></i> &nbsp;Mapa</button>

    <button class="btn-menu" onclick="window.location.href='<%= ctx %>/site/anotacoes.jsp'">
        <i class="bi bi-journal-text"></i> &nbsp;Minhas Anotações
    </button>

    <button class="btn-menu" onclick="window.location.href='<%= ctx %>/site/perfil.jsp'">
        <i class="bi bi-person-circle"></i> &nbsp;Perfil
    </button>

    <button class="btn-menu" onclick="window.location.href='<%= ctx %>/site/configuracoes.jsp'">
        <i class="bi bi-gear"></i> &nbsp;Configurações
    </button>

    <button class="btn-menu" onclick="window.location.href='<%= ctx %>/site/duvidas.jsp'">
        <i class="bi bi-question-circle"></i> &nbsp;Dúvidas
    </button>

    <hr>

    <!-- Busca por CEP -->
    <label>Buscar CEP:</label>
    <input type="text" id="cepInput" class="form-control mb-2" placeholder="Digite o CEP">
    <button id="btnBuscarCEP" class="btn btn-success w-100 mb-3">Buscar CEP</button>

    <hr>

    <!-- Exportação / Edição Avançada -->
    <button id="btnCriarMapa" class="btn btn-primary w-100 mb-3">Edição Avançada</button>

    <label>Modo Edição:</label>
    <button id="btnToggleEdicao" class="mb-4">OFF</button>

    <label>Tipo de Marcador:</label>
    <button id="btnTipoMarcador" class="btn btn-secondary w-100 mb-3">PIN</button>

    <hr>

    <button class="btn btn-danger w-100 mb-3" onclick="confirmarSaida()">Sair</button>

</div>

<!-- ÁREA DO GOOGLE MAPS -->
<div id="map"></div>

<!-- ============================================================
============================= MAPA ==============================
=============================================================== -->
<script>
    /*
       Toda a lógica do mapa foi preservada
       exatamente como você escreveu.
       Abaixo estão apenas comentários técnicos,
       explicando o que cada parte faz.
    */

    const BASE = "<%= ctx %>";
    const cepSessao = "<%= cepUsuario %>";

    let map, geocoder, infoWindow;
    let markers = [];
    let editMode = false;
    let markerType = "pin";

    let currentCenterLat = -23.5226;
    let currentCenterLng = -46.1883;
    let currentZoom = 14;

    /*
       ------------------------------------------------------------
       SHAPES (círculos e retângulos salvos via mapa.jsp)
       ------------------------------------------------------------
    */
    const SHAPES_KEY = "gps_shapes";
    let shapesDesenho = [];
    const infoShape = new google.maps.InfoWindow();

    /*
       Escapa caracteres perigosos para InfoWindow
    */
    function escapeHTML(str) {
        if (!str) return "";
        return str
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#39;");
    };

    /*
       Carrega shapes salvos no localStorage
    */
    function carregarShapes() {
        const saved = JSON.parse(localStorage.getItem(SHAPES_KEY) || "[]");

        saved.forEach((s, index) => {
            let shape;

            if (s.tipo === "rectangle") {
                shape = new google.maps.Rectangle({
                    map,
                    bounds: {
                        north: s.north,
                        south: s.south,
                        east: s.east,
                        west: s.west
                    },
                    strokeColor: "#2ecc71",
                    strokeOpacity: 1,
                    strokeWeight: 2,
                    fillColor: "#2ecc71",
                    fillOpacity: 0.15,
                    clickable: true,
                    editable: false
                });

            } else if (s.tipo === "circle") {
                shape = new google.maps.Circle({
                    map,
                    center: { lat: s.lat, lng: s.lng },
                    radius: s.radius,
                    strokeColor: "#2ecc71",
                    strokeOpacity: 1,
                    strokeWeight: 2,
                    fillColor: "#2ecc71",
                    fillOpacity: 0.15,
                    clickable: true,
                    editable: false
                });
            }

            shapesDesenho.push({ shape, index });

            google.maps.event.addListener(shape, "click", (e) => {
                infoShape.setContent(
                    "<div style='color:#000'>" +
                    "<b>Desenho selecionado</b><br>" +
                    "<button class='btn btn-danger btn-sm' onclick='excluirShape(" + index + ")'>Excluir</button>" +
                    "</div>"
                );
                infoShape.setPosition(e.latLng);
                infoShape.open(map);
            });
        });
    };

    /*
       Exclui shape por índice
    */
    function excluirShape(index) {
        const saved = JSON.parse(localStorage.getItem(SHAPES_KEY) || "[]");

        saved.splice(index, 1);
        localStorage.setItem(SHAPES_KEY, JSON.stringify(saved));

        shapesDesenho[index].shape.setMap(null);
        infoShape.close();

        location.reload();
    };

    /*
       ------------------------------------------------------------
       INICIALIZAÇÃO DO MAPA
       ------------------------------------------------------------
    */
    function initMap() {
        map = new google.maps.Map(document.getElementById("map"), {
            zoom: currentZoom,
            center: { lat: currentCenterLat, lng: currentCenterLng },
            draggable: true,
            scrollwheel: true
        });

        geocoder = new google.maps.Geocoder();
        infoWindow = new google.maps.InfoWindow();

        carregarMarcadores();
        carregarShapes();
        configurarUI();

        if (cepSessao) buscarCep(cepSessao);

        // >>>>>>> AQUI <<<<<<<<
        google.maps.event.addListener(map, "click", function (e) {
            if (!editMode) return;
            adicionarMarcador(e.latLng);
        });
    }

    /*
       Configura botões e interações
    */
    function configurarUI() {
        const btnTipo = document.getElementById("btnTipoMarcador");

        btnTipo.addEventListener("click", () => {
            if (markerType === "pin") {
                markerType = "casa";
                btnTipo.textContent = "CASA";
                btnTipo.style.background = "#4CAF50";
            } else {
                markerType = "pin";
                btnTipo.textContent = "PIN";
                btnTipo.style.background = "#6c757d";
            }
        });

        document.getElementById("btnBuscarCEP").onclick =
            () => buscarCep(document.getElementById("cepInput").value);

        document.getElementById("btnToggleEdicao").onclick = function () {
            editMode = !editMode;
            this.textContent = editMode ? "ON" : "OFF";
            this.classList.toggle("active");

            map.setOptions({
                draggable: !editMode,
                scrollwheel: !editMode
            });
        };

        document.getElementById("btnCriarMapa").onclick = salvarParaExportacao;
    };

    /*
       Busca por CEP via Google Maps Geocoder
    */
    function buscarCep(cepDigitado) {
        const cep = cepDigitado.replace(/\D/g, "");
        if (cep.length !== 8) return alert("CEP inválido");

        geocoder.geocode({ address: cep + ", Brasil" }, (results, status) => {
            if (status === "OK" && results[0]) {
                map.setCenter(results[0].geometry.location);
                map.setZoom(17);
            } else alert("CEP não encontrado.");
        });
    };

    /*
       Carrega marcadores salvos no banco
    */
    function carregarMarcadores() {
        fetch(BASE + "/marcador?action=list")
            .then(r => r.json())
            .then(lista => {

                lista.forEach(m => {
                    const nota = m.nota && m.nota.trim() !== "" ? m.nota : "Sem anotação";

                    const marker = new google.maps.Marker({
                        position: { lat: Number(m.lat), lng: Number(m.lng) },
                        map,
                        draggable: true,
                        title: escapeHTML(nota)
                    });

                    marker.nota = nota;
                    marker.tipo = m.tipo || "pin";
                    marker.idMarcador = m.id;

                    if (marker.tipo === "casa") {
                        marker.setIcon({
                            url: "https://maps.gstatic.com/mapfiles/kml/shapes/homegardenbusiness.png",
                            scaledSize: new google.maps.Size(32, 32)
                        });
                    }

                    marker.addListener("dragend", e =>
                        salvarNovaPosicao(marker, e.latLng.lat(), e.latLng.lng())
                    );

                    marker.addListener("click", () => mostrarInfo(marker));

                    markers.push(marker);
                });
            });
    };

    /*
       Mostra janela (InfoWindow) do marcador
    */
    function mostrarInfo(marker) {
        const notaEscapada = escapeHTML(marker.nota);

        const html =
            "<div style='min-width:220px;'>" +
            "<b>Nota:</b> " + notaEscapada + "<br><br>" +
            "<button id='btn-editar-pin' class='btn btn-primary btn-sm'>Editar</button> " +
            "<button id='btn-excluir-pin' class='btn btn-danger btn-sm'>Excluir</button>" +
            "</div>";

        infoWindow.setContent(html);
        infoWindow.open(map, marker);

        google.maps.event.addListenerOnce(infoWindow, "domready", () => {
            document.getElementById("btn-editar-pin").onclick = () => editarPin(marker);
            document.getElementById("btn-excluir-pin").onclick = () => excluirPin(marker);
        });
    };

    /*
       Edita anotação do marcador
    */
    function editarPin(marker) {
        const nova = prompt("Editar anotação:", marker.nota) || "Sem anotação";
        marker.nota = nova;
        marker.setTitle(escapeHTML(nova));

        fetch(BASE + "/marcador", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "action=updateNota&id=" + marker.idMarcador + "&nota=" + encodeURIComponent(nova)
        });

        mostrarInfo(marker);
    };

    /*
       Remove marcador do mapa e do banco
    */
    function excluirPin(marker) {
        if (!confirm("Deseja excluir este ponto?")) return;

        fetch(BASE + "/marcador", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "action=delete&id=" + marker.idMarcador
        })
            .then(r => r.json())
            .then(res => {
                if (res.ok) {
                    marker.setMap(null);
                    markers = markers.filter(m => m !== marker);
                    infoWindow.close();
                }
            });
    };

    /*
       Salva centro, zoom e marcadores no localStorage
       para permitir exportação (mapa.jsp)
    */
    function salvarParaExportacao() {
        const center = map.getCenter();
        localStorage.setItem("gps_lat", center.lat());
        localStorage.setItem("gps_lng", center.lng());
        localStorage.setItem("gps_zoom", map.getZoom());

        const listaPins = markers.map(m => ({
            id: m.idMarcador,
            lat: m.getPosition().lat(),
            lng: m.getPosition().lng(),
            nota: m.nota,
            tipo: m.tipo
        }));

        localStorage.setItem("gps_pins", JSON.stringify(listaPins));
        window.location.href = BASE + "/site/mapa.jsp";
    };

    /*
       Salva nova posição após arrastar pin
    */
    function salvarNovaPosicao(marker, lat, lng) {
        if (!marker.idMarcador) return;

        fetch(BASE + "/marcador", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body:
                "action=update&id=" + marker.idMarcador +
                "&lat=" + lat +
                "&lng=" + lng
        });
    }

    /*
       Criar novo marcador ao clicar no mapa (modo edição)
    */
    mapClickListener = null;

    function adicionarMarcador(latLng) {
        const nota = prompt("Anotação do ponto:") || "Sem anotação";

        const marker = new google.maps.Marker({
            position: latLng,
            map,
            draggable: true,
            title: escapeHTML(nota)
        });

        if (markerType === "casa") {
            marker.setIcon({
                url: "https://maps.gstatic.com/mapfiles/kml/shapes/homegardenbusiness.png",
                scaledSize: new google.maps.Size(32, 32)
            });
        }

        marker.nota = nota;
        marker.tipo = markerType;
        markers.push(marker);

        marker.addListener("dragend", e =>
            salvarNovaPosicao(marker, e.latLng.lat(), e.latLng.lng())
        );

        marker.addListener("click", () => mostrarInfo(marker));

        salvarMarcador(marker, latLng.lat(), latLng.lng(), nota, markerType);
    };

    function salvarMarcador(marker, lat, lng, nota, tipo) {
        const body =
            "action=add" +
            "&lat=" + lat +
            "&lng=" + lng +
            "&nota=" + encodeURIComponent(nota) +
            "&tipo=" + encodeURIComponent(tipo);

        fetch(BASE + "/marcador", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body
        })
            .then(r => r.json())
            .then(res => {
                if (res.ok) marker.idMarcador = res.id;
            });
    };

    /*
       Logout
    */
    function confirmarSaida() {
        if (confirm("Deseja realmente sair?")) {
            window.location.href = BASE + "/index.jsp";
        }
    }
</script>

<!-- Google Maps API -->
<script async src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDF4L49IMVcew2OAuPet4sXlgv_fkBCOsw&callback=initMap"></script>

<!-- ============================================================
========================= TEMA (GLOBAL) =========================
=============================================================== -->
<script>
    /*
       Leitura do cookie
    */
    function getCookie(name) {
        const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
        return match ? match[2] : null;
    };

    /*
       Aplica o tema salvo
    */
    function applySavedTheme() {
        let tema = getCookie("temaGlobal");

        if (!tema) tema = localStorage.getItem("theme");

        if (tema === "light") {
            document.body.classList.add("light");
        } else {
            document.body.classList.remove("light");
        }

        updateIcon();
        updateLogoSidebar();
    }

    /*
       Alterna o tema
    */
    function toggleTheme() {
        document.body.classList.toggle("light");

        const tema = document.body.classList.contains("light") ? "light" : "dark";

        localStorage.setItem("theme", tema);
        document.cookie = "temaGlobal=" + tema + "; path=/; max-age=31536000";

        updateIcon();
        updateLogoSidebar();
    }

    /*
       Atualiza ícone 🌞 / 🌙
    */
    function updateIcon() {
        const themeBtn = document.getElementById("themeToggle");
        themeBtn.textContent = document.body.classList.contains("light") ? "🌞" : "🌙";
    }

    /*
       Atualiza logo da sidebar (claro/escuro)
    */
    function updateLogoSidebar() {
        const logo = document.getElementById("logoSidebar");

        if (!logo) return;

        if (document.body.classList.contains("light")) {
            logo.src = "<%= ctx %>/imagem?id=5";  // logo clara
        } else {
            logo.src = "<%= ctx %>/imagem?id=7";  // logo escura
        }
    }

    /*
       Eventos do botão
    */
    document.getElementById("themeToggle")
        .addEventListener("click", toggleTheme);

    /*
       Aplica o tema ao carregar
    */
    applySavedTheme();
</script>

</body>
</html>
