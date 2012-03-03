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
  final String WIZARD_NAME = "MembersDetectDuplicates";
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
  <title>Detect Duplicate Members</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta name="label" content="Detect Duplicate Members">
  <meta name="toolTip" content="Detect Duplicate Members">
  <meta name="targetType" content="_blank">
  <meta name="forClass" content="org:opencrx:kernel:account1:Contact">
  <meta name="forClass" content="org:opencrx:kernel:account1:LegalEntity">
  <meta name="forClass" content="org:opencrx:kernel:account1:Group">
  <meta name="forClass" content="org:opencrx:kernel:account1:UnspecifiedAccount">
  <meta name="order" content="9100">
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

	final String INDENT = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

    try {
    	// get reference of calling object
      RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));

      Path objectPath = new Path(objectXri);
      String providerName = objectPath.get(2);
      String segmentName = objectPath.get(4);

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
         Detect Duplicate Members
      </div>
      <form name="DuplicateMembers" accept-charset="UTF-8" method="POST" action="<%= FORMACTION %>">
        <input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
        <input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
        <br />
<%
        Set accountXris = new HashSet();
        Set membersToDelete = new HashSet();
        int sizeOfSet = 0;
        for(Iterator i = accountSource.getMember().iterator(); i.hasNext(); ) {
            org.opencrx.kernel.account1.jmi1.Member member = (org.opencrx.kernel.account1.jmi1.Member)i.next();
            try {
              if (member.getAccount() != null) {
                accountXris.add(member.getAccount().refMofId());
              }
            } catch (Exception e) {}
            if (accountXris.size() <= sizeOfSet) {
                // current account is duplicate
                membersToDelete.add(member);
            }
            sizeOfSet = accountXris.size();
        }
%>
        <table><tr><td>
        <table id="resultTable" class="gridTableFull">
          <tr class="gridTableHeaderFull"><!-- 6 columns -->
            <td><b><%= app.getLabel(ACCOUNT_CLASS) %><br><%= INDENT + app.getLabel(MEMBER_CLASS) %></b></td>
            <td align="center"><b><%= app.getLabel(MEMBER_CLASS) %> <%= userView.getFieldLabel(MEMBER_CLASS, "disabled", app.getCurrentLocaleAsIndex()) %></b></td>
            <td align="center"><b><%= app.getLabel(ACCOUNT_CLASS) %> <%= userView.getFieldLabel(ACCOUNT_CLASS, "disabled", app.getCurrentLocaleAsIndex()) %></b></td>
            <td align="left"><b><%= app.getLabel(MEMBER_CLASS) %> <%= userView.getFieldLabel(MEMBER_CLASS, "createdAt", app.getCurrentLocaleAsIndex()) %></b></td>
            <td align="left"><b><%= app.getLabel(MEMBER_CLASS) %> <%= userView.getFieldLabel(MEMBER_CLASS, "createdBy", app.getCurrentLocaleAsIndex()) %></b></td>
            <td align="center"></td>
          </tr>
<%
          for(Iterator i = membersToDelete.iterator(); i.hasNext(); ) {
              try {
                //pm.currentTransaction().begin();
                org.opencrx.kernel.account1.jmi1.Member member = (org.opencrx.kernel.account1.jmi1.Member)i.next();
                org.opencrx.kernel.account1.jmi1.Account account = null;

                String customerInfo = "---";
                String accountHref = "";
                if (member.getAccount() != null) {
                  customerInfo = (new ObjectReference(member.getAccount(), app)).getTitle();
                  account = member.getAccount();
                  Action action = new ObjectReference(
                      account,
                      app
                  ).getSelectObjectAction();
                  accountHref = "../../" + action.getEncodedHRef();
                } else {
                  continue;
                }
%>
                <tr class="gridTableRowFull"><!-- 6 columns -->
                  <td colspan="6"><b><a href="<%= accountHref %>" target="_blank"><%= customerInfo %></a></b></td>
                </tr>
<%

                // Format dates/times
                TimeZone timezone = TimeZone.getTimeZone(app.getCurrentTimeZone());
                SimpleDateFormat timeFormat = new SimpleDateFormat("dd-MMM-yyyy HH:mm", app.getCurrentLocale());
                timeFormat.setTimeZone(timezone);

                org.opencrx.kernel.account1.cci2.MemberQuery memberFilter = accountPkg.createMemberQuery();
                memberFilter.thereExistsAccount().equalTo(account);
                for(Iterator m = accountSource.getMember(memberFilter).iterator(); m.hasNext(); ) {
                    org.opencrx.kernel.account1.jmi1.Member currentMember = (org.opencrx.kernel.account1.jmi1.Member)m.next();
                    String memberHref = "";
                    Action action = new ObjectReference(
                        currentMember,
                        app
                    ).getSelectObjectAction();
                    memberHref = "../../" + action.getEncodedHRef();
%>
                    <tr class="gridTableRowFull"><!-- 6 columns -->
                      <td><a href="<%= memberHref %>" target="_blank"><%= INDENT + (new ObjectReference(currentMember, app)).getTitle() %></a></td>
                      <td align="center"><img src="../../images/<%= currentMember.isDisabled() != null && currentMember.isDisabled().booleanValue() ? "" : "not" %>checked_r.gif" alt="" /></td>
                      <td align="center"><img src="../../images/<%= currentMember.getAccount() != null && currentMember.getAccount().isDisabled() != null && currentMember.getAccount().isDisabled().booleanValue() ? "" : "not" %>checked_r.gif" alt="" /></td>
                      <td align="left"><%= timeFormat.format(currentMember.getCreatedAt()) %></td>
                      <td align="left"><%= currentMember.getCreatedBy() %></td>
                      <td></td>
                    </tr>
<%
                }
                //member.refDelete();
                //pm.currentTransaction().commit();
              } catch (Exception e) {
                  new ServiceException(e).log();
                  try {
                      pm.currentTransaction().rollback();
                  } catch (Exception er) {}
              }
          }
%>
        </table>
        </td></tr></table>
      </form>

      <INPUT type="Button" name="Print.Button" tabindex="1010" value="Print" onClick="javascript:window.print();" />
      <INPUT type="Submit" name="Cancel.Button" tabindex="1020" value="<%= app.getTexts().getCancelTitle() %>" onClick="javascript:window.close();" />
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
