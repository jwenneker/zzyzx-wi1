<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: CreateCampaignWizard.jsp,v 1.24 2011/10/06 21:13:24 wfro Exp $
 * Description: CreateCampaignWizard
 * Revision:    $Revision: 1.24 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/10/06 21:13:24 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2004-2011, CRIXP Corp., Switzerland
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
%><%@ page session="true" import="
java.util.*,
java.io.*,
java.text.*,
org.opencrx.kernel.backend.*,
org.opencrx.kernel.generic.*,
org.openmdx.base.text.conversion.*,
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*
" %><%
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
	String FORM_NAME = "CreateCampaignForm";
	String WIZARD_NAME = "CreateCampaignWizard.jsp";

	// Get Parameters
	String command = request.getParameter("Command");
	if(command == null) command = "";
	boolean actionCreate = "OK".equals(command);
	boolean actionCancel = "Cancel".equals(command);

	if(actionCancel) {
	  session.setAttribute(WIZARD_NAME, null);
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}
%>
<!--
	<meta name="UNUSEDlabel" content="Create Campaign">
	<meta name="UNUSEDtoolTip" content="Create Campaign">
	<meta name="targetType" content="_inplace">
	<meta name="forClass" content="org:opencrx:kernel:activity1:Segment">
	<meta name="order" content="org:opencrx:kernel:activity1:Segment:createCampaign">
-->
<%
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
	org.opencrx.kernel.activity1.jmi1.Segment activitySegment = Activities.getInstance().getActivitySegment(pm, providerName, segmentName);
	org.openmdx.ui1.jmi1.FormDefinition formDefinition = app.getUiFormDefinition(FORM_NAME);
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
	if(actionCreate) {
	    String name = (String)formValues.get("org:opencrx:kernel:activity1:ActivityGroup:name");
	    String description = (String)formValues.get("org:opencrx:kernel:activity1:ActivityGroup:description");
	    org.opencrx.kernel.activity1.jmi1.ActivityType activityType = formValues.get("org:opencrx:kernel:activity1:ActivityCreator:activityType") != null ?
   	    	(org.opencrx.kernel.activity1.jmi1.ActivityType)pm.getObjectById(
     	    	formValues.get("org:opencrx:kernel:activity1:ActivityCreator:activityType")
     	    ) : null;
	    if(
	        (name != null) &&
	        (name.length() > 0) &&
	        activityType != null
	    ) {
			org.opencrx.security.realm1.jmi1.PrincipalGroup usersPrincipalGroup =
				(org.opencrx.security.realm1.jmi1.PrincipalGroup)org.opencrx.kernel.backend.SecureObject.getInstance().findPrincipal(
					"Users",
					org.opencrx.kernel.backend.SecureObject.getInstance().getRealm(
						pm,
						providerName,
						segmentName
					)
				);
			org.opencrx.security.realm1.jmi1.PrincipalGroup administratorsPrincipalGroup =
				(org.opencrx.security.realm1.jmi1.PrincipalGroup)org.opencrx.kernel.backend.SecureObject.getInstance().findPrincipal(
					"Administrators",
					org.opencrx.kernel.backend.SecureObject.getInstance().getRealm(
						pm,
						providerName,
						segmentName
					)
				);
			List allUsers = new ArrayList();
			allUsers.add(usersPrincipalGroup);
			allUsers.add(administratorsPrincipalGroup);
	        org.opencrx.kernel.activity1.jmi1.ActivityTracker activityTracker = Activities.getInstance().initActivityTracker(
	            name,
	            allUsers,
	            pm,
	            providerName,
	            segmentName
	        );
	    	// ActivityCreator for specified activityType
	    	org.opencrx.kernel.activity1.jmi1.ActivityCreator activityCreator = Activities.getInstance().initActivityCreator(
	    	    name + " - " + activityType.getName(),
	    	    activityType,
	    	    (List)Arrays.asList(new Object[]{activityTracker}),
	    	    allUsers
	    	);
	    	// Update tracker
	        pm.currentTransaction().begin();
	    	activityTracker.setDescription(description);
	    	if(activityTracker.getDefaultCreator() == null) {
	    		activityTracker.setDefaultCreator(activityCreator);
	    	}
	    	pm.currentTransaction().commit();
	    	// Forward to tracker
		    Action nextAction = new ObjectReference(
		    	activityTracker,
		    	app
		   	).getSelectObjectAction();
			response.sendRedirect(
				request.getContextPath() + "/" + nextAction.getEncodedHRef()
			);
			return;
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
<form id="<%= FORM_NAME %>" name="<%= FORM_NAME %>" accept-charset="UTF-8" method="POST" action="<%= servletPath %>">
	<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
	<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
	<input type="Hidden" id="Command" name="Command" value="" />
	<table cellspacing="8" class="tableLayout">
		<tr>
			<td class="cellObject">
				<div class="panel" id="panel<%= FORM_NAME %>" style="display: block">
<%
					form.paint(
						p,
						null, // frame
						true // forEditing
					);
					p.flush();
%>
				</div>
				<input type="submit" class="abutton" name="OK" id="OK.Button" tabindex="9000" value="Create" onclick="javascript:$('Command').value=this.name;" />
				<input  type="submit" class="abutton" name="Cancel" tabindex="9010" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Command').value=this.name;" />
			</td>
		</tr>
	</table>
</form>
<script language="javascript" type="text/javascript">
	Event.observe('<%= FORM_NAME %>', 'submit', function(event) {
		$('<%= FORM_NAME %>').request({
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
