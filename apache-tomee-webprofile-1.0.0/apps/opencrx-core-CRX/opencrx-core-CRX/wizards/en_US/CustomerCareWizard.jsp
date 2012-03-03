﻿<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.openmdx.org/
 * Name:        $Id: CustomerCareWizard.jsp,v 1.19 2011/10/24 06:55:46 wfro Exp $
 * Description: CustomerCareWizard
 * Revision:    $Revision: 1.19 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/10/24 06:55:46 $
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
%><%@ page session="true" import="
java.util.*,
java.io.*,
java.text.*,
org.opencrx.kernel.backend.*,
org.opencrx.kernel.portal.*,
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.openmdx.base.text.conversion.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.base.exception.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.databinding.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*
" %>
<%!
	enum Command {
		NA,
		CANCEL,
		BACK_TO_SEARCH_CONTACT,
		BACK_TO_CONTACT,
		SEARCH_CONTACT,
		SELECT_CONTACT,
		SAVE_CONTACT,
		LOCK_CONTACT,
		NEW_ACTIVITY_CONTACT,
		NEW_ACTIVITY,
		SAVE_AS_NEW_ACTIVITY_CONTACT,
		SAVE_AS_NEW_ACTIVITY,
		SELECT_ACTIVITY,
		DO_FOLLOWUP
	}

	enum Form {
		
		SEARCH_CONTACT("CustomerCareSearchContactForm"),	
		CONTACT("ContactForm"),
		CREATE_ACTIVITY("CustomerCareCreateActivityForm"),
		SHOW_ACTIVITY("CustomerCareShowActivityForm"),
		CREATE_FOLLOW_UP("CustomerCareCreateFollowUpForm");

		private final String name;
		
		private Form(
			String name
		) {
			this.name = name;
		}
		
		public String getName(
		) {
			return this.name;
		}

	}
	
	static final String PROPERTY_NAME_IS_LOCKED = "org:opencrx:wizards:CustomerCareWizard!contactIsLocked";
	
	static final long LOCK_TIMEOUT = 300000L; // 5 minutes 
			
	static class WizardState {
	
		public WizardState(
			org.opencrx.kernel.activity1.jmi1.Segment activitySegment,
			ApplicationContext app
		) {
			javax.jdo.PersistenceManager pm = javax.jdo.JDOHelper.getPersistenceManager(activitySegment);
			// Allowed activity creators
			List<Path> allowedActivityCreators = new ArrayList<Path>(); 
			List<Path> allowedActivityCreatorsContact = new ArrayList<Path>(); 
			org.opencrx.kernel.activity1.cci2.ActivityCreatorQuery activityCreatorQuery = (org.opencrx.kernel.activity1.cci2.ActivityCreatorQuery)pm.newQuery(org.opencrx.kernel.activity1.jmi1.ActivityCreator.class);
			activityCreatorQuery.forAllDisabled().isFalse();
			activityCreatorQuery.orderByName().ascending();
			List<org.opencrx.kernel.activity1.jmi1.ActivityCreator> activityCreators = activitySegment.getActivityCreator(activityCreatorQuery);
			for(org.opencrx.kernel.activity1.jmi1.ActivityCreator activityCreator: activityCreators) {
				if(app.getPortalExtension().hasPermission("CustomerCareWizard:" + Form.SEARCH_CONTACT + ":" + activityCreator.refGetPath().get(5) + "/" + activityCreator.refGetPath().get(6), activityCreator, app, WebKeys.GRANT_PREFIX + "show")) {
					allowedActivityCreators.add(activityCreator.refGetPath());
				}
				else if(app.getPortalExtension().hasPermission("CustomerCareWizard:" + Form.CONTACT + ":" + activityCreator.refGetPath().get(5) + "/" + activityCreator.refGetPath().get(6), activityCreator, app, WebKeys.GRANT_PREFIX + "show")) {
					allowedActivityCreatorsContact.add(activityCreator.refGetPath());
				}
			}
			this.allowedActivityCreators = allowedActivityCreators;
			this.allowedActivityCreatorsContact = allowedActivityCreatorsContact;
			// Allowed process states
			List<Path> allowedProcessStates = new ArrayList<Path>(); 
			Collection<org.opencrx.kernel.activity1.jmi1.ActivityProcess> activityProcesses = activitySegment.getActivityProcess();
			for(org.opencrx.kernel.activity1.jmi1.ActivityProcess activityProcess: activityProcesses) {
				Collection<org.opencrx.kernel.activity1.jmi1.ActivityProcessState> activityProcessStates = activityProcess.getState();
				for(org.opencrx.kernel.activity1.jmi1.ActivityProcessState processState: activityProcessStates) {
					if(
						app.getPortalExtension().hasPermission("CustomerCareWizard:" + processState.refGetPath().get(5) + "/" + processState.refGetPath().get(6) + "/" + processState.refGetPath().get(7) + "/:*", activitySegment, app, WebKeys.GRANT_PREFIX + "show") ||							
						app.getPortalExtension().hasPermission("CustomerCareWizard:" + processState.refGetPath().get(5) + "/" + processState.refGetPath().get(6) + "/" + processState.refGetPath().get(7) + "/" + processState.refGetPath().get(8), processState, app, WebKeys.GRANT_PREFIX + "show")
					) {
						allowedProcessStates.add(processState.refGetPath());
					}					
				}
			}
			this.allowedProcessStates = allowedProcessStates;
		}
		
		public void setSelectedContactIdentity(
			Path newValue
		) {
			this.selectedContactIdentity = newValue;
		}
		
		public Path getSelectedContactIdentity(
		) {
			return this.selectedContactIdentity;
		}
		
		public void setSelectedActivityIdentity(
			Path newValue
		) {
			this.selectedActivityIdentity = newValue;
		}
		
		public Path getSelectedActivityIdentity(
		) {
			return this.selectedActivityIdentity;
		}
		
		public List<Path> getAllowedActivityCreatorsContact(
		) {
			return this.allowedActivityCreatorsContact;
		}
		
		public List<Path> getAllowedActivityCreators(
		) {
			return this.allowedActivityCreators;
		}
		
		public List<Path> getAllowedProcessStates(
		) {
			return this.allowedProcessStates;
		}
		
		public Path getSelectedActivityCreatorIdentity(
		) {
			return this.selectedActivityCreatorIdentity;
		}
		
		public void setSelectedActivityCreatorIdentity(
			Path newValue
		) {
			this.selectedActivityCreatorIdentity = newValue;
		}
		
		private Path selectedContactIdentity = null;
		private Path selectedActivityIdentity = null;
		private Path selectedActivityCreatorIdentity = null;
		private final List<Path> allowedActivityCreatorsContact;
		private final List<Path> allowedActivityCreators;
		private final List<Path> allowedProcessStates;
	}
	
	public static boolean contactIsLocked(
		org.opencrx.kernel.account1.jmi1.Account contact
	) {
		BooleanPropertyDataBinding binding = new BooleanPropertyDataBinding(AbstractPropertyDataBinding.PropertySetHolderType.CrxObject);
		org.opencrx.kernel.base.jmi1.Property p = binding.findProperty(contact, PROPERTY_NAME_IS_LOCKED);
		return 
			Boolean.TRUE.equals(binding.getValue(contact, PROPERTY_NAME_IS_LOCKED)) &&
			p != null &&
			p.getModifiedAt().getTime() > System.currentTimeMillis() - LOCK_TIMEOUT;
	}
	
	public static void lockContact(
		org.opencrx.kernel.account1.jmi1.Account contact
	) {
		BooleanPropertyDataBinding binding = new BooleanPropertyDataBinding(AbstractPropertyDataBinding.PropertySetHolderType.CrxObject);
		javax.jdo.PersistenceManager pm = javax.jdo.JDOHelper.getPersistenceManager(contact);
		// Make sure that modifiedAt is updated
		pm.currentTransaction().begin();
		binding.setValue(
			contact, 
			PROPERTY_NAME_IS_LOCKED, 
			false
		);
		pm.currentTransaction().commit();
		pm.currentTransaction().begin();
		binding.setValue(
			contact, 
			PROPERTY_NAME_IS_LOCKED, 
			true
		);
		pm.currentTransaction().commit();
	}

%>
<%
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

	final String WIZARD_NAME = "CustomerCareWizard.jsp";

	final String WILCARD = ".*";
	
	final String PARAMETER_SELECTED_OBJECT_XRI = "SelectedObject.XRI";
	
	// Get Parameters
	String commandAsString = request.getParameter("Command");
	if(commandAsString == null) commandAsString = Command.NA.toString();
	Command command = Command.valueOf(commandAsString);
	Path selectedObjectIdentity = request.getParameter(PARAMETER_SELECTED_OBJECT_XRI) == null ?
		null :
			new Path(request.getParameter(PARAMETER_SELECTED_OBJECT_XRI));

	List matchingAccounts = null;
	if(command == Command.CANCEL) {
		session.setAttribute(WIZARD_NAME, null);
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
	org.opencrx.kernel.activity1.jmi1.Segment activitySegment = Activities.getInstance().getActivitySegment(pm, providerName, segmentName);
	WizardState wizardState = null;
	try {
		wizardState = (WizardState)session.getAttribute(WIZARD_NAME);
	} catch(Exception e) {}
	if(wizardState == null) {
		session.setAttribute(
			WIZARD_NAME,
			wizardState = new WizardState(
				activitySegment,
				app
			)
		);
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html dir="<%= texts.getDir() %>">
<head>
	<title><%= app.getApplicationName() + " - Customer Care (" + providerName + "/" + segmentName + ")" %></title>
	<meta name="label" content="Customer Care">
	<meta name="toolTip" content="Customer Care">
	<meta name="targetType" content="_self">
	<meta name="forClass" content="org:opencrx:kernel:home1:UserHome">
	<meta name="forClass" content="org:opencrx:kernel:account1:Account">
	<meta name="forClass" content="org:opencrx:kernel:activity1:ActivityGroup">
	<meta name="order" content="5555">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<link href="../../_style/calendar-small.css" rel="stylesheet" type="text/css">	
	<link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
	<link href="../../_style/colors.css" rel="stylesheet" type="text/css">
	<link href="../../_style/ssf.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="../../javascript/portal-all.js"></script>
	<script type="text/javascript" src="../../javascript/calendar/lang/calendar-en_US.js"></script>
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
									<td id="headerCellMiddle" style="text-align:right;"><a class="abutton" href="#" onclick="javascript:new Effect.Pulsate(this,{pulses:1,duration:0.5});window.location.href='./'+getEncodedHRef(['../../ObjectInspectorServlet', 'requestId', '<%= requestId %>', 'event', '<%= org.openmdx.portal.servlet.action.LogoffAction.EVENT_ID %>']);">Logoff</a></td>
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
				int showMaxContacts = 200;
				org.opencrx.kernel.home1.jmi1.UserHome userHome = null;
				org.opencrx.kernel.activity1.jmi1.ActivityGroup activityGroup = null;
				org.opencrx.kernel.account1.jmi1.Account account = null;
				if(obj instanceof org.opencrx.kernel.home1.jmi1.UserHome) {
				    userHome = (org.opencrx.kernel.home1.jmi1.UserHome)obj;
				} else if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityGroup) {
					activityGroup = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)obj;
				} else if(obj instanceof org.opencrx.kernel.account1.jmi1.Account) {
					account = (org.opencrx.kernel.account1.jmi1.Account)obj;
				}
				Form form = Form.SEARCH_CONTACT;
				switch(command) {
					case SELECT_CONTACT:
					case BACK_TO_CONTACT:
					case SAVE_CONTACT:
					case LOCK_CONTACT:
						form = Form.CONTACT;
						break;
					case SELECT_ACTIVITY:
						form = Form.SHOW_ACTIVITY;
						break;
					case SAVE_AS_NEW_ACTIVITY_CONTACT:
					case SAVE_AS_NEW_ACTIVITY:
					case NEW_ACTIVITY_CONTACT:
					case NEW_ACTIVITY:
						form = Form.CREATE_ACTIVITY;
						break;
					case DO_FOLLOWUP:
						form = Form.CREATE_FOLLOW_UP;
						break;
					default:
						form = Form.SEARCH_CONTACT;
						break;
				}
				org.openmdx.ui1.jmi1.FormDefinition formDefinition = app.getUiFormDefinition(form.getName());
				org.openmdx.portal.servlet.control.FormControl formCtrl = new org.openmdx.portal.servlet.control.FormControl(
					formDefinition.refGetPath().getBase(),
					app.getCurrentLocaleAsString(),
					app.getCurrentLocaleAsIndex(),
					app.getUiContext(),
					formDefinition
				);
				Map formValues = new HashMap();
				// Initialize formValues with account values
				{
					// nothing to do
				}
				formCtrl.updateObject(
					request.getParameterMap(),
					formValues,
					app,
					pm
				);

				List<?> matchingContacts = null;
				if(command == Command.BACK_TO_CONTACT) {
					command = Command.SELECT_CONTACT;
					selectedObjectIdentity = wizardState.getSelectedContactIdentity();
				}
				if(command == Command.BACK_TO_SEARCH_CONTACT) {
					command = Command.SEARCH_CONTACT;
				}
				if(
					(command == Command.NEW_ACTIVITY_CONTACT || command == Command.NEW_ACTIVITY) &&
					selectedObjectIdentity != null
				) {
					wizardState.setSelectedActivityCreatorIdentity(
						selectedObjectIdentity
					);
				}
				if(command == Command.LOCK_CONTACT) {
					if(wizardState.getSelectedContactIdentity() != null) {
						org.opencrx.kernel.account1.jmi1.Contact contact = (org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(wizardState.getSelectedContactIdentity());
						try {
							lockContact(contact);
						} catch(Exception e) {
							try {
								pm.currentTransaction().rollback();
							} catch(Exception e1) {}
							new ServiceException(e).log();
						}
						selectedObjectIdentity = wizardState.getSelectedContactIdentity();
						command = Command.SELECT_CONTACT;
					}
				}
				if(
					(command == Command.SAVE_AS_NEW_ACTIVITY_CONTACT || command == Command.SAVE_AS_NEW_ACTIVITY) &&
					wizardState.getSelectedActivityCreatorIdentity() != null
				) {
					String name = (String)formValues.get("org:opencrx:kernel:activity1:Activity:name");
					Short priority = (Short)formValues.get("org:opencrx:kernel:activity1:Activity:priority");
					Date dueBy = (Date)formValues.get("org:opencrx:kernel:activity1:Activity:dueBy");
					Date scheduledStart = (Date)formValues.get("org:opencrx:kernel:activity1:Activity:scheduledStart");
					Date scheduledEnd = (Date)formValues.get("org:opencrx:kernel:activity1:Activity:scheduledEnd");
					String misc1 = (String)formValues.get("org:opencrx:kernel:activity1:Activity:misc1");					
					String misc2 = (String)formValues.get("org:opencrx:kernel:activity1:Activity:misc2");					
					String misc3 = (String)formValues.get("org:opencrx:kernel:activity1:Activity:misc3");					
					String description = (String)formValues.get("org:opencrx:kernel:activity1:Activity:description");					
					String detailedDescription = (String)formValues.get("org:opencrx:kernel:activity1:Activity:detailedDescription");
					org.opencrx.kernel.account1.jmi1.Contact reportingContact = null;
					if(command == Command.SAVE_AS_NEW_ACTIVITY_CONTACT) {
						reportingContact = (org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(wizardState.getSelectedContactIdentity());
					}
					org.opencrx.kernel.activity1.jmi1.ActivityCreator activityCreator = (org.opencrx.kernel.activity1.jmi1.ActivityCreator)pm.getObjectById(wizardState.getSelectedActivityCreatorIdentity());					
					org.opencrx.kernel.activity1.jmi1.Activity newActivity = null;
					if(name != null) {
						try {
							pm.currentTransaction().begin();
							newActivity = Activities.getInstance().newActivity(
								activityCreator, 
								name,
								description == null ? null : description.replace("\r\n", "\n"), 
								detailedDescription == null ? null : detailedDescription.replace("\r\n", "\n"), 
								scheduledStart, 
								scheduledEnd, 
								dueBy, 
								priority, 
								ICalendar.ICAL_TYPE_NA, 
								reportingContact, 
								null // creationContext
							);
							newActivity.setMisc1(misc1);
							newActivity.setMisc2(misc2);
							newActivity.setMisc3(misc3);
							pm.currentTransaction().commit();
						} catch(Exception e)  {
							new ServiceException(e).log();
							try {
								pm.currentTransaction().rollback();
							} catch(Exception e0) {}
						}
					}
					if(newActivity != null) {
						wizardState.setSelectedActivityIdentity(newActivity.refGetPath());
						if(command == Command.SAVE_AS_NEW_ACTIVITY_CONTACT) {
							command = Command.SELECT_ACTIVITY;
							form = Form.SHOW_ACTIVITY;
							selectedObjectIdentity = newActivity.refGetPath();
						} else {
							command = Command.SEARCH_CONTACT;
							form = Form.SEARCH_CONTACT;
						}
					}
					else {
						if(command == Command.SAVE_AS_NEW_ACTIVITY_CONTACT) {
							command = Command.SELECT_CONTACT;
							form = Form.CONTACT;
							selectedObjectIdentity = wizardState.getSelectedContactIdentity();							
						}
						else {
							command = Command.BACK_TO_SEARCH_CONTACT;
							form = Form.SEARCH_CONTACT;
						}
					}
				}
				if(command == Command.SEARCH_CONTACT) {
					String firstName = (String)formValues.get("org:opencrx:kernel:account1:Contact:firstName");
					String lastName = (String)formValues.get("org:opencrx:kernel:account1:Contact:lastName");
					String aliasName = (String)formValues.get("org:opencrx:kernel:account1:Account:aliasName");
					String eMailBusiness = (String)formValues.get("org:opencrx:kernel:account1:Account:address*Business!emailAddress");
					String phoneBusiness = (String)formValues.get("org:opencrx:kernel:account1:Account:address*Business!phoneNumberFull");
					if(
						(firstName != null && !firstName.isEmpty()) ||
						(lastName != null && !lastName.isEmpty()) ||
						(aliasName != null && !aliasName.isEmpty()) ||
						(eMailBusiness != null && !eMailBusiness.isEmpty()) ||				
						(phoneBusiness != null && !phoneBusiness.isEmpty())						
					) {
						if(account != null) {
							org.opencrx.kernel.account1.cci2.MemberQuery memberQuery = (org.opencrx.kernel.account1.cci2.MemberQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.Member.class);
							memberQuery.orderByName().ascending();
							if(
								(firstName != null && !firstName.isEmpty()) ||
								(lastName != null && !lastName.isEmpty())
							) {
								memberQuery.thereExistsAccount().thereExistsFullName().like(
									"(?i)" +
									(lastName !=  null && !lastName.isEmpty() ? lastName + WILCARD : "") +
									(firstName !=  null && !firstName.isEmpty() ? WILCARD + firstName + WILCARD : "")
								);						
							}
							if(aliasName != null && !aliasName.isEmpty()) {
								memberQuery.thereExistsAccount().thereExistsAliasName().like("(?i)" + WILCARD + aliasName + WILCARD);						
							}
							memberQuery.thereExistsAccount().thereExistsAssignedActivity().thereExistsProcessState().elementOf(wizardState.getAllowedProcessStates());
							{
								org.openmdx.base.persistence.cci.PersistenceHelper.setClasses(
									memberQuery.thereExistsAccount(), 
									org.opencrx.kernel.account1.jmi1.Contact.class
								);
							}
							if(phoneBusiness != null && !phoneBusiness.isEmpty()) {
								org.opencrx.kernel.account1.cci2.PhoneNumberQuery query = (org.opencrx.kernel.account1.cci2.PhoneNumberQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.PhoneNumber.class);
								query.thereExistsPhoneNumberFull().like(WILCARD + phoneBusiness + WILCARD);
								memberQuery.thereExistsAccount().thereExistsAddress().elementOf(org.openmdx.base.persistence.cci.PersistenceHelper.asSubquery(query));
						    }
						    if(eMailBusiness != null && !eMailBusiness.isEmpty()) {
						    	org.opencrx.kernel.account1.cci2.EMailAddressQuery query = (org.opencrx.kernel.account1.cci2.EMailAddressQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.EMailAddress.class);
						    	query.thereExistsEmailAddress().like(WILCARD + eMailBusiness + WILCARD);
								memberQuery.thereExistsAccount().thereExistsAddress().elementOf(org.openmdx.base.persistence.cci.PersistenceHelper.asSubquery(query));						    	
						    }
							matchingContacts = account.getMember(memberQuery);
						}
						else if(activityGroup != null) {
							org.opencrx.kernel.activity1.cci2.ActivityQuery activityQuery = (org.opencrx.kernel.activity1.cci2.ActivityQuery)pm.newQuery(org.opencrx.kernel.activity1.jmi1.Activity.class);
							if(
								(firstName != null && !firstName.isEmpty()) ||
								(lastName != null && !lastName.isEmpty())
							) {
								activityQuery.thereExistsReportingContact().thereExistsFullName().like(
									"(?i)" +
									(lastName !=  null && !lastName.isEmpty() ? lastName + WILCARD : "") +
									(firstName !=  null && !firstName.isEmpty() ? WILCARD + firstName + WILCARD : "")
								);						
							}
							if(aliasName != null && !aliasName.isEmpty()) {
								activityQuery.thereExistsReportingContact().thereExistsAliasName().like("(?i)" + WILCARD + aliasName + WILCARD);						
							}
							activityQuery.thereExistsProcessState().elementOf(wizardState.getAllowedProcessStates());
						    if(phoneBusiness != null && !phoneBusiness.isEmpty()) {
								org.opencrx.kernel.account1.cci2.PhoneNumberQuery query = (org.opencrx.kernel.account1.cci2.PhoneNumberQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.PhoneNumber.class);
								query.thereExistsPhoneNumberFull().like(WILCARD + phoneBusiness + WILCARD);
								activityQuery.thereExistsReportingContact().thereExistsAddress().elementOf(org.openmdx.base.persistence.cci.PersistenceHelper.asSubquery(query));
						    }
						    if(eMailBusiness != null && !eMailBusiness.isEmpty()) {
						    	org.opencrx.kernel.account1.cci2.EMailAddressQuery query = (org.opencrx.kernel.account1.cci2.EMailAddressQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.EMailAddress.class);
						    	query.thereExistsEmailAddress().like(WILCARD + eMailBusiness + WILCARD);
						    	activityQuery.thereExistsReportingContact().thereExistsAddress().elementOf(org.openmdx.base.persistence.cci.PersistenceHelper.asSubquery(query));
						    }
							matchingContacts = activityGroup.getFilteredActivity(activityQuery);						
						}
						else {
							org.opencrx.kernel.account1.cci2.ContactQuery contactQuery = (org.opencrx.kernel.account1.cci2.ContactQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.Contact.class);
							contactQuery.orderByFullName().ascending();
							if(
								(firstName != null && !firstName.isEmpty()) ||
								(lastName != null && !lastName.isEmpty())
							) {
								contactQuery.thereExistsFullName().like(
									"(?i)" +
									(lastName !=  null && !lastName.isEmpty() ? lastName + WILCARD : "") +
									(firstName !=  null && !firstName.isEmpty() ? WILCARD + firstName + WILCARD : "")
								);
							}
							if(aliasName != null && !aliasName.isEmpty()) {
								contactQuery.thereExistsAliasName().like("(?i)" + WILCARD + aliasName + WILCARD);						
							}
							contactQuery.thereExistsAssignedActivity().thereExistsProcessState().elementOf(wizardState.getAllowedProcessStates());
						    if(phoneBusiness != null && !phoneBusiness.isEmpty()) {
								org.opencrx.kernel.account1.cci2.PhoneNumberQuery query = (org.opencrx.kernel.account1.cci2.PhoneNumberQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.PhoneNumber.class);
								query.thereExistsPhoneNumberFull().like(WILCARD + phoneBusiness + WILCARD);
								contactQuery.thereExistsAddress().elementOf(org.openmdx.base.persistence.cci.PersistenceHelper.asSubquery(query));
						    }
						    if(eMailBusiness != null && !eMailBusiness.isEmpty()) {
						    	org.opencrx.kernel.account1.cci2.EMailAddressQuery query = (org.opencrx.kernel.account1.cci2.EMailAddressQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.EMailAddress.class);
						    	query.thereExistsEmailAddress().like(WILCARD + eMailBusiness + WILCARD);
						    	contactQuery.thereExistsAddress().elementOf(org.openmdx.base.persistence.cci.PersistenceHelper.asSubquery(query));
						    }
							matchingContacts = Accounts.getInstance().getAccountSegment(pm, providerName, segmentName).getAccount(contactQuery);
						}
					}
					// By default list all contacts of activity group.
					// Order by activity modification date descending.
					else if(activityGroup != null) {
						org.opencrx.kernel.activity1.cci2.ActivityQuery activityQuery = (org.opencrx.kernel.activity1.cci2.ActivityQuery)pm.newQuery(org.opencrx.kernel.activity1.jmi1.Activity.class);
						activityQuery.orderByModifiedAt().ascending();
						activityQuery.thereExistsProcessState().elementOf(wizardState.getAllowedProcessStates());
						activityQuery.activityState().equalTo(Activities.ActivityState.OPEN.getValue());
						matchingContacts = activityGroup.getFilteredActivity(activityQuery);						
						showMaxContacts = 20;
					}
				}
				if(
					command == Command.SELECT_CONTACT && 
					selectedObjectIdentity != null
				) {
					org.opencrx.kernel.account1.jmi1.Contact selectedContact = null;
					try {
						wizardState.setSelectedContactIdentity(selectedObjectIdentity);
						selectedContact = (org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(wizardState.getSelectedContactIdentity());
					} catch(Exception e) {}
					if(selectedContact != null) {
						formValues.clear();
					    formValues.put("org:opencrx:kernel:account1:Contact:salutationCode", selectedContact.getSalutationCode());
					    formValues.put("org:opencrx:kernel:account1:Contact:salutation", selectedContact.getSalutation());
					    formValues.put("org:opencrx:kernel:account1:Contact:firstName", selectedContact.getFirstName());
					    formValues.put("org:opencrx:kernel:account1:Contact:middleName", selectedContact.getMiddleName());
					    formValues.put("org:opencrx:kernel:account1:Contact:lastName", selectedContact.getLastName());
					    formValues.put("org:opencrx:kernel:account1:Account:aliasName", selectedContact.getAliasName());
					    formValues.put("org:opencrx:kernel:account1:Contact:jobTitle", selectedContact.getJobTitle());
					    formValues.put("org:opencrx:kernel:account1:Contact:jobRole", selectedContact.getJobRole());
					    formValues.put("org:opencrx:kernel:account1:Contact:organization", selectedContact.getOrganization());
					    formValues.put("org:opencrx:kernel:account1:Contact:department", selectedContact.getDepartment());
					    formValues.put("org:opencrx:kernel:account1:Contact:doNotPhone", selectedContact.isDoNotPhone());
					    formValues.put("org:opencrx:kernel:account1:Contact:birthdate", selectedContact.getBirthdate());
					    formValues.put("org:opencrx:kernel:account1:Account:description", selectedContact.getDescription());
					    org.opencrx.kernel.account1.jmi1.AccountAddress[] addresses = Accounts.getInstance().getMainAddresses(selectedContact);
					    if(addresses[Accounts.PHONE_BUSINESS] != null) {
					    	formValues.put("org:opencrx:kernel:account1:Account:address*Business!phoneNumberFull", ((org.opencrx.kernel.account1.jmi1.PhoneNumber)addresses[Accounts.PHONE_BUSINESS]).getPhoneNumberFull());
					    }
					    if(addresses[Accounts.MOBILE] != null) {
					    	formValues.put("org:opencrx:kernel:account1:Account:address*Mobile!phoneNumberFull", ((org.opencrx.kernel.account1.jmi1.PhoneNumber)addresses[Accounts.MOBILE]).getPhoneNumberFull());
					    }
					    if(addresses[Accounts.PHONE_HOME] != null) {
					    	formValues.put("org:opencrx:kernel:account1:Contact:address!phoneNumberFull", ((org.opencrx.kernel.account1.jmi1.PhoneNumber)addresses[Accounts.PHONE_HOME]).getPhoneNumberFull());
					    }
					    if(addresses[Accounts.MAIL_BUSINESS] != null) {
					    	formValues.put("org:opencrx:kernel:account1:Account:address*Business!emailAddress", ((org.opencrx.kernel.account1.jmi1.EMailAddress)addresses[Accounts.MAIL_BUSINESS]).getEmailAddress());
					    }
					    if(addresses[Accounts.MAIL_HOME] != null) {
					    	formValues.put("org:opencrx:kernel:account1:Contact:address!emailAddress", ((org.opencrx.kernel.account1.jmi1.EMailAddress)addresses[Accounts.MAIL_HOME]).getEmailAddress());
					    }
					    if(addresses[Accounts.POSTAL_HOME] != null) {
						    formValues.put("org:opencrx:kernel:account1:Contact:address!postalAddressLine", new ArrayList(((org.opencrx.kernel.account1.jmi1.PostalAddress)addresses[Accounts.POSTAL_HOME]).getPostalAddressLine()));
						    formValues.put("org:opencrx:kernel:account1:Contact:address!postalStreet", new ArrayList(((org.opencrx.kernel.account1.jmi1.PostalAddress)addresses[Accounts.POSTAL_HOME]).getPostalStreet()));
						    formValues.put("org:opencrx:kernel:account1:Contact:address!postalCity", ((org.opencrx.kernel.account1.jmi1.PostalAddress)addresses[Accounts.POSTAL_HOME]).getPostalCity());
						    formValues.put("org:opencrx:kernel:account1:Contact:address!postalCode", ((org.opencrx.kernel.account1.jmi1.PostalAddress)addresses[Accounts.POSTAL_HOME]).getPostalCode());
						    formValues.put("org:opencrx:kernel:account1:Contact:address!postalCountry", ((org.opencrx.kernel.account1.jmi1.PostalAddress)addresses[Accounts.POSTAL_HOME]).getPostalCountry());
					    }
					    if(addresses[Accounts.POSTAL_BUSINESS] != null) {
						    formValues.put("org:opencrx:kernel:account1:Account:address*Business!postalAddressLine", new ArrayList(((org.opencrx.kernel.account1.jmi1.PostalAddress)addresses[Accounts.POSTAL_BUSINESS]).getPostalAddressLine()));
						    formValues.put("org:opencrx:kernel:account1:Account:address*Business!postalStreet", new ArrayList(((org.opencrx.kernel.account1.jmi1.PostalAddress)addresses[Accounts.POSTAL_BUSINESS]).getPostalStreet()));
						    formValues.put("org:opencrx:kernel:account1:Account:address*Business!postalCity", ((org.opencrx.kernel.account1.jmi1.PostalAddress)addresses[Accounts.POSTAL_BUSINESS]).getPostalCity());
						    formValues.put("org:opencrx:kernel:account1:Account:address*Business!postalCode", ((org.opencrx.kernel.account1.jmi1.PostalAddress)addresses[Accounts.POSTAL_BUSINESS]).getPostalCode());
						    formValues.put("org:opencrx:kernel:account1:Account:address*Business!postalCountry", ((org.opencrx.kernel.account1.jmi1.PostalAddress)addresses[Accounts.POSTAL_BUSINESS]).getPostalCountry());
					    }
					}
				}
				if(
					command == Command.DO_FOLLOWUP && 
					selectedObjectIdentity != null
				) {
					org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition transition = (org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition)pm.getObjectById(selectedObjectIdentity);
					String followUpTitle = (String)formValues.get("org:opencrx:kernel:base:Note:title");
					String followUpText = (String)formValues.get("org:opencrx:kernel:base:Note:text");
					if(
						wizardState.getSelectedActivityIdentity() != null &&
						transition != null
					) {
						org.opencrx.kernel.activity1.jmi1.ActivityDoFollowUpParams params = org.opencrx.kernel.utils.Utils.getActivityPackage(pm).createActivityDoFollowUpParams(
							null, // assignTo
							followUpText == null ? null : followUpText.replace("\r\n", "\n"),
							followUpTitle,
							transition
						);
						try {
							pm.currentTransaction().begin();
							org.opencrx.kernel.activity1.jmi1.Activity activity = (org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(wizardState.getSelectedActivityIdentity());
							activity.doFollowUp(params);
							pm.currentTransaction().commit();
						} catch(Exception e) {
							try {
								new ServiceException(e).log();
								pm.currentTransaction().rollback();
							} catch(Exception e0) {}
						}
					}
					command = Command.SELECT_ACTIVITY;
					form = Form.SHOW_ACTIVITY;
					selectedObjectIdentity = wizardState.getSelectedActivityIdentity();
				}
				if(
					command == Command.SELECT_ACTIVITY && 
					selectedObjectIdentity != null
				) {
					org.opencrx.kernel.activity1.jmi1.Activity selectedActivity = null;
					try {
						wizardState.setSelectedActivityIdentity(selectedObjectIdentity);
						selectedActivity = (org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(wizardState.getSelectedActivityIdentity());
					} catch(Exception e) {}
					if(selectedActivity != null) {
					    formValues.put("org:opencrx:kernel:activity1:Activity:activityNumber", selectedActivity.getActivityNumber());
					    formValues.put("org:opencrx:kernel:activity1:Activity:name", selectedActivity.getName());
					    formValues.put("org:opencrx:kernel:activity1:Activity:lastAppliedCreator", selectedActivity.getLastAppliedCreator());
					    formValues.put("org:opencrx:kernel:activity1:Activity:reportingContact", selectedActivity.getReportingContact());
					   	formValues.put("org:opencrx:kernel:activity1:Activity:reportingAccount", selectedActivity.getReportingAccount());
					   	formValues.put("org:opencrx:kernel:activity1:Activity:processState", selectedActivity.getProcessState());
					    formValues.put("org:opencrx:kernel:activity1:Activity:priority", selectedActivity.getPriority());
					    formValues.put("org:opencrx:kernel:activity1:Activity:dueBy", selectedActivity.getDueBy());
					    formValues.put("org:opencrx:kernel:activity1:Activity:scheduledStart", selectedActivity.getScheduledStart());
					    formValues.put("org:opencrx:kernel:activity1:Activity:scheduledEnd", selectedActivity.getScheduledEnd());
					    formValues.put("org:opencrx:kernel:activity1:Activity:misc1", selectedActivity.getMisc1());
					    formValues.put("org:opencrx:kernel:activity1:Activity:misc2", selectedActivity.getMisc2());
					    formValues.put("org:opencrx:kernel:activity1:Activity:misc3", selectedActivity.getMisc3());
					    formValues.put("org:opencrx:kernel:activity1:Activity:description", selectedActivity.getDescription());
					    formValues.put("org:opencrx:kernel:activity1:Activity:detailedDescription", selectedActivity.getDetailedDescription());						
					}
				}
				formDefinition = app.getUiFormDefinition(form.getName());
				formCtrl = new org.openmdx.portal.servlet.control.FormControl(
					formDefinition.refGetPath().getBase(),
					app.getCurrentLocaleAsString(),
					app.getCurrentLocaleAsIndex(),
					app.getUiContext(),
					formDefinition
				);
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
				p.setResourcePathPrefix("../../");				
%>
				<form id="<%= form.getName() %>" name="<%= form.getName() %>" method="post" accept-charset="UTF-8" action="<%= WIZARD_NAME %>">
					<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
					<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
					<input type="Hidden" id="Command" name="Command" value="" />
					<input type="Hidden" id="<%= PARAMETER_SELECTED_OBJECT_XRI %>" name="<%= PARAMETER_SELECTED_OBJECT_XRI %>" value="" />
					<table cellspacing="8" class="tableLayout">
						<tr>
							<td class="cellObject">
								<div class="panel" id="panel<%= form.getName() %>" style="display:block">
<%
									boolean forEditing = 
										form == Form.SEARCH_CONTACT ||
										command == Command.NEW_ACTIVITY_CONTACT ||
										command == Command.NEW_ACTIVITY;

									if(form == Form.SEARCH_CONTACT) {
%>										
										<div>
											<input type="submit" class="abutton" name="<%= Command.SEARCH_CONTACT %>" id="<%= Command.SEARCH_CONTACT %>.Button" tabindex="9010" value="<%= texts.getSearchText() %>" onclick="javascript:$('Command').value=this.name;" />
<%										
											for(Path activityCreatorIdentity: wizardState.getAllowedActivityCreators()) {
												org.opencrx.kernel.activity1.jmi1.ActivityCreator activityCreator = (org.opencrx.kernel.activity1.jmi1.ActivityCreator)pm.getObjectById(activityCreatorIdentity);
%>										
												<input type="submit" class="abutton" tabindex="9050" value="<%= texts.getNewText() + ": " + activityCreator.getName() %>" onclick="javascript:$('<%= PARAMETER_SELECTED_OBJECT_XRI %>').value='<%= activityCreatorIdentity %>';$('Command').value='<%= Command.NEW_ACTIVITY %>';" />
<%
											}										
%>
											<input type="submit" class="abutton" name="<%= Command.CANCEL %>" tabindex="9080" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Command').value=this.name;"/>
										</div>
<%
									}
									else if(form == Form.CONTACT) {
%>
										<div>
<%																				
											for(Path activityCreatorIdentity: wizardState.getAllowedActivityCreatorsContact()) {
												org.opencrx.kernel.activity1.jmi1.ActivityCreator activityCreator = (org.opencrx.kernel.activity1.jmi1.ActivityCreator)pm.getObjectById(activityCreatorIdentity);
%>										
												<input type="submit" class="abutton" tabindex="9050" value="<%= texts.getNewText() + ": " + activityCreator.getName() %>" onclick="javascript:$('<%= PARAMETER_SELECTED_OBJECT_XRI %>').value='<%= activityCreatorIdentity %>';$('Command').value='<%= Command.NEW_ACTIVITY_CONTACT %>';" />
<%
											}
%>
											<input type="submit" class="abutton" tabIndex="9050" value="<%= texts.getCancelTitle() %>" onclick="javascript:$('Command').value='<%= Command.BACK_TO_SEARCH_CONTACT %>';"></a>
										</div>
										<div>&nbsp;</div>
										<div>
<%
											org.opencrx.kernel.account1.jmi1.Contact selectedContact = (org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(wizardState.getSelectedContactIdentity());
											if(contactIsLocked(selectedContact)) {
%>
												<img src="../../images/Lock.gif">
<%												
											}
											else {
%>
												<input type="image" name="<%= Command.LOCK_CONTACT %>" id="<%= Command.LOCK_CONTACT %>.Button" class="abutton" tabIndex="9060" src="../../images/PhoneCall.gif" onclick="javascript:$('Command').value=this.name;" /> 
<%
											}
%>										
										</div>
<%
									}
									else if(form == Form.CREATE_ACTIVITY) {
										if(command == Command.NEW_ACTIVITY_CONTACT) {
%>
											<div>
												<input type="submit" class="abutton" name="<%= Command.SAVE_AS_NEW_ACTIVITY_CONTACT %>" id="<%= Command.SAVE_AS_NEW_ACTIVITY_CONTACT %>.Button" tabindex="9070" value="<%= texts.getSaveTitle() %>" onclick="javascript:$('Command').value=this.name;" />
												<input type="submit" class="abutton" tabIndex="9050" value="<%= texts.getCancelTitle() %>" onclick="javascript:$('Command').value='<%= Command.BACK_TO_CONTACT %>';"></a>
											</div>
<%
										}
										else if(command == Command.NEW_ACTIVITY) {
%>
											<div>
												<input type="submit" class="abutton" name="<%= Command.SAVE_AS_NEW_ACTIVITY %>" id="<%= Command.SAVE_AS_NEW_ACTIVITY %>.Button" tabindex="9070" value="<%= texts.getSaveTitle() %>" onclick="javascript:$('Command').value=this.name;" />
												<input type="submit" class="abutton" tabIndex="9050" value="<%= texts.getCancelTitle() %>" onclick="javascript:$('Command').value='<%= Command.BACK_TO_SEARCH_CONTACT %>';"></a>
											</div>
<%											
										}
									}
									else if(form == Form.SHOW_ACTIVITY) {
										if(wizardState.getSelectedActivityIdentity() != null) {
											org.opencrx.kernel.activity1.jmi1.Activity selectedActivity = (org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(wizardState.getSelectedActivityIdentity());											
											org.opencrx.kernel.activity1.jmi1.ActivityProcess activityProcess = selectedActivity.getActivityType().getControlledBy();
											org.opencrx.kernel.activity1.jmi1.ActivityProcessState processState = selectedActivity.getProcessState();
											org.opencrx.kernel.activity1.cci2.ActivityProcessTransitionQuery transitionQuery = (org.opencrx.kernel.activity1.cci2.ActivityProcessTransitionQuery)pm.newQuery(org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition.class);
											transitionQuery.thereExistsPrevState().equalTo(selectedActivity.getProcessState());
											transitionQuery.orderByName().ascending();
											List<org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition> transitions = activityProcess.getTransition(transitionQuery);
											// One button for each transition
%>
											<div id="transitions">
<%																						
												for(org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition transition: transitions) {
													if(!transition.getNextState().equals(activityProcess.getStartState())) {
														String transitionId = transition.refGetPath().getBase();
%>
														<input type="button" class="abutton" tabindex="9070" value="<%= transition.getName() %>..." onclick="javascript:$('<%= transitionId %>').style.display='block';$('<%= transitionId %>.Title').style.display='block';$('followUp').style.display='block';$('transitions').style.display='none';" />
<%
													}
												}
%>								
												<input type="submit" class="abutton" tabIndex="9080" value="<%= texts.getCancelTitle() %>" onclick="javascript:$('Command').value='<%= Command.BACK_TO_CONTACT %>';"></a>
											</div>
<%											
											// One title div for each transition
											for(org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition transition: transitions) {
												if(!transition.getNextState().equals(activityProcess.getStartState())) {
%>
													<div id='<%= transition.refGetPath().getBase() %>.Title' style='display:none;'>
														<div style="font-size:2em;font-weight:bold;"><%= transition.getName() %></div>
													</div>
<%
												}
											}
%>
											<div>&nbsp;</div>
											<div id="followUp" style="display:none;">
<%
												org.openmdx.ui1.jmi1.FormDefinition followUpFormDefinition = app.getUiFormDefinition(Form.CREATE_FOLLOW_UP.getName());
												org.openmdx.portal.servlet.control.FormControl followUpForm = new org.openmdx.portal.servlet.control.FormControl(
													followUpFormDefinition.refGetPath().getBase(),
													app.getCurrentLocaleAsString(),
													app.getCurrentLocaleAsIndex(),
													app.getUiContext(),
													followUpFormDefinition
												);
												followUpForm.paint(
													p,
													null, // frame
													true // forEditing
												);
												p.flush();
%>
											</div>
<%																					
											// One div for each transition
											for(org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition transition: transitions) {
												if(!transition.getNextState().equals(activityProcess.getStartState())) {
													String transitionId = transition.refGetPath().getBase();
%>
													<div id='<%= transitionId %>' style='display:none;'>
														<input type="submit" class="abutton" tabindex="9070" value="<%= texts.getOkTitle() %>" onclick="javascript:$('<%= PARAMETER_SELECTED_OBJECT_XRI %>').value='<%= transition.refGetPath() %>';$('Command').value='<%= Command.DO_FOLLOWUP %>';" />
														<input type="button" class="abutton" tabIndex="9080" value="<%= texts.getCancelTitle() %>" onclick="javascript:$('<%= transitionId %>').style.display='none';$('<%= transitionId %>.Title').style.display='none';$('followUp').style.display='none';$('transitions').style.display='block';"></a>
													</div>
<%
												}
											}
										}
									}
%>									
									<div>&nbsp;</div>
<%									
									formCtrl.paint(
										p,
										null, // frame
										forEditing // forEditing
									);
									p.flush();

									if(command == Command.SEARCH_CONTACT) {
										if(matchingContacts != null) {
%>
											<div>&nbsp;</div>
											<table class="gridTableFull">
												<tr class="gridTableHeaderFull">
													<td class="gridColTypeIcon"/>
													<td><%= view.getShortLabel("org:opencrx:kernel:account1:Account", "fullName", app.getCurrentLocaleAsIndex()) %></td>
													<td />
													<td><%= view.getShortLabel("org:opencrx:kernel:account1:Account", "aliasName", app.getCurrentLocaleAsIndex()) %></td>
													<td><%= view.getShortLabel("org:opencrx:kernel:account1:Account", "address*Business!phoneNumberFull", app.getCurrentLocaleAsIndex()) %></td>
													<td><%= view.getShortLabel("org:opencrx:kernel:account1:Account", "address*Business!emailAddress", app.getCurrentLocaleAsIndex()) %></td>
													<td><%= view.getFieldLabel("org:opencrx:kernel:activity1:Activity", "lastTransition", app.getCurrentLocaleAsIndex()) %></td>
													<td />
													<td />
													<td />
													<td class="addon"/>
												</tr>
<%
												int count = 0;
												try {
													List<org.opencrx.kernel.account1.jmi1.Account> contacts = new ArrayList<org.opencrx.kernel.account1.jmi1.Account>();
													for(Iterator<?> i = matchingContacts.iterator(); i.hasNext(); ) {
													    Object object = i.next();
													    org.opencrx.kernel.account1.jmi1.Account contact = null;
													    if(object instanceof org.opencrx.kernel.account1.jmi1.Member) {
													    	contact = ((org.opencrx.kernel.account1.jmi1.Member)object).getAccount();
													    } else if(object instanceof org.opencrx.kernel.account1.jmi1.Contact) {
													    	contact = (org.opencrx.kernel.account1.jmi1.Contact)object;
													    } else if(object instanceof org.opencrx.kernel.activity1.jmi1.Activity) {
													    	contact = ((org.opencrx.kernel.activity1.jmi1.Activity)object).getReportingContact();
													    }
													    if(contact != null && !contacts.contains(contact)) {
													    	contacts.add(contact);
													    	org.opencrx.kernel.account1.jmi1.AccountAddress[] addresses = Accounts.getInstance().getMainAddresses(contact);
%>
															<tr class="gridTableRowFull <%= count % 2 == 0 ? "" : "gridTableFullhover" %>" onclick="javascript:$('<%= PARAMETER_SELECTED_OBJECT_XRI %>').value='<%= contact.refMofId() %>';$('Command').value='<%= Command.SELECT_CONTACT %>';$('<%= form.getName() %>').submit();">
																<td class="gridColTypeIcon"><img src="../../images/Contact.gif"/></td>
																<td><%= contact.getFullName() == null ? "" : contact.getFullName() %></td>
																<td><%= contactIsLocked(contact) ? "<img src='../../images/Lock.gif'>" : "" %></td>
																<td><%= contact.getAliasName() == null ? "" : contact.getAliasName() %></td>
																<td style="white-space: nowrap;"><%= new org.openmdx.portal.servlet.ObjectReference(addresses[Accounts.PHONE_BUSINESS], app).getTitle() %></td>
																<td style="white-space: nowrap;"><%= new org.openmdx.portal.servlet.ObjectReference(addresses[Accounts.MAIL_BUSINESS], app).getTitle() %></td>
<%
																if(object instanceof org.opencrx.kernel.activity1.jmi1.Activity) {
																	org.opencrx.kernel.activity1.jmi1.Activity activity = (org.opencrx.kernel.activity1.jmi1.Activity)object;
																	org.opencrx.kernel.activity1.cci2.ActivityFollowUpQuery followUpQuery = (org.opencrx.kernel.activity1.cci2.ActivityFollowUpQuery)pm.newQuery(org.opencrx.kernel.activity1.jmi1.ActivityFollowUp.class);
																	followUpQuery.orderByModifiedAt().descending();
																	List<org.opencrx.kernel.activity1.jmi1.ActivityFollowUp> followUps = activity.getFollowUp(followUpQuery);
																	String lastFollowUpTitle = followUps.isEmpty() ? null : followUps.iterator().next().getTitle();
%>															
																	<td style="white-space: nowrap;"><%= DateValue.getLocalizedDateTimeFormatter(null, false, app).format(activity.getModifiedAt()) %></td>
																	<td><%= new org.openmdx.portal.servlet.ObjectReference(activity.getProcessState(), app).getTitle() %></td>
																	<td><%= lastFollowUpTitle == null ? "" : lastFollowUpTitle %></td>
																	<td>#<%= activity.getActivityNumber() %></td>
<%
																} else {
%>
																	<td />
																	<td />
																	<td />
																	<td />
<%
																}
%>
																<td class="addon"/>
															</tr>
<%
															count++;
															if(count > showMaxContacts) break;
													    }
													}
												} catch(Exception e) {
													new ServiceException(e).log();
												}
%>
											</table>
<%
										}
									}
									else if(
										command == Command.SELECT_CONTACT &&
										wizardState.getSelectedContactIdentity() != null
									) {
										org.opencrx.kernel.account1.jmi1.Contact selectedContact = (org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(wizardState.getSelectedContactIdentity());
										// Show assigned activities
										List<org.opencrx.kernel.activity1.jmi1.ActivityProcessState> allowedProcessStates = null;
										if(wizardState.getAllowedProcessStates() != null) {
											allowedProcessStates = new ArrayList<org.opencrx.kernel.activity1.jmi1.ActivityProcessState>();
											for(Path allowedProcessStateIdentity: wizardState.getAllowedProcessStates()) {
												allowedProcessStates.add(
													(org.opencrx.kernel.activity1.jmi1.ActivityProcessState)pm.getObjectById(allowedProcessStateIdentity)
												);
											}
										}
										for(Activities.ActivityState activityState: Arrays.asList(Activities.ActivityState.OPEN, Activities.ActivityState.CLOSED, Activities.ActivityState.CANCELLED)) {
											SimpleDateFormat scheduledStartFormat = DateValue.getLocalizedDateTimeFormatter(
												"org:opencrx:kernel:activity1:Activity:scheduledStart",
												false,
												app
											);
											SimpleDateFormat dueByFormat = DateValue.getLocalizedDateTimeFormatter(
												"org:opencrx:kernel:activity1:Activity:dueBy",
												false,
												app
											);
											org.opencrx.kernel.activity1.cci2.ActivityQuery activityQuery = (org.opencrx.kernel.activity1.cci2.ActivityQuery)pm.newQuery(org.opencrx.kernel.activity1.jmi1.Activity.class);
											activityQuery.activityState().equalTo(activityState.getValue());
											activityQuery.thereExistsProcessState().elementOf(allowedProcessStates);
											activityQuery.orderByModifiedAt().descending();
											List<org.opencrx.kernel.activity1.jmi1.Activity> activities = selectedContact.getAssignedActivity(activityQuery);
											if(!activities.isEmpty()) {
%>
												<div>&nbsp;</div>
												<div><%= activityState.toString() %></div>
												<table class="gridTableFull">
													<tr class="gridTableHeaderFull">
														<td class="gridColTypeIcon"/>
														<td><%= view.getShortLabel("org:opencrx:kernel:activity1:Activity", "activityNumber", app.getCurrentLocaleAsIndex()) %></td>
														<td><%= view.getShortLabel("org:opencrx:kernel:activity1:Activity", "name", app.getCurrentLocaleAsIndex()) %></td>
														<td><%= view.getShortLabel("org:opencrx:kernel:activity1:Activity", "assignedTo", app.getCurrentLocaleAsIndex()) %></td>
														<td><%= view.getShortLabel("org:opencrx:kernel:activity1:Activity", "reportingContact", app.getCurrentLocaleAsIndex()) %></td>
														<td><%= view.getShortLabel("org:opencrx:kernel:activity1:Activity", "processState", app.getCurrentLocaleAsIndex()) %></td>
														<td><%= view.getShortLabel("org:opencrx:kernel:activity1:Activity", "scheduledStart", app.getCurrentLocaleAsIndex()) %></td>
														<td><%= view.getShortLabel("org:opencrx:kernel:activity1:Activity", "dueBy", app.getCurrentLocaleAsIndex()) %></td>
														<td class="addon"/>
													</tr>
<%
													int count = 0;
													for(org.opencrx.kernel.activity1.jmi1.Activity activity: activities) {
														String assignedTo = "N/A";
														try {
															assignedTo = new org.openmdx.portal.servlet.ObjectReference(activity.getAssignedTo(), app).getTitle();
														} catch(Exception e) {}
														String reportingContact = "N/A";
														try {
															reportingContact = new org.openmdx.portal.servlet.ObjectReference(activity.getReportingContact(), app).getTitle();
														} catch(Exception e) {}
														
%>
														<tr class="gridTableRowFull <%= count % 2 == 0 ? "" : "gridTableFullhover" %>" onclick="javascript:$('<%= PARAMETER_SELECTED_OBJECT_XRI %>').value='<%= activity.refMofId() %>';$('Command').value='<%= Command.SELECT_ACTIVITY %>';$('<%= form.getName() %>').submit();">
															<td class="gridColTypeIcon"><img src="../../images/Incident.gif"/></td>
															<td><%= activity.getActivityNumber() == null ? "" : activity.getActivityNumber() %></td>
															<td><%= activity.getName() == null ? "" : activity.getName() %></td>
															<td><%= assignedTo %></td>
															<td><%= reportingContact %></td>
															<td><%= new org.openmdx.portal.servlet.ObjectReference(activity.getProcessState(), app).getTitle() %></td>
															<td style="white-space: nowrap;"><%= activity.getScheduledStart() == null ? "" : scheduledStartFormat.format(activity.getScheduledStart()) %></td>
															<td style="white-space: nowrap;"><%= activity.getDueBy() == null ? "" : dueByFormat.format(activity.getDueBy()) %></td>
															<td class="addon"/>
														</tr>
<%
														count++;
														if(count > 20) break;
													}
%>
												</table>
<%
											}
										}
									}
									else if(
										command == Command.SELECT_ACTIVITY &&
										wizardState.getSelectedActivityIdentity() != null
									) {
										org.opencrx.kernel.activity1.jmi1.Activity selectedActivity = (org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(wizardState.getSelectedActivityIdentity());
%>										
										<div>&nbsp;</div>
										<table class="gridTableFull">
											<tr class="gridTableHeaderFull">
												<td class="gridColTypeIcon"/>
												<td><%= view.getShortLabel("org:opencrx:kernel:activity1:ActivityFollowUp", "title", app.getCurrentLocaleAsIndex()) %></td>
												<td><%= view.getShortLabel("org:opencrx:kernel:activity1:ActivityFollowUp", "text", app.getCurrentLocaleAsIndex()) %></td>
												<td class="addon"/>
											</tr>
<%										
											org.opencrx.kernel.activity1.cci2.ActivityFollowUpQuery followUpQuery = (org.opencrx.kernel.activity1.cci2.ActivityFollowUpQuery)pm.newQuery(org.opencrx.kernel.activity1.jmi1.ActivityFollowUp.class);
											followUpQuery.orderByCreatedAt().descending();
											List<org.opencrx.kernel.activity1.jmi1.ActivityFollowUp> followUps = selectedActivity.getFollowUp(followUpQuery);
											int count = 0;
											for(org.opencrx.kernel.activity1.jmi1.ActivityFollowUp followUp: followUps) {
												%>
												<tr class="gridTableRowFull <%= count % 2 == 0 ? "" : "gridTableFullhover" %>">
													<td class="gridColTypeIcon"><img src="../../images/ActivityFollowUp.gif" /></td>
													<td><%= new FormattedFollowUpDataBinding().getValue(followUp, null, app) %></td>
													<td><%= followUp.getTitle() == null ? "" : new FormattedNoteDataBinding().getValue(followUp, null, app) %></td>
													<td class="addon"/>
												</tr>
<%
												count++;
											}
%>
										</table>
<%
									}
%>
									<div class="fieldGroupName">&nbsp;</div>
								</div>
							</td>
						</tr>
					</table>
				</form>
			</div> <!-- content -->
		</div> <!-- content-wrap -->
	</div> <!-- wrap -->
</div> <!-- container -->			
<%
	p.close(false);
	if(pm != null) {
		pm.close();
	}
%>
