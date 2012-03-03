<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: TwitterCreateAccessTokenWizard.jsp,v 1.4 2011/12/12 10:31:18 cmu Exp $
 * Description: TwitterCreateAccessTokenWizard
 * Revision:    $Revision: 1.4 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/12/12 10:31:18 $
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
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS
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
twitter4j.*,
twitter4j.auth.*,
org.opencrx.kernel.backend.Activities,
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
org.openmdx.base.exception.*,
org.opencrx.application.twitter.*,
org.openmdx.base.naming.*
" %><%
	final String REQUEST_TOKEN_KEY = RequestToken.class.getName();

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
	String formName = "TwitterCreateAccessTokenForm";
	String wizardName = "TwitterCreateAccessTokenWizard.jsp";

	// Get Parameters
	String command = request.getParameter("Command");
	String pin = request.getParameter("PIN");
	if(command == null) command = "";
	boolean actionOk = "OK".equals(command);
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
	<meta name="label" content="Twitter - Create Access Token">
	<meta name="toolTip" content="Twitter - Create Access Token">
	<meta name="targetType" content="_inplace">
	<meta name="forClass" content="org:opencrx:kernel:home1:TwitterAccount">
	<meta name="order" content="9000">
-->
<%
	org.opencrx.kernel.home1.jmi1.TwitterAccount twitterAccount = (org.opencrx.kernel.home1.jmi1.TwitterAccount)obj;
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
	String message = null;
	org.opencrx.kernel.admin1.jmi1.ComponentConfiguration configuration = 
		org.opencrx.application.twitter.TwitterUtils.getComponentConfiguration(
			providerName, 
			segmentName, 
			rootPm
		);
    Twitter twitter = new TwitterFactory().getInstance();
    twitter.setOAuthConsumer(
    	org.opencrx.application.twitter.TwitterUtils.getConsumerKey(twitterAccount, configuration),
    	org.opencrx.application.twitter.TwitterUtils.getConsumerSecret(twitterAccount, configuration)    	
    );
	if(actionOk) {
	    RequestToken requestToken = (RequestToken)session.getAttribute(REQUEST_TOKEN_KEY);
	    if(requestToken != null) {
		    AccessToken accessToken = null;
		    try {
		    	accessToken = twitter.getOAuthAccessToken(requestToken, pin);
		    	pm.currentTransaction().begin();
		    	twitterAccount.setAccessToken(accessToken.getToken());
		    	twitterAccount.setAccessTokenSecret(accessToken.getTokenSecret());
		    	pm.currentTransaction().commit();
			    Action nextAction = new ObjectReference(
			    	twitterAccount,
			    	app
			   	).getSelectObjectAction();
				session.removeAttribute(REQUEST_TOKEN_KEY);
				response.sendRedirect(
					request.getContextPath() + "/" + nextAction.getEncodedHRef()
				);
				return;	    	
			} 
		    catch(Exception e) {
		    	new ServiceException(e).log();
		    	message = e.getMessage();
			}
	    }
	}
	RequestToken requestToken = twitter.getOAuthRequestToken();
   	session.setAttribute(
		REQUEST_TOKEN_KEY,
   		requestToken
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
					<div class="fieldGroupName">&nbsp;</div>				
					<table class="fieldGroup">
						<tr>
							<td title="" class="label"><span class="nw">Authentication URL:</span></td>
							<td><a href="<%= requestToken.getAuthorizationURL() %>" target="_blank">Click here to get PIN</a></td>
							<td class="addon"></td>
						</tr>
					</table>				
					<table class="fieldGroup">
						<tr>
							<td title="" class="label"><span class="nw">PIN:</span></td>
							<td>
							  <input type="text" value="" tabindex="1100" class="valueL mandatory" name="PIN" id="PIN">
							</td>
							<td class="addon"></td>
						</tr>
					</table>
<%
					if(message != null) {
%>														
						<div class="fieldGroupName">&nbsp;</div>				
						<table class="fieldGroup">
							<tr>
								<td><%= message %></td>
							</tr>
						</table>
<%
					}
%>										
				</div>
				<input type="submit" class="abutton" name="OK" id="OK.Button" tabindex="9000" value="<%= app.getTexts().getOkTitle() %>" onclick="javascript:$('Command').value=this.name;" />
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
if(pm != null) {
	pm.close();
}
if(rootPm != null) {
	rootPm.close();
}
%>
