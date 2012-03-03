<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: Maps.jsp,v 1.25 2011/09/23 09:46:22 wfro Exp $
 * Description: prepare calls to mapping services like GoogleMaps
 * Revision:    $Revision: 1.25 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/09/23 09:46:22 $
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
org.openmdx.kernel.log.*
" %><%
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
  <title><%= app.getApplicationName() %> - Maps</title>
  <meta name="label" content="Maps">
  <meta name="toolTip" content="Maps">
  <meta name="targetType" content="_blank">
  <meta name="forClass" content="org:opencrx:kernel:account1:Contact">
  <meta name="forClass" content="org:opencrx:kernel:account1:UnspecifiedAccount">
  <meta name="forClass" content="org:opencrx:kernel:account1:Group">
  <meta name="forClass" content="org:opencrx:kernel:account1:LegalEntity">
  <meta name="forClass" content="org:opencrx:kernel:account1:PostalAddress">
  <meta name="forClass" content="org:opencrx:kernel:contract1:PostalAddress">
  <meta name="forClass" content="org:opencrx:kernel:depot1:PostalAddress">
  <meta name="forClass" content="org:opencrx:kernel:product1:PostalAddress">
  <meta name="order" content="9000">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <link href="../../_style/colors.css" rel="stylesheet" type="text/css">
  <link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
  <link rel='shortcut icon' href='../../images/favicon.ico' />
  <style type="text/css">
  	.gridTableHeaderFull TD {
  		padding: 5px 5px 5px 5px; /* top right bottom left */
  		white-space: nowrap;
  	}
  </style>
</head>

<body>
  <table><tr><td>
  <table class="gridTableFull">
    <tr class="gridTableHeaderFull">
      <td align=left colspan="2"><a href="http://maps.google.com/" target="_bland">Google Maps</a></td>
<!--  does not work anymore...
      <td align=left colspan="2"><a href="http://local.live.com/" target="_bland">Live Search</a></td>
-->
    </tr>
<%
  String[] streetPatterns = {
    /* de */ "STR", "WEG", "HOF", "IFANG", "ACKER", "OBER", "MITTEL", "UNTER",
    /* en */ "STR", "DR", "RD", "AV"
  };
  String defaultCountry = "Switzerland";
	try {
    Codes codes = app.getCodes();
	  boolean actionCancel = false;

    RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));

    if(
       actionCancel ||
       !(
         (obj instanceof org.opencrx.kernel.account1.jmi1.Account)  ||
         (obj instanceof org.opencrx.kernel.account1.jmi1.PostalAddress)  ||
         (obj instanceof org.opencrx.kernel.contract1.jmi1.PostalAddress) ||
         (obj instanceof org.opencrx.kernel.depot1.jmi1.PostalAddress)    ||
         (obj instanceof org.opencrx.kernel.product1.jmi1.PostalAddress)
       )
    ) {
%>
      target object missing or not of expected type<br>
      XRI=<%= objectXri %><br>
      <INPUT type="Submit" name="Cancel.Button" tabindex="0" value="Close" onClick="javascript:window.close();" />
<%
    }
    else {
      List locations = new ArrayList();
      if (obj instanceof org.opencrx.kernel.account1.jmi1.Account) {
        org.opencrx.kernel.account1.jmi1.Account account = (org.opencrx.kernel.account1.jmi1.Account)obj;
        // Get account1 package
        org.opencrx.kernel.account1.jmi1.Account1Package accountPkg = org.opencrx.kernel.utils.Utils.getAccountPackage(pm);
        // get Postaladdresses of this account
        org.opencrx.kernel.account1.cci2.PostalAddressQuery addressFilter = accountPkg.createPostalAddressQuery();
        // TODO: verify
        addressFilter.forAllDisabled().isFalse();
        for (
          Iterator i = account.getAddress(addressFilter).iterator();
          i.hasNext();
        ) {
          locations.add((org.opencrx.kernel.account1.jmi1.PostalAddress)i.next());
        }
      }
      else {
        locations.add((org.opencrx.kernel.account1.jmi1.PostalAddress)obj);
      }

      String liveSearchAllUrl = "http://local.live.com/default.aspx?sp=adr.";
      boolean firstAddress = true;
      for(Iterator l = ((List)locations).iterator(); l.hasNext();) {

        org.opencrx.kernel.account1.jmi1.PostalAddress postalAddress = (org.opencrx.kernel.account1.jmi1.PostalAddress)l.next();
        String googleMapsUrl = "http://maps.google.com/maps?q=";
        //String liveSearchUrl = "http://local.live.com/default.aspx?sp=adr.710%20Ashbury%20St%2C%20San%20Francisco%2C%20CA%2094117|adr.1805%20Haight%20St%2C%20San%20Francisco%2C%20CA%2094117|adr.2401%20Market%20St%2C%20San%20Francisco%2C%20CA%2094114&v=1"
        String liveSearchUrl = "http://local.live.com/default.aspx?sp=adr.";
        String htmlAddress = "";

        int ii = 0;
        String allStreetLines = "";
        boolean atLeastOneIncluded = false;
        for(Iterator m = ((List)postalAddress.getPostalStreet()).iterator(); m.hasNext(); ii++) {
          String streetLine = (m.next().toString().toUpperCase()).trim();
          boolean include = false;
          for (int j=0; (j < streetPatterns.length) && !include; j++) {
            include = streetLine.indexOf(streetPatterns[j]) >= 0;
          }
          if (include) {
            atLeastOneIncluded = true;
            googleMapsUrl += "%20" + streetLine;
            liveSearchUrl += "%20" + streetLine;
            liveSearchAllUrl += "%20" + streetLine;
          }
          allStreetLines += "%20" + streetLine;
          htmlAddress += streetLine + "<br>";
        }
        if (!atLeastOneIncluded) {
          googleMapsUrl += "%20" + allStreetLines;
          liveSearchUrl += "%20" + allStreetLines;
          liveSearchAllUrl += "%20" + allStreetLines;
        }

        String tempStr = postalAddress.getPostalCode() == null
          ? ""
          : postalAddress.getPostalCode().trim();
        if (tempStr.length() > 0) {
          googleMapsUrl += "%20" + tempStr;
          liveSearchUrl += "%2C" + tempStr;
          liveSearchAllUrl += "%2C" + tempStr;
          htmlAddress   += tempStr + ", ";
        }

        tempStr = postalAddress.getPostalCity() == null
          ? ""
          : postalAddress.getPostalCity().trim();
        if (tempStr.length() > 0) {
          googleMapsUrl += "%20" + tempStr;
          liveSearchUrl += "%2C" + tempStr;
          liveSearchAllUrl += "%2C" + tempStr;
          htmlAddress   += tempStr + ", ";
        }

        // country in English, long text version
        String country = postalAddress.getPostalCountry() == 0
          ? defaultCountry
          : (String)(codes.getLongText("country", (short)0, true, true).get(new Short((short)postalAddress.getPostalCountry())));
        tempStr = (country.split("\\[")[0]).trim();
        if (tempStr.length() > 0) {
          googleMapsUrl += "%20" + tempStr;
          liveSearchUrl += "%2C" + tempStr + "&v=1";
          liveSearchAllUrl += "%2C" + tempStr + (l.hasNext() ? "|adr." : "&v=1");
          htmlAddress   += tempStr;
        }
%>
        <tr class="gridTableRowFull">
          <td>
            <a href="<%= googleMapsUrl %>" target="_blank"><img src="../../images/edit.gif" alt="" /></a><br />
          </td>
          <td>
            <a href="<%= googleMapsUrl %>"><%= htmlAddress %></a><br />
          </td>
<!--
          <td>
            <a href="<%= liveSearchUrl %>" target="_blank"><img src="../../images/edit.gif" alt="" /></a><br />
          </td>
          <td>
            <a href="<%= liveSearchUrl %>"><%= htmlAddress %></a><br />
          </td>
-->
        </tr>
<%
//        if (firstAddress && !l.hasNext()) {
//          // redirect to Google Maps with appropriate parameters
//          response.sendRedirect(googleMapsUrl);
//        }
        firstAddress = false;
      }
%>
      <tr class="gridTableRowFull">
        <td>
        </td>
        <td>
        </td>
<!--
        <td colspan="2">
          <a href="<%= liveSearchAllUrl %>" target="_blank"><img src="../../images/edit.gif" alt="" /> All addresses on the same map</a><br />
        </td>
-->
      </tr>
<%
    }
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
  </table>
  </td></tr></table>
</body>
</html>
