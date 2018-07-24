package io.forty11.emailer;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import com.amazonaws.util.StringInputStream;

import io.forty11.j.J;
import io.forty11.sql.Rows;
import io.forty11.sql.Rows.Row;
import io.forty11.sql.Sql;

public class Emailer
{
   public static void main(String[] args) throws Exception
   {
      EmailerRequest req = new EmailerRequest();
      if (args != null && args.length >= 4)
      {
         req.dbDriver = args[0];
         req.dbUrl = args[1];
         req.dbUsername = args[2];
         req.dbPassword = args[3];
      }

      new Emailer().sendMessages(req);
   }

   public void sendMessages(EmailerRequest req) throws Exception
   {
      Class.forName(req.getDbDriver());
      Connection conn = DriverManager.getConnection(req.getDbUrl(), req.getDbUsername(), req.getDbPassword());

      String sql = J.read(getClass().getResourceAsStream("findMessages.sql"));

      for (Row message : Sql.selectRows(conn, sql))
      {
         try
         {
            //            sql = "";
            //            sql += " select m.* ";
            //            sql += " from Message m";
            //            sql += " join SequenceMessage sm on sm.messageId = m.id";
            //            sql += " where sm.sequenceId = ? and sm.order = ?";

            //            Row message = Sql.selectRow(conn, sql, toSend.get("sequenceId"), toSend.get("nextOrder"));

            //            if (message != null)
            //            {
            Rows recipients = Sql.selectRows(conn, "select * from ListAddress where listId = ? order by emailPersonal", message.get("listId"));

            if (!recipients.isEmpty())
            {
               Row sender = Sql.selectRow(conn, "select s.* from List l  join Sender s on l.senderId = s.id where l.id = ?", message.get("listId"));
               if (sender != null)
               {
                  sendMessage(sender, recipients, message);
                  if (message.get("nextOrder") != null && (float) message.get("nextOrder") > 0)
                  {
                     //if nextOrder is < 0 this message was selected because of a specifically associated date
                     Sql.execute(conn, "update ListSequence set lastDate = date(now()), lastOrder = ? where listId = ? and sequenceId = ?", message.get("nextOrder"), message.get("listId"), message.get("sequenceId"));
                  }
                  else
                  {
                     Sql.execute(conn, "update ListSequence set lastDate = date(now()) where listId = ? and sequenceId = ?", message.get("listId"), message.get("sequenceId"));
                  }
               }
            }
         }
         //         }
         catch (Exception ex)
         {
            ex.printStackTrace();
         }

         Thread.sleep(5000);
      }
   }

   void sendMessage(Row sender, Rows recipients, Row message) throws Exception
   {

      Properties props = new Properties();

      props.load(new StringInputStream(sender.getString("smtpProps")));

      String username = (String) props.remove("mail.smtp.username");
      String password = (String) props.remove("mail.smtp.password");

      Session session = Session.getInstance(props, new javax.mail.Authenticator()
         {
            protected PasswordAuthentication getPasswordAuthentication()
            {
               return new PasswordAuthentication(username, password);
            }
         });

      try
      {

         String prefix = message.getString("subjectPrefix");
         String subject = message.getString("subject");

         Message mime = new MimeMessage(session);

         mime.setFrom(new InternetAddress(sender.getString("fromAddress"), sender.getString("fromPersonal")));

         List to = new ArrayList();
         List cc = new ArrayList();
         List bcc = new ArrayList();

         for (Row recipient : recipients)
         {
            String email = recipient.getString("emailAddress");
            String personal = recipient.getString("emailPersonal");
            String type = recipient.getString("type");

            InternetAddress address = null;
            if (personal != null)
            {
               address = new InternetAddress(email, personal);
            }
            else
            {
               address = new InternetAddress(email);
            }

            if ("cc".equalsIgnoreCase(type))
            {
               cc.add(address);
            }
            else if ("bcc".equalsIgnoreCase(type))
            {
               bcc.add(address);
            }
            else
            {
               to.add(address);
            }

         }

         if (!to.isEmpty())
         {
            mime.setRecipients(Message.RecipientType.TO, (InternetAddress[]) to.toArray(new InternetAddress[to.size()]));
         }
         if (!cc.isEmpty())
         {
            mime.setRecipients(Message.RecipientType.CC, (InternetAddress[]) to.toArray(new InternetAddress[cc.size()]));
         }
         if (!bcc.isEmpty())
         {
            mime.setRecipients(Message.RecipientType.BCC, (InternetAddress[]) to.toArray(new InternetAddress[bcc.size()]));
         }

         if (prefix != null)
         {
            if (!prefix.endsWith(" "))
               prefix += " ";
            subject = prefix + subject;
         }

         System.out.println("Sending: " + subject);

         mime.setSubject(subject);
         mime.setContent(message.getString("body"), "text/html; charset=utf-8");

         Transport.send(mime);

      }
      catch (Exception e)
      {
         e.printStackTrace();
         throw new RuntimeException(e);
      }
   }

}
