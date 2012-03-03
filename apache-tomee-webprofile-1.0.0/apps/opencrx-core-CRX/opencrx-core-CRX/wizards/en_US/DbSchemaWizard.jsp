<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: DbSchemaWizard.jsp,v 1.7 2011/11/28 23:03:08 wfro Exp $
 * Description: DbSchemaWizard
 * Revision:    $Revision: 1.7 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/11/28 23:03:08 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2011, CRIXP Corp., Switzerland
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in
 * the documentation and/or other materials provided with the
 * distribution.
 *
 * * Neither the name of CRIXP Corp. nor the names of the contributors
 * to openCRX may be used to endorse or promote products derived
 * from this software without specific prior written permission
 *
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * ------------------
 *
 * This product includes software developed by the Apache Software
 * Foundation (http://www.apache.org/).
 *
 * This product includes software developed by contributors to
 * openMDX (http://www.openmdx.org/)
 */
%>
<%@ page session="true" import="
java.util.*,
java.io.*,
java.net.*,
java.math.*,
java.sql.*,
java.text.*,
javax.net.ssl.*,
javax.naming.Context,
javax.naming.InitialContext,
javax.xml.transform.stream.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.base.exception.*,
org.openmdx.kernel.id.cci.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*,
org.openmdx.kernel.log.*,
org.openmdx.kernel.id.*,
org.openmdx.kernel.exception.*,
org.openmdx.base.text.conversion.*,
org.opencrx.kernel.backend.*,
org.opencrx.application.airsync.utils.*,
org.opencrx.application.airsync.datatypes.*
"%>
<%
	request.setCharacterEncoding("UTF-8");
	String servletPath = "." + request.getServletPath();
	String servletPathPrefix = servletPath.substring(0, servletPath.lastIndexOf("/") + 1);
	ApplicationContext app = (ApplicationContext)session.getValue(WebKeys.APPLICATION_KEY);
	ViewsCache viewsCache = (ViewsCache)session.getValue(WebKeys.VIEW_CACHE_KEY_SHOW);
	String requestId =  request.getParameter(Action.PARAMETER_REQUEST_ID);
	String objectXri = request.getParameter(Action.PARAMETER_OBJECTXRI);
	if(objectXri == null || app == null || viewsCache.getView(requestId) == null) {
		response.sendRedirect(
			request.getContextPath() + "/" + WebKeys.SERVLET_NAME
		);
		return;
	}
	javax.jdo.PersistenceManager pm = app.getNewPmData();
	RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
	Texts_1_0 texts = app.getTexts();
	Codes codes = app.getCodes();
	String formName = "DbSchemaForm";
	String wizardName = "DbSchemaWizard.jsp";

	// Get Parameters
	String command = request.getParameter("Command");
	if(command == null) command = "";
	boolean actionValidate = "Validate".equals(command);
	boolean actionValidateAndFix = "ValidateAndFix".equals(command);
	boolean actionCancel = "Cancel".equals(command);
	String connectionUrl = request.getParameter("connectionUrl");
	String userName = request.getParameter("userName");
	String password = request.getParameter("password");
	
	if(actionCancel) {
	  session.setAttribute(wizardName, null);
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}
%>
<!--
	<meta name="label" content="Database schema wizard">
	<meta name="toolTip" content="Database schema wizard">
	<meta name="targetType" content="_inplace">
	<meta name="forClass" content="org:opencrx:kernel:admin1:Segment">
	<meta name="order" content="9999">
-->
<%
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
	List<String> report = new ArrayList<String>();
	// HSQLDB always required for reading reference schema
	Class.forName(
		org.opencrx.kernel.utils.DbSchemaUtils.getJdbcDriverName("jdbc:hsqldb:")
	);
	if(actionValidate || actionValidateAndFix) {
		// Get connection to running db
		Connection connT = null;
		try {
			if(connectionUrl != null && connectionUrl.startsWith("java:")) {
				Context initialContext = new InitialContext();
				javax.sql.DataSource dsT = (javax.sql.DataSource)initialContext.lookup(connectionUrl);
				connT = dsT.getConnection();
			} else {
				try {
					String driverName = org.opencrx.kernel.utils.DbSchemaUtils.getJdbcDriverName(connectionUrl);
					Class.forName(driverName);
				} catch (Exception e) {
					report.add("ERROR: Unable to load database driver (message=" + e.getMessage() + ")");					
				}
				connT = DriverManager.getConnection(connectionUrl, userName, password);				
			}
		} catch(Exception e) {
			report.add("ERROR: unable to get connection to database (message=" + e.getMessage() + ")");
		}
		if(connT != null) {
			String databaseProductName = connT.getMetaData().getDatabaseProductName();
			// Validate
			report.addAll(
				org.opencrx.kernel.utils.DbSchemaUtils.validateTables(
					connT,
					actionValidateAndFix
				)
			);
			report.addAll(
				org.opencrx.kernel.utils.DbSchemaUtils.validateTableColumns(
					connT,
					actionValidateAndFix
				)
			);
			report.addAll(
				org.opencrx.kernel.utils.DbSchemaUtils.migrateData(
					connT,
					true // migrate by default
				)
			);
			report.addAll(
				org.opencrx.kernel.utils.DbSchemaUtils.validateViews(
					connT,
					actionValidateAndFix
				)
			);
			report.addAll(
				org.opencrx.kernel.utils.DbSchemaUtils.validateIndexes(
					connT,
					actionValidateAndFix
				)
			);
			report.addAll(
				org.opencrx.kernel.utils.DbSchemaUtils.validateSequences(
					connT,
					actionValidateAndFix
				)
			);
		}
	}
%>
<br />
<form id="<%= formName %>" name="<%= formName %>" accept-charset="UTF-8" method="POST" action="<%= servletPath %>">
	<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
	<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
	<input type="hidden" id="Command" name="Command" value="" />
	<table cellspacing="8" class="tableLayout">
		<tr>
			<td class="cellObject">
				<div>
					<h1>openCRX database validation and upgrade wizard</h1>
					The wizard does NOT drop or remove any tables, columns and rows.
				</div>
				<br />
				<div id="waitArea" style="display:none;">
					Validating schema. Please wait...
				</div>
				<div id="contentArea">
					<table>
						<tr>
							<td>Connection URL:</td>
							<td>
								<input type="text" name="connectionUrl" id="connectionUrl" tabIndex="9000" style="width:50em;" value="<%= connectionUrl == null ? "java:comp/env/jdbc_opencrx_" + providerName : connectionUrl %>" />
<pre>Examples:
* java:comp/env/jdbc_opencrx_CRX
* jdbc:postgresql://127.0.0.1/CRX
* jdbc:mysql://127.0.0.1/CRX
* jdbc:hsqldb:hsql://127.0.0.1/CRX
* jdbc:db2://127.0.0.1:50000/CRX
* jdbc:oracle:thin:@127.0.0.1:1521:XE
* jdbc:sqlserver://127.0.0.1:1433;databaseName=CRX;selectMethod=cursor</pre>
							</td>
						</tr>
						<tr>	
							<td>User (for jdbc: URLs only):</td>
							<td><input type="text" name="userName" id="userName" tabIndex="9001" style="width:20em;" value="<%= userName == null ? "" : userName %>" /></td>
						</tr>
						<tr>
							<td>Password (for jdbc: URLs only):</td>
							<td><input type="password" name="password" id="password" tabIndex="9002" style="width:20em;" value="<%= password == null ? "" : password %>" /></td>
						</tr>
					</table>
					<input type="submit" class="abutton" name="Validate" id="Validate.Button" tabindex="9010" value="Validate" onclick="javascript:$('contentArea').style.display='none';$('waitArea').style.display='block';$('Command').value=this.name;" />
					<input type="submit" class="abutton" name="ValidateAndFix" id="ValidateAndFix.Button" tabindex="9020" value="Validate & Fix" onclick="javascript:$('contentArea').style.display='none';$('waitArea').style.display='block';$('Command').value=this.name;" />
					<input type="submit" class="abutton" name="Cancel" tabindex="9030" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Command').value=this.name;" />
<%
				if(!report.isEmpty()) {
%>				
					<pre>Report + <%= new java.util.Date() %>:</pre>
					<table>
<%
					int n = 0;
					for(String reportLine: report) {
%>
						<tr>
							<td style="text-align:center;background-color:<%= reportLine.startsWith("OK") ? "lightgreen;" : reportLine.startsWith("ERROR") ? "red;" : "yellow;" %>"><%= n %></td>
							<td><pre style="display:inline"><%= reportLine %></pre></td>
						</tr>
<%						
						n++;
					}
%>
					</table>
<%
				}
%>
				</div>				
			</td>
		</tr>
	</table>
</form>
<script language="javascript" type="text/javascript">
	Event.observe('<%= formName %>', 'submit', function(event) {
		$('<%= formName %>').request({
			onFailure: function() { },
			onSuccess: function(t) {
				$('UserDialog').update(t.responseText);
			}
		});
		Event.stop(event);
	});
</script>
<%
if(pm != null) {
	pm.close();
}
%>
