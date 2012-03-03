<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: UserSettings.jsp,v 1.69 2011/12/16 09:35:26 cmu Exp $
 * Description: UserSettings
 * Revision:    $Revision: 1.69 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/12/16 09:35:26 $
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
java.net.*,
java.text.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*,
org.openmdx.kernel.log.*,
org.opencrx.kernel.backend.*,
org.opencrx.kernel.layer.application.*,
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.openmdx.base.exception.*
" %>

<%

	//-----------------------------------------------------------------------
	final String WIZARD_NAME = "UserSettings.jsp";

	//-----------------------------------------------------------------------
	// Init
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
	javax.jdo.PersistenceManager pm = app.getNewPmData();
	String requestIdParam = Action.PARAMETER_REQUEST_ID + "=" + requestId;
	String xriParam = Action.PARAMETER_OBJECTXRI + "=" + objectXri;
	Texts_1_0 texts = app.getTexts();
	org.openmdx.portal.servlet.Codes codes = app.getCodes();

	// Get Parameters
	boolean actionSave = request.getParameter("Save.Button") != null;
	boolean actionCancel = request.getParameter("Cancel.Button") != null;
	String command = request.getParameter("command");

	RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
	// Get user home segment
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
	org.opencrx.kernel.home1.jmi1.Segment userHomeSegment = UserHomes.getInstance().getUserHomeSegment(pm, providerName, segmentName);
	org.opencrx.kernel.activity1.jmi1.Segment activitySegment = Activities.getInstance().getActivitySegment(pm, providerName, segmentName);
	org.opencrx.kernel.workflow1.jmi1.Segment workflowSegment = Workflows.getInstance().getWorkflowSegment(pm, providerName, segmentName);
	
	// Exit
	if("exit".equalsIgnoreCase(command)) {
		session.setAttribute(WIZARD_NAME, null);
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}

	if(false) {
	}
	// Other commands
	else {
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html dir="<%= texts.getDir() %>">
<head>
	<style type="text/css" media="all">
		body{font-family: Arial, Helvetica, sans-serif; padding: 0; margin:0;}
		h1{  margin: 0; padding: 0 1em; font-size: 150%;}
		h2{ font-size: 130%; margin: 0; text-align: center;}

		a{text-decoration: none;}
		img{border: none;}

		/* Main Navigation across the top */
		.nav{padding: 0; margin: 0 0 1em 0; }
		.nav li{display: inline; }
		.nav a{padding: 0 0.5em; border: 1px solid silver;}
		.nav a:hover,
		.nav a:focus{background-color: silver; border: 1px solid gray;}
		.nav.secondary {float: right;}

		#content{width: 80%; margin: 0 auto; font-size: 90%;}

    textarea,
    input[type='text'],
    input[type='password']{
    	width: 100%;
    	margin: 0; border: 1px solid silver;
    	padding: 0;
    	font-size: 100%;
    	font-family: Arial, Helvetica, sans-serif;
    }
    input.button{
    	-moz-border-radius: 4px;
    	-webkit-border-radius: 4px;
    	width: 120px;
    	border: 1px solid silver;
    }

		/* Add/Edit page specific settings */
		.col1,
		.col2{float: left; width: 49.5%;}

		.buttons{clear: both; text-align: left;}
		table{border-collapse: collapse; width: 100%; clear: both;}
		tr{}

		/* List page specific settings */
		table.listview tr{
			border: 1px solid #36c;
			border-style: solid none;
		}
		table.listview tr:hover{
			background-color: #F0F0F0;
		}

		div.letterBar {
			padding: 0.2em 0;
			text-align: center;
		}
		div.letterBar a,
		div.letterBar a:link,
		div.letterBar a:visited{
			padding: 0em 0.3em;
			border: 1px solid gray;
			-moz-border-radius: 6px;
			-webkit-border-radius: 6px;
			margin: 0 2px;
		}
		div.letterBar a:hover,
		div.letterBar a:focus{
			background-color: yellow;
		}

		div.letterBar a.current {
			background-color: #F0F0F0;
		}
	</style>
	<title>openCRX - User Settings</title>
	<meta name="UNUSEDlabel" content="User Settings">
	<meta name="UNUSEDtoolTip" content="User Settings">
	<meta name="targetType" content="_self">
	<meta name="forClass" content="org:opencrx:kernel:home1:UserHome">
  <meta name="order" content="org:opencrx:kernel:home1:UserHome:userSettings">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
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
    if (false) {
    //if (!currentUserIsAdmin) {
      Action nextAction = new ObjectReference(
        (RefObject_1_0)pm.getObjectById(new Path(objectXri)),
        app
      ).getSelectObjectAction();
%>
      <br />
      <br />
      <span style="color:red;"><b><u>Warning:</u> no permission to change user settings!</b></span>
      <br />
      <br />
      <INPUT type="Submit" name="Continue.Button" tabindex="1" value="Continue" onClick="javascript:location='<%= request.getContextPath() + "/" + nextAction.getEncodedHRef() %>';" />
      <br />
      <br />
      <hr>
            </div> <!-- content -->
          </div> <!-- content-wrap -->
      	<div> <!-- wrap -->
      </div> <!-- container -->
  	</body>
  	</html>
<%
      return;
    }

		// Account details
		if(true) {
			short locale =  app.getCurrentLocaleAsIndex();
			String localeAsString = app.getCurrentLocaleAsString();
			org.opencrx.kernel.home1.jmi1.UserHome userHome =  (org.opencrx.kernel.home1.jmi1.UserHome)pm.getObjectById(new Path(objectXri));
			boolean currentUserOwnsHome =
				app.getCurrentUserRole().equals(userHome.refGetPath().getBase() + "@" + segmentName);
			Properties userSettings =  new Properties();
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
			String fTimezone = request.getParameter("timezone");
			String fStoreSettingsOnLogoff = request.getParameter("storeSettingsOnLogoff");
			String fEmailAccount = request.getParameter("emailAccount");
			String fSendmailSubjectPrefix = request.getParameter("sendmailSubjectPrefix");
			String fWebAccessUrl = request.getParameter("webAccessUrl");
			String fTopNavigationShowMax = request.getParameter("topNavigationShowMax");
			String fShowTopNavigationSublevel = request.getParameter("showTopNavigationSublevel");
			String fGridDefaultAlignmentIsWide = request.getParameter("gridDefaultAlignmentIsWide");
			String fHideWorkspaceDashboard = request.getParameter("hideWorkspaceDashboard");
			
			List<String> fRootObjects = new ArrayList<String>();
			fRootObjects.add("1");
			for(int i = 1; i < 20; i++) {
				String state = request.getParameter("rootObject" + i);
				if(i < app.getRootObject().length && app.getRootObject()[i] instanceof org.opencrx.kernel.home1.jmi1.UserHome) {
					state = "1";
				}
				fRootObjects.add(
					state == null ? "0" : "1"
				);
			}
			Map<String,String> fSubscriptions = new HashMap<String,String>();
			Enumeration<String> parameterNames = request.getParameterNames();
			while(parameterNames.hasMoreElements()) {
				String parameterName = parameterNames.nextElement();
				if(
					parameterName.startsWith("topicIsActive-") ||
					parameterName.startsWith("topicCreation-") ||
					parameterName.startsWith("topicReplacement-") ||
					parameterName.startsWith("topicRemoval-")
				) {
					fSubscriptions.put(
						parameterName,
						request.getParameter(parameterName)
					);
				}
			}
			// Apply
			if("apply".equalsIgnoreCase(command)) {
				try {
					pm.currentTransaction().begin();
					org.opencrx.kernel.backend.UserHomes.getInstance().applyUserSettings(
						userHome,
						app.getCurrentPerspective(),
						userSettings,
						!currentUserOwnsHome, // noInitUserHome
						!currentUserOwnsHome, // Store settings if applied on 'foreign' user's home
						userHome.getPrimaryGroup(),
						fTimezone,
						fStoreSettingsOnLogoff,
						fEmailAccount,
						fSendmailSubjectPrefix,
						fWebAccessUrl,
						fTopNavigationShowMax,
						"on".equals(fShowTopNavigationSublevel),
						"on".equals(fGridDefaultAlignmentIsWide),
						"on".equals(fHideWorkspaceDashboard),
						fRootObjects,
						fSubscriptions
					);
					pm.currentTransaction().commit();
				}
				catch(Exception e) {
					new ServiceException(e).log();
					try {
						pm.currentTransaction().rollback();
					} catch(Exception e0) {}
				}
			}
%>
		<ul class="nav">
		</ul>
		<form method="post" action="<%= WIZARD_NAME %>">
			<input type="hidden" name="command" value="apply"/>
			<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>"/>
			<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
			<div class="col1">
				<fieldset>
					<legend>User Home</legend>
					<table>
						<tr><td><label for="timezone_sorttz">Timezone:</label> <img border='0' alt='' title='sorted by timezone' height='16px' src='../../images/filter_down_cal.gif' /></td>
						<td>
							<select id="timezone_sorttz" name="timezone_sorttz" onchange="javascript:
									document.getElementById('timezone').value=this.value;
									document.getElementById('timezone_sortAlpha').value=this.value;" 
							>
<%
    						String initiallySelectedTZ = userSettings.getProperty(UserSettings.TIMEZONE_NAME); //TimeZone.getTimeZone(app.getCurrentTimeZone()).getDisplayName();
								String[] timezones = java.util.TimeZone.getAvailableIDs();
                  for(int i = 0; i < timezones.length; i++) {
                    String timezoneID = timezones[i].trim();
                    String selectedModifier = "";
                    if (timezoneID.equals(userSettings.getProperty(UserSettings.TIMEZONE_NAME))) {
                    		selectedModifier = "selected";
                    		initiallySelectedTZ = timezoneID;
                    }
%>
  										<option  <%= selectedModifier %> value="<%= timezoneID %>"><%= timezoneID %>
<%
                  }
%>
							</select>
						</td></tr>
						<tr><td><label for="timezone_sortAlpha">Timezone:</label> <img border='0' alt='' title='sorted alphabetically' height='16px' src='../../images/filter_down_star.gif' /></td>
						<td>
							<select id="timezone_sortAlpha" name="timezone_sortAlpha" onchange="javascript:
									document.getElementById('timezone').value=this.value;
									document.getElementById('timezone_sorttz').value=this.value;" 
							>
<%
    						String[] timezonesAlpha = java.util.TimeZone.getAvailableIDs();
								java.util.Arrays.sort(timezonesAlpha, java.text.Collator.getInstance());

                  for(int i = 0; i < timezonesAlpha.length; i++) {
                    String timezoneID = timezonesAlpha[i].trim();
                    String selectedModifier = timezoneID.equals(userSettings.getProperty(UserSettings.TIMEZONE_NAME))
                      ? "selected"
                      : "";
%>
  										<option  <%= selectedModifier %> value="<%= timezoneID %>"><%= timezoneID %>
<%
                  }
%>
							</select>
							<input type="text" id="timezone" name="timezone"  value="<%= initiallySelectedTZ %>" style="width:0;visibility:hidden;" />
						</td></tr>
						<tr><td><label for="storeSettingsOnLogoff">Store settings on logoff:</label></td>
						<td><input type="checkbox" <%= userHome.isStoreSettingsOnLogoff() != null && userHome.isStoreSettingsOnLogoff().booleanValue() ? "checked" : "" %> id="storeSettingsOnLogoff" name="storeSettingsOnLogoff"/></td></tr>
<%
						org.opencrx.kernel.home1.cci2.EMailAccountQuery emailAccountQuery = (org.opencrx.kernel.home1.cci2.EMailAccountQuery)pm.newQuery(org.opencrx.kernel.home1.jmi1.EMailAccount.class);
						emailAccountQuery.thereExistsIsActive().isTrue();
						emailAccountQuery.thereExistsIsDefault().isTrue();
						List<org.opencrx.kernel.home1.jmi1.EMailAccount> emailAccounts = userHome.getEMailAccount(emailAccountQuery);
						org.opencrx.kernel.home1.jmi1.EMailAccount defaultEmailAccount = emailAccounts.isEmpty() ?
							null :
								emailAccounts.iterator().next();
%>
						<tr><td><label for="emailAccount">Email:</label></td>
						<td><input type="text" id="emailAccount" name="emailAccount"  value="<%= defaultEmailAccount == null || defaultEmailAccount.getName() == null ? "" :  defaultEmailAccount.getName() %>"/></td></tr>
						<tr><td><label for="sendmailSubjectPrefix">Sendmail subject prefix:</label></td>
						<td><input type="text" id="sendmailSubjectPrefix" name="sendmailSubjectPrefix"  value="<%= userHome.getSendMailSubjectPrefix() == null ? "[" + providerName + ":" + segmentName + "]" : userHome.getSendMailSubjectPrefix() %>"/>
						<tr><td><label for="webAccessUrl">Web access URL:</label></td>
						<td><input type="text" id="webAccessUrl" name="webAccessUrl"  value="<%= userHome.getWebAccessUrl() == null ? request.getRequestURL().substring(0, request.getRequestURL().indexOf("/wizards")) :  userHome.getWebAccessUrl()  %>"/>
					</table>
				</fieldset>
				<fieldset>
					<legend>Root Menu</legend>
					<table>
						<tr><td></td><td>Is&nbsp;Active:</td></tr>
<%
						Action[] rootObjectActions = app.getRootObjectActions();
						// Always show root object 0
						int n = 1;
						for(int i = 1; i < rootObjectActions.length; i++) {
							Action action = rootObjectActions[i];
							if(action.getParameter(Action.PARAMETER_REFERENCE).length() == 0) {
%>
								<tr><td><label for="rootObject<%= n %>"><%= action.getTitle() %>:</label></td><td>
								<input type="checkbox" <%= userSettings.getProperty(UserSettings.ROOT_OBJECT_STATE + (app.getCurrentPerspective() == 0 ? "" : "[" + Integer.toString(app.getCurrentPerspective()) + "]") + "." + n + ".State", "1").equals("1") ? "checked" : "" %> id="rootObject<%= n %>" name="rootObject<%= n %>"/></td></tr>
<%
								n++;
							}
						}
%>
						<tr><td><label for="topNavigationShowMax">Show max items in top navigation:</label></td><td>
						<input type="text" id="topNavigationShowMax" name="topNavigationShowMax" value="<%= userSettings.getProperty(UserSettings.TOP_NAVIGATION_SHOW_MAX, "6") %>"/></td></tr>

						<tr><td><label for="showTopNavigationSublevel">Show top navigation sub-levels:</label></td>
						<td><input type="checkbox" <%= "true".equals(userSettings.getProperty(UserSettings.TOP_NAVIGATION_SHOW_SUBLEVEL)) ? "checked" : "" %> id="showTopNavigationSublevel" name="showTopNavigationSublevel"/></td></tr>

						<tr><td><label for="gridDefaultAlignmentIsWide">Grid default alignment is wide:</label></td>
						<td><input type="checkbox" <%= "true".equals(userSettings.getProperty(UserSettings.GRID_DEFAULT_ALIGNMENT_IS_WIDE)) ? "checked" : "" %> id="gridDefaultAlignmentIsWide" name="gridDefaultAlignmentIsWide"/></td></tr>

						<tr><td><label for="hideWorkspaceDashboard">Hide workspace dashboard:</label></td>
						<td><input type="checkbox" <%= "true".equals(userSettings.getProperty(UserSettings.HIDE_WORKSPACE_DASHBOARD)) ? "checked" : "" %> id="hideWorkspaceDashboard" name="hideWorkspaceDashboard"/></td></tr>

					</table>
				</fieldset>
			</div>
			<div class="col2">
				<fieldset>
					<legend>Subscriptions</legend>
					<table>
						<tr><td></td><td></td><td colspan="3" style="background-color:#DDDDDD;text-align:center;">Notify on</td></tr>
						<tr><td></td><td>&nbsp;Is&nbsp;Active&nbsp;</td><td style="">&nbsp;Creation&nbsp;</td><td style="">&nbsp;Replacement&nbsp;</td><td style="">&nbsp;Removal&nbsp;</td></tr>
<%
                        org.opencrx.kernel.workflow1.cci2.TopicQuery topicQuery =
                            (org.opencrx.kernel.workflow1.cci2.TopicQuery)pm.newQuery(org.opencrx.kernel.workflow1.jmi1.Topic.class);
                        topicQuery.orderByName().ascending();
                        topicQuery.forAllDisabled().isFalse();

						for(Iterator i = workflowSegment.getTopic(topicQuery).iterator(); i.hasNext(); ) {
							org.opencrx.kernel.workflow1.jmi1.Topic topic = (org.opencrx.kernel.workflow1.jmi1.Topic)i.next();
							ObjectReference objRefTopic = new ObjectReference(topic, app);
							org.opencrx.kernel.home1.cci2.SubscriptionQuery query = (org.opencrx.kernel.home1.cci2.SubscriptionQuery)pm.newQuery(org.opencrx.kernel.home1.jmi1.Subscription.class);
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
%>
							<tr><td><label><%= objRefTopic.getTitle() %>:</label></td><td style="text-align:center;">
							<input type="checkbox" <%= subscription == null || !subscription.isActive() ? "" : "checked" %> id="topicIsActive-<%= topicId %>" name="topicIsActive-<%= topicId %>" /></td><td style="text-align:center;">
							<input type="checkbox" <%= eventTypes.contains(Integer.valueOf(1)) ? "checked" : "" %> id="topicCreation-<%= topicId %>" name="topicCreation-<%= topicId %>" /></td><td style="text-align:center;">
							<input type="checkbox" <%= eventTypes.contains(Integer.valueOf(3)) ? "checked" : "" %> id="topicReplacement-<%= topicId %>" name="topicReplacement-<%= topicId %>" /></td><td style="text-align:center;">
							<input type="checkbox" <%= eventTypes.contains(Integer.valueOf(4)) ? "checked" : "" %> id="topicRemoval-<%= topicId %>" name="topicRemoval-<%= topicId %>" /></td></tr>
<%
						}
%>
					</table>
				</fieldset>
			</div>
			<div class="buttons">
<%
				boolean currentUserIsAdmin =
					app.getCurrentUserRole().equals(org.opencrx.kernel.generic.SecurityKeys.ADMIN_PRINCIPAL + org.opencrx.kernel.generic.SecurityKeys.ID_SEPARATOR + segmentName + "@" + segmentName);
				boolean allowApply = currentUserIsAdmin || currentUserOwnsHome;
%>
				<input <%= allowApply ? "" : "disabled" %> type="submit" value="<%= app.getTexts().getSaveTitle() %>"  />
				<input type="button" value="<%= app.getTexts().getCloseText() %>" onclick="javascript:location.href='<%= WIZARD_NAME + "?" + requestIdParam + "&" + xriParam + "&command=exit" %>';" />
				<%= allowApply ? "" : "<h2>Apply not allowed! Non-ownership of user home and first time usage of wizard requires admin permissions.</h2>" %>
			</div>
		</form>
<%
		}
%>
            </div> <!-- content -->
          </div> <!-- content-wrap -->
        </div> <!-- wrap -->
      </div> <!-- container -->
  	</body>
  	</html>
<%
	}
    if(pm != null) {
    	pm.close();
    }
%>
