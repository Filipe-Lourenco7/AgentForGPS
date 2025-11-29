<%-- 
    =====================================================================
    Document   : mapa.jsp (Exportar Mapa)
    Created on : 27/11/2025
    Author     : Filipe & Caio
    Description:
        Página responsável pela exportação avançada do mapa,
        permitindo o usuário:
            • Baixar PNG via Google Static Maps
            • Baixar PDF da visualização
            • Criar shapes (Retângulos e Círculos)
            • Editar e excluir shapes
            • Visualizar os pins com labels grandes
    =====================================================================
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String ctx = request.getContextPath();

    // ============================================================
    // CARREGAR TEMA GLOBAL DO COOKIE
    // ============================================================
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
<title>Exportar Mapa - GPS for Agents</title>

<style>
/* ============================================================
   ESTILOS BÁSICOS E VARIÁVEIS DO TEMA
   ============================================================ */
* { box-sizing: border-box; }

:root {
    --bg: #000;
    --text: #e8e8e8;
    --sidebar: #0b0b0b;
    --accent: #2ecc71;
    --danger: #641313;
    --danger-hover: #e74c3c;
    --btn-bg: #1c1c1c;
}

body.light {
    --bg: #ffffff;
    --text: #222;
    --sidebar: #f0f0f0;
    --accent: #2e7dff;
    --danger: #ffbaba;
    --danger-hover: #ff6b6b;
    --btn-bg: #dddddd;
}

body, html {
    margin: 0;
    padding: 0;
    height: 100%;
    background: var(--bg);
    color: var(--text);
    font-family: Arial, sans-serif;
    transition: background .3s, color .3s;
}

/* ============================================================
   SIDEBAR
   ============================================================ */
#sidebar {
    width: 260px;
    height: 100vh;
    background: var(--sidebar);
    padding: 22px;
    border-right: 2px solid var(--accent);
    position: fixed;
    left: 0;
    top: 0;
    display: flex;
    flex-direction: column;
    gap: 12px;
    z-index: 20;
    transition: background .3s, color .3s;
}

/* ============================================================
   BOTÃO DE TEMA (igual ao padrão utilizado no home.jsp)
   ============================================================ */
#themeToggle {
    position: fixed;
    top: 15px;
    right: 15px;
    font-size: 30px;
    background: transparent;
    border: none;
    color: var(--text);
    cursor: pointer;
    transition: .25s;
    z-index: 999;
}

#themeToggle:hover { transform: scale(1.15); }

/* ============================================================
   BOTÕES DO SIDEBAR
   ============================================================ */
.btn-action {
    width: 100%;
    padding: 12px;
    background: var(--btn-bg);
    border: none;
    border-radius: 8px;
    color: var(--text);
    cursor: pointer;
    font-size: 15px;
    transition: .2s;
    text-align: left;
}

.btn-action:hover {
    background: var(--accent);
    color: #fff;
    transform: translateY(-2px);
}

.danger { background: var(--danger) !important; }
.danger:hover { background: var(--danger-hover) !important; color: #fff; }

/* ============================================================
   ÁREA DO MAPA
   ============================================================ */
#map {
    position: absolute;
    left: 260px;
    top: 0;
    width: calc(100% - 260px);
    height: 100vh;
}

/* Indicador de modo */
.badge-mode {
    font-size: 12px;
    background: #222;
    padding: 4px 8px;
    border-radius: 6px;
}

body.light .badge-mode {
    background: #ddd;
    color: #222;
}

.gm-style .gm-style-iw-c {
    color: #000 !important;
}
</style>
</head>

<body class="<%= temaCookie %>">

<!-- ============================================================
     BOTÃO DE TEMA GLOBAL
     ============================================================ -->
<button id="themeToggle">🌙</button>

<!-- ============================================================
     SIDEBAR – MENU DE EXPORTAÇÃO
     ============================================================ -->
<div id="sidebar">

    <h2 style="margin:0">Exportar mapa</h2>
    <div style="font-size:13px">
        Mapa travado para exportação.<br>
        <span id="modo" class="badge-mode">Modo: Visualização</span>
    </div>

    <!-- Ações principais -->
    <button id="btnPNG" class="btn-action">🖼️ Baixar PNG</button>
    <button id="btnPDF" class="btn-action">📄 Baixar PDF (tela)</button>

    <!-- Criação de shapes -->
    <button id="btnRect" class="btn-action">⬛ Desenhar retângulo</button>
    <button id="btnCircle" class="btn-action">⭕ Desenhar círculo</button>

    <!-- Limpar tudo -->
    <button id="btnClear" class="btn-action danger">🗑️ Limpar desenhos</button>

    <!-- Voltar -->
    <button id="btnVoltar" class="btn-action danger">⬅️ Voltar</button>
</div>

<!-- MAPA -->
<div id="map"></div>

<!-- DEPENDÊNCIAS -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

<script>
/* =======================================================================
   VARIÁVEIS GERAIS E CONFIGURAÇÕES CARREGADAS DO LOCALSTORAGE
   ======================================================================= */
const BASE = "<%= ctx %>";
const GOOGLE_KEY = "AIzaSyDF4L49IMVcew2OAuPet4sXlgv_fkBCOsw";
const SHAPES_KEY = "gps_shapes";

// Estado salvo vindo do home.jsp
const lat  = Number(localStorage.getItem("gps_lat")  || -23.5226);
const lng  = Number(localStorage.getItem("gps_lng")  || -46.1883);
const zoom = Number(localStorage.getItem("gps_zoom") || 14);
const pins = JSON.parse(localStorage.getItem("gps_pins") || "[]");

let map;
let shapes = [];
let drawingManager;

console.log("📌 PINS RECEBIDOS NO MAPA.JSP:", pins);

/* =======================================================================
   INICIALIZAR MAPA
   ======================================================================= */
function initMap() {
    map = new google.maps.Map(document.getElementById("map"), {
        center: { lat, lng },
        zoom,
        draggable: false,
        scrollwheel: false,
        gestureHandling: "none",
        disableDoubleClickZoom: true,
        clickableIcons: false
    });

    carregarPins();         // Renderizar pins com textos grandes
    loadSavedShapes();      // Carregar shapes salvos
    inicializarDrawingManager();
    configurarBotoes();
}

/* =======================================================================
   RENDERIZAÇÃO DOS PINS COM LABELS GRANDES (CANVAS)
   ======================================================================= */
function carregarPins() {
    pins.forEach(p => {
        const nota = p.nota || "Sem anotação";
        const tipo = p.tipo || "pin";

        // Renderização do texto em canvas
        const canvas = document.createElement("canvas");
        canvas.width = 550;
        canvas.height = 80;

        const ctx2 = canvas.getContext("2d");
        ctx2.font = "26px Arial";
        ctx2.fillStyle = "#fff";
        ctx2.strokeStyle = "#000";
        ctx2.lineWidth = 6;
        ctx2.strokeText(nota, 15, 50);
        ctx2.fillText(nota, 15, 50);

        const textIcon = {
            url: canvas.toDataURL(),
            scaledSize: new google.maps.Size(260, 50)
        };

        const marker = new google.maps.Marker({
            map,
            position: { lat: Number(p.lat), lng: Number(p.lng) },
            icon: tipo === "casa" ? {
                url: "https://maps.gstatic.com/mapfiles/kml/shapes/homegardenbusiness.png",
                scaledSize: new google.maps.Size(32, 32)
            } : null
        });

        const labelMarker = new google.maps.Marker({
            map,
            position: marker.getPosition(),
            icon: textIcon,
            clickable: false
        });

        google.maps.event.addListener(marker, "position_changed", () => {
            labelMarker.setPosition(marker.getPosition());
        });
    });
}

/* =======================================================================
   SHAPES (CARREGAR / SALVAR / EDITAR)
   ======================================================================= */
function loadSavedShapes() {
    const saved = JSON.parse(localStorage.getItem(SHAPES_KEY) || "[]");

    saved.forEach(s => {
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
                fillColor: "#2ecc71",
                fillOpacity: 0.15,
                editable: true
            });
        }

        if (s.tipo === "circle") {
            shape = new google.maps.Circle({
                map,
                center: { lat: s.lat, lng: s.lng },
                radius: s.radius,
                strokeColor: "#2ecc71",
                fillColor: "#2ecc71",
                fillOpacity: 0.15,
                editable: true
            });
        }

        shapes.push(shape);
        attachShapeEvents(shape);
    });
}

function saveShapes() {
    const json = [];

    shapes.forEach(s => {
        if (s instanceof google.maps.Rectangle) {
            const b = s.getBounds();
            json.push({
                tipo: "rectangle",
                north: b.getNorthEast().lat(),
                south: b.getSouthWest().lat(),
                east: b.getNorthEast().lng(),
                west: b.getSouthWest().lng()
            });
        }

        if (s instanceof google.maps.Circle) {
            json.push({
                tipo: "circle",
                lat: s.getCenter().lat(),
                lng: s.getCenter().lng(),
                radius: s.getRadius()
            });
        }
    });

    localStorage.setItem(SHAPES_KEY, JSON.stringify(json));
}

function attachShapeEvents(shape) {
    google.maps.event.addListener(shape, "bounds_changed", saveShapes);
    google.maps.event.addListener(shape, "radius_changed", saveShapes);
    google.maps.event.addListener(shape, "center_changed", saveShapes);

    google.maps.event.addListener(shape, "click", () => {
        selecionarShapeParaExcluir(shape);
    });
}

function selecionarShapeParaExcluir(shape) {
    shape.setOptions({ strokeColor: "#ff0000", fillColor: "#ff0000" });

    setTimeout(() => {
        shape.setOptions({ strokeColor: "#2ecc71", fillColor: "#2ecc71" });
    }, 800);

    if (confirm("Excluir somente este desenho?")) {
        shape.setMap(null);
        shapes = shapes.filter(s => s !== shape);
        saveShapes();
    }
}

/* =======================================================================
   DRAWING MANAGER (Ferramentas de desenho)
   ======================================================================= */
function inicializarDrawingManager() {
    drawingManager = new google.maps.drawing.DrawingManager({
        drawingMode: null,
        drawingControl: false,
        rectangleOptions: {
            strokeColor: "#2ecc71",
            fillColor: "#2ecc71",
            fillOpacity: 0.15,
            editable: true
        },
        circleOptions: {
            strokeColor: "#2ecc71",
            fillColor: "#2ecc71",
            fillOpacity: 0.15,
            editable: true
        }
    });

    drawingManager.setMap(map);

    google.maps.event.addListener(drawingManager, "overlaycomplete", event => {
        shapes.push(event.overlay);
        attachShapeEvents(event.overlay);
        saveShapes();

        modo.textContent = "Modo: Visualização";
        drawingManager.setDrawingMode(null);
    });
}

/* =======================================================================
   BOTÕES DO SIDEBAR
   ======================================================================= */
function configurarBotoes() {
    // Criar retângulo
    document.getElementById("btnRect").onclick = () => {
        drawingManager.setDrawingMode(google.maps.drawing.OverlayType.RECTANGLE);
        modo.textContent = "Modo: Desenhando (Retângulo)";
    };

    // Criar círculo
    document.getElementById("btnCircle").onclick = () => {
        drawingManager.setDrawingMode(google.maps.drawing.OverlayType.CIRCLE);
        modo.textContent = "Modo: Desenhando (Círculo)";
    };

    // Limpar tudo
    document.getElementById("btnClear").onclick = () => {
        if (confirm("Tem certeza que deseja excluir TODOS os desenhos?")) {
            shapes.forEach(s => s.setMap(null));
            shapes = [];
            saveShapes();
        }
    };

    // Voltar ao home
    document.getElementById("btnVoltar").onclick = () => {
        window.location.href = BASE + "/site/home.jsp";
    };

    // Exportações
    document.getElementById("btnPNG").onclick = baixarPNGStaticMaps;
    document.getElementById("btnPDF").onclick = baixarPDFTela;
}

/* =======================================================================
   EXPORTAR PNG VIA STATIC MAPS
   ======================================================================= */
function baixarPNGStaticMaps() {
    const center = map.getCenter();
    const zoomAtual = map.getZoom();

    const baseUrl = "https://maps.googleapis.com/maps/api/staticmap";

    const params = [
        "center=" + center.lat() + "," + center.lng(),
        "zoom=" + zoomAtual,
        "size=1280x720",
        "scale=2"
    ];

    pins.forEach(p => {
        if (p.tipo === "casa") {
            params.push(
                "markers=icon:https://maps.gstatic.com/mapfiles/kml/shapes/homegardenbusiness.png|" +
                p.lat + "," + p.lng
            );
        } else {
            params.push("markers=color:red|" + p.lat + "," + p.lng);
        }
    });

    params.push("key=" + GOOGLE_KEY);

    const link = document.createElement("a");
    link.href = baseUrl + "?" + params.join("&");
    link.download = "mapa.png";
    link.click();
}

/* =======================================================================
   EXPORTAR PDF DA TELA (html2canvas + jsPDF)
   ======================================================================= */
async function baixarPDFTela() {
    const canvas = await html2canvas(document.getElementById("map"), { scale: 2, useCORS: true });
    const img = canvas.toDataURL("image/jpeg");

    const { jsPDF } = window.jspdf;
    const pdf = new jsPDF("l", "mm", "a4");

    pdf.addImage(img, "JPEG", 10, 10, 277, 180);
    pdf.save("mapa.pdf");
}

/* =======================================================================
   TEMA GLOBAL — MESMO PADRÃO DO HOME.JSP
   ======================================================================= */
function applySavedTheme() {
    const tema = getCookie("temaGlobal") || "dark";

    if (tema === "light") {
        document.body.classList.add("light");
    } else {
        document.body.classList.remove("light");
    }

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
    const btn = document.getElementById("themeToggle");
    btn.textContent = document.body.classList.contains("light") ? "🌞" : "🌙";
}

function getCookie(name) {
    const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
    return match ? match[2] : null;
}

document.getElementById("themeToggle").addEventListener("click", toggleTheme);

applySavedTheme();
</script>

<!-- ============================================================
     GOOGLE MAPS + LIBRARY DRAWING
     ============================================================ -->
<script async
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDF4L49IMVcew2OAuPet4sXlgv_fkBCOsw&callback=initMap&libraries=drawing">
</script>

</body>
</html>
