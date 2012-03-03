<%@	page contentType= "text/html;charset=utf-8" language="java" pageEncoding= "UTF-8" %><%
/*
 * ====================================================================
 * Project:			openCRX/Core, http://www.opencrx.org/
 * Name:				$Id: ManageUsers.jsp,v 1.5 2010/12/21 12:13:25 cmu Exp $
 * Description: Manage openCRX Users (membership of PrincipalGroups, etc.)
 * Revision:		$Revision: 1.5 $
 * Owner:				CRIXP AG, Switzerland, http://www.crixp.com
 * Date:				$Date: 2010/12/21 12:13:25 $
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
java.math.*,
java.net.*,
java.sql.*,
javax.naming.Context,
javax.naming.InitialContext,
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.opencrx.kernel.portal.*,
org.opencrx.kernel.backend.*,
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
org.openmdx.base.query.*,
org.openmdx.kernel.log.*,
org.apache.poi.hssf.usermodel.*,
org.apache.poi.hssf.util.*
" %>
<%!
	private static HSSFSheet addSheet(
		HSSFWorkbook wb,
		String sheetName,
		boolean isLandscape,
		HSSFCellStyle headerStyle
	) {
		HSSFSheet sheet = wb.createSheet(sheetName);
		sheet.setMargin(HSSFSheet.TopMargin,		0.5);
		sheet.setMargin(HSSFSheet.RightMargin,	0.3);
		sheet.setMargin(HSSFSheet.BottomMargin, 0.6);
		sheet.setMargin(HSSFSheet.LeftMargin,	 0.5);
		sheet.setAutobreaks(true);

		HSSFPrintSetup ps = sheet.getPrintSetup();
		/*
		ps.setFitHeight((short)100);
		ps.setFitWidth((short)1);
		*/
		ps.setPaperSize(HSSFPrintSetup.A4_PAPERSIZE);
		ps.setLandscape(isLandscape);
		ps.setFooterMargin(0.3);

		HSSFFooter footer = sheet.getFooter();
		footer.setRight(HSSFFooter.page() + " / " + HSSFFooter.numPages());

		String[] labels = new String[] {
			 "PrincipalName",
			 "PrincipalDescription",
			 "PrincipalEnabled",
			 "AliasName",
			 "FullName",
			 "EMailAccount",
			 "PrimaryGroup",
			 "MemberOfPrincipalGroups",
			 "Password",
			 "XRI"
		};

		HSSFRow row = null;
		HSSFCell cell = null;
		short nRow = 0;
		short nCell = 0;
		row = sheet.createRow(nRow++);
		for (short i=0; i<labels.length; i++) {
				cell = row.createCell(nCell++);
				cell.setCellStyle(headerStyle);
				cell.setCellValue(labels[i]);
				sheet.setColumnWidth(i, (short)5000);
		}
		sheet.setColumnWidth((short)1, (short)8000);
		sheet.setColumnWidth((short)4, (short)8000);
		sheet.setColumnWidth((short)5, (short)8000);
		sheet.setColumnWidth((short)7, (short)8000);
		return sheet;
	}

	private static short addPrincipal(
		HSSFSheet sheet,
		org.opencrx.security.realm1.jmi1.Principal principal,
		org.opencrx.kernel.home1.jmi1.UserHome userHome,
		org.opencrx.kernel.account1.jmi1.Contact contact,
		String isMemberOfPrincipalGroups,
		String eMailAccount,
		short rowNumber,
		HSSFCellStyle wrappedStyle,
		HSSFCellStyle topAlignedStyle,
		SimpleDateFormat exceldate,
		ApplicationContext app
	) {

		HSSFRow row = null;
		HSSFCell cell = null;
		short nRow = rowNumber;
		short nCell = 0;
		row = sheet.createRow(nRow++);

		//PrincipalName
		cell = row.createCell(nCell++);
		cell.setCellStyle(topAlignedStyle);
		if (principal.getName() != null) {cell.setCellValue(principal.getName());}

		//PrincipalDescription
		cell = row.createCell(nCell++);
		cell.setCellStyle(topAlignedStyle);
		if (principal.getDescription() != null) {cell.setCellValue(principal.getDescription());}

		//PrincipalEnabled
		cell = row.createCell(nCell++);
		cell.setCellStyle(topAlignedStyle);
		cell.setCellValue(!principal.isDisabled());

		//AliasName
		cell = row.createCell(nCell++);
		cell.setCellStyle(topAlignedStyle);
		if (contact != null && contact.getAliasName() != null) {cell.setCellValue(contact.getAliasName());}

		//FullName
		cell = row.createCell(nCell++);
		cell.setCellStyle(topAlignedStyle);
		if (contact != null && contact.getFullName() != null) {cell.setCellValue(contact.getFullName());}

		//EMailAccount
		cell = row.createCell(nCell++);
		cell.setCellStyle(topAlignedStyle);
		if (eMailAccount != null) {cell.setCellValue(eMailAccount);}

		//PrimaryGroup
		cell = row.createCell(nCell++);
		cell.setCellStyle(topAlignedStyle);
		if (userHome != null && userHome.getPrimaryGroup() != null && userHome.getPrimaryGroup().getName() != null) {cell.setCellValue(userHome.getPrimaryGroup().getName());}
		
		//MemberOfPrincipalGroups
		cell = row.createCell(nCell++);
		cell.setCellStyle(topAlignedStyle);
		if (isMemberOfPrincipalGroups != null) {cell.setCellValue(isMemberOfPrincipalGroups);}

		//Password
		cell = row.createCell(nCell++);
		cell.setCellStyle(topAlignedStyle);

		//XRI
		cell = row.createCell(nCell++);
		cell.setCellStyle(topAlignedStyle);
		cell.setCellValue(principal.refMofId());

		//return sheet;
		return nRow;
	}

%>
<%
	final String WIZARD_NAME = "ManageUsers";
	final String FORMACTION	 = WIZARD_NAME + ".jsp";

	request.setCharacterEncoding("UTF-8");
	ApplicationContext app = (ApplicationContext)session.getValue(WebKeys.APPLICATION_KEY);
	ViewsCache viewsCache = (ViewsCache)session.getValue(WebKeys.VIEW_CACHE_KEY_SHOW);
	String requestId =	request.getParameter(Action.PARAMETER_REQUEST_ID);
	String requestIdParam = Action.PARAMETER_REQUEST_ID + "=" + requestId;
	String objectXri = request.getParameter("xri");
	if(app == null || objectXri == null || viewsCache.getView(requestId) == null) {
			response.sendRedirect(
				 request.getContextPath() + "/" + WebKeys.SERVLET_NAME
			);
			return;
	}
	javax.jdo.PersistenceManager pm = app.getNewPmData();
	Texts_1_0 texts = app.getTexts();
	org.openmdx.portal.servlet.Codes codes = app.getCodes();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>

<head>
	<title>Manage Users</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta name="label" content="Manage Users">
	<meta name="toolTip" content="Manage Users">
	<meta name="targetType" content="_blank">
	<meta name="forClass" content="org:opencrx:kernel:home1:Segment">
	<meta name="order" content="1000">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
	<link href="../../_style/ssf.css" rel="stylesheet" type="text/css">
	<link href="../../_style/colors.css" rel="stylesheet" type="text/css">
	<!--[if lt IE 7]><script type="text/javascript" src="../../javascript/iehover-fix.js"></script><![endif]-->
	<script language="javascript" type="text/javascript" src="../../javascript/portal-all.js"></script>
	<link rel="shortcut icon" href="../../images/favicon.ico" />
</head>

<style type="text/css" media="all">
	.gridTableRowFull TD {white-space:nowrap;}
	.gridTableHeaderFull TD {white-space:nowrap;vertical-align:bottom;}
</style>

<%
final String location = UUIDs.getGenerator().next().toString();
String mode = (request.getParameter("mode") == null ? "0" : request.getParameter("mode")); // default is [Manage Members]
%>

<body>
<div id="container">
	<div id="wrap">

		<form name="ManageMembers" style="padding:0;border-top:3px solid #E4E4E4;margin:0;" accept-charset="UTF-8" method="POST" action="<%= FORMACTION %>">
			<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
			<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
			<input type="hidden" name="previousSheet" id="previousSheet" value="<%= location %>" />
			<input type="hidden" name="mode" id="mode" value="<%= mode %>" />
			<input type="hidden" name="paging" id="paging" value="" />
			<input type="checkbox" style="display:none;" name="isFirstCall" checked />
			<input type="checkbox" style="display:none;" name="isSelectionChange" id="isSelectionChange" />

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
<%
				try {
					// get reference of calling object
					RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));

					Path objectPath = new Path(objectXri);
					String providerName = objectPath.get(2);
					String segmentName = objectPath.get(4);

					UserDefinedView userView = new UserDefinedView(
						obj,
						app,
						viewsCache.getView(requestId)
					);

					// Get realm1 package
					org.opencrx.security.realm1.jmi1.Realm1Package realmPkg = org.opencrx.kernel.utils.Utils.getRealmPackage(pm);

					// security realm
					org.openmdx.security.realm1.jmi1.Realm realm =
						(org.openmdx.security.realm1.jmi1.Realm)pm.getObjectById(
							new Path("xri://@openmdx*org.openmdx.security.realm1").getDescendant("provider", providerName, "segment", "Root", "realm", segmentName)
						);

					// Get home1 package
					org.opencrx.kernel.home1.jmi1.Home1Package homePkg = org.opencrx.kernel.utils.Utils.getHomePackage(pm);

					// Get home segment
					org.opencrx.kernel.home1.jmi1.Segment homeSegment = UserHomes.getInstance().getUserHomeSegment(pm, providerName, segmentName);

%>

					<div id="etitle" style="height:20px;padding-left:12px;">
						 Manage Users of Segment "<%= segmentName %>"
					</div>

					<div id="topnavi">
						<ul id="navigation" class="navigation" onmouseover="sfinit(this);">
							<li class="<%= mode.compareTo("0")==0 ? "selected" : "" %>"><a href="#" onclick="javascript:try{$('mode').value='0';}catch(e){};setTimeout('disableSubmit()', 10);$('Reload.Button').click();";><span>Manage Users</span></a></li>
							<li style="display:none;" class="<%= mode.compareTo("1")==0 ? "selected" : "" %>"><a href="#" onclick="javascript:try{$('mode').value='1';}catch(e){};setTimeout('disableSubmit()', 10);$('Reload.Button').click();";><span>Add Users</span></a></li>
						</ul>
			
<%
						NumberFormat formatter = new DecimalFormat("0");

						// Format dates/times
						TimeZone timezone = TimeZone.getTimeZone(app.getCurrentTimeZone());
						SimpleDateFormat timeFormat = new SimpleDateFormat("dd-MMM-yyyy HH:mm", app.getCurrentLocale());
						timeFormat.setTimeZone(timezone);
						SimpleDateFormat timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss", app.getCurrentLocale());
						timestamp.setTimeZone(timezone);
						SimpleDateFormat exceldate = new SimpleDateFormat("dd-MM-yyyy");
						exceldate.setTimeZone(timezone);


						final String USER_CLASS = "org:opencrx:security:realm1:User";
						final String PRINCIPAL_CLASS = "org:opencrx:security:realm1:Principal";
						final String PRINCIPALGROUP_CLASS = "org:opencrx:security:realm1:PrincipalGroup";
						final String USERHOME_CLASS = "org:opencrx:kernel:home1:UserHome";
						final String CONTACT_CLASS = "org:opencrx:kernel:account1:Contact";
						final String MEMBER_CLASS = "org:opencrx:kernel:account1:Member";
						final String ACCOUNTMEMBERSHIP_CLASS = "org:opencrx:kernel:account1:AccountMembership";
						final String EMAILACCOUNT_CLASS = "org:opencrx:kernel:home1:EMailAccount";

						final String ACCOUNTSEGMENT_CLASS = "org:opencrx:kernel:account1:Segment";
						final String ACCOUNT_CLASS = "org:opencrx:kernel:account1:Account";
						final String ACCOUNTFILTERGLOBAL_CLASS = "org:opencrx:kernel:account1:AccountFilterGlobal";
						final String LEGALENTITY_CLASS = "org:opencrx:kernel:account1:LegalEntity";
						final String GROUP_CLASS = "org:opencrx:kernel:account1:Group";
						final String UNSPECIFIEDACCOUNT_CLASS = "org:opencrx:kernel:account1:UnspecifiedAccount";
						final String EMAILADDRESS_CLASS = "org:opencrx:kernel:account1:EMailAddress";

						final String ACCOUNT_FILTER_XRI_PREFIX = "ACCOUNT_FILTER_XRI_";

						final int DEFAULT_PAGE_SIZE = 20;

						final String OK = "<img src='../../images/checked.gif' />";
						final String MISSING = "<img src='../../images/cancel.gif' />";
						final String CHECKED_R = "<img border='0' alt='OK' src='../../images/checked_r.gif'>";
						final String NOTCHECKED_R = "<img border='0' alt='OK' src='../../images/notchecked_r.gif'>";

						final String colorDuplicate = "#FFA477";
						final String colorMember = "#D2FFD2";
						final String colorMemberDisabled = "#F2F2F2";

						final String CAUTION = "<img border='0' alt='' height='16px' src='../../images/caution.gif' />";
						final String SPREADSHEET = "<img border='0' alt='EXCEL' title='EXCEL' align='top' height='24px' src='../../images/spreadsheet.png' />";
						final String sheetName = "Accounts_(openCRX)_" + timestamp.format(new java.util.Date());
						File f = null;
						FileOutputStream os = null;
						HSSFWorkbook wb = null;
						Action downloadAction =	null;
						HSSFSheet sheetPrincipals = null;
						HSSFFont headerfont = null;
						HSSFCellStyle headerStyle = null;
						HSSFCellStyle wrappedStyle = null;
						HSSFCellStyle topAlignedStyle = null;

						HSSFRow row = null;
						HSSFCell cell = null;
						short nRow = 0;
						short nCell = 0;

						String errorMsg = "";

						final String wildcard = ".*";
						String searchString = (request.getParameter("searchString") == null ? "" : request.getParameter("searchString"));
						String previousSearchString = (request.getParameter("previousSearchString") == null ? "" : request.getParameter("previousSearchString"));

						String membershipString = (request.getParameter("membershipString") == null ? "" : request.getParameter("membershipString"));
						String previousMembershipString = (request.getParameter("previousMembershipString") == null ? "" : request.getParameter("previousMembershipString"));
						String membershipSelector = (request.getParameter("membershipSelector") == null ? "" : request.getParameter("membershipSelector"));

						org.opencrx.kernel.home1.cci2.UserHomeQuery userHomeFilter = homePkg.createUserHomeQuery();
						userHomeFilter.orderByIdentity().ascending();
						//userHomeFilter.forAllDisabled().isFalse();

						int tabIndex = 1;
						int pageSize = DEFAULT_PAGE_SIZE;
						int displayStart = 0;
						long highUser = 0;
						boolean isFirstCall = request.getParameter("isFirstCall") == null; // used to properly initialize various options
						boolean highUserIsKnown = ((request.getParameter("highUserIsKnown") != null) && (request.getParameter("highUserIsKnown").length() > 0));
						boolean isSelectionChange = isFirstCall || request.getParameter("isSelectionChange") != null || previousSearchString.compareTo(searchString) != 0 || previousMembershipString.compareTo(membershipString) != 0;
						String userFilterXri = null;
						int userSelectorType = 0;
							/*		0: select active users only
										1: select all users
										2: select disabled users
										5: select users that are propertly initialized (private tracker <user>~Private missing)
							*/
						if (request.getParameter("userSelectorType") != null) {
								try {
										userSelectorType = Integer.parseInt(request.getParameter("userSelectorType"));
								} catch (Exception e) {}
						}
						if (mode.compareTo("0") == 0) {
								if (userSelectorType >= 100) {
										userSelectorType = 0; // mode [Manage Users] requires selection of users, i.e. <100
								}
						} else {
								if (userSelectorType == 1) {
										userSelectorType = 100; // set to search based on Full Name
								}
						}
						boolean activeUsersOnly = userSelectorType == 0;
						boolean detectDuplicates = ((request.getParameter("detectDuplicates") != null) && (request.getParameter("detectDuplicates").length() > 0));
						try {
							pageSize = request.getParameter("pageSize") != null ? Integer.parseInt(request.getParameter("pageSize")) : DEFAULT_PAGE_SIZE;
						} catch (Exception e) {}
						try {
							highUser = request.getParameter("highUser") != null ? Long.parseLong(request.getParameter("highUser")) : 0;
						} catch (Exception e) {}
						try {
							if (request.getParameter("paging") != null && request.getParameter("paging").startsWith("--")) {
								displayStart = ((int)((highUser - (long)(10*pageSize)) / (long)pageSize)) - 1;
								if (displayStart < 0) {
									displayStart = 0;
								}
							} else if (request.getParameter("paging") != null && request.getParameter("paging").startsWith("++")) {
								displayStart = ((int)((highUser + (long)(10*pageSize)) / (long)pageSize)) - 1;
								if (displayStart < 0) {
									displayStart = 0;
								}
							} else if (request.getParameter("displayStart") != null && request.getParameter("displayStart").startsWith("+")) {
								displayStart = ((int)((highUser + Long.parseLong(request.getParameter("displayStart").substring(1))) / (long)pageSize)) - 1;
								if (displayStart < 0) {
									displayStart = 0;
								}
							} else {
								displayStart = request.getParameter("displayStart") != null ? Integer.parseInt(request.getParameter("displayStart")) : 0;
							}
						} catch (Exception e) {}
						if (isSelectionChange) {
							 highUser = 0;
							 displayStart = 0;
							 highUserIsKnown = false;
						}

						if (request.getParameter("Reload.Button") != null) {
								//System.out.println("reload.button");
								//app.resetPmData(); // evict pm data, i.e. clear cache
						}

						Iterator users = null;
						long counter = 0;
						boolean iteratorNotSet = true;
						int itSetCounter = 0;
						final int MAXITSETCOUNTER = 2;

						while (iteratorNotSet && itSetCounter < MAXITSETCOUNTER) {
								itSetCounter++;
								try {
										if (userSelectorType < 100) {
												org.opencrx.security.realm1.cci2.PrincipalQuery principalFilter = realmPkg.createPrincipalQuery();
												if (userSelectorType == 0) {
														// active users only
														principalFilter.forAllDisabled().isFalse();
														//principalFilter.thereExistsIsMemberOf().equalTo(projectPrincipalGroup);
												} else if (userSelectorType == 1) {
														// all users
												} else if (userSelectorType == 2) {
														// disabled users
														principalFilter.thereExistsDisabled().isTrue();
												} else if (userSelectorType == 5) {
													// active users that are not properly initialized (private tracker <user>~Private does not exist)
													principalFilter.forAllDisabled().isFalse();
													org.openmdx.base.query.Extension queryFilterNoPrivateTracker = org.openmdx.base.persistence.cci.PersistenceHelper.newQueryExtension(principalFilter);
													Connection conncrx = null;
													try {
														Context initialContext = new InitialContext();
														javax.sql.DataSource dscrx = (javax.sql.DataSource)initialContext.lookup("java:comp/env/jdbc_opencrx_" + providerName);
														conncrx = dscrx.getConnection();
														String databaseProductName = conncrx.getMetaData().getDatabaseProductName();				
														if("PostgreSQL".equals(databaseProductName)) {
																queryFilterNoPrivateTracker.setClause(
																		"(NOT EXISTS (select * from oocke1_activitycreator where name=(v.name || '~Private'))) and " +
																		"(NOT EXISTS (select * from oocke1_activitygroup   where name=(v.name || '~Private')))"
																);
														}
														else if("Oracle".equals(databaseProductName)) {			
																queryFilterNoPrivateTracker.setClause(
																		"(NOT EXISTS (select * from oocke1_activitycreator where name=CONCAT(v.name, '~Private'))) and " +
																		"(NOT EXISTS (select * from oocke1_activitygroup   where name=CONCAT(v.name, '~Private')))"
																);
														}
														else if(databaseProductName.startsWith("DB2")) {			
																queryFilterNoPrivateTracker.setClause(
																		"(NOT EXISTS (select * from oocke1_activitycreator where name=CONCAT(v.name, '~Private'))) and " +
																		"(NOT EXISTS (select * from oocke1_activitygroup   where name=CONCAT(v.name, '~Private')))"
																);
														}
														else if("MySQL".equals(databaseProductName)) {			
																queryFilterNoPrivateTracker.setClause(
																		"(NOT EXISTS (select * from oocke1_activitycreator where name=CONCAT(v.name, '~Private'))) and " +
																		"(NOT EXISTS (select * from oocke1_activitygroup   where name=CONCAT(v.name, '~Private')))"
																);
														}
														else if("Microsoft SQL Server".equals(databaseProductName)) {			
																queryFilterNoPrivateTracker.setClause(
																		"(NOT EXISTS (select * from oocke1_activitycreator where name=(v.name + '~Private'))) and " +
																		"(NOT EXISTS (select * from oocke1_activitygroup   where name=(v.name + '~Private')))"
																);
														}
														else if("HSQL Database Engine".equals(databaseProductName)) {			
																queryFilterNoPrivateTracker.setClause(
																		"(NOT EXISTS (select * from oocke1_activitycreator where name=CONCAT(v.name, '~Private'))) and " +
																		"(NOT EXISTS (select * from oocke1_activitygroup   where name=CONCAT(v.name, '~Private')))"
																);
														}
														conncrx.close();
													} catch (Exception ep) {
														new ServiceException(ep).log();
														if (conncrx != null) {
															try {
																conncrx.close();
															} catch (Exception connex) {};
														}
													}
												}
												principalFilter.orderByName().ascending();

												if (searchString != null && searchString.length() > 0) {
													String modifiedSearchString = searchString.replaceAll("\\*", "\\\\*");
													if (searchString.compareTo("*") == 0) {
														modifiedSearchString = "";
													}
													principalFilter.name().like("(?i).*" + modifiedSearchString + ".*");
												}
												
												if (membershipString != null && membershipString.length() > 0) {
													String modifiedMembershipString = membershipString.replaceAll("\\*", "\\\\*");
													if (membershipString.compareTo("*") == 0) {
														modifiedMembershipString = "";
													}
													principalFilter.thereExistsIsMemberOf().name().like("(?i).*" + modifiedMembershipString + ".*");
												}
												users = (realm.getPrincipal(principalFilter)).listIterator((int)displayStart*pageSize);
										}

										counter = displayStart*pageSize;
										if (users != null && !users.hasNext()) {
												displayStart = (int)((highUser / (long)pageSize));
												counter = displayStart*pageSize;
										} else {
											iteratorNotSet = false;
										}
								} catch (Exception e) {
										new ServiceException(e).log();
										displayStart = 0;
										counter = 0;
								}
						}

						if (request.getParameter("previousSheet") != null) {
								// delete previous temp file if it exists
								try {
										File previousFile = new File(
											app.getTempFileName(request.getParameter("previousSheet"), "")
										);
										if (previousFile.exists()) {
												previousFile.delete();
												//System.out.println("deleted previous temp file " + request.getParameter("previousSheet"));
										}
								} catch (Exception e){
										new ServiceException(e).log();
								}
						}

						if (request.getParameter("ACTION.enable") != null) {
								// System.out.println("ENABLE: " + request.getParameter("ACTION.enable"));
								// enable principal
								try {
										pm.currentTransaction().begin();
										org.opencrx.security.realm1.jmi1.Principal principal = (org.opencrx.security.realm1.jmi1.Principal)pm.getObjectById(new Path((request.getParameter("ACTION.enable"))));
										//
										// verify that UserHome exists
										org.opencrx.kernel.home1.jmi1.UserHome userHome = null;
										try {
											userHome = (org.opencrx.kernel.home1.jmi1.UserHome)pm.getObjectById(
												new Path("xri://@openmdx*org.opencrx.kernel.home1").getDescendant("provider", providerName, "segment", segmentName, "userHome", principal.getName())
											);
										} catch (Exception e) {
											new ServiceException(e).log();
										}
										if (userHome != null) {
											principal.setDisabled(false);
										} else {
											errorMsg = "Cannot enable " + app.getLabel(PRINCIPAL_CLASS) + " [UserHome missing]";
										}
										pm.currentTransaction().commit();
								} catch (Exception e) {
									errorMsg = "Cannot enable " + app.getLabel(PRINCIPAL_CLASS) + " [enabling failed]";
									new ServiceException(e).log();
									try {
											pm.currentTransaction().rollback();
									} catch (Exception er) {}
								}


						} else if (request.getParameter("ACTION.disable") != null) {
								System.out.println("DISABLE: " + request.getParameter("ACTION.disable"));
								// disable principal
								try {
										pm.currentTransaction().begin();
										org.opencrx.security.realm1.jmi1.Principal principal = (org.opencrx.security.realm1.jmi1.Principal)pm.getObjectById(new Path((request.getParameter("ACTION.disable"))));
										principal.setDisabled(true);
										pm.currentTransaction().commit();
								} catch (Exception e) {
										errorMsg = "Cannot disable " + app.getLabel(PRINCIPAL_CLASS) + " [disabling failed]";
										new ServiceException(e).log();
										try {
												pm.currentTransaction().rollback();
										} catch (Exception er) {}
								}

						} else if (request.getParameter("ACTION.applyUserSettings") != null) {
								// System.out.println("APPLY USER SETTINGS: " + request.getParameter("ACTION.applyUserSettings"));
								// apply users settings
								javax.jdo.PersistenceManager pmUser = null;
								try {
										org.opencrx.kernel.home1.jmi1.UserHome userHome = null;
										
										try {
											org.opencrx.security.realm1.jmi1.Principal principal = (org.opencrx.security.realm1.jmi1.Principal)pm.getObjectById(new Path((request.getParameter("ACTION.applyUserSettings"))));
											pmUser = pm.getPersistenceManagerFactory().getPersistenceManager(
												principal.getName(),
												null
											);
											userHome = (org.opencrx.kernel.home1.jmi1.UserHome)pmUser.getObjectById(
												new Path("xri://@openmdx*org.opencrx.kernel.home1").getDescendant("provider", providerName, "segment", segmentName, "userHome", principal.getName())
											);
										} catch (Exception e) {
												new ServiceException(e).log();
										}
										if (pmUser != null && userHome != null) {
												pmUser.currentTransaction().begin();

												Properties userSettings =	new Properties();
												boolean currentUserOwnsHome = app.getCurrentUserRole().equals(userHome.refGetPath().getBase() + "@" + segmentName);
												if(currentUserOwnsHome) {
													userSettings = app.getSettings();
												}
												else if(userHome.getSettings() != null) {
													userSettings.load(
														new ByteArrayInputStream(
															userHome.getSettings().getBytes("UTF-8")
														)
													);
												}

												String settingTimezone = userSettings.getProperty(UserSettings.TIMEZONE_NAME);
												String settingStoreSettingsOnLogoff = userHome.isStoreSettingsOnLogoff() != null && userHome.isStoreSettingsOnLogoff().booleanValue() ? "true" : "false";

												org.opencrx.kernel.home1.cci2.EMailAccountQuery emailAccountQuery = (org.opencrx.kernel.home1.cci2.EMailAccountQuery)pmUser.newQuery(org.opencrx.kernel.home1.jmi1.EMailAccount.class);
												emailAccountQuery.thereExistsIsActive().isTrue();
												emailAccountQuery.thereExistsIsDefault().isTrue();
												List<org.opencrx.kernel.home1.jmi1.EMailAccount> emailAccounts = userHome.getEMailAccount(emailAccountQuery);
												org.opencrx.kernel.home1.jmi1.EMailAccount defaultEmailAccount = emailAccounts.isEmpty() ? null : emailAccounts.iterator().next();
												String settingEmailAccount = (defaultEmailAccount == null || defaultEmailAccount.getName() == null ? "" : defaultEmailAccount.getName());
												String settingSendmailSubjectPrefix = (userHome.getSendMailSubjectPrefix() == null ? "[" + providerName + ":" + segmentName + "]" : userHome.getSendMailSubjectPrefix());
												String settingWebAccessUrl = (userHome.getWebAccessUrl() == null ? request.getRequestURL().substring(0, request.getRequestURL().indexOf("/wizards")) :	userHome.getWebAccessUrl());
												String settingTopNavigationShowMax = userSettings.getProperty(UserSettings.TOP_NAVIGATION_SHOW_MAX, "6");
												Boolean settingShowTopNavigationSublevel = "true".equals(userSettings.getProperty(UserSettings.TOP_NAVIGATION_SHOW_SUBLEVEL));
												Boolean settingGridDefaultAlignmentIsWide = "true".equals(userSettings.getProperty(UserSettings.GRID_DEFAULT_ALIGNMENT_IS_WIDE));
												Boolean settingHideWorkspaceDashboard = "true".equals(userSettings.getProperty(UserSettings.HIDE_WORKSPACE_DASHBOARD));
												
												Action[] rootObjectActions = app.getRootObjectActions();
												List<String> settingRootObjects = new ArrayList<String>();
												// Always show root object 0
												settingRootObjects.add("1");
												int n = 1;

												for(int i = 1; i < rootObjectActions.length; i++) {
													Action action = rootObjectActions[i];
													if(action.getParameter(Action.PARAMETER_REFERENCE).length() == 0) {
															String state = (userSettings.getProperty(UserSettings.ROOT_OBJECT_STATE + (app.getCurrentPerspective() == 0 ? "" : "[" + Integer.toString(app.getCurrentPerspective()) + "]") + "." + n + ".State", "1").equals("1") ? "1" : "0");
															if(i < app.getRootObject().length && app.getRootObject()[i] instanceof org.opencrx.kernel.home1.jmi1.UserHome) {
																state = "1";
															}
															settingRootObjects.add(
																state == null ? "0" : state
															);
															n++;
													}
												}
												
												Map<String,String> settingSubscriptions = new HashMap<String,String>();
												org.opencrx.kernel.workflow1.cci2.TopicQuery topicQuery =
														(org.opencrx.kernel.workflow1.cci2.TopicQuery)pmUser.newQuery(org.opencrx.kernel.workflow1.jmi1.Topic.class);
												topicQuery.orderByName().ascending();
												topicQuery.forAllDisabled().isFalse();

												org.opencrx.kernel.workflow1.jmi1.Segment workflowSegment = Workflows.getInstance().getWorkflowSegment(pm, providerName, segmentName);
												for(Iterator i = workflowSegment.getTopic(topicQuery).iterator(); i.hasNext(); ) {
													org.opencrx.kernel.workflow1.jmi1.Topic topic = (org.opencrx.kernel.workflow1.jmi1.Topic)i.next();
													ObjectReference objRefTopic = new ObjectReference(topic, app);
													org.opencrx.kernel.home1.cci2.SubscriptionQuery query = homePkg.createSubscriptionQuery();
													query.thereExistsTopic().equalTo(topic);
													Collection subscriptions = userHome.getSubscription(query);
													org.opencrx.kernel.home1.jmi1.Subscription subscription = subscriptions.isEmpty()
														? null
														: (org.opencrx.kernel.home1.jmi1.Subscription)subscriptions.iterator().next();
													Set eventTypes = new HashSet();
													if(subscription != null) {
														for(Iterator j = subscription.getEventType().iterator(); j.hasNext(); ) {
															eventTypes.add(
																Integer.valueOf(((Number)j.next()).intValue())
															);
														}
													}
													String topicId = topic.refGetPath().getBase();
													if (subscription != null && subscription.isActive()) {
															settingSubscriptions.put("topicIsActive-" + topicId, "1");
													}
													if (eventTypes.contains(Integer.valueOf(1))) {settingSubscriptions.put("topicCreation-" + topicId, "1");}
													if (eventTypes.contains(Integer.valueOf(3))) {settingSubscriptions.put("topicReplacement-" + topicId, "3");}
													if (eventTypes.contains(Integer.valueOf(4))) {settingSubscriptions.put("topicRemoval-" + topicId, "4");}
												}

												org.opencrx.kernel.backend.UserHomes.getInstance().applyUserSettings(
													userHome,
													app.getCurrentPerspective(),
													userSettings,
													false, // Do not init user home (allowed, as pmUser runs as user home's principal)
													true, // Always save settings
													userHome.getPrimaryGroup(),
													settingTimezone,
													settingStoreSettingsOnLogoff,
													settingEmailAccount,
													settingSendmailSubjectPrefix,
													settingWebAccessUrl,
													settingTopNavigationShowMax,
													settingShowTopNavigationSublevel,
													settingGridDefaultAlignmentIsWide,
													settingHideWorkspaceDashboard,													
													settingRootObjects,
													settingSubscriptions
												);

										}
										pmUser.currentTransaction().commit();
								} catch (Exception e) {
										errorMsg = "Cannot apply user settings";
										new ServiceException(e).log();
										try {
												pmUser.currentTransaction().rollback();
										} catch (Exception er) {}
								}

						} else if (request.getParameter("ACTION.addMembership") != null) {
								// System.out.println("addMembership: " + request.getParameter("ACTION.addMembership"));
								// make principal member of selectedPrincipalGroup
								try {
										pm.currentTransaction().begin();
										org.opencrx.security.realm1.jmi1.Principal principal = (org.opencrx.security.realm1.jmi1.Principal)pm.getObjectById(new Path((request.getParameter("ACTION.addMembership"))));

										org.opencrx.security.realm1.jmi1.PrincipalGroup selectedPrincipalGroup = null;
										try {
											selectedPrincipalGroup = (org.opencrx.security.realm1.jmi1.PrincipalGroup)org.opencrx.kernel.backend.SecureObject.getInstance().findPrincipal(
												membershipSelector,
												realm
											);
										} catch (Exception e) {}
										boolean isMemberOfSelectedPrincipalGroup = selectedPrincipalGroup != null && principal.getIsMemberOf() != null && principal.getIsMemberOf().contains(selectedPrincipalGroup);

										if (selectedPrincipalGroup != null && !isMemberOfSelectedPrincipalGroup) {
												principal.getIsMemberOf().add(selectedPrincipalGroup);
										}
										pm.currentTransaction().commit();
								} catch (Exception e) {
										errorMsg = "Cannot add Membership";
										new ServiceException(e).log();
										try {
												pm.currentTransaction().rollback();
										} catch (Exception er) {}
								}


						} else if (request.getParameter("ACTION.removeMembership") != null) {
								// System.out.println("removeMembership: " + request.getParameter("ACTION.removeMembership"));
								// make principal member of selectedPrincipalGroup
								try {
										pm.currentTransaction().begin();
										org.opencrx.security.realm1.jmi1.Principal principal = (org.opencrx.security.realm1.jmi1.Principal)pm.getObjectById(new Path((request.getParameter("ACTION.removeMembership"))));

										org.opencrx.security.realm1.jmi1.PrincipalGroup selectedPrincipalGroup = null;
										try {
											selectedPrincipalGroup = (org.opencrx.security.realm1.jmi1.PrincipalGroup)org.opencrx.kernel.backend.SecureObject.getInstance().findPrincipal(
												membershipSelector,
												realm
											);
										} catch (Exception e) {}
										boolean isMemberOfSelectedPrincipalGroup = selectedPrincipalGroup != null && principal.getIsMemberOf() != null && principal.getIsMemberOf().contains(selectedPrincipalGroup);

										if (selectedPrincipalGroup != null && isMemberOfSelectedPrincipalGroup) {
												principal.getIsMemberOf().remove(selectedPrincipalGroup);
										}
										pm.currentTransaction().commit();
								} catch (Exception e) {
										errorMsg = "Cannot remove Membership";
										new ServiceException(e).log();
										try {
												pm.currentTransaction().rollback();
										} catch (Exception er) {}
								}

						} else if (request.getParameter("ACTION.exportXLS") != null) {
								// System.out.println("Export_XLS: " + request.getParameter("ACTION.exportXLS"));
								try {
										f = new File(
											app.getTempFileName(location, "")
										);
										os = new FileOutputStream(f);
										wb = new HSSFWorkbook();

										// Header Style (black background, orange/bold font)
										headerfont = wb.createFont();
										headerfont.setFontHeightInPoints((short)10);
										headerfont.setFontName("Tahoma");
										headerfont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
										headerfont.setColor(HSSFColor.ORANGE.index);
										// Fonts are set into a style so create a new one to use.
										headerStyle = wb.createCellStyle();
										headerStyle.setFillForegroundColor(HSSFColor.BLACK.index);
										headerStyle.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
										headerStyle.setFont(headerfont);

										// Wrapped Style
										wrappedStyle = wb.createCellStyle();
										wrappedStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_TOP);
										wrappedStyle.setWrapText(true);

										// TopAligned Style
										topAlignedStyle = wb.createCellStyle();
										topAlignedStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_TOP);

										downloadAction =	new Action(
												Action.EVENT_DOWNLOAD_FROM_LOCATION,
												new Action.Parameter[]{
														new Action.Parameter(Action.PARAMETER_LOCATION, location),
														new Action.Parameter(Action.PARAMETER_NAME, sheetName + ".xls"),
														new Action.Parameter(Action.PARAMETER_MIME_TYPE, "application/vnd.ms-excel")
												},
												app.getTexts().getClickToDownloadText() + " " + sheetName,
												true
										);
										sheetPrincipals = addSheet(wb, "Principals", true, headerStyle);
								} catch (Exception e) {
										new ServiceException(e).log();
								}
						}
%>
						<table class="fieldGroup" style="width:100%;margin-top:0;padding-top:0;border-top:0;border-collapse:collapse;">
							<tr>
								<td id="submitButtons" style="font-weight:bold;background-color:#E4E4E4;padding-bottom:3px;">
									<div style="padding:8px 3px;">
										<%= app.getTexts().getSelectAllText() %> <select style="width:180px;" id="userSelectorType" name="userSelectorType" onchange="javascript:$('waitMsg').style.visibility='visible';$('submitButtons').style.visibility='hidden';$('isSelectionChange').checked=true;$('Reload.Button').click();" >
<%
										if (mode.compareTo("0") == 0) {
%>
											<option <%= userSelectorType == 0 ? "selected" : "" %> value="0"><%= app.getLabel(USER_CLASS)	%> (active)&nbsp;</option>
											<option <%= userSelectorType == 1 ? "selected" : "" %> value="1"><%= app.getLabel(USER_CLASS)	%> (all)&nbsp;</option>
											<option <%= userSelectorType == 2 ? "selected" : "" %> value="2"><%= app.getLabel(USER_CLASS)	%> (disabled)&nbsp;</option>
											<option <%= userSelectorType == 5 ? "selected" : "" %> value="5"><%= app.getLabel(USER_CLASS)	%> (active - not initialized)&nbsp;</option>
<%
										} else {
%>
											<option <%= userSelectorType == 100 ? "selected" : "" %> value="100">? <%= app.getTexts().getSearchText() %> <%= userView.getFieldLabel("org:opencrx:kernel:account1:LegalEntity", "name", app.getCurrentLocaleAsIndex()) %>&nbsp;</option>
											<option <%= userSelectorType == 110 ? "selected" : "" %> value="110">? <%= app.getTexts().getSearchText() %> <%= app.getLabel(EMAILADDRESS_CLASS) %>&nbsp;</option>
											<option <%= userSelectorType ==	 0 ? "selected" : "" %> value="0"	>* <%= app.getLabel(ACCOUNTSEGMENT_CLASS) %>&nbsp;</option>
<%
										}
%>
										</select>&nbsp;
<%
										if (userSelectorType < 100) {
%>
													<INPUT title="Principal Filter" type="text" name="searchString" id="searchString" tabindex="<%= tabIndex++ %>" value="<%= searchString %>" />
													<INPUT type="hidden" name="previousSearchString" id="previousSearchString" tabindex="<%= tabIndex++ %>" value="<%= searchString %>" />
													<INPUT type="submit" name="go" id="go" title="<%= app.getTexts().getSearchText() %>" tabindex="<%= tabIndex++ %>" value=">>" onclick="setTimeout('disableSubmit()', 10);$('Reload.Button').click();" />
													&nbsp;
													<INPUT title="Membership Filter" type="text" name="membershipString" id="membershipString" tabindex="<%= tabIndex++ %>" value="<%= membershipString %>" />
													<INPUT type="hidden" name="previousMembershipString" id="previousMembershipString" tabindex="<%= tabIndex++ %>" value="<%= membershipString %>" />
													<INPUT type="submit" name="go" id="go" title="<%= app.getTexts().getSearchText() %>" tabindex="<%= tabIndex++ %>" value=">>" onclick="setTimeout('disableSubmit()', 10);$('Reload.Button').click();" />
<%
										} else {
%>
											<INPUT type="text" name="searchString" id="searchString" tabindex="<%= tabIndex++ %>" value="<%= searchString %>" />
											<INPUT type="hidden" name="previousSearchString" id="previousSearchString" tabindex="<%= tabIndex++ %>" value="<%= searchString %>" />
											<INPUT type="submit" name="go" id="go" title="<%= app.getTexts().getSearchText() %>" tabindex="<%= tabIndex++ %>" value=">>" onclick="setTimeout('disableSubmit()', 10);$('Reload.Button').click();" />
<%
										}
%>
									</div>
									<br>
									<a href="#" onclick="javascript:try{$('paging').value='--';}catch(e){};$('Reload.Button').click();" onmouseup="javascript:setTimeout('disableSubmit()', 10);" ><img border="0" align="top" alt="&lt;" src="../../images/previous_fast.gif" style="padding-top:5px;"></a>
									<a href="#" onclick="javascript:try{($('displayStart').value)--;}catch(e){};$('Reload.Button').click();" onmouseup="javascript:setTimeout('disableSubmit()', 10);" ><img border="0" align="top" alt="&lt;" src="../../images/previous.gif" style="padding-top:5px;"></a>
									<span id="displayStartSelector">...</span>
									<a href="#" onclick="javascript:try{($('displayStart').value)++;}catch(e){};$('Reload.Button').click();" onmouseup="javascript:setTimeout('disableSubmit()', 10);" ><img border="0" align="top" alt="&lt;" src="../../images/next.gif" style="padding-top:5px;"></a>
									<a href="#" onclick="javascript:try{$('paging').value='++';}catch(e){};$('Reload.Button').click();" onmouseup="javascript:setTimeout('disableSubmit()', 10);" ><img border="0" align="top" alt="&lt;" src="../../images/next_fast.gif" style="padding-top:5px;"></a>
									&nbsp;&nbsp;&nbsp;
									<select id="pageSize" name="pageSize" style="text-align:right;" onchange="javascript:$('waitMsg').style.visibility='visible';$('submitButtons').style.visibility='hidden';$('isSelectionChange').checked=true;$('Reload.Button').click();" >
										<option <%= pageSize ==	10 ? "selected" : "" %> value="10">10&nbsp;</option>
										<option <%= pageSize ==	20 ? "selected" : "" %> value="20">20&nbsp;</option>
										<option <%= pageSize ==	50 ? "selected" : "" %> value="50">50&nbsp;</option>
										<option <%= pageSize == 100 ? "selected" : "" %> value="100">100&nbsp;</option>
										<option <%= pageSize == 500 ? "selected" : "" %> value="500">500&nbsp;</option>
									</select>
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<!-- <input type="checkbox" name="detectDuplicates" id="detectDuplicates" <%= detectDuplicates ? "checked" : "" %> /> Detect Duplicates -->
									&nbsp;&nbsp;
									<INPUT type="Submit" id="Reload.Button" name="Reload.Button" tabindex="<%= tabIndex++ %>" value="<%= app.getTexts().getReloadText() %>" onmouseup="javascript:setTimeout('disableSubmit()', 10);" />
									<!-- <INPUT type="Submit" id="DetectDuplicates.Button" name="DetectDuplicates.Button" tabindex="<%= tabIndex++ %>" value="Detect Duplicates" onmouseup="javascript:setTimeout('disableSubmit()', 10);" /> -->
									<INPUT type="Button" name="Print.Button" tabindex="<%= tabIndex++ %>" value="Print" onClick="javascript:window.print();return false;" />
									<INPUT type="Submit" name="ACTION.exportXLS" tabindex="<%= tabIndex++ %>" value="Export" onmouseup="javascript:setTimeout('disableSubmit()', 10);" />

<%
									if (downloadAction != null) {
%>
											<span>
												<a href="<%= request.getContextPath() %>/<%= downloadAction.getEncodedHRef(requestId) %>"><%= SPREADSHEET %></a>&nbsp;
											</span>
<%
									}
%>
									<INPUT type="Submit" name="Cancel.Button" tabindex="<%= tabIndex++ %>" value="<%= app.getTexts().getCloseText() %>" onClick="javascript:window.close();" />
									<br>
								</td>
								<td id="waitMsg" style="display:none;">
									<div style="padding-left:5px; padding: 11px 0px 50px 0px;">
										<img src="../../images/wait.gif" alt="" />
									</div>
								</td>
							</tr>
						</table>
<%
						if (errorMsg.length() > 0) {
%>
							<div style="background-color:red;color:white;border:1px solid black;padding:10px;font-weight:bold;margin-top:10px;">
								<%= errorMsg %>
							</div>
<%
						}
%>
				</div> <!-- topnavi -->
			</div> <!-- header -->

			<div id="content-wrap">
				<div id="content" style="padding:20.5em 0.5em 0px 0.5em;">

				<table style="background:white;"><tr><td>
				<table id="resultTable" class="gridTableFull">
					<tr class="gridTableHeaderFull"><!-- 10 columns -->
						<td align="right"><a href="#" onclick="javascript:try{$('paging').value='--';}catch(e){};$('Reload.Button').click();" onmouseup="javascript:setTimeout('disableSubmit()', 10);" ><img border="0" align="top" alt="&lt;" src="../../images/previous_fast.gif"></a>
							<a href="#" onclick="javascript:try{($('displayStart').value)--;}catch(e){};$('Reload.Button').click();" onmouseup="javascript:setTimeout('disableSubmit()', 10);" ><img border="0" align="top" alt="&lt;" src="../../images/previous.gif"></a>
							#
							<a href="#" onclick="javascript:try{($('displayStart').value)++;}catch(e){};$('Reload.Button').click();" onmouseup="javascript:setTimeout('disableSubmit()', 10);" ><img border="0" align="top" alt="&lt;" src="../../images/next.gif"></a>
							<a href="#" onclick="javascript:try{$('paging').value='++';}catch(e){};$('Reload.Button').click();" onmouseup="javascript:setTimeout('disableSubmit()', 10);" ><img border="0" align="top" alt="&lt;" src="../../images/next_fast.gif"></a></td>
						<td align="left">&nbsp;<b><%= app.getLabel(USER_CLASS) %> / <%= app.getLabel(PRINCIPAL_CLASS) %></b></td>
						<td align="left">&nbsp;<b><%= app.getLabel(USERHOME_CLASS) %> / <%= app.getLabel(CONTACT_CLASS) %></b></td>
						<td align="center">&nbsp;<b><%= userView.getFieldLabel(USERHOME_CLASS, "settings", app.getCurrentLocaleAsIndex()) %></b></td>
						<td align="center">&nbsp;<b><%= userView.getFieldLabel(PRINCIPAL_CLASS, "disabled", app.getCurrentLocaleAsIndex()) %></b></td>
						<td align="left" nowrap>
							 <!-- <img src="../../images/NumberReplacement.gif" alt="" align="top" /> -->
							 <!--
							 <INPUT type="submit" name="addvisible"		 id="addvisible"		 title="add/enable visible" tabindex="<%= tabIndex++ %>" value="+"			 onclick="javascript:$('executemulti').style.visibility='visible';$('executemulti').name=this.name;$('disablevisible').style.display='none';$('deletevisible').style.display='none';return false;" onmouseup="this.style.border='3px solid red';" style="font-size:10px;font-weight:bold;" />
							 <INPUT type="submit" name="disablevisible" id="disablevisible" title="disable visible"		tabindex="<%= tabIndex++ %>" value="&ndash;" onclick="javascript:$('executemulti').style.visibility='visible';$('executemulti').name=this.name;$('addvisible').style.display='none';$('deletevisible').style.display='none';return false;"		 onmouseup="this.style.border='3px solid red';" style="font-size:10px;font-weight:bold;" />
							 <INPUT type="submit" name="deletevisible"	id="deletevisible"	title="delete visible"		 tabindex="<%= tabIndex++ %>" value="X"			 onclick="javascript:$('executemulti').style.visibility='visible';$('executemulti').name=this.name;$('addvisible').style.display='none';$('disablevisible').style.display='none';return false;"		onmouseup="this.style.border='3px solid red';" style="font-size:10px;font-weight:bold;" />
							 <INPUT type="submit" name="executemulti"	 id="executemulti"	 title="<%= app.getTexts().getOkTitle() %>" style="visibility:hidden;" tabindex="<%= tabIndex++ %>" value="<%= app.getTexts().getOkTitle() %>" onmouseup="javascript:setTimeout('disableSubmit()', 10);$('addvisible').style.display='none';$('disablevisible').style.display='none';$('deletevisible').style.display='none';this.style.display='none';this.name='ACTION.'+this.name;" style="font-size:10px;font-weight:bold;" /><br>
							 -->
							 <b>&nbsp;<%= app.getLabel(EMAILACCOUNT_CLASS) %></b>
						</td>
						<td align="left" title="<%= app.getLabel(PRINCIPALGROUP_CLASS) %>"><INPUT title="Membership Selector" type="text" name="membershipSelector" id="membershipSelector" tabindex="<%= tabIndex++ %>" value="<%= membershipSelector %>" /></td>
						<td align="left">&nbsp;<b><%= userView.getFieldLabel(USERHOME_CLASS, "primaryGroup", app.getCurrentLocaleAsIndex()) %></b></td>
						<td align="left">&nbsp;<b><%= app.getLabel(ACCOUNTMEMBERSHIP_CLASS) %></b></td>
						<td align="center">&nbsp;<b><%= userView.getFieldLabel(PRINCIPAL_CLASS, "lastLoginAt", app.getCurrentLocaleAsIndex()) %></b></td>
					</tr>
<%
									
					if (users != null) {
							short spreadSheetRow = 1;
							for(
								Iterator i = users;
								i.hasNext() && (counter <= (displayStart+1)*pageSize);
							) {
									org.opencrx.security.realm1.jmi1.Principal principal = (org.opencrx.security.realm1.jmi1.Principal)i.next();
									//
									// get UserHome
									org.opencrx.kernel.home1.jmi1.UserHome userHome = null;
									try {
											userHome = (org.opencrx.kernel.home1.jmi1.UserHome)pm.getObjectById(
													new Path("xri://@openmdx*org.opencrx.kernel.home1/provider/" + providerName + "/segment/" + segmentName + "/userHome/" + principal.getName())
												);
									} catch (Exception e) {
											new ServiceException(e).log();
									}

									String userHomeHref = "";
									Action action = null;
									if (userHome != null) {
											action = new ObjectReference(
													userHome,
													app
											).getSelectObjectAction();
											userHomeHref = "../../" + action.getEncodedHRef();
									}

									String principalHref = "";
									action = new ObjectReference(
											principal,
											app
									).getSelectObjectAction();
									principalHref = "../../" + action.getEncodedHRef();

									org.opencrx.kernel.account1.jmi1.Contact contact = null;
									String contactHref = "";
									if (userHome != null && userHome.getContact() != null) {
											contact = userHome.getContact();
											action = new ObjectReference(
													contact,
													app
											).getSelectObjectAction();
											contactHref = "../../" + action.getEncodedHRef();
									}

									if (!i.hasNext()) {
											highUserIsKnown = true;
											highUser = counter+1;
									}
									counter++;
									if (counter < displayStart*pageSize || counter > (displayStart+1)*pageSize) {
										continue;
									}

									String image = "Principal.gif";
									String label = app.getLabel("org:opencrx:security:realm1:Principal");

									String addressInfo = "";

									boolean currentUserOwnsHome = false;
									Properties userSettings =	new Properties();

									boolean isDisabled = principal != null && principal.isDisabled();

									String fEmailAccount = "";
									if (userHome != null) {
											org.opencrx.kernel.home1.cci2.EMailAccountQuery emailAccountQuery = (org.opencrx.kernel.home1.cci2.EMailAccountQuery)pm.newQuery(org.opencrx.kernel.home1.jmi1.EMailAccount.class);
											emailAccountQuery.thereExistsIsActive().isTrue();
											emailAccountQuery.thereExistsIsDefault().isTrue();
											List<org.opencrx.kernel.home1.jmi1.EMailAccount> emailAccounts = userHome.getEMailAccount(emailAccountQuery);
											org.opencrx.kernel.home1.jmi1.EMailAccount defaultEmailAccount = emailAccounts.isEmpty() ? null : emailAccounts.iterator().next();
											fEmailAccount = (defaultEmailAccount == null || defaultEmailAccount.getName() == null ? "" : defaultEmailAccount.getName());

											currentUserOwnsHome =	app.getCurrentUserRole().equals(userHome.refGetPath().getBase() + "@" + segmentName);
											if(currentUserOwnsHome) {
												userSettings = app.getSettings();
											}
											else if(userHome.getSettings() != null) {
												userSettings.load(
													new ByteArrayInputStream(
														userHome.getSettings().getBytes("UTF-8")
													)
												);
											}
									}
									
									org.opencrx.security.realm1.jmi1.PrincipalGroup primaryGroup = userHome != null ? userHome.getPrimaryGroup() : null;
									boolean isMemberOfPrimaryGroup = primaryGroup != null && principal.getIsMemberOf() != null && principal.getIsMemberOf().contains(primaryGroup);
									
									org.opencrx.security.realm1.jmi1.PrincipalGroup selectedPrincipalGroup = null;
									try {
										selectedPrincipalGroup = (org.opencrx.security.realm1.jmi1.PrincipalGroup)org.opencrx.kernel.backend.SecureObject.getInstance().findPrincipal(
											membershipSelector,
											realm
										);
									} catch (Exception e) {}
									
									boolean isMemberOfSelectedPrincipalGroup = selectedPrincipalGroup != null && principal.getIsMemberOf() != null && principal.getIsMemberOf().contains(selectedPrincipalGroup);
									
									
									Set<String> principalGroups = new TreeSet<String>();
									String isMemberOfPrincipalGroups = "";
														List<org.openmdx.security.realm1.jmi1.Group> groups = principal.getIsMemberOf();
														for(org.openmdx.security.realm1.jmi1.Group group: groups) {
										if(group instanceof org.opencrx.security.realm1.jmi1.PrincipalGroup) {													
											principalGroups.add(group.getName());
										}
									}
									for(String principalGroup: principalGroups) {
											isMemberOfPrincipalGroups += (isMemberOfPrincipalGroups.length() > 0 ? "," : "" ) + principalGroup;
									}

									if (downloadAction != null && sheetPrincipals != null) {
											spreadSheetRow = addPrincipal(sheetPrincipals, principal, userHome, contact, isMemberOfPrincipalGroups, fEmailAccount, spreadSheetRow, wrappedStyle, topAlignedStyle, exceldate, app);
											//spreadSheetRow++;
									}

%>
									<tr class="gridTableRowFull" style="<%= isDisabled ? "background-color:" + (isDisabled ? colorMemberDisabled + ";font-style:italic" : colorMember + ";font-weight:bold") : "" %>;"><!-- 8 columns -->
										<td align="right"><%= formatter.format(counter) %></td>
										<td align="left" <%= "ondblclick='javascript:window.open(\"" + principalHref + "\");'" %> title="<%= label %>"><img src="../../images/<%= image %>" border="0" align="top" alt="o" />&nbsp;<%= (new ObjectReference(principal, app)).getTitle() %></a></td>
										<td align="left"><a href="<%= userHomeHref %>" target="_blank"><%= userHome != null ? (new ObjectReference(userHome, app)).getTitle() : "--" %></a></td>
										<td align="center">
												<INPUT type="submit" name="applyUserSettings" id="applyUserSettings" title="apply user settings - create / update user-specific objects" tabindex="<%= tabIndex++ %>" value="create/update"	onmouseup="javascript:setTimeout('disableSubmit()', 10);this.style.display='none';this.name='ACTION.'+this.name;this.value='<%= principal.refMofId() %>';" style="font-size:10px;font-weight:bold;" />
										</td>
										<td align="center">
<%
										if (!isDisabled) {
												// is enabled principal
%>
												<button type="submit" name="disable" tabindex="<%= tabIndex++ %>" value="&mdash;" onmouseup="javascript:setTimeout('disableSubmit()', 10);this.name='ACTION.'+this.name;this.value='<%= principal.refMofId() %>';" style="border:0; background:transparent;font-size:10px;font-weight:bold;" ><img src="../../images/notchecked.gif" /></button>
											</td>
<%
										} else {
											// disabled
%>
												<button type="submit" name="enable" tabindex="<%= tabIndex++ %>" value="+" onmouseup="javascript:setTimeout('disableSubmit()', 10);this.name='ACTION.'+this.name;this.value='<%= principal.refMofId() %>';" style="border:0; background:transparent;font-size:10px;font-weight:bold;" ><img src="../../images/checked.gif" /></button>
<%
										}
%>
										</td>
										<td align="left" <%= "ondblclick='javascript:window.open(\"" + userHomeHref + "\");'" %>><%= fEmailAccount %></td>
										<td align="left">&nbsp;&nbsp;
<%
											if (selectedPrincipalGroup == null) {
%>
												<%= membershipSelector != null && membershipSelector.length() > 0 ? MISSING : "" %>
<%
											} else {
													if (!isMemberOfSelectedPrincipalGroup) {
%>
															<button type="submit" name="addMembership" tabindex="<%= tabIndex++ %>" value="&mdash;" onmouseup="javascript:setTimeout('disableSubmit()', 10);this.name='ACTION.'+this.name;this.value='<%= principal.refMofId() %>';" style="border:0; background:transparent;font-size:10px;font-weight:bold;" ><img src="../../images/notchecked.gif" /></button>
<%
													} else {
%>
															<button type="submit" name="removeMembership" tabindex="<%= tabIndex++ %>" value="+" onmouseup="javascript:setTimeout('disableSubmit()', 10);this.name='ACTION.'+this.name;this.value='<%= principal.refMofId() %>';" style="border:0; background:transparent;font-size:10px;font-weight:bold;" ><img src="../../images/checked.gif" /></button>
<%
													}
											}
%>
										</td>
										<td align="left" <%= "ondblclick='javascript:window.open(\"" + principalHref + "\");'" %>><%= isMemberOfPrimaryGroup ? CHECKED_R : NOTCHECKED_R %> <%= primaryGroup != null && primaryGroup.getName() != null ? primaryGroup.getName() : "--" %></td>
										<td align="left" <%= "ondblclick='javascript:window.open(\"" + userHomeHref + "\");'" %>><%= isMemberOfPrincipalGroups %></td>
										<td align="left" <%= "ondblclick='javascript:window.open(\"" + principalHref + "\");'" %>><%= principal.getLastLoginAt() != null ? timeFormat.format(principal.getLastLoginAt()) : "--" %></td>
									</tr>
<%
							}
					}
%>
					<tr class="gridTableHeaderFull"><!-- 10 columns -->
						<td align="right"><a href="#" onclick="javascript:try{$('paging').value='--';}catch(e){};$('Reload.Button').click();" onmouseup="javascript:setTimeout('disableSubmit()', 10);" ><img border="0" align="top" alt="&lt;" src="../../images/previous_fast.gif"></a>
							<a href="#" onclick="javascript:try{($('displayStart').value)--}catch(e){};$('Reload.Button').click();"><img border="0" align="top" alt="&lt;" src="../../images/previous.gif"></a>
							#
							<a href="#" onclick="javascript:try{($('displayStart').value)++}catch(e){};$('Reload.Button').click();"><img border="0" align="top" alt="&lt;" src="../../images/next.gif"></a>
							<a href="#" onclick="javascript:try{$('paging').value='++';}catch(e){};$('Reload.Button').click();" onmouseup="javascript:setTimeout('disableSubmit()', 10);" ><img border="0" align="top" alt="&lt;" src="../../images/next_fast.gif"></a></td>
						<td align="left">&nbsp;<b><%= app.getLabel(USER_CLASS) %> / <%= app.getLabel(PRINCIPAL_CLASS) %></b></td>
						<td align="left">&nbsp;<b><%= app.getLabel(USERHOME_CLASS) %> / <%= app.getLabel(CONTACT_CLASS) %></b></td>
						<td align="center">&nbsp;<b><%= userView.getFieldLabel(USERHOME_CLASS, "settings", app.getCurrentLocaleAsIndex()) %></b></td>
						<td align="center">&nbsp;<b><%= userView.getFieldLabel(PRINCIPAL_CLASS, "disabled", app.getCurrentLocaleAsIndex()) %></b></td>
						<td align="left" nowrap><b>&nbsp;<%= app.getLabel(EMAILACCOUNT_CLASS) %></b></td>
						<td align="left" title="<%= app.getLabel(PRINCIPALGROUP_CLASS) %>"><b>&nbsp;<%= membershipSelector != null ? membershipSelector : "" %></b></td>
						<td align="left">&nbsp;<b><%= userView.getFieldLabel(USERHOME_CLASS, "primaryGroup", app.getCurrentLocaleAsIndex()) %></b></td>
						<td align="left">&nbsp;<b><%= app.getLabel(ACCOUNTMEMBERSHIP_CLASS) %></b></td>
						<td align="center">&nbsp;<b><%= userView.getFieldLabel(PRINCIPAL_CLASS, "lastLoginAt", app.getCurrentLocaleAsIndex()) %></b></td>
					</tr>
				</table>
				</td></tr></table>
<%
				if (!highUserIsKnown && (counter-1 > highUser)) {
					highUser = counter-1;
				}
%>
				<input type="hidden" name="highUserIsKnown" id="highUserIsKnown" value="<%= highUserIsKnown ? "highUserIsKnown" : ""	%>" />
				<input type="hidden" id="highUser" name="highUser" value="<%= highUser %>" />
<%
			String displayStartSelector = "<select onchange='javascript:$(\\\"waitMsg\\\").style.visibility=\\\"visible\\\";$(\\\"submitButtons\\\").style.visibility=\\\"hidden\\\";$(\\\"Reload.Button\\\").click();' id='displayStart' name='displayStart' tabindex='" + tabIndex++ + "' style='text-align:right;'>";
			int i = 0;
			while (i*pageSize < highUser) {
				displayStartSelector += "<option " + (i == displayStart ? "selected" : "") + " value='" + formatter.format(i) + "'>" + formatter.format(pageSize*i + 1) + ".." + formatter.format(highUser < pageSize*(i+1) ? highUser : (pageSize*(i+1))) + "&nbsp;</option>";
				i++;
			}
			if (!highUserIsKnown) {
				displayStartSelector += "<option value='" + formatter.format(i) + "'>" + formatter.format(pageSize*i + 1) + ".." + formatter.format(pageSize*(i+1)) + "&nbsp;</option>";
				displayStartSelector += "<option value='+100'>+100&nbsp;</option>";
				displayStartSelector += "<option value='+500'>+500&nbsp;</option>";
				displayStartSelector += "<option value='+1000'>+1000&nbsp;</option>";
				displayStartSelector += "<option value='+5000'>+5000&nbsp;</option>";
				displayStartSelector += "<option value='+10000'>+10000&nbsp;</option>";
				displayStartSelector += "<option value='+50000'>+50000&nbsp;</option>";
				displayStartSelector += "<option value='+100000'>+100000&nbsp;</option>";
				displayStartSelector += "<option value='+500000'>+500000&nbsp;</option>";
			}
			displayStartSelector += "</select>";
%>
			<script language='javascript' type='text/javascript'>
				try {
					$('displayStartSelector').innerHTML = "<%= displayStartSelector %>";
					$('highUser').value = "<%= formatter.format(highUser) %>";
					$('submitButtons').style.visibility='visible';
				} catch(e){};

				function disableSubmit() {
					$('waitMsg').style.display='block';
					$('submitButtons').style.display='none';
				}
			</script>
			<br />
			<INPUT type="Button" name="Print.Button" tabindex="<%= tabIndex++ %>" value="Print" onClick="javascript:window.print();return false;" />
			<INPUT type="Submit" name="Cancel.Button" tabindex="<%= tabIndex++ %>" value="<%= app.getTexts().getCloseText() %>" onClick="javascript:window.close();" />
			<br />&nbsp;
<%
			if (downloadAction != null) {
					wb.write(os);
					os.flush();
					os.close();
			}

		}
		catch (Exception e) {
			new ServiceException(e).log();
			out.println("<p><b>!! Failed !!<br><br>The following exception(s) occured:</b><br><br><pre>");
			PrintWriter pw = new PrintWriter(out);
			ServiceException e0 = new ServiceException(e);
			pw.println(e0.getMessage());
			pw.println(e0.getCause());
			out.println("</pre>");
		} finally {
			if(pm != null) {
				pm.close();
			}
		}
%>
			</div> <!-- content -->
		</div> <!-- content-wrap -->
		</form>
	</div> <!-- wrap -->
</div> <!-- container -->
</body>
</html>
