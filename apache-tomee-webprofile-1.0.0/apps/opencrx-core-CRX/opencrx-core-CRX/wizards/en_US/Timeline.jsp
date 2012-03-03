<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     opencrx, http://www.opencrx.org/
 * Name:        $Id: Timeline.jsp,v 1.22 2010/04/27 12:16:10 wfro Exp $
 * Description: launch timeline (based on http://simile.mit.edu/timeline/)
 * Revision:    $Revision: 1.22 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2010/04/27 12:16:10 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2007-2009, CRIXP Corp., Switzerland
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
java.net.*,
java.text.*,
org.openmdx.base.naming.*,
org.openmdx.base.query.*,
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
	Texts_1_0 texts = app.getTexts();
	javax.jdo.PersistenceManager pm = app.getNewPmData();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html dir="<%= texts.getDir() %>">
<head>
  <title><%= app.getApplicationName() %> - Timeline Launcher</title>
  <meta name="label" content="Timeline">
  <meta name="toolTip" content="Timeline">
  <meta name="targetType" content="_blank">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityTracker">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityCategory">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityMilestone">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityFilterGlobal">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityFilterGroup">
  <meta name="forClass" content="org:opencrx:kernel:activity1:Resource">
  <meta name="forClass" content="org:opencrx:kernel:home1:UserHome">
  <!-- calendars based on contacts -->
  <meta name="forClass" content="org:opencrx:kernel:account1:AccountFilterGlobal"> <!-- bday -->
  <meta name="order" content="5999">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <link rel='shortcut icon' href='../../images/favicon.ico' />
</head>
<body>
<%
	try {
    RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
    Path objectPath = obj.refGetPath();
    String providerName = objectPath.get(2);
    String segmentName = objectPath.get(4);

    String urlBase = (request.getRequestURL().toString()).substring(0, (request.getRequestURL().toString()).indexOf(request.getServletPath().toString()));
    String groupComponent = "";
    String filterComponent = "";

    // activity filter
    if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup) {
      org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup activityFilterGroup =
        (org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup)obj;
      if ((activityFilterGroup.getName() != null) && (activityFilterGroup.getName().length() > 0)) {
        filterComponent = "/filter/" + URLEncoder.encode(activityFilterGroup.getName(), "UTF-8");
      }
      // set obj to parent object
      obj = (RefObject_1_0)pm.getObjectById(new Path(activityFilterGroup.refMofId()).getParent().getParent());
    }
    else if (obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal) {
      org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal activityFilterGlobal =
        (org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal)obj;
      if ((activityFilterGlobal.getName() != null) && (activityFilterGlobal.getName().length() > 0)) {
        filterComponent = "/globalfilter/" + URLEncoder.encode(activityFilterGlobal.getName(), "UTF-8");
      }
    }
    // activity group
    if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityTracker) {
      org.opencrx.kernel.activity1.jmi1.ActivityTracker activityTracker =
        (org.opencrx.kernel.activity1.jmi1.ActivityTracker)obj;
      if ((activityTracker.getName() != null) && (activityTracker.getName().length() > 0)) {
        groupComponent = "/tracker/" + URLEncoder.encode(activityTracker.getName(), "UTF-8");
      }
    }
    else if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityCategory) {
      org.opencrx.kernel.activity1.jmi1.ActivityCategory activityCategory =
        (org.opencrx.kernel.activity1.jmi1.ActivityCategory)obj;
      if ((activityCategory.getName() != null) && (activityCategory.getName().length() > 0)) {
        groupComponent = "/category/" + URLEncoder.encode(activityCategory.getName(), "UTF-8");
      }
    }
    else if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityMilestone) {
      org.opencrx.kernel.activity1.jmi1.ActivityMilestone activityMilestone =
        (org.opencrx.kernel.activity1.jmi1.ActivityMilestone)obj;
      if ((activityMilestone.getName() != null) && (activityMilestone.getName().length() > 0)) {
        groupComponent = "/milestone/" + URLEncoder.encode(activityMilestone.getName(), "UTF-8");
      }
    }
    else if(obj instanceof org.opencrx.kernel.activity1.jmi1.Resource) {
      org.opencrx.kernel.activity1.jmi1.Resource resource =
        (org.opencrx.kernel.activity1.jmi1.Resource)obj;
      if ((resource.getName() != null) && (resource.getName().length() > 0)) {
        groupComponent = "/resource/" + URLEncoder.encode(resource.getName(), "UTF-8");
      }
    }
    else if(obj instanceof org.opencrx.kernel.home1.jmi1.UserHome) {
      groupComponent = "/userhome/" + URLEncoder.encode(obj.refGetPath().getBase(), "UTF-8");
    }
    else if (obj instanceof org.opencrx.kernel.account1.jmi1.AccountFilterGlobal) {
        org.opencrx.kernel.account1.jmi1.AccountFilterGlobal accountFilterGlobal =
          (org.opencrx.kernel.account1.jmi1.AccountFilterGlobal)obj;
        if ((accountFilterGlobal.getName() != null) && (accountFilterGlobal.getName().length() > 0)) {
          filterComponent = "/filter/" + URLEncoder.encode(accountFilterGlobal.getName(), "UTF-8");
        }
    }

    if ((groupComponent.length() > 0) || (filterComponent.length() > 0)) {
		String target =
			request.getContextPath().replace("-core-", "-ical-") + "/" +
			(obj instanceof org.opencrx.kernel.account1.jmi1.AccountFilterGlobal ? "bdays" : "ical") + "?id=" +
			providerName + "/" + segmentName +
			groupComponent + filterComponent +
			"&resource=activities.html&user.locale=" + URLEncoder.encode(app.getCurrentLocaleAsString()) + "&user.tz=" + URLEncoder.encode(app.getCurrentTimeZone());
%>
      <a href="<%= target %>" target="_blank"><%= target %></a>
<%
      response.sendRedirect(target);
    } else {
%>
      <p>cannot call timeline for xri<br><%= obj.refMofId() %></p>
      <p>possible reasons include
      <ul>
        <li>name is empty</li>
        <li>name contains blanks</li>
      </ul>
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
</body>
</html>
