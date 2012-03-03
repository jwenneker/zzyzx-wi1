<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: SegmentSetup.jsp,v 1.91 2011/12/18 22:45:12 wfro Exp $
 * Description: SegmentSetup
 * Revision:    $Revision: 1.91 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/12/18 22:45:12 $
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
org.openmdx.base.query.*,
org.openmdx.kernel.log.*,
org.opencrx.kernel.backend.*,
org.opencrx.kernel.generic.*,
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.openmdx.base.exception.*,
org.openmdx.base.text.conversion.*
" %>

<%!

	public org.opencrx.kernel.account1.jmi1.AccountFilterGlobal findAccountFilter(
		String accountFilterName,
		org.opencrx.kernel.account1.jmi1.Segment segment,
		javax.jdo.PersistenceManager pm
	) {
		org.opencrx.kernel.account1.cci2.AccountFilterGlobalQuery query =
		    (org.opencrx.kernel.account1.cci2.AccountFilterGlobalQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.AccountFilterGlobal.class);
		query.name().equalTo(accountFilterName);
		Collection accountFilters = segment.getAccountFilter(query);
		if(!accountFilters.isEmpty()) {
			return (org.opencrx.kernel.account1.jmi1.AccountFilterGlobal)accountFilters.iterator().next();
		}
		return null;
	}

	public org.opencrx.kernel.account1.jmi1.AddressFilterGlobal findAddressFilter(
		String accountFilterName,
		org.opencrx.kernel.account1.jmi1.Segment segment,
		javax.jdo.PersistenceManager pm
	) {
		org.opencrx.kernel.account1.cci2.AddressFilterGlobalQuery query =
		    (org.opencrx.kernel.account1.cci2.AddressFilterGlobalQuery)pm.newQuery(org.opencrx.kernel.account1.jmi1.AddressFilterGlobal.class);
		query.name().equalTo(accountFilterName);
		Collection addressFilters = segment.getAddressFilter(query);
		if(!addressFilters.isEmpty()) {
			return (org.opencrx.kernel.account1.jmi1.AddressFilterGlobal)addressFilters.iterator().next();
		}
		return null;
	}

	public org.opencrx.kernel.contract1.jmi1.ContractFilterGlobal findContractFilter(
		String contractFilterName,
		org.opencrx.kernel.contract1.jmi1.Segment segment,
		javax.jdo.PersistenceManager pm
	) {
		org.opencrx.kernel.contract1.cci2.ContractFilterGlobalQuery query =
		    (org.opencrx.kernel.contract1.cci2.ContractFilterGlobalQuery)pm.newQuery(org.opencrx.kernel.contract1.jmi1.ContractFilterGlobal.class);
		query.name().equalTo(contractFilterName);
		Collection contractFilters = segment.getContractFilter(query);
		if(!contractFilters.isEmpty()) {
			return (org.opencrx.kernel.contract1.jmi1.ContractFilterGlobal)contractFilters.iterator().next();
		}
		return null;
	}

	public org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal findActivityFilter(
		String activityFilterName,
		org.opencrx.kernel.activity1.jmi1.Segment segment,
		javax.jdo.PersistenceManager pm
	) {
		org.opencrx.kernel.activity1.cci2.ActivityFilterGlobalQuery query =
		    (org.opencrx.kernel.activity1.cci2.ActivityFilterGlobalQuery)pm.newQuery(org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal.class);
		query.name().equalTo(activityFilterName);
		Collection activityFilters = segment.getActivityFilter(query);
		if(!activityFilters.isEmpty()) {
			return (org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal)activityFilters.iterator().next();
		}
		return null;
	}

	public org.opencrx.kernel.home1.jmi1.ExportProfile findExportProfile(
		String exportProfileName,
		org.opencrx.kernel.home1.jmi1.UserHome userHome,
		javax.jdo.PersistenceManager pm
	) {
		org.opencrx.kernel.home1.cci2.ExportProfileQuery query =
		    (org.opencrx.kernel.home1.cci2.ExportProfileQuery)pm.newQuery(org.opencrx.kernel.home1.jmi1.ExportProfile.class);
		query.name().equalTo(exportProfileName);
		Collection exportProfiles = userHome.getExportProfile(query);
		if(!exportProfiles.isEmpty()) {
			return (org.opencrx.kernel.home1.jmi1.ExportProfile)exportProfiles.iterator().next();
		}
		return null;
	}

	public org.opencrx.kernel.document1.jmi1.Document findDocument(
		String documentName,
		org.opencrx.kernel.document1.jmi1.Segment segment
	) throws ServiceException {
		return Documents.getInstance().findDocument(
			documentName,
			segment
		);
	}

	public org.opencrx.kernel.home1.jmi1.QuickAccess findFavorite(
	   String favoriteName,
	   org.opencrx.kernel.home1.jmi1.UserHome userHome,
	   javax.jdo.PersistenceManager pm
	) {
		org.opencrx.kernel.home1.cci2.QuickAccessQuery query = (org.opencrx.kernel.home1.cci2.QuickAccessQuery)pm.newQuery(org.opencrx.kernel.home1.jmi1.QuickAccess.class);
		query.thereExistsName().equalTo(favoriteName);
		Collection favorites = userHome.getQuickAccess(query);
		if(!favorites.isEmpty()) {
			return (org.opencrx.kernel.home1.jmi1.QuickAccess)favorites.iterator().next();
		}
		return null;
	}

	public org.opencrx.kernel.document1.jmi1.DocumentFolder findDocumentFolder(
		String documentFolderName,
		org.opencrx.kernel.document1.jmi1.Segment segment
	) throws ServiceException {
		return Documents.getInstance().findDocumentFolder(
			documentFolderName,
			segment
		);
	}

	public org.opencrx.kernel.account1.jmi1.AccountFilterGlobal initAccountFilter(
		String filterName,
		org.opencrx.kernel.account1.jmi1.AccountFilterProperty[] filterProperties,
		javax.jdo.PersistenceManager pm,
		org.opencrx.kernel.account1.jmi1.Segment segment,
		List allUsers
	) {
		org.opencrx.kernel.account1.jmi1.AccountFilterGlobal accountFilter = findAccountFilter(
			filterName,
			segment,
			pm
		);
		if(accountFilter != null) return accountFilter;
		try {
			pm.currentTransaction().begin();
			accountFilter = pm.newInstance(org.opencrx.kernel.account1.jmi1.AccountFilterGlobal.class);
			accountFilter.refInitialize(false, false);
			accountFilter.setName(filterName);
			accountFilter.getOwningGroup().addAll(allUsers);
			segment.addAccountFilter(
				false,
				org.opencrx.kernel.backend.Accounts.getInstance().getUidAsString(),
				accountFilter
			);
			for(int i = 0; i < filterProperties.length; i++) {
				filterProperties[i].getOwningGroup().addAll(allUsers);
				accountFilter.addAccountFilterProperty(
					false,
					org.opencrx.kernel.backend.Accounts.getInstance().getUidAsString(),
					filterProperties[i]
				);
			}
			pm.currentTransaction().commit();
		}
		catch(Exception e) {
			new ServiceException(e).log();
			try {
				pm.currentTransaction().rollback();
			} catch(Exception e0) {}
		}
		return accountFilter;
	}

	public org.opencrx.kernel.account1.jmi1.AddressFilterGlobal initAddressFilter(
		String filterName,
		org.opencrx.kernel.account1.jmi1.AddressFilterProperty[] filterProperties,
		javax.jdo.PersistenceManager pm,
		org.opencrx.kernel.account1.jmi1.Segment segment,
		List allUsers
	) {
		org.opencrx.kernel.account1.jmi1.AddressFilterGlobal addressFilter = findAddressFilter(
			filterName,
			segment,
			pm
		);
		if(addressFilter != null) return addressFilter;
		try {
			pm.currentTransaction().begin();
			addressFilter = pm.newInstance(org.opencrx.kernel.account1.jmi1.AddressFilterGlobal.class);
			addressFilter.refInitialize(false, false);
			addressFilter.setName(filterName);
			addressFilter.getOwningGroup().addAll(allUsers);
			segment.addAddressFilter(
				false,
				org.opencrx.kernel.backend.Accounts.getInstance().getUidAsString(),
				addressFilter
			);
			for(int i = 0; i < filterProperties.length; i++) {
				filterProperties[i].getOwningGroup().addAll(allUsers);
				addressFilter.addAddressFilterProperty(
					false,
					org.opencrx.kernel.backend.Accounts.getInstance().getUidAsString(),
					filterProperties[i]
				);
			}
			pm.currentTransaction().commit();
		}
		catch(Exception e) {
			new ServiceException(e).log();
			try {
				pm.currentTransaction().rollback();
			} catch(Exception e0) {}
		}
		return addressFilter;
	}

	public org.opencrx.kernel.contract1.jmi1.ContractFilterGlobal initContractFilter(
		String filterName,
		org.opencrx.kernel.contract1.jmi1.ContractFilterProperty[] filterProperties,
		javax.jdo.PersistenceManager pm,
		org.opencrx.kernel.contract1.jmi1.Segment segment,
		List allUsers
	) {
		org.opencrx.kernel.contract1.jmi1.ContractFilterGlobal contractFilter = findContractFilter(
			filterName,
			segment,
			pm
		);
		if(contractFilter != null) return contractFilter;
		try {
			pm.currentTransaction().begin();
			contractFilter = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractFilterGlobal.class);
			contractFilter.refInitialize(false, false);
			contractFilter.setName(filterName);
			contractFilter.getOwningGroup().addAll(allUsers);
			segment.addContractFilter(
				false,
				org.opencrx.kernel.backend.Contracts.getInstance().getUidAsString(),
				contractFilter
			);
			for(int i = 0; i < filterProperties.length; i++) {
				filterProperties[i].getOwningGroup().addAll(allUsers);
				contractFilter.addFilterProperty(
					false,
					org.opencrx.kernel.backend.Contracts.getInstance().getUidAsString(),
					filterProperties[i]
				);
			}
			pm.currentTransaction().commit();
		}
		catch(Exception e) {
			new ServiceException(e).log();
			try {
				pm.currentTransaction().rollback();
			} catch(Exception e0) {}
		}
		return contractFilter;
	}

	public org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal initActivityFilter(
		String filterName,
		org.opencrx.kernel.activity1.jmi1.ActivityFilterProperty[] filterProperties,
		javax.jdo.PersistenceManager pm,
		org.opencrx.kernel.activity1.jmi1.Segment segment,
		List allUsers
	) {
		org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal activityFilter = findActivityFilter(
			filterName,
			segment,
			pm
		);
		if(activityFilter != null) return activityFilter;
		try {
			pm.currentTransaction().begin();
			activityFilter = pm.newInstance(org.opencrx.kernel.activity1.jmi1.ActivityFilterGlobal.class);
			activityFilter.refInitialize(false, false);
			activityFilter.setName(filterName);
			activityFilter.getOwningGroup().addAll(allUsers);
			segment.addActivityFilter(
				false,
				org.opencrx.kernel.backend.Activities.getInstance().getUidAsString(),
				activityFilter
			);
			for(int i = 0; i < filterProperties.length; i++) {
				filterProperties[i].getOwningGroup().addAll(allUsers);
				activityFilter.addFilterProperty(
					false,
					org.opencrx.kernel.backend.Activities.getInstance().getUidAsString(),
					filterProperties[i]
				);
			}
			pm.currentTransaction().commit();
		}
		catch(Exception e) {
			new ServiceException(e).log();
			try {
				pm.currentTransaction().rollback();
			} catch(Exception e0) {}
		}
		return activityFilter;
	}

	public org.opencrx.kernel.document1.jmi1.DocumentFolder initDocumentFolder(
		String documentFolderName,
		org.opencrx.kernel.document1.jmi1.Segment segment,
		List<org.opencrx.security.realm1.jmi1.PrincipalGroup> allUsers
	) throws ServiceException {
		return Documents.getInstance().initDocumentFolder(
			documentFolderName,
			segment,
			allUsers
		);
	}

	public org.opencrx.kernel.document1.jmi1.Document initDocument(
		String documentName,
		URL revisionURL,
		String revisionMimeType,
		String revisionName,
		org.opencrx.kernel.document1.jmi1.DocumentFolder documentFolder,
		org.opencrx.kernel.document1.jmi1.Segment segment,
		List<org.opencrx.security.realm1.jmi1.PrincipalGroup> allUsers
	) throws ServiceException {
		return Documents.getInstance().initDocument(
			documentName,
			documentName,
			revisionURL,
			revisionMimeType,
			revisionName,
			documentFolder,
			segment,
			allUsers
		);
	}

	public org.opencrx.kernel.home1.jmi1.ExportProfile initExportProfile(
		String exportProfileName,
		String[] forClass,
		String mimeType,
		String exportParams,
		org.opencrx.kernel.document1.jmi1.Document template,
		javax.jdo.PersistenceManager pm,
		org.opencrx.kernel.home1.jmi1.UserHome userHome,
		List allUsers
	) {
		org.opencrx.kernel.home1.jmi1.ExportProfile exportProfile = findExportProfile(
			exportProfileName,
			userHome,
			pm
		);
		if(exportProfile != null) return exportProfile;
		try {
			pm.currentTransaction().begin();
			exportProfile = pm.newInstance(org.opencrx.kernel.home1.jmi1.ExportProfile.class);
			exportProfile.refInitialize(false, false);
			exportProfile.setName(exportProfileName);
			exportProfile.getForClass().addAll(
				Arrays.asList(forClass)
			);
			exportProfile.setMimeType(mimeType);
			exportProfile.setExportParams(exportParams);
			exportProfile.setTemplate(template);
			exportProfile.getOwningGroup().addAll(allUsers);
			userHome.addExportProfile(
				false,
				org.opencrx.kernel.backend.Activities.getInstance().getUidAsString(),
				exportProfile
			);
			pm.currentTransaction().commit();
		}
		catch(Exception e) {
			try {
				pm.currentTransaction().rollback();
			} catch(Exception e0) {}
		}
		return exportProfile;
	}

	public org.opencrx.kernel.home1.jmi1.QuickAccess initFavorite(
		String favoriteName,
		org.openmdx.base.jmi1.ContextCapable reference,
		String iconKey,
		String action,
		javax.jdo.PersistenceManager pm,
		org.opencrx.kernel.home1.jmi1.UserHome userHome
	) {
		org.opencrx.kernel.home1.jmi1.QuickAccess favorite = findFavorite(
		    favoriteName,
			userHome,
			pm
		);
		if(favorite != null) return favorite;
		try {
			pm.currentTransaction().begin();
			favorite = pm.newInstance(org.opencrx.kernel.home1.jmi1.QuickAccess.class);
			favorite.refInitialize(false, false);
			favorite.setName(favoriteName);
			favorite.setReference(reference);
			favorite.setDescription(favoriteName);
			favorite.setIconKey(iconKey);
			favorite.setActionType((short)1); // Javascript
			favorite.setActionName(action);
			favorite.getOwningGroup().addAll(
				userHome.getOwningGroup()
			);
			userHome.addQuickAccess(
				false,
				org.opencrx.kernel.backend.Activities.getInstance().getUidAsString(),
				favorite
			);
			pm.currentTransaction().commit();
		}
		catch(Exception e) {
			try {
				pm.currentTransaction().rollback();
			} catch(Exception e0) {}
		}
		return favorite;
	}

	public org.opencrx.kernel.product1.jmi1.SalesTaxType findSalesTaxType(
		String name,
		org.opencrx.kernel.product1.jmi1.Segment segment,
		javax.jdo.PersistenceManager pm
	) {
		org.opencrx.kernel.product1.cci2.SalesTaxTypeQuery query =
		    (org.opencrx.kernel.product1.cci2.SalesTaxTypeQuery)pm.newQuery(org.opencrx.kernel.product1.jmi1.SalesTaxType.class);
		query.name().equalTo(name);
		Collection salesTaxTypes = segment.getSalesTaxType(query);
		if(!salesTaxTypes.isEmpty()) {
			return (org.opencrx.kernel.product1.jmi1.SalesTaxType)salesTaxTypes.iterator().next();
		}
		return null;
	}

	public org.opencrx.kernel.product1.jmi1.SalesTaxType initSalesTaxType(
		String name,
		java.math.BigDecimal rate,
		org.opencrx.kernel.product1.jmi1.Segment segment,
		javax.jdo.PersistenceManager pm
	) {
		org.opencrx.kernel.product1.jmi1.SalesTaxType salesTaxType = findSalesTaxType(
		    name,
			segment,
			pm
		);
		if(salesTaxType != null) return salesTaxType;
		try {
			pm.currentTransaction().begin();
			salesTaxType = pm.newInstance(org.opencrx.kernel.product1.jmi1.SalesTaxType.class);
			salesTaxType.refInitialize(false, false);
			salesTaxType.setName(name);
			salesTaxType.setRate(rate);
			salesTaxType.getOwningGroup().addAll(
				segment.getOwningGroup()
			);
			segment.addSalesTaxType(
				false,
				org.opencrx.kernel.backend.Contracts.getInstance().getUidAsString(),
				salesTaxType
			);
			pm.currentTransaction().commit();
		}
		catch(Exception e) {
			try {
				pm.currentTransaction().rollback();
			} catch(Exception e0) {}
		}
		return salesTaxType;
	}

%>

<%

	final String WIZARD_NAME = "SegmentSetup.jsp";
	final String OK = "<img src='../../images/checked.gif' />";
	final String MISSING = "<img src='../../images/cancel.gif' />";

	final String ACCOUNT_FILTER_NAME_ALL = "All Accounts";
  final String ACCOUNT_FILTER_NAME_NO_OR_BROKEN_VCARD = "Accounts with missing or broken vCard";
	final String ADDRESS_FILTER_NAME_ALL = "All Addresses";

	final String CONTRACT_FILTER_NAME_LEAD_FORECAST = "Lead Forecast";
	final String CONTRACT_FILTER_NAME_OPPORTUNITY_FORECAST = "Opportunity Forecast";
	final String CONTRACT_FILTER_NAME_QUOTE_FORECAST = "Quote Forecast";
	final String CONTRACT_FILTER_NAME_WON_LEADS = "Won Leads";
	final String CONTRACT_FILTER_NAME_WON_OPPORTUNITIES = "Won Opportunities";
	final String CONTRACT_FILTER_NAME_WON_QUOTES = "Won Quotes";

	final String ACTIVITY_FILTER_NAME_PHONE_CALLS = "Phone Calls";
	final String ACTIVITY_FILTER_NAME_NEW_ACTIVITIES = "New Activities";
	final String ACTIVITY_FILTER_NAME_OPEN_ACTIVITIES = "Open Activities";
	final String ACTIVITY_FILTER_NAME_MEETINGS = "Meetings";

	final String EXPORT_PROFILE_NAME_CONTRACT_LIST = "Contract List (Excel)";
	final String EXPORT_PROFILE_NAME_CONTRACT_WITH_POSITION_LIST = "Contract List with Positions (Excel)";
	final String EXPORT_PROFILE_NAME_ACTIVITY_LIST = "Activity List (Excel)";
	final String EXPORT_PROFILE_NAME_ACTIVITY_WITH_FOLLOWUP_LIST = "Activity List with Follow-Ups (Excel)";
	final String EXPORT_PROFILE_NAME_ACCOUNT_MEMBER_LIST = "Account Member List (Excel)";
	final String EXPORT_PROFILE_NAME_ACCOUNT_LIST = "Account List (Excel)";

	final String MAILMERGE_TEMPLATE_FOLDER_NAME = "Mail Merge Templates";
	final String MAILMERGE_TEMPLATE_NAME_LETTER = "Letter Template";
	final String MAILMERGE_TEMPLATE_NAME_LABEL = "Label Template";

	final String SALES_TAX_TYPE_NAME_8_5 = "Sales Tax 8.5%";

	final String REPORT_TEMPLATE_FOLDER_NAME = "Report Templates";
	final String REPORT_TEMPLATE_NAME_CONTRACT_LIST = "Contract Report Template";
	final String REPORT_TEMPLATE_NAME_CONTRACT_WITH_POSITION_LIST = "Contract with Positions Report Template";
	final String REPORT_TEMPLATE_NAME_ACTIVITY_LIST = "Activity Report Template";
	final String REPORT_TEMPLATE_NAME_ACTIVITY_WITH_FOLLOWUP_LIST = "Activity With Follow-Ups Report Template";
	final String REPORT_TEMPLATE_NAME_ACCOUNT_MEMBER_LIST = "Account Members Report Template";
	final String REPORT_TEMPLATE_NAME_ACCOUNT_LIST = "Account Report Template";

	final String FAVORITE_NAME_CREATE_ACTIVITY = "Create Activity";
	final String FAVORITE_NAME_CREATE_CONTACT = "Create Contact";
	final String FAVORITE_NAME_CREATE_CONTRACT = "Create Contract";
	final String FAVORITE_NAME_CREATE_LEAD = "Create Lead";
	final String FAVORITE_NAME_SCHEDULE_EVENT = "Schedule Event";

	// Init
	request.setCharacterEncoding("UTF-8");
	ApplicationContext app = (ApplicationContext)session.getValue(WebKeys.APPLICATION_KEY);
	ViewsCache viewsCache = (ViewsCache)session.getValue(WebKeys.VIEW_CACHE_KEY_SHOW);
	String requestId =  request.getParameter(Action.PARAMETER_REQUEST_ID);
	String objectXri = request.getParameter(Action.PARAMETER_OBJECTXRI);
	javax.jdo.PersistenceManager pm = app.getNewPmData();
	String requestIdParam = Action.PARAMETER_REQUEST_ID + "=" + requestId;
	String xriParam = Action.PARAMETER_OBJECTXRI + "=" + objectXri;
	if(objectXri == null || app == null || viewsCache.getView(requestId) == null) {
		session.setAttribute(WIZARD_NAME, null);
		response.sendRedirect(
			request.getContextPath() + "/" + WebKeys.SERVLET_NAME
		);
		return;
	}
	Texts_1_0 texts = app.getTexts();
	org.openmdx.portal.servlet.Codes codes = app.getCodes();

	// Get Parameters
	boolean actionSave = request.getParameter("Save.Button") != null;
	boolean actionCancel = request.getParameter("Cancel.Button") != null;
	String command = request.getParameter("command");
	RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);

	// Exit
	if("exit".equalsIgnoreCase(command)) {
		session.setAttribute(WIZARD_NAME, null);
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}

	org.opencrx.kernel.account1.jmi1.Segment accountSegment = Accounts.getInstance().getAccountSegment(pm, providerName, segmentName);
	org.opencrx.kernel.activity1.jmi1.Segment activitySegment = Activities.getInstance().getActivitySegment(pm, providerName, segmentName);
	org.opencrx.kernel.product1.jmi1.Segment productSegment = Products.getInstance().getProductSegment(pm, providerName, segmentName);
	org.opencrx.kernel.contract1.jmi1.Segment contractSegment = Contracts.getInstance().getContractSegment(pm, providerName, segmentName);
	org.opencrx.kernel.document1.jmi1.Segment documentSegment = Documents.getInstance().getDocumentSegment(pm, providerName, segmentName);
	org.opencrx.kernel.workflow1.jmi1.Segment workflowSegment = Workflows.getInstance().getWorkflowSegment(pm, providerName, segmentName);
	org.opencrx.kernel.home1.jmi1.UserHome userHome = (org.opencrx.kernel.home1.jmi1.UserHome)pm.getObjectById(
		app.getUserHomeIdentityAsPath()
	);

	boolean currentUserIsAdmin =
		app.getCurrentUserRole().equals(org.opencrx.kernel.generic.SecurityKeys.ADMIN_PRINCIPAL + org.opencrx.kernel.generic.SecurityKeys.ID_SEPARATOR + segmentName + "@" + segmentName);

	// Setup segment
	if(
		"setup".equalsIgnoreCase(command)
	) {
		try {
			pm.currentTransaction().begin();
			activitySegment.setAccessLevelBrowse((short)3);
			pm.currentTransaction().commit();
			org.opencrx.security.realm1.jmi1.PrincipalGroup publicPrincipalGroup =
				org.opencrx.kernel.backend.SecureObject.getInstance().initPrincipalGroup(
					"Public",
					pm,
					providerName,
					segmentName
				);
			org.opencrx.security.realm1.jmi1.PrincipalGroup usersPrincipalGroup =
				org.opencrx.kernel.backend.SecureObject.getInstance().initPrincipalGroup(
					"Users",
					pm,
					providerName,
					segmentName
				);
			org.opencrx.security.realm1.jmi1.PrincipalGroup administratorsPrincipalGroup =
				org.opencrx.kernel.backend.SecureObject.getInstance().initPrincipalGroup(
					"Administrators",
					pm,
					providerName,
					segmentName
				);
			List<org.opencrx.security.realm1.jmi1.PrincipalGroup> allUsers = new ArrayList<org.opencrx.security.realm1.jmi1.PrincipalGroup>();
			allUsers.add(usersPrincipalGroup);
			allUsers.add(administratorsPrincipalGroup);

			org.opencrx.kernel.backend.Workflows.getInstance().initWorkflows(
				pm,
				providerName,
				segmentName
			);
			org.opencrx.kernel.activity1.jmi1.ActivityProcess emailProcess =
				org.opencrx.kernel.backend.Activities.getInstance().initEmailProcess(
					pm,
					providerName,
					segmentName,
					allUsers,
					SecurityKeys.ACCESS_LEVEL_PRIVATE
				);
			org.opencrx.kernel.activity1.jmi1.ActivityProcessState emailProcessStateNew = null;
			org.opencrx.kernel.activity1.jmi1.ActivityProcessState emailProcessStateOpen = null;
			for(Iterator i = emailProcess.getState().iterator(); i.hasNext(); ) {
				org.opencrx.kernel.activity1.jmi1.ActivityProcessState state = (org.opencrx.kernel.activity1.jmi1.ActivityProcessState)i.next();
				if("New".equals(state.getName())) {
					emailProcessStateNew = state;
				}
				if("Open".equals(state.getName())) {
					emailProcessStateOpen = state;
				}
			}
			org.opencrx.kernel.activity1.jmi1.ActivityProcess bugAndFeatureTrackingProcess =
				org.opencrx.kernel.backend.Activities.getInstance().initBugAndFeatureTrackingProcess(
					pm,
					providerName,
					segmentName,
					allUsers,
					SecurityKeys.ACCESS_LEVEL_PRIVATE
				);
			org.opencrx.kernel.activity1.jmi1.ActivityProcessState bugAndFeatureTrackingProcessStateNew = null;
			org.opencrx.kernel.activity1.jmi1.ActivityProcessState bugAndFeatureTrackingProcessStateInProgress  = null;
			for(Iterator i = bugAndFeatureTrackingProcess.getState().iterator(); i.hasNext(); ) {
				org.opencrx.kernel.activity1.jmi1.ActivityProcessState state = (org.opencrx.kernel.activity1.jmi1.ActivityProcessState)i.next();
				if("New".equals(state.getName())) {
					bugAndFeatureTrackingProcessStateNew = state;
				}
				if("In Progress".equals(state.getName())) {
					bugAndFeatureTrackingProcessStateInProgress = state;
				}
			}
			org.opencrx.kernel.backend.Activities.getInstance().initCalendar(
				org.opencrx.kernel.backend.Activities.CALENDAR_NAME_DEFAULT_BUSINESS,
				pm,
				providerName,
				segmentName,
				allUsers,
				SecurityKeys.ACCESS_LEVEL_PRIVATE
			);
			// Activity Types
			org.opencrx.kernel.activity1.jmi1.ActivityType bugsAndFeaturesType =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityType(
					bugAndFeatureTrackingProcess,
					org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_BUGS_AND_FEATURES,
					Activities.ActivityClass.INCIDENT.getValue(),
					allUsers,
					SecurityKeys.ACCESS_LEVEL_PRIVATE
				);
			org.opencrx.kernel.activity1.jmi1.ActivityType emailsType =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityType(
					emailProcess,
					org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_EMAILS,
					Activities.ActivityClass.EMAIL.getValue(),
					allUsers,
					SecurityKeys.ACCESS_LEVEL_PRIVATE
				);
			org.opencrx.kernel.activity1.jmi1.ActivityType tasksType =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityType(
					bugAndFeatureTrackingProcess,
					org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_TASKS,
					Activities.ActivityClass.TASK.getValue(),
					allUsers,
					SecurityKeys.ACCESS_LEVEL_PRIVATE
				);
			org.opencrx.kernel.activity1.jmi1.ActivityType meetingsType =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityType(
					bugAndFeatureTrackingProcess,
					org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_MEETINGS,
					Activities.ActivityClass.MEETING.getValue(),
					allUsers,
					SecurityKeys.ACCESS_LEVEL_PRIVATE
				);
			org.opencrx.kernel.activity1.jmi1.ActivityType phoneCallsType =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityType(
					bugAndFeatureTrackingProcess,
					org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_PHONE_CALLS,
					Activities.ActivityClass.PHONE_CALL.getValue(),
					allUsers,
					SecurityKeys.ACCESS_LEVEL_PRIVATE
				);
			// Activity Trackers
			org.opencrx.kernel.activity1.jmi1.ActivityTracker bugsAndFeaturesTracker =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityTracker(
					org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_BUGS_AND_FEATURES,
					allUsers,
					pm,
					providerName,
					segmentName
				);
			org.opencrx.kernel.activity1.jmi1.ActivityTracker emailsTracker =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityTracker(
					org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_EMAILS,
					allUsers,
					pm,
					providerName,
					segmentName
				);
			org.opencrx.kernel.activity1.jmi1.ActivityTracker tasksTracker =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityTracker(
					org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_TASKS,
					allUsers,
					pm,
					providerName,
					segmentName
				);
			org.opencrx.kernel.activity1.jmi1.ActivityTracker pollsTracker =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityTracker(
					org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_POLLS,
					allUsers,
					pm,
					providerName,
					segmentName
				);
			org.opencrx.kernel.activity1.jmi1.ActivityTracker meetingRoomsTracker =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityTracker(
					org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_MEETING_ROOMS,
					allUsers,
					pm,
					providerName,
					segmentName
				);
			org.opencrx.kernel.activity1.jmi1.ActivityTracker meetingsTracker =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityTracker(
					org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_MEETINGS,
					allUsers,
					pm,
					providerName,
					segmentName
				);
			org.opencrx.kernel.activity1.jmi1.ActivityTracker phoneCallsTracker =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityTracker(
					org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_PHONE_CALLS,
					allUsers,
					pm,
					providerName,
					segmentName
				);
			org.opencrx.kernel.activity1.jmi1.ActivityTracker publicTracker =
				org.opencrx.kernel.backend.Activities.getInstance().initActivityTracker(
					org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_PUBLIC,
					Arrays.asList(new org.opencrx.security.realm1.jmi1.PrincipalGroup[]{publicPrincipalGroup}),
					pm,
					providerName,
					segmentName
				);
			// Activity Creators
			try {
				org.opencrx.kernel.backend.Activities.getInstance().initActivityCreator(
					org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_BUGS_AND_FEATURES,					
					bugsAndFeaturesType,
					Arrays.asList(new org.opencrx.kernel.activity1.jmi1.ActivityGroup[]{bugsAndFeaturesTracker}),
					allUsers
				);
				org.opencrx.kernel.backend.Activities.getInstance().initActivityCreator(
					org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_EMAILS,
					emailsType,
					Arrays.asList(new org.opencrx.kernel.activity1.jmi1.ActivityGroup[]{emailsTracker}),
					allUsers
				);
				org.opencrx.kernel.backend.Activities.getInstance().initActivityCreator(
					org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_TASKS,
					tasksType,
					Arrays.asList(new org.opencrx.kernel.activity1.jmi1.ActivityGroup[]{tasksTracker}),
					allUsers
				);
				org.opencrx.kernel.backend.Activities.getInstance().initActivityCreator(
					org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_POLLS,
					emailsType,
					Arrays.asList(new org.opencrx.kernel.activity1.jmi1.ActivityGroup[]{pollsTracker}),
					allUsers
				);
				org.opencrx.kernel.backend.Activities.getInstance().initActivityCreator(
					org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_MEETING_ROOMS,
					emailsType,
					Arrays.asList(new org.opencrx.kernel.activity1.jmi1.ActivityGroup[]{meetingRoomsTracker}),
					allUsers
				);
				org.opencrx.kernel.backend.Activities.getInstance().initActivityCreator(
					org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_MEETINGS,
					meetingsType,
					Arrays.asList(new org.opencrx.kernel.activity1.jmi1.ActivityGroup[]{meetingsTracker}),
					allUsers
				);
				org.opencrx.kernel.backend.Activities.getInstance().initActivityCreator(
					org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PHONE_CALLS,
					phoneCallsType,
					Arrays.asList(new org.opencrx.kernel.activity1.jmi1.ActivityGroup[]{phoneCallsTracker}),
					allUsers
				);
				org.opencrx.kernel.backend.Activities.getInstance().initActivityCreator(
					org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PUBLIC_EMAILS,
					emailsType,
					Arrays.asList(new org.opencrx.kernel.activity1.jmi1.ActivityGroup[]{publicTracker}),
					Arrays.asList(new org.opencrx.security.realm1.jmi1.PrincipalGroup[]{publicPrincipalGroup})
				);
				org.opencrx.kernel.backend.Activities.getInstance().initActivityCreator(
					org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PUBLIC_TASKS,
					tasksType,
					Arrays.asList(new org.opencrx.kernel.activity1.jmi1.ActivityGroup[]{publicTracker}),
					Arrays.asList(new org.opencrx.security.realm1.jmi1.PrincipalGroup[]{publicPrincipalGroup})
				);
				org.opencrx.kernel.backend.Activities.getInstance().initActivityCreator(
					org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PUBLIC_MEETINGS,
					meetingsType,
					Arrays.asList(new org.opencrx.kernel.activity1.jmi1.ActivityGroup[]{publicTracker}),
					Arrays.asList(new org.opencrx.security.realm1.jmi1.PrincipalGroup[]{publicPrincipalGroup})
				);
				org.opencrx.kernel.backend.Activities.getInstance().initActivityCreator(
					org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PUBLIC_PHONE_CALLS,
					phoneCallsType,
					Arrays.asList(new org.opencrx.kernel.activity1.jmi1.ActivityGroup[]{publicTracker}),
					Arrays.asList(new org.opencrx.security.realm1.jmi1.PrincipalGroup[]{publicPrincipalGroup})
				);
			} catch (Exception e) {
				new ServiceException(e).log();
				try {
					pm.currentTransaction().rollback();
					pm.currentTransaction().begin();
				} catch (Exception re) {}
			}
			
			// PricingRule
			org.opencrx.kernel.backend.Products.getInstance().initPricingRule(
				org.opencrx.kernel.backend.Products.PRICING_RULE_NAME_LOWEST_PRICE,
				org.opencrx.kernel.backend.Products.PRICING_RULE_DESCRIPTION_LOWEST_PRICE,
				org.opencrx.kernel.backend.Products.PRICING_RULE_GET_PRICE_LEVEL_SCRIPT_LOWEST_PRICE,
				pm,
				providerName,
				segmentName
			);
			// SalesTaxType
			initSalesTaxType(
			    SALES_TAX_TYPE_NAME_8_5,
			    new java.math.BigDecimal(8.5),
			    productSegment,
			    pm
			);
			// CalculationRule
			org.opencrx.kernel.backend.Contracts.getInstance().initCalculationRule(
				org.opencrx.kernel.backend.Contracts.CALCULATION_RULE_NAME_DEFAULT,
				null,
				org.opencrx.kernel.backend.Contracts.DEFAULT_GET_POSITION_AMOUNTS_SCRIPT,
				org.opencrx.kernel.backend.Contracts.DEFAULT_GET_CONTRACT_AMOUNTS_SCRIPT,
				pm,
				providerName,
				segmentName
			);

			// AccountFilter

			// ACCOUNT_FILTER_NAME_ALL
			initAccountFilter(
				ACCOUNT_FILTER_NAME_ALL,
				new org.opencrx.kernel.account1.jmi1.AccountFilterProperty[]{},
				pm,
				accountSegment,
				allUsers
			);

      // ACCOUNT_FILTER_NAME_NO_OR_BROKEN_VCARD
      org.opencrx.kernel.account1.jmi1.AccountQueryFilterProperty accountQueryFilterProperty = pm.newInstance(org.opencrx.kernel.account1.jmi1.AccountQueryFilterProperty .class);
      accountQueryFilterProperty.refInitialize(false, false);
      accountQueryFilterProperty.setName("external_link is null or vcard is null");
      accountQueryFilterProperty.setActive(new Boolean (true));
      accountQueryFilterProperty.setClause("object_id IN (\n" +
              "  select oocke1_account.object_id from oocke1_account, oocke1_account_\n" +
              "  where oocke1_account.object_id = oocke1_account_.object_id\n" +
              "  and oocke1_account_.idx=0\n" +
              "  and ((oocke1_account_.external_link is null) or (oocke1_account.vcard is null))\n" +
              "  )"
      );
      org.opencrx.kernel.account1.jmi1.AccountFilterGlobal accountFilterBrokenVcard = initAccountFilter(
    		ACCOUNT_FILTER_NAME_NO_OR_BROKEN_VCARD,
        new org.opencrx.kernel.account1.jmi1.AccountFilterProperty[]{
            accountQueryFilterProperty
        },
        pm,
        accountSegment,
        allUsers
      );

      // ADDRESS_FILTER_NAME_ALL
			initAddressFilter(
				ADDRESS_FILTER_NAME_ALL,
				new org.opencrx.kernel.account1.jmi1.AddressFilterProperty[]{},
				pm,
				accountSegment,
				allUsers
			);

			// ContractFilter

			// CONTRACT_FILTER_NAME_LEAD_FORECAST
			org.opencrx.kernel.contract1.jmi1.ContractTypeFilterProperty contractTypeFilterProperty = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractTypeFilterProperty.class);
			contractTypeFilterProperty.refInitialize(false, false);
			contractTypeFilterProperty.setName("Lead");
			contractTypeFilterProperty.setActive(new Boolean (true));
			contractTypeFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			contractTypeFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			contractTypeFilterProperty.getContractType().add("org:opencrx:kernel:contract1:Lead");
			org.opencrx.kernel.contract1.jmi1.ContractQueryFilterProperty contractQueryFilterProperty = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractQueryFilterProperty .class);
			contractQueryFilterProperty.refInitialize(false, false);
			contractQueryFilterProperty.setName("Estimated close date >= Today");
			contractQueryFilterProperty.setActive(new Boolean (true));
			contractQueryFilterProperty.setClause("(v.estimated_close_date >= now())");
			initContractFilter(
				CONTRACT_FILTER_NAME_LEAD_FORECAST,
				new org.opencrx.kernel.contract1.jmi1.ContractFilterProperty[]{
					contractTypeFilterProperty,
					contractQueryFilterProperty
				},
				pm,
				contractSegment,
				allUsers
			);

			// CONTRACT_FILTER_NAME_WON_LEADS
			contractTypeFilterProperty = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractTypeFilterProperty .class);
			contractTypeFilterProperty.refInitialize(false, false);
			contractTypeFilterProperty.setName("Lead");
			contractTypeFilterProperty.setActive(new Boolean (true));
			contractTypeFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			contractTypeFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			contractTypeFilterProperty.getContractType().add("org:opencrx:kernel:contract1:Lead");
			org.opencrx.kernel.contract1.jmi1.ContractStateFilterProperty contractStateFilterProperty = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractStateFilterProperty.class);
			contractStateFilterProperty.refInitialize(false, false);
			contractStateFilterProperty.setName("Won");
			contractStateFilterProperty.setActive(new Boolean (true));
			contractStateFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			contractStateFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			contractStateFilterProperty.getContractState().add(new Short((short)1110));
			initContractFilter(
				CONTRACT_FILTER_NAME_WON_LEADS,
				new org.opencrx.kernel.contract1.jmi1.ContractFilterProperty[]{
					contractTypeFilterProperty,
					contractStateFilterProperty
				},
				pm,
				contractSegment,
				allUsers
			);

			// CONTRACT_FILTER_NAME_OPPORTUNITY_FORECAST
			contractTypeFilterProperty = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractTypeFilterProperty .class);
			contractTypeFilterProperty.refInitialize(false, false);
			contractTypeFilterProperty.setName("Opportunity");
			contractTypeFilterProperty.setActive(new Boolean (true));
			contractTypeFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			contractTypeFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			contractTypeFilterProperty.getContractType().add("org:opencrx:kernel:contract1:Opportunity");
			contractQueryFilterProperty = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractQueryFilterProperty .class);
			contractQueryFilterProperty.refInitialize(false, false);
			contractQueryFilterProperty.setName("Estimated close date >= Today");
			contractQueryFilterProperty.setActive(new Boolean (true));
			contractQueryFilterProperty.setClause("(v.estimated_close_date >= now())");
			initContractFilter(
				CONTRACT_FILTER_NAME_OPPORTUNITY_FORECAST,
				new org.opencrx.kernel.contract1.jmi1.ContractFilterProperty[]{
					contractTypeFilterProperty,
					contractQueryFilterProperty
				},
				pm,
				contractSegment,
				allUsers
			);

			// CONTRACT_FILTER_NAME_WON_OPPORTUNITIES
			contractTypeFilterProperty = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractTypeFilterProperty .class);
			contractTypeFilterProperty.refInitialize(false, false);
			contractTypeFilterProperty.setName("Opportunity");
			contractTypeFilterProperty.setActive(new Boolean (true));
			contractTypeFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			contractTypeFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			contractTypeFilterProperty.getContractType().add("org:opencrx:kernel:contract1:Opportunity");
			contractStateFilterProperty = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractStateFilterProperty.class);
			contractStateFilterProperty.refInitialize(false, false);
			contractStateFilterProperty.setName("Won");
			contractStateFilterProperty.setActive(new Boolean (true));
			contractStateFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			contractStateFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			contractStateFilterProperty.getContractState().add(new Short((short)1210));
			initContractFilter(
				CONTRACT_FILTER_NAME_WON_OPPORTUNITIES,
				new org.opencrx.kernel.contract1.jmi1.ContractFilterProperty[]{
					contractTypeFilterProperty,
					contractStateFilterProperty
				},
				pm,
				contractSegment,
				allUsers
			);

			// CONTRACT_FILTER_NAME_QUOTE_FORECAST
			contractTypeFilterProperty = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractTypeFilterProperty .class);
			contractTypeFilterProperty.refInitialize(false, false);
			contractTypeFilterProperty.setName("Quote");
			contractTypeFilterProperty.setActive(new Boolean (true));
			contractTypeFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			contractTypeFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			contractTypeFilterProperty.getContractType().add("org:opencrx:kernel:contract1:Quote");
			contractQueryFilterProperty = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractQueryFilterProperty .class);
			contractQueryFilterProperty.refInitialize(false, false);
			contractQueryFilterProperty.setName("Estimated close date >= Today");
			contractQueryFilterProperty.setActive(new Boolean (true));
			contractQueryFilterProperty.setClause("(v.estimated_close_date >= now())");
			initContractFilter(
				CONTRACT_FILTER_NAME_QUOTE_FORECAST,
				new org.opencrx.kernel.contract1.jmi1.ContractFilterProperty[]{
					contractTypeFilterProperty,
					contractQueryFilterProperty
				},
				pm,
				contractSegment,
				allUsers
			);

			// CONTRACT_FILTER_NAME_WON_QUOTES
			contractTypeFilterProperty = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractTypeFilterProperty .class);
			contractTypeFilterProperty.refInitialize(false, false);
			contractTypeFilterProperty.setName("Quote");
			contractTypeFilterProperty.setActive(new Boolean (true));
			contractTypeFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			contractTypeFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			contractTypeFilterProperty.getContractType().add("org:opencrx:kernel:contract1:Quote");
			contractStateFilterProperty = pm.newInstance(org.opencrx.kernel.contract1.jmi1.ContractStateFilterProperty.class);
			contractStateFilterProperty.refInitialize(false, false);
			contractStateFilterProperty.setName("Won");
			contractStateFilterProperty.setActive(new Boolean (true));
			contractStateFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			contractStateFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			contractStateFilterProperty.getContractState().add(new Short((short)1310));
			initContractFilter(
				CONTRACT_FILTER_NAME_WON_QUOTES,
				new org.opencrx.kernel.contract1.jmi1.ContractFilterProperty[]{
					contractTypeFilterProperty,
					contractStateFilterProperty
				},
				pm,
				contractSegment,
				allUsers
			);

			// ActivityFilter

			// ACTIVITY_FILTER_NAME_PHONE_CALLS
			org.opencrx.kernel.activity1.jmi1.ActivityTypeFilterProperty activityTypeFilterProperty = pm.newInstance(org.opencrx.kernel.activity1.jmi1.ActivityTypeFilterProperty.class);
			activityTypeFilterProperty.refInitialize(false, false);
			activityTypeFilterProperty.setName("Phone Calls");
			activityTypeFilterProperty.setActive(new Boolean (true));
			activityTypeFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			activityTypeFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			activityTypeFilterProperty.getActivityType().add(phoneCallsType);
			initActivityFilter(
				ACTIVITY_FILTER_NAME_PHONE_CALLS,
				new org.opencrx.kernel.activity1.jmi1.ActivityFilterProperty[]{
					activityTypeFilterProperty
				},
				pm,
				activitySegment,
				allUsers
			);

			// ACTIVITY_FILTER_NAME_MEETINGS
			activityTypeFilterProperty = pm.newInstance(org.opencrx.kernel.activity1.jmi1.ActivityTypeFilterProperty.class);
			activityTypeFilterProperty.refInitialize(false, false);
			activityTypeFilterProperty.setName("Meetings");
			activityTypeFilterProperty.setActive(new Boolean (true));
			activityTypeFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			activityTypeFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			activityTypeFilterProperty.getActivityType().add(meetingsType);
			initActivityFilter(
				ACTIVITY_FILTER_NAME_MEETINGS,
				new org.opencrx.kernel.activity1.jmi1.ActivityFilterProperty[]{
					activityTypeFilterProperty
				},
				pm,
				activitySegment,
				allUsers
			);

			// ACTIVITY_FILTER_NAME_NEW_ACTIVITIES
			activityTypeFilterProperty = pm.newInstance(org.opencrx.kernel.activity1.jmi1.ActivityTypeFilterProperty.class);
			activityTypeFilterProperty.refInitialize(false, false);
			activityTypeFilterProperty.setName("All Types");
			activityTypeFilterProperty.setActive(new Boolean (true));
			activityTypeFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			activityTypeFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			activityTypeFilterProperty.getActivityType().add(bugsAndFeaturesType);
			activityTypeFilterProperty.getActivityType().add(meetingsType);
			activityTypeFilterProperty.getActivityType().add(emailsType);
			activityTypeFilterProperty.getActivityType().add(phoneCallsType);
			org.opencrx.kernel.activity1.jmi1.ActivityProcessStateFilterProperty activityProcessStateFilterProperty = pm.newInstance(org.opencrx.kernel.activity1.jmi1.ActivityProcessStateFilterProperty.class);
			activityProcessStateFilterProperty.refInitialize(false, false);
			activityProcessStateFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			activityProcessStateFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			activityProcessStateFilterProperty.getProcessState().add(bugAndFeatureTrackingProcessStateNew);
			activityProcessStateFilterProperty.getProcessState().add(emailProcessStateNew);
			initActivityFilter(
				ACTIVITY_FILTER_NAME_NEW_ACTIVITIES,
				new org.opencrx.kernel.activity1.jmi1.ActivityFilterProperty[]{
					activityTypeFilterProperty,
					activityProcessStateFilterProperty
				},
				pm,
				activitySegment,
				allUsers
			);

			// ACTIVITY_FILTER_NAME_OPEN_ACTIVITIES
			activityTypeFilterProperty = pm.newInstance(org.opencrx.kernel.activity1.jmi1.ActivityTypeFilterProperty.class);
			activityTypeFilterProperty.refInitialize(false, false);
			activityTypeFilterProperty.setName("All Types");
			activityTypeFilterProperty.setActive(new Boolean (true));
			activityTypeFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			activityTypeFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			activityTypeFilterProperty.getActivityType().add(bugsAndFeaturesType);
			activityTypeFilterProperty.getActivityType().add(meetingsType);
			activityTypeFilterProperty.getActivityType().add(emailsType);
			activityTypeFilterProperty.getActivityType().add(phoneCallsType);
			activityProcessStateFilterProperty = pm.newInstance(org.opencrx.kernel.activity1.jmi1.ActivityProcessStateFilterProperty.class);
			activityProcessStateFilterProperty.refInitialize(false, false);
			activityProcessStateFilterProperty.setName("Open");
			activityProcessStateFilterProperty.setActive(new Boolean (true));
			activityProcessStateFilterProperty.setFilterQuantor(Quantifier.THERE_EXISTS.code());
			activityProcessStateFilterProperty.setFilterOperator(ConditionType.IS_IN.code());
			activityProcessStateFilterProperty.getProcessState().add(bugAndFeatureTrackingProcessStateInProgress);
			activityProcessStateFilterProperty.getProcessState().add(emailProcessStateOpen);
			initActivityFilter(
				ACTIVITY_FILTER_NAME_OPEN_ACTIVITIES,
				new org.opencrx.kernel.activity1.jmi1.ActivityFilterProperty[]{
					activityTypeFilterProperty,
					activityProcessStateFilterProperty
				},
				pm,
				activitySegment,
				allUsers
			);

			// Mail Merge Templates
			org.opencrx.kernel.document1.jmi1.DocumentFolder templateFolder = initDocumentFolder(
				MAILMERGE_TEMPLATE_FOLDER_NAME,
				documentSegment,
				allUsers
			);
			org.opencrx.kernel.document1.jmi1.Document templateMailMergeLetter = initDocument(
				MAILMERGE_TEMPLATE_NAME_LETTER,
				getServletContext().getResource("/documents/Template_MailMergeLetter.rtf"),
				"text/rtf",
				MAILMERGE_TEMPLATE_NAME_LETTER,
				templateFolder,
				documentSegment,
				allUsers
			);
			org.opencrx.kernel.document1.jmi1.Document templateMailMergeEtiquette = initDocument(
				MAILMERGE_TEMPLATE_NAME_LABEL,
				getServletContext().getResource("/documents/Template_MailMergeLabel.rtf"),
				"text/rtf",
				MAILMERGE_TEMPLATE_NAME_LABEL,
				templateFolder,
				documentSegment,
				allUsers
			);

			// Report Templates
			templateFolder = initDocumentFolder(
				REPORT_TEMPLATE_FOLDER_NAME,
				documentSegment,
				allUsers
			);
			org.opencrx.kernel.document1.jmi1.Document templateContractList = initDocument(
				REPORT_TEMPLATE_NAME_CONTRACT_LIST,
				getServletContext().getResource("/documents/Template_ContractList.xls"),
				"application/x-excel",
				REPORT_TEMPLATE_NAME_CONTRACT_LIST,
				templateFolder,
				documentSegment,
				allUsers
			);
			org.opencrx.kernel.document1.jmi1.Document templateContractWithPositionList = initDocument(
				REPORT_TEMPLATE_NAME_CONTRACT_WITH_POSITION_LIST,
				getServletContext().getResource("/documents/Template_ContractWithPositionList.xls"),
				"application/x-excel",
				REPORT_TEMPLATE_NAME_CONTRACT_WITH_POSITION_LIST,
				templateFolder,
				documentSegment,
				allUsers
			);
			org.opencrx.kernel.document1.jmi1.Document templateActivityList = initDocument(
				REPORT_TEMPLATE_NAME_ACTIVITY_LIST,
				getServletContext().getResource("/documents/Template_ActivityList.xls"),
				"application/x-excel",
				REPORT_TEMPLATE_NAME_ACTIVITY_LIST,
				templateFolder,
				documentSegment,
				allUsers
			);
			org.opencrx.kernel.document1.jmi1.Document templateActivityWithFollowUpList = initDocument(
				REPORT_TEMPLATE_NAME_ACTIVITY_WITH_FOLLOWUP_LIST,
				getServletContext().getResource("/documents/Template_ActivityListWithFollowups.xls"),
				"application/x-excel",
				REPORT_TEMPLATE_NAME_ACTIVITY_WITH_FOLLOWUP_LIST,
				templateFolder,
				documentSegment,
				allUsers
			);
			org.opencrx.kernel.document1.jmi1.Document templateAccountMemberList = initDocument(
				REPORT_TEMPLATE_NAME_ACCOUNT_MEMBER_LIST,
				getServletContext().getResource("/documents/Template_MemberList.xls"),
				"application/x-excel",
				REPORT_TEMPLATE_NAME_ACCOUNT_MEMBER_LIST,
				templateFolder,
				documentSegment,
				allUsers
			);
			org.opencrx.kernel.document1.jmi1.Document templateAccountList = initDocument(
				REPORT_TEMPLATE_NAME_ACCOUNT_LIST,
				getServletContext().getResource("/documents/Template_FilteredAccountList.xls"),
				"application/x-excel",
				REPORT_TEMPLATE_NAME_ACCOUNT_LIST,
				templateFolder,
				documentSegment,
				allUsers
			);

			// ExportProfile
			initExportProfile(
				EXPORT_PROFILE_NAME_CONTRACT_LIST,
				new String[]{
					"org:opencrx:kernel:contract1:ContractFilterGlobal"
				},
				"application/x-excel",
					"xri:@openmdx:org.opencrx.kernel.code1/provider/" + providerName + "/segment/Root/valueContainer/currency\n" +
					"$\n" +
					"filteredContract,customer,salesRep,entry\n" +
					"!\n" +
					"ContractFilter[XRI;IDX;name;object_class],\n" +
					"FilteredContract[XRI;IDX;name;contractNumber;customer;salesRep;contractState;priority;contractCurrency;totalBaseAmount;totalDiscountAmount;totalAmount;totalTaxAmount;totalAmountIncludingTax;totalSalesCommission],\n" +
					"Account[XRI;IDX;fullName;aliasName;lastName;firstName;vcard;object_class],\n" +
					"Entry[XRI;IDX;ID;shortText;longText]",
				templateContractList,
				pm,
				userHome,
				allUsers
			);
			initExportProfile(
				EXPORT_PROFILE_NAME_CONTRACT_WITH_POSITION_LIST,
				new String[]{
					"org:opencrx:kernel:contract1:ContractFilterGlobal"
				},
				"application/x-excel",
					"xri:@openmdx:org.opencrx.kernel.code1/provider/" + providerName + "/segment/Root/valueContainer/currency\n" +
					"$\n" +
					"filteredContract,customer,salesRep,position,product,address,salesTaxType,entry\n" +
					"!\n" +
					"ContractFilter[XRI;IDX;name;object_class],\n" +
					"FilteredContract[XRI;IDX;name;contractNumber;customer;salesRep;contractState;priority;contractCurrency;totalBaseAmount;totalDiscountAmount;totalAmount;totalTaxAmount;totalAmountIncludingTax;totalSalesCommission],\n" +
					"Position[XRI;IDX;name;positionNumber;contractPositionState;quantity;pricePerUnit;pricingState;uom;priceUom;salesTaxType;discount;discountIsPercentage;salesCommission;salesCommissionIsPercentage;baseAmount;discountAmount;amount;taxAmount],\n" +
					"Product[XRI;IDX;name;productNumber],\n" +
					"Account[XRI;IDX;fullName;aliasName;lastName;firstName;vcard;object_class],\n" +
					"Address[XRI;IDX;isMain;usage;phoneNumberFull;postalCity;postalCode;postalCountry;postalState;postalAddressLine;postalStreet;emailAddress;webUrl;object_class]\n" +
					"SalesTaxType[XRI;IDX;name;rate],\n" +
					"Entry[XRI;IDX;ID;shortText;longText]",
				templateContractWithPositionList,
				pm,
				userHome,
				allUsers
			);
			initExportProfile(
				EXPORT_PROFILE_NAME_ACTIVITY_LIST,
				new String[]{
					"org:opencrx:kernel:activity1:AbstractFilterActivity",
					"org:opencrx:kernel:activity1:ActivityGroup",
				},
				"application/x-excel",
					"filteredActivity,assignedTo,address,processState,lastTransition\n" +
					"!\n" +
					"ActivityFilter[XRI;IDX;name;object_class],\n" +
					"ActivityTracker[XRI;IDX;name;object_class],\n" +
					"ActivityMilestone[XRI;IDX;name;object_class],\n" +
					"ActivityCategory[XRI;IDX;name;object_class],\n" +
					"FilteredActivity[XRI;IDX;activityNumber;name;scheduledStart;scheduledEnd;dueBy;priority;processState;assignedTo;lastTransition;percentComplete;object_class],\n" +
					"Account[XRI;IDX;fullName;aliasName;lastName;firstName;vcard;object_class]",
				templateActivityList,
				pm,
				userHome,
				allUsers
			);
			initExportProfile(
				EXPORT_PROFILE_NAME_ACTIVITY_WITH_FOLLOWUP_LIST,
				new String[]{
					"org:opencrx:kernel:activity1:AbstractFilterActivity",
					"org:opencrx:kernel:activity1:ActivityGroup"
				},
				"application/x-excel",
					"filteredActivity,followUp,assignedTo,address,processState,lastTransition\n" +
					"!\n" +
					"ActivityFilter[XRI;IDX;name;object_class],\n" +
					"ActivityTracker[XRI;IDX;name;object_class],\n" +
					"ActivityMilestone[XRI;IDX;name;object_class],\n" +
					"ActivityCategory[XRI;IDX;name;object_class],\n" +
					"FilteredActivity[XRI;IDX;activityNumber;name;scheduledStart;scheduledEnd;dueBy;priority;processState;assignedTo;lastTransition;percentComplete;object_class],\n" +
					"FollowUp[XRI;IDX;title;text;object_class],\n" +
					"Account[XRI;IDX;fullName;aliasName;lastName;firstName;vcard;object_class]",
				templateActivityWithFollowUpList,
				pm,
				userHome,
				allUsers
			);
			initExportProfile(
				EXPORT_PROFILE_NAME_ACCOUNT_MEMBER_LIST,
				new String[]{
					"org:opencrx:kernel:account1:Contact",
					"org:opencrx:kernel:account1:AbstractGroup"
				},
				"application/x-excel",
					"member,account,address[2]\n" +
					"!\n" +
					"Member[XRI;IDX;account],\n" +
					"Account[XRI;IDX;fullName;aliasName;lastName;firstName;vcard;object_class],\n" +
					"Address[XRI;IDX;isMain;usage;phoneNumberFull;postalCity;postalCode;postalCountry;postalState;postalAddressLine;postalStreet;emailAddress;webUrl;object_class]",
				templateAccountMemberList,
				pm,
				userHome,
				allUsers
			);
			initExportProfile(
				EXPORT_PROFILE_NAME_ACCOUNT_LIST,
				new String[]{
					"org:opencrx:kernel:account1:AbstractFilterAccount"
				},
				"application/x-excel",
					"filteredAccount,address\n" +
					"!\n" +
					"FilteredAccount[XRI;IDX;fullName;aliasName;lastName;firstName;vcard;object_class],\n" +
					"Address[XRI;IDX;isMain;usage;phoneNumberFull;postalCity;postalCode;postalCountry;postalState;postalAddressLine;postalStreet;emailAddress;webUrl;object_class]",
				templateAccountList,
				pm,
				userHome,
				allUsers
			);

			// Favorites
			initFavorite(
			    FAVORITE_NAME_CREATE_ACTIVITY,
			    activitySegment,
			    "ActivityManagement.gif",
			    "$('UserDialogWait').className='loading udwait';new Ajax.Updater('UserDialog', './wizards/en_US/CreateActivityWizard.jsp?" + Action.PARAMETER_REQUEST_ID + "=" + View.REQUEST_ID_TEMPLATE + "&" + Action.PARAMETER_OBJECTXRI + "=xri:@openmdx:org.opencrx.kernel.activity1/provider/" + providerName + "/segment/" + segmentName + "', {evalScripts: true});",
				pm,
				userHome
			);
			initFavorite(
			    FAVORITE_NAME_CREATE_CONTACT,
			    accountSegment,
			    "Account.gif",
			    "$('UserDialogWait').className='loading udwait';new Ajax.Updater('UserDialog', './wizards/en_US/CreateContactWizard.jsp?" + Action.PARAMETER_REQUEST_ID + "=" + View.REQUEST_ID_TEMPLATE + "&" + Action.PARAMETER_OBJECTXRI + "=xri:@openmdx:org.opencrx.kernel.account1/provider/" + providerName + "/segment/" + segmentName + "', {evalScripts: true});",
				pm,
				userHome
			);
			initFavorite(
			    FAVORITE_NAME_CREATE_CONTRACT,
			    contractSegment,
			    "SalesOrder.gif",
			    "$('UserDialogWait').className='loading udwait';new Ajax.Updater('UserDialog', './wizards/en_US/CreateContractWizard.jsp?" + Action.PARAMETER_REQUEST_ID + "=" + View.REQUEST_ID_TEMPLATE + "&" + Action.PARAMETER_OBJECTXRI + "=xri:@openmdx:org.opencrx.kernel.contract1/provider/" + providerName + "/segment/" + segmentName + "', {evalScripts: true});",
				pm,
				userHome
			);
			initFavorite(
			    FAVORITE_NAME_CREATE_LEAD,
			    contractSegment,
			    "Lead.gif",
			    "$('UserDialogWait').className='loading udwait';new Ajax.Updater('UserDialog', './wizards/en_US/CreateLeadWizard.jsp?" + Action.PARAMETER_REQUEST_ID + "=" + View.REQUEST_ID_TEMPLATE + "&" + Action.PARAMETER_OBJECTXRI + "=xri:@openmdx:org.opencrx.kernel.contract1/provider/" + providerName + "/segment/" + segmentName + "', {evalScripts: true});",
				pm,
				userHome
			);
			initFavorite(
			    FAVORITE_NAME_SCHEDULE_EVENT,
			    activitySegment,
			    "Meeting.gif",
			    "$('UserDialogWait').className='loading udwait';window.location.href='./wizards/en_US/ScheduleEventWizard.jsp?" + Action.PARAMETER_REQUEST_ID + "=" + View.REQUEST_ID_TEMPLATE + "&" + Action.PARAMETER_OBJECTXRI + "=xri:@openmdx:org.opencrx.kernel.activity1/provider/" + providerName + "/segment/" + segmentName + "';",
				pm,
				userHome
			);
		}
		catch(Exception e) {
			try {
				pm.currentTransaction().rollback();
			} catch(Exception e0) {}
			new ServiceException(e).log();
		}
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html dir="<%= texts.getDir() %>">
<head>
	<style type="text/css" media="all">
		body{font-family: Arial, Helvetica, sans-serif; padding: 0; margin:0;}
		h1{ margin: 0.5em 0em; font-size: 150%;}
		h2{ font-size: 130%; margin: 0.5em 0em; text-align: left;}
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
		.col1,
		.col2{float: left; width: 49.5%;}
	</style>
	<title>openCRX - Segment Setup Wizard</title>
	<meta name="label" content="Segment Setup">
	<meta name="toolTip" content="Segment Setup">
	<meta name="targetType" content="_self">
	<meta name="forClass" content="org:opencrx:kernel:home1:UserHome">
	<meta name="order" content="2100">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
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

	<form method="post" action="<%= WIZARD_NAME %>">
		<div class="col1">
			<fieldset>
				<legend>Activity and Incident Management</legend>
				<table>
					<tr>
						<td colspan="2"><h2>Activity Processes</h2></td>
					</tr>
					<tr>
						<td width="400px"><%= org.opencrx.kernel.backend.Activities.ACTIVITY_PROCESS_NAME_BUG_AND_FEATURE_TRACKING %></label></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityProcess(org.opencrx.kernel.backend.Activities.ACTIVITY_PROCESS_NAME_BUG_AND_FEATURE_TRACKING, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_PROCESS_NAME_EMAILS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityProcess(org.opencrx.kernel.backend.Activities.ACTIVITY_PROCESS_NAME_EMAILS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td colspan="2"><h2>Calendars</h2></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.CALENDAR_NAME_DEFAULT_BUSINESS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findCalendar(org.opencrx.kernel.backend.Activities.CALENDAR_NAME_DEFAULT_BUSINESS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td colspan="2"><h2>Activity Types</h2></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_BUGS_AND_FEATURES %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityType(org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_BUGS_AND_FEATURES, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_EMAILS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityType(org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_EMAILS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_TASKS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityType(org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_TASKS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_MEETINGS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityType(org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_MEETINGS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_PHONE_CALLS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityType(org.opencrx.kernel.backend.Activities.ACTIVITY_TYPE_NAME_PHONE_CALLS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td colspan="2"><h2>Activity Trackers</h2></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_BUGS_AND_FEATURES %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityTracker(org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_BUGS_AND_FEATURES, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_EMAILS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityTracker(org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_EMAILS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_TASKS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityTracker(org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_TASKS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_POLLS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityTracker(org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_POLLS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_MEETING_ROOMS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityTracker(org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_MEETING_ROOMS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_MEETINGS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityTracker(org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_MEETINGS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_PHONE_CALLS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityTracker(org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_PHONE_CALLS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_PUBLIC %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityTracker(org.opencrx.kernel.backend.Activities.ACTIVITY_TRACKER_NAME_PUBLIC, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td colspan="2"><h2>Activity Creators</h2></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_BUGS_AND_FEATURES %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityCreator(org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_BUGS_AND_FEATURES, activitySegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_EMAILS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityCreator(org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_EMAILS, activitySegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_TASKS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityCreator(org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_TASKS, activitySegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_POLLS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityCreator(org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_POLLS, activitySegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_MEETING_ROOMS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityCreator(org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_MEETING_ROOMS, activitySegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_MEETINGS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityCreator(org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_MEETINGS, activitySegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PHONE_CALLS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityCreator(org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PHONE_CALLS, activitySegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PUBLIC_EMAILS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityCreator(org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PUBLIC_EMAILS, activitySegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PUBLIC_TASKS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityCreator(org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PUBLIC_TASKS, activitySegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PUBLIC_MEETINGS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityCreator(org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PUBLIC_MEETINGS, activitySegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PUBLIC_PHONE_CALLS %></td>
						<td><%= org.opencrx.kernel.backend.Activities.getInstance().findActivityCreator(org.opencrx.kernel.backend.Activities.ACTIVITY_CREATOR_NAME_PUBLIC_PHONE_CALLS, activitySegment) == null ? MISSING : OK %></td>
					</tr>
				</table>
			</fieldset>
			<fieldset>
				<legend>Workflows and Topics</legend>
				<table>
					<tr>
						<td colspan="2"><h2>Topics</h2></td>
					</tr>
					<tr>
						<td width="400px"><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_ACCOUNT_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_ACCOUNT_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_ACTIVITY_FOLLOWUP_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_ACTIVITY_FOLLOWUP_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_ACTIVITY_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_ACTIVITY_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_ALERT_MODIFICATIONS_EMAIL %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_ALERT_MODIFICATIONS_EMAIL, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_ALERT_MODIFICATIONS_TWITTER %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_ALERT_MODIFICATIONS_TWITTER, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_BOOKING_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_BOOKING_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_COMPETITOR_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_COMPETITOR_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_COMPOUND_BOOKING_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_COMPOUND_BOOKING_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_INVOICE_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_INVOICE_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_LEAD_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_LEAD_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_OPPORTUNITY_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_OPPORTUNITY_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_ORGANIZATION_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_ORGANIZATION_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_PRODUCT_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_PRODUCT_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_QUOTE_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_QUOTE_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_REMINDER_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_REMINDER_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.TOPIC_NAME_SALES_ORDER_MODIFICATIONS %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findTopic(org.opencrx.kernel.backend.Workflows.TOPIC_NAME_SALES_ORDER_MODIFICATIONS, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td colspan="2"><h2>Workflows</h2></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.WORKFLOW_NAME_EXPORT_MAIL %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findWfProcess(org.opencrx.kernel.backend.Workflows.WORKFLOW_NAME_EXPORT_MAIL, workflowSegment, pm) == null && org.opencrx.kernel.backend.Workflows.getInstance().findWfProcess("org.opencrx.mail.workflow.ExportMailWorkflow", workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.WORKFLOW_NAME_PRINT_CONSOLE %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findWfProcess(org.opencrx.kernel.backend.Workflows.WORKFLOW_NAME_PRINT_CONSOLE, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.WORKFLOW_NAME_SEND_ALERT %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findWfProcess(org.opencrx.kernel.backend.Workflows.WORKFLOW_NAME_SEND_ALERT, workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.WORKFLOW_NAME_SEND_MAIL %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findWfProcess(org.opencrx.kernel.backend.Workflows.WORKFLOW_NAME_SEND_MAIL, workflowSegment, pm) == null && org.opencrx.kernel.backend.Workflows.getInstance().findWfProcess("org.opencrx.mail.workflow.SendMailWorkflow", workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.WORKFLOW_NAME_SEND_MAIL_NOTIFICATION %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findWfProcess(org.opencrx.kernel.backend.Workflows.WORKFLOW_NAME_SEND_MAIL_NOTIFICATION, workflowSegment, pm) == null && org.opencrx.kernel.backend.Workflows.getInstance().findWfProcess("org.opencrx.mail.workflow.SendMailNotificationWorkflow", workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= org.opencrx.kernel.backend.Workflows.WORKFLOW_NAME_SEND_DIRECT_MESSAGE_TWITTER %></td>
						<td><%= org.opencrx.kernel.backend.Workflows.getInstance().findWfProcess(org.opencrx.kernel.backend.Workflows.WORKFLOW_NAME_SEND_DIRECT_MESSAGE_TWITTER, workflowSegment, pm) == null && org.opencrx.kernel.backend.Workflows.getInstance().findWfProcess("org.opencrx.mail.workflow.SendMailNotificationWorkflow", workflowSegment, pm) == null ? MISSING : OK %></td>
					</tr>
				</table>
			</fieldset>
		</div>
		<div class="col2">
			<fieldset>
				<legend>Products</legend>
				<table>
					<tr>
						<td colspan="2"><h2>Pricing Rules</h2></td>
					</tr>
					<tr>
						<td width="400px"><%= org.opencrx.kernel.backend.Products.PRICING_RULE_NAME_LOWEST_PRICE %></td>
						<td><%= org.opencrx.kernel.backend.Products.getInstance().findPricingRule(org.opencrx.kernel.backend.Products.PRICING_RULE_NAME_LOWEST_PRICE, productSegment, pm) == null ? MISSING : OK %></td>
					</tr>
				</table>
				<table>
					<tr>
						<td colspan="2"><h2>Sales Tax Types</h2></td>
					</tr>
					<tr>
						<td width="400px"><%= SALES_TAX_TYPE_NAME_8_5 %></td>
						<td><%= findSalesTaxType(SALES_TAX_TYPE_NAME_8_5, productSegment, pm) == null ? MISSING : OK %></td>
					</tr>
				</table>
			</fieldset>
			<fieldset>
				<legend>Contracts</legend>
				<table>
					<tr>
						<td colspan="2"><h2>Calculation Rules</h2></td>
					</tr>
					<tr>
						<td width="400px"><%= org.opencrx.kernel.backend.Contracts.CALCULATION_RULE_NAME_DEFAULT %></td>
						<td><%= org.opencrx.kernel.backend.Contracts.getInstance().findCalculationRule(org.opencrx.kernel.backend.Contracts.CALCULATION_RULE_NAME_DEFAULT, contractSegment, pm) == null ? MISSING : OK %></td>
					</tr>
				</table>
			</fieldset>
			<fieldset>
				<legend>Reports</legend>
				<table>
					<tr>
						<td colspan="2"><h2>Account Filters</h2></td>
					</tr>
					<tr>
						<td width="400px"><%= ACCOUNT_FILTER_NAME_ALL %></td>
						<td><%= findAccountFilter(ACCOUNT_FILTER_NAME_ALL, accountSegment, pm) == null ? MISSING : OK %></td>
					</tr>
	        <tr>
	          <td width="400px"><%= ACCOUNT_FILTER_NAME_NO_OR_BROKEN_VCARD %></td>
	          <td><%= findAccountFilter(ACCOUNT_FILTER_NAME_NO_OR_BROKEN_VCARD, accountSegment, pm) == null ? MISSING : OK %></td>
	        </tr>
					<tr>
						<td width="400px"><%= ADDRESS_FILTER_NAME_ALL %></td>
						<td><%= findAddressFilter(ADDRESS_FILTER_NAME_ALL, accountSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td colspan="2"><h2>Contract Filters</h2></td>
					</tr>
					<tr>
						<td width="400px"><%= CONTRACT_FILTER_NAME_LEAD_FORECAST %></td>
						<td><%= findContractFilter(CONTRACT_FILTER_NAME_LEAD_FORECAST, contractSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= CONTRACT_FILTER_NAME_OPPORTUNITY_FORECAST %></td>
						<td><%= findContractFilter(CONTRACT_FILTER_NAME_OPPORTUNITY_FORECAST, contractSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= CONTRACT_FILTER_NAME_QUOTE_FORECAST %></td>
						<td><%= findContractFilter(CONTRACT_FILTER_NAME_QUOTE_FORECAST, contractSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= CONTRACT_FILTER_NAME_WON_LEADS %></td>
						<td><%= findContractFilter(CONTRACT_FILTER_NAME_WON_LEADS, contractSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= CONTRACT_FILTER_NAME_WON_OPPORTUNITIES %></td>
						<td><%= findContractFilter(CONTRACT_FILTER_NAME_WON_OPPORTUNITIES, contractSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= CONTRACT_FILTER_NAME_WON_QUOTES %></td>
						<td><%= findContractFilter(CONTRACT_FILTER_NAME_WON_QUOTES, contractSegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td colspan="2"><h2>Activity Filters</h2></td>
					</tr>
					<tr>
						<td><%= ACTIVITY_FILTER_NAME_PHONE_CALLS %></td>
						<td><%= findActivityFilter(ACTIVITY_FILTER_NAME_PHONE_CALLS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= ACTIVITY_FILTER_NAME_MEETINGS %></td>
						<td><%= findActivityFilter(ACTIVITY_FILTER_NAME_MEETINGS, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= ACTIVITY_FILTER_NAME_NEW_ACTIVITIES %></td>
						<td><%= findActivityFilter(ACTIVITY_FILTER_NAME_NEW_ACTIVITIES, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= ACTIVITY_FILTER_NAME_OPEN_ACTIVITIES %></td>
						<td><%= findActivityFilter(ACTIVITY_FILTER_NAME_OPEN_ACTIVITIES, activitySegment, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td colspan="2"><h2>Export Profiles</h2></td>
					</tr>
					<tr>
						<td><%= EXPORT_PROFILE_NAME_CONTRACT_LIST %></td>
						<td><%= findExportProfile(EXPORT_PROFILE_NAME_CONTRACT_LIST, userHome, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= EXPORT_PROFILE_NAME_CONTRACT_WITH_POSITION_LIST %></td>
						<td><%= findExportProfile(EXPORT_PROFILE_NAME_CONTRACT_WITH_POSITION_LIST, userHome, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= EXPORT_PROFILE_NAME_ACTIVITY_LIST %></td>
						<td><%= findExportProfile(EXPORT_PROFILE_NAME_ACTIVITY_LIST, userHome, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= EXPORT_PROFILE_NAME_ACTIVITY_WITH_FOLLOWUP_LIST %></td>
						<td><%= findExportProfile(EXPORT_PROFILE_NAME_ACTIVITY_WITH_FOLLOWUP_LIST, userHome, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= EXPORT_PROFILE_NAME_ACCOUNT_MEMBER_LIST %></td>
						<td><%= findExportProfile(EXPORT_PROFILE_NAME_ACCOUNT_MEMBER_LIST, userHome, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= EXPORT_PROFILE_NAME_ACCOUNT_LIST %></td>
						<td><%= findExportProfile(EXPORT_PROFILE_NAME_ACCOUNT_LIST, userHome, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td colspan="2"><h2>Mail Merge Templates</h2></td>
					</tr>
					<tr>
						<td><%= MAILMERGE_TEMPLATE_NAME_LETTER %></td>
						<td><%= findDocument(MAILMERGE_TEMPLATE_NAME_LETTER, documentSegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= MAILMERGE_TEMPLATE_NAME_LABEL %></td>
						<td><%= findDocument(MAILMERGE_TEMPLATE_NAME_LABEL, documentSegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td colspan="2"><h2>Report Templates</h2></td>
					</tr>
					<tr>
						<td><%= REPORT_TEMPLATE_NAME_CONTRACT_LIST %></td>
						<td><%= findDocument(REPORT_TEMPLATE_NAME_CONTRACT_LIST, documentSegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= REPORT_TEMPLATE_NAME_CONTRACT_WITH_POSITION_LIST %></td>
						<td><%= findDocument(REPORT_TEMPLATE_NAME_CONTRACT_WITH_POSITION_LIST, documentSegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= REPORT_TEMPLATE_NAME_ACTIVITY_LIST %></td>
						<td><%= findDocument(REPORT_TEMPLATE_NAME_ACTIVITY_LIST, documentSegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= REPORT_TEMPLATE_NAME_ACTIVITY_WITH_FOLLOWUP_LIST %></td>
						<td><%= findDocument(REPORT_TEMPLATE_NAME_ACTIVITY_WITH_FOLLOWUP_LIST, documentSegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= REPORT_TEMPLATE_NAME_ACCOUNT_MEMBER_LIST %></td>
						<td><%= findDocument(REPORT_TEMPLATE_NAME_ACCOUNT_MEMBER_LIST, documentSegment) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td><%= REPORT_TEMPLATE_NAME_ACCOUNT_LIST %></td>
						<td><%= findDocument(REPORT_TEMPLATE_NAME_ACCOUNT_LIST, documentSegment) == null ? MISSING : OK %></td>
					</tr>
				</table>
			</fieldset>
			<fieldset>
				<legend>Menues</legend>
				<table>
					<tr>
						<td colspan="2"><h2>Favorites</h2></td>
					</tr>
					<tr>
						<td width="400px"><%= FAVORITE_NAME_CREATE_ACTIVITY %></td>
						<td><%= findFavorite(FAVORITE_NAME_CREATE_ACTIVITY, userHome, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td width="400px"><%= FAVORITE_NAME_CREATE_CONTACT %></td>
						<td><%= findFavorite(FAVORITE_NAME_CREATE_CONTACT, userHome, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td width="400px"><%= FAVORITE_NAME_CREATE_CONTRACT %></td>
						<td><%= findFavorite(FAVORITE_NAME_CREATE_CONTRACT, userHome, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td width="400px"><%= FAVORITE_NAME_CREATE_LEAD %></td>
						<td><%= findFavorite(FAVORITE_NAME_CREATE_LEAD, userHome, pm) == null ? MISSING : OK %></td>
					</tr>
					<tr>
						<td width="400px"><%= FAVORITE_NAME_SCHEDULE_EVENT %></td>
						<td><%= findFavorite(FAVORITE_NAME_SCHEDULE_EVENT, userHome, pm) == null ? MISSING : OK %></td>
					</tr>
				</table>
			</fieldset>
		</div>
		<br />

		<div class="buttons">
			<input type="hidden" name="command" value="setup"/>
			<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
			<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
<%
			if(currentUserIsAdmin) {
%>
				<input type="submit" value="<%= app.getTexts().getSaveTitle() %>" />
<%
			}
%>
			<input type="button" value="<%= app.getTexts().getCloseText() %>" onclick="javascript:location.href='<%= WIZARD_NAME + "?" + requestIdParam + "&" + xriParam + "&command=exit" %>';" />
			<%= currentUserIsAdmin ? "" : "<h2>This wizard requires admin permissions.</h2>" %>
			<br>
		</div>
	</form>
  <br>
      </div> <!-- content -->
    </div> <!-- content-wrap -->
  </div> <!-- wrap -->
</div> <!-- container -->
</body>
</html>
<%
if(pm != null) {
	pm.close();
}
%>
