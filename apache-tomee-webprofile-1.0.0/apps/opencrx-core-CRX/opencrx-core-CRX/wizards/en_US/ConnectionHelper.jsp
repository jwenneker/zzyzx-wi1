<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     opencrx, http://www.opencrx.org/
 * Name:        $Id: ConnectionHelper.jsp,v 1.28 2011/11/28 14:18:20 wfro Exp $
 * Description: Generate vCard/iCal/CalDAV URLs
 * Revision:    $Revision: 1.28 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/11/28 14:18:20 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2009-2011 CRIXP Corp., Switzerland
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
java.util.zip.*,
java.io.*,
java.text.*,
java.math.*,
java.net.*,
java.sql.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.base.exception.*,
org.openmdx.kernel.id.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*,
org.openmdx.base.query.*,
org.openmdx.kernel.log.*
" %><%
	request.setCharacterEncoding("UTF-8");
	ApplicationContext app = (ApplicationContext)session.getValue("ObjectInspectorServlet.ApplicationContext");
	ViewsCache viewsCache = (ViewsCache)session.getValue(WebKeys.VIEW_CACHE_KEY_SHOW);
	String requestId =  request.getParameter(Action.PARAMETER_REQUEST_ID);
	String objectXri = request.getParameter(Action.PARAMETER_OBJECTXRI);
	if(app == null || objectXri == null || viewsCache.getView(requestId) == null) {
      response.sendRedirect(
         request.getContextPath() + "/" + WebKeys.SERVLET_NAME
      );
      return;
   }
   Texts_1_0 texts = app.getTexts();
   javax.jdo.PersistenceManager pm = app.getNewPmData();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>

<head>
  <title><%= app.getApplicationName() %> - Connection Helper: AirSync / Calendar / vCard / WebDAV</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta name="label" content="Connection Helper: AirSync/Calendar/vCard/WebDAV">
  <meta name="toolTip" content="Connection Helper: AirSync/Calendar/vCard/WebDAV">
  <meta name="targetType" content="_blank">
  <!-- calendars based on activities -->
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityTracker">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityCategory">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityMilestone">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityFilterGlobal">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityFilterGroup">
  <meta name="forClass" content="org:opencrx:kernel:activity1:Resource">
  <meta name="forClass" content="org:opencrx:kernel:home1:UserHome">
  <meta name="forClass" content="org:opencrx:kernel:home1:AirSyncProfile">
  <meta name="forClass" content="org:opencrx:kernel:home1:CalendarProfile">
  <!-- calendars based on contacts -->
  <meta name="forClass" content="org:opencrx:kernel:account1:AccountFilterGlobal"> <!-- bday -->
  <!-- webdav -->
  <meta name="forClass" content="org:opencrx:kernel:home1:DocumentProfile">
  <!-- carddav -->
  <meta name="forClass" content="org:opencrx:kernel:home1:CardProfile">

  <meta name="order" content="5998">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <script language="javascript" type="text/javascript" src="../../javascript/prototype.js"></script>
  <link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
  <link href="../../_style/colors.css" rel="stylesheet" type="text/css">
  <link rel='shortcut icon' href='../../images/favicon.ico' />

  <style type="text/css" media="all">
    TABLE.fieldGroup TD {
      vertical-align:middle;
    }
    .label {
      width:190px;
    }
  </style>
</head>

<%
  final String FORM_ACTION = "ConnectionHelper.jsp";
  NumberFormat formatter = new DecimalFormat("00000");
  final Integer MAX_ENTRY_SELECT = 200;

  try {
	  boolean isFirstCall = request.getParameter("isFirstCall") == null; // used to properly initialize various options
    boolean mustReload = request.getParameter("mustReload") != null;

    //System.out.println("must reload = " + mustReload);

    RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
    Path objectPath = obj.refGetPath();
    String providerName = objectPath.get(2);
    String segmentName = objectPath.get(4);
    UserDefinedView userView = new UserDefinedView(
        pm.getObjectById(new Path(objectXri)),
        app,
        viewsCache.getView(requestId)
    );

    String anchorObjectXri = request.getParameter("anchorObjectXri");
    if (!isFirstCall && (anchorObjectXri != null)) {
        try {
            obj = (RefObject_1_0)pm.getObjectById(new Path(anchorObjectXri));
        } catch (Exception e) {}
    }
    String type = request.getParameter("type") != null ? request.getParameter("type") : "";
    String selectorType = request.getParameter("selectorType") != null ? request.getParameter("selectorType") : "";

    //System.out.println("anchor = " + anchorObjectXri);
    //System.out.println("obj    = " + obj.refMofId());

    final String ACTIVITYTRACKER_CLASS = "org:opencrx:kernel:activity1:ActivityTracker";
    final String ACTIVITYCATEGORY_CLASS = "org:opencrx:kernel:activity1:ActivityCategory";
    final String ACTIVITYMILESTONE_CLASS = "org:opencrx:kernel:activity1:ActivityMilestone";
    final String ACTIVITYFILTERGROUP_CLASS = "org:opencrx:kernel:activity1:ActivityFilterGroup";
    final String ACTIVITYFILTERGLOBAL_CLASS = "org:opencrx:kernel:activity1:ActivityFilterGlobal";
    final String RESOURCE_CLASS = "org:opencrx:kernel:activity1:Resource";
    final String RESOURCEASSIGNMENT_CLASS = "org:opencrx:kernel:activity1:ResourceAssignment";
    final String USERHOME_CLASS = "org:opencrx:kernel:home1:UserHome";
    final String CALENDARPROFILE_CLASS = "org:opencrx:kernel:home1:CalendarProfile";
    final String ACCOUNTFILTERGLOBAL_CLASS = "org:opencrx:kernel:account1:AccountFilterGlobal";
    final String CONTACT_CLASS = "org:opencrx:kernel:account1:Contact";
    final String DOCUMENTPROFILE_CLASS = "org:opencrx:kernel:home1:DocumentProfile";
    final String CARDPROFILE_CLASS = "org:opencrx:kernel:home1:CardProfile";
    final String ABSTRACTPRICELEVEL_CLASS = "org:opencrx:kernel:product1:AbstractPriceLevel";

    final String HTML_COMMENT_BEGIN = "<!-- ";
    final String HTML_COMMENT_END = " -->";
    final String PROTOCOL_SPECIFIER_HTTP = "http:";
    final String PROTOCOL_SPECIFIER_HTTPS = "https:";
    final String UNKNOWN = "_?_";

    final String TYPE_AIRSYNC               = "AirSync";
    final String TYPE_CALENDAR              = "Calendar";
    final String TYPE_VCARD                 = "vCard";
    final String TYPE_WEBDAV                = "WebDAV";
    final String TYPE_CARDDAV               = "CardDAV";

    final String SELTYPE_TRACKER            = "tracker";
    final String SELTYPE_CATEGORY           = "category";
    final String SELTYPE_MILESTONE          = "milestone";
    final String SELTYPE_FILTERED           = "Filtered";
    final String SELTYPE_GLOBALFILTER       = "globalfilter";
    final String SELTYPE_USERHOME           = "userhome";
    final String SELTYPE_AIRSYNCPROFILE     = "airsyncprofile";
    final String SELTYPE_CALENDARPROFILE    = "calendarprofile";
    final String SELTYPE_RESOURCE           = "resource";
    final String SELTYPE_BDAY               = "bday";
    final String SELTYPE_VCARD              = "vcard";
    final String SELTYPE_DOCUMENTPROFILE    = "documentprofile";
    final String SELTYPE_CARDPROFILE        = "cardprofile";


    final String optionSourceFreebusy   = "freebusy";
    final String optionSourceActivities = "activities";
    final String optionSourceBdays      = "bdays";
    final String optionSourceVcards     = "accounts";
    final String optionSourceBdaysLText = "Birthdays";
    final String optionCategoriesDefault = "Birthday";
    final String optionSummaryPrefixDefault = "";
    final String optionTypeHtml = "html";
    final String optionTypeCalDAV = "CalDAV_VEVENT";        // VEVENT is the default
    final String optionTypeCalDAV_VTODO = "CalDAV_VTODO";   // VTODO by request
    final String optionTypeAirSync = "AirSync";
    final String optionTypeIcs  = "ics";
    final String optionTypeXml  = "xml";
    final String optionIcalTypeEvent= "VEVENT";
    final String optionIcalTypeTodo= "VTODO";

    final String optionValueTRUE  = "true";
    final String optionValueFALSE = "false";
    final String hintDefaultValue = "default";
    final String hintManualEntry = "enter value below";
    final String optionValueUSER = "USER";
    final String optionValueMANUAL = "MANUAL ENTRY";

    String urlBase = (request.getRequestURL().toString()).substring(0, (request.getRequestURL().toString()).indexOf(request.getServletPath().toString()));
    String groupComponent = "";
    String filterComponent = "";
    String typeFromInitialObject = "";
    String selectorTypeFromInitialObject = "";
    String anchorObjectXriFromInitialObject = "";
    String anchorObjectFilteredXriFromInitialObject = null;

    String target = "";
    String server = "";
    String path = "";
    String options = "";
                 
    String sourceType          = request.getParameter("sourceType")          != null ? request.getParameter("sourceType"         ) : optionSourceActivities;    // [freebusy|activities|bdays|webdav]
    String optionType          = request.getParameter("optionType")          != null ? request.getParameter("optionType"         ) : optionTypeIcs;             // [AirSync|CalDAV|ics|xml|html] activities
    String optionNonOwningUser = request.getParameter("optionNonOwningUser") != null ? request.getParameter("optionNonOwningUser") : optionValueFALSE;          // [true|false]     allow option .../user/<user>/...
    String optionUsernameEmail = request.getParameter("optionUsernameEmail") != null ? request.getParameter("optionUsernameEmail") : app.getLoginPrincipal(); // [user name|e-mail address] for option .../user/<user>/...
    String optionDisabled      = request.getParameter("optionDisabled")      != null ? request.getParameter("optionDisabled"     ) : optionValueFALSE;          // [true|false]     activities, freebusy
    String optionAlarm         = request.getParameter("optionAlarm")         != null ? request.getParameter("optionAlarm"        ) : optionValueFALSE;          // [true|false]     bdays
    String optionIcalType      = request.getParameter("optionIcalType")      != null ? request.getParameter("optionIcalType"     ) : optionIcalTypeEvent;       // [VTODO|VEVENT]   bdays
    String optionFreebusyAsCal = request.getParameter("optionFreebusyAsCal") != null ? request.getParameter("optionFreebusyAsCal") : optionValueFALSE;          // [true|false]     freebusy only vs. freebusy as calendar
    String optionFreebusyUser  = request.getParameter("optionFreebusyUser")  != null ? request.getParameter("optionFreebusyUser" ) : optionValueUSER;           // [USER or e-mail] freebusy with e-mail vs. username
    String optionMax           = request.getParameter("optionMax"     )      != null ? request.getParameter("optionMax"          ) : "";                        //                  bdays
    String optionCategories    = request.getParameter("optionCategories")    != null ? request.getParameter("optionCategories"   ) : optionCategoriesDefault;   //                  bdays
    String optionSummaryPrefix = request.getParameter("optionSummaryPrefix") != null ? request.getParameter("optionSummaryPrefix") : optionSummaryPrefixDefault;//                  bdays
    String optionYear          = request.getParameter("optionYear")          != null ? request.getParameter("optionYear"         ) : "";                        // YYYY             bdays

    String optionUserTz     = "GMT-0000";
    String optionUserLocale = "en_US";
    String optionHeight        = request.getParameter("optionHeight")        != null ? request.getParameter("optionHeight"       ) : "500";                  // in pixels        activities/xml

    String selectedAnchorObjectXRI = "";

    boolean supportsAccessByUser = true; // enable insertion of /user/<user>/ into URL

    int tabIndex = 0;

    // get current userHome
    org.opencrx.kernel.home1.jmi1.UserHome currentUserHome = (org.opencrx.kernel.home1.jmi1.UserHome)pm.getObjectById(app.getUserHomeIdentityAsPath());

    org.opencrx.kernel.account1.jmi1.Account1Package accountPkg = org.opencrx.kernel.utils.Utils.getAccountPackage(pm);
    org.opencrx.kernel.account1.jmi1.Segment accountSegment = (org.opencrx.kernel.account1.jmi1.Segment)pm.getObjectById(
        new Path("xri:@openmdx:org.opencrx.kernel.account1/provider/" + providerName + "/segment/" + segmentName)
    );
    org.opencrx.kernel.activity1.jmi1.Activity1Package activityPkg = org.opencrx.kernel.utils.Utils.getActivityPackage(pm);
    org.opencrx.kernel.activity1.jmi1.Segment activitySegment = (org.opencrx.kernel.activity1.jmi1.Segment)pm.getObjectById(
        new Path("xri:@openmdx:org.opencrx.kernel.activity1/provider/" + providerName + "/segment/" + segmentName)
    );
    org.opencrx.kernel.home1.jmi1.Home1Package homePkg = org.opencrx.kernel.utils.Utils.getHomePackage(pm);
    org.opencrx.kernel.home1.jmi1.Segment homeSegment = (org.opencrx.kernel.home1.jmi1.Segment)pm.getObjectById(
        new Path("xri:@openmdx:org.opencrx.kernel.home1/provider/" + providerName + "/segment/" + segmentName)
    );

    String nonOwningUserComponent = "";
    if ((optionNonOwningUser.compareTo(optionValueTRUE ) == 0) && (optionUsernameEmail != null) && (optionUsernameEmail.length() > 0)) {
    		nonOwningUserComponent = "/user/" + optionUsernameEmail;
    }

    // activity filter
    if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup) {
    	typeFromInitialObject = TYPE_CALENDAR;
    	selectorTypeFromInitialObject = SELTYPE_FILTERED;
      org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup activityFilterGroup =
        (org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup)obj;
      if ((activityFilterGroup.getName() != null) && (activityFilterGroup.getName().length() > 0)) {
        filterComponent = "/filter/" + URLEncoder.encode(activityFilterGroup.getName(), "UTF-8");
        anchorObjectXriFromInitialObject = activityFilterGroup.refMofId();
      }
      // set obj to parent object
      obj = (RefObject_1_0)pm.getObjectById(new Path(activityFilterGroup.refMofId()).getParent().getParent());
    }
    else if (obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal) {
      typeFromInitialObject = TYPE_CALENDAR;
      selectorTypeFromInitialObject = SELTYPE_GLOBALFILTER;
      org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal activityFilterGlobal =
        (org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal)obj;
      if ((activityFilterGlobal.getName() != null) && (activityFilterGlobal.getName().length() > 0)) {
        filterComponent = "/globalfilter/" + URLEncoder.encode(activityFilterGlobal.getName(), "UTF-8");
        anchorObjectFilteredXriFromInitialObject = activityFilterGlobal.refMofId();
      }
    }
    // activity group
    if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityTracker) {
      org.opencrx.kernel.activity1.jmi1.ActivityTracker activityTracker =
        (org.opencrx.kernel.activity1.jmi1.ActivityTracker)obj;
      if ((activityTracker.getName() != null) && (activityTracker.getName().length() > 0)) {
        groupComponent = "/tracker/" + URLEncoder.encode(activityTracker.getName(), "UTF-8");
        if (selectorTypeFromInitialObject.compareTo(SELTYPE_FILTERED) != 0) {
          anchorObjectXriFromInitialObject = activityTracker.refMofId();
        }
      }
      typeFromInitialObject = TYPE_CALENDAR;
      selectorTypeFromInitialObject = SELTYPE_TRACKER + selectorTypeFromInitialObject;
    }
    else if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityCategory) {
      org.opencrx.kernel.activity1.jmi1.ActivityCategory activityCategory =
        (org.opencrx.kernel.activity1.jmi1.ActivityCategory)obj;
      if ((activityCategory.getName() != null) && (activityCategory.getName().length() > 0)) {
        groupComponent = "/category/" + URLEncoder.encode(activityCategory.getName(), "UTF-8");
        if (selectorTypeFromInitialObject.compareTo(SELTYPE_FILTERED) != 0) {
          anchorObjectXriFromInitialObject = activityCategory.refMofId();
        }
      }
      typeFromInitialObject = TYPE_CALENDAR;
      selectorTypeFromInitialObject = SELTYPE_CATEGORY + selectorTypeFromInitialObject;
    }
    else if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityMilestone) {
      org.opencrx.kernel.activity1.jmi1.ActivityMilestone activityMilestone =
        (org.opencrx.kernel.activity1.jmi1.ActivityMilestone)obj;
      if ((activityMilestone.getName() != null) && (activityMilestone.getName().length() > 0)) {
        groupComponent = "/milestone/" + URLEncoder.encode(activityMilestone.getName(), "UTF-8");
        if (selectorTypeFromInitialObject.compareTo(SELTYPE_FILTERED) != 0) {
          anchorObjectXriFromInitialObject = activityMilestone.refMofId();
        }
      }
      typeFromInitialObject = TYPE_CALENDAR;
      selectorTypeFromInitialObject = SELTYPE_MILESTONE + selectorTypeFromInitialObject;
    }
    else if(obj instanceof org.opencrx.kernel.home1.jmi1.UserHome) {
        typeFromInitialObject = TYPE_CALENDAR;
        selectorTypeFromInitialObject = SELTYPE_USERHOME + selectorTypeFromInitialObject;
        groupComponent = "/userhome/" + (sourceType.compareTo(optionSourceFreebusy) == 0 
        	? (optionFreebusyUser.compareTo(optionValueMANUAL) == 0 ? optionUsernameEmail : optionFreebusyUser)
        	: URLEncoder.encode(obj.refGetPath().getBase(), "UTF-8")
        );
        if (isFirstCall) {
            anchorObjectXriFromInitialObject = ((org.opencrx.kernel.home1.jmi1.UserHome)obj).refMofId();
        }
    }
    else if(obj instanceof org.opencrx.kernel.home1.jmi1.CalendarProfile) {
        typeFromInitialObject = TYPE_CALENDAR;
        selectorTypeFromInitialObject = SELTYPE_CALENDARPROFILE + selectorTypeFromInitialObject;
        if (optionType.compareTo(optionTypeCalDAV_VTODO) != 0) {
            optionType = optionTypeCalDAV;
        }
        org.opencrx.kernel.home1.jmi1.SyncProfile syncProfile =
            (org.opencrx.kernel.home1.jmi1.SyncProfile)obj;
        if ((syncProfile.getName() != null) && (syncProfile.getName().length() > 0)) {
            // userhome is parent object of syncProfile --> get parent object
        	  org.opencrx.kernel.home1.jmi1.UserHome userHome =  (org.opencrx.kernel.home1.jmi1.UserHome)pm.getObjectById(new Path(obj.refMofId()).getParent().getParent());
            groupComponent = "/user/" + URLEncoder.encode(userHome.refGetPath().getBase(), "UTF-8") + "/profile/" + URLEncoder.encode(syncProfile.getName(), "UTF-8");
        }
    }
    else if(obj instanceof org.opencrx.kernel.home1.jmi1.DocumentProfile) {
        typeFromInitialObject = TYPE_WEBDAV;
        selectorTypeFromInitialObject = SELTYPE_DOCUMENTPROFILE + selectorTypeFromInitialObject;
        org.opencrx.kernel.home1.jmi1.SyncProfile syncProfile =
            (org.opencrx.kernel.home1.jmi1.SyncProfile)obj;
        if ((syncProfile.getName() != null) && (syncProfile.getName().length() > 0)) {
            // userhome is parent object of syncProfile --> get parent object
        	  org.opencrx.kernel.home1.jmi1.UserHome userHome =  (org.opencrx.kernel.home1.jmi1.UserHome)pm.getObjectById(new Path(obj.refMofId()).getParent().getParent());
            //groupComponent = "/user/" + URLEncoder.encode(userHome.refGetPath().getBase(), "UTF-8") + "/profile/" + URLEncoder.encode(syncProfile.getName(), "UTF-8");
            groupComponent = "/user/" + URLEncoder.encode(userHome.refGetPath().getBase(), "UTF-8") + "/profile/" + syncProfile.getName();
        }
    }
    else if(obj instanceof org.opencrx.kernel.home1.jmi1.SyncProfile || obj instanceof org.opencrx.kernel.home1.jmi1.AirSyncProfile) {
        typeFromInitialObject = TYPE_AIRSYNC;
        selectorTypeFromInitialObject = SELTYPE_AIRSYNCPROFILE + selectorTypeFromInitialObject;
        //optionType = optionTypeAirSync;
        org.opencrx.kernel.home1.jmi1.SyncProfile syncProfile =
            (org.opencrx.kernel.home1.jmi1.SyncProfile)obj;
        if ((syncProfile.getName() != null) && (syncProfile.getName().length() > 0)) {
            // userhome is parent object of syncProfile --> get parent object
        	  org.opencrx.kernel.home1.jmi1.UserHome userHome =  (org.opencrx.kernel.home1.jmi1.UserHome)pm.getObjectById(new Path(obj.refMofId()).getParent().getParent());
            groupComponent = "/user/" + URLEncoder.encode(userHome.refGetPath().getBase(), "UTF-8") + "/profile/" + URLEncoder.encode(syncProfile.getName(), "UTF-8");
        }
    }
    else if(obj instanceof org.opencrx.kernel.activity1.jmi1.Resource) {
      typeFromInitialObject = TYPE_CALENDAR;
      selectorTypeFromInitialObject = SELTYPE_RESOURCE + selectorTypeFromInitialObject;
      org.opencrx.kernel.activity1.jmi1.Resource resource =
        (org.opencrx.kernel.activity1.jmi1.Resource)obj;
      if ((resource.getName() != null) && (resource.getName().length() > 0)) {
        groupComponent = "/resource/" + URLEncoder.encode(resource.getName(), "UTF-8");
      }
    }
    else if (obj instanceof org.opencrx.kernel.account1.jmi1.AccountFilterGlobal) {
        if (type.compareTo(TYPE_VCARD) == 0) {
            typeFromInitialObject = TYPE_VCARD;
            selectorTypeFromInitialObject = SELTYPE_VCARD;
            sourceType = optionSourceVcards;
            options = "&type=vcf";
        } else {
            typeFromInitialObject = TYPE_CALENDAR;
            selectorTypeFromInitialObject = SELTYPE_BDAY;
            sourceType = optionSourceBdays;
        }
        org.opencrx.kernel.account1.jmi1.AccountFilterGlobal accountFilterGlobal =
          (org.opencrx.kernel.account1.jmi1.AccountFilterGlobal)obj;
        if ((accountFilterGlobal.getName() != null) && (accountFilterGlobal.getName().length() > 0)) {
          filterComponent = "/filter/" + URLEncoder.encode(accountFilterGlobal.getName(), "UTF-8");
          anchorObjectFilteredXriFromInitialObject = accountFilterGlobal.refMofId();
        }
    }

    if (anchorObjectFilteredXriFromInitialObject != null) {
        anchorObjectXriFromInitialObject = anchorObjectFilteredXriFromInitialObject;
    }

    type = request.getParameter("type") != null ? request.getParameter("type") : typeFromInitialObject;
    selectorType = request.getParameter("selectorType") != null ? request.getParameter("selectorType") : selectorTypeFromInitialObject;
    String anchorObjectLabel = "Anchor object";

    if (sourceType.compareTo(optionSourceFreebusy) == 0) {
    		supportsAccessByUser = false;
    }

    if (type.compareTo(optionTypeAirSync) == 0) {
        target = urlBase.replace("-core-", "-airsync-") + "/Microsoft-Server-ActiveSync/";
        /* selectorType = SELTYPE_AIRSYNCPROFILE; */
        java.security.cert.X509Certificate certs [] = (java.security.cert.X509Certificate [])
          request.getAttribute("javax.servlet.request.X509Certificate");
        server = request.getServerName() + ":" + request.getServerPort() + request.getContextPath().replace("-core-", "-airsync-") + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[SSL " + (urlBase.contains(PROTOCOL_SPECIFIER_HTTPS) ? "yes" : "no") + "]";
        //server = request.getServerName() + ":" + request.getServerPort() + request.getContextPath().replace("-core-", "-airsync-") + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[SSL " + ((certs != null) && (certs.length > 0) ? "yes" : "no") + "]";
				supportsAccessByUser = false;
    } else if ((groupComponent.length() > 0) || (filterComponent.length() > 0)) {
        if (type.compareTo(TYPE_CALENDAR) == 0) {
            if ((optionType.compareTo(optionTypeCalDAV) == 0 || optionType.compareTo(optionTypeCalDAV_VTODO) == 0 || (obj instanceof org.opencrx.kernel.home1.jmi1.SyncProfile || obj instanceof org.opencrx.kernel.home1.jmi1.AirSyncProfile)) && (sourceType.compareTo(optionSourceActivities) == 0)) {
                target =
                    urlBase.replace("-core-", "-caldav-") + "/" +
                    providerName + "/" + segmentName + (supportsAccessByUser ? nonOwningUserComponent : "") +
                    groupComponent + filterComponent + (optionType.compareTo(optionTypeCalDAV_VTODO) == 0 ? "/" + optionIcalTypeTodo : "");
            } else {
                target =
                    urlBase.replace("-core-", "-ical-") + "/" + sourceType + "?id=" +
                    providerName + "/" + segmentName + (supportsAccessByUser ? nonOwningUserComponent : "") +
                    groupComponent + filterComponent;
            }
        } else if (type.compareTo(TYPE_VCARD) == 0) {
            target =
                urlBase.replace("-core-", "-vcard-") + "/" + sourceType + "?id=" +
                providerName + "/" + segmentName +
                groupComponent + filterComponent;
            supportsAccessByUser = false;
        } else if (type.compareTo(TYPE_WEBDAV) == 0) {
		        server = request.getServerName() + ":" + request.getServerPort() + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[SSL " + (urlBase.contains(PROTOCOL_SPECIFIER_HTTPS) ? "yes" : "no") + "]";
		        path = request.getContextPath().replace("-core-", "-webdav-") + "/" +
		        providerName + "/" + segmentName +
            groupComponent + filterComponent;
            target =
                urlBase.replace("-core-", "-webdav-").replace("http:", "webdav:").replace("https:", "webdavs:") + "/" +
				        providerName + "/" + segmentName +
                groupComponent + filterComponent;
            supportsAccessByUser = false;
        }
    } else {
        target = "";
        supportsAccessByUser = false;
    }

    Map orderedanchorObjects = new TreeMap();

    if (selectorType.compareTo(SELTYPE_TRACKER) == 0) {
        anchorObjectLabel = app.getLabel(ACTIVITYTRACKER_CLASS);
        // get ActivityTrackers (not disabled)
        org.opencrx.kernel.activity1.cci2.ActivityTrackerQuery trackerFilter = activityPkg.createActivityTrackerQuery();
        trackerFilter.forAllDisabled().isFalse();
        int index = 0;
        for(Iterator i = activitySegment.getActivityTracker(trackerFilter).iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)i.next();
            String display = (ag.getName() != null ? ag.getName() : UNKNOWN);
            String sortKey = display.toUpperCase() + formatter.format(index++);
            orderedanchorObjects.put(
                HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                ag.refMofId()
            );
        }
    } else if (selectorType.compareTo(SELTYPE_TRACKER + SELTYPE_FILTERED) == 0) {
        anchorObjectLabel = app.getLabel(ACTIVITYTRACKER_CLASS);
        // get ActivityFilters of ActivityTrackers (not disabled)
        org.opencrx.kernel.activity1.cci2.ActivityTrackerQuery trackerFilter = activityPkg.createActivityTrackerQuery();
        trackerFilter.forAllDisabled().isFalse();
        int index = 0;
        for(Iterator i = activitySegment.getActivityTracker(trackerFilter).iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)i.next();
            for(Iterator j = ag.getActivityFilter().iterator(); j.hasNext() && index < MAX_ENTRY_SELECT; ) {
                org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup afg = (org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup)j.next();
                String display = (ag.getName() != null ? ag.getName() : UNKNOWN) + " &lt;" + (afg.getName() != null ? afg.getName() : UNKNOWN) + "&gt;";
                String sortKey = display.toUpperCase() + formatter.format(index++);
                orderedanchorObjects.put(
                    HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                    afg.refMofId()
                );
            }
        }
    } else if (selectorType.compareTo(SELTYPE_CATEGORY) == 0) {
        anchorObjectLabel = app.getLabel(ACTIVITYCATEGORY_CLASS);
        // get ActivityCategories (not disabled)
        org.opencrx.kernel.activity1.cci2.ActivityCategoryQuery categoryFilter = activityPkg.createActivityCategoryQuery();
        categoryFilter.forAllDisabled().isFalse();
        int index = 0;
        for(Iterator i = activitySegment.getActivityCategory(categoryFilter).iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)i.next();
            String display = (ag.getName() != null ? ag.getName() : UNKNOWN);
            String sortKey = display.toUpperCase() + formatter.format(index++);
            orderedanchorObjects.put(
                HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                ag.refMofId()
            );
        }
    } else if (selectorType.compareTo(SELTYPE_CATEGORY + SELTYPE_FILTERED) == 0) {
        anchorObjectLabel = app.getLabel(ACTIVITYCATEGORY_CLASS);
        // get ActivityFilters of ActivityCategories (not disabled)
        org.opencrx.kernel.activity1.cci2.ActivityCategoryQuery categoryFilter = activityPkg.createActivityCategoryQuery();
        categoryFilter.forAllDisabled().isFalse();
        int index = 0;
        for(Iterator i = activitySegment.getActivityCategory(categoryFilter).iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)i.next();
            for(Iterator j = ag.getActivityFilter().iterator(); j.hasNext() && index < MAX_ENTRY_SELECT; ) {
                org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup afg = (org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup)j.next();
                String display = (ag.getName() != null ? ag.getName() : UNKNOWN) + " &lt;" + (afg.getName() != null ? afg.getName() : UNKNOWN) + "&gt;";
                String sortKey = display.toUpperCase() + formatter.format(index++);
                orderedanchorObjects.put(
                    HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                    afg.refMofId()
                );
            }
        }
    } else if (selectorType.compareTo(SELTYPE_MILESTONE) == 0) {
        anchorObjectLabel = app.getLabel(ACTIVITYMILESTONE_CLASS);
        // get ActivityMilestones (not disabled)
        org.opencrx.kernel.activity1.cci2.ActivityMilestoneQuery milestoneFilter = activityPkg.createActivityMilestoneQuery();
        milestoneFilter.forAllDisabled().isFalse();
        int index = 0;
        for(Iterator i = activitySegment.getActivityMilestone(milestoneFilter).iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)i.next();
            String display = (ag.getName() != null ? ag.getName() : UNKNOWN);
            String sortKey = display.toUpperCase() + formatter.format(index++);
            orderedanchorObjects.put(
                HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                ag.refMofId()
            );
        }
    } else if (selectorType.compareTo(SELTYPE_MILESTONE + SELTYPE_FILTERED) == 0) {
        anchorObjectLabel = app.getLabel(ACTIVITYMILESTONE_CLASS);
        // get ActivityFilters of ActivityMilestones (not disabled)
        org.opencrx.kernel.activity1.cci2.ActivityMilestoneQuery milestoneFilter = activityPkg.createActivityMilestoneQuery();
        milestoneFilter.forAllDisabled().isFalse();
        int index = 0;
        for(Iterator i = activitySegment.getActivityMilestone(milestoneFilter).iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)i.next();
            for(Iterator j = ag.getActivityFilter().iterator(); j.hasNext() && index < MAX_ENTRY_SELECT; ) {
                org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup afg = (org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup)j.next();
                String display = (ag.getName() != null ? ag.getName() : UNKNOWN) + " &lt;" + (afg.getName() != null ? afg.getName() : UNKNOWN) + "&gt;";
                String sortKey = display.toUpperCase() + formatter.format(index++);
                orderedanchorObjects.put(
                    HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                    afg.refMofId()
                );
            }
        }
    } else if (selectorType.compareTo(SELTYPE_GLOBALFILTER) == 0) {
        anchorObjectLabel = app.getLabel(ACTIVITYFILTERGLOBAL_CLASS);
        // get ActivityTrackers (not disabled)
        org.opencrx.kernel.activity1.cci2.ActivityFilterGlobalQuery activityFilter = activityPkg.createActivityFilterGlobalQuery();
        activityFilter.forAllDisabled().isFalse();
        int index = 0;
        for(Iterator i = activitySegment.getActivityFilter(activityFilter).iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal af = (org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal)i.next();
            String display = (af.getName() != null ? af.getName() : UNKNOWN);
            String sortKey = display.toUpperCase() + formatter.format(index++);
            orderedanchorObjects.put(
                HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                af.refMofId()
            );
        }
    } else if (selectorType.compareTo(SELTYPE_USERHOME) == 0) {
        anchorObjectLabel = app.getLabel(USERHOME_CLASS);
        // get UserHomes
        int index = 0;
        for(Iterator i = homeSegment.getUserHome().iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.home1.jmi1.UserHome userHome = (org.opencrx.kernel.home1.jmi1.UserHome)i.next();
            org.opencrx.kernel.account1.jmi1.Contact contact = null;
            try {
                contact = userHome.getContact();
            } catch (Exception e) {}
            String principal = userHome.refGetPath().getBase();
            String display = (contact != null && contact.getFullName() != null ? contact.getFullName() : UNKNOWN) + " [" + principal + "]";
            String sortKey = display.toUpperCase() + formatter.format(index++);
            orderedanchorObjects.put(
                HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                userHome.refMofId()
            );
        }
    } else if (selectorType.compareTo(SELTYPE_CALENDARPROFILE) == 0) {
        anchorObjectLabel = app.getLabel(CALENDARPROFILE_CLASS);
        org.opencrx.kernel.account1.jmi1.Contact contact = null;
        try {
            contact = currentUserHome.getContact();
        } catch (Exception e) {}
        String principal = currentUserHome.refGetPath().getBase();
        int index = 0;
        for(Iterator i = currentUserHome.getSyncProfile().iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.home1.jmi1.SyncProfile syncProfile = (org.opencrx.kernel.home1.jmi1.SyncProfile)i.next();
            String display = (syncProfile.getName() != null ? syncProfile.getName() : "?")
              + (syncProfile instanceof org.opencrx.kernel.home1.jmi1.DocumentProfile ? " {WebDAV}" : (syncProfile instanceof org.opencrx.kernel.home1.jmi1.CalendarProfile ? " {CalDAV}" : " {AirSync}"))
              + " [" + (contact != null && contact.getFullName() != null ? contact.getFullName() : UNKNOWN) + " /" + principal + "]";
            String sortKey = display.toUpperCase() + formatter.format(index++);
            orderedanchorObjects.put(
                HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                syncProfile.refMofId()
            );
        }
    } else if (selectorType.compareTo(SELTYPE_AIRSYNCPROFILE) == 0) {
        anchorObjectLabel = optionTypeAirSync;
        int index = 0;
        for(Iterator i = currentUserHome.getSyncProfile().iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.home1.jmi1.SyncProfile syncProfile = (org.opencrx.kernel.home1.jmi1.SyncProfile)i.next();
            if (
                (syncProfile instanceof org.opencrx.kernel.home1.jmi1.AirSyncProfile) &&
                (syncProfile.getName() != null && syncProfile.getName().compareTo(TYPE_AIRSYNC) == 0)
            ) {
                String display = (syncProfile.getName() != null ? syncProfile.getName() : "?");
                String sortKey = display.toUpperCase() + formatter.format(index++);
                orderedanchorObjects.put(
                    HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                    syncProfile.refMofId()
                );
            }
        }
    } else if (selectorType.compareTo(SELTYPE_RESOURCE) == 0) {
        anchorObjectLabel = app.getLabel(RESOURCE_CLASS);
        // get Resources (not disabled)
        org.opencrx.kernel.activity1.cci2.ResourceQuery resourceFilter = activityPkg.createResourceQuery();
        resourceFilter.forAllDisabled().isFalse();
        int index = 0;
        for(Iterator i = activitySegment.getResource(resourceFilter).iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.activity1.jmi1.Resource resource = (org.opencrx.kernel.activity1.jmi1.Resource)i.next();
            org.opencrx.kernel.account1.jmi1.Contact contact = resource.getContact();
            String display = (resource.getName() != null ? resource.getName() : UNKNOWN) + " [" + (contact != null && contact.getFullName() != null ? contact.getFullName() : UNKNOWN) + "]";
            String sortKey = display.toUpperCase() + formatter.format(index++);
            orderedanchorObjects.put(
                HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                resource.refMofId()
            );
        }
    } else if ((selectorType.compareTo(SELTYPE_BDAY) == 0) || (selectorType.compareTo(SELTYPE_VCARD) == 0)) {
        anchorObjectLabel = app.getLabel(ACCOUNTFILTERGLOBAL_CLASS);
        // get AccountFilterGlobals (not disabled)
        org.opencrx.kernel.account1.cci2.AccountFilterGlobalQuery accountFilter = accountPkg.createAccountFilterGlobalQuery();
        accountFilter.forAllDisabled().isFalse();
        int index = 0;
        for(Iterator i = accountSegment.getAccountFilter(accountFilter).iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.account1.jmi1.AccountFilterGlobal af = (org.opencrx.kernel.account1.jmi1.AccountFilterGlobal)i.next();
            String display = (af.getName() != null ? af.getName() : UNKNOWN);
            String sortKey = display.toUpperCase() + formatter.format(index++);
            orderedanchorObjects.put(
                HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                af.refMofId()
            );
        }
    } else if (selectorType.compareTo(SELTYPE_DOCUMENTPROFILE) == 0) {
        anchorObjectLabel = app.getLabel(DOCUMENTPROFILE_CLASS);
        org.opencrx.kernel.account1.jmi1.Contact contact = null;
        try {
            contact = currentUserHome.getContact();
        } catch (Exception e) {}
        String principal = currentUserHome.refGetPath().getBase();
        int index = 0;
        for(Iterator i = currentUserHome.getSyncProfile().iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
            org.opencrx.kernel.home1.jmi1.SyncProfile syncProfile = (org.opencrx.kernel.home1.jmi1.SyncProfile)i.next();
            if (syncProfile instanceof org.opencrx.kernel.home1.jmi1.DocumentProfile) {
                String display = (syncProfile.getName() != null ? syncProfile.getName() : "?");
                String sortKey = display.toUpperCase() + formatter.format(index++);
                orderedanchorObjects.put(
                    HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
                    syncProfile.refMofId()
                );
            }
        }
    }
%>
    <body onload="initPage();">
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
          <form name="ConnectionHelper" accept-charset="UTF-8" method="POST" action="<%= FORM_ACTION %>">
            <input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
            <input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
            <input type="checkbox" style="display:none;" id="isFirstCall" name="isFirstCall" checked />
            <input type="checkbox" style="display:none;" id="mustReload" name="mustReload" />

            <div style="background-color:#F4F4F4;border:1px solid #EBEBEB;padding:10px;margin-top:15px;">

                <table class="fieldGroup">
                  <tr>
                    <td class="label"><span class="nw"><%= userView.getFieldLabel(RESOURCEASSIGNMENT_CLASS, "resourceRole", app.getCurrentLocaleAsIndex()) %>:</span></td>
                    <td>
                        <select class="valueL" id="type" name="type" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('mustReload').checked = true;$('reload.button').click();">
                            <option <%= type.compareTo(TYPE_AIRSYNC ) == 0 ? "selected" : "" %> value="<%= TYPE_AIRSYNC  %>"><%= TYPE_AIRSYNC  %></option>
                            <option <%= type.compareTo(TYPE_CALENDAR) == 0 ? "selected" : "" %> value="<%= TYPE_CALENDAR %>"><%= TYPE_CALENDAR %></option>
                            <option <%= type.compareTo(TYPE_VCARD   ) == 0 ? "selected" : "" %> value="<%= TYPE_VCARD    %>"><%= TYPE_VCARD    %></option>
                            <option <%= type.compareTo(TYPE_WEBDAV  ) == 0 ? "selected" : "" %> value="<%= TYPE_WEBDAV   %>"><%= TYPE_WEBDAV   %></option>
                        </select>
                    </td>
                    <td class="addon"></td>
                  </tr>

                  <tr <%= type.compareTo(TYPE_AIRSYNC) == 0 ? "style='display:none;'" : "" %>>
<%
                    if (type.compareTo(TYPE_CALENDAR) == 0) {
%>
                        <td class="label"><span class="nw"><%= userView.getFieldLabel(ABSTRACTPRICELEVEL_CLASS, "basedOn", app.getCurrentLocaleAsIndex()) %>:</span></td>
                        <td>
                            <select class="valueL" id="selectorType" name="selectorType" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('reload.button').click();">
                                <option <%= selectorType.compareTo(SELTYPE_TRACKER                     ) == 0 ? "selected" : "" %> value="<%= SELTYPE_TRACKER                      %>"><%= app.getLabel(ACTIVITYTRACKER_CLASS)      %></option>
                                <option <%= selectorType.compareTo(SELTYPE_TRACKER + SELTYPE_FILTERED  ) == 0 ? "selected" : "" %> value="<%= SELTYPE_TRACKER + SELTYPE_FILTERED   %>"><%= app.getLabel(ACTIVITYTRACKER_CLASS)      %> &lt;<%= app.getLabel(ACTIVITYFILTERGROUP_CLASS) %>&gt;</option>
                                <option <%= selectorType.compareTo(SELTYPE_CATEGORY                    ) == 0 ? "selected" : "" %> value="<%= SELTYPE_CATEGORY                     %>"><%= app.getLabel(ACTIVITYCATEGORY_CLASS)     %></option>
                                <option <%= selectorType.compareTo(SELTYPE_CATEGORY + SELTYPE_FILTERED ) == 0 ? "selected" : "" %> value="<%= SELTYPE_CATEGORY + SELTYPE_FILTERED  %>"><%= app.getLabel(ACTIVITYCATEGORY_CLASS)     %> &lt;<%= app.getLabel(ACTIVITYFILTERGROUP_CLASS) %>&gt;</option>
                                <option <%= selectorType.compareTo(SELTYPE_MILESTONE                   ) == 0 ? "selected" : "" %> value="<%= SELTYPE_MILESTONE                    %>"><%= app.getLabel(ACTIVITYMILESTONE_CLASS)    %></option>
                                <option <%= selectorType.compareTo(SELTYPE_MILESTONE + SELTYPE_FILTERED) == 0 ? "selected" : "" %> value="<%= SELTYPE_MILESTONE + SELTYPE_FILTERED %>"><%= app.getLabel(ACTIVITYMILESTONE_CLASS)    %> &lt;<%= app.getLabel(ACTIVITYFILTERGROUP_CLASS) %>&gt;</option>
                                <option <%= selectorType.compareTo(SELTYPE_GLOBALFILTER                ) == 0 ? "selected" : "" %> value="<%= SELTYPE_GLOBALFILTER                 %>"><%= app.getLabel(ACTIVITYFILTERGLOBAL_CLASS) %></option>
                                <option <%= selectorType.compareTo(SELTYPE_USERHOME                    ) == 0 ? "selected" : "" %> value="<%= SELTYPE_USERHOME                     %>"><%= app.getLabel(USERHOME_CLASS)             %></option>
                                <option <%= selectorType.compareTo(SELTYPE_CALENDARPROFILE             ) == 0 ? "selected" : "" %> value="<%= SELTYPE_CALENDARPROFILE              %>">CalDAV <%= app.getLabel(CALENDARPROFILE_CLASS) %></option>
                                <option <%= selectorType.compareTo(SELTYPE_RESOURCE                    ) == 0 ? "selected" : "" %> value="<%= SELTYPE_RESOURCE                     %>"><%= app.getLabel(RESOURCE_CLASS)             %></option>
                                <option <%= selectorType.compareTo(SELTYPE_BDAY                        ) == 0 ? "selected" : "" %> value="<%= SELTYPE_BDAY                         %>"><%= app.getLabel(ACCOUNTFILTERGLOBAL_CLASS)  %> / <%= userView.getFieldLabel(CONTACT_CLASS, "birthdate", app.getCurrentLocaleAsIndex()) %></option>
                            </select>
                        </td>
                        <td class="addon"></td>
<%
                    } else if (type.compareTo(TYPE_WEBDAV) == 0) {
%>
                        <td class="label"><span class="nw">Selector type:</span></td>
                        <td>
                            <select class="valueL" id="selectorType" name="selectorType" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('reload.button').click();">
                                <option <%= selectorType.compareTo(SELTYPE_DOCUMENTPROFILE) == 0 ? "selected" : "" %> value="<%= SELTYPE_DOCUMENTPROFILE %>"><%= app.getLabel(DOCUMENTPROFILE_CLASS)  %></option>
                            </select>
                        </td>
                        <td class="addon"></td>
<%
                    } else {
%>
                        <td class="label"><span class="nw">Selector type:</span></td>
                        <td>
                            <select class="valueL" id="selectorType" name="selectorType" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('reload.button').click();">
                                <option <%= selectorType.compareTo(SELTYPE_VCARD) == 0 ? "selected" : "" %> value="<%= SELTYPE_VCARD %>"><%= app.getLabel(ACCOUNTFILTERGLOBAL_CLASS)  %></option>
                            </select>
                        </td>
                        <td class="addon"></td>
<%
                    }
%>
                  </tr>

                  <tr <%= type.compareTo(TYPE_AIRSYNC) == 0 ? "style='display:none;'" : "" %>>
                    <td class="label"><span class="nw"><%= anchorObjectLabel %>:</span></td>
                    <td>
<%
                        if (orderedanchorObjects.isEmpty()) {
                            target = "";
%>
                            <select class="valueL" id="anchorObjectXri" name="anchorObjectXri" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('reload.button').click();">
                                <option value="">--</option>
                            </select>
<%
                        } else {
%>
                            <select class="valueL" id="anchorObjectXri" name="anchorObjectXri" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('reload.button').click();">
<%
                                boolean hasSelection = false;
                                for (
                                		Iterator i = orderedanchorObjects.keySet().iterator();
                                		i.hasNext();
                                ) {
                                    String key = (String)i.next();
                                    String value = (String)orderedanchorObjects.get(key);
                                    boolean selected = ((anchorObjectXri != null) && (value != null) && (anchorObjectXri.compareTo(value) == 0)) ||
                                                       //(isFirstCall && value.compareTo(obj.refMofId()) == 0);
                                                       (isFirstCall && value.compareTo(anchorObjectXriFromInitialObject) == 0);
                                    if (selected) {
                                        hasSelection = true;
                                        selectedAnchorObjectXRI = value;
                                    }
%>
	                                  <option <%= selected ? "selected" : "" %> value="<%= value != null ? value : "" %>"><%= key %></option>
<%
	                              }
%>
	                          </select>
<%
                            if ((anchorObjectXri != null) && (anchorObjectXri.length() > 0) && (!hasSelection)) {
                                mustReload = true;
                            }
                        }
%>
                    </td>
                    <td class="addon"></td>
                  </tr>
                </table>
            </div>

            <div style="background-color:#F4F4F4;border:1px solid #EBEBEB;padding:10px;margin-top:15px;">

                <div class="fieldGroupName"><%= type %> Options</div>
                <div class="fieldGroupName">&nbsp;</div>
<%
                if (type.compareTo(TYPE_CALENDAR) == 0) {
%>
                    <table class="fieldGroup">
                      <tr>
                        <td class="label"><span class="nw">Generate:</span></td>
                        <td>
                            <select class="valueL" id="sourceType" name="sourceType" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('reload.button').click();">
<%
                                boolean hasSourceTypeSelection = false;
                                boolean hasFreebusyTypeSelection = false;
                                if (obj instanceof org.opencrx.kernel.account1.jmi1.AccountFilterGlobal) {
                                    if (optionIcalType.compareTo(optionIcalTypeTodo) == 0) {
                                                                           options += "&icalType="      + URLEncoder.encode(optionIcalTypeTodo,  "UTF-8");
                                    }
                                    if (optionCategories.length()    > 0 && optionCategories.compareTo(optionCategoriesDefault) != 0) {
                                                                           options += "&categories="    + URLEncoder.encode(optionCategories,    "UTF-8");
                                    }
                                    if (optionSummaryPrefix.length() > 0) {options += "&summaryPrefix=" + URLEncoder.encode(optionSummaryPrefix, "UTF-8");}
                                    if (optionMax.length()           > 0) {options += "&max="           + URLEncoder.encode(optionMax,           "UTF-8");}
                                    if (optionYear.length()          > 0) {options += "&year="          + URLEncoder.encode(optionYear,          "UTF-8");}
                                    if (sourceType.compareTo(optionSourceBdays) == 0) {
                                        hasSourceTypeSelection = true;
                                    }
%>
                                    <option <%= sourceType.compareTo(optionSourceBdays     ) == 0 ? "selected" : "" %> value="<%= optionSourceBdays      %>"><%= optionSourceBdaysLText %> (from Contacts)</option>
<%
                                } else if (selectorType.compareTo(SELTYPE_CALENDARPROFILE) == 0) {
                                    sourceType =  optionSourceActivities;
                                    hasSourceTypeSelection = true;
%>
                                    <option <%= sourceType.compareTo(optionSourceActivities) == 0 ? "selected" : "" %> value="<%= optionSourceActivities %>"><%= optionSourceActivities %> (from Activities)</option>
<%
                                } else {
                                    if ((sourceType.compareTo(optionSourceActivities) == 0) || (sourceType.compareTo(optionSourceFreebusy) == 0)) {
                                        hasSourceTypeSelection = true;
                                    }
                                    if ((sourceType.compareTo(optionSourceFreebusy) == 0)) {
                                        hasFreebusyTypeSelection = true;
                                    }

%>
                                    <option <%= sourceType.compareTo(optionSourceActivities        ) == 0 ? "selected" : "" %> value="<%= optionSourceActivities         %>"><%= optionSourceActivities         %> (from Activities)</option>
                                    <option <%= sourceType.compareTo(optionSourceFreebusy          ) == 0 ? "selected" : "" %> value="<%= optionSourceFreebusy           %>"><%= optionSourceFreebusy           %> (from Activities)</option>
<%
                                }
                                if (!hasSourceTypeSelection) {
                                    mustReload = true;
                                }
%>
                            </select>
                        </td>
                        <td class="addon"></td>
                      </tr>
<%
                      if (sourceType.compareTo(optionSourceBdays) == 0) {
%>
                          <tr>
                            <td class="label"><span class="nw">iCal type:</span></td>
                            <td>
                                <select class="valueL" id="optionIcalType" name="optionIcalType" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('reload.button').click();">
<%
                                    if ((optionIcalType.compareTo(optionIcalTypeEvent) != 0) && (optionIcalType.compareTo(optionIcalTypeTodo  ) != 0)) {
                                        mustReload = true;
                                    }
%>
                                    <option <%= optionIcalType.compareTo(optionIcalTypeEvent) == 0 ? "selected" : "" %> value="<%= optionIcalTypeEvent %>"><%= optionIcalTypeEvent %></option>
                                    <option <%= optionIcalType.compareTo(optionIcalTypeTodo ) == 0 ? "selected" : "" %> value="<%= optionIcalTypeTodo  %>"><%= optionIcalTypeTodo  %></option>
                                </select>
                            </td>
                            <td class="addon"></td>
                          </tr>

                          <tr title="Categories - default is '<%= optionCategoriesDefault %>'">
                            <td class="label"><span class="nw">Categories:</span></td>
                            <td>
                                <input type="text" value="<%= optionCategories %>" tabindex="<%= tabIndex + 10 %>" class="valueL" name="optionCategories" id="optionCategories"  onchange="javascript:$('reload.button').click();" />
                            </td>
                            <td class="addon"></td>
                          </tr>

                          <tr title="Summary prefix - default is '<%= optionSummaryPrefixDefault %>'">
                            <td class="label"><span class="nw">Summary prefix:</span></td>
                            <td>
                                <input type="text" value="<%= optionSummaryPrefix %>" tabindex="<%= tabIndex + 10 %>" class="valueL" name="optionSummaryPrefix" id="optionSummaryPrefix"  onchange="javascript:$('reload.button').click();" />
                            </td>
                            <td class="addon"></td>
                          </tr>

                          <tr title="maximum number of accounts - default is '500'">
                            <td class="label"><span class="nw">Max #Accounts:</span></td>
                            <td>
                                <input type="text" value="<%= optionMax %>" maxlength="4" tabindex="<%= tabIndex + 10 %>" class="valueL" name="optionMax" id="optionMax"  onchange="javascript:$('reload.button').click();" />
                            </td>
                            <td class="addon"></td>
                          </tr>

                          <tr title="generate data for year-1, year, year+1 - default is current year">
                            <td class="label"><span class="nw">Year [YYYY]:</span></td>
                            <td>
                                <input type="text" value="<%= optionYear %>" maxlength="4" tabindex="<%= tabIndex + 10 %>" class="valueL" name="optionYear" id="optionYear"  onchange="javascript:$('reload.button').click();" />
                            </td>
                            <td class="addon"></td>
                          </tr>
<%
                      } else {
                          if (sourceType.compareTo(optionSourceActivities) == 0) {
%>
                              <tr>
                                <td class="label"><span class="nw">Type:</span></td>
                                <td>
                                    <select class="valueL" id="optionType" name="optionType" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('reload.button').click();">
<%
                                        if (optionType.compareTo(optionTypeCalDAV) == 0) {
%>
                                            <option selected value="<%= optionTypeCalDAV %>"><%= optionTypeCalDAV %></option>
                                            <option          value="<%= optionTypeCalDAV_VTODO %>"><%= optionTypeCalDAV_VTODO %></option>
<%
                                        } else if (optionType.compareTo(optionTypeCalDAV_VTODO) == 0) {
%>
                                            <option          value="<%= optionTypeCalDAV %>"><%= optionTypeCalDAV %></option>
                                            <option selected value="<%= optionTypeCalDAV_VTODO %>"><%= optionTypeCalDAV_VTODO %></option>
<%
                                        } else if (obj instanceof org.opencrx.kernel.home1.jmi1.SyncProfile || obj instanceof org.opencrx.kernel.home1.jmi1.AirSyncProfile) {
%>
                                            <option <%= optionType.compareTo(optionTypeCalDAV)       == 0 ? "selected" : "" %> value="<%= optionTypeCalDAV %>"><%= optionTypeCalDAV %></option>
                                            <option <%= optionType.compareTo(optionTypeCalDAV_VTODO) == 0 ? "selected" : "" %> value="<%= optionTypeCalDAV_VTODO %>"><%= optionTypeCalDAV_VTODO %></option>
<%
                                        } else if (selectorType.compareTo(SELTYPE_CALENDARPROFILE) != 0) {
%>
                                            <option value="<%= optionTypeCalDAV %>"><%= optionTypeCalDAV %></option>
                                            <option value="<%= optionTypeCalDAV_VTODO %>"><%= optionTypeCalDAV_VTODO %></option>
<%
                                        }
                                        if (selectorType.compareTo(SELTYPE_CALENDARPROFILE) != 0) {
%>
                                            <option <%= optionType.compareTo(optionTypeHtml)   == 0 ? "selected" : "" %> value="<%= optionTypeHtml   %>"><%= optionTypeHtml   %> (Timeline)</option>
                                            <option <%= optionType.compareTo(optionTypeIcs )   == 0 ? "selected" : "" %> value="<%= optionTypeIcs    %>"><%= optionTypeIcs    %></option>
                                            <option <%= optionType.compareTo(optionTypeXml )   == 0 ? "selected" : "" %> value="<%= optionTypeXml    %>"><%= optionTypeXml    %></option>
<%
                                        }
%>
                                    </select>
                                </td>
                                <td class="addon"></td>
                              </tr>
<%
                              boolean hasSelection = false;
                              if (
                                  optionType.compareTo(optionTypeCalDAV)  == 0 ||
                                  optionType.compareTo(optionTypeCalDAV_VTODO) == 0 ||
                                  obj instanceof org.opencrx.kernel.home1.jmi1.SyncProfile || obj instanceof org.opencrx.kernel.home1.jmi1.AirSyncProfile
                              ) {
                                  hasSelection = true;
                                  optionDisabled = optionValueFALSE; // CalDAV does NOT support this option
                              }
                              if (optionType.compareTo(optionTypeIcs)  == 0) {
                                  options += "&type=" + optionTypeIcs;
                                  hasSelection = true;
                              }
                              if (optionType.compareTo(optionTypeXml)  == 0) {
                                  options += "&type=" + optionTypeXml;
                                  hasSelection = true;
                              }
                              if (optionType.compareTo(optionTypeHtml) == 0) {
                                  options += "&type=" + optionTypeHtml;
                                  hasSelection = true;
%>
                                  <tr title="height of Timeline chart">
                                    <td class="label"><span class="nw">Timeline height [in pixels]:</span></td>
                                    <td>
                                        <input type="text" value="<%= optionHeight %>" maxlength="4" tabindex="<%= tabIndex + 10 %>" class="valueL" name="optionHeight" id="optionHeight"  onchange="javascript:$('reload.button').click();" />
                                    </td>
                                    <td class="addon"></td>
                                  </tr>
<%
                                  if (optionHeight.length() > 0) {options += "&height=" + URLEncoder.encode(optionHeight, "UTF-8");}

                              }
                              if (!hasSelection) {
                                  mustReload = true;
                              }
                          }

                          if (optionFreebusyAsCal.compareTo(optionValueTRUE) == 0) {options += "&type=" + optionTypeIcs;}
%>
                          <tr title="activate option 'as calendar' to retrieve freebusy information in ics calendar format" <%= (sourceType.compareTo(optionSourceFreebusy) == 0) ? "" : "style='display:none;'" %>>
                            <td class="label"><span class="nw">freebusy as <i>ics calendar</i>:</span></td>
                            <td>
                                <select class="valueL" id="optionFreebusyAsCal" name="optionFreebusyAsCal" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('reload.button').click();">
                                    <option <%= optionFreebusyAsCal.compareTo(optionValueFALSE) == 0 ? "selected" : "" %> value="<%= optionValueFALSE %>"><%= optionValueFALSE %> (<%= hintDefaultValue %>)</option>
                                    <option <%= optionFreebusyAsCal.compareTo(optionValueTRUE ) == 0 ? "selected" : "" %> value="<%= optionValueTRUE  %>"><%= optionValueTRUE  %></option>
                                </select>
                            </td>
                            <td class="addon"></td>
                          </tr>

                          <tr title="select access by user name or e-mail address'" <%= (sourceType.compareTo(optionSourceFreebusy) == 0) ? "" : "style='display:none;'" %>>
                            <td class="label"><span class="nw">freebusy <i>for user</i>:</span></td>
                            <td>
                                <select class="valueL" id="optionFreebusyUser" name="optionFreebusyUser" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('reload.button').click();">
<%
																		Map entries = new TreeMap();
																		if (selectorType.compareTo(SELTYPE_USERHOME) == 0) {
				                                // try to get selected Userhome
				                                org.opencrx.kernel.home1.jmi1.UserHome userHome = null;
				                                String principal = "";
				                                try {
				                                  userHome = (org.opencrx.kernel.home1.jmi1.UserHome)pm.getObjectById(new Path(selectedAnchorObjectXRI));
				                                  principal = userHome.refGetPath().getBase();
				                                } catch (Exception e) {}
																				if (userHome != null) {
																						org.opencrx.kernel.account1.jmi1.Contact contact = null;
																						try {
																								contact = userHome.getContact();
																						} catch (Exception e) {}
																						String display = optionValueUSER + ":&nbsp;&nbsp;" + (contact != null && contact.getFullName() != null ? contact.getFullName() : UNKNOWN) + " [" + principal + "]";
																						String sortKey = display.toUpperCase() + formatter.format(0);
																						entries.put(
																								HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
																								userHome.refMofId()
																						);
																				}
																		} else {
																				if (sourceType.compareTo(optionSourceFreebusy) == 0) {
																						options += "/&user=" + optionFreebusyUser;
																				}
																				// get all UserHomes
																				int index = 0;
																				for(Iterator i = homeSegment.getUserHome().iterator(); i.hasNext() && index < MAX_ENTRY_SELECT; ) {
																						org.opencrx.kernel.home1.jmi1.UserHome userHome = (org.opencrx.kernel.home1.jmi1.UserHome)i.next();
																						org.opencrx.kernel.account1.jmi1.Contact contact = null;
																						try {
																								contact = userHome.getContact();
																						} catch (Exception e) {}
																						String principal = userHome.refGetPath().getBase();
																						String display = optionValueUSER + ":&nbsp;&nbsp;" + (contact != null && contact.getFullName() != null ? contact.getFullName() : UNKNOWN) + " [" + principal + "]";
																						String sortKey = display.toUpperCase() + formatter.format(index++);
																						entries.put(
																								HTML_COMMENT_BEGIN + sortKey + HTML_COMMENT_END + display,
																								userHome.refMofId()
																						);
																				}
																		}
														        if (entries.isEmpty()) {
														        		mustReload = true;
%>
												                <option value="">--</option>
<%
														        } else {
														        		boolean hasSelection = false;
												                for (
												                		Iterator i = entries.keySet().iterator();
												                		i.hasNext();
												                ) {
												                    String key = (String)i.next();
												                    String value = (String)entries.get(key);
												                    String principal = "";
								                            org.opencrx.kernel.home1.jmi1.UserHome userHome = null;
								                            try {
								                              userHome = (org.opencrx.kernel.home1.jmi1.UserHome)pm.getObjectById(new Path(value));
								                              principal = userHome.refGetPath().getBase();
								                            } catch (Exception e) {}
								                            value = principal;
												                    boolean selected = ((optionFreebusyUser != null) && (value != null) && (optionFreebusyUser.compareTo(value) == 0));
												                    if (selected) {hasSelection = true;}
%>
													                  <option <%= selected ? "selected" : "" %> value="<%= value != null ? value : "" %>"><%= key %></option>
<%
								                            // try to get the list of E-Mail Addresses
								                            if (userHome != null) {
																								org.opencrx.kernel.home1.cci2.EMailAccountQuery eMailAccountQuery = (org.opencrx.kernel.home1.cci2.EMailAccountQuery)pm.newQuery(org.opencrx.kernel.home1.jmi1.EMailAccount.class);
																								eMailAccountQuery.thereExistsIsActive().isTrue();
																								eMailAccountQuery.orderByName().ascending();
																								List<org.opencrx.kernel.home1.jmi1.EMailAccount> emailAccounts = userHome.getEMailAccount(eMailAccountQuery);
																								for(org.opencrx.kernel.home1.jmi1.EMailAccount eMailAccount: emailAccounts) {
								                                  try {
								                                    if ((eMailAccount.getName() != null) && (eMailAccount.getName().length() > 0)) {
								                                      String eMailAddress = eMailAccount.getName();
								                                      selected = optionFreebusyUser.compareTo(eMailAddress) == 0;
																	                    if (selected) {hasSelection = true;}
%>
				                                              <option <%= selected ? "selected" : "" %> value="<%= eMailAddress %>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%= eMailAddress %></option>
<%
								                                    }
								                                  } catch (Exception e) {
								                                    new ServiceException(e).log();
								                                  }
								                                }
								                            }
													              }
										                    if (!hasSelection) {
										                        mustReload = true;
										                    }
														        }
%>
		                                <!-- this option is not useful
		                                <option <%= optionFreebusyUser.compareTo(optionValueMANUAL) == 0 ? "selected" : "" %> value="<%= optionValueMANUAL %>"><%= optionValueMANUAL %>:&nbsp;&nbsp; <%= hintManualEntry %></option>
		                                -->
                                </select>
                            </td>
                            <td class="addon"></td>
                          </tr>
<%
                          if (supportsAccessByUser) {
%>
		                        <tr title="access by non-owning user">
		                          <td class="label"><span class="nw">Access by <i>non-owning</i> user:</span></td>
		                          <td>
		                              <select class="valueL" id="optionNonOwningUser" name="optionNonOwningUser" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('reload.button').click();">
		                                  <option <%= optionNonOwningUser.compareTo(optionValueFALSE) == 0 ? "selected" : "" %> value="<%= optionValueFALSE %>"><%= optionValueFALSE %> (<%= hintDefaultValue %>)</option>
		                                  <option <%= optionNonOwningUser.compareTo(optionValueTRUE ) == 0 ? "selected" : "" %> value="<%= optionValueTRUE  %>"><%= optionValueTRUE  %></option>
		                              </select>
		                          </td>
		                          <td class="addon"></td>
		                        </tr>
<%
													}
													
													if ((supportsAccessByUser && (optionNonOwningUser.compareTo(optionValueTRUE ) == 0)) || optionFreebusyUser.compareTo(optionValueMANUAL) == 0) {
%>
				                    <tr title="user name or e-mail address">
				                      <td class="label"><span class="nw">&nbsp;&nbsp;\-- User name or e-mail address:</span></td>
				                      <td>
																<input type="text" value="<%= optionUsernameEmail %>" tabindex="<%= tabIndex + 10 %>" class="valueL" name="optionUsernameEmail" id="optionUsernameEmail"  onchange="javascript:$('reload.button').click();" />
				                      </td>
				                      <td class="addon"></td>
				                    </tr>
<%
                          }

                          if (optionDisabled.compareTo(optionValueTRUE) == 0) {options += "&disabled=" + optionValueTRUE;}
%>
                          <tr title="activate filter 'disabled' to process disabled activities only" <%= (sourceType.compareTo(optionSourceActivities) == 0) && (optionType.compareTo(optionTypeCalDAV) == 0 || optionType.compareTo(optionTypeCalDAV_VTODO) == 0 || (obj instanceof org.opencrx.kernel.home1.jmi1.SyncProfile || obj instanceof org.opencrx.kernel.home1.jmi1.AirSyncProfile)) ? "style='display:none;'" : "" %>>
                            <td class="label"><span class="nw">Filter <i>disabled</i>:</span></td>
                            <td>
                                <select class="valueL" id="optionDisabled" name="optionDisabled" class="valueL" tabindex="<%= tabIndex + 10 %>" onchange="javascript:$('reload.button').click();">
                                    <option <%= optionDisabled.compareTo(optionValueFALSE) == 0 ? "selected" : "" %> value="<%= optionValueFALSE %>"><%= optionValueFALSE %> (<%= hintDefaultValue %>)</option>
                                    <option <%= optionDisabled.compareTo(optionValueTRUE ) == 0 ? "selected" : "" %> value="<%= optionValueTRUE  %>"><%= optionValueTRUE  %></option>
                                </select>
                            </td>
                            <td class="addon"></td>
                          </tr>
<%
                      }
%>
                    </table>
                    <br>
<%
                    if ((optionType.compareTo(optionTypeIcs)  == 0) || (sourceType.compareTo(optionSourceFreebusy) == 0)) {
%>
                    	<div class="fieldGroupName" style="padding-top:10px;font-size:12px;">Hint: you can set <strong>maxActivities</strong> in the Component-Configuration of the ICalServlet (default is 500) - see <a href="http://www.opencrx.org/documents.htm" target="_blank"><strong>openCRX Admin Guide</strong></a></div>
<%
                    } else if (
                        optionType.compareTo(optionTypeCalDAV)  == 0 ||
                        optionType.compareTo(optionTypeCalDAV_VTODO) == 0
                    ) {
%>
                    	<div class="fieldGroupName" style="padding-top:10px;font-size:12px;">Hint: you can set <strong>maxActivities</strong> in the Component-Configuration of the CalDavServlet (default is 500) - see <a href="http://www.opencrx.org/documents.htm" target="_blank"><strong>openCRX Admin Guide</strong></a></div>
<%
										}
                }
                if (type.compareTo(TYPE_VCARD) == 0) {
%>
                    <div class="fieldGroupName">Hint: you can set <strong>maxAccounts</strong> in the Component-Configuration of the vCardServlet (default is 500)</div>
<%
                }
%>
            </div>

<%
            if (target != null && target.length() > 0) {
                target = target.replace("+", "%20");
                options = options.replace("+", "%20");
                
%>
                <br>
                URL: <a href="<%= target + options %>" target="_blank"><%= target + options %></a><br>
<%
            }
            if (server != null && server.length() > 0) {
%>
                <br>
                <div style="background-color:#F4F4F4;border:1px solid #EBEBEB;padding:10px;margin-top:15px;">
                <table class="fieldGroup">
                  <tr>
                    <td class="label"><span class="nw">Server:</span></td>
                    <td><b><%= server %></b></td>
                    <td class="addon"></td>
                  </tr>
<%
                  if (type.compareTo(TYPE_WEBDAV) == 0) {
%>
	                  <tr>
	                    <td class="label"><span class="nw">Path:</span></td>
	                    <td><b><%= path %></b></td>
	                    <td class="addon"></td>
	                  </tr>
<%
                  } else {
                  	// AirSync
%>
	                  <tr>
	                    <td class="label"><span class="nw">Domain:</span></td>
	                    <td><b><%= segmentName %></b></td>
	                    <td class="addon"></td>
	                  </tr>
<%
                  }
%>
                  <tr>
                    <td class="label"><span class="nw">Username:</span></td>
                    <td><b><%= currentUserHome.refGetPath().getBase() %></b></td>
                    <td class="addon"></td>
                  </tr>
                </table>
                </div>
<%
            }
%>

            <br>
            <input type="submit" id="reload.button" name="reload.button" tabindex="<%= tabIndex++ %>" value="<%= app.getTexts().getReloadText() %>" />
            <input type="submit" id="Cancel" name="Cancel" tabindex="30" value="<%= app.getTexts().getCancelTitle() %>"  onClick="javascript:window.close();" />
            <br>
          </form>
        </div> <!-- content -->
      </div> <!-- content-wrap -->
     </div> <!-- wrap -->
    </div> <!-- container -->

    <script language="javascript" type="text/javascript">
        function initPage() {
<%
            if (mustReload) {
%>
                $('reload.button').click();
<%
            }
%>
}
    </script>

    </body>
    </html>
<%
  }
  catch(Exception e) {
    new ServiceException(e).log();
      // Go back to previous view
    Action nextAction = new ObjectReference(
         (RefObject_1_0)pm.getObjectById(new Path(objectXri)),
         app
    ).getSelectObjectAction();
    response.sendRedirect(
      request.getContextPath() + "/" + nextAction.getEncodedHRef()
    );
  } finally {
	  if(pm != null) {
		  pm.close();
	  }
  }
%>
