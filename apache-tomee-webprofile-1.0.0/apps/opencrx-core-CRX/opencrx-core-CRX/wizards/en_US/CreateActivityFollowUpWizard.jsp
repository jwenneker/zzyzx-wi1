<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: CreateActivityFollowUpWizard.jsp,v 1.12 2011/11/15 17:52:16 cmu Exp $
 * Description: CreateActivityFollowUpWizard
 * Revision:    $Revision: 1.12 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/11/15 17:52:16 $
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
org.opencrx.kernel.portal.*,
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
	final String FORM_NAME_DOFOLLOWUP = "doFollowUpForm";
	final String wizardName = "CreateActivityFollowUpWizard.jsp";
	final String RESOURCE_CLASS = "org:opencrx:kernel:activity1:Resource";

  try {
    	// Get Parameters
    	String command = request.getParameter("Command");
    	if(command == null) command = "";
    	boolean actionCreate = "OK".equals(command);
    	boolean actionCancel = "Cancel".equals(command);

    	if(actionCancel || (!(obj instanceof org.opencrx.kernel.activity1.jmi1.Activity))) {
    		session.setAttribute(wizardName, null);
    		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
    		response.sendRedirect(
    			request.getContextPath() + "/" + nextAction.getEncodedHRef()
    		);
    		return;
    	}
    	org.opencrx.kernel.activity1.jmi1.Activity activity = (org.opencrx.kernel.activity1.jmi1.Activity)obj;
%>
      <!--
      	<meta name="UNUSEDlabel" content="Create Activity Follow Up">
      	<meta name="UNUSEDtoolTip" content="Create Activity Follow Up">
      	<meta name="targetType" content="_inplace">
      	<meta name="forClass" content="org:opencrx:kernel:activity1:Activity">
      	<meta name="order" content="org:opencrx:kernel:activity1:Activity:createActivityFollowUp">
      -->
<%
    	org.openmdx.ui1.jmi1.FormDefinition doFollowUpFormDefinition = app.getUiFormDefinition(FORM_NAME_DOFOLLOWUP);
    	org.openmdx.portal.servlet.control.FormControl doFollowUpForm = new org.openmdx.portal.servlet.control.FormControl(
    		doFollowUpFormDefinition.refGetPath().getBase(),
    		app.getCurrentLocaleAsString(),
    		app.getCurrentLocaleAsIndex(),
    		app.getUiContext(),
    		doFollowUpFormDefinition
    	);

      Map formValues = new HashMap();
      doFollowUpForm.updateObject(
    		request.getParameterMap(),
    		formValues,
    		app,
    		pm
    	);

		// get additional parameters
		boolean isFirstCall = request.getParameter("isFirstCall") == null; // used to properly initialize various options
		if (isFirstCall) {
			// populate form fields related to activity with activity's attribute values
			formValues.put("org:opencrx:kernel:activity1:Activity:assignedTo", activity.getAssignedTo() == null ? null : activity.getAssignedTo().refGetPath());
			formValues.put("org:opencrx:kernel:activity1:Activity:description", activity.getDescription());
			formValues.put("org:opencrx:kernel:activity1:Activity:location", activity.getLocation());
			formValues.put("org:opencrx:kernel:activity1:Activity:priority", activity.getPriority());
			formValues.put("org:opencrx:kernel:activity1:Activity:dueBy", activity.getDueBy());
		}

		if(request.getParameter("resourceContact") != null) {
			org.opencrx.kernel.account1.jmi1.Contact resourceContact = null;
			try {
				resourceContact = (org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(new Path(request.getParameter("resourceContact")));
		 	} catch (Exception e) {}
		 	if (resourceContact != null && request.getParameter("fetchResourceContact") != null && request.getParameter("fetchResourceContact").length() > 0) {
				formValues.put("org:opencrx:kernel:activity1:Activity:assignedTo", resourceContact.refGetPath());
		 	}
		}
		 	
 	    org.opencrx.kernel.account1.jmi1.Contact assignedTo = null;
 	    try {
 	    	assignedTo = formValues.get("org:opencrx:kernel:activity1:Activity:assignedTo") != null ?
	 	    	(org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(
	 	    		formValues.get("org:opencrx:kernel:activity1:Activity:assignedTo")
	 	    	) : null;
 	    } catch (Exception e) {}

     	if(actionCreate) {
    	    //
    	    // doFollowUp
    	    org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition transition =
            	(org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition)pm.getObjectById(
            		formValues.get("org:opencrx:kernel:activity1:ActivityDoFollowUpParams:transition")
            	);
    	    String followUpTitle = (String)formValues.get("org:opencrx:kernel:activity1:ActivityDoFollowUpParams:followUpTitle");
    	    String followUpText = (String)formValues.get("org:opencrx:kernel:activity1:ActivityDoFollowUpParams:followUpText");
			org.opencrx.kernel.account1.jmi1.Contact assignTo = formValues.get("org:opencrx:kernel:activity1:ActivityDoFollowUpParams:assignTo") != null ?
    	    	(org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(
    	    		formValues.get("org:opencrx:kernel:activity1:ActivityDoFollowUpParams:assignTo")
    	    	) : null;

            // updateActivity
    	    String description = (String)formValues.get("org:opencrx:kernel:activity1:Activity:description");
    	    String location = (String)formValues.get("org:opencrx:kernel:activity1:Activity:location");
    	    Short priority = (Short)formValues.get("org:opencrx:kernel:activity1:Activity:priority");
    	    Date dueBy = (Date)formValues.get("org:opencrx:kernel:activity1:Activity:dueBy");

    	    if(transition != null) {
    			org.opencrx.kernel.activity1.jmi1.ActivityDoFollowUpParams params = org.opencrx.kernel.utils.Utils.getActivityPackage(pm).createActivityDoFollowUpParams(
              assignTo,
              followUpText,
              followUpTitle,
              transition
    			);
          pm.refresh(activity);
          pm.currentTransaction().begin();
    			org.opencrx.kernel.activity1.jmi1.ActivityDoFollowUpResult result = activity.doFollowUp(params);
          activity.setAssignedTo(assignedTo);
          activity.setDescription(description);
          activity.setLocation(location);
          activity.setPriority(priority);
          activity.setDueBy(dueBy);
    			pm.currentTransaction().commit();
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
      <form id="<%= FORM_NAME_DOFOLLOWUP %>" name="<%= FORM_NAME_DOFOLLOWUP %>" accept-charset="UTF-8" method="POST" action="<%= servletPath %>">
      	<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
      	<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
      	<input type="hidden" id="Command" name="Command" value="" />
        <input type="checkbox" style="display:none;" id="isFirstCall" name="isFirstCall" checked="true" />
      	<table cellspacing="8" class="tableLayout">
      		<tr>
      			<td class="cellObject">
      				<div class="panel" id="panel<%= FORM_NAME_DOFOLLOWUP %>" style="display: block">
<%
      					doFollowUpForm.paint(
      						p,
      						null, // frame
      						true // forEditing
      					);
      					p.flush();
%>
								<table class="fieldGroup">
									<div class="fieldGroupName">&nbsp;</div>
									<tr>
										<td class="label">
											<span class="nw"><%= app.getLabel(RESOURCE_CLASS) %>:</span>
										</td>
										<td>
											<input type="hidden" id="fetchResourceContact" name="fetchResourceContact" value="" /> 
											<select id="resourceContact" name="resourceContact" class="valueL" onchange="javascript:$('fetchResourceContact').value='override';$('Refresh.Button').click();" >
<%
				                // get Resources sorted by name(asc)
												String providerName = obj.refGetPath().get(2);
												String segmentName = obj.refGetPath().get(4);
												org.opencrx.kernel.activity1.jmi1.Segment activitySegment = (org.opencrx.kernel.activity1.jmi1.Segment)pm.getObjectById(
														new Path("xri:@openmdx:org.opencrx.kernel.activity1/provider/" + providerName + "/segment/" + segmentName)
													);
												org.opencrx.kernel.activity1.jmi1.Activity1Package activityPkg = org.opencrx.kernel.utils.Utils.getActivityPackage(pm);
				                org.opencrx.kernel.activity1.cci2.ResourceQuery recourceFilter = activityPkg.createResourceQuery();
				                recourceFilter.orderByName().ascending();
												recourceFilter.forAllDisabled().isFalse();
												int maxResourceToShow = 200;
				                for (
				                  Iterator k = activitySegment.getResource(recourceFilter).iterator();
				                  k.hasNext() && maxResourceToShow > 0;
				                  maxResourceToShow--
				                ) {
				                	try {
					                  // get resource
					            	    org.opencrx.kernel.activity1.jmi1.Resource resource =
					                    (org.opencrx.kernel.activity1.jmi1.Resource)k.next();
					            	    org.opencrx.kernel.account1.jmi1.Contact contact = resource.getContact();
					            	    if (contact != null) {
						                  String selectedModifier = ((contact != null ) && (assignedTo != null) && (assignedTo.refMofId().compareTo(contact.refMofId()) == 0)) ? "selected" : "";
%>
						                  <option <%= selectedModifier %> value="<%= contact.refMofId() %>"><%= resource.getName() + (contact != null ? " (" + contact.getFirstName() + " " + contact.getLastName() + ")": "") %></option>
<%
					            	    }
				                	} catch (Exception e) {}
				                }
%>
				              </select>
					          </td>
										<td class="addon"/>
									</tr>
								</table>

      				</div>

      				<input type="submit" class="abutton", name="Refresh" id="Refresh.Button" tabindex="9000" value="<%= app.getTexts().getReloadText() %>" style="display:none;" onclick="javascript:$('Command').value=this.name;" />
      				<input type="submit" class="abutton", name="OK" id="OK.Button" tabindex="9000" value="<%= app.getTexts().getOkTitle() %>" onclick="javascript:$('Command').value=this.name;this.name='--';" />
      				<input type="submit" class="abutton" name="Cancel" tabindex="9010" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Command').value=this.name;" />
      			</td>
      		</tr>
      	</table>
      </form>
      <br>&nbsp;
      <script language="javascript" type="text/javascript">
      	Event.observe('<%= FORM_NAME_DOFOLLOWUP %>', 'submit', function(event) {
      		$('<%= FORM_NAME_DOFOLLOWUP %>').request({
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
