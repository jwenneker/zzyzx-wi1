<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     opencrx, http://www.opencrx.org/
 * Name:        $Id: ShowCalendarWeekly.jsp,v 1.3 2011/11/19 10:59:01 cmu Exp $
 * Description: launch timeline (based on http://simile.mit.edu/timeline/)
 * Revision:    $Revision: 1.3 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/11/19 10:59:01 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2010-2011, CRIXP Corp., Switzerland
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
 *
 * This product includes software developed by Nikolaus Gradwohl posted at
 * http://www.local-guru.net/blog/2009/03/29/javascript-caldav-frontend
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
" %>
<%!

	public static String getDateAsString(
		GregorianCalendar date
	) {
		return getDateAsString(
			date.get(GregorianCalendar.YEAR),
			date.get(GregorianCalendar.MONTH) + 1,
			date.get(GregorianCalendar.DAY_OF_MONTH)
		);
	}

	public static String getDateAsString(
		int year,
		int month,
		int dayOfMonth
	) {
		return // YYYYMMDD
			Integer.toString(year) +
			((month < 10 ? "0" : "") + Integer.toString(month)) +
			((dayOfMonth < 10 ? "0" : "") + Integer.toString(dayOfMonth));
	}

	public static GregorianCalendar getDateAsCalendar(
		String dateAsString,
		ApplicationContext app
	) {

		GregorianCalendar date = new GregorianCalendar(app.getCurrentLocale());
		date.setTimeZone(TimeZone.getTimeZone(app.getCurrentTimeZone()));
		date.setMinimalDaysInFirstWeek(4); // this conforms to DIN 1355/ISO 8601
		date.set(GregorianCalendar.YEAR, Integer.valueOf(dateAsString.substring(0, 4)));
		date.set(GregorianCalendar.MONTH, Integer.valueOf(dateAsString.substring(4, 6)) - 1);
		date.set(GregorianCalendar.DAY_OF_MONTH, Integer.valueOf(dateAsString.substring(6, 8)));
		date.set(GregorianCalendar.HOUR_OF_DAY, 0);
		date.set(GregorianCalendar.MINUTE, 0);
		date.set(GregorianCalendar.SECOND, 0);
		date.set(GregorianCalendar.MILLISECOND, 0);
		return date;
	}

%>
<%
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
  <title><%= app.getApplicationName() %> - Weekly Calendar View</title>
  <meta name="label" content="Show Calendar Weekly">
  <meta name="toolTip" content="Show Calendar Weekly">
  <meta name="targetType" content="_blank">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityTracker">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityCategory">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityMilestone">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityFilterGlobal">
  <meta name="forClass" content="org:opencrx:kernel:activity1:ActivityFilterGroup">
  <meta name="forClass" content="org:opencrx:kernel:activity1:Resource">
  <meta name="forClass" content="org:opencrx:kernel:home1:UserHome">
  <meta name="order" content="6001">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
  <link href="../../_style/cal.css" rel="stylesheet" type="text/css">
  <script language="javascript" type="text/javascript" src="../../javascript/mootools.js"></script>
  <link rel='shortcut icon' href='../../images/favicon.ico' />

  <script language="javascript" type="text/javascript">

var events = [];

function clearEvents() {
    events = [];
}

function lastMonday( now ) {
    var res = new Date();
    if (!now) {
        res = new Date();
    } else {
        res.setTime( now.getTime());
    }

    if ( res.getDay() > 1 ) {
        res.setTime( res.getTime() - ((res.getDay() - 1) * 24 * 60 * 60 * 1000) );
    } else if ( res.getDay() == 0 ) {
        res.setTime( res.getTime() - (6 * 24 * 60 * 60 * 1000) );
    }

    return res;
}

function nextMonday( now) {
    var res = new Date();
    res.setTime( now.getTime() + 7 * 24 * 60 * 60 * 1000 );
    return lastMonday( res );
}

function formatD(d) {
    var y = d.getFullYear();
    var m = d.getMonth()+1;
    if ( m < 10) {
        m = "0" + m;
    }
    var d = d.getDate();
    if ( d < 10) {
        d = "0" + d;
    }

    return y + "" + m + "" +  d;
}

function formatDate( d ) {
    var y = d.getFullYear();
    var m = d.getMonth()+1;
    if ( m < 10) {
        m = "0" + m;
    }
    var d = d.getDate();
    if ( d < 10) {
        d = "0" + d;
    }

    return y + "" + m + "" +  d + "T000000Z";
}

function parseDate( str ) {
    var year = parseInt( str.substring(0,4), 10);
    var month = parseInt( str.substring(4,6), 10);
    var day = parseInt( str.substring(6,8), 10);
    var res = new Date();
    res.setFullYear( year, month - 1, day );
    return res;
}

function parseTime( str ) {
    if ( str.indexOf('T') < 0) {
        return -2 * 60*60;
    }
    var ofs = str.indexOf( 'T' ) + 1;
    var h = parseInt( str.substring(ofs,ofs+2), 10);
    var min = parseInt( str.substring(ofs+2,ofs+4), 10);
    var sec = parseInt( str.substring(ofs+4,ofs+6), 10);
    return h*60*60 + min*60 + sec;
}

var IcalEvent = {
    uid: "",
    summary: "",
    start: "",
    duration: "",
    color: ""
};

function renderEvents( events ) {
    r = "";
    offsets = [ 670, 10, 120, 230, 340, 450, 560 ];
    if ($('events').getChildren().length > 0) {
        $('events').getChildren().each( function( item ) {
                $('events').removeChild(item);
                });
    }
    for( i=0; i < events.length; i++) {
        r +=  events[i].start +  " " + events[i].summary + "\n";
        var l = offsets[ parseDate(events[i].start).getDay()];
        var t = 220 + parseTime( events[i].start )/180;
        var h  = events[i].duration / 180;
        var w = 100;

        for( j=0; j < events.length; j++) {
            if ( i != j && (parseDate(events[i].start).getTime() == parseDate(events[j].start).getTime())) {
                if (parseTime(events[i].start) < parseTime(events[j].start)) {
                    if ((parseTime(events[i].start) + events[i].duration) > parseTime(events[j].start)) {
                        w = 80;
                    }
                } else {
                    if ((parseTime(events[j].start) + events[j].duration) > parseTime(events[i].start)) {
                        w = 80;
                        l += 20;
                    }
                }
            }
        }

        var ev_div = new Element ( 'div' , { 'class': 'event', 'style':'top: ' + t + 'px; left: ' + l + 'px; height: ' + h + 'px; width: ' + w + '; background: ' + events[i].color + ';' }) ;
        ev_div.set('text', events[i].summary);
        /* ev_div.set('events', {click: function(){ window.location.href='http://www.nzz.ch/'; }}); */
        ev_div.injectInside($('events'));
    }
    $('result').set('text', '');
}

function parseIcal( ics, color ) {

            var arr = ics.split( '\n' );
            var e = Object.create(IcalEvent);
            e.color = color;
            var inEvent = 0;
            for( j=0; j < arr.length; j++) {
                if (arr[j].indexOf("BEGIN:VEVENT") >=0 ) {
                    inEvent = 1;
                }
                else if (arr[j].indexOf("END:VEVENT") >=0 ) {
                    inEvent = 0;
                }

                if ( inEvent ) {
                    if (arr[j].indexOf("SUMMARY:")>=0) {
                        e.summary = arr[j].substring( 8, 27 );
                    }
                    else if (arr[j].indexOf("DTSTART")>=0) {
                        e.start = arr[j].substring( arr[j].indexOf(":")+1);
                    }
                    else if (arr[j].indexOf("DTEND")>=0) {
                        end =  arr[j].substring( arr[j].indexOf(":")+1)
                            e.duration = parseTime( end ) - parseTime( e.start );
                        if (e.duration == 0) {
                  			    e.duration = 60 * 60  ;
                  			    var d1 = new Date();
                  			    e.start= d1.getFullYear() + end.substring(4);
                  			    d1 = parseDate(e.start);
                  			    d1.setTime(d1.getTime()-(24*60*60*1000));
                  			    e.start=formatD(d1);
                  			}
                    }
                }
            }
            events.push(e);
}

    function today( d ) {
       var d1 = new Date();
       return d1.getYear() == d.getYear() && d1.getMonth() == d.getMonth() && d1.getDate() == d.getDate();
    }

    function renderDate( d ) {
        var mon = lastMonday( d );
        days = ['mon', 'tue', 'wen', 'thu', 'fri', 'sat', 'sun'];
        for ( var i =0; i < days.length; i++) {
        $(days[i]+"_label").set('text',  days[i]+' '+mon.getDate()+'-'+(1 + mon.getMonth())+'-'+(mon.getFullYear()));
        if ( today( mon )) {
            $(days[i]+"_label").set('style', 'border-color: black; background: #CCCCFF;' );
        } else {
            $(days[i]+"_label").set('style', '' );
        }
            mon.setTime( mon.getTime() + 24 * 60 * 60 * 1000  );
        }
    }

  </script>
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
<%
	final String FORM_NAME = "ShowCalendarWeekly";
	final String WIZARD_NAME = FORM_NAME + ".jsp";
  final String SUBMIT_HANDLER = "javascript:$('command').value=this.name;";

  final String EVENT_COLOR = "#00FF00";

	String command = request.getParameter("command");
	//System.out.println("command=" + command);
	boolean actionClose     = "Close".equals(command);
	boolean actionToday     = "Today".equals(command);
	boolean actionNextWeek  = "NextWeek".equals(command);
	boolean actionPrevWeek  = "PrevWeek".equals(command);
	boolean actionNextMonth = "NextMonth".equals(command);
	boolean actionPrevMonth = "PrevMonth".equals(command);
	boolean actionNextYear  = "NextYear".equals(command);
 	boolean actionPrevYear  = "PrevYear".equals(command);

	try {
    RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
    Path objectPath = obj.refGetPath();
    String providerName = objectPath.get(2);
    String segmentName = objectPath.get(4);

    String urlBase = (request.getRequestURL().toString()).substring(0, (request.getRequestURL().toString()).indexOf(request.getServletPath().toString()));
    String groupComponent = "";
    String filterComponent = "";
    String name = "?";

		TimeZone timezone = TimeZone.getTimeZone(app.getCurrentTimeZone());
		SimpleDateFormat datenicef = new SimpleDateFormat("dd-MMM-yyyy", app.getCurrentLocale()); datenicef.setTimeZone(timezone);
		SimpleDateFormat datef = new SimpleDateFormat("yyyy/MM/dd", app.getCurrentLocale()); datef.setTimeZone(timezone);
		SimpleDateFormat icsD = new SimpleDateFormat("yyyyMMdd", app.getCurrentLocale()); datef.setTimeZone(timezone);
		SimpleDateFormat icsT = new SimpleDateFormat("HHmmss", app.getCurrentLocale()); datef.setTimeZone(timezone);

		String selectedDateStr = request.getParameter("selectedDateStr"); // // YYYYMMDD

		if(actionToday) {
			selectedDateStr = null;
		}

		if(selectedDateStr == null || selectedDateStr.length() != 8) {
			GregorianCalendar today = new GregorianCalendar(app.getCurrentLocale());
			today.setTimeZone(TimeZone.getTimeZone(app.getCurrentTimeZone()));
			selectedDateStr = getDateAsString(today);
		}

		if(actionPrevWeek) {
			GregorianCalendar date = getDateAsCalendar(selectedDateStr, app); //
			date.add(GregorianCalendar.DAY_OF_MONTH, -7);
			selectedDateStr = getDateAsString(date);
		}
		if(actionNextWeek) {
			GregorianCalendar date = getDateAsCalendar(selectedDateStr, app); //
			date.add(GregorianCalendar.DAY_OF_MONTH, 7);
			selectedDateStr = getDateAsString(date);
		}
		if(actionPrevMonth) {
			GregorianCalendar date = getDateAsCalendar(selectedDateStr, app); //
			date.add(GregorianCalendar.MONTH, -1);
			selectedDateStr = getDateAsString(date);
		}
		if(actionNextMonth) {
			GregorianCalendar date = getDateAsCalendar(selectedDateStr, app); //
			date.add(GregorianCalendar.MONTH, 1);
			selectedDateStr = getDateAsString(date);
		}
		if(actionPrevYear) {
			GregorianCalendar date = getDateAsCalendar(selectedDateStr, app); //
			date.add(GregorianCalendar.YEAR, -1);
			selectedDateStr = getDateAsString(date);
		}
		if(actionNextYear) {
			GregorianCalendar date = getDateAsCalendar(selectedDateStr, app); //
			date.add(GregorianCalendar.YEAR, 1);
			selectedDateStr = getDateAsString(date);
		}

		GregorianCalendar calendarBeginOfWeek = getDateAsCalendar(selectedDateStr, app);
		//while (calendarBeginOfWeek.get(GregorianCalendar.DAY_OF_WEEK) != calendarBeginOfWeek.getFirstDayOfWeek()) {
		while (calendarBeginOfWeek.get(GregorianCalendar.DAY_OF_WEEK) != 2) {
				calendarBeginOfWeek.add(GregorianCalendar.DAY_OF_MONTH, -1);
		}
		int tz_dst_offset = calendarBeginOfWeek.get(GregorianCalendar.ZONE_OFFSET)/(60*60*1000) + calendarBeginOfWeek.get(GregorianCalendar.DST_OFFSET)/(60*60*1000);

    selectedDateStr = getDateAsString(
			calendarBeginOfWeek.get(GregorianCalendar.YEAR),
			calendarBeginOfWeek.get(GregorianCalendar.MONTH) + 1,
			calendarBeginOfWeek.get(GregorianCalendar.DAY_OF_MONTH)
		);
    //System.out.println("selectedDateStr = " + datenicef.format(getDateAsCalendar(selectedDateStr, app).getTime()) + " (GMT+" + tz_dst_offset + ")");

    // get Activities within time window, i.e. ScheduledStart IN [beginOfPeriod..endOfPeriod]
    org.opencrx.kernel.activity1.jmi1.Activity1Package activityPkg = org.opencrx.kernel.utils.Utils.getActivityPackage(pm);
		java.util.Date beginOfPeriod = calendarBeginOfWeek.getTime();
		calendarBeginOfWeek.add(GregorianCalendar.DAY_OF_MONTH, 8);
		java.util.Date endOfPeriod   = calendarBeginOfWeek.getTime();

		org.opencrx.kernel.activity1.cci2.ActivityQuery activityQuery = activityPkg.createActivityQuery();
		activityQuery.forAllDisabled().isFalse();
    activityQuery.thereExistsScheduledStart().greaterThan(
      beginOfPeriod
    );
    activityQuery.thereExistsScheduledStart().lessThan(
      endOfPeriod
    );

    Iterator i = null;

    // activity filter
    if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup) {
      org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup activityFilterGroup =
        (org.opencrx.kernel.activity1.jmi1.ActivityFilterGroup)obj;
      i = activityFilterGroup.getFilteredActivity(activityQuery).iterator();
      if (activityFilterGroup.getName() != null) {
        name = activityFilterGroup.getName();
      }
    }
    else if (obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal) {
      org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal activityFilterGlobal =
        (org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal)obj;
      i = activityFilterGlobal.getFilteredActivity(activityQuery).iterator();
      if (activityFilterGlobal.getName() != null) {
        name = activityFilterGlobal.getName();
      }
    }
    // activity group
    if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityTracker) {
      org.opencrx.kernel.activity1.jmi1.ActivityTracker activityTracker =
        (org.opencrx.kernel.activity1.jmi1.ActivityTracker)obj;
      i = activityTracker.getFilteredActivity(activityQuery).iterator();
      if (activityTracker.getName() != null) {
        name = activityTracker.getName();
      }
    }
    else if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityCategory) {
      org.opencrx.kernel.activity1.jmi1.ActivityCategory activityCategory =
        (org.opencrx.kernel.activity1.jmi1.ActivityCategory)obj;
      i = activityCategory.getFilteredActivity(activityQuery).iterator();
      if (activityCategory.getName() != null) {
        name = activityCategory.getName();
      }
    }
    else if(obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityMilestone) {
      org.opencrx.kernel.activity1.jmi1.ActivityMilestone activityMilestone =
        (org.opencrx.kernel.activity1.jmi1.ActivityMilestone)obj;
      i = activityMilestone.getFilteredActivity(activityQuery).iterator();
      if (activityMilestone.getName() != null) {
        name = activityMilestone.getName();
      }
    }
    else if(obj instanceof org.opencrx.kernel.activity1.jmi1.Resource) {
      org.opencrx.kernel.activity1.jmi1.Resource resource =
        (org.opencrx.kernel.activity1.jmi1.Resource)obj;
      i = resource.getAssignedActivity(activityQuery).iterator();
      if (resource.getName() != null) {
        name = resource.getName();
      }
    }
    else if(obj instanceof org.opencrx.kernel.home1.jmi1.UserHome) {
    	org.opencrx.kernel.home1.jmi1.UserHome userHome =
    	  (org.opencrx.kernel.home1.jmi1.UserHome)obj;
      i = userHome.getAssignedActivity(activityQuery).iterator();
      name = URLEncoder.encode(obj.refGetPath().getBase(), "UTF-8");
    }
/*
    else if (obj instanceof org.opencrx.kernel.account1.jmi1.AccountFilterGlobal) {
        org.opencrx.kernel.account1.jmi1.AccountFilterGlobal accountFilterGlobal =
          (org.opencrx.kernel.account1.jmi1.AccountFilterGlobal)obj;
    }
*/
    int tabIndex = 1000; // calendar
%>
    <script language="javascript" type="text/javascript">
    	clearEvents();
<%
      for (Iterator acts = i; acts.hasNext(); ) {
        org.opencrx.kernel.activity1.jmi1.Activity act = (org.opencrx.kernel.activity1.jmi1.Activity)acts.next();
        if (act.getScheduledStart() != null) {
	        System.out.println("Act # " + act.getActivityNumber() + "  start=" + act.getScheduledStart());
	        System.out.println(act.getIcal());
	        /*
	        String iCal = act.getIcal().replace("\r\n", "\n");
	        iCal = iCal.replace("\n", "\\n\" + \n\"");
	        */
%>
			    /*
			    GregorianCalendar scheduledStart = new GregorianCalendar(app.getCurrentLocale());
			    scheduledStart.setTimeZone(TimeZone.getTimeZone(app.getCurrentTimeZone()));
			    scheduledStart.setMinimalDaysInFirstWeek(4); // this conforms to DIN 1355/ISO 8601
			    scheduledStart.setTime(act.getScheduledStart());
			    int tz_dst_offset = (scheduledStart.get(GregorianCalendar.ZONE_OFFSET) + scheduledStart.get(GregorianCalendar.DST_OFFSET))/(60*60*1000);
			    */

	        var iCal = "BEGIN:VEVENT\n" +
	                   "DTSTART:<%= icsD.format(act.getScheduledStart()) %>T<%= icsT.format(act.getScheduledStart()) %>Z \n" +
	                   <%= act.getScheduledEnd() == null ? "" : "\"DTEND:" + icsD.format(act.getScheduledEnd()) + "T" + icsT.format(act.getScheduledEnd()) + "Z \\n\" +" %>
	                   "SUMMARY:<%= act.getName().replace("\"","'") %>" + " //<%= act.getActivityNumber() %>\n" +
	                   "END:VEVENT";
	        parseIcal(iCal,  '<%= EVENT_COLOR %>');
<%
        }
      }
%>
    </script>
<%

%>
    <div id="etitle" style="height:20px;padding-left:12px;">
       Calendar "<%= name %>" &nbsp;&nbsp; <%= datenicef.format(getDateAsCalendar(selectedDateStr, app).getTime()) + " [GMT+" + tz_dst_offset + "]" %>
    </div>

    <div id="content-wrap">
    	<div id="content" style="padding:0px 0.5em 0px 0.5em;">

			<form name="<%= FORM_NAME %>" accept-charset="UTF-8" method="POST" action="<%= WIZARD_NAME %>">
				<input type="hidden" name="command" id="command" value="none"/>
				<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
				<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
				<input type="hidden" name="selectedDateStr" value="<%= selectedDateStr %>" />

        <div style="position:absolute;top:135px;">
					<input id="Button.PrevYear" name="PrevYear" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="««" onclick="<%= SUBMIT_HANDLER %>" />
					<input id="Button.PrevMonth" name="PrevMonth" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&nbsp;&nbsp;«&nbsp;"  onclick="<%= SUBMIT_HANDLER %>" />
					<input id="Button.PrevWeek" name="PrevWeek" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&nbsp;&nbsp;&lt;&nbsp;"  onclick="<%= SUBMIT_HANDLER %>" />
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input id="Button.Today" name="Today" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&nbsp;&nbsp;&nbsp;o&nbsp;&nbsp;&nbsp;" onclick="<%= SUBMIT_HANDLER %>" />
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input id="Button.NextWeek" name="NextWeek" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&nbsp;&gt;&nbsp;&nbsp;" onclick="<%= SUBMIT_HANDLER %>" />
					<input id="Button.NextMonth" name="NextMonth" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&nbsp;»&nbsp;&nbsp;" onclick="<%= SUBMIT_HANDLER %>" />
					<input id="Button.NextYear" name="NextYear" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="»»" onclick="<%= SUBMIT_HANDLER %>" />
					<input id="Button.Close" name="Close" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="X" onClick="javascript:window.close();" style="position:absolute;left:790px;" />
        </div>

        <pre id="result" style="position: absolute; top: 720px;">loading...</pre>

			  <div id="calendar">
			    <div class="hour" id="h0">00:00</div>
			    <div class="hour" id="h1">01:00</div>
			    <div class="hour" id="h2">02:00</div>
			    <div class="hour" id="h3">03:00</div>
			    <div class="hour" id="h4">04:00</div>
			    <div class="hour" id="h5">05:00</div>
			    <div class="hour" id="h6">06:00</div>
			    <div class="hour" id="h7">07:00</div>
			    <div class="hour" id="h8">08:00</div>
			    <div class="hour" id="h9">09:00</div>
			    <div class="hour" id="h10">10:00</div>
			    <div class="hour" id="h11">11:00</div>
			    <div class="hour" id="h12">12:00</div>
			    <div class="hour" id="h13">13:00</div>
			    <div class="hour" id="h14">14:00</div>
			    <div class="hour" id="h15">15:00</div>
			    <div class="hour" id="h16">16:00</div>
			    <div class="hour" id="h17">17:00</div>
			    <div class="hour" id="h18">18:00</div>
			    <div class="hour" id="h19">19:00</div>
			    <div class="hour" id="h20">20:00</div>
			    <div class="hour" id="h21">21:00</div>
			    <div class="hour" id="h22">22:00</div>
			    <div class="hour" id="h23">23:00</div>

			    <div class="label" id="mon_label">Mon</div>
			    <div class="label" id="tue_label">Tue</div>
			    <div class="label" id="wen_label">Wen</div>
			    <div class="label" id="thu_label">Thu</div>
			    <div class="label" id="fri_label">Fri</div>
			    <div class="label" id="sat_label">Sat</div>
			    <div class="label" id="sun_label">Sun</div>

			    <div class="day" id="mon"></div>
			    <div class="day" id="tue"></div>
			    <div class="day" id="wen"></div>
			    <div class="day" id="thu"></div>
			    <div class="day" id="fri"></div>
			    <div class="day" id="sat"></div>
			    <div class="day" id="sun"></div>
			  </div>

        <div style="position:absolute;top:710px;">
					<input id="Button.PrevYear" name="PrevYear" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="««" onclick="<%= SUBMIT_HANDLER %>" />
					<input id="Button.PrevMonth" name="PrevMonth" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&nbsp;&nbsp;«&nbsp;"  onclick="<%= SUBMIT_HANDLER %>" />
					<input id="Button.PrevWeek" name="PrevWeek" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&nbsp;&nbsp;&lt;&nbsp;"  onclick="<%= SUBMIT_HANDLER %>" />
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input id="Button.Today" name="Today" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&nbsp;&nbsp;&nbsp;o&nbsp;&nbsp;&nbsp;" onclick="<%= SUBMIT_HANDLER %>" />
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input id="Button.NextWeek" name="NextWeek" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&nbsp;&gt;&nbsp;&nbsp;" onclick="<%= SUBMIT_HANDLER %>" />
					<input id="Button.NextMonth" name="NextMonth" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&nbsp;»&nbsp;&nbsp;" onclick="<%= SUBMIT_HANDLER %>" />
					<input id="Button.NextYear" name="NextYear" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="»»" onclick="<%= SUBMIT_HANDLER %>" />
        </div>

			  <div id="events"><div>
      </form>

			<script language="javascript" type="text/javascript">
			  var now = new Date();
			  renderEvents( events );
			  renderDate( new Date('<%= datef.format(getDateAsCalendar(selectedDateStr, app).getTime()) %>') );
			</script>
<%
  }
  catch (Exception e) {
		new ServiceException(e).log();
    out.println("<p><b>!! Failed !!<br><br>The following exception(s) occured:</b><br><br><pre>");
    PrintWriter pw = new PrintWriter(out);
    ServiceException e0 = new ServiceException(e);
    pw.println(e0.getMessage());
    pw.println(e0.getCause());
    out.println("</pre>");
  } finally {
  	if(pm != null) {
  		pm.close();
  	}
  }
%>
      </div> <!-- content -->
    </div> <!-- content-wrap -->
  </div> <!-- wrap -->
</div> <!-- container -->
</body>
</html>
