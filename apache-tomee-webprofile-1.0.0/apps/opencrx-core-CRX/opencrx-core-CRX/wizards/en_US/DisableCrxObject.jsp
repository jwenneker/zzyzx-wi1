<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     opencrx, http://www.opencrx.org/
 * Name:        $Id: DisableCrxObject.jsp,v 1.4 2010/04/27 12:16:11 wfro Exp $
 * Description: disable account, composites like addresses, and members referencing account
 * Revision:    $Revision: 1.4 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2010/04/27 12:16:11 $
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
  <title><%= app.getApplicationName() + " - Disable " + (new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getTitle() + ((new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getTitle().length() == 0 ? "" : " - ") + (new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getLabel() %></title>
  <meta name="UNUSEDlabel" content="Disable">
  <meta name="UNUSEDtoolTip" content="Disable">
  <meta name="targetType" content="_self">
  <meta name="forClass" content="org:opencrx:kernel:generic:CrxObject">
  <meta name="order" content="org:opencrx:kernel:generic:CrxObject:disable">
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
    // openCRX object requests

		boolean actionOk = request.getParameter("OK.Button") != null;
		boolean actionCancel = request.getParameter("Cancel.Button") != null;
		boolean actionContinue = request.getParameter("Continue.Button") != null;

    final boolean disable = !((request.getParameter("disable") != null) && (request.getParameter("disable").length() > 0));

    Path objectPath = new Path(objectXri);
    RefObject_1_0 refObj = (RefObject_1_0)pm.getObjectById(objectPath);
    final String providerName = objectPath.get(2);
    final String segmentName = objectPath.get(4);
    final long compositeCounter = 0;

  	boolean currentUserIsAdmin =
  		app.getCurrentUserRole().equals(org.opencrx.kernel.generic.SecurityKeys.ADMIN_PRINCIPAL + org.opencrx.kernel.generic.SecurityKeys.ID_SEPARATOR + segmentName + "@" + segmentName);

    final String currentUserRole = app.getCurrentUserRole();

    boolean permissionOk = true; //currentUserIsAdmin;
%>
    <form name="disabler" accept-charset="utf-8" method="post" action="DisableCrxObject.jsp">
      <input type="hidden" class="valueL" name="xri" value="<%= objectXri %>" />
      <input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
      <input type="Checkbox" name="disable" <%= disable ? "" : "checked" %> value="disable" style="display:none;" />
<%
  		if(permissionOk && actionOk) {
%>
        <%= (new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getTitle() + ((new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getTitle().length() == 0 ? "" : " - ") + (new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getLabel() %><br />
        Qualifier = <%= objectXri %><br /><br /><br />
<%
        try {
          RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
          String parentXri = new Path(objectXri).getParent().getParent().toXri();
          org.opencrx.kernel.generic.jmi1.CrxObject crxObject = (org.opencrx.kernel.generic.jmi1.CrxObject)obj;
          pm.currentTransaction().begin();
          crxObject.setDisabled(new Boolean(disable));
          crxObject.setDisabledReason(currentUserRole);
          System.out.println((disable ? "Disabling: " : "Enabling: ") + crxObject.refGetPath());

          // disable/enable composites
          try {
              Utils.traverseObjectTree(
                crxObject,
                null, // referenceFilter
                new Utils.TraverseObjectTreeCallback() {

                    // @Override
                    public Object visit(
                      RefObject_1_0 object,
                      Object context
                    ) throws ServiceException {
                      if (object instanceof org.opencrx.kernel.generic.jmi1.CrxObject) {
                          ((org.opencrx.kernel.generic.jmi1.CrxObject)object).setDisabled(new Boolean(disable));
                          ((org.opencrx.kernel.generic.jmi1.CrxObject)object).setDisabledReason(currentUserRole);
                          System.out.println((disable ? "Disabling: " : "Enabling: ") + object.refGetPath());
                      }
                      return null;
                    }
                  },
                null
              );
          }
          catch(Exception e) {
              new ServiceException(e).log();
          }
          pm.currentTransaction().commit();
%>
          ...<%= disable ? "Disabled" : "Enabled" %>
<%
    	    // Go back to previous view
      		Action action = new ObjectReference(refObj, app).getSelectObjectAction();
      		response.sendRedirect(
      			request.getContextPath() + "/" + action.getEncodedHRef()
        	);
        }
        catch(Exception e) {
%>
          ...<b>NOT</b> <%= disable ? "Disabled" : "Enabled" %> <%= compositeCounter %> objects
          <br><br>
          <INPUT type="Submit" name="Cancel.Button" tabindex="2010" value=">>" />
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
%>
            <div style="border:1px solid black;padding:10px;margin:2px 2px 10px 2px;background-color:<%= disable ? "#FF9900" : "#20FF20" %>;">
              <div title="XRI=<%= objectXri %>">
                <%= disable ? "Disable" : "Enable" %> <b><%= (new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getTitle() + ((new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getTitle().length() == 0 ? "" : " - ") + (new ObjectReference((RefObject_1_0)pm.getObjectById(new Path(objectXri)), app)).getLabel() %></b> and composites<br>
                XRI=<%= objectXri %>
              </div>
              <div>
<%
                  try {
                      RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
                      org.opencrx.kernel.generic.jmi1.CrxObject crxObject = (org.opencrx.kernel.generic.jmi1.CrxObject)obj;

                      Utils.traverseObjectTree(
                        crxObject,
                        null, // referenceFilter
                        new Utils.TraverseObjectTreeCallback() {

                            // @Override
                            public Object visit(
                              RefObject_1_0 object,
                              Object context
                            ) throws ServiceException {
                              //System.out.println("Visit=" + object.refGetPath());
                              //compositeCounter++;
                              return null;
                            }
                          },
                        null
                      );
                  }
                  catch(Exception e) {
                      new ServiceException(e).log();
                  }
%>
              </div>
            </div>
            <INPUT type="Submit" name="OK.Button" tabindex="2000" value="<%= app.getTexts().getOkTitle() %>" />
            <INPUT type="Submit" name="Cancel.Button" tabindex="2000" value="<%= app.getTexts().getCancelTitle() %>" />
<%
          }
          else {
%>
            <h1><font color="red">No Permission</font></h1>
            <br />
            <br />
          	<INPUT type="Submit" name="Cancel.Button" tabindex="2010" value="<%= app.getTexts().getCancelTitle() %>" />
<%
          }
        }
      }
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
