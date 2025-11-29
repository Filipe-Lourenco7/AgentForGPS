package controller;

/* ============================================================================
 *  Servlet: CaptchaServlet
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Gerar código CAPTCHA aleatório.
 *      - Armazenar o valor na sessão do usuário.
 *      - Renderizar o CAPTCHA como imagem PNG.
 *
 *  Fluxo:
 *      1) Gerar string de 5 caracteres
 *      2) Salvar na sessão
 *      3) Criar imagem com ruído
 *      4) Escrever texto e enviar como PNG ao navegador
 * ============================================================================ */

import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.Random;

public class CaptchaServlet extends HttpServlet {

    // Dimensões do Captcha
    private static final int WIDTH = 150;
    private static final int HEIGHT = 50;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        /* ----------------------------------------------------------------------
         * 1) GERAR CÓDIGO CAPTCHA
         * ---------------------------------------------------------------------- */
        String chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // sem O/0, I/1 para evitar confusão
        Random rnd = new Random();

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 5; i++) {
            sb.append(chars.charAt(rnd.nextInt(chars.length())));
        }
        String captcha = sb.toString();

        /* ----------------------------------------------------------------------
         * 2) SALVAR CAPTCHA NA SESSÃO
         * ---------------------------------------------------------------------- */
        HttpSession session = req.getSession();
        session.setAttribute("captcha", captcha);

        /* ----------------------------------------------------------------------
         * 3) GERAR IMAGEM
         * ---------------------------------------------------------------------- */
        BufferedImage img = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = img.createGraphics();

        // fundo
        g.setColor(Color.WHITE);
        g.fillRect(0, 0, WIDTH, HEIGHT);

        // fonte
        g.setFont(new Font("Arial", Font.BOLD, 32));

        // ruído (linhas aleatórias)
        for (int i = 0; i < 15; i++) {
            g.setColor(new Color(
                    rnd.nextInt(256),
                    rnd.nextInt(256),
                    rnd.nextInt(256)
            ));
            int x1 = rnd.nextInt(WIDTH), y1 = rnd.nextInt(HEIGHT);
            int x2 = rnd.nextInt(WIDTH), y2 = rnd.nextInt(HEIGHT);
            g.drawLine(x1, y1, x2, y2);
        }

        // texto principal
        g.setColor(Color.BLACK);
        g.drawString(captcha, 20, 35);

        g.dispose();

        /* ----------------------------------------------------------------------
         * 4) RETORNAR IMAGEM PNG AO NAVEGADOR
         * ---------------------------------------------------------------------- */
        resp.setContentType("image/png");
        ImageIO.write(img, "png", resp.getOutputStream());
    }
}
