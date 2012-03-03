<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.openmdx.org/
 * Name:        $Id: ImportMantisProject.jsp,v 1.23 2011/12/12 10:31:18 cmu Exp $
 * Description: ImportMantisProject wizard
 * Revision:    $Revision: 1.23 $
 * Owner:       OMEX AG, Switzerland, http://www.omex.ch
 * Date:        $Date: 2011/12/12 10:31:18 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2004-2010, OMEX AG, Switzerland
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
" %><%
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
<html dir="<%= texts.getDir() %>">
<head>
  <title>openCRX - Import Mantis Project</title>
  <meta name="label" content="Import Mantis Project">
  <meta name="toolTip" content="Import Mantis Project">
  <meta name="targetType" content="_self">
  <meta name="forClass" content="org:opencrx:kernel:activity1:Segment">
  <meta name="order" content="200">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
  <link href="../../_style/colors.css" rel="stylesheet" type="text/css">
  <script language="javascript" type="text/javascript" src="../../javascript/guicontrol.js"></script>
  <link rel='shortcut icon' href='../../images/favicon.ico' />
</head>
<body>

<%
		try {

			// Get parameters
			String projectName = request.getParameter("projectName");
			String activityCreatorName = request.getParameter("activityCreatorName");
			String processTransitionName = request.getParameter("processTransitionName");
			String bugCategoryNames = request.getParameter("bugCategoryNames");
			String fileBaseDir = request.getParameter("fileBaseDir");
			String jdbcDriverClass = request.getParameter("jdbcDriverClass");
			String jdbcConnectionUrl = request.getParameter("jdbcConnectionUrl");
			String jdbcUser = request.getParameter("jdbcUser");
			String jdbcPassword = request.getParameter("jdbcPassword");
			List errors = new ArrayList();
			List report = new ArrayList();

			boolean actionOk = request.getParameter("OK.Button") != null;
			boolean actionCancel = request.getParameter("Cancel.Button") != null;

			if(actionCancel) {
				Action nextAction = new ObjectReference(
					(RefObject_1_0)pm.getObjectById(new Path(objectXri)),
					app
				).getSelectObjectAction();
				response.sendRedirect(
					request.getContextPath() + "/" + nextAction.getEncodedHRef()
				);
			}
			else if(
				actionOk &&
				 (projectName != null) &&
				(activityCreatorName != null) &&
				(processTransitionName != null) &&
				(bugCategoryNames != null) &&
				(fileBaseDir != null) &&
				(jdbcDriverClass != null) &&
				(jdbcConnectionUrl != null) &&
				(jdbcUser != null) &&
				(jdbcPassword != null)
			) {

				org.opencrx.application.mantis.ProjectImporter importer = null;
				try {
					importer =
						new org.opencrx.application.mantis.ProjectImporter(
							pm,
							jdbcDriverClass,
							jdbcConnectionUrl,
							jdbcUser,
							jdbcPassword
						);
				}
				catch(Exception e) {
					errors.add(
						"Error setting up importer: " + e.getMessage()
					);
				}
				if(errors.isEmpty()) {
					org.opencrx.kernel.activity1.jmi1.Segment activitySegment = (org.opencrx.kernel.activity1.jmi1.Segment)pm.getObjectById(new Path(objectXri));
					Path activitySegmentIdentity = new Path(activitySegment.refMofId());
					importer.importProjects(
						activitySegmentIdentity.get(2),
						activitySegmentIdentity.get(4),
						projectName,
						activityCreatorName,
						processTransitionName,
						bugCategoryNames,
						fileBaseDir,
						errors,
						report
					);
					importer.close();
				}
			}
			boolean invalidProjectName = actionOk && ((projectName == null) || (projectName.length() == 0));
			boolean invalidActivityCreatorName = actionOk && ((activityCreatorName == null) || (activityCreatorName.length() == 0));
			boolean invalidProcessTransitionName = actionOk && ((processTransitionName == null) || (processTransitionName.length() == 0));
			boolean invalidFileBaseDir = actionOk && ((fileBaseDir == null) || (fileBaseDir.length() == 0));
			boolean invalidJdbcDriverClass = actionOk && ((jdbcDriverClass == null) || (jdbcDriverClass.length() == 0));
			boolean invalidJdbcConnectionUrl = actionOk && ((jdbcConnectionUrl == null) || (jdbcConnectionUrl.length() == 0));
			boolean invalidJdbcUser = actionOk && ((jdbcUser == null) || (jdbcUser.length() == 0));
			boolean invalidJdbcPassword = actionOk && ((jdbcPassword == null) || (jdbcPassword.length() == 0));
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

<form name="ImportMantisProject" accept-charset="UTF-8" method="POST" action="ImportMantisProject.jsp">
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
        Import Mantis Project
      </div>

      <div class="panel" id="panelObj0" style="display: block">
		  <div class="fieldGroupName">Mantis</div>
	      <table class="fieldGroup">
	        <tr>
				<td class="label"><span class="nw">Mantis project name <font color="red">*</font></span></td>
				<td>
					<input type="text" class="valueL" name="projectName" maxlength="50" tabindex="100" value="<%= projectName == null ? "" : projectName %>" />
				</td>
				<td class="addon">
					<font color="red"><%= invalidProjectName ? "!" : "" %></font>
				</td>
				<td class="label"><span class="nw"></span></td>
				<td></td>
				<td class="addon"></td>
	        </tr>
	        <tr>
				<td class="label"><span class="nw">Bug category names</span></td>
				<td>
					<input type="text" class="valueL" name="bugCategoryNames" maxlength="50" tabindex="100" value="<%= bugCategoryNames == null ? "" : bugCategoryNames %>" />
				</td>
				<td class="addon"></td>
				<td class="label"><span class="nw"></span></td>
				<td></td>
				<td class="addon"></td>
	        </tr>
	        <tr>
				<td class="label"><span class="nw">File upload base dir <font color="red">*</font></span></td>
				<td>
					<input type="text" class="valueL" name="fileBaseDir" maxlength="50" tabindex="100" value="<%= fileBaseDir == null ? "" : fileBaseDir %>" />
				</td>
				<td class="addon">
					<font color="red"><%= invalidFileBaseDir ? "!" : "" %></font>
				</td>
				<td class="label"><span class="nw"></span></td>
				<td></td>
				<td class="addon"></td>
	        </tr>
	        <tr>
				<td class="label"><span class="nw">Jdbc driver class <font color="red">*</font></span></td>
				<td>
					<input type="text" class="valueL" name="jdbcDriverClass" maxlength="50" tabindex="100" value="<%= jdbcDriverClass == null ? "" : jdbcDriverClass %>" />
				</td>
				<td class="addon">
					<font color="red"><%= invalidJdbcDriverClass ? "!" : "" %></font>
				</td>
				<td class="label"><span class="nw"></span></td>
				<td></td>
				<td class="addon"></td>
	        </tr>
	        <tr>
				<td class="label"><span class="nw">Jdbc connection URL <font color="red">*</font></span></td>
				<td>
					<input type="text" class="valueL" name="jdbcConnectionUrl" maxlength="50" tabindex="100" value="<%= jdbcConnectionUrl == null ? "" : jdbcConnectionUrl %>" />
				</td>
				<td class="addon">
					<font color="red"><%= invalidJdbcConnectionUrl ? "!" : "" %></font>
				</td>
				<td class="label"><span class="nw"></span></td>
				<td></td>
				<td class="addon"></td>
	        </tr>
	        <tr>
				<td class="label"><span class="nw">Jdbc user <font color="red">*</font></span></td>
				<td>
					<input type="text" class="valueL" name="jdbcUser" maxlength="50" tabindex="100" value="<%= jdbcUser == null ? "" : jdbcUser %>" />
				</td>
				<td class="addon">
					<font color="red"><%= invalidJdbcUser ? "!" : "" %></font>
				</td>
				<td class="label"><span class="nw"></span></td>
				<td></td>
				<td class="addon"></td>
	        </tr>
	        <tr>
				<td class="label"><span class="nw">Jdbc password <font color="red">*</font></span></td>
				<td>
					<input type="text" class="valueL" name="jdbcPassword" maxlength="50" tabindex="100" value="<%= jdbcPassword == null ? "" : jdbcPassword %>" />
				</td>
				<td class="addon">
					<font color="red"><%= invalidJdbcPassword ? "!" : "" %></font>
				</td>
				<td class="label"><span class="nw"></span></td>
				<td></td>
				<td class="addon"></td>
	        </tr>
	      </table>
		  <div class="fieldGroupName">openCRX</div>
	      <table class="fieldGroup">
	        <tr>
				<td class="label"><span class="nw">Activity creator name <font color="red">*</font></span></td>
				<td>
					<input type="text" class="valueL" name="activityCreatorName" maxlength="50" tabindex="100" value="<%= activityCreatorName == null ? "" : activityCreatorName  %>" />
				</td>
				<td class="addon">
					<font color="red"><%= invalidActivityCreatorName ? "!" : "" %></font>
				</td>
				<td class="label"><span class="nw"></span></td>
				<td></td>
				<td class="addon"></td>
	        </tr>
	        <tr>
				<td class="label"><span class="nw">Process transition name <font color="red">*</font></span></td>
				<td>
					<input type="text" class="valueL" name="processTransitionName" maxlength="50" tabindex="100" value="<%= processTransitionName == null ? "" : processTransitionName %>" />
				</td>
				<td class="addon">
					<font color="red"><%= invalidProcessTransitionName ? "!" : "" %></font>
				</td>
				<td class="label"><span class="nw"></span></td>
				<td></td>
				<td class="addon"></td>
	        </tr>
		</table>
		<div class="fieldGroupName">&nbsp;</div>
		<table>
	        <tr>
				<td class="label"><span class="nw">Errors</span></td>
				<td>
					<%= errors%>
				</td>
				<td class="addon"></td>
				<td class="label"><span class="nw"></span></td>
				<td></td>
				<td class="addon"></td>
	        </tr>
	        <tr>
				<td class="label"><span class="nw">Report</span></td>
				<td>
					<%= report %>
				</td>
				<td class="addon"></td>
				<td class="label"><span class="nw"></span></td>
				<td></td>
				<td class="addon"></td>
	        </tr>
	    </table>
		<div class="fieldGroupName">&nbsp;</div>
	    <table>
	        <tr>
	          <td class="label">
	          	<INPUT type="Submit" name="OK.Button" tabindex="1000" value="Import" />
      			<INPUT type="Submit" name="Cancel.Button" tabindex="1010" value="<%= app.getTexts().getCancelTitle() %>" />
	          </td>
	          <td>&nbsp;</td>
	          <td class="addon"></td>
	          <td></td>
	          <td></td>
	          <td></td>
	        </tr>
	      </table>
      </div>
  	</td>
  </tr>
</table>
</form>
<%
    }
    catch (Exception ex) {
	    out.println("<p><b>!! Failed !!<br><br>The following exception occur:</b><br><br>");
	    ex.printStackTrace(new PrintWriter(out));
    } finally {
    	if(pm != null) {
    		pm.close();
    	}
    }
%>
      </div> <!-- content -->
    </div> <!-- content-wrap -->
  </div> <!-- wrap -->
</div> <!-- container -->
</body>
</html>
