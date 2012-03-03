<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: DbCopyWizard.jsp,v 1.6 2011/11/28 14:18:20 wfro Exp $
 * Description: DbCopywizard
 * Revision:    $Revision: 1.6 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/11/28 14:18:20 $
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
<%!
	static class CopyThread extends Thread {
	
		public CopyThread(
			String runningUser,
			String usernameSource,
			String passwordSource,
			String jdbcUrlSource,
			String usernameTarget,
			String passwordTarget,
			String jdbcUrlTarget,
			String kernelStartFromDbObject,
			String kernelEndWithDbObject,
			String securityStartFromDbObject,
			String securityEndWithDbObject,
			String providerNameSource,
			String providerNameTarget				
		) {
			super(runningUser + "@CopyThread");
			this.usernameSource = usernameSource; 
			this.passwordSource = passwordSource;
			this.jdbcUrlSource = jdbcUrlSource;
			this.usernameTarget = usernameTarget;
			this.passwordTarget = passwordTarget;
			this.jdbcUrlTarget = jdbcUrlTarget;
			this.kernelStartFromDbObject = kernelStartFromDbObject;
			this.kernelEndWithDbObject = kernelEndWithDbObject;
			this.securityStartFromDbObject = securityStartFromDbObject;
			this.securityEndWithDbObject = securityEndWithDbObject;
			this.providerNameSource = providerNameSource;
			this.providerNameTarget = providerNameTarget;
			this.reportBos = new ByteArrayOutputStream();
			this.report = new PrintStream(reportBos);			
		}
	
		public void run(
		) {
			try {
				org.opencrx.kernel.tools.CopyDb.copyDb(
					org.opencrx.kernel.utils.DbSchemaUtils.getJdbcDriverName(this.jdbcUrlSource),
					this.usernameSource,
					this.passwordSource,
					this.jdbcUrlSource,
					org.opencrx.kernel.utils.DbSchemaUtils.getJdbcDriverName(this.jdbcUrlTarget),
					this.usernameTarget,
					this.passwordTarget,
					this.jdbcUrlTarget,
					this.kernelStartFromDbObject,
					this.kernelEndWithDbObject,
					this.securityStartFromDbObject,
					this.securityEndWithDbObject,
					this.providerNameSource,
					this.providerNameTarget,
					report
				);
			} catch(Exception e) {
				ServiceException e0 = new ServiceException(e);
				e0.printStackTrace(this.report);
			}
		}
		
		public String getReport(
		) {
			try {
				return this.reportBos.toString("UTF-8");
			} catch(Exception e) {
				return this.reportBos.toString();
			}
		}
		
		private final String usernameSource;
		private final String passwordSource;
		private final String jdbcUrlSource;
		private final String usernameTarget;
		private final String passwordTarget;
		private final String jdbcUrlTarget;
		private final String kernelStartFromDbObject;
		private final String kernelEndWithDbObject;
		private final String securityStartFromDbObject;
		private final String securityEndWithDbObject;
		private final String providerNameSource;
		private final String providerNameTarget;			
		private final ByteArrayOutputStream reportBos;
		private final PrintStream report;
	}

%>
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
	String formName = "DbCopyForm";
	String wizardName = "DbCopyWizard.jsp";

	// Get Parameters
	String command = request.getParameter("Command");
	if(command == null) command = "";
	boolean actionCopy = "Copy".equals(command);
	boolean actionCancel = "Cancel".equals(command);
	boolean actionClear = "Clear".equals(command);
	String jdbcUrlSource = request.getParameter("jdbcUrlSource");
	String usernameSource = request.getParameter("usernameSource");
	String passwordSource = request.getParameter("passwordSource");
	String jdbcUrlTarget = request.getParameter("jdbcUrlTarget");
	String usernameTarget = request.getParameter("usernameTarget");
	String passwordTarget = request.getParameter("passwordTarget");
	String kernelStartFromDbObject = request.getParameter("kernelStartFromDbObject");
	String kernelEndWithDbObject = request.getParameter("kernelEndWithDbObject");
	String securityStartFromDbObject = request.getParameter("securityStartFromDbObject");
	String securityEndWithDbObject = request.getParameter("securityEndWithDbObject");
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
	<meta name="label" content="Database Copy wizard">
	<meta name="toolTip" content="Database Copy wizard">
	<meta name="targetType" content="_inplace">
	<meta name="forClass" content="org:opencrx:kernel:admin1:Segment">
	<meta name="order" content="9999">
-->
<%
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
	String currentPrincipal = app.getLoginPrincipal();
	CopyThread copyThread = (CopyThread)session.getAttribute(org.opencrx.kernel.tools.CopyDb.class.getName());
	// In case of a logoff try to lookup copy thread in list of active threads
	if(copyThread == null) {
		Thread[] runningThreads = new Thread[Thread.activeCount()];
		Thread.enumerate(runningThreads);
		copyThread = null;
		for(Thread thread: runningThreads) {
			if(thread instanceof CopyThread && thread.getName().equals(currentPrincipal + "@CopyThread")) {
				copyThread = (CopyThread)thread;
				session.setAttribute(
					org.opencrx.kernel.tools.CopyDb.class.getName(), 
					copyThread
				);	
				break;
			}
		}
	}
	// actionClear
	if(actionClear && copyThread != null && !copyThread.isAlive()) {
		session.removeAttribute(
			org.opencrx.kernel.tools.CopyDb.class.getName() 
		);
	}
	// actionCopy
	if(copyThread == null && actionCopy) {
		copyThread = new CopyThread(
			currentPrincipal,
			usernameSource,
			passwordSource,
			jdbcUrlSource,
			usernameTarget,
			passwordTarget,
			jdbcUrlTarget,
			kernelStartFromDbObject,
			kernelEndWithDbObject,
			securityStartFromDbObject,
			securityEndWithDbObject,
			obj.refGetPath().get(2),
			obj.refGetPath().get(2)
		);
		session.setAttribute(
			org.opencrx.kernel.tools.CopyDb.class.getName(), 
			copyThread
		);	
		copyThread.start();
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
					<h1>openCRX copy database wizard</h1>
				</div>
				<div id="contentArea">
<%
					// Read to launch new copy thread
					if(copyThread == null) {
%>
						<h1>WARNING: all data in the TARGET database will be LOST.</h1>										
						<table>
							<tr>
								<td colspan="2">
									<h1>Source database:</h1>
								</td>
							</tr>
							<tr>
								<td>URL:</td>
								<td>
									<input type="text" name="jdbcUrlSource" id="connectionUrl" tabIndex="9000" style="width:50em;" value="<%= jdbcUrlSource == null ? "" : jdbcUrlSource %>" />
<pre>Examples:
* jdbc:postgresql://127.0.0.1/CRX
* jdbc:mysql://127.0.0.1/CRX
* jdbc:hsqldb:hsql://127.0.0.1/CRX
* jdbc:db2://127.0.0.1:50000/CRX
* jdbc:oracle:thin:@127.0.0.1:1521:XE
* jdbc:sqlserver://127.0.0.1:1433;databaseName=CRX;selectMethod=cursor</pre>
								</td>
							</tr>
							<tr>
								<td>User:</td>
								<td><input type="text" name="usernameSource" id="usernameSource" tabIndex="9001" style="width:20em;" value="<%= usernameSource == null ? "" : usernameSource %>" /></td>
							</tr>
							<tr>
								<td>Password:</td>
								<td><input type="password" name="passwordSource" id="passwordSource" tabIndex="9002" style="width:20em;" value="<%= passwordSource == null ? "" : passwordSource %>" /></td>
							</tr>
							<tr>
								<td colspan="2">
									<h1>Target database:</h1>
								</td>
							</tr>
							<tr>
								<td>URL:</td>
								<td><input type="text" name="jdbcUrlTarget" id="jdbcUrlTarget" tabIndex="9010" style="width:50em;" value="<%= jdbcUrlTarget == null ? "" : jdbcUrlTarget %>" /></td>
							</tr>
							<tr>						
								<td>User:</td>
								<td><input type="text" name="usernameTarget" id="usernameTarget" tabIndex="9011" style="width:20em;" value="<%= usernameTarget == null ? "" : usernameTarget %>" /></td>
							</tr>
							<tr>
								<td>Password:</td>
								<td><input type="password" name="passwordTarget" id="passwordTarget" tabIndex="9012" style="width:20em;" value="<%= passwordTarget == null ? "" : passwordTarget %>" /></td>
							</tr>
							<tr>
								<td colspan="2">
									<h1>Options:</h1>
								</td>
							</tr>
							<tr>
								<td>Start from (OOCKE1) [Default=0]:</td>
								<td><input type="text" name="kernelStartFromDbObject" id="kernelStartFromDbObject" tabIndex="9020" style="width:5em;" value="<%= kernelStartFromDbObject == null ? "" : kernelStartFromDbObject %>" /></td>
							</tr>
							<tr>
								<td>End with (OOCKE1) [Default=9999]:</td>
								<td><input type="text" name="kernelEndWithDbObject" id="kernelEndWithDbObject" tabIndex="9021" style="width:5em;" value="<%= kernelEndWithDbObject == null ? "" : kernelEndWithDbObject %>" /></td>
							</tr>
							<tr>
								<td>Start from (OOMSE2) [Default=0]:</td>
								<td><input type="text" name="securityStartFromDbObject" id="securityStartFromDbObject" tabIndex="9022" style="width:5em;" value="<%= securityStartFromDbObject == null ? "" : securityStartFromDbObject %>" /></td>
							</tr>
							<tr>
								<td>End with (OOMSE2) [Default=9999]:</td>
								<td><input type="text" name="securityEndWithDbObject" id="securityEndWithDbObject" tabIndex="9023" style="width:5em;" value="<%= securityEndWithDbObject == null ? "" : securityEndWithDbObject %>" /></td>
							</tr>
						</table>
						<input type="submit" class="abutton" name="Copy" id="Copy.Button" tabindex="9030" value="Copy" onclick="$('Command').value=this.name;" />
						<input type="submit" class="abutton" name="Cancel" tabindex="9031" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Command').value=this.name;" />
<%
					}
					// Copy is running
					else {						
%>
						Copy is running. Refresh to see log output ...
						<pre>
<%= copyThread.getReport() %></pre>
						<input type="submit" class="abutton" name="Refresh" id="Refresh.Button" tabindex="9030" value="Refresh" onclick="$('Command').value=this.name;" />
<%
						if(!copyThread.isAlive()) {
%>						
							<input type="submit" class="abutton" name="Clear" id="Clear.Button" tabindex="9030" value="Clear" onclick="$('Command').value=this.name;" />
<%
						}
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
