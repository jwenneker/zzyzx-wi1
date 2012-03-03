<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: BulkCreateActivityWizard.jsp,v 1.3 2011/10/05 20:51:04 wfro Exp $
 * Description: BulkCreateActivityWizard.jsp
 * Revision:    $Revision: 1.3 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/10/05 20:51:04 $
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
%><%@ page session="true" import="
java.util.*,
java.io.*,
java.text.*,
org.opencrx.kernel.portal.*,
org.opencrx.kernel.backend.*,
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.base.exception.*,
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
	final String FORM_NAME = "bulkCreateActivityForm";
	final String wizardName = "BulkCreateActivityWizard.jsp";

	try {
    	// Get Parameters
		String command = request.getParameter("Command");
		if(command == null) command = "";
		boolean actionCreate = "OK".equals(command);
		boolean actionCancel = "Cancel".equals(command);
		if(actionCancel || (!(obj instanceof org.opencrx.kernel.account1.jmi1.AccountFilterGlobal))) {
			session.setAttribute(wizardName, null);
			Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
			response.sendRedirect(
				request.getContextPath() + "/" + nextAction.getEncodedHRef()
			);
			return;
		}
		org.opencrx.kernel.account1.jmi1.AccountFilterGlobal accountFilter = (org.opencrx.kernel.account1.jmi1.AccountFilterGlobal)obj;
		String providerName = accountFilter.refGetPath().get(2);
		String segmentName = accountFilter.refGetPath().get(4);
		org.opencrx.kernel.activity1.jmi1.Segment activitySegment = Activities.getInstance().getActivitySegment(pm, providerName, segmentName);
%>
      <!--
      	<meta name="label" content="Bulk - Create Activity">
      	<meta name="toolTip" content="Bulk - Create Activity">
      	<meta name="targetType" content="_inplace">
      	<meta name="forClass" content="org:opencrx:kernel:account1:AccountFilterGlobal">
      	<meta name="order" content="5555">
      -->
<%
		org.openmdx.ui1.jmi1.FormDefinition formDefinition = app.getUiFormDefinition(FORM_NAME);
		org.openmdx.portal.servlet.control.FormControl bulkCreateActivityForm = new org.openmdx.portal.servlet.control.FormControl(
			formDefinition.refGetPath().getBase(),
			app.getCurrentLocaleAsString(),
			app.getCurrentLocaleAsIndex(),
			app.getUiContext(),
			formDefinition
		);
		Map formValues = new HashMap();
		bulkCreateActivityForm.updateObject(
    		request.getParameterMap(),
    		formValues,
    		app,
    		pm
    	);
		boolean isFirstCall = request.getParameter("isFirstCall") == null;
		// Initialize formValues on first call
		if(isFirstCall) {
			// Nothing todo
		}
		if(actionCreate) {
    	    org.opencrx.kernel.activity1.jmi1.ActivityCreator activityCreator =
            	(org.opencrx.kernel.activity1.jmi1.ActivityCreator)pm.getObjectById(
            		formValues.get("org:opencrx:kernel:activity1:Activity:lastAppliedCreator")
            	);
    	    String name = (String)formValues.get("org:opencrx:kernel:activity1:Activity:name");
    	    String description = (String)formValues.get("org:opencrx:kernel:activity1:Activity:description");
    	    String detailedDescription = (String)formValues.get("org:opencrx:kernel:activity1:Activity:detailedDescription");
    	    Date scheduledStart = (Date)formValues.get("org:opencrx:kernel:activity1:Activity:scheduledStart");
    	    Date scheduledEnd = (Date)formValues.get("org:opencrx:kernel:activity1:Activity:scheduledEnd");
    	    Short priority = (Short)formValues.get("org:opencrx:kernel:activity1:Activity:priority");
    	    Date dueBy = (Date)formValues.get("org:opencrx:kernel:activity1:Activity:dueBy");
    	    // Create activities
    	    if(activityCreator != null) {    	    	
    	    	Collection<org.opencrx.kernel.account1.jmi1.Account> accounts = accountFilter.getFilteredAccount();
    	    	for(org.opencrx.kernel.account1.jmi1.Account account: accounts) {
    	    		String activityName = name + " / " + account.getFullName() + (account.getAliasName() == null ? "" : " / " + account.getAliasName());
	    			org.opencrx.kernel.activity1.cci2.ActivityQuery activityQuery = (org.opencrx.kernel.activity1.cci2.ActivityQuery)pm.newQuery(org.opencrx.kernel.activity1.jmi1.Activity.class);
	    			activityQuery.name().equalTo(activityName);
	    			List<org.opencrx.kernel.activity1.jmi1.Activity> activities = activitySegment.getActivity(activityQuery);
	    			// Create if activity does not exist
	    			if(activities.isEmpty()) {
	        			org.opencrx.kernel.activity1.jmi1.NewActivityParams params = org.opencrx.kernel.utils.Utils.getActivityPackage(pm).createNewActivityParams(
	        				null, // creationContext
	        				description,
	        				detailedDescription,
	        				dueBy,
	        				ICalendar.ICAL_TYPE_NA,
	        				activityName,
	        				priority,
	        				null, // reportingContact
	        				scheduledEnd,
	        				scheduledStart
						);
	        			try {
	        				pm.currentTransaction().begin();
	        				org.opencrx.kernel.activity1.jmi1.NewActivityResult result = activityCreator.newActivity(params);	        				
	        				pm.currentTransaction().commit();
							if(result.getActivity() != null) {
								org.opencrx.kernel.activity1.jmi1.Activity newActivity = (org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(result.getActivity().refGetPath()); 
								pm.currentTransaction().begin();
								if(account instanceof org.opencrx.kernel.account1.jmi1.Contact) {
									newActivity.setReportingContact((org.opencrx.kernel.account1.jmi1.Contact)account);
								} else {
									newActivity.setReportingContact(null);
									newActivity.setReportingAccount(account);
								}
								pm.currentTransaction().commit();
							}
	        			} catch(Exception e) {
	        				try {
	        					pm.currentTransaction().rollback();
	        				} catch(Exception e0) {}
	        			}
	    			}
    	    	}
				Action nextAction = new ObjectReference(
					obj,
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
			<input type="hidden" id="Command" name="Command" value="" />
			<input type="checkbox" style="display:none;" id="isFirstCall" name="isFirstCall" checked="true" />
			<table cellspacing="8" class="tableLayout">
				<tr>
					<td class="cellObject">
						<div class="panel" id="panel<%= FORM_NAME %>" style="display: block">
<%
							bulkCreateActivityForm.paint(
								p,
								null, // frame
								true // forEditing
							);
							p.flush();
%>
						</div>
						<div id="waitMsg" style="display:none;">
							Processing request - please wait...<br>
							<img border="0" src='./images/progress_bar.gif' alt='please wait...' />
						</div>						
						<div id="submitButtons">
							<input type="submit" class="abutton", name="Refresh" id="Refresh.Button" tabindex="9000" value="<%= app.getTexts().getReloadText() %>" style="display:none;" onclick="javascript:$('Command').value=this.name;" />
							<input type="submit" class="abutton", name="OK" id="OK.Button" tabindex="9000" value="<%= app.getTexts().getOkTitle() %>" onclick="javascript:$('Command').value=this.name;this.name='--';$('waitMsg').style.display='block';$('submitButtons').style.visibility='hidden';" />
							<input type="submit" class="abutton" name="Cancel" tabindex="9010" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Command').value=this.name;" />
						</div>
					</td>
				</tr>
			</table>
		</form>
		<br>&nbsp;
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
	}
	catch (Exception e) {
		new ServiceException(e).log();
	}
	finally {
		if(pm != null) {
			pm.close();
		}
	}
%>
