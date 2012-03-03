<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:	 openCRX/Core, http://www.opencrx.org/
 * Name:		$Id: SetReminderOnCrxObject.jsp,v 1.2 2012/01/04 13:32:20 wfro Exp $
 * Description: Set reminder on CrxObject
 * Revision:	$Revision: 1.2 $
 * Owner:	   CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:		$Date: 2012/01/04 13:32:20 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2012, CRIXP Corp., Switzerland
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
org.opencrx.kernel.utils.*,
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
org.openmdx.kernel.exception.BasicException,
org.openmdx.kernel.id.*
" %>
<%!

	public static java.util.Date incDate(
		java.util.Date date,
		int numberOfMinutes,
		ApplicationContext app
	) {
		GregorianCalendar cal = new GregorianCalendar(app.getCurrentLocale());
		cal.setTimeZone(TimeZone.getTimeZone(app.getCurrentTimeZone()));
		cal.setMinimalDaysInFirstWeek(4); // this conforms to DIN 1355/ISO 8601
		cal.setFirstDayOfWeek(GregorianCalendar.MONDAY);
		cal.setTime(date);
		cal.add(GregorianCalendar.MINUTE, numberOfMinutes);
		return cal.getTime();
	}

%>
<%
	request.setCharacterEncoding("UTF-8");
	ApplicationContext app = (ApplicationContext)session.getValue(WebKeys.APPLICATION_KEY);
	ViewsCache viewsCache = (ViewsCache)session.getValue(WebKeys.VIEW_CACHE_KEY_SHOW);
	String requestId =  request.getParameter(Action.PARAMETER_REQUEST_ID);
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
	
	final String REMINDER_CLASS = "org:opencrx:kernel:home1:Reminder";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html dir="<%= texts.getDir() %>">
<head>
	<title><%= app.getApplicationName() + " - Set Reminder " + (new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getTitle() + ((new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getTitle().length() == 0 ? "" : " - ") + (new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getLabel() %></title>
	<meta name="UNUSEDlabel" content="Set Reminder">
	<meta name="UNUSEDtoolTip" content="Set Reminder">
	<meta name="targetType" content="_self">
	<meta name="forClass" content="org:opencrx:kernel:generic:CrxObject">
	<meta name="order" content="org:opencrx:kernel:generic:CrxObject:setReminder">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<link href="../../_style/colors.css" rel="stylesheet" type="text/css">
	<link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
	<link href="../../_style/calendar-small.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="../../javascript/portal-all.js"></script>
	<!--[if lt IE 7]><script type="text/javascript" src="../../javascript/iehover-fix.js"></script><![endif]-->
	<script type="text/javascript" src="../../javascript/calendar/lang/calendar-<%= app.getCurrentLocaleAsString() %>.js"></script>
	<link rel='shortcut icon' href='../../images/favicon.ico' />
	<script language="javascript" type="text/javascript">
		function timeTick(dd_mm_yyyy_hh_dd, upMins) {
			var right_now = new Date();
	  		var dateTime = dd_mm_yyyy_hh_dd.split(" ");
	  		var hrs = right_now.getHours();
	  		var mins = right_now.getMinutes();
	  		try {
				dateStr = dateTime[0];
				timeStr = dateTime[1].split(":");
				hrsStr = timeStr[0];
				minsStr = timeStr[1];
	  		} catch (e) {}
	  		try {
				hrs = parseInt(hrsStr, 10);
	  		} catch (e) {}
	  		if (isNaN(hrs)) {hrs=12;}
	  		try {
				mins = parseInt(minsStr, 10);
				mins = parseInt(mins/15, 10)*15;
	  		} catch (e) {}
	  		if (isNaN(mins)) {mins=00;}
	  		mins = hrs*60 + mins + upMins;
	  		while (mins < 0) {mins += 24*60;}
	  		while (mins >= 24*60) {mins -= 24*60;}
	  		hrs = parseInt(mins/60, 10);
	  		if (hrs < 10) {
				hrsStr = "0" + hrs;
	  		} else {
				hrsStr = hrs;
	  		}
	  		mins -= hrs*60;
	  		if (mins < 10) {
				minsStr = "0" + mins;
	  		} else {
				minsStr = mins;
	  		}
	  		if (dateStr.length < 10) {
				dateStr = ((right_now.getDate() < 10) ? "0" : "") + right_now.getDate() + "-" + ((right_now.getMonth() < 9) ? "0" : "") + (right_now.getMonth()+1) + "-" + right_now.getFullYear();
	  		}
			return dateStr + " " + hrsStr + ":" + minsStr;
		}
	</script>
</head>
<body>
<div id="container">
	<div id="wrap">
		<div id="header" style="height:150px;">
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
			<div id="etitle" style="height:20px;padding-left:12px;">
			   <%= app.getLabel(REMINDER_CLASS) %>
			</div>
		</div>
		<div id="content-wrap">
			<div id="content" style="padding:150px 0.5em 0px 0.5em;">
<%
				try {
					Path objectPath = new Path(objectXri);
					RefObject_1_0 refObj = (RefObject_1_0)pm.getObjectById(objectPath);
					final String providerName = objectPath.get(2);
					final String segmentName = objectPath.get(4);
					UserDefinedView userView = new UserDefinedView(
						pm.getObjectById(new Path(objectXri)),
						app,
						viewsCache.getView(requestId)
					);
					boolean actionOk = request.getParameter("OK.Button") != null;
					boolean actionCancel = request.getParameter("Cancel.Button") != null;
					boolean actionContinue = request.getParameter("Continue.Button") != null;		
					String name = request.getParameter("name") == null ? app.getLabel(REMINDER_CLASS) + " (" + app.getLoginPrincipal() + ")" : request.getParameter("name");
					// parse Date triggerAtDate DD-MM-YYYY HH:MM
					boolean triggerAtDateOk = false;
					SimpleDateFormat activityDateFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm", app.getCurrentLocale());
					java.util.Date proposedTriggerAt = incDate(new java.util.Date(), 15, app);
					if(refObj instanceof org.opencrx.kernel.activity1.jmi1.Activity) {
						org.opencrx.kernel.activity1.jmi1.Activity activity = (org.opencrx.kernel.activity1.jmi1.Activity)refObj;
						if (activity.getScheduledStart() != null) {
							proposedTriggerAt = incDate(activity.getScheduledStart(), -15, app);
							if (proposedTriggerAt.compareTo(new java.util.Date()) < 0) {
								incDate(new java.util.Date(), 15, app);
							}
						}
					}
					String triggerAt = request.getParameter("triggerAt") == null ? activityDateFormat.format(proposedTriggerAt)	: request.getParameter("triggerAt");
					java.util.Date triggerAtDate = null;
					try {
				  		if ((triggerAt != null) && (triggerAt.length() == 16)) {
							triggerAtDate = new java.util.Date();
							triggerAtDate.setYear(Integer.parseInt(triggerAt.substring(6,10))-1900);
							triggerAtDate.setMonth(Integer.parseInt(triggerAt.substring(3,5))-1);
							triggerAtDate.setDate(Integer.parseInt(triggerAt.substring(0,2)));
							triggerAtDate.setHours(Integer.parseInt(triggerAt.substring(11,13)));
							triggerAtDate.setMinutes(Integer.parseInt(triggerAt.substring(14,16)));
							triggerAtDate.setSeconds(0);
							triggerAtDateOk = true;
						}
					} catch (Exception e) {}		
			  		boolean currentUserIsAdmin =
			  			app.getCurrentUserRole().equals(org.opencrx.kernel.generic.SecurityKeys.ADMIN_PRINCIPAL + org.opencrx.kernel.generic.SecurityKeys.ID_SEPARATOR + segmentName + "@" + segmentName);
					final String currentUserRole = app.getCurrentUserRole();
					boolean permissionOk = true; //currentUserIsAdmin;
					boolean triggerAtIsInTheFuture = triggerAtDateOk && triggerAtDate.compareTo(new java.util.Date()) > 0;
%>
					<form name="setReminder" accept-charset="utf-8" method="post" action="SetReminderOnCrxObject.jsp">
			  			<input type="hidden" class="valueL" name="xri" value="<%= objectXri %>" />
			  			<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
<%
	  					if(
	  						permissionOk && 
	  						actionOk && 
	  						triggerAtDateOk && name != null && 
	  						!name.isEmpty() && 
	  						triggerAtIsInTheFuture
	  					) {
							try {
				  				pm.currentTransaction().begin();
				  				org.opencrx.kernel.home1.jmi1.UserHome currentUserHome = org.opencrx.kernel.backend.UserHomes.getInstance().getUserHome(objectPath, pm, true);		  
								org.opencrx.kernel.home1.jmi1.Reminder reminder = org.opencrx.kernel.utils.Utils.getHomePackage(pm).getReminder().createReminder();
								reminder.refInitialize(false, false);
								reminder.setName(name);
								reminder.setTriggerAt(triggerAtDate);
								reminder.setTriggerAction(new Short((short)20)); // display
								reminder.setAlarmRepeat(1);
								reminder.setAlarmIntervalMinutes(1);
								reminder.setDisabled(false);
								reminder.setReminderState(new Short((short)10)); // open
								reminder.setAutocalcTriggerAt(true);
								reminder.setTriggerEndAt(incDate(triggerAtDate, 1, app));
								reminder.setReference((org.openmdx.base.jmi1.BasicObject)refObj);
								currentUserHome.addReminder(
									false,
									org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
									reminder
								);
				  				pm.currentTransaction().commit();
								// Go back to previous view
								Action action = new ObjectReference(refObj, app).getSelectObjectAction();
								response.sendRedirect(
									request.getContextPath() + "/" + action.getEncodedHRef()
								);
							}
							catch(Exception e) {
%>
								<br><br>
								<input type="Submit" name="Cancel.Button" tabindex="2010" value=">>" />
<%
								try {
									pm.currentTransaction().rollback();
								} catch(Exception e1) {}
								new ServiceException(e).log();
							}
						}
			  			else {
							if (actionContinue || actionCancel) {
								// Go back to previous view
								Action nextAction = new ObjectReference(refObj, app).getSelectObjectAction();
								response.sendRedirect(
									request.getContextPath() + "/" + nextAction.getEncodedHRef()
								);
								return;
							}
							else {
								if (permissionOk) {
									try {
%>
										<table cellspacing="8" class="tableLayout">
											<tr>
												<td class="cellObject">
											  		<fieldset>
<%
														if (!triggerAtIsInTheFuture) {
%>
															<div style="background-color:red;color:white;border:1px solid black;padding:10px;font-weight:bold;margin-top:10px;">
																Reminder is in the past
															</div>
<%
														}
%>
												  		<table class="fieldGroup">
															<tr>
													  			<td class="label">
																	<span class="nw"><%= userView.getFieldLabel(REMINDER_CLASS, "name", app.getCurrentLocaleAsIndex()) %>:</span>
																</td>
																<td>
																	<input type="text" class="valueL lightUp" name="name" id="name" maxlength="50" tabindex="200" value="<%= name.replaceAll("\"", "&quot;") %>" />
																</td>
																<td class="addon"></td>
																<td class="label">
																	<span class="nw"><%= userView.getFieldLabel(REMINDER_CLASS, "triggerAt", app.getCurrentLocaleAsIndex()) %>:</span>
																</td>
																<td style="padding-top:2px;">
																	<input type="text" class="valueL <%= triggerAtDateOk ? "lightUp" : "valueError" %>" name="triggerAt" id="triggerAt" maxlength="16" tabindex="800" value="<%= triggerAt %>" />
																</td>
																<td class="addon">
																	<a><img class="popUpButton" id="cal_trigger_triggerAt" border="0" alt="Click to open Calendar" src="../../images/cal.gif" /></a>
																	<script language="javascript" type="text/javascript">
																		  Calendar.setup({
																			inputField   : "triggerAt",
																			ifFormat	 : "%d-%m-%Y %H:%M",
																			timeFormat   : "24",
																			button	   : "cal_trigger_triggerAt",
																			align		: "Tr",
																			singleClick  : true,
																			showsTime	: true
																		  });
																	</script>
																	<img class="popUpButton" border="0" title="-15 Min. / aktuelle Zeit" alt="" src="../../images/arrow_smallleft.gif" onclick="javascript:$('triggerAt').value = timeTick($('triggerAt').value, -15);$('triggerAt').className='valueL lightUp';" /><img class="popUpButton" border="0"  title="+15 Min. / aktuelle Zeit" alt="" src="../../images/arrow_smallright.gif" onclick="javascript:$('triggerAt').value = timeTick($('triggerAt').value, 15);$('triggerAt').className='valueL lightUp';" />
																</td>
															</tr>
														</table>
													</fieldset>
												</td>
											</tr>
										</table>
										<input type="Submit" name="OK.Button" tabindex="2000" value="<%= app.getTexts().getOkTitle() %>" />
										<input type="Submit" name="Cancel.Button" tabindex="2000" value="<%= app.getTexts().getCancelTitle() %>" />
<%
									} catch (Exception e) {
										new ServiceException(e).log();
									}
								}
								else {
%>
									<h1><font color="red">No Permission</font></h1>
									<br />
									<br />
									<input type="Submit" name="Cancel.Button" tabindex="2010" value="<%= app.getTexts().getCancelTitle() %>" />
<%
								}
							}
						}
%>
					</form>
<%
				}
				catch (Exception e) {
					ServiceException e0 = new ServiceException(e);
					e0.log();
					out.println("<p><b>!! Failed !!<br><br>The following exception(s) occured:</b><br><br><pre>");
					PrintWriter pw = new PrintWriter(out);
					e0.printStackTrace(pw);
					out.println("</pre></p>");
				}
%>
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
