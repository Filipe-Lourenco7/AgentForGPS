package controller;

/* ============================================================================
 *  Classe utilitária: EmailSender
 *  Autores: Filipe & Caio
 *
 *  Função:
 *      - Envio de e-mails via SMTP (Gmail)
 *      - Usado no fluxo de recuperação de senha
 *
 *  Observação:
 *      - Requer App Password do Gmail (2FA ativado)
 *      - Apenas envio de HTML seguro
 * ============================================================================ */

import java.util.Properties;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class EmailSender {

    /* -------------------------------------------------------------------------
       CONFIGURAÇÃO PRINCIPAL DO E-MAIL
    ------------------------------------------------------------------------- */
    private static final String EMAIL_REMETENTE = "filipe.cavaleiro2018@gmail.com";
    private static final String SENHA_APP       = "awbikflklvzickug"; 
    // ↑ Senha de aplicativo (não é a senha normal do Gmail)

    /* -------------------------------------------------------------------------
       MÉTODO PRINCIPAL DE ENVIO
    ------------------------------------------------------------------------- */
    public static void enviarEmail(String destinatario, String assunto, String mensagemHtml) {

        /* ---------------------------------------------------------------------
           CONFIGURAÇÕES SMTP DO GMAIL
        --------------------------------------------------------------------- */
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");

        /* ---------------------------------------------------------------------
           AUTENTICAÇÃO
        --------------------------------------------------------------------- */
        Session session = Session.getInstance(props, new jakarta.mail.Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(EMAIL_REMETENTE, SENHA_APP);
            }
        });

        // Ativar logs do envio (útil somente para testes)
        session.setDebug(true);

        /* ---------------------------------------------------------------------
           CONSTRUÇÃO E ENVIO DO E-MAIL
        --------------------------------------------------------------------- */
        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(EMAIL_REMETENTE));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
            message.setSubject(assunto);

            // Template HTML base do sistema
            String corpoEmail = 
                "<html><body>"
                    + "<h2 style='color:#2563eb;'>GPS for Agents</h2>"
                    + "<p>Você solicitou a recuperação de senha.</p>"
                    + "<br>"
                    + mensagemHtml
                    + "<br><br>"
                    + "<small>Se você não solicitou isso, apenas ignore este e-mail.</small>"
                + "</body></html>";

            message.setContent(corpoEmail, "text/html; charset=UTF-8");

            Transport.send(message);

            System.out.println("📩 E-mail enviado com sucesso para: " + destinatario);

        } catch (MessagingException e) {
            e.printStackTrace();
            System.out.println("❌ Falha ao enviar e-mail.");
        }
    }
}
