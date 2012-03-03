<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: TwitterUpdateStatusWizard.jsp,v 1.3 2011/10/05 16:35:58 wfro Exp $
 * Description: TwitterUpdateStatusWizard
 * Revision:    $Revision: 1.3 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/10/05 16:35:58 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2005-2011, CRIXP Corp., Switzerland
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
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.openmdx.kernel.log.*,
org.openmdx.base.exception.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*,
twitter4j.*,
twitter4j.auth.*
" %><%
	final String NOTE_TITLE_PREFIX = "Status updated for";
	
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
	javax.jdo.PersistenceManager rootPm = pm.getPersistenceManagerFactory().getPersistenceManager(
		org.opencrx.kernel.generic.SecurityKeys.ROOT_PRINCIPAL,
		null
	);    			
	RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
	Texts_1_0 texts = app.getTexts();
	Codes codes = app.getCodes();
	String formName = "TwitterUpdateStatusForm";
	String wizardName = "TwitterUpdateStatusWizard.jsp";

	// Get Parameters
	String command = request.getParameter("Command");
	if(command == null) command = "";
	boolean actionSend = "OK".equals(command);
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
	<meta name="label" content="Twitter - Update Status">
	<meta name="toolTip" content="Twitter - Update Status">
	<meta name="targetType" content="_inplace">
	<meta name="forClass" content="org:opencrx:kernel:generic:CrxObject">
	<meta name="forClass" content="org:opencrx:kernel:home1:UserHome">
	<meta name="order" content="9010">
-->
<%
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
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
	formValues.put(
		"serviceAccountId",
		request.getParameter("serviceAccountId")
	);
	org.opencrx.kernel.home1.jmi1.UserHome userHome = UserHomes.getInstance().getUserHome(obj.refGetPath(), pm);
	if(actionSend) {
	    String serviceAccountId = (String)formValues.get("serviceAccountId");
	    String text = (String)formValues.get("org:opencrx:kernel:base:Note:text");
	    if(
	        (serviceAccountId != null) &&
	        (serviceAccountId.length() > 0) &&
	        (text != null) &&
	        (text.length() > 0)
	    ) {
	    	org.opencrx.kernel.admin1.jmi1.ComponentConfiguration configuration = org.opencrx.application.twitter.TwitterUtils.getComponentConfiguration(
               	providerName, 
               	segmentName, 
               	rootPm
            );
            // Find default twitter account
            org.opencrx.kernel.home1.jmi1.TwitterAccount twitterAccount = (org.opencrx.kernel.home1.jmi1.TwitterAccount)userHome.getEMailAccount(serviceAccountId);
	    	if(twitterAccount != null) {
            	TwitterFactory twitterFactory = new TwitterFactory();
            	AccessToken accessToken = new AccessToken(
            		twitterAccount.getAccessToken(),
            		twitterAccount.getAccessTokenSecret()
            	);
            	Twitter twitter = twitterFactory.getInstance();
            	twitter.setOAuthConsumer(
               		org.opencrx.application.twitter.TwitterUtils.getConsumerKey(twitterAccount, configuration),
               		org.opencrx.application.twitter.TwitterUtils.getConsumerSecret(twitterAccount, configuration)
               	);
            	twitter.setOAuthAccessToken(accessToken);
               	try {
	            	Status status = twitter.updateStatus(
	            		text
	            	);
               	} catch(Exception e) {
               		new ServiceException(e).log();
               	}
               	// Send alert if invoked on user's home
	            String title = NOTE_TITLE_PREFIX + " [" + twitterAccount.getName() + "] @ " + new Date(); 
               	if(obj instanceof org.opencrx.kernel.home1.jmi1.UserHome) {
               		org.opencrx.kernel.home1.jmi1.UserHome user = (org.opencrx.kernel.home1.jmi1.UserHome)obj;
               		Base.getInstance().sendAlert(
               			user, // target
               			user.refGetPath().getBase(),
               			title,
               			text,
               			(short)2, // importance
               			0, // resendDelayInSeconds
               			null // reference
               		);
               	}
                // Attach message as Note
                else if(obj instanceof org.opencrx.kernel.generic.jmi1.CrxObject) {
                    try {
                    	pm.currentTransaction().begin();
	               		org.opencrx.kernel.generic.jmi1.CrxObject crxObject = (org.opencrx.kernel.generic.jmi1.CrxObject)obj;
	                	org.opencrx.kernel.generic.jmi1.Note note = pm.newInstance(org.opencrx.kernel.generic.jmi1.Note.class);
	                	note.refInitialize(false, false);
						note.setTitle(title);
						note.setText(text);
						crxObject.addNote(
							Base.getInstance().getUidAsString(),
							note
						);
						pm.currentTransaction().commit();
						// FollowUp if obj is an activity
						if(obj instanceof org.opencrx.kernel.activity1.jmi1.Activity) {
        					try {
        						org.opencrx.kernel.activity1.jmi1.Activity activity = (org.opencrx.kernel.activity1.jmi1.Activity)obj;
        						org.opencrx.kernel.activity1.jmi1.ActivityProcess activityProcess = activity.getActivityType().getControlledBy();
        						org.opencrx.kernel.activity1.cci2.ActivityProcessTransitionQuery processTransitionQuery = (org.opencrx.kernel.activity1.cci2.ActivityProcessTransitionQuery)pm.newQuery(org.opencrx.kernel.activity1.cci2.ActivityProcessTransition.class);
        						processTransitionQuery.thereExistsPrevState().equalTo(activity.getProcessState());
        						processTransitionQuery.orderByNewPercentComplete().ascending();
        						List<org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition> processTransitions = activityProcess.getTransition(processTransitionQuery);
        						if(!processTransitions.isEmpty()) {
        							org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition processTransition = processTransitions.iterator().next();
        							pm.currentTransaction().begin();
        							org.opencrx.kernel.activity1.jmi1.ActivityFollowUp followUp = Activities.getInstance().doFollowUp(
       					        		activity, 
       					        		title, 
       					        		text, 
       					        		processTransition, 
       					        		null // reportingContact
       					        	);	
        							pm.currentTransaction().commit();
        						}
        					} catch(Exception e) {
        						try {
        							pm.currentTransaction().rollback();
        						} catch(Exception e0) {}
        					}							
						}
                    } catch(Exception e) {
                    	try {
                    		pm.currentTransaction().rollback();
                    	} catch(Exception e0) {}
                    }
                }
    	    	// Forward to obj
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
					<table class="fieldGroup">
						<tr>
							<td title="" class="label"><span class="nw"><%= app.getLabel("org:opencrx:kernel:home1:TwitterAccount") %>:</span></td>
							<td>
							    <select tabindex="1000" class="valueL" name="serviceAccountId" id="serviceAccountId">
<%
									org.opencrx.kernel.home1.cci2.TwitterAccountQuery twitterAccountQuery = (org.opencrx.kernel.home1.cci2.TwitterAccountQuery)pm.newQuery(org.opencrx.kernel.home1.jmi1.TwitterAccount.class);
									twitterAccountQuery.thereExistsIsActive().isTrue();
									twitterAccountQuery.orderByName().ascending();
									List<org.opencrx.kernel.home1.jmi1.TwitterAccount> twitterAccounts = userHome.getEMailAccount(twitterAccountQuery);
									for(org.opencrx.kernel.home1.jmi1.TwitterAccount twitterAccount: twitterAccounts) {
%>							    
							        	<option value="<%= twitterAccount.refGetPath().getBase() %>"><%= app.getHtmlEncoder().encode(twitterAccount.getName(), false) %></option>
<%
									}
%>							        	
							    </select>
							</td>						
							<td class="addon"></td>
						</tr>
					</table>				
<%
					form.paint(
						p,
						null, // frame
						true // forEditing
					);
					p.flush();
%>
				</div>
				<input type="submit" class="abutton" name="OK" id="OK.Button" tabindex="9000" value="Send" onclick="javascript:$('Command').value=this.name;" />
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
if(rootPm != null) {
	rootPm.close();
}
%>
