<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: ActivityProcessImportWizard.jsp,v 1.4 2011/07/06 15:24:45 wfro Exp $
 * Description: ActivityProcessImportWizard
 * Revision:    $Revision: 1.4 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/07/06 15:24:45 $
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
	String formName = "ActivityProcessImportForm";
	String wizardName = "ActivityProcessImportWizard.jsp";

	// Get Parameters
	String command = request.getParameter("Command");
	if(command == null) command = "";
	boolean actionCreate = "OK".equals(command);
	boolean actionCancel = "Cancel".equals(command);

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
	<meta name="label" content="State Chart XML - Import Activity Process">
	<meta name="toolTip" content="State Chart XML - Import Activity Process">
	<meta name="targetType" content="_inplace">
	<meta name="forClass" content="org:opencrx:kernel:activity1:Segment">
	<meta name="order" content="9999">
-->
<%
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
	org.opencrx.kernel.activity1.jmi1.Segment activitySegment = org.opencrx.kernel.backend.Activities.getInstance().getActivitySegment(
		pm,
		providerName,
		segmentName
	);
	org.openmdx.ui1.jmi1.FormDefinition formDefinition = app.getUiFormDefinition(formName);
	org.openmdx.portal.servlet.control.FormControl form = new org.openmdx.portal.servlet.control.FormControl(
		formDefinition.refGetPath().getBase(),
		app.getCurrentLocaleAsString(),
		app.getCurrentLocaleAsIndex(),
		app.getUiContext(),
		formDefinition
	);
	Map formValues = new HashMap();
	form.updateObject(
		request.getParameterMap(),
		formValues,
		app,
		pm
	);
	List<String> report = new ArrayList<String>();
	if(actionCreate) {
	    org.opencrx.kernel.document1.jmi1.Document document = 
	    	(org.opencrx.kernel.document1.jmi1.Document)pm.getObjectById(
	    		formValues.get("org:opencrx:kernel:generic:DocumentAttachment:document")
	    	);
	    if(document != null) {
	    	String contentType = document.getContentType();
	    	if(contentType != null && contentType.startsWith("text/")) {
	    		org.opencrx.kernel.document1.jmi1.DocumentRevision headRevision = document.getHeadRevision();
	    		if(headRevision instanceof org.opencrx.kernel.document1.jmi1.MediaContent) {
	    			org.opencrx.kernel.document1.jmi1.MediaContent mediaContent = (org.opencrx.kernel.document1.jmi1.MediaContent)headRevision;
	    			InputStream content = mediaContent.getContent().getContent();
    				pm.currentTransaction().begin();
    				org.opencrx.kernel.activity1.jmi1.ActivityProcess activityProcess = Activities.getInstance().importActivityProcessFromScXml(
   						activitySegment,
   						content,
   						report
   					);
    				if(report.isEmpty()) {
    					pm.currentTransaction().commit();
		    	    	if(activityProcess != null) {
			    		    Action nextAction = new ObjectReference(
			    		    	activityProcess,
			    		    	app
			    		   	).getSelectObjectAction();
			    			response.sendRedirect(
			    				request.getContextPath() + "/" + nextAction.getEncodedHRef()
			    			);
			    			return;
		    	    	}    					
    				} else {
    					try {
    						pm.currentTransaction().rollback();
    					} catch(Exception e1) {}
    				}
	    		}
	    	}
	    }
	}
	TransientObjectView view = new TransientObjectView(
		formValues,
		app,
		obj,
		pm
	);
	ViewPort p = ViewPortFactory.openPage(
		view,
		request,
		out
	);
%>
<br />
<form id="<%= formName %>" name="<%= formName %>" accept-charset="UTF-8" method="POST" action="<%= servletPath %>">
	<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
	<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
	<input type="hidden" id="Command" name="Command" value="" />
	<table cellspacing="8" class="tableLayout">
		<tr>
			<td class="cellObject">
				<div class="panel" id="panel<%= formName %>" style="display: block">
<%
					form.paint(
						p,
						null, // frame
						true // forEditing
					);
					p.flush();
%>
				</div>
<%
				if(!report.isEmpty()) {
%>				
					<pre>
Report:<%
					int n = 0;
					for(String reportLine: report) {
%>
<%= n + ": " + reportLine %><%
						n++;
					}
%></pre>
<%
				}
%>
				<input type="submit" class="abutton" name="OK" id="OK.Button" tabindex="9000" value="Create" onclick="javascript:$('Command').value=this.name;" />
				<input  type="submit" class="abutton" name="Cancel" tabindex="9010" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Command').value=this.name;" />
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
p.close(false);
if(pm != null) {
	pm.close();
}
%>
