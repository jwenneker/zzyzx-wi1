<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     opencrx, http://www.opencrx.org/
 * Name:        $Id: EnableCrxObject.jsp,v 1.2 2010/04/27 12:16:10 wfro Exp $
 * Description: disable account, composites like addresses, and members referencing account
 * Revision:    $Revision: 1.2 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2010/04/27 12:16:10 $
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
%><%@ page session="true" import="
java.util.*,
java.io.*,
java.text.*,
java.net.*,
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
" %><%
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
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html dir="<%= texts.getDir() %>">
<head>
  <title><%= app.getApplicationName() + " - Enable " + (new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getTitle() + ((new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getTitle().length() == 0 ? "" : " - ") + (new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getLabel() %></title>
  <meta name="UNUSEDlabel" content="Enable">
  <meta name="UNUSEDtoolTip" content="Enable">
  <meta name="targetType" content="_self">
  <meta name="forClass" content="org:opencrx:kernel:generic:CrxObject">
  <meta name="order" content="org:opencrx:kernel:generic:CrxObject:enable">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <link href="../../_style/colors.css" rel="stylesheet" type="text/css">
  <link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
  <link rel='shortcut icon' href='../../images/favicon.ico' />
</head>

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
<%
	try {
	    // forward to wizard DisableCrxObject with parameter disable=false
	    String formAction = "DisableCrxObject.jsp";
	    String disableAction = "wizards/en_US/" + formAction;
	    // redirect to wizard DisableCrxObject
	    response.sendRedirect(
	      request.getContextPath() + "/" + disableAction + "?xri=" + URLEncoder.encode(request.getParameter("xri"), "UTF-8") + "&" + requestIdParam + "&disable=false"
	    );
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
  </form>

      </div> <!-- content -->
    </div> <!-- content-wrap -->
  </div> <!-- wrap -->
</div> <!-- container -->

</body>
</html>
