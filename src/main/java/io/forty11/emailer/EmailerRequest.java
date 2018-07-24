package io.forty11.emailer;

public class EmailerRequest
{
   String dbDriver   = null;
   String dbUrl      = null;
   String dbUsername = null;
   String dbPassword = null;

   public String getDbDriver()
   {
      return dbDriver != null ? dbDriver : System.getenv("JDBC_DRIVER");
   }

   public void setDbDriver(String dbDriver)
   {
      this.dbDriver = dbDriver;
   }

   public String getDbUrl()
   {
      return dbUrl != null ? dbUrl : System.getenv("JDBC_URL");
   }

   public void setDbUrl(String dbUrl)
   {
      this.dbUrl = dbUrl;
   }

   public String getDbUsername()
   {
      return dbUsername != null ? dbUsername : System.getenv("JDBC_USERNAME");
   }

   public void setDbUsername(String dbUsername)
   {
      this.dbUsername = dbUsername;
   }

   public String getDbPassword()
   {
      return dbPassword != null ? dbPassword : System.getenv("JDBC_PASSWORD");
   }

   public void setDbPassword(String dbPassword)
   {
      this.dbPassword = dbPassword;
   }

}
