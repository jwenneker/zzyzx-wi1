<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.openmdx.org/
 * Name:        $Id: LogConfiguration.jsp,v 1.11 2010/06/08 09:50:49 wfro Exp $
 * Description: ImportMantisProject wizard
 * Revision:    $Revision: 1.11 $
 * Owner:       OMEX AG, Switzerland, http://www.omex.ch
 * Date:        $Date: 2010/06/08 09:50:49 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2004-2009, OMEX AG, Switzerland
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or
 * without modification, are permitted provided that the following
 * conditions are met:
 *
 * * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in
 * the documentation and/or other materials provided with the
 * distribution.
 *
 * * Neither the name of the openMDX team nor the names of its
 * contributors may be used to endorse or promote products derived
 * from this software without specific prior written permission.
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
 * This product includes software developed by Mihai Bazon
 * (http://dynarch.com/mishoo/calendar.epl) published with an LGPL
 * license.
 */
%><%@ page session="true" import="
java.util.*,
java.io.*,
java.text.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*,
org.openmdx.kernel.log.*,
org.openmdx.uses.org.apache.commons.fileupload.*,
org.openmdx.kernel.id.*
" %>
<%
	request.setCharacterEncoding("UTF-8");
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
	Texts_1_0 texts = app.getTexts();
	javax.jdo.PersistenceManager pm = app.getNewPmData();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>Logging Configuration</title>
  <meta name="label" content="Logging Configuration">
  <meta name="toolTip" content="Logging Configuration">
  <meta name="targetType" content="_self">
  <meta name="forClass" content="org:opencrx:kernel:admin1:Segment">
  <meta name="order" content="110">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
  <link href="../../_style/colors.css" rel="stylesheet" type="text/css">
  <script language="javascript" type="text/javascript" src="../../javascript/prototype.js"></script>
  <link rel='shortcut icon' href='../../images/favicon.ico' />
</head>
<body>
<%
	boolean actionOk = request.getParameter("OK.Button") != null;
	boolean actionCancel = request.getParameter("Cancel.Button") != null;

	final int INDIVIDUAL = 9999;
	int levelALL_LOGGER = INDIVIDUAL;
	if (request.getParameter("levelALL_LOGGER") != null) {
		try {
			levelALL_LOGGER = Integer.parseInt(request.getParameter("levelALL_LOGGER"));
		} catch (Exception e) {}
	}

	if(actionCancel) {
		Action nextAction = new ObjectReference(
			(RefObject_1_0)pm.getObjectById(new Path(objectXri)),
			app
		).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
	}
	else if(actionOk) {
		java.util.logging.LogManager logManager = java.util.logging.LogManager.getLogManager();
		Enumeration<String> parameterNames = request.getParameterNames();
		while(parameterNames.hasMoreElements()) {
			String parameterName = parameterNames.nextElement();
			if(parameterName.startsWith("Logger.")) {
				String loggerName = parameterName.substring(7);
				java.util.logging.Level logLevel = java.util.logging.Level.parse(request.getParameter(parameterName));
				java.util.logging.Logger logger = logManager.getLogger(loggerName);
				if(logger != null) {
					logger.setLevel(logLevel);
					for(java.util.logging.Handler handler: logger.getHandlers()) {
						handler.setLevel(logLevel);
					}
				}
				// Set level for all loggers registered by openMDX logger factory
				if(org.openmdx.kernel.log.LoggerFactory.STANDARD_LOGGER_NAME.equals(loggerName)) {
					Collection<java.util.logging.Logger> loggers = org.openmdx.kernel.log.LoggerFactory.getLoggers();
					for(java.util.logging.Logger l: loggers) {
						l.setLevel(logLevel);
						for(java.util.logging.Handler handler: l.getHandlers()) {
							handler.setLevel(logLevel);
						}						
					}
				}
			}
		}
	}
	String jsBuffer = ";";

%>
<div id="container">
	<div id="wrap">
		<div id="header" style="height:90px;">
	      <div id="logoTable">
	        <table id="headerlayout">
	          <tr id="headRow">
	            <td id="head" colspan="2">
	              <table id="info">
	                <tr>
	                  <td id="headerCellLeft"><img id="logoLeft" src="../../images/logoLeft.gif" alt="openCRX" title="" /></td>
	                  <td id="headerCellSpacerLeft"></td>
	                  <td id="headerCellMiddle">&nbsp;</td>
	                  <td id="headerCellRight"><img id="logoRight" src="../../images/logoRight.gif" alt="" title="" /></td>
	                </tr>
	              </table>
	            </td>
	          </tr>
	        </table>
	      </div>
		</div>
	    <div id="content-wrap">
	    	<div id="content" style="padding:100px 0.5em 0px 0.5em;">
				<form name="LogConfiguration" accept-charset="UTF-8" method="POST" action="LogConfiguration.jsp">
					<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
					<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
					<table cellspacing="8" class="tableLayout">
					  <tr>
					    <td class="cellObject">
					      <noscript>
					        <div class="panelJSWarning" style="display: block;">
					          <a href="../../helpJsCookie.html" target="_blank"><img class="popUpButton" src="../../images/help.gif" width="16" height="16" border="0" onclick="javascript:void(window.open('helpJsCookie.html', 'Help', 'fullscreen=no,toolbar=no,status=no,menubar=no,scrollbars=yes,resizable=yes,directories=no,location=no,width=400'));" alt="" /></a> <%= texts.getPageRequiresScriptText() %>
					        </div>
					      </noscript>
					      <div id="etitle" style="height:20px;">
					        Logging Configuration
					      </div>
					      <div class="panel" id="panelObj0" style="display: block">
					        <table>
						        <tr>
						          <td class="label">
						          	<INPUT type="Submit" name="OK.Button"  id="OK.Button"tabindex="1000" value="<%= app.getTexts().getOkTitle() %>" />
					      				<INPUT type="Submit" name="Cancel.Button" id="Cancel.Button" tabindex="1010" value="<%= app.getTexts().getCancelTitle() %>" />
						          </td>
						          <td>&nbsp;</td>
						          <td class="addon"></td>
						        </tr>
						    </table>
							<div class="fieldGroupName">&nbsp;</div>
							<table>
								<tr>
									<td style="padding:5px 0px;background-color:#FFFED2;vertical-align:middle;"><strong>ALL LOGGERS</strong></td>
									<td width="120px;" style="padding:5px 0px;background-color:#FFFED2;vertical-align:middle;">
										<select name="levelALL_LOGGER" onchange="javascript:setLoggersTo(this.selectedIndex);$('OK.Button').click();">
											<option <%= levelALL_LOGGER == INDIVIDUAL ? "SELECTED" : "" %> value="<%= INDIVIDUAL %>">INDIVIDUAL SETTINGS</option>
											<option <%= levelALL_LOGGER == java.util.logging.Level.SEVERE.intValue()  ? "SELECTED" : "" %> value="<%= java.util.logging.Level.SEVERE.intValue()  %>">SEVERE</option>
											<option <%= levelALL_LOGGER == java.util.logging.Level.WARNING.intValue() ? "SELECTED" : "" %> value="<%= java.util.logging.Level.WARNING.intValue() %>">WARNING</option>
											<option <%= levelALL_LOGGER == java.util.logging.Level.INFO.intValue()    ? "SELECTED" : "" %> value="<%= java.util.logging.Level.INFO.intValue()    %>">INFO</option>
											<option <%= levelALL_LOGGER == java.util.logging.Level.FINE.intValue()    ? "SELECTED" : "" %> value="<%= java.util.logging.Level.FINE.intValue()    %>">FINE</option>
											<option <%= levelALL_LOGGER == java.util.logging.Level.FINER.intValue()   ? "SELECTED" : "" %> value="<%= java.util.logging.Level.FINER.intValue()   %>">FINER</option>
											<option <%= levelALL_LOGGER == java.util.logging.Level.FINEST.intValue()  ? "SELECTED" : "" %> value="<%= java.util.logging.Level.FINEST.intValue()  %>">FINEST</option>
										</select>
									</td>
						        </tr>
<%
								java.util.logging.LogManager logManager = java.util.logging.LogManager.getLogManager();
								Enumeration<String> loggerNames = logManager.getLoggerNames();
								Set<String> sortedLoggerNames = new TreeSet<String>();
								while(loggerNames.hasMoreElements()) {
									sortedLoggerNames.add(loggerNames.nextElement());
								}
								int ii = 0;
								for(String loggerName: sortedLoggerNames) {
									java.util.logging.Logger logger = logManager.getLogger(loggerName);
									if(logger != null) {
										jsBuffer += "$('Logger." + loggerName + "').selectedIndex = level-1;";
%>
										<tr>
											<td <%= ii % 2 == 0 ? "style='background-color:#E6FEE6;'" : "" %> style="vertical-align:middle;"><%= loggerName.length() == 0 ? "*" : loggerName %></td>
											<td <%= ii % 2 == 0 ? "style='background-color:#E6FEE6;'" : "" %> width="120px;">
												<select name="Logger.<%= loggerName %>" id="Logger.<%= loggerName %>" onchange="javascript:$('OK.Button').click();">
													<option <%= logger.getLevel() == java.util.logging.Level.SEVERE  ? "SELECTED" : "" %> value="<%= java.util.logging.Level.SEVERE.intValue()   %>">SEVERE</option>
													<option <%= logger.getLevel() == java.util.logging.Level.WARNING ? "SELECTED" : "" %> value="<%= java.util.logging.Level.WARNING.intValue()  %>">WARNING</option>
													<option <%= logger.getLevel() == java.util.logging.Level.INFO    ? "SELECTED" : "" %>>INFO</option>
													<option <%= logger.getLevel() == java.util.logging.Level.FINE    ? "SELECTED" : "" %>>FINE</option>
													<option <%= logger.getLevel() == java.util.logging.Level.FINER   ? "SELECTED" : "" %>>FINER</option>
													<option <%= logger.getLevel() == java.util.logging.Level.FINEST  ? "SELECTED" : "" %>>FINEST</option>
												</select>
											</td>
								        </tr>
<%
										ii++;
									}
								}
%>
							</table>
							<div class="fieldGroupName">&nbsp;</div>
						    <table>
						        <tr>
						          <td class="label">
						          	<INPUT type="Submit" name="OK2.Button" tabindex="1000" value="<%= app.getTexts().getOkTitle() %>" onclick="javascript:$('OK.Button').click();return false;" />
						      			<INPUT type="Submit" name="Cancel2.Button" tabindex="1010" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Cancel.Button').click();return false;" />
						          </td>
						          <td>&nbsp;</td>
						          <td class="addon"></td>
						        </tr>
						      </table>
					      </div>
					  	</td>
					  </tr>
					</table>
				</form>
			</div> <!-- content -->
	    </div> <!-- content-wrap -->
	</div> <!-- wrap -->
</div> <!-- container -->
	<script type="text/javascript">
		function setLoggersTo(level) {
			if (level > 0) {
				<%= jsBuffer %>;
			}
		}
	</script>
</body>
</html>
<%
if(pm != null) {
	pm.close();
}
%>
