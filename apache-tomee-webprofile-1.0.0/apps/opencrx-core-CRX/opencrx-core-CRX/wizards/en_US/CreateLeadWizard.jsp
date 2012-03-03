<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: CreateLeadWizard.jsp,v 1.19 2011/11/02 16:30:55 cmu Exp $
 * Description: CreateLeadWizard
 * Revision:    $Revision: 1.19 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/11/02 16:30:55 $
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
org.openmdx.base.accessor.cci.*,
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
	String formName = "CreateLeadForm";
	String wizardName = "CreateLeadWizard.jsp";

	// Get Parameters
	String command = request.getParameter("Command");
	if(command == null) command = "";						
	boolean actionCreate = "OK".equals(command);
	boolean actionCancel = "Cancel".equals(command);

	if(actionCancel) {
	  session.setAttribute(wizardName, null);
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}
%>
<!--
	<meta name="UNUSEDlabel" content="Create Lead">
	<meta name="UNUSEDtoolTip" content="Create Lead">
	<meta name="targetType" content="_inplace">
	<meta name="forClass" content="org:opencrx:kernel:contract1:Segment">
	<meta name="order" content="org:opencrx:kernel:contract1:Segment:createLead">
-->	
<%
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
	org.opencrx.kernel.contract1.jmi1.Segment contractSegment =
	    (org.opencrx.kernel.contract1.jmi1.Segment)pm.getObjectById(
	        new Path("xri:@openmdx:org.opencrx.kernel.contract1/provider/" + providerName + "/segment/" + segmentName)
		);
	org.openmdx.ui1.jmi1.FormDefinition formDefinition = app.getUiFormDefinition(formName);
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
	// form.paint() renders in the context of a Lead
	formValues.put(
	    SystemAttributes.OBJECT_CLASS,
	    "org:opencrx:kernel:contract1:Lead"
	);
	if(obj instanceof org.opencrx.kernel.account1.jmi1.Contact) {
	    org.opencrx.kernel.account1.jmi1.Contact contact = (org.opencrx.kernel.account1.jmi1.Contact)obj;
	    formValues.put(
	        "org:opencrx:kernel:contract1:SalesContract:customer",
	        contact.refGetPath()
	    );
	    if(contact.getAliasName() != null) {
		    formValues.put(
		       	"org:opencrx:kernel:contract1:AbstractContract:contractNumber",
		        contact.getAliasName() + "-" + (System.currentTimeMillis() / 1000)
		    );
	    }
	}
	if(actionCreate) {
	    org.opencrx.kernel.account1.jmi1.Contact customer = formValues.get("org:opencrx:kernel:contract1:SalesContract:customer") != null ?
	    	(org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(
	    		formValues.get("org:opencrx:kernel:contract1:SalesContract:customer")
	    	) : null;
	    String name = (String)formValues.get("org:opencrx:kernel:contract1:AbstractContract:name");
	    String contractNumber = (String)formValues.get("org:opencrx:kernel:contract1:AbstractContract:contractNumber");
	    Short leadSource = (Short)formValues.get("org:opencrx:kernel:contract1:Lead:leadSource");
	    Short leadState = (Short)formValues.get("org:opencrx:kernel:contract1:AbstractContract:contractState");
	    Short leadRating = (Short)formValues.get("org:opencrx:kernel:contract1:Lead:leadRating");
	    Short closeProbability = (Short)formValues.get("org:opencrx:kernel:contract1:Lead:closeProbability");
	    Short priority = (Short)formValues.get("org:opencrx:kernel:contract1:AbstractContract:priority");
	    Short contractCurrency = (Short)formValues.get("org:opencrx:kernel:contract1:SalesContract:contractCurrency");
	    java.math.BigDecimal estimatedValue = (java.math.BigDecimal)formValues.get("org:opencrx:kernel:contract1:Lead:estimatedValue");
	    Date estimatedCloseDate = (Date)formValues.get("org:opencrx:kernel:contract1:Lead:estimatedCloseDate");
	    java.math.BigDecimal estimatedSalesCommission = (java.math.BigDecimal)formValues.get("org:opencrx:kernel:contract1:Lead:estimatedSalesCommission");
	    String description = (String)formValues.get("org:opencrx:kernel:contract1:AbstractContract:description");
	    String nextStep = (String)formValues.get("org:opencrx:kernel:contract1:Lead:nextStep");
	    if(
	        (customer != null) &&
	        (name != null)
	    ) {
	        org.opencrx.kernel.contract1.jmi1.Lead lead = pm.newInstance(org.opencrx.kernel.contract1.jmi1.Lead.class);
	        lead.refInitialize(false, false);
	        lead.setName(name);
	        lead.setContractNumber(contractNumber);
	        lead.setCustomer(customer);
	        lead.setLeadSource(leadSource);
	        lead.setContractState(leadState);
	        lead.setLeadRating(leadRating);
	        lead.setCloseProbability(closeProbability);
	        lead.setPriority(priority);
	        lead.setContractCurrency(contractCurrency);
	        lead.setEstimatedValue(estimatedValue);
	        lead.setEstimatedCloseDate(estimatedCloseDate);
	        lead.setEstimatedSalesCommission(estimatedSalesCommission);
	        lead.setDescription(description);
	        lead.setNextStep(nextStep);
	      	pm.currentTransaction().begin();
	      	contractSegment.addLead(
	            false,
	            org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
	            lead
	        );
	        pm.currentTransaction().commit();
		    Action nextAction = new ObjectReference(
		    	lead,
		    	app
		   	).getSelectObjectAction();
			response.sendRedirect(
				request.getContextPath() + "/" + nextAction.getEncodedHRef()
			);
			return;
	    }
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
<form id="<%= formName %>" name="<%= formName %>" accept-charset="UTF-8" method="POST" action="<%= servletPath %>">
	<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
	<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
	<input type="hidden" id="Command" name="Command" value="" />									
	<table cellspacing="8" class="tableLayout">
		<tr>
			<td class="cellObject">
				<div class="panel" id="panel<%= formName %>" style="display: block">
<%
					form.paint(
						p,
						null, // frame
						true // forEditing
					);
					p.flush();
%>
				</div>
				<input type="submit" class="abutton" name="OK" id="OK.Button" tabindex="9000" value="Create" onclick="javascript:$('Command').value=this.name;" />
				<input  type="submit" class="abutton" name="Cancel" tabindex="9010" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Command').value=this.name;" />
			</td>
		</tr>
	</table>
</form>
<script language="javascript" type="text/javascript">
	Event.observe('<%= formName %>', 'submit', function(event) {
		$('<%= formName %>').request({
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
if(pm != null) {
	pm.close();
}
%>
