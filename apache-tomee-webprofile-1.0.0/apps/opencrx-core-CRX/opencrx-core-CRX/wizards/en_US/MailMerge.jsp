<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     opencrx, http://www.opencrx.org/
 * Name:        $Id: MailMerge.jsp,v 1.34 2011/09/23 09:46:22 wfro Exp $
 * Description: mail merge addresses of group's members --> RTF document
 * Revision:    $Revision: 1.34 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/09/23 09:46:22 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2008-2009, CRIXP Corp., Switzerland
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
" %>

<%!

   public org.opencrx.kernel.document1.jmi1.DocumentFolder findDocumentFolder(
      String documentFolderName,
      org.opencrx.kernel.document1.jmi1.Segment segment,
      javax.jdo.PersistenceManager pm
   ) {
      org.opencrx.kernel.document1.cci2.DocumentFolderQuery query =
        org.opencrx.kernel.utils.Utils.getDocumentPackage(pm).createDocumentFolderQuery();
      query.name().equalTo(documentFolderName);
      Collection documentFolders = segment.getFolder(query);
      if(!documentFolders.isEmpty()) {
         return (org.opencrx.kernel.document1.jmi1.DocumentFolder)documentFolders.iterator().next();
      }
      return null;
   }

%>
<%
	request.setCharacterEncoding("UTF-8");
	ApplicationContext app = (ApplicationContext)session.getValue("ObjectInspectorServlet.ApplicationContext");
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

<html>

<head>
  <title><%= app.getApplicationName() %> - Mail Merge</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta name="UNUSEDlabel" content="Mail Merge --&gt; RTF">
  <meta name="UNUSEDtoolTip" content="Mail Merge --&gt; RTF">
  <meta name="targetType" content="_blank">
  <meta name="forClass" content="org:opencrx:kernel:account1:Group">
  <meta name="forClass" content="org:opencrx:kernel:account1:Contact">
  <meta name="forClass" content="org:opencrx:kernel:account1:LegalEntity">
  <meta name="forClass" content="org:opencrx:kernel:account1:UnspecifiedAccount">
  <meta name="forClass" content="org:opencrx:kernel:account1:AccountFilterGlobal">
  <meta name="forClass" content="org:opencrx:kernel:account1:PostalAddress">
  <meta name="forClass" content="org:opencrx:kernel:account1:AddressFilterGlobal">
  <meta name="forClass" content="org:opencrx:kernel:activity1:Mailing">
  <meta name="forClass" content="org:opencrx:kernel:activity1:AddressGroup">
  <meta name="order" content="org:opencrx:kernel:account1:Group:mailMerge">
  <meta name="order" content="org:opencrx:kernel:account1:Contact:mailMerge">
  <meta name="order" content="org:opencrx:kernel:account1:LegalEntity:mailMerge">
  <meta name="order" content="org:opencrx:kernel:account1:UnspecifiedAccount:mailMerge">
  <meta name="order" content="org:opencrx:kernel:account1:AccountFilterGlobal:mailMerge">
  <meta name="order" content="org:opencrx:kernel:account1:PostalAddress:mailMerge">
  <meta name="order" content="org:opencrx:kernel:account1:AddressFilterGlobal:mailMerge">
  <meta name="order" content="org:opencrx:kernel:activity1:Mailing:mailMerge">
  <meta name="order" content="org:opencrx:kernel:activity1:AddressGroup:mailMerge">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <script language="javascript" type="text/javascript" src="../../javascript/prototype.js"></script>
  <link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
  <link href="../../_style/colors.css" rel="stylesheet" type="text/css">
  <link href="../../_style/calendar-small.css" rel="stylesheet" type="text/css">
  <link rel='shortcut icon' href='../../images/favicon.ico' />
</head>

<%
   final String FORM_ACTION = "MailMerge.jsp";
   final String MAILMERGE_TEMPLATE_FOLDER_NAME = "Mail Merge Templates";
   final String TEMPLATE_MIMETYPE1 = "application/rtf";
   final String TEMPLATE_MIMETYPE2 = "text/rtf";

   final String featurePostalCountryCode = "country";
   final String documentName = "MailMerge";

   String templateXri   = request.getParameter("templateXri"); // XRI of a mediaContent object
   boolean actionOk     = request.getParameter("Ok.Button") != null;
   boolean actionCancel = request.getParameter("Cancel.Button") != null;
   boolean hasTemplates = templateXri != null;

   try {
       Codes codes = app.getCodes();

       // Timezone is reusable
       final TimeZone tz = TimeZone.getTimeZone(app.getCurrentTimeZone());
       // DateFormat is not multi-thread-safe!
       DateFormat timestamp = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
       timestamp.setLenient(false);
       timestamp.setTimeZone(tz);

       NumberFormat formatter6 = new DecimalFormat("000000");

       RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));

       Path objPath = new Path(obj.refMofId());
       String providerName = objPath.get(2);
       String segmentName = objPath.get(4);

       // Get account1 package
       org.opencrx.kernel.account1.jmi1.Account1Package accountPkg = org.opencrx.kernel.utils.Utils.getAccountPackage(pm);

       // Get document1 package
       org.opencrx.kernel.document1.jmi1.Document1Package documentPkg = org.opencrx.kernel.utils.Utils.getDocumentPackage(pm);
       org.opencrx.kernel.document1.jmi1.Segment documentSegment = (org.opencrx.kernel.document1.jmi1.Segment)pm.getObjectById(
            new Path("xri:@openmdx:org.opencrx.kernel.document1/provider/" + providerName + "/segment/" + segmentName)
         );

%>
      <body onload="$('waitMsg').style.display='none';$('submitButtons').style.display='block';">
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
              <form name="MailMerge" accept-charset="UTF-8" method="POST" action="<%= FORM_ACTION %>">
                <div style="background-color:#F4F4F4;border:1px solid #EBEBEB;padding:10px;margin-top:15px;">
                  <h1>Mail Merge - <%= (new ObjectReference(obj, app)).getLabel() %></h1>
                  <div style="background-color:#FFFFBB;margin:5px 0px;padding:5px;"><i><%= (new ObjectReference(obj, app)).getTitle() %></i></div>
                  <INPUT type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
                  <input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
                  <input type="hidden" name="lastSelection" id="lastSelection" value="<%= request.getParameter("lastSelection") != null ? request.getParameter("lastSelection") : "--" %>" />
<%
      if (!actionCancel) {
        // must choose template first
        org.opencrx.kernel.document1.jmi1.DocumentFolder documentFolder = findDocumentFolder(
           MAILMERGE_TEMPLATE_FOLDER_NAME,
           documentSegment,
           pm
        );
        if (documentFolder != null) {
           org.opencrx.kernel.document1.cci2.DocumentFolderEntryQuery documentFolderEntryFilter = documentPkg.createDocumentFolderEntryQuery();
           documentFolderEntryFilter.forAllDisabled().isFalse();
           documentFolderEntryFilter.orderByName().ascending();
%>
           <select class="valueL" id="templateXri" name="templateXri" tabindex="100" onchange="javascript:$('lastSelection').value=this.value;">
<%
             for(
                 Iterator i = documentFolder.getFolderEntry(documentFolderEntryFilter).iterator();
                 i.hasNext();
             ) {
                org.opencrx.kernel.document1.jmi1.DocumentFolderEntry entry =
                   (org.opencrx.kernel.document1.jmi1.DocumentFolderEntry)i.next();
                if (entry.getDocument() instanceof org.opencrx.kernel.document1.jmi1.Document) {
		                org.opencrx.kernel.document1.jmi1.Document document =
		                  (org.opencrx.kernel.document1.jmi1.Document)entry.getDocument();
		                InputStream content = null;
		                String contentName = null;
		                try {
		                    // get content of head revision
		                    if (document.getHeadRevision() != null) {
		                      org.opencrx.kernel.document1.jmi1.MediaContent mediaContent = null;
		                      if (document.getHeadRevision() instanceof org.opencrx.kernel.document1.jmi1.MediaReference) {
		                        org.opencrx.kernel.document1.jmi1.MediaReference mediaReference =
		                          (org.opencrx.kernel.document1.jmi1.MediaReference)document.getHeadRevision();
		                        if (mediaReference.getMedia() != null) {
		                          mediaContent =
		                            (org.opencrx.kernel.document1.jmi1.MediaContent)((org.opencrx.kernel.document1.jmi1.Media)mediaReference.getMedia());
		                        }
		                      }
		                      else {
		                        if (document.getHeadRevision() instanceof org.opencrx.kernel.document1.jmi1.MediaContent) {
		                          mediaContent =
		                            (org.opencrx.kernel.document1.jmi1.MediaContent)document.getHeadRevision();
		                        }
		                      }
		                      if (
		                        (mediaContent != null) &&
		                        (mediaContent.getContentMimeType() != null) &&
		                        (TEMPLATE_MIMETYPE1.equals(mediaContent.getContentMimeType()) || TEMPLATE_MIMETYPE2.equals(mediaContent.getContentMimeType()))
		                      ) {
		                        contentName = mediaContent.getContentName();
		                        hasTemplates = true;
		                        boolean selected =
		                          request.getParameter("lastSelection") != null &&
		                          request.getParameter("lastSelection").compareTo(mediaContent.refMofId()) == 0;
%>
		                        <option <%= selected ? "selected" : "" %> value="<%= mediaContent.refMofId() %>"><%= entry.getName() == null ? "#" : entry.getName() %> / <%= contentName == null ? "*" : contentName %>
<%
		                      }
		                    }
		                  }
		                catch (Exception em) {
		                  new ServiceException(em).log();
		                }
                }
             }
%>
        </select>
<%
        if (hasTemplates) {
%>
           <BR>
           <BR>
           <div id="submitButtons" <%= actionOk ? "style='display:none;'" : "" %>>
             <BR>
             <INPUT type="Submit" name="Ok.Button" tabindex="1000" value="<%= app.getTexts().getOkTitle() %>" onmouseup="javascript:$('waitMsg').style.display='block';$('submitButtons').style.display='none';" />
               <INPUT type="Submit" name="Cancel.Button" tabindex="1010" value="<%= app.getTexts().getCloseText() %>" onClick="javascript:window.close();" />
             </div>
          <div id="waitMsg" style="<%= actionOk ? "" : "display:none;" %>;padding:18px 10px 4px 10px;">
            <img src="../../images/wait.gif" alt="" />
          </div>
<%
        } else {
%>
          <p>no suitable templates found</p>
<%
        }
      }
    }

    if (templateXri == null && hasTemplates) {
      return;
    }
    if (actionCancel || !hasTemplates) {
    	 if (!hasTemplates) {System.out.println("no templates");}
         Action nextAction = new ObjectReference(
           (RefObject_1_0)pm.getObjectById(new Path(objectXri)),
           app
        ).getSelectObjectAction();
        response.sendRedirect(
           request.getContextPath() + "/" + nextAction.getEncodedHRef()
        );
        return;
    }

    // Get template
    org.opencrx.kernel.document1.jmi1.MediaContent mediaContent =
       (org.opencrx.kernel.document1.jmi1.MediaContent)pm.getObjectById(new Path(templateXri));
    pm.refresh(mediaContent);
    InputStream content = mediaContent.getContent().getContent();
    ByteArrayOutputStream bytes = new ByteArrayOutputStream();
    int b;
    while((b = content.read()) != -1) {
       bytes.write(b);
    }
    bytes.close();
    byte[] template = bytes.toByteArray();

    // Prepare
    org.opencrx.kernel.account1.jmi1.Account account = null;
    String location = UUIDs.getGenerator().next().toString();
    String filename = null;

    ArrayList postalAddressesXri = new ArrayList();

    boolean isAccount = false;
    boolean isAddressFilterGlobal = false;
    boolean isAddressGroupMember = false;
    boolean isAccountFilterGlobal = false;
    boolean isMailingActivityRecipient = false;
    Iterator i = null;
    if (obj instanceof org.opencrx.kernel.account1.jmi1.Group) {
      i = ((org.opencrx.kernel.account1.jmi1.Group)obj).getMember().iterator();
      // prepare zip file to be sent to browser
    }
    if (obj instanceof org.opencrx.kernel.account1.jmi1.AccountFilterGlobal) {
      i = ((org.opencrx.kernel.account1.jmi1.AccountFilterGlobal)obj).getFilteredAccount().iterator();
      // prepare zip file to be sent to browser
      isAccountFilterGlobal = true;
    }
    if (obj instanceof org.opencrx.kernel.account1.jmi1.AddressFilterGlobal) {
      i = ((org.opencrx.kernel.account1.jmi1.AddressFilterGlobal)obj).getFilteredAddress().iterator();
      // prepare zip file to be sent to browser
      isAddressFilterGlobal = true;
    }
    if (obj instanceof org.opencrx.kernel.activity1.jmi1.AddressGroup) {
      i = ((org.opencrx.kernel.activity1.jmi1.AddressGroup)obj).getMember().iterator();
      // prepare zip file to be sent to browser
      isAddressGroupMember = true;
    }
    if (obj instanceof org.opencrx.kernel.activity1.jmi1.Mailing) {
      i = ((org.opencrx.kernel.activity1.jmi1.Mailing)obj).getMailingRecipient().iterator();
      // prepare zip file to be sent to browser
      isMailingActivityRecipient = true;
    }
    if (
        (obj instanceof org.opencrx.kernel.account1.jmi1.Contact) ||
        (obj instanceof org.opencrx.kernel.account1.jmi1.LegalEntity) ||
        (obj instanceof org.opencrx.kernel.account1.jmi1.UnspecifiedAccount)
    ) {
      isAccount = true;
      account = (org.opencrx.kernel.account1.jmi1.Account)obj;
    }
    if (obj instanceof org.opencrx.kernel.account1.jmi1.PostalAddress) {
      postalAddressesXri.add(obj.refMofId());
    }

    while (
      ((i != null) && i.hasNext()) ||
      (isAccount && (account != null))
    ) {
      if (isAddressFilterGlobal) {
        org.opencrx.kernel.account1.jmi1.AccountAddress accountAddress =
            (org.opencrx.kernel.account1.jmi1.AccountAddress)i.next();
        if (accountAddress instanceof org.opencrx.kernel.account1.jmi1.PostalAddress) {
          postalAddressesXri.add(accountAddress.refMofId());
        }
      }
      else {
        if (isAddressGroupMember) {
          org.opencrx.kernel.activity1.jmi1.AddressGroupMember addressGroupMember =
             (org.opencrx.kernel.activity1.jmi1.AddressGroupMember)i.next();
          if ((addressGroupMember.getAddress() != null) && (addressGroupMember.getAddress() instanceof org.opencrx.kernel.account1.jmi1.PostalAddress)) {
              postalAddressesXri.add(addressGroupMember.getAddress().refMofId());
          }
        }
        else {
          if (isMailingActivityRecipient) {
            org.opencrx.kernel.activity1.jmi1.AbstractMailingRecipient abstractMailingRecipient =
                (org.opencrx.kernel.activity1.jmi1.AbstractMailingRecipient)i.next();
            if (abstractMailingRecipient instanceof org.opencrx.kernel.activity1.jmi1.MailingRecipient) {
              org.opencrx.kernel.activity1.jmi1.MailingRecipient mailingRecipient =
                  (org.opencrx.kernel.activity1.jmi1.MailingRecipient)abstractMailingRecipient;
              if ((mailingRecipient.getParty() != null) && (mailingRecipient.getParty() instanceof org.opencrx.kernel.account1.jmi1.PostalAddress)) {
                postalAddressesXri.add(mailingRecipient.getParty().refMofId());
              }
            } else {
              if (abstractMailingRecipient instanceof org.opencrx.kernel.activity1.jmi1.MailingRecipientGroup) {
                org.opencrx.kernel.activity1.jmi1.MailingRecipientGroup mailingRecipientGroup =
                    (org.opencrx.kernel.activity1.jmi1.MailingRecipientGroup)abstractMailingRecipient;
                if ((mailingRecipientGroup.getParty() != null) && (mailingRecipientGroup.getParty() instanceof org.opencrx.kernel.activity1.jmi1.AddressGroup)) {
                  org.opencrx.kernel.activity1.jmi1.AddressGroup addressGroup =
                    (org.opencrx.kernel.activity1.jmi1.AddressGroup)mailingRecipientGroup.getParty();
                  for(
                      Iterator j = addressGroup.getMember().iterator();
                      j.hasNext();
                  ) {
                    org.opencrx.kernel.activity1.jmi1.AddressGroupMember addressGroupMember =
                       (org.opencrx.kernel.activity1.jmi1.AddressGroupMember)j.next();
                    if ((addressGroupMember.getAddress() != null) && (addressGroupMember.getAddress() instanceof org.opencrx.kernel.account1.jmi1.PostalAddress)) {
                        postalAddressesXri.add(addressGroupMember.getAddress().refMofId());
                    }
                  }
                }
              }
            }
          }
          else {
            if (!isAccount) {
              if (isAccountFilterGlobal) {
                account = (org.opencrx.kernel.account1.jmi1.Account)i.next();
              } else {
                org.opencrx.kernel.account1.jmi1.Member member =
                   (org.opencrx.kernel.account1.jmi1.Member)i.next();
                if ((member.isDisabled() != null) && (member.isDisabled().booleanValue())) {
                  // skip disabled members
                  continue;
                }
                else {
                  account = member.getAccount();
                }
                if ((account != null) && (account.isDisabled() != null) && (account.isDisabled().booleanValue())) {
                  // skip disabled accounts
                  continue;
                }
              }
            }
            if(account != null) {
            org.opencrx.kernel.account1.jmi1.PostalAddress mailingAddress = null;
              boolean searchingMainMailingAddress = true;
              for(
                  Iterator addr = account.getAddress().iterator();
                  addr.hasNext() && searchingMainMailingAddress;
              ) {
                org.opencrx.kernel.account1.jmi1.AccountAddress address =
                  (org.opencrx.kernel.account1.jmi1.AccountAddress)addr.next();
                 if (!(address instanceof org.opencrx.kernel.account1.jmi1.PostalAddress)) {continue;}
                 mailingAddress = (org.opencrx.kernel.account1.jmi1.PostalAddress)address;
                 searchingMainMailingAddress = !mailingAddress.isMain();
                }
                if (mailingAddress != null) {
                  postalAddressesXri.add(mailingAddress.refMofId());
                }
            }
            account = null; /* ensure termination if isAccount==true !!! */
          }
        }

      }
    } /* while */

    // Generate document(s)
    org.opencrx.kernel.utils.rtf.RTFTemplate document = new org.opencrx.kernel.utils.rtf.RTFTemplate();
    document.readFrom(new InputStreamReader(new ByteArrayInputStream(template)), true);
    org.opencrx.kernel.utils.rtf.Bookmark bmTemplateRow = null;
    String[] templateRowLayout = null;
    try {
        bmTemplateRow = document.searchBookmark("TemplateRow");
        String layoutDefinition = bmTemplateRow.getRawContent();
        if(layoutDefinition != null && layoutDefinition.indexOf(" ") > 0) {
            layoutDefinition = layoutDefinition.substring(layoutDefinition.lastIndexOf(" ")).trim();
        }
        templateRowLayout = bmTemplateRow == null || layoutDefinition == null?
           null :
           layoutDefinition.split(";");

    } catch(Exception e) {}
    int nColumns = (templateRowLayout == null) || (templateRowLayout.length < 1) ?
       1 :
       Integer.valueOf(templateRowLayout[0]).intValue();
    int nRecordsPerRow = (templateRowLayout == null) || (templateRowLayout.length < 2) ?
       1 :
       Integer.valueOf(templateRowLayout[1]).intValue();
    ZipOutputStream zipos = new ZipOutputStream(new FileOutputStream(app.getTempFileName(location, "")));
    int counter = 0;
    int recordIndex = -1;
    for(
       Iterator a = postalAddressesXri.iterator();
       a.hasNext();
    ) {
      counter += 1;
      org.opencrx.kernel.account1.jmi1.PostalAddress mailingAddress =
         (org.opencrx.kernel.account1.jmi1.PostalAddress)pm.getObjectById(new Path((String)a.next()));
      if(bmTemplateRow != null) {
          if((recordIndex == -1) || (recordIndex == nRecordsPerRow)) {
             document.appendTableRow("TemplateRow");
             recordIndex = 0;
          }
      }
      else {
         document = new org.opencrx.kernel.utils.rtf.RTFTemplate();
         document.readFrom(new InputStreamReader(new ByteArrayInputStream(template)), true);
      }
      org.opencrx.kernel.utils.rtf.MultiTextParts mtpWarning = new org.opencrx.kernel.utils.rtf.MultiTextParts();
      mtpWarning.addText(org.opencrx.kernel.utils.rtf.TextPart.NEWLINE);
      // Map mailing address
      org.opencrx.kernel.utils.rtf.MultiTextParts mtpMailingAddress = new org.opencrx.kernel.utils.rtf.MultiTextParts();
      boolean needsNewLine = false;
      if (mailingAddress != null) {
         try {
             for(Iterator m = mailingAddress.getPostalAddressLine().iterator(); m.hasNext();) {
               String lineToAdd = (m.next()).toString();
               if (lineToAdd != null) {
                 lineToAdd = lineToAdd.trim();
                 if (lineToAdd.length() > 0) {
                   if(needsNewLine) mtpMailingAddress.addText(org.opencrx.kernel.utils.rtf.TextPart.NEWLINE);
                   mtpMailingAddress.addText(new org.opencrx.kernel.utils.rtf.TextPart(lineToAdd));
                   needsNewLine = true;
                 }
               }
             }
             for(Iterator m = mailingAddress.getPostalStreet().iterator(); m.hasNext();) {
               String lineToAdd = (m.next()).toString();
               if (lineToAdd != null) {
                 lineToAdd = lineToAdd.trim();
                 if (lineToAdd.length() > 0) {
                   if(needsNewLine) mtpMailingAddress.addText(org.opencrx.kernel.utils.rtf.TextPart.NEWLINE);
                   mtpMailingAddress.addText(new org.opencrx.kernel.utils.rtf.TextPart(lineToAdd));
                   needsNewLine = true;
                 }
               }
             }
             if(needsNewLine) mtpMailingAddress.addText(org.opencrx.kernel.utils.rtf.TextPart.NEWLINE);
             mtpMailingAddress.addText(new org.opencrx.kernel.utils.rtf.TextPart(
               (mailingAddress.getPostalCountry() == (short)0
                   ? ""
                   : (String)(codes.getShortText(featurePostalCountryCode, app.getCurrentLocaleAsIndex(), true, true).get(new Short(mailingAddress.getPostalCountry()))) + "-")
               + (mailingAddress.getPostalCode() == null
                   ? ""
                   : (mailingAddress.getPostalCode().length() > 0 ? mailingAddress.getPostalCode() + " " : ""))
               + (mailingAddress.getPostalCity() == null ? "" : mailingAddress.getPostalCity())
             ));
             }
         catch (Exception e) {}
      }
      else {
           mtpMailingAddress.addText(new org.opencrx.kernel.utils.rtf.TextPart("WARNING: no postal address available"));
           mtpMailingAddress.addText(org.opencrx.kernel.utils.rtf.TextPart.NEWLINE);
      }
      // Filename
      String filenameDetail = "---";
      try {
          String accountXri = new Path(mailingAddress.refMofId()).getParent().getParent().toXri();
          account = (org.opencrx.kernel.account1.jmi1.Account)pm.getObjectById(new Path(accountXri));
          filenameDetail = ((account.getFullName() != null ? account.getFullName() : "---NoName")).replaceAll(" +", "_");
      }
      catch (Exception ef) {}
      filename =
           providerName + "_"
           + segmentName + "_"
           + (formatter6.format(counter)) + "_"
           + filenameDetail;
      filename = org.opencrx.kernel.utils.Utils.toFilename(filename) + ".rtf";
      filename = URLEncoder.encode(filename, "UTF-8");

      // Replace template bookmarks with actual values
      String suffix = recordIndex <= 0 ? "" : "" + Integer.toString(recordIndex);
      try {document.setBookmarkContent("filename" + suffix, filename, true); } catch (Exception e) {}
      try {document.setBookmarkContent("accountXri" + suffix, account.refMofId(), true); } catch (Exception e) {}
      try {document.setBookmarkContent("fullName" + suffix, account.getFullName(), true); } catch (Exception e) {}
      try {document.setBookmarkContent("counter" + suffix, formatter6.format(counter), true); } catch (Exception e) {}
      try {document.setBookmarkContent("timestamp" + suffix, timestamp.format(new java.util.Date()), true); } catch (Exception e) {}
      try {document.setBookmarkContent("addressXri" + suffix, mailingAddress.refMofId(), true); } catch (Exception e) {}
      try {document.setBookmarkContent("mailingAddress" + suffix, mtpMailingAddress, true); } catch (Exception e) {}
      if(bmTemplateRow == null) {
         try {
              zipos.putNextEntry(new ZipEntry(filename));
              document.writeTo(zipos);
              zipos.closeEntry();
            }
         catch (Exception e) {
               try {
                 zipos.closeEntry();
               }
               catch (Exception ex) {}
               new ServiceException(e).log();
           }
      }
      if(bmTemplateRow != null) {
          recordIndex++;
      }
    } // for loop over addresses

    // Write file
    if(bmTemplateRow != null) {
      try {
           zipos.putNextEntry(new ZipEntry("MailMerge.rtf"));
           document.writeTo(zipos);
           zipos.closeEntry();
         }
      catch (Exception e) {
            try {
              zipos.closeEntry();
            }
            catch (Exception ex) {}
            new ServiceException(e).log();
        }
    }
    try {
        zipos.finish();
        zipos.close();
    } catch (Exception e) {
        new ServiceException(e).log();
    }
    if(location != null) {
       // determine user-agent because IE doesn't handle application/zip properly
       String userAgent = request.getHeader("User-Agent");
       String mimeType = "application/zip";
       if ((userAgent != null) && (userAgent.indexOf("IE") >=0)) {
          mimeType = "text/plain";
       }
       Action downloadAction = null;
       String fileToDownload = documentName + ".zip";
       downloadAction =
         new Action(
               Action.EVENT_DOWNLOAD_FROM_LOCATION,
               new Action.Parameter[]{
                   new Action.Parameter(Action.PARAMETER_LOCATION, location),
                   new Action.Parameter(Action.PARAMETER_NAME, fileToDownload),
                   new Action.Parameter(Action.PARAMETER_MIME_TYPE, mimeType)
               },
               app.getTexts().getClickToDownloadText() + " " + fileToDownload,
               true
           );
%>
      <div style="background-color:#FFFFFF;border:1px solid #EBEBEB;padding:10px;margin-top:15px;">
        <a href="<%= request.getContextPath() + "/" + downloadAction.getEncodedHRef(requestId) %>"><%= app.getTexts().getClickToDownloadText() %> <b><%= fileToDownload %></b></a>
        (containing <%= counter %> documents)
      </div>
<%
    }
    else {
      // Go back to previous view
      Action nextAction = new ObjectReference(
           (RefObject_1_0)pm.getObjectById(new Path(objectXri)),
           app
        ).getSelectObjectAction();
         response.sendRedirect(
         request.getContextPath() + "/" + nextAction.getEncodedHRef()
         );
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
