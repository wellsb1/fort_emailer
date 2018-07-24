package io.forty11.emailer;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import io.forty11.j.J;

public class EmailerLambdaHandler implements RequestHandler<EmailerRequest, EmailerResponse>
{

   @Override
   public EmailerResponse handleRequest(EmailerRequest req, Context context)
   {
      EmailerResponse res = new EmailerResponse();
      try
      {
         Emailer e = new Emailer();
         e.sendMessages(req);
      }
      catch (Exception ex)
      {
         ex.printStackTrace();
         res.error = J.getShortCause(ex);
      }
      return res;
   }

}