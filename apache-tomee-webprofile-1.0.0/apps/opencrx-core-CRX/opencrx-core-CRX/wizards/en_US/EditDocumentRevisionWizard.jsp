<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: EditDocumentRevisionWizard.jsp,v 1.2 2011/11/28 14:01:59 wfro Exp $
 * Description: EditDocumentRevisionWizard
 * Revision:    $Revision: 1.2 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/11/28 14:01:59 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2004-2011, CRIXP Corp., Switzerland
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
org.opencrx.kernel.portal.*,
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
org.openmdx.base.naming.*
" %><%
	request.setCharacterEncoding("UTF-8");
	String servletPath = "." + request.getServletPath();
	String servletPathPrefix = servletPath.substring(0, servletPath.lastIndexOf("/") + 1);
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
	final String FORM_NAME = "editDocumentRevisionForm";
	final String WIZARD_NAME = "EditDocumentRevisionWizard.jsp";

  try {
    	// Get Parameters
    	String command = request.getParameter("Command");
    	if(command == null) command = "";
    	boolean actionCreate = "OK".equals(command);
    	boolean actionCancel = "Cancel".equals(command);

    	if(actionCancel || (!(obj instanceof org.opencrx.kernel.document1.jmi1.Document))) {
    		session.setAttribute(WIZARD_NAME, null);
    		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
    		response.sendRedirect(
    			request.getContextPath() + "/" + nextAction.getEncodedHRef()
    		);
    		return;
    	}
    	org.opencrx.kernel.document1.jmi1.Document document = (org.opencrx.kernel.document1.jmi1.Document)obj;
%>
      <!--
      	<meta name="label" content="Edit Revision">
      	<meta name="toolTip" content="Edit Revision">
      	<meta name="targetType" content="_inplace">
      	<meta name="forClass" content="org:opencrx:kernel:document1:Document">
      	<meta name="order" content="999">
      -->
<%
    	org.openmdx.ui1.jmi1.FormDefinition formDefinition = app.getUiFormDefinition(FORM_NAME);
    	org.openmdx.portal.servlet.control.FormControl form = new org.openmdx.portal.servlet.control.FormControl(
    		formDefinition.refGetPath().getBase(),
    		app.getCurrentLocaleAsString(),
    		app.getCurrentLocaleAsIndex(),
    		app.getUiContext(),
    		formDefinition
    	);

		Map formValues = new HashMap();
		form.updateObject(
    		request.getParameterMap(),
    		formValues,
    		app,
    		pm
    	);

    	// get additional parameters
		boolean isFirstCall = request.getParameter("isFirstCall") == null; // used to properly initialize various options
		if (isFirstCall) {
			// populate form fields with document's attribute values
			String text = "";
			if(document.getHeadRevision() instanceof org.opencrx.kernel.document1.jmi1.MediaContent) {
				org.opencrx.kernel.document1.jmi1.MediaContent mediaContent = (org.opencrx.kernel.document1.jmi1.MediaContent)document.getHeadRevision();
			    if(mediaContent.getContentMimeType().startsWith("text/")) {
			    	ByteArrayOutputStream content = new ByteArrayOutputStream();
			    	org.w3c.cci2.BinaryLargeObjects.streamCopy(mediaContent.getContent().getContent(), 0L, content);
			    	content.close();
			    	text = new String(content.toByteArray(), "UTF-8");
			    }
          	}
          	formValues.put("org:opencrx:kernel:base:Note:text", text);
      	}

    	if(actionCreate) {
    		org.opencrx.kernel.document1.jmi1.MediaContent newHeadRevision = pm.newInstance(org.opencrx.kernel.document1.jmi1.MediaContent.class);
    		newHeadRevision.refInitialize(false, false);
    		if(document.getHeadRevision() instanceof org.opencrx.kernel.document1.jmi1.MediaContent) {
    			org.opencrx.kernel.document1.jmi1.MediaContent headRevision = (org.opencrx.kernel.document1.jmi1.MediaContent)document.getHeadRevision();
    			newHeadRevision.setName(headRevision.getName());
    			newHeadRevision.setContentName(headRevision.getContentName());
    			if(headRevision.getContentMimeType().startsWith("text/")) {
    				newHeadRevision.setContentMimeType(headRevision.getContentMimeType());
    			}
    			int newVersion = 0;
    			try {
    				newVersion = Integer.valueOf(headRevision.getVersion());
    				newVersion++;
    			} catch(Exception e) {}
    			newHeadRevision.setVersion(Integer.toString(newVersion));
    		} else {
    			newHeadRevision.setName(document.getName());
    			newHeadRevision.setContentName(document.getName());
    			newHeadRevision.setContentMimeType("text/plain");
    		}
			newHeadRevision.setAuthor(app.getLoginPrincipal());
    		String text = (String)formValues.get("org:opencrx:kernel:base:Note:text");    		
    		newHeadRevision.setContent(
    			org.w3c.cci2.BinaryLargeObjects.valueOf(
    				text == null ? new byte[]{} : text.getBytes()
    			)
    		);
    		pm.currentTransaction().begin();
    		document.addRevision(
    			org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
    			newHeadRevision
    		);
    		document.setHeadRevision(newHeadRevision);
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
    	TransientObjectView view = new TransientObjectView(
    		formValues,
    		app,
    		obj,
    		pm
    	);
    	ViewPort p = ViewPortFactory.openPage(
    		view,
    		request,
    		out
    	);
%>
      <br />
      <form id="<%= FORM_NAME %>" name="<%= FORM_NAME %>" accept-charset="UTF-8" method="POST" action="<%= servletPath %>">
      	<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
      	<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
      	<input type="hidden" id="Command" name="Command" value="" />
        <input type="checkbox" style="display:none;" id="isFirstCall" name="isFirstCall" checked="true" />
      	<table cellspacing="8" class="tableLayout">
      		<tr>
      			<td class="cellObject">
      				<div class="panel" id="panel<%= FORM_NAME %>" style="display: block">
<%
						form.paint(
      						p,
      						null, // frame
      						true // forEditing
      					);
      					p.flush();
%>
      				</div>

      				<input type="submit" class="abutton", name="Refresh" id="Refresh.Button" tabindex="9000" value="<%= app.getTexts().getReloadText() %>" style="display:none;" onclick="javascript:$('Command').value=this.name;" />
      				<input type="submit" class="abutton", name="OK" id="OK.Button" tabindex="9000" value="<%= app.getTexts().getOkTitle() %>" onclick="javascript:$('Command').value=this.name;" />
      				<input type="submit" class="abutton" name="Cancel" tabindex="9010" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Command').value=this.name;" />
      			</td>
      		</tr>
      	</table>
      </form>
      <br>&nbsp;
      <script language="javascript" type="text/javascript">
      	Event.observe('<%= FORM_NAME %>', 'submit', function(event) {
      		$('<%= FORM_NAME %>').request({
      			onFailure: function() { },
      			onSuccess: function(t) {
      				$('UserDialog').update(t.responseText);
      			}
      		});
      		Event.stop(event);
      	});
      </script>
<%
      p.close(false);
  }
  catch (Exception e) {
    new ServiceException(e).log();
  }
  finally {
    if(pm != null) {
    	pm.close();
    }
  }
%>
