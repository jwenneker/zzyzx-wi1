<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     opencrx, http://www.opencrx.org/
 * Name:        $Id: ImportAccountsFromXLS.jsp,v 1.30 2011/11/02 16:30:55 cmu Exp $
 * Description: import accounts from Excel Sheet (xls or xslx format)
 * Revision:    $Revision: 1.30 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/11/02 16:30:55 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2008-2011, CRIXP Corp., Switzerland
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
java.math.*,
java.net.URL,
java.net.URLEncoder,
java.net.MalformedURLException,
java.io.UnsupportedEncodingException,
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.opencrx.kernel.portal.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.base.exception.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.action.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*,
org.openmdx.base.query.*,
org.openmdx.base.exception.*,
org.openmdx.kernel.log.*,
org.openmdx.uses.org.apache.commons.fileupload.*,
org.apache.poi.hssf.usermodel.*,
org.apache.poi.xssf.usermodel.*,
org.apache.poi.ss.usermodel.*,
org.apache.poi.hssf.util.*,
org.apache.poi.poifs.filesystem.POIFSFileSystem
" %>
<%!

    public List<org.opencrx.kernel.account1.jmi1.Contact> findContact(
        String firstName,
        String lastName,
        String aliasName,
        String extString0,
        org.opencrx.kernel.account1.jmi1.Segment accountSegment,
        javax.jdo.PersistenceManager pm
    ) {
        List<org.opencrx.kernel.account1.jmi1.Contact> matchingContacts = null;
        try {
            boolean hasQueryProperty = false;
            org.opencrx.kernel.account1.cci2.ContactQuery contactFilter =
                (org.opencrx.kernel.account1.cci2.ContactQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.Contact.class);
            if(extString0 != null) {
                hasQueryProperty = true;
                contactFilter.thereExistsExtString0().equalTo(extString0); // exact match required
            } else {
                contactFilter.forAllDisabled().isFalse();
                if(firstName != null) {
                    hasQueryProperty = true;
                    //contactFilter.thereExistsFirstName().like("(?i).*" + firstName + ".*");
                    contactFilter.thereExistsFirstName().equalTo(firstName); // exact match
                }
                if(lastName != null) {
                    hasQueryProperty = true;
                    //contactFilter.thereExistsLastName().like("(?i).*" + lastName + ".*");
                    contactFilter.thereExistsLastName().equalTo(lastName); // exact match
                }
                if(aliasName != null) {
                    hasQueryProperty = true;
                    //contactFilter.thereExistsLastName().like("(?i).*" + lastName + ".*");
                    contactFilter.thereExistsAliasName().equalTo(aliasName); // exact match
                }
            }
            if (hasQueryProperty) {
                Collection contacts = accountSegment.getAccount(contactFilter);
                if (!contacts.isEmpty()) {
                    for(Iterator c = contacts.iterator(); c.hasNext(); ) {
                        if (matchingContacts == null) {
                                matchingContacts = new ArrayList();
                        }
                        matchingContacts.add((org.opencrx.kernel.account1.jmi1.Contact)c.next());
                    }
                }
            }
        } catch (Exception e) {
            new ServiceException(e).log();
        }
        return matchingContacts;
    }

    public List<org.opencrx.kernel.account1.jmi1.AbstractGroup> findAbstractGroup(
        String name,
        String aliasName,
        String extString0,
        boolean allowDtypeGroup,
        boolean allowDtypeLegalEntity,
        boolean allowDtypeUnspecifiedAccount,
        org.opencrx.kernel.account1.jmi1.Segment accountSegment,
        javax.jdo.PersistenceManager pm
    ) {
        List<org.opencrx.kernel.account1.jmi1.AbstractGroup> matchingAbstractGroups = null;
        try {
            boolean hasQueryProperty = false;
            org.opencrx.kernel.account1.cci2.AbstractGroupQuery abstractGroupFilter =
                (org.opencrx.kernel.account1.cci2.AbstractGroupQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.AbstractGroup.class);
            if(extString0 != null) {
                hasQueryProperty = true;
                abstractGroupFilter.thereExistsExtString0().equalTo(extString0); // exact match required
            } else {
                abstractGroupFilter.forAllDisabled().isFalse();
                if(name != null) {
                    hasQueryProperty = true;
                    abstractGroupFilter.thereExistsFullName().like("(?i).*" + name + ".*");
                }
                if(aliasName != null) {
                    hasQueryProperty = true;
                    //abstractGroupFilter.thereExistsLastName().like("(?i).*" + lastName + ".*");
                    abstractGroupFilter.thereExistsAliasName().equalTo(aliasName); // exact match
                }
            }
            if (hasQueryProperty) {
                Collection abstractGroups = accountSegment.getAccount(abstractGroupFilter);
                if (!abstractGroups.isEmpty()) {
                    for(Iterator c = abstractGroups.iterator(); c.hasNext(); ) {
                        org.opencrx.kernel.account1.jmi1.AbstractGroup abstractGroup = (org.opencrx.kernel.account1.jmi1.AbstractGroup)c.next();
                        if (
                            (allowDtypeGroup && abstractGroup instanceof org.opencrx.kernel.account1.jmi1.Group) ||
                            (allowDtypeLegalEntity && abstractGroup instanceof org.opencrx.kernel.account1.jmi1.LegalEntity) ||
                            (allowDtypeUnspecifiedAccount && abstractGroup instanceof org.opencrx.kernel.account1.jmi1.UnspecifiedAccount)
                        ) {
                            if (matchingAbstractGroups == null) {
                                    matchingAbstractGroups = new ArrayList();
                            }
                            matchingAbstractGroups.add(abstractGroup);
                        }
                    }
                }
            }
        } catch (Exception e) {
            new ServiceException(e).log();
        }
        return matchingAbstractGroups;
    }

    public org.opencrx.kernel.account1.jmi1.Account findUniqueTargetAccount(
        String valueToMatch,
        org.opencrx.kernel.account1.jmi1.Segment accountSegment,
        javax.jdo.PersistenceManager pm
    ) {
        org.opencrx.kernel.account1.jmi1.Account targetAccount = null;
        if(valueToMatch != null) {
            boolean directMatch = valueToMatch.startsWith("@#");
            if (!directMatch) {
                // try to locate account based on fullName
                try {
                    org.opencrx.kernel.account1.cci2.AccountQuery accountFilter =
                        (org.opencrx.kernel.account1.cci2.AccountQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.Account.class);
                    accountFilter.forAllDisabled().isFalse(); // exlude disabled accounts in search
                    accountFilter.thereExistsFullName().like("(?i).*" + valueToMatch + ".*");
                    Iterator accounts = accountSegment.getAccount(accountFilter).iterator();
                    if (accounts.hasNext()) {
                        targetAccount = (org.opencrx.kernel.account1.jmi1.Account)accounts.next();
                        if (accounts.hasNext()) {
                            // match must be unique
                            targetAccount = null;
                        }
                    }
                } catch (Exception e) {
                    new ServiceException(e).log();
                }
            } else {
                valueToMatch = valueToMatch.substring(2);
            }

            if (directMatch || targetAccount == null) {
                // try to locate account based on exact match with extString0
                try {
                    org.opencrx.kernel.account1.cci2.AccountQuery accountFilter =
                        (org.opencrx.kernel.account1.cci2.AccountQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.Account.class);
                    //accountFilter.forAllDisabled().isFalse(); // include disabled accounts in search
                    accountFilter.thereExistsExtString0().equalTo(valueToMatch); // exact match required
                    Iterator accounts = accountSegment.getAccount(accountFilter).iterator();
                    if (accounts.hasNext()) {
                        targetAccount = (org.opencrx.kernel.account1.jmi1.Account)accounts.next();
                        if (accounts.hasNext()) {
                            // match must be unique
                            targetAccount = null;
                        }
                    }
                } catch (Exception e) {
                    new ServiceException(e).log();
                }
            }
        }
        return targetAccount;
    }

    public org.opencrx.kernel.account1.jmi1.Member createOrUpdateMember(
        org.opencrx.kernel.account1.jmi1.Account parentAccount,
        org.opencrx.kernel.account1.jmi1.Account memberAccount,
        String keyMemberRole, /* a semicolon-separated list */
        String feature,
        Codes codes,
        org.opencrx.kernel.account1.jmi1.Account1Package accountPkg,
        org.opencrx.kernel.account1.jmi1.Segment accountSegment,
        javax.jdo.PersistenceManager pm
    ) {
        org.opencrx.kernel.account1.jmi1.Member member = null;
        List<Short> memberRoles = new ArrayList<Short>();
        if ((parentAccount != null) && (memberAccount != null)) {
            if (keyMemberRole != null) {
                StringTokenizer tokenizer = new StringTokenizer(keyMemberRole, ";", false);
                while(tokenizer.hasMoreTokens()) {
                    String memberRoleStr = (String)tokenizer.nextToken();
                    short memberRole = codes.findCodeFromValue(
                        memberRoleStr,
                        feature
                    );
                    if (memberRole == 0) {
                        try {
                            memberRole = Short.parseShort(memberRoleStr);
                        } catch (Exception e) {}
                    }
                    if (memberRole != 0) {
                        memberRoles.add(memberRole);
                    }
                }
            }

            // try to locate member with same parent and account (or create new member)
            org.opencrx.kernel.account1.cci2.MemberQuery memberFilter = accountPkg.createMemberQuery();
            memberFilter.forAllDisabled().isFalse();
            memberFilter.thereExistsAccount().equalTo(memberAccount);
            // memberFilter.thereExistsMemberRole().equalTo(memberRole);
            try {
                Iterator m = parentAccount.getMember(memberFilter).iterator();
                if (m.hasNext()) {
                    member = (org.opencrx.kernel.account1.jmi1.Member)m.next();
                } else {
                    // create new member
                    member = accountPkg.getMember().createMember();
                    member.refInitialize(false, false);
                    member.setValidFrom(new java.util.Date());
                    parentAccount.addMember(
                        false,
                        org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
                        member
                    );
                }
            } catch (Exception e) {
                new ServiceException(e).log();
            }
            if (member != null) {
                member.setMemberRole(memberRoles);
                member.setAccount(memberAccount);
                member.setName(memberAccount.getFullName());
                member.setQuality((short)5); // normal
                if (
                    (memberAccount.isDisabled() != null && memberAccount.isDisabled().booleanValue()) &&
                    (member.isDisabled() == null || (!member.isDisabled().booleanValue()))
                ) {
                    // disable member if memberAccount is disabled
                    member.setDisabled(new Boolean(true));
                    member.setDisabledReason("referenced Account is disabled");
                }
                //System.out.println("member parent: " + memberAccount.getFullName());
                //System.out.println("member child:  " + parentAccount.getFullName());
                //System.out.println("member role:   " + memberRole);
            }
        }
        return member;
    }

    public org.opencrx.kernel.generic.jmi1.Note createOrUpdateNote(
        org.opencrx.kernel.account1.jmi1.Account account,
        String noteTitle,
        String noteText,
        org.opencrx.kernel.generic.jmi1.GenericPackage genericPkg,
        javax.jdo.PersistenceManager pm
    ) {
        org.opencrx.kernel.generic.jmi1.Note note = null;
        if (account != null && noteTitle != null  && noteTitle.length() > 0) {
            // try to locate note with same parent and title (or create new note)
            org.opencrx.kernel.generic.cci2.NoteQuery noteFilter = genericPkg.createNoteQuery();
            //noteFilter.forAllDisabled().isFalse();
            noteFilter.thereExistsTitle().equalTo(noteTitle);
            try {
                Iterator n = account.getNote(noteFilter).iterator();
                if (n.hasNext()) {
                    note = (org.opencrx.kernel.generic.jmi1.Note)n.next();
                } else {
                    // create new note
                    note = genericPkg.getNote().createNote();
                    note.refInitialize(false, false);
                    account.addNote(
                        false,
                        org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
                        note
                    );
                }
            } catch (Exception e) {
                new ServiceException(e).log();
            }
            if (note != null) {
                note.setTitle(noteTitle);
                note.setText(noteText);
            }
        }
        return note;
    }

    public String getObjectHref(
        org.opencrx.kernel.generic.jmi1.CrxObject crxObject
    ) {
        String href = "";
        if (crxObject != null) {
            Action parentAction = new Action(
                SelectObjectAction.EVENT_ID,
                new Action.Parameter[]{
                    new Action.Parameter(Action.PARAMETER_OBJECTXRI, crxObject.refMofId())
                },
                "",
                true // enabled
            );
            href = "../../" + parentAction.getEncodedHRef();
        }
        return href;
    }

%>

<%
    final String ATTR_EXTSTRING0 = "extString0";
    final String ATTR_FIRSTNAME = "FirstName";
    final String ATTR_LASTNAME = "LastName";
    final String ATTR_ALIASNAME = "AliasName";
    final String ATTR_COMPANY = "Company";
    final String ATTR_DTYPE = "Dtype";
    final String ATTR_XRI = "xri";

    final String ATTR_MEMBEROF = "MemberOf";
    final String ATTR_MEMBERROLE = "MemberRole";
    final String ATTR_NOTETITLE = "NoteTitle";
    final String ATTR_NOTETEXT = "NoteText";

    final String ATTR_TITLE = "title";
    final String ATTR_ACADEMICTITLE = "academicTitle";
    final String ATTR_MIDDLENAME = "middleName";
    final String ATTR_SUFFIX = "suffix";
    final String ATTR_NICKNAME = "nickName";
    final String ATTR_COMPANYROLE = "companyRole";
    final String ATTR_JOBTITLE = "jobTitle";
    final String ATTR_DEPARTMENT = "DEPARTMENT";
    final String ATTR_BIRTHDAY = "BIRTHDAY";
    final String ATTR_HOMEPHONE = "HOMEPHONE";
    final String ATTR_HOMEPHONE2 = "HOMEPHONE2";
    final String ATTR_HOMEFAX = "HOMEFAX";
    final String ATTR_HOMEADDRESSLINE = "HOMEADDRESSLINE";
    final String ATTR_HOMESTREET = "HOMESTREET";
    final String ATTR_HOMECITY = "HOMECITY";
    final String ATTR_HOMEPOSTALCODE = "HOMEPOSTALCODE";
    final String ATTR_HOMESTATE = "HOMESTATE";
    final String ATTR_HOMECOUNTRY = "HOMECOUNTRY";
    final String ATTR_HOMECOUNTRYREGION = "HOMECOUNTRYREGION";
    final String ATTR_NOTES = "NOTES";

    final String ATTR_BUSINESSPHONE = "BUSINESSPHONE";
    final String ATTR_BUSINESSPHONE2 = "BUSINESSPHONE2";
    final String ATTR_BUSINESSFAX = "BUSINESSFAX";
    final String ATTR_MOBILEPHONE = "MOBILEPHONE";
    final String ATTR_EMAILADDRESS = "EMAILADDRESS";
    final String ATTR_EMAIL2ADDRESS = "EMAIL2ADDRESS";
    final String ATTR_EMAIL3ADDRESS = "EMAIL3ADDRESS";
    final String ATTR_WEBPAGE = "WEBPAGE";
    final String ATTR_BUSINESSADDRESSLINE = "BUSINESSADDRESSLINE";
    final String ATTR_BUSINESSSTREET = "BUSINESSSTREET";
    final String ATTR_BUSINESSCITY = "BUSINESSCITY";
    final String ATTR_BUSINESSPOSTALCODE = "BUSINESSPOSTALCODE";
    final String ATTR_BUSINESSSTATE = "BUSINESSSTATE";
    final String ATTR_BUSINESSCOUNTRY = "BUSINESSCOUNTRY";
    final String ATTR_BUSINESSCOUNTRYREGION = "BUSINESSCOUNTRYREGION";
    final String ATTR_ASSISTANTSNAME = "ASSISTANTSNAME";
    final String ATTR_ASSISTANTSNAMEROLE = "ASSISTANTSNAMEROLE";
    final String ATTR_MANAGERSNAME = "MANAGERSNAME";
    final String ATTR_MANAGERSROLE = "MANAGERSROLE";
    final String ATTR_CATEGORIES = "CATEGORIES";
    final String ATTR_BUSINESSTYPE = "BUSINESSTYPE";

/*  not yet implemented
    final String ATTR_ALTADDR_PHONE = "ALTADDR_PHONE";
    final String ATTR_ALTADDR_PHONEUSAGE = "ALTADDR_PHONE_USAGE";
    final String ATTR_ALTADDR_EMAILADDRESS = "ALTADDR_EMAILADDRESS";
    final String ATTR_ALTADDR_EMAILADDRESSUSAGE = "ALTADDR_EMAILADDRESS_USAGE";
    final String ATTR_ALTADDR_ADDRESSLINE = "ALTADDR_ADDRESSLINE";
    final String ATTR_ALTADDR_STREET = "ALTADDR_STREET";
    final String ATTR_ALTADDR_CITY = "ALTADDR_CITY";
    final String ATTR_ALTADDR_POSTALCODE = "ALTADDR_POSTALCODE";
    final String ATTR_ALTADDR_STATE = "ALTADDR_STATE";
    final String ATTR_ALTADDR_COUNTRY = "ALTADDR_COUNTRY";
    final String ATTR_ALTADDR_COUNTRYREGION = "ALTADDR_COUNTRYREGION";
    final String ATTR_ALTADDR_USAGE = "ALTADDR_USAGE";
*/

    final String DTYPE_CONTACT = "Contact";
    final String DTYPE_GROUP = "Group";
    final String DTYPE_LEGALENTITY = "LegalEntity";
    final String DTYPE_UNSPECIFIEDACCOUNT = "UnspecifiedAccount";
    final String FEATURE_POSTALCOUNTRY_CODE = "org:opencrx:kernel:address1:PostalAddressable:postalCountry";
    final String FEATURE_SALUTATION_CODE = "org:opencrx:kernel:account1:Contact:salutationCode";
    final String FEATURE_ACADEMICTITLE = "org:opencrx:kernel:account1:Contact:userCode1";
    final String FEATURE_MEMBERROLE = "org:opencrx:kernel:account1:Member:memberRole";

    final String EXTSTRING0PREFIX = "@#";
    final String EOL_HTML = "<br>";

    request.setCharacterEncoding("UTF-8");
    ApplicationContext app = (ApplicationContext)session.getValue(WebKeys.APPLICATION_KEY);
    Map parameterMap = request.getParameterMap();
    if(FileUpload.isMultipartContent(request)) {
        parameterMap = new HashMap();
        DiskFileUpload upload = new DiskFileUpload();
        upload.setHeaderEncoding("UTF-8");
        try {
            List items = upload.parseRequest(
              request,
              200, // in-memory threshold. Content for fields larger than threshold is written to disk
              50000000, // max request size [overall limit]
              app.getTempDirectory().getPath()
            );
            for(Iterator i = items.iterator(); i.hasNext(); ) {
              FileItem item = (FileItem)i.next();
              if(item.isFormField()) {
                parameterMap.put(
                  item.getFieldName(),
                  new String[]{item.getString("UTF-8")}
                );
              }
              else {
                // reset binary
                if("#NULL".equals(item.getName())) {
                  parameterMap.put(
                    item.getFieldName(),
                    new String[]{item.getName()}
                  );
                }
                // add to parameter map if file received
                else if(item.getSize() > 0) {
                  parameterMap.put(
                    item.getFieldName(),
                    new String[]{item.getName()}
                  );
                  String location = app.getTempFileName(item.getFieldName(), "");

                  // bytes
                  File outFile = new File(location);
                  item.write(outFile);

                  // type
                  PrintWriter pw = new PrintWriter(
                    new FileOutputStream(location + ".INFO")
                  );
                  pw.println(item.getContentType());
                  int sep = item.getName().lastIndexOf("/");
                  if(sep < 0) {
                    sep = item.getName().lastIndexOf("\\");
                  }
                  pw.println(item.getName().substring(sep + 1));
                  pw.close();
                }
              }
            }
        }
        catch(FileUploadException e) {
            SysLog.warning("cannot upload file", e.getMessage());
%>
            <div style="padding:10px 10px 10px 10px;background-color:#FF0000;color:#FFFFFF;">
              <table>
                <tr>
                  <td style="padding:5px;"><b>ERROR</b>:</td>
                  <td>cannot upload file - <%= e.getMessage() %></td>
                </tr>
              </table>
            </div>
<%
        }
    }
    String[] requestIds = (String[])parameterMap.get(Action.PARAMETER_REQUEST_ID);
    String requestId = (requestIds == null) || (requestIds.length == 0) ? request.getParameter(Action.PARAMETER_REQUEST_ID) : requestIds[0];
    String requestIdParam = Action.PARAMETER_REQUEST_ID + "=" + requestId;
    String[] objectXris = (String[])parameterMap.get("xri");
    String objectXri = (objectXris == null) || (objectXris.length == 0) ? null : objectXris[0];
    ViewsCache viewsCache = (ViewsCache)session.getValue(WebKeys.VIEW_CACHE_KEY_SHOW);
    if(objectXri == null || app == null || viewsCache.getView(requestId) == null) {
        response.sendRedirect(
               request.getContextPath() + "/" + WebKeys.SERVLET_NAME
        );
        return;
    }
    javax.jdo.PersistenceManager pm = app.getNewPmData();
    Texts_1_0 texts = app.getTexts();
    Codes codes = app.getCodes();
    final String formAction = "ImportAccountsFromXLS.jsp";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="org.opencrx.kernel.generic.jmi1.CrxObject"%><html>

<head>
  <title>Import Accounts from Excel Sheet (xls or xslx format)</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta name="UNUSEDlabel" content="Import Accounts from Excel Sheet (XLS/XSLX)">
  <meta name="UNUSEDtoolTip" content="Import Accounts from Excel Sheet (XLS/XSLX)">
  <meta name="targetType" content="_self">
  <meta name="forClass" content="org:opencrx:kernel:account1:Segment">
  <meta name="order" content="org:opencrx:kernel:account1:Segment:importAccountsFromXLS">
  <link href="../../_style/colors.css" rel="stylesheet" type="text/css">
  <link href="../../_style/n2default.css" rel="stylesheet" type="text/css" />
  <script language="javascript" type="text/javascript" src="../../javascript/prototype.js"></script>

  <link rel='shortcut icon' href='../../images/favicon.ico' />

  <style type="text/css">
      .gridTableHeaderFull TD {
          padding: 1px 5px 1px 5px; /* top right bottom left */
          white-space: nowrap;
      }
      .err {background-color:red;color:white;}
      .ImportTable {border-collapse:collapse;border:1px solid grey;}
      .ImportTable .attributes TD {font-weight:bold;background-color:orange;}
      .ImportTable .sheetInfo TD {background-color:yellow;padding:5px;}
      .ImportTable .importHeader TD {font-weight:bold;background-color:#ddd;}
      .ImportTable TD {white-space:nowrap;border:1px solid grey;padding:1px;}
      .ImportTable TD.empty {background-color:grey;}
      .ImportTable TD.searchAttr {background-color:#CFE9FE;}
      .ImportTable TD.match {background-color:#D2FFD2;}
      .ImportTable TD.create {background-color:#00FF00;}
      .ImportTable TD.ok {background-color:#00FF00;}
      .ImportTable TD.nok {background-color:#FF0000;}
  </style>
</head>

<body>
<div id="container">
    <div id="wrap">
        <div id="fixheader" style="height:90px;">
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
        <div id="content" style="padding:10px 0.5em 0px 0.5em;">

<%
    NumberFormat formatter = new DecimalFormat("0000");
    final String UPLOAD_FILE_FIELD_NAME = "uploadFile";
    try {
      boolean actionOk = parameterMap.get("OK.Button") != null;
      boolean actionCancel = parameterMap.get("Cancel.Button") != null;
      boolean continueToExit = false;

      String[] descriptions = (String[])parameterMap.get("description");
      String description = (descriptions == null) || (descriptions.length == 0) ? "" : descriptions[0];

      //System.out.println("XRI=" + objectXri);
      String location = app.getTempFileName(UPLOAD_FILE_FIELD_NAME, "");

      // Get data package. This is the JMI root package to handle
      // openCRX object requests

      RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));

      Path objectPath = new Path(objectXri);
      String providerName = objectPath.get(2);
      String segmentName = objectPath.get(4);

      //Set userRoles = app.getUserRoles();
      String currentUserRole = app.getCurrentUserRole();
      String adminRole = "admin-" + segmentName + "@" + segmentName;
      boolean permissionOk = currentUserRole.compareTo(adminRole) == 0;
      permissionOk = true;

      if(actionCancel || (objectXri == null) || (!permissionOk)) {
          Action nextAction = new ObjectReference(
            (RefObject_1_0)pm.getObjectById(new Path(objectXri)),
            app
          ).getSelectObjectAction();
          continueToExit = true;
          if (actionCancel) {
              response.sendRedirect(
                  request.getContextPath() + "/" + nextAction.getEncodedHRef()
              );
          } else {
              String errorMessage = "Cannot upload Excel File!)";
              if (!permissionOk) {errorMessage = "no permission to run this wizard";}
%>
                  <br />
                  <br />
                  <span style="color:red;"><b><u>ERROR:</u> <%= errorMessage %></b></span>
                  <br />
                  <br />
                  <INPUT type="Submit" name="Cancel.Button" tabindex="1" value="Weiter" onClick="javascript:location='<%= request.getContextPath() + "/" + nextAction.getEncodedHRef() %>';" />
                  <br />
                  <br />
                  <hr>
<%
          }
      }
      else if(actionOk) {
          if(
              new File(location + ".INFO").exists() &&
              new File(location).exists() &&
              (new File(location).length() > 0)
          ) {
              // mimeType and name
              BufferedReader r = new BufferedReader(
                  new FileReader(location + ".INFO")
              );
              String contentMimeType = r.readLine();
              String contentName = r.readLine();
              r.close();
              new File(location + ".INFO").delete();

              if(
                  (contentName != null) &&
                  (contentName.length() > 0) &&
                  (contentMimeType != null) &&
                  (contentMimeType.length() > 0)
              ) {
                  try {
                      java.util.Date today = new java.util.Date();

                      // Get generic package
                      org.opencrx.kernel.generic.jmi1.GenericPackage genericPkg = org.opencrx.kernel.utils.Utils.getGenericPackage(pm);

                      // Get acount1 package
                      org.opencrx.kernel.account1.jmi1.Account1Package accountPkg = org.opencrx.kernel.utils.Utils.getAccountPackage(pm);

                      // Get account segment
                      org.opencrx.kernel.account1.jmi1.Segment accountSegment =
                        (org.opencrx.kernel.account1.jmi1.Segment)pm.getObjectById(
                          new Path("xri:@openmdx:org.opencrx.kernel.account1/provider/" + providerName + "/segment/" + segmentName)
                         );

                      int idxExtString0 = -1;
                      int idxFirstName = -1;
                      int idxLastName = -1;
                      int idxAliasName = -1;
                      int idxCompany = -1;
                      int idxDtype = -1;
                      int idxXri = -1;
                      Set explicitlyMappedAttributes = new HashSet(); // contains (capitalized) feature names mapped explicitely

                      explicitlyMappedAttributes.add(ATTR_EXTSTRING0.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_FIRSTNAME.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_LASTNAME.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ALIASNAME.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_COMPANY.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_DTYPE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_XRI.toUpperCase());

                      explicitlyMappedAttributes.add(ATTR_MEMBEROF.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_MEMBERROLE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_NOTETITLE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_NOTETEXT.toUpperCase());

                      explicitlyMappedAttributes.add(ATTR_TITLE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ACADEMICTITLE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_MIDDLENAME.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_SUFFIX.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_NICKNAME.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_COMPANYROLE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_JOBTITLE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_DEPARTMENT.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_BIRTHDAY.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_HOMEPHONE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_HOMEPHONE2.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_HOMEFAX.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_HOMEADDRESSLINE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_HOMESTREET.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_HOMECITY.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_HOMEPOSTALCODE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_HOMESTATE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_HOMECOUNTRY.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_HOMECOUNTRYREGION.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_NOTES.toUpperCase());

                      explicitlyMappedAttributes.add(ATTR_BUSINESSPHONE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_BUSINESSPHONE2.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_BUSINESSFAX.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_MOBILEPHONE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_EMAILADDRESS.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_EMAIL2ADDRESS.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_EMAIL3ADDRESS.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_WEBPAGE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_BUSINESSADDRESSLINE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_BUSINESSSTREET.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_BUSINESSCITY.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_BUSINESSPOSTALCODE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_BUSINESSSTATE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_BUSINESSCOUNTRY.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_BUSINESSCOUNTRYREGION.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ASSISTANTSNAME.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ASSISTANTSNAMEROLE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_MANAGERSNAME.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_MANAGERSROLE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_CATEGORIES.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_BUSINESSTYPE.toUpperCase());

/*  not yet implemented
                      explicitlyMappedAttributes.add(ATTR_ALTADDR_PHONE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ALTADDR_PHONEUSAGE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ALTADDR_EMAILADDRESS.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ALTADDR_EMAILADDRESSUSAGE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ALTADDR_ADDRESSLINE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ALTADDR_STREET.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ALTADDR_CITY.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ALTADDR_POSTALCODE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ALTADDR_STATE.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ALTADDR_COUNTRY.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ALTADDR_COUNTRYREGION.toUpperCase());
                      explicitlyMappedAttributes.add(ATTR_ALTADDR_USAGE.toUpperCase());
*/

                      // verify whether File exists
				              Workbook wb = null;
				              try {
				            	  wb = WorkbookFactory.create(new FileInputStream(location));
				              } catch (Exception e) {
				            	  new ServiceException(e).log();
				              }

                      if(permissionOk && actionOk && (wb != null)) {
                          continueToExit = true;

                          try {
                              //for (int i = 0; i < workbook.getNumberOfSheets(); i++) {
                              // read first sheet only!!!
                              for (int i = 0; i < 1; i++) {
                                  Sheet sheet = wb.getSheetAt(i);
                                  int linesRead = 0;
                                  int contactsUpdated = 0;
                                  int contactsCreated = 0;
                                  int groupsUpdated = 0;
                                  int groupsCreated = 0;
                                  int legalEntitiesUpdated = 0;
                                  int legalEntitiesCreated = 0;
                                  int unspecifiedAccountsUpdated = 0;
                                  int unspecifiedAccountsCreated = 0;

%>
                                  <table class="ImportTable">
<%
                                  Iterator rows = sheet.rowIterator();
                                  int nRow = 0;
                                  int maxCell = 0;
                                  Row row = null;

                                  Map attributeMap = new TreeMap();
                                  if (rows.hasNext()) {
                                       nRow += 1;
                                      // read first row with attribute names
%>
                                      <tr class="attributes">
                                          <td>Row<br><%= formatter.format(nRow) %></td>
<%
                                          row = (Row) rows.next();
                                          try {
                                              Iterator cells = row.cellIterator();
                                              int nCell = 0;
                                              while (cells.hasNext()) {
                                                  Cell cell = (Cell)cells.next();
                                                  nCell = cell.getColumnIndex();
                                                  if (nCell > maxCell) {
                                                      maxCell = nCell;
                                                  }
                                                  try {
                                                      if (
                                                          (cell.getCellType() == Cell.CELL_TYPE_STRING) &&
                                                          (cell.getStringCellValue() != null)
                                                      ) {
                                                          boolean isSearchAttribute = false;
                                                          String cellValue = (cell.getStringCellValue().trim());
                                                          attributeMap.put(formatter.format(nCell), cellValue);
                                                          // get idx of select attributes
                                                          if (ATTR_EXTSTRING0.compareToIgnoreCase(cellValue) == 0) {
                                                              idxExtString0 = nCell;
                                                              isSearchAttribute = true;
                                                          } else if (ATTR_FIRSTNAME.compareToIgnoreCase(cellValue) == 0) {
                                                              idxFirstName = nCell;
                                                              isSearchAttribute = true;
                                                          } else if (ATTR_LASTNAME.compareToIgnoreCase(cellValue) == 0) {
                                                              idxLastName = nCell;
                                                              isSearchAttribute = true;
                                                          } else if (ATTR_ALIASNAME.compareToIgnoreCase(cellValue) == 0) {
                                                              idxAliasName = nCell;
                                                              isSearchAttribute = true;
                                                          } else if (ATTR_COMPANY.compareToIgnoreCase(cellValue) == 0) {
                                                              idxCompany = nCell;
                                                              isSearchAttribute = true;
                                                          } else if (ATTR_DTYPE.compareToIgnoreCase(cellValue) == 0) {
                                                              idxDtype = nCell;
                                                          } else if (ATTR_XRI.compareToIgnoreCase(cellValue) == 0) {
                                                              idxXri = nCell;
                                                              isSearchAttribute = true;
                                                          }
%>
                                                          <td <%= isSearchAttribute ? "class='searchAttr' title='attribute used for matching'" : "" %>>Col-<%= formatter.format(nCell) + EOL_HTML + cellValue %></td>
<%
                                                      } else {
%>
                                                          <td class="err">c<%= formatter.format(nCell) %>[not a string cell]<br><%= cell.getCellFormula() %></td>
<%
                                                      }
                                                  } catch (Exception ec) {
                                                        new ServiceException(ec).log();
%>
                                                        <td class="err">c<%= formatter.format(nCell) %> [UNKNOWN ERROR]<br><%= cell.getCellFormula() %></td>
<%
                                                  }
                                              }
                                          } catch (Exception e) {
                                              new ServiceException(e).log();
%>
                                              <td class="err">ERROR in Attribute Row!</td>
<%
                                          }
%>
                                      </tr>
<%
                                  }
                                  while (rows.hasNext()) {
                                      nRow += 1;
                                      linesRead += 1;

                                      org.opencrx.kernel.account1.jmi1.Contact contact = null;
                                      org.opencrx.kernel.account1.jmi1.LegalEntity legalEntity = null;
                                      org.opencrx.kernel.account1.jmi1.Group group = null;
                                      org.opencrx.kernel.account1.jmi1.UnspecifiedAccount unspecifiedAccount = null;
                                      boolean dtypeExplicitlySet = false;
                                      boolean xriExplicitlySet = false;
                                      boolean isDtypeContact = true; // default
                                      boolean isDtypeGroup = false;
                                      boolean isDtypeLegalEntity = false;
                                      boolean isDtypeUnspecifiedAccount = false;
                                      String className = DTYPE_CONTACT; // default

                                      row = (Row) rows.next();
                                      String extString0 = null;
                                      String firstName = null;
                                      String lastName = null;
                                      String aliasName = null;
                                      String company = null;
                                      String xri = null;

                                      String cellId = null;
                                      String multiMatchList = "";
                                      //Map valueMap = new TreeMap();
                                      Map valueMap = new TreeMap<String,Object>(String.CASE_INSENSITIVE_ORDER);
                                      boolean isCreation = false;
                                      boolean isUpdate = false;
                                      String appendErrorRow = null;
%>
                                      <tr>
                                          <td><b>Row<br><%= formatter.format(nRow) %></b></td>
<%
                                          String jsBuffer = "";
                                          try {
                                              Iterator cells = row.cellIterator();
                                              int nCell = 0;
                                              int currentCell = 0;
                                              appendErrorRow = null;
                                              while (cells.hasNext()) {
                                                  //Cell cell = (Cell)row.getCell((short)0);
                                                  Cell cell = (Cell)cells.next();
                                                  nCell = cell.getColumnIndex();
                                                  if (nCell > currentCell) {
%>
                                                      <td colspan="<%= nCell-currentCell %>" class="empty">&nbsp;</td>
<%
                                                  }
                                                  currentCell = nCell+1;
                                                  try {
                                                      cellId =  "id='r" + nRow + (attributeMap.get(formatter.format(nCell))).toString().toUpperCase() + "'";
                                                      if (cell.getCellType() == Cell.CELL_TYPE_STRING) {
                                                          String cellValue = cell.getStringCellValue().trim();
                                                          valueMap.put((attributeMap.get(formatter.format(nCell))).toString(), cellValue);
                                                          if (nCell == idxDtype) {
                                                              if (DTYPE_GROUP.compareToIgnoreCase(cellValue) == 0) {
                                                                  dtypeExplicitlySet = true;
                                                                  isDtypeGroup = true;
                                                                  isDtypeContact = false;
                                                                  className = DTYPE_GROUP;
                                                              } else if (DTYPE_LEGALENTITY.compareToIgnoreCase(cellValue) == 0) {
                                                                  dtypeExplicitlySet = true;
                                                                  isDtypeLegalEntity = true;
                                                                  isDtypeContact = false;
                                                                  className = DTYPE_LEGALENTITY;
                                                              } else if (DTYPE_UNSPECIFIEDACCOUNT.compareToIgnoreCase(cellValue) == 0) {
                                                                  dtypeExplicitlySet = true;
                                                                  isDtypeUnspecifiedAccount = true;
                                                                  isDtypeContact = false;
                                                                  className = DTYPE_UNSPECIFIEDACCOUNT;
                                                              } else if (DTYPE_CONTACT.compareToIgnoreCase(cellValue) == 0) {
                                                                  dtypeExplicitlySet = true;
                                                                  className = DTYPE_UNSPECIFIEDACCOUNT;
                                                              }
                                                          } else if (nCell == idxExtString0) {
                                                              extString0 = cellValue;
                                                          } else if (nCell == idxFirstName) {
                                                              firstName = cellValue;
                                                          } else if (nCell == idxLastName) {
                                                              lastName = cellValue;
                                                          } else if (nCell == idxAliasName) {
                                                              aliasName = cellValue;
                                                          } else if (nCell == idxCompany) {
                                                              company = cellValue;
                                                          } else if (nCell == idxXri) {
                                                              xriExplicitlySet = true;
                                                              xri = cellValue;
                                                          }
%>
                                                          <td <%= cellId %>><%= cellValue != null ? (cellValue.replace("\r\n", EOL_HTML)).replace("\n", EOL_HTML) : "" %></td>
<%
                                                      } else if (cell.getCellType() == Cell.CELL_TYPE_NUMERIC) {
                                                          BigDecimal cellValue = new BigDecimal(cell.getNumericCellValue());
                                                          valueMap.put((attributeMap.get(formatter.format(nCell))).toString(), cellValue);
%>
                                                          <td <%= cellId %>><%= cellValue %></td>
<%
                                                      } else if (cell.getCellType() == Cell.CELL_TYPE_BOOLEAN) {
                                                          boolean cellValue = cell.getBooleanCellValue();
                                                          valueMap.put((attributeMap.get(formatter.format(nCell))).toString(), cellValue);
%>
                                                          <td <%= cellId %>><%= cellValue ? "TRUE" : "FALSE" %></td>
<%
                                                      } else if (cell.getCellType() == Cell.CELL_TYPE_BLANK) {
%>
                                                          <td <%= cellId %> class="empty">&nbsp;</td>
<%
                                                      } else {
%>
                                                          <td class="err">r<%= formatter.format(nRow) %>-c<%= formatter.format(nCell) %>[cell-type (<%= cell.getCellType() %>) not supported]<br><%= cell.getCellFormula() %></td>
<%
                                                      }
                                                  } catch (Exception ec) {
                                                      new ServiceException(ec).log();
%>
                                                      <td class="err">r<%= formatter.format(nRow) %>-c<%= formatter.format(nCell) %> [UNKNOWN ERROR]<br><%= cell.getCellFormula() %></td>
<%
                                                  }
                                              }
                                              if (nCell < maxCell) {
%>
                                                  <td colspan="<%= maxCell-nCell %>" class="empty"></td>
<%
                                              }
                                          } catch (Exception e) {
                                              new ServiceException(e).log();
%>
                                              <td class="err" colspan="<%= maxCell+2 %>">ERROR in Attribute Row!</td>
<%
                                          }
                                          boolean createNew = true;
                                          boolean updateExisting = false;

                                          List<org.opencrx.kernel.account1.jmi1.Contact> matchingContacts = null;
                                          List<org.opencrx.kernel.account1.jmi1.AbstractGroup> matchingAbstractGroups = null;
                                          String accountHref = "";
                                          org.opencrx.kernel.account1.jmi1.Account account = null;

                                          if (xriExplicitlySet) {
                                              // try to find existing account with provided xri
                                              try {
                                                  account = (org.opencrx.kernel.account1.jmi1.Account)pm.getObjectById(new Path(xri));
                                              } catch (Exception e) {
                                                  new ServiceException(e).log();
                                              }
                                              if (account != null) {
                                                  dtypeExplicitlySet = true;
                                                  isDtypeContact = false;
                                                  isDtypeGroup = false;
                                                  isDtypeLegalEntity = false;
                                                  isDtypeUnspecifiedAccount = false;
                                                  if (account instanceof org.opencrx.kernel.account1.jmi1.Contact) {
                                                      isDtypeContact = true;
                                                      matchingContacts = new ArrayList();
                                                      matchingContacts.add((org.opencrx.kernel.account1.jmi1.Contact)account);
                                                  } else if (account instanceof org.opencrx.kernel.account1.jmi1.Group) {
                                                      isDtypeGroup = true;
                                                      matchingAbstractGroups = new ArrayList();
                                                      matchingAbstractGroups.add((org.opencrx.kernel.account1.jmi1.AbstractGroup)account);
                                                  } else if (account instanceof org.opencrx.kernel.account1.jmi1.LegalEntity) {
                                                      isDtypeLegalEntity = true;
                                                      matchingAbstractGroups = new ArrayList();
                                                      matchingAbstractGroups.add((org.opencrx.kernel.account1.jmi1.AbstractGroup)account);
                                                  } else if (account instanceof org.opencrx.kernel.account1.jmi1.UnspecifiedAccount) {
                                                      isDtypeUnspecifiedAccount = true;
                                                      matchingAbstractGroups = new ArrayList();
                                                      matchingAbstractGroups.add((org.opencrx.kernel.account1.jmi1.AbstractGroup)account);
                                                  }
                                              }
                                          }

                                          if (!dtypeExplicitlySet) {
                                              // try to find existing account to determine dtype
                                              matchingContacts = findContact(
                                                  firstName,
                                                  lastName,
                                                  aliasName,
                                                  extString0,
                                                  accountSegment,
                                                  pm
                                              );
                                              if (matchingContacts == null) {
                                                  // try again without aliasName
                                                  matchingContacts = findContact(
                                                      firstName,
                                                      lastName,
                                                      null,
                                                      extString0,
                                                      accountSegment,
                                                      pm
                                                  );
                                              }
                                              if (matchingContacts != null) {
                                                  dtypeExplicitlySet = true;
                                              } else {
                                                  matchingAbstractGroups = findAbstractGroup(
                                                      company,
                                                      aliasName,
                                                      extString0,
                                                      true,
                                                      true,
                                                      true,
                                                      accountSegment,
                                                      pm
                                                  );
                                                  if (matchingAbstractGroups != null) {
                                                      org.opencrx.kernel.account1.jmi1.AbstractGroup matchingAbstractGroup = (org.opencrx.kernel.account1.jmi1.AbstractGroup)(matchingAbstractGroups.iterator().next());
                                                      if (matchingAbstractGroup instanceof org.opencrx.kernel.account1.jmi1.Group) {
                                                          dtypeExplicitlySet = true;
                                                          isDtypeGroup = true;
                                                          isDtypeContact = false;
                                                          className = DTYPE_GROUP;
                                                      } else if (matchingAbstractGroup instanceof org.opencrx.kernel.account1.jmi1.LegalEntity) {
                                                          dtypeExplicitlySet = true;
                                                          isDtypeLegalEntity = true;
                                                          isDtypeContact = false;
                                                          className = DTYPE_LEGALENTITY;
                                                      } else if (matchingAbstractGroup instanceof org.opencrx.kernel.account1.jmi1.UnspecifiedAccount) {
                                                          dtypeExplicitlySet = true;
                                                          isDtypeUnspecifiedAccount = true;
                                                          isDtypeContact = false;
                                                          className = DTYPE_UNSPECIFIEDACCOUNT;
                                                      }
                                                  }
                                              }
                                          }

                                          if (isDtypeContact) {
                                              if (matchingContacts == null) {
                                                  matchingContacts = findContact(
                                                      firstName,
                                                      lastName,
                                                      aliasName,
                                                      extString0,
                                                      accountSegment,
                                                      pm
                                                  );
                                              }
                                              if (matchingContacts == null) {
                                                  // try again without aliasName
                                                  matchingContacts = findContact(
                                                      firstName,
                                                      lastName,
                                                      null,
                                                      extString0,
                                                      accountSegment,
                                                      pm
                                                  );
                                              }
                                              if (matchingContacts != null) {
                                                  // at least 1 match with existing contacts
                                                  updateExisting = true;
                                                  createNew = false;
                                                  for(Iterator c = matchingContacts.iterator(); c.hasNext(); ) {
                                                      org.opencrx.kernel.account1.jmi1.Contact matchingContact = (org.opencrx.kernel.account1.jmi1.Contact)c.next();
                                                      if (c.hasNext()) {
                                                          // more than 1 match
                                                          updateExisting = false;;
                                                          Action action = new Action(
                                                        	  SelectObjectAction.EVENT_ID,
                                                              new Action.Parameter[]{
                                                                  new Action.Parameter(Action.PARAMETER_OBJECTXRI, matchingContact.refMofId())
                                                              },
                                                              "",
                                                              true // enabled
                                                          );
                                                          accountHref = "../../" + action.getEncodedHRef();
                                                          multiMatchList += "<br><a href='" + accountHref + " target='_blank'><b>" + (new ObjectReference(matchingContact, app)).getTitle() + "</b> [" + matchingContact.refMofId() + "]</a>";
                                                      } else if (updateExisting) {
                                                          contactsUpdated += 1;
                                                          isUpdate = true;
                                                          contact = matchingContact;
                                                      }
                                                  }
                                              } else {
                                                  // no match with existing contacts
                                                  if (
                                                      // minimum requirements to create contact
                                                      ((firstName != null) || (lastName != null))
                                                  ) {
                                                      try {
                                                          pm.currentTransaction().begin();
                                                          contact = pm.newInstance(org.opencrx.kernel.account1.jmi1.Contact.class);
                                                          contact.refInitialize(false, false);
                                                          contact.setFirstName(firstName);
                                                          contact.setLastName(lastName);
                                                          contact.setExtString0(extString0);
                                                          accountSegment.addAccount(
                                                              false,
                                                              org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
                                                              contact
                                                          );
                                                          pm.currentTransaction().commit();
                                                      } catch (Exception e) {
                                                          new ServiceException(e).log();
                                                          contact = null;
                                                          try {
                                                              pm.currentTransaction().rollback();
                                                          } catch(Exception e1) {}
                                                      }
                                                  }
                                                  if (contact != null) {
                                                      contactsCreated += 1;
                                                      isCreation = true;
                                                  } else {
                                                      // creation failed
                                                      appendErrorRow = "<tr><td class='err' colspan='" + (maxCell+2) + "'>CREATION FAILED [<b>" + className + "</b>]</td></tr>";
                                                  }
                                              }

                                              if (contact != null) {
                                                  // update new or existing contact
                                                  Action action = new Action(
                                                	  SelectObjectAction.EVENT_ID,
                                                      new Action.Parameter[]{
                                                          new Action.Parameter(Action.PARAMETER_OBJECTXRI, contact.refMofId())
                                                      },
                                                      "",
                                                      true // enabled
                                                  );
                                                  accountHref = "../../" + action.getEncodedHRef();
                                                  account = (org.opencrx.kernel.account1.jmi1.Account)contact;
                                                  try {
                                                      pm.currentTransaction().begin();
                                                      for (
                                                          Iterator c = valueMap.keySet().iterator();
                                                          c.hasNext();
                                                      ) {
                                                          String key = (String)c.next(); // key is equal to name of attribute
                                                          cellId =  "r" + nRow + key.toUpperCase();

                                                          /*--------------------------------------------------------------*\
                                                          | BEGIN   M a p p i n g   C o n t a c t   t o   o p e n C R X    |
                                                          \---------------------------------------------------------------*/

                                                          boolean isOk = false;
                                                          boolean isNok = false;
                                                          try {
                                                              DataBinding_1_0 postalHomeDataBinding = new PostalAddressDataBinding("[isMain=(boolean)true];usage=(short)400?zeroAsNull=true");

                                                              if (key.equalsIgnoreCase(ATTR_TITLE)) {
                                                                  // salutationCode
                                                                  short salutationCode = codes.findCodeFromValue(
                                                                      (String)valueMap.get(key),
                                                                      FEATURE_SALUTATION_CODE
                                                                  );
                                                                  contact.setSalutationCode(salutationCode);
                                                                  if (salutationCode != 0) {
                                                                      isOk = true;
                                                                  } else {
                                                                      isNok = true;
                                                                  }
                                                                  if ((String)valueMap.get(key) != null && ((String)valueMap.get(key)).length() > 0) {
                                                                      contact.setSalutation((String)valueMap.get(key));
                                                                  }
                                                              } else if (key.equalsIgnoreCase(ATTR_ACADEMICTITLE)) {
                                                                  // academic Title (
                                                                  short academicTitle = codes.findCodeFromValue(
                                                                      (String)valueMap.get(key),
                                                                      FEATURE_ACADEMICTITLE
                                                                  );
                                                                  contact.setUserCode1(academicTitle);
                                                                  if (academicTitle != 0) {
                                                                          isOk = true;
                                                                  } else {
                                                                          isNok = true;
                                                                  }
                                                              } else if (key.equalsIgnoreCase(ATTR_FIRSTNAME)) {
                                                                  contact.setFirstName((String)valueMap.get(key)); isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_MIDDLENAME)) {
                                                                  contact.setMiddleName((String)valueMap.get(key)); isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_LASTNAME)) {
                                                                  contact.setLastName((String)valueMap.get(key)); isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_SUFFIX)) {
                                                                  contact.setSuffix((String)valueMap.get(key)); isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_ALIASNAME)) {
                                                                  contact.setAliasName((String)valueMap.get(key)); isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_NICKNAME)) {
                                                                  contact.setNickName((String)valueMap.get(key)); isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_COMPANY)) {
                                                                  String memberRole = null;
                                                                  if (valueMap.containsKey(ATTR_COMPANYROLE)) {
                                                                          memberRole = (String)valueMap.get(ATTR_COMPANYROLE);
                                                                  }
                                                                  org.opencrx.kernel.account1.jmi1.Account parentAccount = findUniqueTargetAccount((String)valueMap.get(key), accountSegment, pm);
                                                                  org.opencrx.kernel.account1.jmi1.Member member = createOrUpdateMember(
                                                                      parentAccount,
                                                                      account,
                                                                      memberRole,
                                                                      FEATURE_MEMBERROLE,
                                                                      codes,
                                                                      accountPkg,
                                                                      accountSegment,
                                                                      pm
                                                                  );
                                                                  if (member != null) {
                                                                      if (valueMap.containsKey(ATTR_JOBTITLE)) {
                                                                          member.setDescription((String)valueMap.get(ATTR_JOBTITLE));
                                                                      }
                                                                      isOk = true;
                                                                      if (memberRole != null) {
                                                                          jsBuffer += "$('r" + nRow +  ATTR_COMPANYROLE.toUpperCase() + "').className += ' ok';";
                                                                      }
                                                                      // add clickable links
                                                                      jsBuffer += "$('r" + nRow + ATTR_COMPANY.toUpperCase() + "').innerHTML += '<br>&lt;Parent: <a href=\""
                                                                        + getObjectHref(parentAccount) + "\" target=\"_blank\"><b>" + (new ObjectReference(parentAccount, app)).getTitle() + "</b></a>&gt;<br>&lt;Member: <a href=\""
                                                                        + getObjectHref(account) + "\" target=\"_blank\"><b>" + (new ObjectReference(account, app)).getTitle() + "</b></a>&gt;';";
                                                                      contact.setOrganization(parentAccount.getFullName()); isOk = true;
                                                                  } else {
                                                                      contact.setOrganization((String)valueMap.get(key)); isOk = true;
                                                                  }
                                                              } else if (key.equalsIgnoreCase(ATTR_DEPARTMENT)) {
                                                                  contact.setDepartment((String)valueMap.get(key)); isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_JOBTITLE)) {
                                                                  contact.setJobTitle((String)valueMap.get(key)); isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_BIRTHDAY)) {
                                                                  String value = (String)valueMap.get(key);
                                                                  if (!value.startsWith("00") && !value.startsWith("0.") && !value.startsWith("0-")) {
                                                                      java.util.Date birthdate = null;
                                                                      try {
                                                                          SimpleDateFormat sd = new SimpleDateFormat("MM/dd/yyyy");
                                                                          birthdate = sd.parse((String)valueMap.get(key));
                                                                      } catch (Exception e) {}
                                                                      if (birthdate == null) {
                                                                          try {
                                                                              SimpleDateFormat sd = new SimpleDateFormat("MM/dd/yy");
                                                                              birthdate = sd.parse((String)valueMap.get(key));
                                                                          } catch (Exception e) {}
                                                                      }
                                                                      if (birthdate == null) {
                                                                          try {
                                                                              SimpleDateFormat sd = new SimpleDateFormat("dd-MM-yyyy");
                                                                              birthdate = sd.parse((String)valueMap.get(key));
                                                                          } catch (Exception e) {}
                                                                      }
                                                                      if (birthdate == null) {
                                                                          try {
                                                                              SimpleDateFormat sd = new SimpleDateFormat("dd-MM-yy");
                                                                              birthdate = sd.parse((String)valueMap.get(key));
                                                                          } catch (Exception e) {}
                                                                      }
                                                                      if (birthdate != null) {
                                                                          contact.setBirthdate(birthdate); isOk = true;
                                                                      }
                                                                  }
                                                              } else if (key.equalsIgnoreCase(ATTR_HOMEPHONE)) {
                                                                  // Phone Home
                                                                  DataBinding_1_0 phoneHomeDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)400;automaticParsing=(boolean)true");
                                                                  phoneHomeDataBinding.setValue(
                                                                      contact,
                                                                      "org:opencrx:kernel:account1:Contact:address!phoneNumberFull",
                                                                      (String)valueMap.get(key)
                                                                  );
                                                                  isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_HOMEPHONE2)) {
                                                                  // Phone other
                                                                  DataBinding_1_0 phoneOtherDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)1800;automaticParsing=(boolean)true");
                                                                  phoneOtherDataBinding.setValue(
                                                                      contact,
                                                                      "org:opencrx:kernel:account1:Account:address*Other!phoneNumberFull",
                                                                      (String)valueMap.get(key)
                                                                  );
                                                                  isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_HOMEFAX)) {
                                                                  // Fax Home
                                                                  DataBinding_1_0 faxHomeDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)430;automaticParsing=(boolean)true");
                                                                  faxHomeDataBinding.setValue(
                                                                      contact,
                                                                      "org:opencrx:kernel:account1:Contact:address*Fax!phoneNumberFull",
                                                                      (String)valueMap.get(key)
                                                                  );
                                                                  isOk = true;
/*
                                                              } else if (key.equalsIgnoreCase("WebPage")) {
                                                                  // Web page
                                                                  org.openmdx.portal.servlet.databinding.CompositeObjectDataBinding webPageHomeDataBinding =
                                                                      new org.openmdx.portal.servlet.databinding.CompositeObjectDataBinding("type=org:opencrx:kernel:account1:WebAddress;disabled=(boolean)false;[isMain=(boolean)true];usage=(short)400");
                                                                  webPageHomeDataBinding.setValue(
                                                                      contact,
                                                                      "org:opencrx:kernel:account1:Contact:address!webUrl",
                                                                      (String)valueMap.get(key)
                                                                  );
                                                                  isOk = true;
*/
                                                              } else if (key.equalsIgnoreCase(ATTR_HOMEADDRESSLINE)) {
                                                                  // Postal Address Business / addressLine
                                                                  List<String> postalAddressLines = new ArrayList<String>();
                                                                  if (valueMap.get(key).toString() != null) {
                                                                      StringTokenizer tokenizer = new StringTokenizer(valueMap.get(key).toString(), "\r\n", false);
                                                                      while(tokenizer.hasMoreTokens()) {
                                                                          postalAddressLines.add(tokenizer.nextToken());
                                                                      }
                                                                      postalHomeDataBinding.setValue(
                                                                          contact,
                                                                          "org:opencrx:kernel:account1:Contact:address!postalAddressLine",
                                                                          postalAddressLines
                                                                      );
                                                                  }
                                                                  isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_HOMESTREET)) {
                                                                  // Postal Address Business / postalStreet
                                                                  List<String> postalStreetLines = new ArrayList<String>();
                                                                  if (valueMap.get(key).toString() != null) {
                                                                      StringTokenizer tokenizer = new StringTokenizer(valueMap.get(key).toString(), "\r\n", false);
                                                                      while(tokenizer.hasMoreTokens()) {
                                                                          postalStreetLines.add(tokenizer.nextToken());
                                                                      }
                                                                      postalHomeDataBinding.setValue(
                                                                          contact,
                                                                          "org:opencrx:kernel:account1:Contact:address!postalStreet",
                                                                          postalStreetLines
                                                                      );
                                                                  }
                                                                  isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_HOMECITY)) {
                                                                  // Postal Address Business / postalCity
                                                                  postalHomeDataBinding.setValue(
                                                                      contact,
                                                                      "org:opencrx:kernel:account1:Contact:address!postalCity",
                                                                      (String)valueMap.get(key)
                                                                  );
                                                                  isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_HOMEPOSTALCODE)) {
                                                                  // Postal Address Business / postalCode
                                                                  postalHomeDataBinding.setValue(
                                                                      contact,
                                                                      "org:opencrx:kernel:account1:Contact:address!postalCode",
                                                                      (String)valueMap.get(key)
                                                                  );
                                                                  isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_HOMESTATE)) {
                                                                  // Postal Address Business / postalState
                                                                  postalHomeDataBinding.setValue(
                                                                      contact,
                                                                      "org:opencrx:kernel:account1:Contact:address!postalState",
                                                                      (String)valueMap.get(key)
                                                                  );
                                                                  isOk = true;
                                                              } else if (key.equalsIgnoreCase(ATTR_HOMECOUNTRY) || key.equalsIgnoreCase(ATTR_HOMECOUNTRYREGION)) {
                                                                  // Postal Address Business / postalCountry
                                                                  short postalCountry = codes.findCodeFromValue(
                                                                      (String)valueMap.get(key),
                                                                      FEATURE_POSTALCOUNTRY_CODE
                                                                  );
                                                                  postalHomeDataBinding.setValue(
                                                                      contact,
                                                                      "org:opencrx:kernel:account1:Contact:address!postalCountry",
                                                                      postalCountry
                                                                  );
                                                                  if (postalCountry != 0) {
                                                                      isOk = true;
                                                                  } else {
                                                                      isNok = true;
                                                                  }
                                                              }
                                                          } catch (Exception e) {
                                                              new ServiceException(e).log();
                                                              isNok = true;
                                                          }
                                                          if (isOk) {
                                                              jsBuffer += "$('" + cellId + "').className += ' ok';";
                                                          }
                                                          if (isNok) {
                                                              jsBuffer += "$('" + cellId + "').className += ' nok';";
                                                          }
                                                          /*--------------------------------------------------------------*\
                                                          | END   M a p p i n g   C o n t a c t   t o   o p e n C R X      |
                                                          \---------------------------------------------------------------*/
                                                      }
                                                      pm.currentTransaction().commit();
                                                  } catch (Exception e) {
                                                      new ServiceException(e).log();
                                                      contact = null;
                                                      try {
                                                          pm.currentTransaction().rollback();
                                                      } catch(Exception e1) {}
                                                  }
                                              }
                                          } else if (
                                                  isDtypeGroup ||
                                                  isDtypeLegalEntity ||
                                                  isDtypeUnspecifiedAccount
                                          ) {
                                              org.opencrx.kernel.account1.jmi1.AbstractGroup abstractGroup = null;
                                              if (matchingAbstractGroups == null) {
                                                  matchingAbstractGroups = findAbstractGroup(
                                                      company,
                                                      aliasName,
                                                      extString0,
                                                      isDtypeGroup,
                                                      isDtypeLegalEntity,
                                                      isDtypeUnspecifiedAccount,
                                                      accountSegment,
                                                      pm
                                                  );
                                              }
                                              if (matchingAbstractGroups != null) {
                                                  // at least 1 match with existing AbstractGroups
                                                  updateExisting = true;
                                                  createNew = false;
                                                  for(Iterator c = matchingAbstractGroups.iterator(); c.hasNext(); ) {
                                                      org.opencrx.kernel.account1.jmi1.AbstractGroup matchingAbstractGroup = (org.opencrx.kernel.account1.jmi1.AbstractGroup)c.next();
                                                      if (c.hasNext()) {
                                                          // more than 1 match
                                                          updateExisting = false;;
                                                          Action action = new Action(
                                                        	  SelectObjectAction.EVENT_ID,
                                                              new Action.Parameter[]{
                                                                  new Action.Parameter(Action.PARAMETER_OBJECTXRI, matchingAbstractGroup.refMofId())
                                                              },
                                                              "",
                                                              true // enabled
                                                          );
                                                          accountHref = "../../" + action.getEncodedHRef();
                                                          multiMatchList += "<br><a href='" + accountHref + " target='_blank'><b>" + (new ObjectReference(matchingAbstractGroup, app)).getTitle() + "</b> [" + matchingAbstractGroup.refMofId() + "]</a>";
                                                    } else if (updateExisting) {
                                                          isUpdate = true;
                                                          if (isDtypeGroup) {
                                                              groupsUpdated += 1;
                                                              group = (org.opencrx.kernel.account1.jmi1.Group)matchingAbstractGroup;
                                                              abstractGroup = matchingAbstractGroup;
                                                          } else if (isDtypeLegalEntity) {
                                                              legalEntitiesUpdated += 1;
                                                              legalEntity = (org.opencrx.kernel.account1.jmi1.LegalEntity)matchingAbstractGroup;
                                                              abstractGroup = matchingAbstractGroup;
                                                          } else if (isDtypeUnspecifiedAccount) {
                                                              unspecifiedAccountsUpdated += 1;
                                                              unspecifiedAccount = (org.opencrx.kernel.account1.jmi1.UnspecifiedAccount)matchingAbstractGroup;
                                                              abstractGroup = matchingAbstractGroup;
                                                          }
                                                      }
                                                  }
                                              } else {
                                                  // no match with existing AbstractGroups
                                                  if (
                                                      // minimum requirements to create AbstractGroup
                                                      (company != null)
                                                  ) {
                                                      try {
                                                          pm.currentTransaction().begin();
                                                          if (isDtypeGroup) {
                                                              group = pm.newInstance(org.opencrx.kernel.account1.jmi1.Group.class);
                                                              group.refInitialize(false, false);
                                                              group.setName(company);
                                                              group.setExtString0(extString0);
                                                              accountSegment.addAccount(
                                                                  false,
                                                                  org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
                                                                  group
                                                              );
                                                          } else if (isDtypeLegalEntity) {
                                                              legalEntity = pm.newInstance(org.opencrx.kernel.account1.jmi1.LegalEntity.class);
                                                              legalEntity.refInitialize(false, false);
                                                              legalEntity.setName(company);
                                                              legalEntity.setExtString0(extString0);
                                                              accountSegment.addAccount(
                                                                  false,
                                                                  org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
                                                                  legalEntity
                                                              );
                                                          } else if (isDtypeUnspecifiedAccount) {
                                                              unspecifiedAccount = pm.newInstance(org.opencrx.kernel.account1.jmi1.UnspecifiedAccount.class);
                                                              unspecifiedAccount.refInitialize(false, false);
                                                              unspecifiedAccount.setName(company);
                                                              unspecifiedAccount.setExtString0(extString0);
                                                              accountSegment.addAccount(
                                                                  false,
                                                                  org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
                                                                  unspecifiedAccount
                                                              );
                                                          }
                                                          pm.currentTransaction().commit();
                                                      } catch (Exception e) {
                                                          new ServiceException(e).log();
                                                          contact = null;
                                                          try {
                                                              pm.currentTransaction().rollback();
                                                          } catch(Exception e1) {}
                                                      }
                                                  }

                                                  if (isDtypeGroup && group != null) {
                                                      groupsCreated += 1;
                                                      isCreation = true;
                                                      abstractGroup = (org.opencrx.kernel.account1.jmi1.AbstractGroup)group;
                                                  } else if (isDtypeLegalEntity && legalEntity != null) {
                                                      legalEntitiesCreated += 1;
                                                      isCreation = true;
                                                      abstractGroup = (org.opencrx.kernel.account1.jmi1.AbstractGroup)legalEntity;
                                                  } else if (isDtypeUnspecifiedAccount && unspecifiedAccount != null) {
                                                      unspecifiedAccountsCreated += 1;
                                                      isCreation = true;
                                                      abstractGroup = (org.opencrx.kernel.account1.jmi1.AbstractGroup)unspecifiedAccount;
                                                  } else {
                                                      // creation failed
                                                      appendErrorRow = "<tr><td class='err' colspan='" + (maxCell+2) + "'>CREATION FAILED [<b>" + className + "</b>]</td></tr>";
                                                  }
                                              }

                                              if (abstractGroup != null) {
                                                  // update new or existing abstractGroup
                                                  Action action = new Action(
                                                	  SelectObjectAction.EVENT_ID,
                                                      new Action.Parameter[]{
                                                          new Action.Parameter(Action.PARAMETER_OBJECTXRI, abstractGroup.refMofId())
                                                      },
                                                      "",
                                                      true // enabled
                                                  );
                                                  accountHref = "../../" + action.getEncodedHRef();
                                                  account = (org.opencrx.kernel.account1.jmi1.Account)abstractGroup;
                                                  try {
                                                      pm.currentTransaction().begin();
                                                      for (
                                                          Iterator c = valueMap.keySet().iterator();
                                                          c.hasNext();
                                                      ) {
                                                          String key = (String)c.next(); // key is equal to name of attribute
                                                          cellId =  "r" + nRow + key.toUpperCase();

                                                          boolean isOk = false;
                                                          try {
                                                              if (isDtypeGroup) {
                                                                  /*----------------------------------------------------------*\
                                                                  | BEGIN   M a p p i n g   G r o u p   t o   o p e n C R X    |
                                                                  \-----------------------------------------------------------*/
                                                                  if (key.equalsIgnoreCase(ATTR_COMPANY)) {
                                                                      group.setName((String)valueMap.get(key)); isOk = true;
                                                                  }
                                                                  /*----------------------------------------------------------*\
                                                                  | END     M a p p i n g   G r o u p   t o   o p e n C R X    |
                                                                  \-----------------------------------------------------------*/
                                                              } else if (isDtypeLegalEntity) {
                                                                  /*----------------------------------------------------------------------*\
                                                                  | BEGIN   M a p p i n g   L e g a l E n t i t y   t o   o p e n C R X    |
                                                                  \-----------------------------------------------------------------------*/
                                                                  if (key.equalsIgnoreCase(ATTR_COMPANY)) {
                                                                      legalEntity.setName((String)valueMap.get(key)); isOk = true;
                                                                  }
                                                                  /*----------------------------------------------------------------------*\
                                                                  | END     M a p p i n g   L e g a l E n t i t y   t o   o p e n C R X    |
                                                                  \-----------------------------------------------------------------------*/
                                                              } else if (isDtypeUnspecifiedAccount) {
                                                                  /*------------------------------------------------------------------------------------*\
                                                                  | BEGIN   M a p p i n g   U n s p e c i f i e d A c c o u n t   t o   o p e n C R X    |
                                                                  \-------------------------------------------------------------------------------------*/
                                                                  if (key.equalsIgnoreCase(ATTR_COMPANY)) {
                                                                      unspecifiedAccount.setName((String)valueMap.get(key)); isOk = true;
                                                                  }
                                                                  /*------------------------------------------------------------------------------------*\
                                                                  | END     M a p p i n g   U n s p e c i f i e d A c c o u n t   t o   o p e n C R X    |
                                                                  \-------------------------------------------------------------------------------------*/
                                                              }
                                                          } catch (Exception e) {
                                                              jsBuffer += "$('" + cellId + "').className += ' nok';";
                                                          }
                                                          if (isOk) {
                                                              jsBuffer += "$('" + cellId + "').className += ' ok';";
                                                          }
                                                      }
                                                      pm.currentTransaction().commit();
                                                  } catch (Exception e) {
                                                      new ServiceException(e).log();
                                                      try {
                                                          pm.currentTransaction().rollback();
                                                      } catch(Exception e1) {}
                                                      abstractGroup = null;
                                                      group = null;
                                                      legalEntity = null;
                                                      unspecifiedAccount = null;
                                                  }
                                              }
                                          }

                                          boolean isOk = false;
                                          boolean isNok = false;

                                          if (account != null) {
                                              // update attributes common to all subclasses of Account
                                              try {
                                                  pm.currentTransaction().begin();
                                                  for (
                                                      Iterator c = valueMap.keySet().iterator();
                                                      c.hasNext();
                                                  ) {
                                                      String key = (String)c.next(); // key is equal to name of attribute
                                                      cellId =  "r" + nRow + key.toUpperCase();

                                                      /*--------------------------------------------------------------*\
                                                      | BEGIN   M a p p i n g   A c c o u n t   t o   o p e n C R X    |
                                                      \---------------------------------------------------------------*/

                                                      isOk = false;
                                                      isNok = false;
                                                      try {
                                                          DataBinding_1_0 postalBusinessDataBinding = new PostalAddressDataBinding("[isMain=(boolean)true];usage=(short)500?zeroAsNull=true");

                                                          if (key.equalsIgnoreCase(ATTR_XRI)) {
                                                              // set isOk to true
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_EXTSTRING0)) {
                                                              // verify, but do NOT set extString0 (may only be set during creation of new contact!!!)
                                                              isOk = (valueMap.get(key) != null) && (account.getExtString0() != null) && (valueMap.get(key).toString().compareTo(account.getExtString0()) == 0);
                                                          } else if (key.equalsIgnoreCase(ATTR_BUSINESSTYPE)) {
                                                              // businessType
                                                              List<Short> businessTypes = new ArrayList<Short>();
                                                              if (valueMap.get(key).toString() != null) {
                                                                  StringTokenizer tokenizer = new StringTokenizer(valueMap.get(key).toString(), "\r\n", false);
                                                                  while(tokenizer.hasMoreTokens()) {
                                                                      businessTypes.add(Short.parseShort(tokenizer.nextToken()));
                                                                  }
                                                                  account.setBusinessType(businessTypes);
                                                              }
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_NOTES)) {
                                                              // description
                                                              account.setDescription((String)valueMap.get(key));
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_BUSINESSPHONE)) {
                                                              // Phone Business
                                                              DataBinding_1_0 phoneBusinessDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)500;automaticParsing=(boolean)true");
                                                              phoneBusinessDataBinding.setValue(
                                                                  account,
                                                                  "org:opencrx:kernel:account1:Account:address*Business!phoneNumberFull",
                                                                  (String)valueMap.get(key)
                                                              );
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_BUSINESSPHONE2)) {
                                                              // Phone other
                                                              DataBinding_1_0 phoneOtherDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)1800;automaticParsing=(boolean)true");
                                                              phoneOtherDataBinding.setValue(
                                                                  account,
                                                                  "org:opencrx:kernel:account1:Account:address*Other!phoneNumberFull",
                                                                  (String)valueMap.get(key)
                                                              );
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_BUSINESSFAX)) {
                                                              // Fax Business
                                                              DataBinding_1_0 faxBusinessDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)530;automaticParsing=(boolean)true");
                                                              faxBusinessDataBinding.setValue(
                                                                  account,
                                                                  "org:opencrx:kernel:account1:Account:address*BusinessFax!phoneNumberFull",
                                                                  (String)valueMap.get(key)
                                                              );
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_MOBILEPHONE)) {
                                                              // Phone Mobile
                                                              DataBinding_1_0 phoneMobileDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)200;automaticParsing=(boolean)true");
                                                              phoneMobileDataBinding.setValue(
                                                                  account,
                                                                  "org:opencrx:kernel:account1:Account:address*Mobile!phoneNumberFull",
                                                                  (String)valueMap.get(key)
                                                              );
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_EMAILADDRESS)) {
                                                              // Mail Business
                                                              DataBinding_1_0 mailBusinessDataBinding = new EmailAddressDataBinding("[isMain=(boolean)true];usage=(short)500;[emailType=(short)1]");
                                                              mailBusinessDataBinding.setValue(
                                                                  account,
                                                                  "org:opencrx:kernel:account1:Account:address*Business!emailAddress",
                                                                  (String)valueMap.get(key)
                                                              );
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_EMAIL2ADDRESS)) {
                                                              // Mail Home
                                                              DataBinding_1_0 mailHomeDataBinding = new EmailAddressDataBinding("[isMain=(boolean)true];usage=(short)400;[emailType=(short)1]");
                                                              mailHomeDataBinding.setValue(
                                                                  account,
                                                                  "org:opencrx:kernel:account1:Contact:address!emailAddress",
                                                                  (String)valueMap.get(key)
                                                              );
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_EMAIL3ADDRESS)) {
                                                              // Mail Other
                                                              DataBinding_1_0 mailOtherDataBinding = new EmailAddressDataBinding("[isMain=(boolean)true];usage=(short)1800;[emailType=(short)1]");
                                                              mailOtherDataBinding.setValue(
                                                                  account,
                                                                  "org:opencrx:kernel:account1:Account:address*Other!emailAddress",
                                                                  (String)valueMap.get(key)
                                                              );
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_WEBPAGE)) {
                                                              // Web page
                                                              org.openmdx.portal.servlet.databinding.CompositeObjectDataBinding webPageBusinessDataBinding =
                                                                  new org.openmdx.portal.servlet.databinding.CompositeObjectDataBinding("type=org:opencrx:kernel:account1:WebAddress;disabled=(boolean)false;[isMain=(boolean)true];usage=(short)500");
                                                              webPageBusinessDataBinding.setValue(
                                                                  account,
                                                                  "org:opencrx:kernel:account1:LegalEntity:address!webUrl",
                                                                  (String)valueMap.get(key)
                                                              );
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_BUSINESSADDRESSLINE)) {
                                                              // Postal Address Business / addressLine
                                                              List<String> postalAddressLines = new ArrayList<String>();
                                                              if (valueMap.get(key).toString() != null) {
                                                                  StringTokenizer tokenizer = new StringTokenizer(valueMap.get(key).toString(), "\r\n", false);
                                                                  while(tokenizer.hasMoreTokens()) {
                                                                      postalAddressLines.add(tokenizer.nextToken());
                                                                  }
                                                                  postalBusinessDataBinding.setValue(
                                                                      account,
                                                                      "org:opencrx:kernel:account1:Account:address*Business!postalAddressLine",
                                                                      postalAddressLines
                                                                  );
                                                              }
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_BUSINESSSTREET)) {
                                                              // Postal Address Business / postalStreet
                                                              List<String> postalStreetLines = new ArrayList<String>();
                                                              if (valueMap.get(key).toString() != null) {
                                                                  StringTokenizer tokenizer = new StringTokenizer(valueMap.get(key).toString(), "\r\n", false);
                                                                  while(tokenizer.hasMoreTokens()) {
                                                                      postalStreetLines.add(tokenizer.nextToken());
                                                                  }
                                                                  postalBusinessDataBinding.setValue(
                                                                      account,
                                                                      "org:opencrx:kernel:account1:Account:address*Business!postalStreet",
                                                                      postalStreetLines
                                                                  );
                                                              }
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_BUSINESSCITY)) {
                                                              // Postal Address Business / postalCity
                                                              postalBusinessDataBinding.setValue(
                                                                      account,
                                                                  "org:opencrx:kernel:account1:Account:address*Business!postalCity",
                                                                  (String)valueMap.get(key)
                                                              );
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_BUSINESSPOSTALCODE)) {
                                                              // Postal Address Business / postalCode
                                                              postalBusinessDataBinding.setValue(
                                                                  account,
                                                                  "org:opencrx:kernel:account1:Account:address*Business!postalCode",
                                                                  (String)valueMap.get(key)
                                                              );
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_BUSINESSSTATE)) {
                                                              // Postal Address Business / postalState
                                                              postalBusinessDataBinding.setValue(
                                                                      account,
                                                                  "org:opencrx:kernel:account1:Account:address*Business!postalState",
                                                                  (String)valueMap.get(key)
                                                              );
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_BUSINESSCOUNTRY) || key.equalsIgnoreCase(ATTR_BUSINESSCOUNTRYREGION)) {
                                                              // Postal Address Business / postalCountry
                                                              short postalCountry = codes.findCodeFromValue(
                                                                  (String)valueMap.get(key),
                                                                  FEATURE_POSTALCOUNTRY_CODE
                                                              );
                                                              postalBusinessDataBinding.setValue(
                                                                  account,
                                                                  "org:opencrx:kernel:account1:Account:address*Business!postalCountry",
                                                                  postalCountry
                                                              );
                                                              if (postalCountry != 0) {
                                                                  isOk = true;
                                                              } else {
                                                                  isNok = true;
                                                              }
                                                          } else if (key.equalsIgnoreCase(ATTR_ASSISTANTSNAME)) {
                                                              String memberRole = null;
                                                              if (valueMap.containsKey(ATTR_ASSISTANTSNAMEROLE)) {
                                                                  memberRole = (String)valueMap.get(ATTR_ASSISTANTSNAMEROLE);
                                                              }
                                                              org.opencrx.kernel.account1.jmi1.Account parentAccount = findUniqueTargetAccount((String)valueMap.get(key), accountSegment, pm);
                                                              org.opencrx.kernel.account1.jmi1.Member member = createOrUpdateMember(
                                                                  parentAccount,
                                                                  account,
                                                                  memberRole,
                                                                  FEATURE_MEMBERROLE,
                                                                  codes,
                                                                  accountPkg,
                                                                  accountSegment,
                                                                  pm
                                                              );
                                                              if (member != null) {
                                                                  isOk = true;
                                                                  if (memberRole != null) {
                                                                      jsBuffer += "$('r" + nRow +  ATTR_ASSISTANTSNAMEROLE.toUpperCase() + "').className += ' ok';";
                                                                  }
                                                                  // add clickable links
                                                                  jsBuffer += "$('r" + nRow + ATTR_ASSISTANTSNAME.toUpperCase() + "').innerHTML += '<br>&lt;Parent: <a href=\""
                                                                    + getObjectHref(parentAccount) + "\" target=\"_blank\"><b>" + (new ObjectReference(parentAccount, app)).getTitle() + "</b></a>&gt;<br>&lt;Member: <a href=\""
                                                                    + getObjectHref(account) + "\" target=\"_blank\"><b>" + (new ObjectReference(account, app)).getTitle() + "</b></a>&gt;';";
                                                              }
                                                          } else if (key.equalsIgnoreCase(ATTR_MANAGERSNAME)) {
                                                              String memberRole = null;
                                                              if (valueMap.containsKey(ATTR_MANAGERSROLE)) {
                                                                      memberRole = (String)valueMap.get(ATTR_MANAGERSROLE);
                                                              }
                                                              org.opencrx.kernel.account1.jmi1.Account manager = findUniqueTargetAccount((String)valueMap.get(key), accountSegment, pm);
                                                              org.opencrx.kernel.account1.jmi1.Member member = createOrUpdateMember(
                                                                  account,
                                                                  manager,
                                                                  memberRole,
                                                                  FEATURE_MEMBERROLE,
                                                                  codes,
                                                                  accountPkg,
                                                                  accountSegment,
                                                                  pm
                                                              );
                                                              if (member != null) {
                                                                  isOk = true;
                                                                  if (memberRole != null) {
                                                                      jsBuffer += "$('r" + nRow +  ATTR_MANAGERSROLE.toUpperCase() + "').className += ' ok';";
                                                                  }
                                                                  // add clickable links
                                                                  jsBuffer += "$('r" + nRow + ATTR_MANAGERSNAME.toUpperCase() + "').innerHTML += '<br>&lt;Parent: <a href=\""
                                                                    + getObjectHref(account) + "\" target=\"_blank\"><b>" + (new ObjectReference(account, app)).getTitle() + "</b></a>&gt;<br>&lt;Member: <a href=\""
                                                                    + getObjectHref(manager) + "\" target=\"_blank\"><b>" + (new ObjectReference(manager, app)).getTitle() + "</b></a>&gt;';";
                                                              }
                                                          } else if (key.equalsIgnoreCase(ATTR_CATEGORIES)) {
                                                              // semicolon-separated categories
                                                              if (valueMap.get(key).toString() != null) {
                                                                  StringTokenizer tokenizer = new StringTokenizer(valueMap.get(key).toString(), ";", false);
                                                                  while(tokenizer.hasMoreTokens()) {
                                                                      String category = (String)tokenizer.nextToken();
                                                                      if (!account.getCategory().contains(category)) {
                                                                          account.getCategory().add(category);
                                                                      }
                                                                  }
                                                              }
                                                              isOk = true;
                                                          } else if (key.equalsIgnoreCase(ATTR_MEMBEROF)) {
                                                              // businessType
                                                              String memberRoles = null;
                                                              if (valueMap.containsKey(ATTR_MEMBERROLE)) {
                                                                  memberRoles = (String)valueMap.get(ATTR_MEMBERROLE);
                                                              }
                                                              org.opencrx.kernel.account1.jmi1.Account parentAccount = findUniqueTargetAccount((String)valueMap.get(key), accountSegment, pm);
                                                              org.opencrx.kernel.account1.jmi1.Member member = createOrUpdateMember(
                                                                  parentAccount,
                                                                  account,
                                                                  memberRoles,
                                                                  FEATURE_MEMBERROLE,
                                                                  codes,
                                                                  accountPkg,
                                                                  accountSegment,
                                                                  pm
                                                              );
                                                              if (member != null) {
                                                                  if (valueMap.containsKey(ATTR_MEMBERROLE)) {
                                                                      member.setDescription((String)valueMap.get(ATTR_MEMBERROLE));
                                                                  }
                                                                  isOk = true;
                                                                  if (memberRoles != null) {
                                                                      jsBuffer += "$('r" + nRow +  ATTR_MEMBERROLE.toUpperCase() + "').className += ' ok';";
                                                                  }
                                                                  // add clickable links
                                                                  jsBuffer += "$('r" + nRow + ATTR_MEMBEROF.toUpperCase() + "').innerHTML += '<br>&lt;Parent: <a href=\""
                                                                    + getObjectHref(parentAccount) + "\" target=\"_blank\"><b>" + (new ObjectReference(parentAccount, app)).getTitle() + "</b></a>&gt;<br>&lt;Member: <a href=\""
                                                                    + getObjectHref(account) + "\" target=\"_blank\"><b>" + (new ObjectReference(account, app)).getTitle() + "</b></a>&gt;';";
                                                              }
                                                          } else if (key.equalsIgnoreCase(ATTR_NOTETITLE)) {
                                                              // note
                                                              String noteTitle = (String)valueMap.get(key);
                                                              String noteText = null;
                                                              if (valueMap.containsKey(ATTR_NOTETEXT)) {
                                                                  noteText = (String)valueMap.get(ATTR_NOTETEXT);
                                                              }
                                                              org.opencrx.kernel.generic.jmi1.Note note = createOrUpdateNote(
                                                                  account,
                                                                  noteTitle,
                                                                  noteText,
                                                                  genericPkg,
                                                                  pm
                                                              );
                                                              isOk = note != null;
                                                              if (isOk && noteText != null) {
                                                                  jsBuffer += "$('r" + nRow +  ATTR_NOTETEXT.toUpperCase() + "').className += ' ok';";
                                                              }
                                                          } else if (!(explicitlyMappedAttributes.contains(key.toUpperCase()))) {
                                                              // try to set attribute with reflective coding
                                                              try {
                                                                  org.openmdx.base.mof.cci.Model_1_0 model = org.openmdx.base.mof.spi.Model_1Factory.getModel();
                                                                  Map features = null;
                                                                  if (isDtypeContact) {
                                                                      features = (Map)model.getElement(contact.refClass().refMofId()).objGetValue("allFeature");
                                                                  } else if (isDtypeGroup) {
                                                                      features = (Map)model.getElement(group.refClass().refMofId()).objGetValue("allFeature");
                                                                  } else if (isDtypeLegalEntity) {
                                                                      features = (Map)model.getElement(legalEntity.refClass().refMofId()).objGetValue("allFeature");
                                                                  } else if (isDtypeUnspecifiedAccount) {
                                                                      features = (Map)model.getElement(unspecifiedAccount.refClass().refMofId()).objGetValue("allFeature");
                                                                  }
                                                                  org.openmdx.base.mof.cci.ModelElement_1_0 featureDef = (features == null ? null : (org.openmdx.base.mof.cci.ModelElement_1_0)features.get(key));
                                                                  if (featureDef != null) {
                                                                      if(
                                                                          org.openmdx.base.mof.cci.PrimitiveTypes.STRING.equals(model.getElementType(featureDef).objGetValue("qualifiedName")) &&
                                                                          (
                                                                              org.openmdx.base.mof.cci.Multiplicities.SINGLE_VALUE.equals(featureDef.objGetValue("multiplicity")) ||
                                                                              org.openmdx.base.mof.cci.Multiplicities.OPTIONAL_VALUE.equals(featureDef.objGetValue("multiplicity"))
                                                                          )
                                                                      ) {
                                                                          // optional, single-valued String
                                                                          if (isDtypeContact) {
                                                                              contact.refSetValue(key, valueMap.get(key).toString());
                                                                          } else if (isDtypeGroup) {
                                                                              group.refSetValue(key, valueMap.get(key).toString());
                                                                          } else if (isDtypeLegalEntity) {
                                                                              legalEntity.refSetValue(key, valueMap.get(key).toString());
                                                                          } else if (isDtypeUnspecifiedAccount) {
                                                                              unspecifiedAccount.refSetValue(key, valueMap.get(key).toString());
                                                                          }
                                                                          isOk = true;
                                                                      }
                                                                      if(
                                                                          org.openmdx.base.mof.cci.PrimitiveTypes.SHORT.equals(model.getElementType(featureDef).objGetValue("qualifiedName")) &&
                                                                          (
                                                                              org.openmdx.base.mof.cci.Multiplicities.SINGLE_VALUE.equals(featureDef.objGetValue("multiplicity")) ||
                                                                              org.openmdx.base.mof.cci.Multiplicities.OPTIONAL_VALUE.equals(featureDef.objGetValue("multiplicity"))
                                                                          )
                                                                      ) {
                                                                          // optional, single-valued Short
                                                                          if (isDtypeContact) {
                                                                              contact.refSetValue(key, Short.parseShort(valueMap.get(key).toString()));
                                                                          } else if (isDtypeGroup) {
                                                                              group.refSetValue(key, Short.parseShort(valueMap.get(key).toString()));
                                                                          } else if (isDtypeLegalEntity) {
                                                                              legalEntity.refSetValue(key, Short.parseShort(valueMap.get(key).toString()));
                                                                          } else if (isDtypeUnspecifiedAccount) {
                                                                              unspecifiedAccount.refSetValue(key, Short.parseShort(valueMap.get(key).toString()));
                                                                          }
                                                                          isOk = true;
                                                                      }
                                                                      if(
                                                                          org.openmdx.base.mof.cci.PrimitiveTypes.BOOLEAN.equals(model.getElementType(featureDef).objGetValue("qualifiedName")) &&
                                                                          (
                                                                              org.openmdx.base.mof.cci.Multiplicities.SINGLE_VALUE.equals(featureDef.objGetValue("multiplicity")) ||
                                                                              org.openmdx.base.mof.cci.Multiplicities.OPTIONAL_VALUE.equals(featureDef.objGetValue("multiplicity"))
                                                                          )
                                                                      ) {
                                                                          // optional, single-valued Boolean
                                                                          if (isDtypeContact) {
                                                                              contact.refSetValue(key, Boolean.valueOf(valueMap.get(key).toString()));
                                                                          } else if (isDtypeGroup) {
                                                                              group.refSetValue(key, Boolean.valueOf(valueMap.get(key).toString()));
                                                                          } else if (isDtypeLegalEntity) {
                                                                              legalEntity.refSetValue(key, Boolean.valueOf(valueMap.get(key).toString()));
                                                                          } else if (isDtypeUnspecifiedAccount) {
                                                                              unspecifiedAccount.refSetValue(key, Boolean.valueOf(valueMap.get(key).toString()));
                                                                          }
                                                                          isOk = true;
                                                                      }
                                                                      if(
                                                                          org.openmdx.base.mof.cci.PrimitiveTypes.DECIMAL.equals(model.getElementType(featureDef).objGetValue("qualifiedName")) &&
                                                                          (
                                                                              org.openmdx.base.mof.cci.Multiplicities.SINGLE_VALUE.equals(featureDef.objGetValue("multiplicity")) ||
                                                                              org.openmdx.base.mof.cci.Multiplicities.OPTIONAL_VALUE.equals(featureDef.objGetValue("multiplicity"))
                                                                          )
                                                                      ) {
                                                                          // optional, single-valued BigDecimal
                                                                          if (isDtypeContact) {
                                                                              contact.refSetValue(key, new BigDecimal(valueMap.get(key).toString()));
                                                                          } else if (isDtypeGroup) {
                                                                              group.refSetValue(key, new BigDecimal(valueMap.get(key).toString()));
                                                                          } else if (isDtypeLegalEntity) {
                                                                              legalEntity.refSetValue(key, new BigDecimal(valueMap.get(key).toString()));
                                                                          } else if (isDtypeUnspecifiedAccount) {
                                                                              unspecifiedAccount.refSetValue(key, new BigDecimal(valueMap.get(key).toString()));
                                                                          }
                                                                          isOk = true;
                                                                      }
                                                                  }
                                                              } catch (Exception e) {
                                                                  new ServiceException(e).log();
                                                              }
                                                          }
                                                      } catch (Exception e) {
                                                          new ServiceException(e).log();
                                                          isNok = true;
                                                      }
                                                      /*--------------------------------------------------------------*\
                                                      | END   M a p p i n g   A c c o u n t   t o   o p e n C R X      |
                                                      \---------------------------------------------------------------*/
                                                      if (isOk) {
                                                          jsBuffer += "$('" + cellId + "').className += ' ok';";
                                                      }
                                                      if (isNok) {
                                                          jsBuffer += "$('" + cellId + "').className += ' nok';";
                                                      }
                                                  }
                                                  pm.currentTransaction().commit();
                                              } catch (Exception e) {
                                                  new ServiceException(e).log();
                                                  isOk = false;
                                                  isNok = true;
                                                  contact = null;
                                                  try {
                                                      pm.currentTransaction().rollback();
                                                  } catch(Exception e1) {}
                                              }
                                          }
%>
                                      </tr>
<%
                                      if (appendErrorRow != null) {
%>
                                          <%= appendErrorRow %>
<%
                                      }
                                      valueMap = null;
                                      if (isCreation) {
%>
                                          <tr>
                                              <td class="<%= isNok ? "err" : "match" %>" colspan="<%= maxCell+2 %>">
                                                  CREATE <%= isNok ? "FAILED" : "OK" %> [<b><%= className %></b>]: <a href="<%= accountHref %>" target="_blank"><b><%=  (new ObjectReference(account, app)).getTitle() %></b> [<%= account.refMofId() %>]</a>
                                                  <%= jsBuffer.length() > 0 ? "<script language='javascript' type='text/javascript'>" + jsBuffer + "</script>" : "" %>
                                              </td>
                                          </tr>
<%
                                      }
                                      if (isUpdate) {
                                          if (multiMatchList.length() > 0) {
%>
                                              <tr>
                                                  <td class="err" colspan="<%= maxCell+2 %>">
                                                      NO UPDATE [<b><%= className %></b>] - Multiple Matches:<%= multiMatchList %>
                                                  </td>
                                              </tr>
<%
                                          } else {
%>
                                              <tr>
                                                  <td class="<%= isNok ? "err" : "match" %>" colspan="<%= maxCell+2 %>">
                                                      UPDATE <%= isNok ? "FAILED" : "OK" %> [<b><%= className %></b>]: <a href="<%= accountHref %>" target="_blank"><b><%=  (new ObjectReference(account, app)).getTitle() %></b> [<%= account.refMofId() %>]</a>
                                                      <%= jsBuffer.length() > 0 ? "<script language='javascript' type='text/javascript'>" + jsBuffer + "</script>" : "" %>
                                                  </td>
                                              </tr>
<%
                                          }
                                      }
                                  } /* while */
%>
                                  <tr class="sheetInfo">
                                      <td colspan="<%= maxCell+2 %>">
                                          Sheet: <b><%= sheet.getSheetName() %></b> |
                                          data lines <b>read: <%= linesRead %></b><br>
                                      </td>
                                  </tr>
                                  <tr class="importHeader">
                                      <td><%= ATTR_DTYPE %></td>
                                      <td>created</td>
                                      <td colspan="<%= maxCell %>">updated</td>
                                  </tr>
                                  <tr>
                                      <td><%= DTYPE_CONTACT %></td>
                                      <td><%= contactsCreated %></td>
                                      <td colspan="<%= maxCell %>"><%= contactsUpdated %></td>
                                  </tr>
                                  <tr>
                                      <td><%= DTYPE_GROUP %></td>
                                      <td><%= groupsCreated %></td>
                                      <td colspan="<%= maxCell %>"><%= groupsUpdated %></td>
                                  </tr>
                                  <tr>
                                      <td><%= DTYPE_LEGALENTITY %></td>
                                      <td><%= legalEntitiesCreated %></td>
                                      <td colspan="<%= maxCell %>"><%= legalEntitiesUpdated %></td>
                                  </tr>
                                  <tr>
                                      <td><%= DTYPE_UNSPECIFIEDACCOUNT %></td>
                                      <td><%= unspecifiedAccountsCreated %></td>
                                      <td colspan="<%= maxCell %>"><%= unspecifiedAccountsUpdated %></td>
                                  </tr>
<%
                                  if (linesRead != contactsCreated + contactsUpdated +
                                     groupsCreated + groupsUpdated +
                                     legalEntitiesCreated + legalEntitiesUpdated +
                                     unspecifiedAccountsCreated + unspecifiedAccountsUpdated
                                  ) {
%>
                                    <tr>
                                        <td class="err" colspan="<%= maxCell+2 %>">WARNING: some data lines were not processed due to data errors (e.g. multiple matches, missing first/last name, etc.)</td>
                                    </tr>
<%
                                  }
%>
                                  </table>
<%
                              } /* for */
%>
                              <hr>
<%
                          } catch (Exception e) {
                              ServiceException e0 = new ServiceException(e);
                              e0.log();
                              out.println("<div style='color:red;padding:5px;margin:10px;'><b><u>Warning:</u> Error reading/processing Excel file!<br><br>The following exception(s) occured:</b><br><br><pre>");
                              PrintWriter pw = new PrintWriter(out);
                              e0.printStackTrace(pw);
                              out.println("</pre></div>");
                          }
                      }
                      new File(location).delete();

                      // Go back to previous view
                      Action nextAction =
                        new Action(
                          SelectObjectAction.EVENT_ID,
                          new Action.Parameter[]{
                            new Action.Parameter(Action.PARAMETER_OBJECTXRI, objectXri)
                            },
                          "", true
                        );
%>
                      <br />
                      <br />
                      <INPUT type="Submit" name="Cancel.Button" tabindex="1" value="Continue" onClick="javascript:location='<%= request.getContextPath() + "/" + nextAction.getEncodedHRef() %>';" />
                      <br />
                      <br />
<%
                  }
                  catch(Exception e) {
                      new ServiceException(e).log();
                  }
              }
          }
          else {

          }
      }
      else {
          File uploadFile = new File(location);
          System.out.println("Import: file " + location + " either does not exist or has size 0: exists=" + uploadFile.exists() + "; length=" + uploadFile.length());
      }
      if (!continueToExit) {
%>
<form name="UploadMedia" enctype="multipart/form-data" accept-charset="UTF-8" method="POST" action="<%= formAction %>">
<input type="hidden" class="valueL" name="xri" value="<%= objectXri %>" />
<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
<table cellspacing="8" class="tableLayout">
  <tr>
    <td class="cellObject">
      <noscript>
        <div class="panelJSWarning" style="display: block;">
          <a href="../../helpJsCookie.html" target="_blank"><img class="popUpButton" src="../../images/help.gif" width="16" height="16" border="0" onclick="javascript:void(window.open('helpJsCookie.html', 'Help', 'fullscreen=no,toolbar=no,status=no,menubar=no,scrollbars=yes,resizable=yes,directories=no,location=no,width=400'));" alt="" /></a> <%= texts.getPageRequiresScriptText() %>
        </div>
      </noscript>
      <div id="etitle" style="height:20px;">
         Import Accounts from Excel Sheet (XLS / XSLX) - 1 account per row<br>
      </div>

      <div class="panel" id="panelObj0" style="display: block">
        <div class="fieldGroupName">
          <span style="font-size:9px;">(Hint: row 1 contains field names, data starts at row 2)</span>
        </div>
        <br>
        <table class="fieldGroup">
          <tr id="waitMsg" style="display:none;">
            <td colspan="3">
              <table class="objectTitle">
                <tr>
                  <td>
                    <div style="padding-left:5px; padding-bottom: 3px;">
                      Processing request - please wait...<br>
                      <img border="0" src='../../images/progress_bar.gif' alt='please wait...' />
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr id="submitFilename">
            <td class="label"><span class="nw">File:</span></td>
            <td >
                <input type="file" class="valueL" size="100" name="<%= UPLOAD_FILE_FIELD_NAME %>" tabindex="500" />
            </td>
            <td class="addon" >&nbsp;<br>&nbsp;</td>
          </tr>
          <tr id="submitButtons">
            <td class="label" colspan="3">
                <INPUT type="Submit" name="OK.Button" tabindex="1000" value="Importieren" onclick="javascript:$('waitMsg').style.display='block';$('submitButtons').style.visibility='hidden';$('submitFilename').style.visibility='hidden';" />
                  <INPUT type="Submit" name="Cancel.Button" tabindex="1010" value="Abbrechen" />
            </td>
            <td></td>
            <td class="addon" >&nbsp;<br>&nbsp;</td>
          </tr>
        </table>
      </div>
    </td>
  </tr>
</table>
</form>
<%
      }
    }
    catch (Exception ex) {
        Action nextAction = new ObjectReference(
          (RefObject_1_0)pm.getObjectById(new Path(objectXri)),
          app
        ).getSelectObjectAction();
%>
        <br />
        <br />
        <span style="color:red;"><b><u>Warning:</u> cannot upload file (no permission?)</b></span>
        <br />
        <br />
        <INPUT type="Submit" name="Continue.Button" tabindex="1" value="Continue" onClick="javascript:location='<%= request.getContextPath() + "/" + nextAction.getEncodedHRef() %>';" />
        <br />
        <br />
        <hr>
<%
        ServiceException e0 = new ServiceException(ex);
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
      </div> <!-- content -->
    </div> <!-- content-wrap -->
  </div> <!-- wrap -->
</div> <!-- container -->
</body>
</html>
