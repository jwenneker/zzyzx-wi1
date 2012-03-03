<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: ActivityProcessExportWizard.jsp,v 1.2 2011/06/30 22:28:44 wfro Exp $
 * Description: ExportActivityProcess
 * Revision:    $Revision: 1.2 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/06/30 22:28:44 $
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
%>
<%@ page session="true" import="
java.util.*,
java.io.*,
java.net.*,
java.math.*,
java.sql.*,
java.text.*,
javax.net.ssl.*,
javax.naming.Context,
javax.naming.InitialContext,
javax.xml.transform.stream.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.base.exception.*,
org.openmdx.kernel.id.cci.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*,
org.openmdx.kernel.log.*,
org.openmdx.kernel.id.*,
org.openmdx.kernel.exception.*,
org.openmdx.base.text.conversion.*,
org.opencrx.kernel.backend.*,
org.opencrx.application.airsync.utils.*,
org.opencrx.application.airsync.datatypes.*
"%>
<%
	request.setCharacterEncoding("UTF-8");
	String servletPath = "." + request.getServletPath();
	String servletPathPrefix = servletPath.substring(0, servletPath.lastIndexOf("/") + 1);
	ApplicationContext app = (ApplicationContext)session.getValue(WebKeys.APPLICATION_KEY);
	// ViewsCache viewsCache = (ViewsCache)session.getValue(WebKeys.VIEW_CACHE_KEY_SHOW);
	// String requestId =  request.getParameter(Action.PARAMETER_REQUEST_ID);
	// requestId is optional and may not be provided be external invokers
	String objectXri = request.getParameter(Action.PARAMETER_OBJECTXRI);
	if(objectXri == null || app == null /* || viewsCache.getView(requestId) == null */) {
		response.sendRedirect(
			request.getContextPath() + "/" + WebKeys.SERVLET_NAME
		);
		return;
	}
	javax.jdo.PersistenceManager pm = app.getNewPmData();
	RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
	if(!(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityProcess)) {
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}
	org.opencrx.kernel.activity1.jmi1.ActivityProcess activityProcess = (org.opencrx.kernel.activity1.jmi1.ActivityProcess)obj;
%>
<!--
	<meta name="label" content="State Chart XML - Export Activity Process">
	<meta name="toolTip" content="State Chart XML - Export Activity Process">
	<meta name="targetType" content="_self">
	<meta name="forClass" content="org:opencrx:kernel:activity1:ActivityProcess">
	<meta name="order" content="20">
-->
<%
	String xml = Activities.getInstance().exportActivityProcessToScXml(activityProcess);
    response.setContentType("text/xml");
    response.setHeader("Content-disposition", "attachment;filename=" + activityProcess.getName() + ".scxml");            
    OutputStream os = response.getOutputStream();
    byte[] xmlBytes = xml.getBytes("UTF-8");
    for(int i = 0; i < xmlBytes.length; i++) {
        os.write(xmlBytes[i]);
    }
    response.setContentLength(xmlBytes.length);
    os.close();
   	if(pm != null) {
   		pm.close();
   	}
%>
