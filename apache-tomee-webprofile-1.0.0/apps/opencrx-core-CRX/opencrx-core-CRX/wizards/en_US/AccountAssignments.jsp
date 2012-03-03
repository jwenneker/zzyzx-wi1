<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     opencrx, http://www.opencrx.org/
 * Name:        $Id: AccountAssignments.jsp,v 1.18 2011/11/23 13:44:30 wfro Exp $
 * Description: list account assignments
 * Revision:    $Revision: 1.18 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/11/23 13:44:30 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2008-2011, CRIXP Corp., Switzerland
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
java.math.*,
java.sql.*,
javax.naming.Context,
javax.naming.InitialContext,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.base.exception.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.action.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*,
org.openmdx.base.query.*
" %><%
	request.setCharacterEncoding("UTF-8");
	ApplicationContext app = (ApplicationContext)session.getValue(WebKeys.APPLICATION_KEY);
	ViewsCache viewsCache = (ViewsCache)session.getValue(WebKeys.VIEW_CACHE_KEY_SHOW);
	String requestId = request.getParameter(Action.PARAMETER_REQUEST_ID);
	String objectXri = request.getParameter("xri");
	if(objectXri == null || app == null || viewsCache.getView(requestId) == null) {
		response.sendRedirect(
			request.getContextPath() + "/" + WebKeys.SERVLET_NAME
		);
		return;
	}
	javax.jdo.PersistenceManager pm = app.getNewPmData();
	Texts_1_0 texts = app.getTexts();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
  <title>Account Assignments (Inventory Items)</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta name="label" content="Account Assignments (Inventory Items)">
  <meta name="toolTip" content="Account Assignments (Inventory Items)">
  <meta name="targetType" content="_blank">
  <meta name="forClass" content="org:opencrx:kernel:account1:Segment">
  <meta name="forClass" content="org:opencrx:kernel:account1:Contact">
  <meta name="forClass" content="org:opencrx:kernel:account1:LegalEntity">
  <meta name="forClass" content="org:opencrx:kernel:account1:UnspecifiedAccount">
  <meta name="forClass" content="org:opencrx:kernel:account1:Group">
  <meta name="forClass" content="org:opencrx:kernel:building1:Segment">
  <meta name="order" content="8500">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <link href="../../_style/colors.css" rel="stylesheet" type="text/css">

  <script language="javascript" type="text/javascript" src="../../javascript/prototype.js"></script>
  <script language="javascript" type="text/javascript" src="../../javascript/scriptaculous.js"></script>
  <link rel="stylesheet" type="text/css" href="../../javascript/yui-ext/resources/css/ytheme-gray.css" >
  <link href="../../_style/n2default.css" rel="stylesheet" type="text/css" />

  <link rel='shortcut icon' href='../../images/favicon.ico' />
</head>

<body class="ytheme-gray">
<%
  final String FORM_ACTION = "AccountAssignments.jsp";
  final String AccountAssignmentInventoryItem_CLASS = "org:opencrx:kernel:building1:AccountAssignmentInventoryItem";
	try {
      Codes codes = app.getCodes();
      short currentLocale = app.getCurrentLocaleAsIndex();

      Path objectPath = new Path(objectXri);
      String providerName = objectPath.get(2); // e.g. CRX
      String segmentName = objectPath.get(4);  // e.g. Standard

      // Get building1 package
      org.opencrx.kernel.building1.jmi1.Building1Package buildingPkg = org.opencrx.kernel.utils.Utils.getBuildingPackage(pm);

      // Get building segment
      org.opencrx.kernel.building1.jmi1.Segment buildingSegment =
        (org.opencrx.kernel.building1.jmi1.Segment)pm.getObjectById(
          new Path("xri:@openmdx:org.opencrx.kernel.building1/provider/" + providerName + "/segment/" + segmentName)
         );

      RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));

      // Timezone is reusable
			Properties userSettings =  new Properties();
			userSettings = app.getSettings();
      //final TimeZone utc = TimeZone.getTimeZone("Europe/Zurich");
      final TimeZone tz = TimeZone.getTimeZone(userSettings.getProperty("TimeZone.Name"));
      // DateFormat is not multi-thread-safe!
      DateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy hh:mm:ss");
      dateFormat.setLenient(false); // if the timestamp string is always complete
      dateFormat.setTimeZone(tz);

%>
      <h1 style="padding:2px;">
        <%= app.getLabel(AccountAssignmentInventoryItem_CLASS) %>
        <INPUT type="Submit" name="Cancel.Button" tabindex="8020" value="X" onClick="javascript:window.close();" />
      </h1>
<%
    	Attribute accountAttr = null;
    	Attribute accountRoleAttr = null;
    	Attribute validFromAttr = null;
    	Attribute validToAttr = null;
    	Attribute disabledAttr = null;
    	Attribute nameAttr = null;
    	Attribute descriptionAttr = null;
    	Attribute modifiedAtAttr = null;
  		Map accountAssignmentInventoryItemValues = null;
		UserDefinedView userView = (UserDefinedView)session.getValue(FORM_ACTION);
  		if (userView == null) {
    		accountAssignmentInventoryItemValues = new HashMap();
    		userView = new UserDefinedView(
    			accountAssignmentInventoryItemValues,
    			app,
    			viewsCache.getView(requestId)
    		);
     		// get AccountAssignmentInventoryItem attributes
			try {
				accountAttr = userView.addAttribute(
					  AccountAssignmentInventoryItem_CLASS + ":account",
					  AccountAssignmentInventoryItem_CLASS,
					"account",
					accountAssignmentInventoryItemValues
				);
			} catch (Exception e) {}
			try {
				accountRoleAttr = userView.addAttribute(
					  AccountAssignmentInventoryItem_CLASS + ":accountRole",
					  AccountAssignmentInventoryItem_CLASS,
					"accountRole",
					accountAssignmentInventoryItemValues
				);
			} catch (Exception e) {}
			try {
				validFromAttr = userView.addAttribute(
					  AccountAssignmentInventoryItem_CLASS + ":validFrom",
					  AccountAssignmentInventoryItem_CLASS,
					"validFrom",
					accountAssignmentInventoryItemValues
				);
			} catch (Exception e) {}
			try {
				validToAttr = userView.addAttribute(
					  AccountAssignmentInventoryItem_CLASS + ":validTo",
					  AccountAssignmentInventoryItem_CLASS,
					"validTo",
					accountAssignmentInventoryItemValues
				);
			} catch (Exception e) {}
			try {
				disabledAttr = userView.addAttribute(
					  AccountAssignmentInventoryItem_CLASS + ":disabled",
					  AccountAssignmentInventoryItem_CLASS,
					"disabled",
					accountAssignmentInventoryItemValues
				);
			} catch (Exception e) {}
			try {
				nameAttr = userView.addAttribute(
					  AccountAssignmentInventoryItem_CLASS + ":name",
					  AccountAssignmentInventoryItem_CLASS,
					"name",
					accountAssignmentInventoryItemValues
				);
			} catch (Exception e) {}
			try {
				descriptionAttr = userView.addAttribute(
					  AccountAssignmentInventoryItem_CLASS + ":description",
					  AccountAssignmentInventoryItem_CLASS,
					"description",
					accountAssignmentInventoryItemValues
				);
			} catch (Exception e) {}
			try {
				modifiedAtAttr = userView.addAttribute(
					  AccountAssignmentInventoryItem_CLASS + ":modifiedAt",
					  AccountAssignmentInventoryItem_CLASS,
					"modifiedAt",
					accountAssignmentInventoryItemValues
				);
			} catch (Exception e) {}
		}

%>
		  <table><tr><td>
			<table id="resultTable" class="gridTableFull">
			  <tr class="gridTableHeader">
			    <td>&nbsp;<%= app.getLabel("org:opencrx:kernel:building1:InventoryItem") %></td>
			    <td>&nbsp;<%= accountAttr     == null ? "Account"     : userView.getAttribute(AccountAssignmentInventoryItem_CLASS + ":account"    ).getLabel() %></td>
			    <td>&nbsp;<%= accountRoleAttr == null ? "Role"        : userView.getAttribute(AccountAssignmentInventoryItem_CLASS + ":accountRole").getLabel() %></td>
			    <td>&nbsp;<%= validFromAttr   == null ? "Valid from"  : userView.getAttribute(AccountAssignmentInventoryItem_CLASS + ":validFrom"  ).getLabel() %></td>
			    <td>&nbsp;<%= validToAttr     == null ? "Valid to"    : userView.getAttribute(AccountAssignmentInventoryItem_CLASS + ":validTo"    ).getLabel() %></td>
			    <td>&nbsp;<%= disabledAttr    == null ? "Disabled"    : userView.getAttribute(AccountAssignmentInventoryItem_CLASS + ":disabled"   ).getLabel() %></td>
			    <td>&nbsp;<%= nameAttr        == null ? "Name"        : userView.getAttribute(AccountAssignmentInventoryItem_CLASS + ":name"       ).getLabel() %></td>
			    <td>&nbsp;<%= descriptionAttr == null ? "Description" : userView.getAttribute(AccountAssignmentInventoryItem_CLASS + ":description").getLabel() %></td>
			    <td>&nbsp;<%= modifiedAtAttr  == null ? "Modified at" : userView.getAttribute(AccountAssignmentInventoryItem_CLASS + ":modifiedAt" ).getLabel() %> <img src='../../images/arrow_down.gif' alt='' /></td>
			  </tr>
<%
        org.opencrx.kernel.building1.cci2.AccountAssignmentInventoryItemQuery accountAssignmentInventoryItemQuery =
        	(org.opencrx.kernel.building1.cci2.AccountAssignmentInventoryItemQuery)org.openmdx.base.persistence.cci.PersistenceHelper.newQuery(
        		pm.getExtent(org.opencrx.kernel.building1.jmi1.AccountAssignmentInventoryItem.class),
        		buildingSegment.refGetPath().getDescendant("inventoryItem", ":*", "assignedAccount", ":*")
        	);
        if(
             (obj instanceof org.opencrx.kernel.account1.jmi1.Contact) ||
             (obj instanceof org.opencrx.kernel.account1.jmi1.Group) ||
             (obj instanceof org.opencrx.kernel.account1.jmi1.LegalEntity) ||
             (obj instanceof org.opencrx.kernel.account1.jmi1.UnspecifiedAccount)
        ) {
          accountAssignmentInventoryItemQuery.thereExistsAccount().equalTo(obj);
        }
        accountAssignmentInventoryItemQuery.orderByModifiedAt().descending();

        List accountAssignments = null;
        try {
          accountAssignments = buildingSegment.getExtent(accountAssignmentInventoryItemQuery);
        } catch (Exception e) {}
        int shown = 0;
        int toShow = 5000;;

        if (accountAssignments != null) {
          for (
            Iterator j = accountAssignments.iterator();
            j.hasNext() && (shown < toShow);
          ) {
            // get AccountAssignmentInventoryItem
      	    org.opencrx.kernel.building1.jmi1.AccountAssignmentInventoryItem accountAssignmentInventoryItem = null;
            try {
        	    accountAssignmentInventoryItem = (org.opencrx.kernel.building1.jmi1.AccountAssignmentInventoryItem)j.next();
            } catch (Exception e) {
              //new ServiceException(e).log();
%>
              <tr class="gridTableRow">
                <td colspan="8">N/P</td>
              </tr>
<%
              continue;
            }
            shown++;

%>
            <tr class="gridTableRow">
              <td>
<%
                String inventoryItemXri = new Path(accountAssignmentInventoryItem.refMofId()).getParent().getParent().toXri();
                org.opencrx.kernel.building1.jmi1.InventoryItem inventoryItem =
                  (org.opencrx.kernel.building1.jmi1.InventoryItem)pm.getObjectById(new Path(inventoryItemXri));
                String inventoryItemHref = "";
                Action action = new Action(
                   SelectObjectAction.EVENT_ID,
                   new Action.Parameter[]{
                       new Action.Parameter(Action.PARAMETER_OBJECTXRI, inventoryItem.refMofId())
                   },
                   "",
                   true // enabled
                );
                inventoryItemHref = "../../" + action.getEncodedHRef();
%>
                <a href="<%= inventoryItemHref %>" target="_blank"><%= (new ObjectReference(inventoryItem, app)).getTitle() %></a>
              </td>
              <td>
<%
                org.opencrx.kernel.account1.jmi1.Account account = null;
                if (accountAssignmentInventoryItem.getAccount() != null) {
                  account = accountAssignmentInventoryItem.getAccount();
                }
                if(account != null) {
					String accountHref = "";
					action = new ObjectReference(
						account,
						app
					).getSelectObjectAction();
                  accountHref = "../../" + action.getEncodedHRef();
%>
                  <a href="<%= accountHref %>" target="_blank"><%= (new ObjectReference(account, app)).getTitle() %></a>
<%
                }
%>
              </td>
              <td><%= (String)(codes.getLongText("accountRoleInventoryItem", currentLocale, true, true).get(new Short((short)accountAssignmentInventoryItem.getAccountRole()))) %></td>
      		    <td><%= accountAssignmentInventoryItem.getValidFrom() != null ? dateFormat.format(accountAssignmentInventoryItem.getValidFrom()) : "" %></td>
      		    <td><%= accountAssignmentInventoryItem.getValidTo()   != null ? dateFormat.format(accountAssignmentInventoryItem.getValidTo())   : "" %></td>
      		    <td><img src='../../images/<%= (accountAssignmentInventoryItem.isDisabled() != null) && (accountAssignmentInventoryItem.isDisabled().booleanValue()) ? "" : "not" %>checked_r.gif' alt='' /></td>
      		    <td><%= accountAssignmentInventoryItem.getName()        != null ? accountAssignmentInventoryItem.getName()        : "" %></td>
      		    <td><%= accountAssignmentInventoryItem.getDescription() != null ? accountAssignmentInventoryItem.getDescription() : "" %></td>
      		    <td><%= accountAssignmentInventoryItem.getModifiedAt()  != null ? dateFormat.format(accountAssignmentInventoryItem.getModifiedAt()) : "" %></td>
            </tr>
<%
          } // loop over AccountAssignments
        }
%>
      </table>
      </td></tr></table>
<%
      if (accountAssignments == null) {
%>
        <br>
        <br>
        <h1>keine ausreichende Berechtigung für diese Abfrage</h1>
<%
      }
	}
	catch (Exception e) {
      ServiceException e0 = new ServiceException(e);
      e0.log();
      out.println("<p><b>!! Failed !!<br><br>The following exception(s) occured:</b><br><br><pre>");
      PrintWriter pw = new PrintWriter(out);
      e0.printStackTrace(pw);
      out.println("</pre></p>");
  	} finally {
  		if(pm != null) {
  			pm.close();
  		}
  	}

%>
  <INPUT type="Submit" name="Cancel.Button" tabindex="8020" value="X" onClick="javascript:window.close();" />
</body>

</html>
