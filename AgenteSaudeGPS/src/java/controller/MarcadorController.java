package controller;

/* ============================================================================
 *  MarcadorController
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - CRUD de marcadores (pontos no mapa)
 *      - Retorna JSON seguro
 *      - Controle por sessão
 * ============================================================================ */

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import model.Marcador;
import modelDAO.MarcadorDAO;

@WebServlet("/marcador")
public class MarcadorController extends HttpServlet {

    private final MarcadorDAO dao = new MarcadorDAO();

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "")
                .replace("\t", "\\t");
    }

    /* -------------------------------------------------------------------------
       LISTAR / GET
    ------------------------------------------------------------------------- */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("idUsuario") == null) {
            out.print("{\"error\":\"nao_logado\"}");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");

        if ("list".equals(action)) {

            List<Marcador> lista = dao.listarPorUsuario(idUsuario);
            StringBuilder json = new StringBuilder("[");

            for (int i = 0; i < lista.size(); i++) {
                Marcador m = lista.get(i);

                String nota = (m.getNota() == null || m.getNota().trim().isEmpty())
                                ? "Sem anotação"
                                : m.getNota();

                json.append("{")
                    .append("\"id\":").append(m.getId()).append(",")
                    .append("\"lat\":").append(m.getLat()).append(",")
                    .append("\"lng\":").append(m.getLng()).append(",")
                    .append("\"tipo\":\"").append(escape(m.getTipo())).append("\",")
                    .append("\"nota\":\"").append(escape(nota)).append("\"")
                    .append("}");

                if (i < lista.size() - 1) json.append(",");
            }

            json.append("]");
            out.print(json.toString());
        }
    }

    /* -------------------------------------------------------------------------
       ADD / UPDATE / DELETE / POST
    ------------------------------------------------------------------------- */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("idUsuario") == null) {
            out.print("{\"ok\":false}");
            return;
        }

        int idUsuario = (Integer) session.getAttribute("idUsuario");

        /* ---------------------------------------------------------------------
           ADICIONAR
        --------------------------------------------------------------------- */
        if ("add".equals(action)) {
            try {
                double lat = Double.parseDouble(request.getParameter("lat"));
                double lng = Double.parseDouble(request.getParameter("lng"));
                String nota = request.getParameter("nota");
                String tipo = request.getParameter("tipo");

                if (tipo == null || tipo.trim().isEmpty())
                    tipo = "pin";

                if (nota == null || nota.trim().isEmpty())
                    nota = "Sem anotação";

                Marcador m = new Marcador();
                m.setIdUsuario(idUsuario);
                m.setLat(lat);
                m.setLng(lng);
                m.setNota(nota);
                m.setTipo(tipo);

                int id = dao.inserir(m);
                out.print("{\"ok\":true, \"id\":" + id + "}");

            } catch (Exception e) {
                out.print("{\"ok\":false}");
            }
            return;
        }

        /* ---------------------------------------------------------------------
           ATUALIZAR POSIÇÃO
        --------------------------------------------------------------------- */
        if ("update".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                double lat = Double.parseDouble(request.getParameter("lat"));
                double lng = Double.parseDouble(request.getParameter("lng"));

                boolean ok = dao.atualizarPosicao(id, idUsuario, lat, lng);
                out.print("{\"ok\":" + ok + "}");

            } catch (Exception e) {
                out.print("{\"ok\":false}");
            }
            return;
        }

        /* ---------------------------------------------------------------------
           ATUALIZAR NOTA
        --------------------------------------------------------------------- */
        if ("updateNota".equals(action) || "edit".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                String nota = request.getParameter("nota");

                if (nota == null || nota.trim().isEmpty())
                    nota = "Sem anotação";

                boolean ok = dao.atualizarNota(id, idUsuario, nota);
                out.print("{\"ok\":" + ok + "}");

            } catch (Exception e) {
                out.print("{\"ok\":false}");
            }
            return;
        }

        /* ---------------------------------------------------------------------
           EXCLUIR ÚNICO
        --------------------------------------------------------------------- */
        if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean ok = dao.excluir(id, idUsuario);
                out.print("{\"ok\":" + ok + "}");

            } catch (Exception e) {
                out.print("{\"ok\":false}");
            }
            return;
        }

        /* ---------------------------------------------------------------------
           EXCLUIR VÁRIOS
        --------------------------------------------------------------------- */
        if ("deleteMany".equals(action)) {
            try {
                String idsStr = request.getParameter("ids");
                String[] parts = idsStr.split(",");

                List<Integer> lista = new ArrayList<>();

                for (String p : parts) {
                    try {
                        lista.add(Integer.parseInt(p.trim()));
                    } catch (Exception ignored) {}
                }

                boolean ok = dao.excluirVarios(lista, idUsuario);
                out.print("{\"ok\":" + ok + "}");

            } catch (Exception e) {
                out.print("{\"ok\":false}");
            }
        }
    }
}
