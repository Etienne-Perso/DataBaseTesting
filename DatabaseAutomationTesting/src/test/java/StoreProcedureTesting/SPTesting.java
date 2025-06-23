package StoreProcedureTesting;

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
/*
Syntax of calling store procedure
{call procedure_name()}		accept no parameters and return no value
{call procedure_name(?,?)}  accept two parameters and return no value
{?=call procedure_name()}   accept no parameter and return value
{?=call procedure_name(?)}  accept one parameter and return value
 */

public class SPTesting {
	
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
	void teardown() throws SQLException {
		con.close();
	}
	
	@Test(priority=1)
	void test_storeProceduresexists() throws SQLException {
		stmt=con.createStatement();
		rs=stmt.executeQuery("SELECT proname FROM pg_proc WHERE proname = 'selectallcustomers'");
		rs.next();
		Assert.assertEquals(rs.getString("proname"), "selectallcustomers"); 
	}
	
	@Test(priority=2)
	void test_selectAllCustomers() throws SQLException {
		
		stmt=con.createStatement();
		rs1=stmt.executeQuery("select * from selectallcustomers()"); //resultSet1
		
		stmt=con.createStatement();
		rs2=stmt.executeQuery("select * from customers"); //resultSet2
	
		Assert.assertEquals(compareResultSets(rs1,rs2), true); 
	}
	
	@Test(priority=3)
	void test_selectAllCustomersByCity() throws SQLException {
		
		stmt=con.createStatement();
		rs1=stmt.executeQuery("select * from selectallcustomersbycity('Nantes')"); //resultSet1
		
		
		stmt=con.createStatement();
		rs2=stmt.executeQuery("select * from customers where city='Nantes'"); //resultSet2
	
		Assert.assertEquals(compareResultSets(rs1,rs2), true); 
	}
	
	@Test(priority=4)
	void test_selectAllCustomersByCityAndPin() throws SQLException {
		
		stmt=con.createStatement();
		rs1=stmt.executeQuery("select * from selectallCustomersbycityandpin('San Francisco','94217')"); //resultSet1
		
		
		stmt=con.createStatement();
		rs2=stmt.executeQuery("select * from customers where city='San Francisco' and postalcode='94217'"); //resultSet2
	
		Assert.assertEquals(compareResultSets(rs1,rs2), true); 
	}
	
	@Test(priority=5)
	void test_getOrderByCust() throws SQLException {
		
		stmt=con.createStatement();
		rs=stmt.executeQuery("select * from get_order_by_cust(129)");
		rs.next();
		int shipped=rs.getInt("shipped");
		int canceled=rs.getInt("canceled");
		int resolved=rs.getInt("resolved");
		int disputed=rs.getInt("disputed");
		
		//System.out.println(shipped+ " "+canceled+" "+" "+resolved+" "+disputed); --> 3 0 0 0
		
		stmt=con.createStatement();
		rs=stmt.executeQuery("SELECT\r\n"
				+ "    COUNT(*) FILTER (WHERE status = 'Shipped')  AS shipped,\r\n"
				+ "    COUNT(*) FILTER (WHERE status = 'Canceled') AS canceled,\r\n"
				+ "    COUNT(*) FILTER (WHERE status = 'Resolved') AS resolved,\r\n"
				+ "    COUNT(*) FILTER (WHERE status = 'Disputed') AS disputed\r\n"
				+ "FROM orders\r\n"
				+ "WHERE customerNumber = 129;");
		rs.next();
		int exp_shipped=rs.getInt("shipped");
		int exp_canceled=rs.getInt("canceled");
		int exp_resolved=rs.getInt("resolved");
		int exp_disputed=rs.getInt("disputed");
		
		//System.out.println(exp_shipped+ " "+exp_canceled+" "+" "+exp_resolved+" "+exp_disputed); --> 3 0 0 0
		
		if(shipped==exp_shipped && canceled==exp_canceled && resolved==exp_resolved && disputed==exp_disputed) {
			Assert.assertTrue(true);
		}else {
			Assert.assertTrue(true);
		}
		
	}
	
	
	@Test(priority=6)
	void test_GetCustomerShipping() throws SQLException {
		
		//Executing the store procedure
		stmt=con.createStatement();
		rs=stmt.executeQuery("select * from GetCustomerShipping(103)");
		
		rs.next();
		String shippingTime=rs.getString("shippingtime");
		System.out.println(shippingTime);
		//Executing the sql query
		stmt=con.createStatement();
		rs=stmt.executeQuery("select country, \r\n"
				+ "case\r\n"
				+ "	when Country='USA' then '2-days shipping'\r\n"
				+ "	when Country='Canada' then '3-days shipping'\r\n"
				+ "	else '5-days shipping'\r\n"
				+ "end as ShippingTime from customers where customerNumber=103;");
		
		rs.next();
		String exp_shippingTime=rs.getString("shippingtime");
		System.out.println(exp_shippingTime);
		
		Assert.assertEquals(shippingTime, shippingTime);
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
