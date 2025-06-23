package StoredFunctionTesting;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.apache.commons.lang3.StringUtils;
import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

public class SFTesting {
	
	Connection con=null;
	Statement stmt; 
	ResultSet rs;
	ResultSet rs1;
	ResultSet rs2;
	
	@BeforeClass
	void setup() throws SQLException {
		con=DriverManager.getConnection("jdbc:postgresql://localhost:5432/ClassicModels","postgres","admin");
	}
	
	@AfterClass
	void tearDown() throws SQLException {
		
		con.close();
	}
	
	//@Test(priority=1)
	void test_storedFunctionExists() throws SQLException {
		
		stmt=con.createStatement();
		rs=stmt.executeQuery("SELECT\r\n"
				+ "    n.nspname AS schema_name,\r\n"
				+ "    p.proname AS function_name,\r\n"
				+ "    pg_get_function_arguments(p.oid) AS arguments,\r\n"
				+ "    pg_get_function_result(p.oid) AS return_type,\r\n"
				+ "    l.lanname AS language,\r\n"
				+ "    p.prokind AS kind  -- 'f' = function, 'p' = procedure\r\n"
				+ "FROM \r\n"
				+ "    pg_proc p\r\n"
				+ "JOIN \r\n"
				+ "    pg_namespace n ON n.oid = p.pronamespace\r\n"
				+ "JOIN\r\n"
				+ "    pg_language l ON l.oid = p.prolang\r\n"
				+ "WHERE \r\n"
				+ "    p.prokind = 'f'\r\n"
				+ "    AND p.proname = 'customerlevel'");
		
		rs.next();
		String functionName=rs.getString("function_name");
		//System.out.println(functionName);
		
		Assert.assertEquals(functionName, "customerlevel");
	}
	
	
	@Test(priority=2)
	void test_customerLevel_with_SQLStament() throws SQLException {
		stmt=con.createStatement();
		rs1=stmt.executeQuery("select customername, customerlevel(creditLimit) from customers");
		
		stmt=con.createStatement();
		rs2=stmt.executeQuery("select customername,                      \r\n"
				+ "case                                                                                             \r\n"
				+ "	when creditLimit>50000 then\r\n"
				+ "'PlATINUM'\r\n"
				+ "	when (creditLimit>=10000 and creditLimit<=50000)then\r\n"
				+ "'GOLD'\r\n"
				+ "	when creditLimit < 10000 then\r\n"
				+ "'SILVER'                                                                                           \r\n"
				+ "end as customerlevel from customers;");
	
		Assert.assertEquals(compareResultSets(rs1,rs2), true);
	}
	
	
	public boolean compareResultSets(ResultSet resultSet1, ResultSet resultSet2) throws SQLException {
		while (resultSet1.next())
		{
			
			resultSet2.next();
			int count=resultSet1.getMetaData().getColumnCount();
			for (int i=1; i<=count;i++) {
				if (!StringUtils.equals(resultSet1.getString(i),resultSet2.getString(i) )) {
					return false;
				}
			}
		}
		return true;
	}
	
	
	

}
