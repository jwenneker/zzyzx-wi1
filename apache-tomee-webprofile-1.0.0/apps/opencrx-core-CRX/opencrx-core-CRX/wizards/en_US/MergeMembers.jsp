<%@  page contentType= "text/html;charset=utf-8" language="java" pageEncoding= "UTF-8" %>
<%@ page session="true" import="
java.util.*,
java.io.*,
java.text.*,
java.math.*,
java.net.*,
java.sql.*,
javax.naming.Context,
javax.naming.InitialContext,
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
org.openmdx.base.naming.*,
org.openmdx.base.query.*,
org.openmdx.kernel.log.*
" %><%
  final String WIZARD_NAME = "MergeMembers";
  final String FORMACTION   = WIZARD_NAME + ".jsp";
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

<html>

<head>
  <title>Merge Members into other Account</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta name="label" content="Merge Members into other Account">
  <meta name="toolTip" content="Merge Members into other Account">
  <meta name="targetType" content="_blank">
  <meta name="forClass" content="org:opencrx:kernel:account1:Contact">
  <meta name="forClass" content="org:opencrx:kernel:account1:LegalEntity">
  <meta name="forClass" content="org:opencrx:kernel:account1:Group">
  <meta name="forClass" content="org:opencrx:kernel:account1:UnspecifiedAccount">
  <meta name="order" content="9101">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
  <link href="../../_style/ssf.css" rel="stylesheet" type="text/css">
  <link href="../../_style/colors.css" rel="stylesheet" type="text/css">
  <!--[if lt IE 7]><script type="text/javascript" src="../../javascript/iehover-fix.js"></script><![endif]-->
  <script language="javascript" type="text/javascript" src="../../javascript/portal-all.js"></script>

  <script language="javascript" type="text/javascript">
    var OF = null;
    try {
      OF = self.opener.OF;
    }
    catch(e) {
      OF = null;
    }
    if(!OF) {
      OF = new ObjectFinder();
    }
  </script>
  <link rel="shortcut icon" href="../../images/favicon.ico" />
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
    NumberFormat formatter = new DecimalFormat("0");

	final String MEMBER_CLASS = "org:opencrx:kernel:account1:Member";
	final String ACCOUNT_CLASS = "org:opencrx:kernel:account1:Account";
	final String CONTACT_CLASS = "org:opencrx:kernel:account1:Contact";
	final String GROUP_CLASS = "org:opencrx:kernel:account1:Group";

    final String accountTargetFinder = "org:opencrx:kernel:account1:Segment:account";

    // get Parameters
    String accountTargetXriTitle = (request.getParameter("accountTargetXri.Title") == null ? "" : request.getParameter("accountTargetXri.Title"));
    String accountTargetXri = (request.getParameter("accountTargetXri") == null ? "" : request.getParameter("accountTargetXri"));
    org.opencrx.kernel.account1.jmi1.Account accountTarget = null;
    if (accountTargetXri.length() > 0) {
      try {
        accountTarget = (org.opencrx.kernel.account1.jmi1.Account)pm.getObjectById(new Path(accountTargetXri));
      } catch (Exception e) {
        accountTargetXri = "";
      }
    }
    if (accountTargetXriTitle == null || accountTargetXriTitle.trim().length() == 0) {
      accountTargetXri = "";
      accountTarget = null;
    }

    boolean includeDisabledMembers = request.getParameter("includeDisabledMembers") != null;
    boolean includeDisabledAccounts = request.getParameter("includeDisabledAccounts") != null;

    boolean actionOk = request.getParameter("OK.Button") != null;
    boolean actionCancel = request.getParameter("Cancel.Button") != null;

    try {
    	// get reference of calling object
      RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));

      Path objectPath = new Path(objectXri);
      String providerName = objectPath.get(2);
      String segmentName = objectPath.get(4);

      if (actionCancel) {
        // Go back to previous view
    		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
    		response.sendRedirect(
    			request.getContextPath() + "/" + nextAction.getEncodedHRef()
      	);
      	return;
      }

      UserDefinedView userView = new UserDefinedView(
        obj,
        app,
        viewsCache.getView(requestId)
      );

      // Get account1 package
      org.opencrx.kernel.account1.jmi1.Account1Package accountPkg = org.opencrx.kernel.utils.Utils.getAccountPackage(pm);

      // Get account segment
      org.opencrx.kernel.account1.jmi1.Segment accountSegment =
        (org.opencrx.kernel.account1.jmi1.Segment)pm.getObjectById(
          new Path("xri:@openmdx:org.opencrx.kernel.account1/provider/" + providerName + "/segment/" + segmentName)
         );

      org.opencrx.kernel.account1.jmi1.Account accountSource = null;
      if (obj instanceof org.opencrx.kernel.account1.jmi1.Account) {
        accountSource = (org.opencrx.kernel.account1.jmi1.Account)obj;
      }
%>
      <div id="etitle" style="height:20px;">
         Merge Members
      </div>
      <form name="MergeMembers" accept-charset="UTF-8" method="POST" action="<%= FORMACTION %>">
        <input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
        <input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
        <br />

        <fieldset>
  	      <table class="fieldGroup">
  	        <tr>
              <td class="label"><span class="nw">&nbsp;</span></td>
  	          <td></td>
  	          <td class="addon"></td>
            	<td class="label"><span class="nw">&nbsp;</span></td>
  	          <td></td>
  	          <td class="addon"></td>
  	        </tr>

  	        <tr>
              <td class="label"><span class="nw">SOURCE <%= app.getLabel(ACCOUNT_CLASS) %></span></td>
  	          <td colspan=4><b><%= accountSource == null ? "???" : (new ObjectReference(accountSource, app)).getTitle() %></b></td>
  	          <td class="addon"></td>
  	        </tr>

   	        <tr>
            	<td class="label"><span class="nw">TARGET <%= app.getLabel(ACCOUNT_CLASS) %> <font color="red">*</font></span></td>
<%
              String lookupId = org.opencrx.kernel.backend.Contracts.getInstance().getUidAsString();
              Action findAccountTargetObjectAction = Action.getFindObjectAction(accountTargetFinder, lookupId);
              String accountName = app.getLabel(ACCOUNT_CLASS);
%>
  	          <td colspan=4>
                <div class="autocompleterMenu">
                  <ul id="nav" class="nav" onmouseover="sfinit(this);" >
                    <li><a href="#"><img border="0" alt="" src="../../images/autocomplete_select.png" /></a>
                      <ul onclick="this.style.left='-999em';" onmouseout="this.style.left='';">
                        <li class="selected"><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Account)*filterByFeature*(fullName)*filterOperator*(IS_LIKE)*orderByFeature*(fullName)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(ACCOUNT_CLASS, "fullName", app.getCurrentLocaleAsIndex()) %></a></li>
                        <li><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Account)*filterByFeature*(description)*filterOperator*(IS_LIKE)*orderByFeature*(description)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(ACCOUNT_CLASS, "description", app.getCurrentLocaleAsIndex()) %></a></li>
                        <li><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Account)*filterByFeature*(aliasName)*filterOperator*(IS_LIKE)*orderByFeature*(aliasName)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(ACCOUNT_CLASS, "aliasName", app.getCurrentLocaleAsIndex()) %></a></li>
                        <li><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Account)*filterByFeature*(firstName)*filterOperator*(IS_LIKE)*orderByFeature*(firstName)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(CONTACT_CLASS, "firstName", app.getCurrentLocaleAsIndex()) %></a></li>
                        <li><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Account)*filterByFeature*(middleName)*filterOperator*(IS_LIKE)*orderByFeature*(middleName)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(CONTACT_CLASS, "middleName", app.getCurrentLocaleAsIndex()) %></a></li>
                        <li><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Account)*filterByFeature*(lastName)*filterOperator*(IS_LIKE)*orderByFeature*(lastName)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(CONTACT_CLASS, "lastName", app.getCurrentLocaleAsIndex()) %></a></li>
                        <li><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Account)*filterByFeature*(name)*filterOperator*(IS_LIKE)*orderByFeature*(name)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(GROUP_CLASS, "name", app.getCurrentLocaleAsIndex()) %></a></li>
                        <li><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Account)*filterByFeature*(nickName)*filterOperator*(IS_LIKE)*orderByFeature*(nickName)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(CONTACT_CLASS, "nickName", app.getCurrentLocaleAsIndex()) %></a></li>
                      </ul>
                    </li>
                  </ul>
                </div>
                <div class="autocompleterInput"><input type="text" class="valueL valueAC <%= actionOk && (accountTarget == null) ? "mandatory" : "" %>" id="accountTargetXri.Title" name="accountTargetXri.Title" tabindex="100" value="<%= accountTargetXriTitle != null ? accountTargetXriTitle : "" %>" /></div>
                <input type="hidden" class="valueLLocked" id="accountTargetXri" name="accountTargetXri" readonly value="<%= accountTargetXri != null ? accountTargetXri : "" %>" />
                <div class="autocomplete" id="accountTarget.Update" style="display:none;z-index:500;"></div>
                <script type="text/javascript" language="javascript" charset="utf-8">
                  ac_addObject0 = new Ajax.Autocompleter(
                    'accountTargetXri.Title',
                    'accountTarget.Update',
                    '../../ObjectInspectorServlet?event=40&parameter=xri*%28xri%3A%40openmdx%3Aorg.opencrx.kernel.account1%2Fprovider%2F<%= providerName %>%2Fsegment%2F<%= segmentName %>%29*referenceName*%28account%29*filterByType*%28org%3Aopencrx%3Akernel%3Aaccount1%3AAccount%29*filterByFeature*%28fullName%29*filterOperator*%28IS_LIKE%29*orderByFeature*%28fullName%29*position*%280%29*size*%2820%29',
                    {
                      paramName: 'filtervalues',
                      minChars: 0,
                      afterUpdateElement: updateXriField
                    }
                  );
                </script>
  	          </td>
  	          <td class="addon">
                <img class="popUpButton" border="0" align="bottom" alt="Click to open ObjectFinder" src="../../images/lookup.gif" onclick="OF.findObject('../../<%= findAccountTargetObjectAction.getEncodedHRef() %>', $('accountTargetXri.Title'), $('accountTargetXri'), '<%= lookupId %>');" />
  	          </td>
            </tr>

  	        <tr>
              <td class="label"><INPUT type="checkbox" name="includeDisabledMembers" tabindex="500" value="includeDisabledMembers" <%= includeDisabledMembers ? "checked" : "" %> /></td>
  	          <td colspan=4>merge disabled Members</td>
  	          <td class="addon"></td>
  	        </tr>

  	        <tr>
              <td class="label"><INPUT type="checkbox" name="includeDisabledAccounts" tabindex="500" value="includeDisabledAccounts" <%= includeDisabledAccounts ? "checked" : "" %> /></td>
  	          <td colspan=4>merge Members referencing disabled Accounts</td>
  	          <td class="addon"></td>
  	        </tr>

          </table>
        </fieldset>
        <br>
<%
        try {
          Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
%>
          <table class="fieldGroup">
            <tr id="submitButtons" style="font-weight:bold;">
              <td>
                <INPUT type="Submit" name="OK.Button" id="OK.Button" tabindex="9000" value="<%= app.getTexts().getOkTitle() %>" onmouseup="javascript:$('waitMsg').style.display='block';$('submitButtons').style.visibility='hidden';" />
                <INPUT style="display:none;" type="Submit" name="Cancel.Button" tabindex="9010" value="<%= app.getTexts().getCancelTitle() %>" onmouseup="javascript:$('waitMsg').style.display='block';$('submitButtons').style.visibility='hidden';" />
                <INPUT type="Submit" name="Cancel.Button" tabindex="9010" value="<%= app.getTexts().getCancelTitle() %>" onClick="javascript:window.close();" />
              </td>
            </tr>
            <tr id="waitMsg" style="display:none;">
              <td>
                <div style="padding-left:5px; padding-bottom: 3px;">
                  <img src="../../images/wait.gif" alt="" />
                </div>
              </td>
            </tr>
          </table>
          <br>
          <br>
<%
        }
        catch (Exception e) {};

        org.opencrx.kernel.account1.jmi1.Member currentMember = null;
        org.opencrx.kernel.account1.jmi1.Account currentAccount = null;

        if (actionOk && accountTarget != null) {
          // add members of accountSource to accountTarget
          String accountTargetHref = "";
          Action action = new ObjectReference(
            accountTarget,
            app
          ).getSelectObjectAction();
          accountTargetHref = "../../" + action.getEncodedHRef();
%>
          <table><tr><td>
          <table id="resultTable" class="gridTableFull">
            <tr class="gridTableHeaderFull"><!-- 4 columns -->
              <td><b><%= app.getLabel(MEMBER_CLASS) %></b></td>
              <td align=center>SOURCE<br><b><%= app.getLabel(MEMBER_CLASS) %> <%= userView.getFieldLabel(MEMBER_CLASS, "disabled", app.getCurrentLocaleAsIndex()) %></b></td>
              <td align=center>SOURCE<br><b><%= app.getLabel(ACCOUNT_CLASS) %> <%= userView.getFieldLabel(ACCOUNT_CLASS, "disabled", app.getCurrentLocaleAsIndex()) %></b></td>
              <td align=center>Added to TARGET<br><b><a href="<%= accountTargetHref %>" target="_blank"><%= accountTarget.getFullName() %></a></b></td>
            </tr>
            <tr class="gridTableHeaderFull"><!-- 4 columns -->
              <td colspan="4" style="margin-bottom:1px;background-color:#000000;"><img border=0 src="../../images/spacer.gif" width="1px" height="1px" alt="" /></td>
            </tr>
<%
            Iterator j = null;
            org.opencrx.kernel.account1.cci2.MemberQuery memberFilter = accountPkg.createMemberQuery();
            //memberFilter.forAllDisabled().isFalse();
            Set memberXri = new HashSet();
            for (Iterator m = accountSource.getMember(memberFilter).iterator(); m.hasNext();) {
              memberXri.add(((org.opencrx.kernel.account1.jmi1.Member)m.next()).refMofId());
            }
            j = memberXri.iterator();
            while (((j == null) && (currentMember != null)) || ((j != null) && (j.hasNext())) || (currentAccount != null)) {
              boolean createNewMember = false;
              try {
                pm.currentTransaction().begin();
                String customerInfo = "---";
                if (currentAccount == null) {
                  // get member
                  if ((currentMember == null) && (j != null) && (j.hasNext())) {
                    try {
                      currentMember = (org.opencrx.kernel.account1.jmi1.Member)pm.getObjectById(new Path((String)j.next()));
                    } catch (Exception e) {}
                  }
                  if (currentMember != null) {
                    currentAccount = currentMember.getAccount();
                  }
            	}
                String memberHref = "";
                if (currentAccount != null) {
                  customerInfo = (new ObjectReference(currentAccount, app)).getTitle();
                  action = new ObjectReference(
                    currentMember,
                    app
                  ).getSelectObjectAction();
                  memberHref = "../../" + action.getEncodedHRef();
                  if (
                    (includeDisabledMembers || (currentMember != null && (currentMember.isDisabled() == null || !currentMember.isDisabled().booleanValue()))) &&
                    (includeDisabledAccounts || (currentAccount != null && (currentAccount.isDisabled() == null || !currentAccount.isDisabled().booleanValue())))
                  ) {
                    createNewMember = true;
                  }
                }
%>
                <tr class="gridTableRowFull"><!-- 4 columns -->
                  <td><a href="<%= memberHref %>" target="_blank"><%= customerInfo %></a></td>
                  <td align=center><b><img src="../../images/<%= currentMember.isDisabled() != null && currentMember.isDisabled().booleanValue() ? "" : "not" %>checked_r.gif" alt="" /></td>
                  <td align=center><b><img src="../../images/<%= currentAccount.isDisabled() != null && currentAccount.isDisabled().booleanValue() ? "" : "not" %>checked_r.gif" alt="" /></td>
<%
                  if (createNewMember && (currentAccount != null) && (accountTarget != currentAccount)) {
                    // add new member to accountTarget
                    customerInfo += " (added)";
                    org.opencrx.kernel.account1.jmi1.Member newMember = accountPkg.getMember().createMember();
                    newMember.refInitialize(false, false);
                    newMember.getForUseBy().addAll(currentMember.getForUseBy());
                    newMember.setName(currentMember.getName());
                    newMember.setDescription(currentMember.getDescription());
                    newMember.setMemberRole(currentMember.getMemberRole());
                    newMember.setValidFrom(new java.util.Date());
                    newMember.setAccount(currentAccount);
                    newMember.setQuality((short)5); // normal
                    accountTarget.addMember(
                      false,
                      org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
                      newMember
                    );
%>
                    <td align=center><b><img src="../../images/checked_r.gif" alt="" /></td>
<%
                  } else {
                    customerInfo += " (NOT added)";
%>
                    <td align=center><b><img src="../../images/notchecked_r.gif" alt="" /></td>
<%
                  }
                  System.out.println(customerInfo);
                  pm.currentTransaction().commit();
                } catch (Exception e) {
                  try {
        	        pm.currentTransaction().rollback();
        	      } catch (Exception er) {}
                    ServiceException e0 = new ServiceException(e);
                    e0.log();
                    out.println("<p><b>!! Failed !!<br><br>The following exception(s) occured:</b><br><br><pre>");
                    PrintWriter pw = new PrintWriter(out);
                    e0.printStackTrace(pw);
                    out.println("</pre></p>");
                    continue;
                }
                currentMember = null;
                currentAccount = null;
%>
              </tr>
<%
            } /* while more members  */
            obj = (RefObject_1_0)accountTarget;
%>
          </table>
          </td></tr></table>
<%
        }
%>
      </form>
<%
    }
    catch (Exception e) {
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
