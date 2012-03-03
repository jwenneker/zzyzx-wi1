<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: AirSyncResyncReplaceItemsOnServer.jsp,v 1.1 2010/06/28 10:16:32 wfro Exp $
 * Description: AirSyncSyncWizard
 * Revision:    $Revision: 1.1 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2010/06/28 10:16:32 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2010, CRIXP Corp., Switzerland
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
	if(!(obj instanceof org.opencrx.kernel.home1.jmi1.SyncFeed)) {
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}
	org.opencrx.kernel.home1.jmi1.SyncFeed syncFeed = (org.opencrx.kernel.home1.jmi1.SyncFeed)obj;
%>
<!--
	<meta name="label" content="Resync - Replace all items on the server">
	<meta name="toolTip" content="Resync - Replace all items on the server">
	<meta name="targetType" content="_self">
	<meta name="forClass" content="org:opencrx:kernel:home1:SyncFeed">
-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head></head>
  <body>
<%
    try {
    	org.opencrx.application.airsync.backend.cci.SyncBackend syncBackend = 
    		new org.opencrx.application.airsync.backend.impl.OpenCrxSyncBackend(
    			pm.getPersistenceManagerFactory(),
    			syncFeed.refGetPath().get(2)
    		);
    	org.opencrx.application.airsync.backend.impl.DatatypeMapper datatypeMapper = 
    		new org.opencrx.application.airsync.backend.impl.DatatypeMapper();
    	org.opencrx.kernel.home1.jmi1.UserHome userHome = 
    		UserHomes.getInstance().getUserHome(syncFeed.refGetPath(), pm);
    	org.opencrx.kernel.home1.jmi1.AirSyncClientProfile syncProfile = 
    		(org.opencrx.kernel.home1.jmi1.AirSyncClientProfile)pm.getObjectById(
    			syncFeed.refGetPath().getPrefix(9)
    		);
    	org.opencrx.application.airsync.backend.cci.SyncBackend.RequestContext requestContext = 
    		syncBackend.newRequestContext(
	   			syncProfile.refGetPath().get(4) + org.opencrx.application.airsync.backend.cci.SyncBackend.DOMAIN_SEPARATOR + userHome.refGetPath().getBase(),
	   			null
	   		);
    	org.opencrx.application.airsync.backend.cci.ClientProfile clientProfile = 
    		syncBackend.getClientProfile(
	    		requestContext,
	    		syncProfile.getName()
	    	);
    	if(clientProfile != null) {
        	Set<String> folderIds = new HashSet<String>();
    		for(org.opencrx.application.airsync.backend.cci.ClientProfile.Folder folder: clientProfile.getFolders()) {
    			String folderId = datatypeMapper.toObjectId(syncFeed);
    			if(folderId.equals(folder.getClientId())) {
    				folder.setSyncKeyClient(null);
    				folderIds.add(folderId);
    				break;
    			}
    		}
			syncBackend.updateClientProfile(
				requestContext,
				clientProfile,
				folderIds,
				false, // noSyncKeys
				true // noMappings
			);
    	}
    } catch (Exception e) {
        new ServiceException(e).log();
    } finally {
    }
   	Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
   	response.sendRedirect(
   		request.getContextPath() + "/" + nextAction.getEncodedHRef()
   	);
   	if(pm != null) {
   		pm.close();
   	}
%>
  </body>
</html>
