<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: ImportAddressesWizard.jsp,v 1.7 2010/04/27 12:16:10 wfro Exp $
 * Description: ImportAddressGroupMemberWizard
 * Revision:    $Revision: 1.7 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2010/04/27 12:16:10 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2004-2010, CRIXP Corp., Switzerland
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
	String formName = "ImportAddressesForm";
	String wizardName = "ImportAddressesWizard.jsp";

	// Get Parameters
	boolean actionImport = request.getParameter("OK.Button") != null;
	boolean actionCancel = request.getParameter("Cancel.Button") != null;

	if(actionCancel) {
	  session.setAttribute(wizardName, null);
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html dir="<%= texts.getDir() %>">
<head>
	<title><%= app.getTexts().getNewText() %> - <%= app.getLabel("org:opencrx:kernel:activity1:AddressGroup") %></title>
	<meta name="label" content="Import Addresses">
	<meta name="toolTip" content="Import Addresses">
	<meta name="targetType" content="_self">
	<meta name="forClass" content="org:opencrx:kernel:activity1:AddressGroup">
	<meta name="order" content="9998">
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
	org.opencrx.kernel.account1.jmi1.Segment accountSegment = (org.opencrx.kernel.account1.jmi1.Segment)pm.getObjectById(
	    new Path("xri:@openmdx:org.opencrx.kernel.account1/provider/" + providerName + "/segment/" + segmentName)
	);
	if(actionImport) {
	    if(
	    	(obj instanceof org.opencrx.kernel.activity1.jmi1.AddressGroup) &&
	    	(request.getParameter("AddressFilter.xri") != null)
	    ) {
	      org.opencrx.kernel.activity1.jmi1.AddressGroup addressGroup = (org.opencrx.kernel.activity1.jmi1.AddressGroup)obj;
	      Set addressXris = new HashSet();
				for(Iterator i = addressGroup.getMember().iterator(); i.hasNext(); ) {
						addressXris.add(((org.opencrx.kernel.activity1.jmi1.AddressGroupMember)i.next()).getAddress().refMofId());
				}

		    org.opencrx.kernel.account1.jmi1.AddressFilterGlobal addressFilter = (org.opencrx.kernel.account1.jmi1.AddressFilterGlobal)pm.getObjectById(new Path(request.getParameter("AddressFilter.xri")));
		    int countLimit = -1;
		    try {
		    		countLimit = Integer.valueOf(request.getParameter("CountLimit"));
		    } catch (Exception e) {}
				pm.currentTransaction().begin();
				int ii = 0;
				for(Iterator i = addressFilter.getFilteredAddress().iterator(); i.hasNext() && ii < countLimit; ) {
				    org.opencrx.kernel.account1.jmi1.AccountAddress address = (org.opencrx.kernel.account1.jmi1.AccountAddress)i.next();
				    if (addressXris.contains(address.refMofId())) {continue;} // do not import duplicates

				    org.opencrx.kernel.activity1.jmi1.AddressGroupMember member = pm.newInstance(org.opencrx.kernel.activity1.jmi1.AddressGroupMember.class);
				    member.refInitialize(false, false);
				    member.setAddress(address);
						addressGroup.addMember(
						    false,
						    org.opencrx.kernel.backend.Accounts.getInstance().getUidAsString(),
						    member
						);
						ii++;
						if(ii % 100 == 0) {
							pm.currentTransaction().commit();
							pm.currentTransaction().begin();
						}
				}
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
%>
<body>
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
				<form name="<%= formName %>" accept-charset="UTF-8" method="POST" action="<%= wizardName %>">
					<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
					<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
					<table cellspacing="8" class="tableLayout">
						<tr>
							<td class="cellObject">
								<div class="panel" id="panelObj0" style="display: block">
									<div class="fieldGroupName">Import addresses</div>
										<table class="fieldGroup">
											<tr>
												<td class="label">Address filter:</td>
												<td>
													<select id="AddressFilter.xri" class="valueL" tabindex="100" name="AddressFilter.xri">
<%
														org.opencrx.kernel.account1.cci2.AddressFilterGlobalQuery addressFilterQuery = (org.opencrx.kernel.account1.cci2.AddressFilterGlobalQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.AddressFilterGlobal.class);
														addressFilterQuery.forAllDisabled().isFalse();
														addressFilterQuery.orderByName().ascending();
														for(Iterator i = accountSegment.getAddressFilter(addressFilterQuery).iterator(); i.hasNext(); ) {
														    org.opencrx.kernel.account1.jmi1.AddressFilterGlobal addressFilter = (org.opencrx.kernel.account1.jmi1.AddressFilterGlobal)i.next();
%>
															<option value="<%= addressFilter.refMofId() %>"><%= new ObjectReference(addressFilter, app).getTitle() %></option>
<%
														}
%>
													</select>
												</td>
												<td class="addon"/>
												<td class="label"/>
												<td/>
												<td class="addon"/>
											</tr>
											<tr>
												<td class="label">Count limit:</td>
												<td><input type="text" class="valueR" id="CountLimit" name="CountLimit" value="0"/></td>
												<td class="addon"/></td>
												<td class="label"/>
												<td/>
												<td class="addon"/>
											</tr>
										</table>
									</div>
								</div>
								<input type="submit" class="abutton" name="OK.Button" id="OK.Button" tabindex="9000" value="Import" />
								<input  type="submit" class="abutton" name="Cancel.Button" tabindex="9010" value="<%= app.getTexts().getCancelTitle() %>" />
							</td>
						</tr>
					</table>
				</form>
			</div> <!-- content -->
		</div> <!-- content-wrap -->
	</div> <!-- wrap -->
</div> <!-- container -->
</body>
</html>
<%
if(pm != null) {
	pm.close();
}
%>
