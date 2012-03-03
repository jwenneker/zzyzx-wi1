<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: AddressGroupRemoveDuplicateMembers.jsp,v 1.5 2010/04/27 12:16:11 wfro Exp $
 * Description: ImportAddressGroupMemberWizard
 * Revision:    $Revision: 1.5 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2010/04/27 12:16:11 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2004-2009, CRIXP Corp., Switzerland
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
org.openmdx.kernel.log.*
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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html dir="<%= texts.getDir() %>">
<head>
	<title><%= app.getTexts().getNewText() %> - <%= app.getLabel("org:opencrx:kernel:activity1:AddressGroup") %></title>
	<meta name="label" content="Remove Duplicate Addresses">
	<meta name="toolTip" content="Remove Duplicate Addresses">
	<meta name="targetType" content="_self">
	<meta name="forClass" content="org:opencrx:kernel:activity1:AddressGroup">
	<meta name="order" content="9999">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<link href="../../_style/colors.css" rel="stylesheet" type="text/css">
	<link href="../../_style/calendar-small.css" rel="stylesheet" type="text/css">
	<!--[if lt IE 7]><script type="text/javascript" src="../../javascript/iehover-fix.js"></script><![endif]-->
	<script language="javascript" type="text/javascript" src="../../javascript/portal-all.js"></script>
	<script language="javascript" type="text/javascript" src="../../javascript/calendar/lang/calendar-<%= app.getCurrentLocaleAsString() %>.js"></script>
	<link rel="stylesheet" type="text/css" href="../../_style/ssf.css">
	<link rel="stylesheet" type="text/css" href="../../_style/n2default.css">
	<link rel="shortcut icon" href="../../images/favicon.ico" />
	<script language="javascript" type="text/javascript">
    	history.forward(); // prevent going back to this page by breaking history
	  	var OF = null;
	  	try {
			OF = self.opener.OF;
	  	}
	  	catch(e) {
			OF = null;
	  	}
	  	if(!OF) {
			OF = new ObjectFinder();
	  	}
	</script>
</head>
<%
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
  if(
  	(obj instanceof org.opencrx.kernel.activity1.jmi1.AddressGroup)
  ) {
    org.opencrx.kernel.activity1.jmi1.AddressGroup addressGroup = (org.opencrx.kernel.activity1.jmi1.AddressGroup)obj;
    Set addressXris = new HashSet();
    Set emailAddresses = new HashSet();
    Set phoneNumbers = new HashSet();
    Set membersToDelete = new HashSet();
    int sizeOfSet = 0;
    int sizeOfEmailAddrSet = 0;
    int sizeOfPhoneNumberSet = 0;
    for(Iterator i = addressGroup.getMember().iterator(); i.hasNext(); ) {
        org.opencrx.kernel.activity1.jmi1.AddressGroupMember addressGroupMember = (org.opencrx.kernel.activity1.jmi1.AddressGroupMember)i.next();
        org.opencrx.kernel.account1.jmi1.AccountAddress address = addressGroupMember.getAddress();
        addressXris.add(address.refMofId());
        if (addressXris.size() <= sizeOfSet) {
            // current address object is duplicate
            membersToDelete.add(addressGroupMember);
        }
        sizeOfSet = addressXris.size();

        if (address instanceof org.opencrx.kernel.account1.jmi1.EMailAddress) {
            org.opencrx.kernel.account1.jmi1.EMailAddress eMailAddress = (org.opencrx.kernel.account1.jmi1.EMailAddress)address;
            if (eMailAddress.getEmailAddress() != null) {
                emailAddresses.add(eMailAddress.getEmailAddress());
                if (emailAddresses.size() <= sizeOfEmailAddrSet) {
                    // current e-mail address is duplicate
                    membersToDelete.add(addressGroupMember);
                }
                sizeOfEmailAddrSet = emailAddresses.size();
            }
        }

        if (address instanceof org.opencrx.kernel.account1.jmi1.PhoneNumber) {
            org.opencrx.kernel.account1.jmi1.PhoneNumber phoneNumber = (org.opencrx.kernel.account1.jmi1.PhoneNumber)address;
            if (phoneNumber.getPhoneNumberFull() != null) {
                phoneNumbers.add(phoneNumber.getPhoneNumberFull());
                if (phoneNumbers.size() <= sizeOfPhoneNumberSet) {
                    // current phone number is duplicate
                    membersToDelete.add(addressGroupMember);
                }
                sizeOfPhoneNumberSet = phoneNumbers.size();
            }

        }
    }

    for(Iterator i = membersToDelete.iterator(); i.hasNext(); ) {
        try {
            pm.currentTransaction().begin();
            org.opencrx.kernel.activity1.jmi1.AddressGroupMember addressGroupMember = (org.opencrx.kernel.activity1.jmi1.AddressGroupMember)i.next();
            addressGroupMember.refDelete();
            pm.currentTransaction().commit();
        } catch (Exception e) {
            new ServiceException(e).log();
            try {
                pm.currentTransaction().rollback();
            } catch (Exception er) {}
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
<body>
</body>
</html>
