<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: EMailForwardWizard.jsp,v 1.9 2011/11/28 14:04:37 wfro Exp $
 * Description: EMailForwardToWizard
 * Revision:    $Revision: 1.9 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/11/28 14:04:37 $
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
org.openmdx.application.cci.*,
org.openmdx.base.text.conversion.*,
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
org.openmdx.base.naming.*,
org.openmdx.kernel.log.*,
org.opencrx.kernel.backend.*
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
	javax.jdo.PersistenceManager pm = app.getNewPmData();
	RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
	Texts_1_0 texts = app.getTexts();
	Codes codes = app.getCodes();
%>	
<!--	
	<meta name="label" content="Forward E-Mail">
	<meta name="toolTip" content="Forward E-Mail">
	<meta name="targetType" content="_self">
	<meta name="forClass" content="org:opencrx:kernel:activity1:EMail">
	<meta name="order" content="9999">
-->
<%
	if(obj instanceof org.opencrx.kernel.activity1.jmi1.EMail) {
		org.opencrx.kernel.activity1.jmi1.EMail eMailActivity = (org.opencrx.kernel.activity1.jmi1.EMail)obj;
		if(eMailActivity.getLastAppliedCreator() != null) {
			org.opencrx.kernel.activity1.jmi1.NewActivityParams params = org.opencrx.kernel.utils.Utils.getActivityPackage(pm).createNewActivityParams(
				eMailActivity.getCreationContext(),
				eMailActivity.getDescription(),
				eMailActivity.getDetailedDescription(),
				eMailActivity.getDueBy(),
				eMailActivity.getIcalType(),
				"(Fwd: " + eMailActivity.getName() + ")",
				eMailActivity.getPriority(),
				eMailActivity.getReportingContact(),
				eMailActivity.getScheduledEnd(),
				eMailActivity.getScheduledStart()
			);
			pm.currentTransaction().begin();
			org.opencrx.kernel.activity1.jmi1.NewActivityResult result = eMailActivity.getLastAppliedCreator().newActivity(params);
			pm.currentTransaction().commit();
			if(result.getActivity() != null) {
				org.opencrx.kernel.activity1.jmi1.EMail forwardEMailActivity = (org.opencrx.kernel.activity1.jmi1.EMail)result.getActivity();
			 	pm.refresh(forwardEMailActivity);
			 	pm.currentTransaction().begin();
			 	// Subject
			 	forwardEMailActivity.setMessageSubject("(Fwd: " + eMailActivity.getMessageSubject() + ")");
			 	// Body
			 	StringBuilder newMessageBody = new StringBuilder();
			 	newMessageBody.append("//-------- Original Message --------\n");
			 	newMessageBody.append("Subject: 	" + eMailActivity.getMessageSubject() + "\n");
			 	newMessageBody.append("Date:        " + eMailActivity.getCreatedAt() + "\n");
			 	newMessageBody.append("From:        " + (eMailActivity.getSender() == null ? "" : ((org.opencrx.kernel.account1.jmi1.EMailAddress)eMailActivity.getSender()).getEmailAddress()) + "\n");
			 	Collection<org.opencrx.kernel.activity1.jmi1.EMailRecipient> recipients = eMailActivity.getEmailRecipient();
			 	for(org.opencrx.kernel.activity1.jmi1.EMailRecipient recipient: recipients) {
			 		if(recipient.getPartyType() == Activities.PartyType.EMAIL_TO.getValue()) {
					 	newMessageBody.append("To:        " + ((org.opencrx.kernel.account1.jmi1.EMailAddress)recipient.getParty()).getEmailAddress() + "\n");			 			
			 		}
			 		else if(recipient.getPartyType() == Activities.PartyType.EMAIL_CC.getValue()) {
					 	newMessageBody.append("CC:        " + ((org.opencrx.kernel.account1.jmi1.EMailAddress)recipient.getParty()).getEmailAddress() + "\n");			 			
			 		}
			 	}
			 	newMessageBody.append("\n\n");
			 	if(eMailActivity.getMessageBody() != null) {
			 		newMessageBody.append(eMailActivity.getMessageBody());
			 	}
			 	forwardEMailActivity.setMessageBody(newMessageBody.toString());
			 	// Gateway
			 	forwardEMailActivity.setGateway(eMailActivity.getGateway());
			 	// Current user  Sender
			 	org.opencrx.kernel.home1.jmi1.UserHome userHome = UserHomes.getInstance().getUserHome(
			 		eMailActivity.refGetPath(), 
			 		pm
			 	);
			 	org.opencrx.kernel.account1.jmi1.AccountAddress[] accountAddresses = Accounts.getInstance().getMainAddresses(userHome.getContact());
			 	if(accountAddresses != null) {
			 		forwardEMailActivity.setSender(accountAddresses[Accounts.MAIL_BUSINESS]);			 				
			 	}
			 	// Set link
			 	org.opencrx.kernel.activity1.jmi1.ActivityLinkTo linkTo = pm.newInstance(org.opencrx.kernel.activity1.jmi1.ActivityLinkTo.class);
			 	linkTo.refInitialize(false, false);
			 	linkTo.setName("#" + eMailActivity.getActivityNumber() + ": " + eMailActivity.getName());
			 	linkTo.setActivityLinkType((short)97); // is derived from
			 	linkTo.setLinkTo(eMailActivity);
			 	forwardEMailActivity.addActivityLinkTo(
			 		org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
			 		linkTo
			 	);
			 	pm.currentTransaction().commit();
			 	obj = forwardEMailActivity;
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
	if(pm != null) {
		pm.close();
	}
%>
