<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:        $Id: ManageGUIPermissionsWizard.jsp,v 1.9 2011/08/22 14:46:44 wfro Exp $
 * Description: ManageGUIPermissionsWizard
 * Revision:    $Revision: 1.9 $
 * Owner:       CRIXP AG, Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/08/22 14:46:44 $
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
org.opencrx.kernel.utils.*,
org.opencrx.kernel.backend.*,
org.opencrx.kernel.generic.*,
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.openmdx.base.exception.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*
" %>
<%!

	static List<String> getGenericPermissions(
		RefObject_1_0 obj,
		String elementName,
		boolean hasEditAction
	) {
		List<String> permissions = new ArrayList<String>();
		if(elementName.indexOf(":") < 0 || !elementName.startsWith(obj.refClass().refMofId())) {
			permissions.add(elementName + "|" + WebKeys.PERMISSION_REVOKE_SHOW);
			permissions.add(elementName + "|" + WebKeys.PERMISSION_GRANT_SHOW);
			if(hasEditAction) {
				permissions.add(elementName + "|" + WebKeys.PERMISSION_REVOKE_EDIT);
				permissions.add(elementName + "|" + WebKeys.PERMISSION_GRANT_EDIT);
			}
		}
		return permissions;
	}

	static List<String> getSpecificPermissions(
		RefObject_1_0 obj,
		String elementName,
		boolean hasEditAction
	) {
		List<String> permissions = new ArrayList<String>();
		if(elementName.indexOf(":") > 0) {
			if(elementName.startsWith(obj.refClass().refMofId())) {
				permissions.add(elementName + "|" + WebKeys.PERMISSION_REVOKE_SHOW);
				permissions.add(elementName + "|" + WebKeys.PERMISSION_GRANT_SHOW);
				if(hasEditAction) {
					permissions.add(elementName + "|" + WebKeys.PERMISSION_REVOKE_EDIT);
					permissions.add(elementName + "|" + WebKeys.PERMISSION_GRANT_EDIT);
				}
			} else {
				String specificElementName = obj.refClass().refMofId() + elementName.substring(elementName.lastIndexOf(":"));
				permissions.add(specificElementName + "|" + WebKeys.PERMISSION_REVOKE_SHOW);
				if(hasEditAction) {
					permissions.add(specificElementName + "|" + WebKeys.PERMISSION_REVOKE_EDIT);
				}
				permissions.add(specificElementName + "|" + WebKeys.PERMISSION_GRANT_SHOW);
				if(hasEditAction) {
					permissions.add(specificElementName + "|" + WebKeys.PERMISSION_GRANT_EDIT);
				}
			}
		}
		return permissions;
	}
	
	static boolean isStoredPermission(
		List<String> storedPermissions,
		String permission
	) {
		return storedPermissions.indexOf(permission) >= 0;
	}
	
	static void addPermission(
		org.openmdx.security.authorization1.jmi1.Policy policy,
		org.openmdx.security.realm1.jmi1.Role role,
		String permission
	) throws ServiceException {
		String[] p = permission.split("\\|");
		if(p.length == 2) {
			javax.jdo.PersistenceManager pm = javax.jdo.JDOHelper.getPersistenceManager(role);
			org.openmdx.security.realm1.cci2.PermissionQuery permissionQuery = (org.openmdx.security.realm1.cci2.PermissionQuery)pm.newQuery(org.openmdx.security.realm1.jmi1.Permission.class);
			permissionQuery.name().equalTo(p[0]);
			permissionQuery.thereExistsAction().equalTo(p[1]);
			Collection<org.openmdx.security.realm1.jmi1.Permission> permissions = role.getPermission(permissionQuery);
			if(permissions.isEmpty()) {
				org.openmdx.security.realm1.cci2.PrivilegeQuery privilegeQuery = (org.openmdx.security.realm1.cci2.PrivilegeQuery)pm.newQuery(org.openmdx.security.realm1.jmi1.Privilege.class);
				privilegeQuery.name().equalTo(p[0]);
				List<org.openmdx.security.realm1.jmi1.Privilege> privileges = policy.getPrivilege(privilegeQuery);
				org.openmdx.security.realm1.jmi1.Privilege privilege = null;
				if(privileges.isEmpty()) {
					privilege = pm.newInstance(org.openmdx.security.realm1.jmi1.Privilege.class);
					privilege.refInitialize(false, false);
					privilege.setName(p[0]);
					policy.addPrivilege(
						Base.getInstance().getUidAsString(),
						privilege
					);
				} else {
					privilege = privileges.iterator().next();
				}
				org.openmdx.security.realm1.jmi1.Permission newPermission = pm.newInstance(org.openmdx.security.realm1.jmi1.Permission.class);
				newPermission.refInitialize(false, false);
				newPermission.setName(p[0]);
				newPermission.getAction().add(p[1]);
				newPermission.setPrivilege(privilege);
				role.addPermission(
					Base.getInstance().getUidAsString(), 
					newPermission
				);
			}
		}
	}
	
	static void removePermission(
		org.openmdx.security.realm1.jmi1.Role role,
		String permission
	) {
		String[] p = permission.split("\\|");
		if(p.length == 2) {
			javax.jdo.PersistenceManager pm = javax.jdo.JDOHelper.getPersistenceManager(role);
			org.openmdx.security.realm1.cci2.PermissionQuery permissionQuery = (org.openmdx.security.realm1.cci2.PermissionQuery)pm.newQuery(org.openmdx.security.realm1.jmi1.Permission.class);
			permissionQuery.name().equalTo(p[0]);
			permissionQuery.thereExistsAction().equalTo(p[1]);
			Collection<org.openmdx.security.realm1.jmi1.Permission> permissions = role.getPermission(permissionQuery);
			for(org.openmdx.security.realm1.jmi1.Permission permissionToBeRemoved: permissions) {
				pm.deletePersistent(permissionToBeRemoved);
			}
		}
	}

	static class WizardViewState {
		
		// Generic permissions
		public List<String> genericPermissions = new ArrayList<String>();
		public List<String> removedGenericPermissions = new ArrayList<String>();
		public List<String> addedGenericPermissions = new ArrayList<String>();
		public List<String> currentGenericPermissions = new ArrayList<String>();

		// Specific permissions
		public List<String> specificPermissions = new ArrayList<String>();
		public List<String> removedSpecificPermissions = new ArrayList<String>();
		public List<String> addedSpecificPermissions = new ArrayList<String>();
		public List<String> currentSpecificPermissions = new ArrayList<String>();		
	}
	
	static class WizardState {
		
		public static String VIEW_OPERATION_PERMISSIONS = "Operations";
		public static String VIEW_FIELD_PERMISSIONS = "Fields";
		public static String VIEW_GRID_PERMISSIONS = "Grids";
		
		public WizardState(
		) {
			viewStates.put(VIEW_OPERATION_PERMISSIONS, new WizardViewState());
			viewStates.put(VIEW_FIELD_PERMISSIONS, new WizardViewState());
			viewStates.put(VIEW_GRID_PERMISSIONS, new WizardViewState());
		}
		
		public boolean isDirty(
		) {
			for(WizardViewState viewState: viewStates.values()) {
				if(
					!viewState.addedGenericPermissions.isEmpty() ||
					!viewState.addedSpecificPermissions.isEmpty() ||
					!viewState.removedGenericPermissions.isEmpty() ||
					!viewState.removedSpecificPermissions.isEmpty()
				) {
					return true;
				}
			}
			return false;
		}
		
		public String roleName = null;
		public final Map<String,WizardViewState> viewStates = new HashMap<String,WizardViewState>();
		
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
	String formName = "ManageGUIPermissionsForm";
	String wizardName = "ManageGUIPermissionsWizard.jsp";

	// Get Parameters
	String command = request.getParameter("Command");
	if(command == null) command = "";
	boolean actionApply = "Apply".equals(command);
	boolean actionCancel = "Cancel".equals(command);
	boolean actionAddGenericPermissions = "AddGenericPermissions".equals(command);
	boolean actionRemoveGenericPermissions = "RemoveGenericPermissions".equals(command);
	boolean actionAddSpecificPermissions = "AddSpecificPermissions".equals(command);
	boolean actionRemoveSpecificPermissions = "RemoveSpecificPermissions".equals(command);
	
	String viewName = request.getParameter("view");
	if(viewName == null) {
		viewName = WizardState.VIEW_FIELD_PERMISSIONS;
	}
	String roleName = request.getParameter("role");
	if(roleName == null) {
		roleName = "Public";
	}
	
	if(actionCancel) {
		session.removeAttribute(WizardState.class.getName());
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}	
%>
<!--
	<meta name="label" content="Manage GUI Permissions">
	<meta name="toolTip" content="Manage GUI Permissions">
	<meta name="targetType" content="_inplace">
	<meta name="forClass" content="org:openmdx:base:BasicObject">
	<meta name="forClass" content="org:opencrx:kernel:generic:CrxObject">
	<meta name="forClass" content="org:opencrx:kernel:home1:UserHome">
	<meta name="forClass" content="org:opencrx:kernel:Segment">
	<meta name="order" content="5555">
-->
<%
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
	org.openmdx.security.realm1.jmi1.Principal currentPrincipal = Utils.getRequestingPrincipal(pm, providerName, segmentName);
	boolean currentUserIsAdmin = currentPrincipal.refGetPath().getBase().equals(SecurityKeys.ADMIN_PRINCIPAL + SecurityKeys.ID_SEPARATOR + segmentName);

	WizardState wizardState = (WizardState)session.getAttribute(WizardState.class.getName());	
	org.openmdx.security.authorization1.jmi1.Policy policy = null;
	try {
		policy = SecureObject.getInstance().getPolicy(
			pm,
			providerName,
			segmentName
		);
	} catch(Exception e) {}
	if(currentUserIsAdmin && policy == null) {
		// Create segment-specific policy if it does not exist already
		pm.currentTransaction().begin();
		policy = Admin.getInstance().createPolicy(
			pm, 
			providerName, 
			segmentName
		);
		// Create role Public so at least one role is shown in role drop-down
		org.openmdx.security.realm1.jmi1.Role role = pm.newInstance(org.openmdx.security.realm1.jmi1.Role.class);
		role.refInitialize(false, false);
		role.setName("Public");
		role.setDescription(segmentName + "\\\\Public");
		policy.addRole(
			"Public",
			role
		);
		pm.currentTransaction().commit();
	}
	org.openmdx.security.realm1.jmi1.Role selectedRole = null;
	if(policy != null) {
		org.openmdx.security.realm1.cci2.RoleQuery roleQuery = (org.openmdx.security.realm1.cci2.RoleQuery)pm.newQuery(org.openmdx.security.realm1.jmi1.Role.class);
		roleQuery.name().equalTo(roleName);
		List<org.openmdx.security.realm1.jmi1.Role> roles = policy.getRole(roleQuery);
		if(!roles.isEmpty()) {
			selectedRole = roles.iterator().next();							
		}
	}
	if(actionApply) {
		String[] views = {WizardState.VIEW_FIELD_PERMISSIONS, WizardState.VIEW_GRID_PERMISSIONS, WizardState.VIEW_OPERATION_PERMISSIONS};
		pm.currentTransaction().begin();
		for(String view: views) {
			WizardViewState viewState = wizardState.viewStates.get(view);
			for(String permission: viewState.addedGenericPermissions) {
				addPermission(
					policy, 
					selectedRole, 
					permission
				);
			}
			for(String permission: viewState.removedGenericPermissions) {
				removePermission(
					selectedRole, 
					permission
				);
			}
			for(String permission: viewState.addedSpecificPermissions) {
				addPermission(
					policy, 
					selectedRole, 
					permission
				);
			}
			for(String permission: viewState.removedSpecificPermissions) {
				removePermission(
					selectedRole, 
					permission
				);
			}
		}
		pm.currentTransaction().commit();
		wizardState = null;
	}	
	if(wizardState == null || !roleName.equals(wizardState.roleName)) {
		session.setAttribute(
			WizardState.class.getName(),
			wizardState = new WizardState()
		);
		wizardState.roleName = roleName;
		if(selectedRole == null) {
			org.openmdx.security.realm1.cci2.RoleQuery roleQuery = (org.openmdx.security.realm1.cci2.RoleQuery)pm.newQuery(org.openmdx.security.realm1.jmi1.Role.class);
			roleQuery.orderByName().ascending();
			List<org.openmdx.security.realm1.jmi1.Role> roles = policy.getRole(roleQuery);
			if(!roles.isEmpty()) {
				selectedRole = roles.iterator().next();
			}
		}
		List<String> storedPermissions = new ArrayList<String>();
		if(selectedRole != null) {
			Collection<org.openmdx.security.realm1.jmi1.Permission> permissions = selectedRole.getPermission();
			for(org.openmdx.security.realm1.jmi1.Permission permission: permissions) {
				for(String action: permission.getAction()) {
					storedPermissions.add(permission.getPrivilege().getName() + "|" + action);
				}
			}
		}
		// Get ui elements
		ObjectView view = viewsCache.getView(requestId);
		if(view instanceof ShowObjectView) {		
			ShowObjectView showView = (ShowObjectView)view;
			// Operations
			WizardViewState viewState = wizardState.viewStates.get(WizardState.VIEW_OPERATION_PERMISSIONS);
			for(OperationPaneControl paneControl: showView.getShowInspectorControl().getOperationPaneControl()) {
				for(OperationTabControl tabControl: paneControl.getOperationTabControl()) {
					String elementName = tabControl.getQualifiedOperationName();
					for(String permission: getGenericPermissions(obj, elementName, true)) {
						if(isStoredPermission(storedPermissions, permission)) {
							viewState.currentGenericPermissions.add(permission);
						} else {
							viewState.genericPermissions.add(permission);
						}
					}
					for(String permission: getSpecificPermissions(obj, elementName, true)) {
						if(isStoredPermission(storedPermissions, permission)) {
							viewState.currentSpecificPermissions.add(permission);
						} else {
							viewState.specificPermissions.add(permission);
						}										
					}
				}
			}
			// Wizards
			for(WizardTabControl tabControl: showView.getShowInspectorControl().getWizardControl().getWizardTabControls()) {
				for(String permission: getGenericPermissions(obj, tabControl.getQualifiedOperationName(), true)) {
					if(isStoredPermission(storedPermissions, permission)) {
						viewState.currentGenericPermissions.add(permission);
					} else {
						viewState.genericPermissions.add(permission);
					}									
				}
			}
			// Fields
			viewState = wizardState.viewStates.get(WizardState.VIEW_FIELD_PERMISSIONS);
			for(AttributeTab attributeTab: showView.getAttributePane().getAttributeTab()) {						
				for(FieldGroup fieldGroup: attributeTab.getFieldGroup()) {
					// Field groups only have generic permissions
					String elementName = fieldGroup.getFieldGroupControl().getId();
					for(String permission: getSpecificPermissions(obj, elementName, false)) {
						if(isStoredPermission(storedPermissions, permission)) {
							viewState.currentSpecificPermissions.add(permission);
						} else {
							viewState.specificPermissions.add(permission);
						}
					}
					for(FieldGroupControl.Field field: fieldGroup.getFieldGroupControl().getFields()) {
						elementName = field.getField().getQualifiedFeatureName();
						for(String permission: getGenericPermissions(obj, elementName, true)) {
							if(isStoredPermission(storedPermissions, permission)) {
								viewState.currentGenericPermissions.add(permission);
							} else {
								viewState.genericPermissions.add(permission);
							}
						}
						for(String permission: getSpecificPermissions(obj, elementName, true)) {
							if(isStoredPermission(storedPermissions, permission)) {
								viewState.currentSpecificPermissions.add(permission);
							} else {
								viewState.specificPermissions.add(permission);
							}
						}
					}
				}
			}
			// Grids
			viewState = wizardState.viewStates.get(WizardState.VIEW_GRID_PERMISSIONS);
			for(ReferencePane referencePane: showView.getReferencePane()) {
				for(GridControl gridControl: referencePane.getReferencePaneControl().getGridControl()) {
					String elementName = gridControl.getQualifiedReferenceTypeName();
					for(String permission: getGenericPermissions(obj, elementName, true)) {
						if(isStoredPermission(storedPermissions, permission)) {
							viewState.currentGenericPermissions.add(permission);
						} else {
							viewState.genericPermissions.add(permission);
						}
					}
					for(String permission: getSpecificPermissions(obj, elementName, true)) {
						if(isStoredPermission(storedPermissions, permission)) {
							viewState.currentSpecificPermissions.add(permission);
						} else {
							viewState.specificPermissions.add(permission);
						}
					}
				}
			}
		}
	}
	WizardViewState viewState = wizardState.viewStates.get(viewName);
	if(actionAddGenericPermissions) {
		String[] selectedPermissions = request.getParameterValues("genericPermissions");
		if(selectedPermissions != null) {
			viewState.genericPermissions.removeAll(Arrays.asList(selectedPermissions));
			viewState.removedGenericPermissions.removeAll(Arrays.asList(selectedPermissions));
			viewState.addedGenericPermissions.addAll(Arrays.asList(selectedPermissions));
			viewState.currentGenericPermissions.addAll(Arrays.asList(selectedPermissions));
		}
	}
	else if(actionRemoveGenericPermissions) {
		String[] selectedPermissions = request.getParameterValues("currentGenericPermissions");
		if(selectedPermissions != null) {
			viewState.genericPermissions.addAll(Arrays.asList(selectedPermissions));
			viewState.removedGenericPermissions.addAll(Arrays.asList(selectedPermissions));
			viewState.addedGenericPermissions.removeAll(Arrays.asList(selectedPermissions));
			viewState.currentGenericPermissions.removeAll(Arrays.asList(selectedPermissions));
		}
	} else if(actionAddSpecificPermissions) {
		String[] selectedPermissions = request.getParameterValues("specificPermissions");
		if(selectedPermissions != null) {
			viewState.specificPermissions.removeAll(Arrays.asList(selectedPermissions));
			viewState.removedSpecificPermissions.removeAll(Arrays.asList(selectedPermissions));
			viewState.addedSpecificPermissions.addAll(Arrays.asList(selectedPermissions));
			viewState.currentSpecificPermissions.addAll(Arrays.asList(selectedPermissions));
		}
	} else if(actionRemoveSpecificPermissions) {
		String[] selectedPermissions = request.getParameterValues("currentSpecificPermissions");
		if(selectedPermissions != null) {
			viewState.specificPermissions.addAll(Arrays.asList(selectedPermissions));
			viewState.removedSpecificPermissions.addAll(Arrays.asList(selectedPermissions));
			viewState.addedSpecificPermissions.removeAll(Arrays.asList(selectedPermissions));
			viewState.currentSpecificPermissions.removeAll(Arrays.asList(selectedPermissions));
		}
	}
%>
<br />
<form id="<%= formName %>" name="<%= formName %>" accept-charset="UTF-8" method="POST" action="<%= servletPath %>">
	<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
	<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
	<input type="hidden" id="Command" name="Command" value="" />
	<table cellspacing="8" class="tableLayout">
		<tr>
			<td class="cellObject">
				<div class="panel" id="panel<%= formName %>" style="display: block">
					<h1 style="font-size:larger;">Manage GUI permissions</h1>
					<table>
						<tr>
							<td style="vertical-align:middle">Role:</td>
							<td style="vertical-align:middle">
								<select name="role" onchange="javascript:$('Refresh.Button').click();return false;">
<%
									org.openmdx.security.realm1.cci2.RoleQuery roleQuery = (org.openmdx.security.realm1.cci2.RoleQuery)pm.newQuery(org.openmdx.security.realm1.jmi1.Role.class);
									roleQuery.orderByName().ascending();
									List<org.openmdx.security.realm1.jmi1.Role> roles = policy.getRole(roleQuery);
									for(org.openmdx.security.realm1.jmi1.Role role: roles) {
%>
										<option value="<%= role.getName() %>" <%= roleName.equals(role.getName()) ? "selected" : "" %>><%= role.getName() %></option>
<%											
									}										
%>									
								</select>
							</td>
						</tr>
						<tr>
							<td style="vertical-align:middle">View:</td>
							<td style="vertical-align:middle">
								<input type="radio" name="view" <%= WizardState.VIEW_OPERATION_PERMISSIONS.equals(viewName) ? "checked" : "" %> value="<%= WizardState.VIEW_OPERATION_PERMISSIONS %>" onchange="javascript:$('Refresh.Button').click();return false;">Operations</input>
								<input type="radio" name="view" <%= WizardState.VIEW_FIELD_PERMISSIONS.equals(viewName) ? "checked" : "" %> value="<%= WizardState.VIEW_FIELD_PERMISSIONS %>" onchange="javascript:$('Refresh.Button').click();return false;">Fields</input>
								<input type="radio" name="view" <%= WizardState.VIEW_GRID_PERMISSIONS.equals(viewName) ? "checked" : "" %> value="<%= WizardState.VIEW_GRID_PERMISSIONS %>" onchange="javascript:$('Refresh.Button').click();return false;">Grids</input>
							</td>
						</tr>
					</table>
<%
					if(viewState != null) {
%>
						<table>
							<tr>
								<td>		
									<h2 style="font-size:larger;">Generic permissions:</h2>
									<h3>Available:</h3>													
									<select name="genericPermissions" id="genericPermissions" multiple style="font-family:Courier;font-size:11px;height:10em;width:50em;">
<%													
										for(String permission: viewState.genericPermissions) {
%>
											<option value="<%= permission %>"><%=  permission.replace("|", " | ") %></option>
<%					
										}
%>									
									</select>
								</td>
								<td style="vertical-align:middle">
									<input type="submit" class="abutton" name="RemoveGenericPermissions" value="&lt;" onclick="javascript:$('Command').value=this.name;" />
									<input type="submit" class="abutton" name="AddGenericPermissions" value="&gt;" onclick="javascript:$('Command').value=this.name;" />
								</td>
								<td>							
									<h2 style="font-size:larger;">&nbsp;</h2>
									<h3>Current:</h3>
									<select name="currentGenericPermissions" id="currentGenericPermissions" multiple style="font-family:Courier;font-size:11px;width:50em;height:10em;">
<%													
										for(String permission: viewState.currentGenericPermissions) {
%>
											<option value="<%= permission %>"><%=  permission.replace("|", " | ") %></option>
<%					
										}
%>									
									</select>
								</td>
							</tr>
						</table>
						<br />						
						<table>
							<tr>
								<td>
									<h2 style="font-size:larger;">Permissions for <i><%= obj.refClass().refMofId() %></i>:</h2>								
									<h3>Available:</h3>													
									<select name="specificPermissions" id="specificPermissions" multiple style="font-family:Courier;font-size:11px;width:50em;height:10em;">
<%													
										for(String permission: viewState.specificPermissions) {
%>
											<option value="<%= permission %>"><%=  permission.replace("|", " | ") %></option>
<%					
										}
%>									
									</select>
								</td>
								<td style="vertical-align:middle">
									<input type="submit" class="abutton" name="RemoveSpecificPermissions" value="&lt;" onclick="javascript:$('Command').value=this.name;" />
									<input type="submit" class="abutton" name="AddSpecificPermissions" value= "&gt;" onclick="javascript:$('Command').value=this.name;" />
								</td>
								<td>
									<h2 style="font-size:larger;">&nbsp;</h2>								
									<h3>Current:</h3>
									<select name="currentSpecificPermissions" id="currentSpecificPermissions" multiple style="font-family:Courier;font-size:11px;width:50em;height:10em;">
<%													
										for(String permission: viewState.currentSpecificPermissions) {
%>
											<option value="<%= permission %>"><%=  permission.replace("|", " | ") %></option>
<%					
										}
%>									
									</select>
								</td>
							</tr>
						</table>
<%
					}
%>
				</div>	
				<input type="submit" class="abutton" name="Refresh" id="Refresh.Button" tabindex="9000" value="<%= app.getTexts().getReloadText() %>" onclick="javascript:$('Command').value=this.name;" />
<%
				if(currentUserIsAdmin && wizardState.isDirty()) {
%>				
					<input type="submit" class="abutton" name="Apply" id="Apply.Button" tabindex="9010" value="Apply" onclick="javascript:$('Command').value=this.name;" />
<%
				}
%>
				<input type="submit" class="abutton" name="Cancel" tabindex="9020" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Command').value=this.name;" />
			</td>
		</tr>
	</table>
</form>
<script language="javascript" type="text/javascript">

	Event.observe('<%= formName %>', 'submit', function(event) {
		$('<%= formName %>').request({
			onFailure: function() { },
			onSuccess: function(t) {
				$('UserDialog').update(t.responseText);
			}
		});
		Event.stop(event);
	});
	
</script>
<%
if(pm != null) {
	pm.close();
}
%>
