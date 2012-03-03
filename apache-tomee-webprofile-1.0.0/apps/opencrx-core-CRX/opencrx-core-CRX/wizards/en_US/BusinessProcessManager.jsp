<%@	page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     opencrx, http://www.opencrx.org/
 * Name:        $Id: BusinessProcessManager.jsp,v 1.9 2011/12/16 09:35:26 cmu Exp $
 * Description: Manage Activities of a Business Process
 * Revision:    $Revision: 1.9 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
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
javax.naming.Context,
javax.naming.InitialContext,
java.sql.*,
org.openmdx.base.accessor.jmi.cci.*,
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
org.openmdx.kernel.log.*,
org.opencrx.kernel.backend.*,
org.opencrx.kernel.generic.*,
org.opencrx.kernel.portal.*,
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.openmdx.base.exception.*,
org.openmdx.base.text.conversion.*,
org.openmdx.uses.org.apache.commons.fileupload.*
" %>

<%!

	enum Command {
		NA,
		CANCEL,
		DO_FOLLOWUP,
		PREPARE_FOLLOWUP,
		CREATE_FOLLOWUP,
		CANCEL_FOLLOWUP,
		FILE_UPLOAD,
		EMAIL_UPLOAD,
		RELOAD
	}

	final String ACCOUNT_CLASS = "org:opencrx:kernel:account1:Account";
	final String CONTACT_CLASS = "org:opencrx:kernel:account1:Contact";
	final String ACTIVITY_CLASS = "org:opencrx:kernel:activity1:Activity";
	final String ACTIVITYFOLLOWUP_CLASS = "org:opencrx:kernel:activity1:ActivityFollowUp";
	final String RESOURCE_CLASS = "org:opencrx:kernel:activity1:Resource";

	final String FORM_NAME_DOFOLLOWUP = "doFollowUpForm";
	final String UPLOAD_FILE_FIELD_NAME = "uploadFile";
	final String UPLOAD_EMAIL_FIELD_NAME = "uploadEmail";
	final short ACTIVITY_CLOSED = 20;
	final String CLICK_RELOAD = "$('Reload').click();";

	class ProcessNode {
		  private String name;
		  private org.opencrx.kernel.activity1.jmi1.ActivityProcess nodeActivityProcess;
		  private org.opencrx.kernel.activity1.jmi1.Activity nodeActivity;
		  private List<org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition> validTransitions;
		  private List<ProcessNode> subProcessNodes;
	};
	
	
	public ProcessNode addSubNode(
			ProcessNode node,
			String name,
			org.opencrx.kernel.activity1.jmi1.ActivityProcess nodeActivityProcess,
			org.opencrx.kernel.activity1.jmi1.Activity activity
	) {
			if (node != null) {
					if (node.subProcessNodes == null) {
							node.subProcessNodes = new ArrayList();
					}
					ProcessNode subNode = new ProcessNode();
					subNode.name = name;
					subNode.nodeActivityProcess = nodeActivityProcess;
					subNode.nodeActivity = activity;
					subNode.subProcessNodes = null;
					node.subProcessNodes.add(subNode);
					return subNode;
			}
			return null;		
	}
	

	public ProcessNode getSubProcessActivities( // finds all activities of the respective subprocess instances
			ProcessNode node,
			javax.jdo.PersistenceManager pm
	) {
			if (node == null || node.nodeActivity == null) {return node;}

			org.opencrx.kernel.activity1.jmi1.Activity1Package activityPkg = org.opencrx.kernel.utils.Utils.getActivityPackage(pm);
			org.opencrx.kernel.activity1.jmi1.Activity nodeActivity = node.nodeActivity;
			if (nodeActivity != null) {
					//System.out.println("node activity #" + nodeActivity.getActivityNumber());
					// try to determine dependent activities by following linkedFrom with type "isParentOf" (i.e. 100 - "isChildOf")
					org.opencrx.kernel.activity1.cci2.ActivityLinkFromQuery linkFromQuery = activityPkg.createActivityLinkFromQuery();
					linkFromQuery.activityLinkType().equalTo(new Short((short)(100 - Activities.ActivityLinkType.IS_CHILD_OF.getValue())));
					for (Iterator linkFrom = nodeActivity.getActivityLinkFrom(linkFromQuery).iterator(); linkFrom.hasNext();) {
							try {
									org.opencrx.kernel.activity1.jmi1.ActivityLinkFrom activityLinkFrom = (org.opencrx.kernel.activity1.jmi1.ActivityLinkFrom)linkFrom.next();
									if (activityLinkFrom.getLinkFrom() != null) {
											org.opencrx.kernel.activity1.jmi1.Activity linkedFromActivity = activityLinkFrom.getLinkFrom();
											//System.out.print("   dependent activity #" + linkedFromActivity.getActivityNumber()); 
											// determine matching subProcessNode
											org.opencrx.kernel.activity1.jmi1.ActivityProcess activityProcess = getControllingProcessOfActivity(linkedFromActivity);
											
											boolean abort = false;
											Iterator subProcessNodes = node.subProcessNodes.iterator();
											while (!abort && subProcessNodes.hasNext()) {
													try {
															ProcessNode currentNode = (ProcessNode)subProcessNodes.next();
															if (
																	currentNode.nodeActivityProcess != null &&
																	activityProcess != null &&
																	currentNode.nodeActivity == null &&
																	currentNode.nodeActivityProcess.refMofId().compareTo(activityProcess.refMofId()) == 0
															) {
																	// matching node found
																	String transitionName = null;
																	try {
																			// verify that context matches as well
																			transitionName = ((org.opencrx.kernel.activity1.jmi1.ActivityFollowUp)linkedFromActivity.getCreationContext()).getTransition().getName();
																	} catch (Exception e) {
																			new ServiceException(e).log();
																	}
																	if (currentNode.name != null && transitionName != null && transitionName.compareTo(currentNode.name) == 0) { 
																			//System.out.print("--------------matched activity #" + linkedFromActivity.getActivityNumber() + " to node '" + currentNode.name + "'" );
																			currentNode.nodeActivity = linkedFromActivity;
																			currentNode.validTransitions = getNextTransitionsOfActivity(linkedFromActivity, true, true, pm);
																			currentNode = getSubProcessActivities(currentNode, pm);
																			cleanTransitions(currentNode, pm);
																			abort = true;
																	}
															}
													} catch (Exception e) {
															new ServiceException(e).log();
													}
											}
											//System.out.println("");
									}
							} catch (Exception e) {
									new ServiceException(e).log();
							}
					}
			}
			return node;
	}
	

	public ProcessNode cleanTransitions(
			ProcessNode node,
			javax.jdo.PersistenceManager pm
	) {
			//System.out.println("cleanTransitions of node " + node.name);
			if (node.subProcessNodes != null && !node.subProcessNodes.isEmpty()) {
					int nIdx = node.subProcessNodes.size();
					while (nIdx > 0) {
							nIdx--;
							ProcessNode currentNode = (ProcessNode)node.subProcessNodes.get(nIdx);
							// eliminate creating transition of parent node
							if (node.validTransitions != null && !node.validTransitions.isEmpty()) {
								int idx = node.validTransitions.size();
								boolean match = false;
								while (!match && idx > 0) {
										idx--;
										org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition transition = (org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition)node.validTransitions.get(idx);
										if (transition.getName().compareTo(currentNode.name) == 0 && currentNode.nodeActivity != null) {
												//System.out.println("remove transition " + transition.getName() + " (matched node)");
												match = true;
												node.validTransitions.remove(idx);
										}
								}
							}
							
					}
			}
			return node;
	}
	

	public List<org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition> getNextTransitionsOfActivity(
			org.opencrx.kernel.activity1.jmi1.Activity activity,
			boolean onlySubActivityTransitions,
			boolean orderPercentCompleteIncreasing,
			javax.jdo.PersistenceManager pm
	) {
			List<org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition> transitions = new ArrayList();
			if (activity == null) {return transitions;}
			
			org.opencrx.kernel.activity1.jmi1.ActivityProcess activityProcess = null;
			try {
					activityProcess = activity.getActivityType().getControlledBy();
			} catch (Exception e) {
					System.out.println("activity #" + activity.getActivityNumber() + " with control process error");
					new ServiceException(e).log();
			}
			org.opencrx.kernel.activity1.jmi1.ActivityProcessState processState = null;
			try {
					processState = activity.getProcessState();
			} catch (Exception e) {
					System.out.println("activity #" + activity.getActivityNumber() + " with process state error");
					new ServiceException(e).log();
			}
			if (processState != null) {
					org.opencrx.kernel.activity1.jmi1.Activity1Package activityPkg = org.opencrx.kernel.utils.Utils.getActivityPackage(pm);
					if (onlySubActivityTransitions) {
							org.opencrx.kernel.activity1.cci2.SubActivityTransitionQuery subActivityTransitionQuery = activityPkg.createSubActivityTransitionQuery();
							subActivityTransitionQuery.thereExistsPrevState().equalTo(processState);
							if (orderPercentCompleteIncreasing) {
									subActivityTransitionQuery.orderByNewPercentComplete().ascending();
							} else {
									subActivityTransitionQuery.orderByNewPercentComplete().descending();
							}
							subActivityTransitionQuery.orderByName().ascending();
							for(Iterator t = activityProcess.getTransition(subActivityTransitionQuery).iterator(); t.hasNext();) {
									transitions.add((org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition)t.next());
							}
					} else {
							org.opencrx.kernel.activity1.cci2.ActivityProcessTransitionQuery activityProcessTransitionQuery = activityPkg.createActivityProcessTransitionQuery();
							activityProcessTransitionQuery.thereExistsPrevState().equalTo(processState);
							if (orderPercentCompleteIncreasing) {
									activityProcessTransitionQuery.orderByNewPercentComplete().ascending();
							} else {
									activityProcessTransitionQuery.orderByNewPercentComplete().descending();
							}
							activityProcessTransitionQuery.orderByName().ascending();
							for(Iterator t = activityProcess.getTransition(activityProcessTransitionQuery).iterator(); t.hasNext();) {
									transitions.add((org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition)t.next());
							}
						
					}
			}
			return transitions;
	}

	public ProcessNode getSubProcesses(
			ProcessNode processNode,
			org.opencrx.kernel.activity1.jmi1.ActivityProcess activityProcess,
			javax.jdo.PersistenceManager pm
	) {
			org.opencrx.kernel.activity1.jmi1.Activity1Package activityPkg = org.opencrx.kernel.utils.Utils.getActivityPackage(pm);
			if (activityProcess != null) {
					processNode.subProcessNodes = new ArrayList();
					
					// try to determine subNodes based on SubActivityTransitions
					org.opencrx.kernel.activity1.cci2.SubActivityTransitionQuery subActivityTransitionQuery = activityPkg.createSubActivityTransitionQuery();
					subActivityTransitionQuery.orderByNewPercentComplete().ascending();
					subActivityTransitionQuery.orderByName().ascending();
					for (Iterator t = activityProcess.getTransition(subActivityTransitionQuery).iterator(); t.hasNext();) {
							org.opencrx.kernel.activity1.jmi1.SubActivityTransition subActivityTransition =	(org.opencrx.kernel.activity1.jmi1.SubActivityTransition)t.next();
							try {
									org.opencrx.kernel.activity1.jmi1.ActivityProcess subActivityProcess = null;
									org.opencrx.kernel.activity1.jmi1.ActivityCreator activityCreator = subActivityTransition.getActivityCreator();
									if (activityCreator != null & activityCreator.getActivityType() != null && activityCreator.getActivityType().getControlledBy() != null) {
											subActivityProcess = activityCreator.getActivityType().getControlledBy();
									}
									ProcessNode subNode = addSubNode(processNode, (subActivityTransition.getName() != null ? subActivityTransition.getName() : "--"), subActivityProcess, null);
									if (subActivityProcess != null) {
											ProcessNode tempNode = getSubProcesses(subNode, subActivityProcess, pm);
									} else {
											// nothing to do
									}
							} catch (Exception e) {
									try {
										SysLog.warning("bad transition (" + subActivityTransition.getName() + ") with xri = " + subActivityTransition.refMofId(), e.getMessage());
									} catch (Exception el) {}
							}
					}
			}
			return processNode;
	}

	
	public org.opencrx.kernel.activity1.jmi1.ActivityProcess getControllingProcessOfActivity(
			org.opencrx.kernel.activity1.jmi1.Activity activity
	) {
			org.opencrx.kernel.activity1.jmi1.ActivityProcess activityProcess = null;
			try {
					if (
							activity != null &&
							activity.getActivityType() != null &&
							activity.getActivityType().getControlledBy() != null
					) {
						activityProcess = activity.getActivityType().getControlledBy();
					}
			} catch (Exception e) {
					new ServiceException(e).log();
			}
			return activityProcess;
	}
	
	
	public ProcessNode getProcess(
			org.opencrx.kernel.activity1.jmi1.Activity activity, // any activity belonging to the process
			javax.jdo.PersistenceManager pm
	) {
			org.opencrx.kernel.activity1.jmi1.Activity1Package activityPkg = org.opencrx.kernel.utils.Utils.getActivityPackage(pm);
			org.opencrx.kernel.activity1.jmi1.Activity topLevelActivity = activity;
			if (activity != null) {
					// try to determine top-level controlling activity by following linkedTo with type "isChildOf"
					org.opencrx.kernel.activity1.cci2.ActivityLinkToQuery linkToQuery = activityPkg.createActivityLinkToQuery();
					linkToQuery.activityLinkType().equalTo(new Short(Activities.ActivityLinkType.IS_CHILD_OF.getValue()));
					boolean abort = false;
					Collection linkTo = topLevelActivity.getActivityLinkTo(linkToQuery);
					while (!abort && topLevelActivity != null && !linkTo.isEmpty()) {
							try {
									org.opencrx.kernel.activity1.jmi1.ActivityLinkTo activityLinkTo = (org.opencrx.kernel.activity1.jmi1.ActivityLinkTo)linkTo.iterator().next(); // note: only 1 linkTo!
									if (activityLinkTo.getLinkTo() != null) {
											topLevelActivity = activityLinkTo.getLinkTo();
											linkTo = topLevelActivity.getActivityLinkTo(linkToQuery);
									} else {
											abort = true;
									}
							} catch (Exception e) {
									abort = true;
							}
					}
			}
	
			// determine process
			org.opencrx.kernel.activity1.jmi1.ActivityProcess activityProcess = getControllingProcessOfActivity(topLevelActivity);
			
			ProcessNode topNode = null;
			if (activityProcess != null) {
					topNode = new ProcessNode();
					topNode.name = activityProcess.getName() != null ? activityProcess.getName() : "--";
					topNode.subProcessNodes = null;
					topNode = getSubProcesses(topNode, activityProcess, pm);
					topNode.nodeActivity = topLevelActivity;
					topNode.validTransitions = getNextTransitionsOfActivity(topLevelActivity, true, true, pm);
					topNode = getSubProcessActivities(topNode, pm);
					topNode = cleanTransitions(topNode, pm);
			}
			return topNode;
	}

	public String getLastElementOfName(
			String name
	) {
			String result = "";
			if (name != null) {
					String[] splittedName = name.split(" - ");
					if (splittedName.length > 0) {
							result = splittedName[splittedName.length-1];
					}
			}
			//System.out.println(name + "  -->  " + result);
			return result;
	}

	public boolean doFollowUp(
			org.opencrx.kernel.activity1.jmi1.Activity activity,
			org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition transition,
			String title,
			String text,
			org.opencrx.kernel.account1.jmi1.Contact assignTo,
			javax.jdo.PersistenceManager pm
	) {
			boolean success = false;
			if(activity != null && transition != null) {
					org.opencrx.kernel.activity1.jmi1.ActivityDoFollowUpParams params = org.opencrx.kernel.utils.Utils.getActivityPackage(pm).createActivityDoFollowUpParams(
							assignTo, // assignTo
							text == null ? null : text.replace("\r\n", "\n"),
							title,
							transition
					);
					try {
							pm.currentTransaction().begin();
							org.opencrx.kernel.activity1.jmi1.ActivityDoFollowUpResult activityDoFollowUpResult = activity.doFollowUp(params);
							pm.currentTransaction().commit();
							if (activityDoFollowUpResult.getFollowUp() instanceof org.opencrx.kernel.activity1.jmi1.SubActivity) {
									pm.currentTransaction().begin();
									org.opencrx.kernel.activity1.jmi1.Activity subActivity = activityDoFollowUpResult.getFollowUp().getActivity();
									subActivity.setReportingAccount(activity.getReportingAccount());
									subActivity.setReportingContact(activity.getReportingContact());
									pm.currentTransaction().commit();
							}
							success = true;
					} catch(Exception e) {
							try {
									new ServiceException(e).log();
									pm.currentTransaction().rollback();
							} catch(Exception e0) {}
					}
			}
			return success;
	}

	public String getAccountEntry(
			org.opencrx.kernel.account1.jmi1.Account account,
			String caption,
			String title,
			UserDefinedView userView,
			ApplicationContext app
	) {
			String result = "<table class='accountEntryTable ' title='" + title  + "'>"
											+ "<caption>" + caption + "</caption>"
											+ "<tr><td class='accountName'>&nbsp;</td></tr>"
											+ "<tr><td class='accountPhone'>&nbsp;</td></tr>"
											+ "<tr><td class='accountPhone'>&nbsp;</td></tr>"
											+ "<tr><td class='accountEMail'>&nbsp;</td></tr>"
											+ "</table>";
			if (account != null) {
					try {
					    //DataBinding_1_0 postalHomeDataBinding = new PostalAddressDataBinding("[isMain=(boolean)true];usage=(short)400?zeroAsNull=true");
					    //DataBinding_1_0 faxHomeDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)430;automaticParsing=(boolean)true");
					    //DataBinding_1_0 phoneHomeDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)400;automaticParsing=(boolean)true");
					    //DataBinding_1_0 phoneOtherDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)1800;automaticParsing=(boolean)true");
					    DataBinding_1_0 phoneMobileDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)200;automaticParsing=(boolean)true");
					    DataBinding_1_0 mailBusinessDataBinding = new EmailAddressDataBinding("[isMain=(boolean)true];usage=(short)500;[emailType=(short)1]");
					    //DataBinding_1_0 mailHomeDataBinding = new EmailAddressDataBinding("[isMain=(boolean)true];usage=(short)400;[emailType=(short)1]");
					    //DataBinding_1_0 mailOtherDataBinding = new EmailAddressDataBinding("[isMain=(boolean)true];usage=(short)1800;[emailType=(short)1]");
					    //org.openmdx.portal.servlet.databinding.CompositeObjectDataBinding webPageBusinessDataBinding =
					    //    new org.openmdx.portal.servlet.databinding.CompositeObjectDataBinding("type=org:opencrx:kernel:account1:WebAddress;disabled=(boolean)false;[isMain=(boolean)true];usage=(short)500");
					    DataBinding_1_0 postalBusinessDataBinding = new PostalAddressDataBinding("[isMain=(boolean)true];usage=(short)500?zeroAsNull=true");
					    //DataBinding_1_0 faxBusinessDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)530;automaticParsing=(boolean)true");
					    DataBinding_1_0 phoneBusinessDataBinding = new PhoneNumberDataBinding("[isMain=(boolean)true];usage=(short)500;automaticParsing=(boolean)true");
					    
					    String businessPhone = (String)phoneBusinessDataBinding.getValue(account, "org:opencrx:kernel:account1:Account:address*Business!phoneNumberFull");
					    String mobilePhone = (String)phoneMobileDataBinding.getValue(account, "org:opencrx:kernel:account1:Account:address*Mobile!phoneNumberFull");
					    String businessEmail = (String)mailBusinessDataBinding.getValue(account, "org:opencrx:kernel:account1:Account:address*Business!emailAddress");
		
							String accountHref = null;
							Action action = new Action(
									SelectObjectAction.EVENT_ID,
									new Action.Parameter[]{
											new Action.Parameter(Action.PARAMETER_OBJECTXRI, account.refMofId())
									},
									"",
									true // enabled
								);
							accountHref = "../../" + action.getEncodedHRef();
		
							result = "<table class='accountEntryTable " + (account instanceof org.opencrx.kernel.account1.jmi1.LegalEntity ? "legalEntity" : "contact") + "' title='" + title  + "'>"
											+ "<caption>" + caption + "</caption>"
											+ "<tr><td class='accountName'><a href='" + accountHref + "' target='_blank' title='" + app.getHtmlEncoder().encode(new ObjectReference(account, app).getTitle(), false) + "'>"
											+		"<img src='../../images/" + (new ObjectReference(account, app)).getIconKey() + "' border='0' align='absbottom' style='padding-bottom:3px;' /> "
											+		"<b>" + (account.getFullName() != null ? account.getFullName() : "--") + (account.getExtString0() != null ? " (" + account.getExtString0() + ")" : "") + "</b></a>"
											+ "</td></tr>"
											+ "<tr><td class='accountPhone' title='" + userView.getFieldLabel(ACCOUNT_CLASS, "address*Business!phoneNumberFull", app.getCurrentLocaleAsIndex()) + "'>" + (businessPhone != null ? "<a href='tel:"    + businessPhone + "'>" + businessPhone + "</a>" : "--") + "</td></tr>"
											+ "<tr><td class='accountPhone' title='" + userView.getFieldLabel(ACCOUNT_CLASS, "address*Mobile!phoneNumberFull",   app.getCurrentLocaleAsIndex()) + "'>" + (mobilePhone   != null ? "<a href='tel:"    + mobilePhone   + "'>" + mobilePhone   + "</a>" : "--") + "</td></tr>"
											+ "<tr><td class='accountEMail' title='" + userView.getFieldLabel(ACCOUNT_CLASS, "address*Business!emailAddress",    app.getCurrentLocaleAsIndex()) + "'>" + (businessEmail != null ? "<a href='mailto:" + businessEmail + "'>" + businessEmail + "</a>" : "--") + "</td></tr>"
											+ "</table>";
					} catch (Exception e) {
							new ServiceException(e).log();
					}
			}
			return result;
	}
	
	public String getActivityEntry(
			ProcessNode processNode,
			String activityHref,
			UserDefinedView userView,
			javax.jdo.PersistenceManager pm,
			ApplicationContext app
	) {
			try {
					boolean hasValidTransitions = processNode.nodeActivity != null ? (getNextTransitionsOfActivity(processNode.nodeActivity, false, false, pm).size() > 0) : false;
					SimpleDateFormat activityDateFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm", app.getCurrentLocale());
					/*
					String history = "";

					org.opencrx.kernel.activity1.cci2.ActivityFollowUpQuery activityFollowUpFilter = org.opencrx.kernel.utils.Utils.getActivityPackage(pm).createActivityFollowUpQuery();
					activityFollowUpFilter.forAllDisabled().isFalse();
					activityFollowUpFilter.orderByCreatedAt().descending();
					for (
							Iterator j = processNode.nodeActivity.getFollowUp(activityFollowUpFilter).iterator();
							j.hasNext();
					) {
							try {
									// get ActivityFollowUp
									org.opencrx.kernel.activity1.jmi1.ActivityFollowUp activityFollowUp = (org.opencrx.kernel.activity1.jmi1.ActivityFollowUp)j.next();
									history += activityDateFormat.format(activityFollowUp.getCreatedAt()) + "  " 
													+ (activityFollowUp.getTitle() != null ? activityFollowUp.getTitle().replaceAll("&nbsp;", " ").replaceAll("#ERR", "N/P") : "") + "<br>";
							} catch (Exception e) {}
					}
					*/
					
					String result = "<table class='actEntryTable'><tr>";
					result += "<td class='actEntry noact'>" + processNode.name + "</td>";
					result += "<td class='normal actAssignedTo'>" + app.getHtmlEncoder().encode(new ObjectReference(processNode.nodeActivity.getAssignedTo(), app).getTitle(), false) + "</td>";
					result += "<td class='actModifiedAt'>" + processNode.nodeActivity.getPercentComplete() + "%</td>";
					result += "</tr><tr>";
					result += "<td colspan='2' class='normal actEntry'><div class='" + (hasValidTransitions ? "followUp actFollowUp" : "invisible") + "' title='" + app.getLabel(ACTIVITYFOLLOWUP_CLASS)  + "' onclick=\"javascript:"
					 + "$('ACTIVITY_XRI').value='" + (processNode.nodeActivity == null ? "" : processNode.nodeActivity.refMofId()) + "';"
					 + "$('command').value='PREPARE_FOLLOWUP';" + CLICK_RELOAD + "return false;\""
	         + ">" + (hasValidTransitions ? "<img src='../../images/next.gif'/>" : "") + "</div><div style='padding-top:2px;'>&nbsp;#" + processNode.nodeActivity.getActivityNumber() + ": " + getLastElementOfName(processNode.nodeActivity.getName()) + "</div></td>";
					result += "<td class='normal actModifiedAt'>" + activityDateFormat.format(processNode.nodeActivity.getModifiedAt());
					//result += history;
					result += "</td>";
					result += "</tr></table>";
					return result;
			} catch (Exception e) {
					new ServiceException(e).log();
			}
			return "";
	}
	
	public String produceTable(
			ProcessNode processNode,
			boolean showCompleteProcess,
			UserDefinedView userView,
			javax.jdo.PersistenceManager pm,
			ApplicationContext app
	) {
			String result = "";
			if (processNode != null) {
					try {
							String name = "";
							boolean isOpen = false; 
							String actStatus = "";
							String actTitle = "";
							String activityHref = null;
							if (processNode.nodeActivity != null) {
								//System.out.println("table activity #" + processNode.nodeActivity.getActivityNumber());
								isOpen = processNode.nodeActivity.getActivityState() < ACTIVITY_CLOSED;
								if (isOpen) {
										actStatus = "actopen";
								} else {
										actStatus = "actclosed";
								}
								actTitle = "title='" + app.getHtmlEncoder().encode(new ObjectReference(processNode.nodeActivity, app).getTitle(), false) + "'";
								Action action = new Action(
										SelectObjectAction.EVENT_ID,
										new Action.Parameter[]{
												new Action.Parameter(Action.PARAMETER_OBJECTXRI, processNode.nodeActivity.refMofId())
										},
										"",
										true // enabled
									);
								activityHref = "../../" + action.getEncodedHRef();
								name = "<a href='" + activityHref + "' target='_blank' " + actTitle + ">" + getLastElementOfName(processNode.nodeActivity.getName()) + "</a>";
							}
							
							boolean hasValidTransitions = processNode.nodeActivity != null ? (getNextTransitionsOfActivity(processNode.nodeActivity, false, false, pm).size() > 0) : false;;
							String title = "<td title='" + processNode.name + "' class='processName " + actStatus + "' rowspan='" + processNode.subProcessNodes.size() + "'>" 
															+ "<div class='processNode noact'>"
															+ processNode.name + "</div>"
															+ "<div class='" + (hasValidTransitions ? "followUp actFollowUp" : "invisible") + "' title='" + app.getLabel(ACTIVITYFOLLOWUP_CLASS)  + "' onclick=\"javascript:"
															+ "$('ACTIVITY_XRI').value='" + (processNode.nodeActivity == null ? "" : processNode.nodeActivity.refMofId()) + "';"
															+ "$('command').value='PREPARE_FOLLOWUP';" + CLICK_RELOAD + "return false;\""
											        + ">" + (hasValidTransitions ? "<img src='../../images/next.gif'/>" : "") + "</div>&nbsp;"
															+"<b>" + name + "</b>";
							if (processNode.validTransitions != null && !processNode.validTransitions.isEmpty()) {
									title += "<br><br>";
									for(org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition transition: processNode.validTransitions) {
											title += "<div class='transition' title='" + app.getTexts().getNewText() + ": " + transition.getName() + "' onclick=\"javascript:"
															 + "$('ACTIVITY_XRI').value='" + (processNode.nodeActivity == null ? "" : processNode.nodeActivity.refMofId()) + "';"
															 + "$('TRANSITION_XRI').value='" + transition.refMofId() + "';"
															 + "$('command').value='DO_FOLLOWUP';" + CLICK_RELOAD + "\""
											         + "><img src='../../images/Export.gif'/> " + transition.getName() + "</div>";
									}
							}
							
							title += "</td>";
							if (processNode.subProcessNodes != null && processNode.subProcessNodes.size() > 0) {
									result += "<table class='processTable'>";
									for (int r=0; r < processNode.subProcessNodes.size(); r++) {
											ProcessNode currentNode = (ProcessNode)processNode.subProcessNodes.get(r);
											result += "<tr>" + (r == 0 ? title : "");
											result += "<td>" + (showCompleteProcess || currentNode.nodeActivity != null ? produceTable(currentNode, showCompleteProcess, userView, pm, app) : "") + "</td></tr>";  
									}
									result += "</table>";
							} else {
									if (activityHref == null) {
											if (showCompleteProcess) {
													result += "<div class='processNode noact'>" + processNode.name + "</div>";
											}
									} else {
											result += "<div class='processNode " + (isOpen ? "actopen" : "actclosed") + "' " + actTitle + "><a href='" + activityHref + "' target='_blank'>" + getActivityEntry(processNode, activityHref, userView, pm, app) + "</a></div><b>";
									}
							}
					} catch (Exception e) {
							new ServiceException(e).log();
					}
			}
			return result;
	}
	
%>

<%

	final String WIZARD_NAME = "BusinessProcessManager.jsp";
	final String OK = "<img src='../../images/checked.gif' />";
	final String NOTCHECKED = "<img src='../../images/notchecked.gif' />";
	final String MISSING = "<img src='../../images/cancel.gif' />";
	//System.out.println("---------------------------------------------------------------------------------------------");

	// Init
	request.setCharacterEncoding("UTF-8");
	ApplicationContext app = (ApplicationContext)session.getValue(WebKeys.APPLICATION_KEY);
	ViewsCache viewsCache = (ViewsCache)session.getValue(WebKeys.VIEW_CACHE_KEY_SHOW);
	String requestId =	null;
	String objectXri = null;
	String commandAsString = null;
	List filecb = new ArrayList();

	if(FileUpload.isMultipartContent(request)) {
			try {
				Map parameterMap = request.getParameterMap();
	    	if(FileUpload.isMultipartContent(request)) {
					parameterMap = new HashMap();
					DiskFileUpload upload = new DiskFileUpload();
					upload.setHeaderEncoding("UTF-8");
					try {
						List items = upload.parseRequest(
							request,
							200,  // in-memory threshold. Content for fields larger than threshold is written to disk
							50000000, // max request size [overall limit]
						  app.getTempDirectory().getPath()
						);
						int fileCounter = 0;
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
									fileCounter++;
								  parameterMap.put(
										item.getFieldName(),
										new String[]{item.getName()}
								  );
								  String location = app.getTempFileName(fileCounter + "." + item.getFieldName(), "");
		
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
									System.out.println("location = " + location + " / name = " + item.getName().substring(sep + 1));
								  pw.close();
								}
						  }
						}
						int recount = 1;
						while (recount <= fileCounter) {
							boolean isChecked = parameterMap.get("filecb" + recount) != null;
							filecb.add(new Boolean(isChecked));
							recount++;
						}
					}
					catch(FileUploadException e) {
						SysLog.warning("can not upload file", e.getMessage());
					}
				}
				String[] requestIds = (String[])parameterMap.get(Action.PARAMETER_REQUEST_ID);
				requestId = (requestIds == null) || (requestIds.length == 0) ? "" : requestIds[0];
				String[] objectXris = (String[])parameterMap.get("xri");
				objectXri = (objectXris == null) || (objectXris.length == 0) ? "" : objectXris[0];
				String[] commandAsStrings = (String[])parameterMap.get("DOCcommand");
				commandAsString = (commandAsStrings == null) || (commandAsStrings.length == 0) ? "" : commandAsStrings[0];
			} catch (Exception e) {
				new ServiceException(e).log();
			}
	} else {
		requestId =	request.getParameter(Action.PARAMETER_REQUEST_ID);
		objectXri = request.getParameter(Action.PARAMETER_OBJECTXRI);
		commandAsString = request.getParameter("command");
		if (request.getParameter("Fcommand") != null && request.getParameter("Fcommand").length() > 0) {
				commandAsString = request.getParameter("Fcommand");
		}
	}
	
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
	if(commandAsString == null || commandAsString.length() == 0) commandAsString = Command.NA.toString();
	//System.out.println(commandAsString);
	Command command = Command.valueOf(commandAsString);
	RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);
	
	String ACTIVITY_XRI = (request.getParameter("ACTIVITY_XRI") == null ? "" : request.getParameter("ACTIVITY_XRI"));
	if (request.getParameter("FOLLOWUPACTIVITY_XRI") != null && request.getParameter("FOLLOWUPACTIVITY_XRI").length() > 0) {
			ACTIVITY_XRI = request.getParameter("FOLLOWUPACTIVITY_XRI");
			//System.out.println("FOLLOWUPACTIVITY_XRI = " + ACTIVITY_XRI);
	}
	String TRANSITION_XRI = (request.getParameter("TRANSITION_XRI") == null ? "" : request.getParameter("TRANSITION_XRI"));
	//System.out.println("ACTIVITY_XRI = " + ACTIVITY_XRI);
	//System.out.println("TRANSITION_XRI = " + TRANSITION_XRI);


	boolean showCompleteProcess = (request.getParameter("showCompleteProcess") != null) && (request.getParameter("showCompleteProcess").length() > 0);

	// Exit
	if(command == Command.CANCEL) {
		session.setAttribute(WIZARD_NAME, null);
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}

	if(command == Command.DO_FOLLOWUP) {
		org.opencrx.kernel.activity1.jmi1.Activity activity = null;
		org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition transition = null;
		try {
				activity = (org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(new Path(ACTIVITY_XRI));
				transition = (org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition)pm.getObjectById(new Path(TRANSITION_XRI));
		} catch (Exception e) {
				new ServiceException(e).log();
		}
		org.opencrx.kernel.account1.jmi1.Account customer = null;
		if (activity != null && activity.getReportingAccount() != null) {
				try {
						customer = activity.getReportingAccount();
				} catch (Exception e) {
						new ServiceException(e).log();
				}
		}
		boolean isOk = doFollowUp(
				activity,
				transition,
				(customer != null && customer.getFullName() != null && customer.getFullName().length() > 0 ? customer.getFullName() : "Kunde fehlt"),
				(transition != null && transition.getName() != null ? transition.getName() : "Name der Transition fehlt"),
				null,
				pm
		);
	}	

	org.opencrx.kernel.activity1.jmi1.Activity activity = null;
	if (obj instanceof org.opencrx.kernel.activity1.jmi1.Activity) {
			activity = (org.opencrx.kernel.activity1.jmi1.Activity)obj;
	}
	org.opencrx.kernel.account1.jmi1.Segment accountSegment = Accounts.getInstance().getAccountSegment(pm, providerName, segmentName);
	org.opencrx.kernel.activity1.jmi1.Segment activitySegment = Activities.getInstance().getActivitySegment(pm, providerName, segmentName);
	org.opencrx.kernel.home1.jmi1.Segment homeSegment = UserHomes.getInstance().getUserHomeSegment(pm, providerName, segmentName);
	org.opencrx.kernel.home1.jmi1.UserHome currentUserHome = (org.opencrx.kernel.home1.jmi1.UserHome)pm.getObjectById(
		app.getUserHomeIdentityAsPath()
	);
	org.openmdx.security.realm1.jmi1.Realm realm = org.opencrx.kernel.backend.SecureObject.getInstance().getRealm(
		pm,
		providerName,
		segmentName
	);

	UserDefinedView userView = new UserDefinedView(
		pm.getObjectById(new Path(objectXri)),
		app,
		viewsCache.getView(requestId)
	);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html dir="<%= texts.getDir() %>">
<head>
	<style type="text/css" media="all">
    .processTable {table-layout:fixed;border-collapse:collapse;border:1px 0px 0px 0px solid grey;width:100%;margin-left:3px;}
    .processTable TD {padding: 0px 5px 5px 5px; /* top right bottom left */;white-space:nowrap;border:1px 0px 1px 0px solid grey;vertical-align:top;}
    .processTable TD.processName {width:150px;overflow:hidden;}
    .actopen{background-color:#FFC700;}
    .actclosed{background-color:#C9FF00;}
    .noact{background-color:#849996;color:#eee;}
    .processNode{width:100%;padding:1px 1px 1px 3px;font-weight:bold;}
    .actEntryTable{table-layout:fixed;border-collapse:collapse;width:100%;}
    .actEntryTable TD {padding:1px 3px; /* top right bottom left */;vertical-align:middle;white-space:nowrap;text-overflow:ellipsis;overflow:hidden;border:1px solid grey;}
    .actEntry{width:220px;vertical-align:middle;}
    .actFollowUp{float:left;width:16px;text-align:center;padding:0px 2px;}
    .followUp{background-color:#E9E9E9;border:1px solid black;padding:1px;}
    .invisible{display:none;}
    .actHeader{}
    .actAssignedTo{width:180px;}
    .actModifiedAt{width:110px;text-align:right;}
    .normal{font-weight:normal;}
    .transition{overflow:hidden;cursor:pointer;}

		.accountEntryTable{float:left;margin:0px 5px 5px 5px; border-width: 1px;	border-spacing: 2px;border-style: solid; border-color: gray; border-collapse: separate;	width:161px;}
		.accountEntryTable caption {padding:2px 2px 1px 5px;background-color:#eee; font-weight: bold; text-align:left;}
		.accountEntryTable td {border-width: 1px;	padding: 1px;	border-style: none;	border-color: gray;	vertical-align:middle;white-space:nowrap;text-overflow:ellipsis;overflow:}

		.legalEntity{background-color:#99FFFF;}
		.contact{background-color:#FFFB99;}
		.salesRep{;}
		
		.fileDropTable{float:left;margin:0px 5px 5px 5px; border-width: 1px;	border-spacing: 2px;border-style: solid; border-color: #eee; border-collapse: separate;	width:120px;}
		.fileDropTable caption {padding:2px 2px 1px 5px;background-color:#eee; font-weight: bold; text-align:left;}
		.fileDropTable tbody {border-style:0px none white;}
		.fileDropTable td {border-width: 1px;	padding: 1px;	border-style: none;	border-color: gray;	vertical-align:middle;white-space:nowrap;text-overflow:ellipsis;overflow:}
		.fileDrop {border:1px solid #ddd;}

		.emailDropTable{float:left;margin:0px 5px 5px 5px; border-width: 1px;	border-spacing: 2px;border-style: solid; border-color: #eee; border-collapse: separate;	width:120px;}
		.emailDropTable caption {padding:2px 2px 1px 5px;background-color:#eee; font-weight: bold; text-align:left;}
		.emailDropTable tbody {border-style:0px none white;}
		.emailDropTable td {border-width: 1px;	padding: 1px;	border-style: none;	border-color: gray;	vertical-align:middle;white-space:nowrap;text-overflow:ellipsis;overflow:}
		.emailDrop {border:1px solid #ddd;}


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
			-webkit-border-radius: 4x;
			width: 120px;
			border: 1px solid silver;
		}
		.col1,
		.col2{float: left; width: 49.5%;}
		.small{font-size:8pt;}
		.smallheader{text-decoration:underline;}
		.principals tr td{vertical-align:top;white-space:nowrap;}
	</style>
	<title>openCRX - Business Process Manager</title>
	<meta name="label" content="Business Process Manager">
	<meta name="toolTip" content="Business Process Manager">
	<meta name="targetType" content="_self">
  <meta name="forClass" content="org:opencrx:kernel:activity1:Activity">
	<meta name="order" content="20">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<link href="../../_style/colors.css" rel="stylesheet" type="text/css">
	<link href="../../_style/calendar-small.css" rel="stylesheet" type="text/css">
	<script language="javascript" type="text/javascript" src="../../javascript/portal-all.js"></script>
	<!--[if lt IE 7]><script type="text/javascript" src="../../javascript/iehover-fix.js"></script><![endif]-->
	<script language="javascript" type="text/javascript" src="../../javascript/calendar/lang/calendar-<%= app.getCurrentLocaleAsString() %>.js"></script> <!-- calendar language -->
	<link rel="stylesheet" type="text/css" href="../../_style/ssf.css">
	<link rel="stylesheet" type="text/css" href="../../_style/n2default.css">
	<link rel='shortcut icon' href='../../images/favicon.ico' />
</head>
<body>
<div id="container">
	<div id="wrap">
		<div id="scrollheader" style="height:90px;">
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
			<div id="content" style="padding:0px 0.5em 0px 0.5em;">
<%
	int tabIndex = 3000;

// FollowUp
	if(activity != null && (command == Command.PREPARE_FOLLOWUP || command == Command.CREATE_FOLLOWUP)) {
			try {
					activity = (org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(new Path(ACTIVITY_XRI));
			} catch (Exception e) {
					new ServiceException(e).log();
			}
			
    	org.openmdx.ui1.jmi1.FormDefinition doFollowUpFormDefinition = app.getUiFormDefinition(FORM_NAME_DOFOLLOWUP);
    	org.openmdx.portal.servlet.control.FormControl doFollowUpForm = new org.openmdx.portal.servlet.control.FormControl(
    		doFollowUpFormDefinition.refGetPath().getBase(),
    		app.getCurrentLocaleAsString(),
    		app.getCurrentLocaleAsIndex(),
    		app.getUiContext(),
    		doFollowUpFormDefinition
    	);

      Map formValues = new HashMap();
      doFollowUpForm.updateObject(
    		request.getParameterMap(),
    		formValues,
    		app,
    		pm
    	);

			// get additional parameters
			boolean isFirstCall = request.getParameter("isFirstCall") == null; // used to properly initialize various options
			doFollowUpForm.getFieldGroupControl();
			if (isFirstCall) {
				// populate form fields related to activity with activity's attribute values
				formValues.put("org:opencrx:kernel:activity1:Activity:assignedTo", activity.getAssignedTo() == null ? null : activity.getAssignedTo().refGetPath());
				formValues.put("org:opencrx:kernel:activity1:Activity:description", activity.getDescription());
				formValues.put("org:opencrx:kernel:activity1:Activity:location", activity.getLocation());
				formValues.put("org:opencrx:kernel:activity1:Activity:priority", activity.getPriority());
				formValues.put("org:opencrx:kernel:activity1:Activity:dueBy", activity.getDueBy());
			}
	
			if(request.getParameter("resourceContact") != null) {
				org.opencrx.kernel.account1.jmi1.Contact resourceContact = null;
				try {
					resourceContact = (org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(new Path(request.getParameter("resourceContact")));
			 	} catch (Exception e) {}
			 	if (resourceContact != null && request.getParameter("fetchResourceContact") != null && request.getParameter("fetchResourceContact").length() > 0) {
					formValues.put("org:opencrx:kernel:activity1:Activity:assignedTo", resourceContact.refGetPath());
			 	}
			}
		 	
 	    org.opencrx.kernel.account1.jmi1.Contact assignedTo = null;
 	    try {
 	    	assignedTo = formValues.get("org:opencrx:kernel:activity1:Activity:assignedTo") != null ?
	 	    	(org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(
	 	    		formValues.get("org:opencrx:kernel:activity1:Activity:assignedTo")
	 	    	) : null;
 	    } catch (Exception e) {}

			if(command == Command.CREATE_FOLLOWUP) {
    	    // doFollowUp
    	    org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition transition =
            	(org.opencrx.kernel.activity1.jmi1.ActivityProcessTransition)pm.getObjectById(
            		formValues.get("org:opencrx:kernel:activity1:ActivityDoFollowUpParams:transition")
            	);
    	    String followUpTitle = (String)formValues.get("org:opencrx:kernel:activity1:ActivityDoFollowUpParams:followUpTitle");
    	    String followUpText = (String)formValues.get("org:opencrx:kernel:activity1:ActivityDoFollowUpParams:followUpText");
					org.opencrx.kernel.account1.jmi1.Contact assignTo = formValues.get("org:opencrx:kernel:activity1:ActivityDoFollowUpParams:assignTo") != null ?
    	    	(org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(
    	    		formValues.get("org:opencrx:kernel:activity1:ActivityDoFollowUpParams:assignTo")
    	    	) : null;

					// updateActivity
    	    String description = (String)formValues.get("org:opencrx:kernel:activity1:Activity:description");
    	    String location = (String)formValues.get("org:opencrx:kernel:activity1:Activity:location");
    	    Short priority = (Short)formValues.get("org:opencrx:kernel:activity1:Activity:priority");
    	    java.util.Date dueBy = (java.util.Date)formValues.get("org:opencrx:kernel:activity1:Activity:dueBy");

    	    if(transition != null) {
		    			org.opencrx.kernel.activity1.jmi1.ActivityDoFollowUpParams params = org.opencrx.kernel.utils.Utils.getActivityPackage(pm).createActivityDoFollowUpParams(
		              assignTo,
		              followUpText,
		              followUpTitle,
		              transition
		    			);
		          pm.refresh(activity);
		          pm.currentTransaction().begin();
		    			org.opencrx.kernel.activity1.jmi1.ActivityDoFollowUpResult result = activity.doFollowUp(params);
		    			activity.setAssignedTo(assignedTo);
		    			activity.setDescription(description);
		    			activity.setLocation(location);
		    			activity.setPriority(priority);
		    			activity.setDueBy(dueBy);
		    			pm.currentTransaction().commit();
		    			/*
		    			Action nextAction = new ObjectReference(
		    		    	obj,
		    		    	app
		    		   	).getSelectObjectAction();
		    			response.sendRedirect(
		    				request.getContextPath() + "/" + nextAction.getEncodedHRef()
		    			);
		    			return;
		    			*/
    	    }
    	} else {
    			// prepare FollowUp
		    	TransientObjectView view = new TransientObjectView(
		    		formValues,
		    		app,
		    		(RefObject_1_0)activity,
		    		pm
		    	);
		    	ViewPort p = ViewPortFactory.openPage(
		    		view,
		    		request,
		    		out
		    	);
		    	p.setResourcePathPrefix("../../");
    	
%>
		      <br />
		      <div class='processNode noact'><%= app.getLabel(ACTIVITYFOLLOWUP_CLASS) %>: <%= app.getHtmlEncoder().encode(new ObjectReference(activity, app).getTitle(), false) %></div>
		      <form class="followUp" id="<%= FORM_NAME_DOFOLLOWUP %>" name="<%= FORM_NAME_DOFOLLOWUP %>" accept-charset="UTF-8" method="POST" action="<%= WIZARD_NAME %>">
		      	<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
		      	<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
		      	<input type="hidden" id="Fcommand" name="Fcommand" value="" />
		
						<input type="hidden" name="FOLLOWUPACTIVITY_XRI" id="FOLLOWUPACTIVITY_XRI" value="" />
		        <input type="checkbox" style="display:none;" id="isFirstCall" name="isFirstCall" checked="true" />
		      	<table cellspacing="8" class="tableLayout">
		      		<tr>
		      			<td class="cellObject">
		      				<div class="panel" id="panel<%= FORM_NAME_DOFOLLOWUP %>" style="display: block">
<%
		      					doFollowUpForm.paint(
		      						p,
		      						null, // frame
		      						true // forEditing
		      					);
		      					p.flush();
%>
										<table class="fieldGroup">
											<div class="fieldGroupName">&nbsp;</div>
											<tr>
												<td class="label">
													<span class="nw"><%= app.getLabel(RESOURCE_CLASS) %>:</span>
												</td>
												<td>
													<input type="hidden" id="fetchResourceContact" name="fetchResourceContact" value="" /> 
													<select id="resourceContact" name="resourceContact" class="valueL" tabindex="<%= tabIndex++ %>" onchange="javascript:$('fetchResourceContact').value='override';$('Refresh.Button').click();" >
<%
						                // get Resources sorted by name(asc)
														org.opencrx.kernel.activity1.jmi1.Activity1Package activityPkg = org.opencrx.kernel.utils.Utils.getActivityPackage(pm);
						                org.opencrx.kernel.activity1.cci2.ResourceQuery recourceFilter = activityPkg.createResourceQuery();
						                recourceFilter.orderByName().ascending();
														recourceFilter.forAllDisabled().isFalse();
														int maxResourceToShow = 200;
						                for (
						                  Iterator k = activitySegment.getResource(recourceFilter).iterator();
						                  k.hasNext() && maxResourceToShow > 0;
						                  maxResourceToShow--
						                ) {
						                	try {
							                  // get resource
							            	    org.opencrx.kernel.activity1.jmi1.Resource resource =
							                    (org.opencrx.kernel.activity1.jmi1.Resource)k.next();
							            	    org.opencrx.kernel.account1.jmi1.Contact contact = resource.getContact();
							            	    if (contact != null) {
								                  String selectedModifier = ((contact != null ) && (assignedTo != null) && (assignedTo.refMofId().compareTo(contact.refMofId()) == 0)) ? "selected" : "";
%>
								                  <option <%= selectedModifier %> value="<%= contact.refMofId() %>"><%= resource.getName() + (contact != null ? " (" + contact.getFirstName() + " " + contact.getLastName() + ")": "") %></option>
<%
							            	    }
						                	} catch (Exception e) {}
						                }
%>
						              </select>
							          </td>
												<td class="addon"/>
											</tr>
										</table>
		
		      				</div>
		
		      				<input type="submit" name="OK.button" tabindex="<%= tabIndex++ %>" value="<%= app.getTexts().getOkTitle() %>" onclick="javascript:
		      					  $('FOLLOWUPACTIVITY_XRI').value='<%= (activity == null ? "" : activity.refMofId()) %>';
		          				$('Fcommand').value='CREATE_FOLLOWUP';this.name='--';"
		          		/>
		      				<input type="submit" name="Cancel.button" tabindex="<%= tabIndex++ %>" value="<%= app.getTexts().getCancelTitle() %>" onclick="javascript:$('Fcommand').value='CANCEL_FOLLOWUP';" />
		      			</td>
		      		</tr>
		      	</table>
		      </form>
<%
    	}
	}
%>	

	<div>&nbsp;</div>
<%
	ProcessNode processNode = getProcess(activity, pm);
	org.opencrx.kernel.activity1.jmi1.Activity topLevelActivity = processNode.nodeActivity;

	String activityHref = null;
	if (topLevelActivity != null) {
		Action action = new Action(
				SelectObjectAction.EVENT_ID,
				new Action.Parameter[]{
						new Action.Parameter(Action.PARAMETER_OBJECTXRI, topLevelActivity.refMofId())
				},
				"",
				true // enabled
			);
		activityHref = "../../" + action.getEncodedHRef();
	}
	
	//FileUpload
	if(topLevelActivity != null && (command == Command.FILE_UPLOAD)) {
		int fileCounter = 1;
		String location = app.getTempFileName(fileCounter + "." + UPLOAD_FILE_FIELD_NAME, "");
		while(
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
					pm.currentTransaction().begin();

					RefObject_1_0 actobj = (RefObject_1_0)topLevelActivity;
					
					boolean isChecked = false;
					try {
							isChecked = filecb.get(fileCounter-1) != null && ((Boolean)filecb.get(fileCounter-1)).booleanValue();
					} catch (Exception e) {}

					//System.out.println(contentName + " is " + (isChecked ? "" : "not") + " checked");
					// CrxObject
					if (isChecked && actobj instanceof org.opencrx.kernel.generic.jmi1.CrxObject) {
						org.opencrx.kernel.generic.jmi1.CrxObject crxObject =
							(org.opencrx.kernel.generic.jmi1.CrxObject)actobj;
						org.opencrx.kernel.generic.jmi1.Media media = null;
						if(media == null) {
							org.opencrx.kernel.generic.jmi1.GenericPackage genericPkg = org.opencrx.kernel.utils.Utils.getGenericPackage(pm);
							media = genericPkg.getMedia().createMedia();
							media.refInitialize(false, false);
						}
						//media.setDescription(description.length() > 0 ? description : contentName);
						media.setContentName(contentName);
						media.setContentMimeType(contentMimeType);
						media.setContent(
							org.w3c.cci2.BinaryLargeObjects.valueOf(new File(location))
						);
						crxObject.addMedia(
							false,
							org.opencrx.kernel.backend.Activities.getInstance().getUidAsString(),
							media
						);
					}

					pm.currentTransaction().commit();
					new File(location).delete();
				}
				catch(Exception e) {
					new ServiceException(e).log();
					try {
						pm.currentTransaction().rollback();
					} catch(Exception e0) {}
				}
			} else {
					System.out.println("empty file at location = " + location);
			}
			fileCounter++;
			location = app.getTempFileName(fileCounter + "." + UPLOAD_FILE_FIELD_NAME, "");
		}
	}

	int numOfDocuments = 0;
	try {
		if (topLevelActivity != null && !topLevelActivity.getMedia().isEmpty()) {
			numOfDocuments = topLevelActivity.getMedia().size();
		}
	} catch (Exception e) {}

		
	//EMailUpload
	if(topLevelActivity != null && (command == Command.EMAIL_UPLOAD)) {
		int fileCounter = 1;
		String location = app.getTempFileName(fileCounter + "." + UPLOAD_EMAIL_FIELD_NAME, "");
		while(
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
					//RefObject_1_0 actobj = (RefObject_1_0)topLevelActivity;
					
					boolean isChecked = false;
					try {
							isChecked = filecb.get(fileCounter-1) != null && ((Boolean)filecb.get(fileCounter-1)).booleanValue();
					} catch (Exception e) {}

					System.out.println(contentName + " is " + (isChecked ? "" : "not") + " checked");
					if (isChecked) {
						System.out.println("calling importMimeMessage");
						List<org.opencrx.kernel.activity1.jmi1.EMail> emails = Activities.getInstance().importMimeMessage(
								pm,
								providerName,
								segmentName,
								new MimeMessageImpl(new FileInputStream(location)),
								null //obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityCreator ? (org.opencrx.kernel.activity1.jmi1.ActivityCreator)obj : null
							);
						System.out.println("calling importMimeMessage done");
						System.out.println("emails = " + emails);
						if (emails != null && !emails.isEmpty()) {
							try {	
								// link e-mails to topLevelActivity
								pm.currentTransaction().begin();
								org.opencrx.kernel.activity1.jmi1.EMail importedEMail = (org.opencrx.kernel.activity1.jmi1.EMail)emails.iterator().next();
								org.opencrx.kernel.activity1.jmi1.ActivityLinkTo activityLinkTo = org.opencrx.kernel.utils.Utils.getActivityPackage(pm).getActivityLinkTo().createActivityLinkTo();
								activityLinkTo.refInitialize(false, false);
								activityLinkTo.setLinkTo(topLevelActivity);
								activityLinkTo.setName("activity:" + topLevelActivity.getActivityNumber());
								activityLinkTo.setActivityLinkType(Activities.ActivityLinkType.RELATES_TO.getValue()); // relates to
								importedEMail.addActivityLinkTo(
									false,
									org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
									activityLinkTo
								);
								pm.currentTransaction().commit();
							}	catch(Exception e) {
								new org.openmdx.base.exception.ServiceException(e).log();
								try {
									pm.currentTransaction().rollback();
								} catch(Exception e1) {}
							}
						}
						new File(location).delete();
					}
				}
				catch(Exception e) {
					new ServiceException(e).log();
					try {
						pm.currentTransaction().rollback();
					} catch(Exception e0) {}
				}
			} else {
					System.out.println("empty file at location = " + location);
			}
			fileCounter++;
			location = app.getTempFileName(fileCounter + "." + UPLOAD_EMAIL_FIELD_NAME, "");
		}
	}

	int numOfEmails = 0;
	if (topLevelActivity != null) {
		try {
			org.opencrx.kernel.activity1.cci2.ActivityLinkFromQuery linkFromQuery = org.opencrx.kernel.utils.Utils.getActivityPackage(pm).createActivityLinkFromQuery();
			linkFromQuery.activityLinkType().equalTo(new Short((short)(100 - Activities.ActivityLinkType.RELATES_TO.getValue())));
			for (Iterator linkFrom = topLevelActivity.getActivityLinkFrom(linkFromQuery).iterator(); linkFrom.hasNext();) {
					try {
							org.opencrx.kernel.activity1.jmi1.ActivityLinkFrom activityLinkFrom = (org.opencrx.kernel.activity1.jmi1.ActivityLinkFrom)linkFrom.next();
							if (activityLinkFrom.getLinkFrom() != null && activityLinkFrom.getLinkFrom() instanceof org.opencrx.kernel.activity1.jmi1.EMail) {
								numOfEmails++;
							}
					} catch (Exception e) {}
			}
		} catch (Exception e) {}
	}

	// render overview
	org.opencrx.kernel.account1.jmi1.Account customer = null;
	org.opencrx.kernel.account1.jmi1.Account customerContact = null;
	org.opencrx.kernel.account1.jmi1.Account assignedToContact = null;
	try {
			if (topLevelActivity.getReportingAccount() != null) {
					customer = topLevelActivity.getReportingAccount();
			}
	} catch (Exception e) {
			new ServiceException(e).log();
	}
	try {
			if (topLevelActivity.getReportingContact() != null) {
					customerContact = topLevelActivity.getReportingContact();
			}
	} catch (Exception e) {
			new ServiceException(e).log();
	}
	try {
		if (topLevelActivity.getAssignedTo() != null) {
				assignedToContact = topLevelActivity.getAssignedTo();
		}
} catch (Exception e) {
		new ServiceException(e).log();
}

%>
		<%= getAccountEntry(
						customer,
						userView.getFieldLabel(ACTIVITY_CLASS, "reportingAccount", app.getCurrentLocaleAsIndex()),
						app.getLabel(customer != null ? customer.refClass().refMofId().toString() : ACCOUNT_CLASS),
						userView,
						app
				) %>
		<%= getAccountEntry(
						customerContact, 
						userView.getFieldLabel(ACTIVITY_CLASS, "reportingContact", app.getCurrentLocaleAsIndex()),
						app.getLabel(customerContact != null ? customerContact.refClass().refMofId().toString() : CONTACT_CLASS), 
						userView,
						app
				) %>
		<%= getAccountEntry(
						assignedToContact, 
						userView.getFieldLabel(ACTIVITY_CLASS, "assignedTo", app.getCurrentLocaleAsIndex()),
						app.getLabel(assignedToContact != null ? assignedToContact.refClass().refMofId().toString() : CONTACT_CLASS), 
						userView,
						app
				) %>

		<table class='fileDropTable'>
		<caption>
		  <input type="submit" name="UploadDocs" id="UploadDocs" style="float:right;visibility:hidden;" value="<%= app.getTexts().getSaveTitle() %>" tabindex="<%= tabIndex++ %>" onclick="javascript:$('DOCcommand').value='FILE_UPLOAD';this.name='--';" />
			<a href='<%= activityHref %>' target='_blank'>
			  <img src='../../images/Media.gif'/>
			  <%= app.getLabel("org:opencrx:kernel:generic:DocumentAttachment") %> (<%= numOfDocuments %>)
		  </a>
		</caption>
		<tr>
			<td>
				<form id="DOCS<%= WIZARD_NAME %>" name="DOCS<%= WIZARD_NAME %>" enctype="multipart/form-data" accept-charset="UTF-8" method="POST" action="<%= WIZARD_NAME %>">
					<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
					<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
					<input type="hidden" name="DOCcommand" id="DOCcommand" value="NA"/>
				
					<input name="<%= UPLOAD_FILE_FIELD_NAME %>" id="<%= UPLOAD_FILE_FIELD_NAME %>" size="5" class="fileDrop" title="drop files here" type="file" multiple="multiple" onChange="javascript:$('UploadDocs').style.visibility='visible' ; makeFileList();" />
					<div id="fileList"></div>
					<script type="text/javascript">
						$('<%= UPLOAD_FILE_FIELD_NAME %>').style.height='75px';
					
						function makeFileList() {
							$('<%= UPLOAD_FILE_FIELD_NAME %>').style.height='';
							var input = $("<%= UPLOAD_FILE_FIELD_NAME %>");
							var outerdiv = $("fileList");
							while (outerdiv.hasChildNodes()) {
								outerdiv.removeChild(outerdiv.firstChild);
							}
							for (var i = 0; i < input.files.length; i++) {
								var div = document.createElement("div");
								var cb = document.createElement("input");
								cb.type = "checkbox";
								cb.name = "filecb"+(i+1);
				        cb.id = "filecb"+(i+1);
				        cb.value = input.files[i].name;
				        cb.checked = true;
				        var text = document.createTextNode(input.files[i].name);
								div.appendChild(cb);
								div.appendChild(text);
								outerdiv.appendChild(div);
							}
							if(!outerdiv.hasChildNodes()) {
								outerdiv.innerHTML = '--';
								$('<%= UPLOAD_FILE_FIELD_NAME %>').style.height='75px';
							}
						}
					</script>
				</form>
			</td>
		</tr>
		</table>

		<table class='emailDropTable'>
		<caption>
		  <input type="submit" name="UploadEmails" id="UploadEmails" style="float:right;visibility:hidden;" value="<%= app.getTexts().getSaveTitle() %>" tabindex="<%= tabIndex++ %>" onclick="javascript:$('EMAILcommand').value='EMAIL_UPLOAD';this.name='--';document.forms['EMAILS<%= WIZARD_NAME %>'].submit();" />
			<a href='<%= activityHref %>' target='_blank'>
			  <img src='../../images/EMail.gif'/>
			  <%= app.getLabel("org:opencrx:kernel:activity1:EMail") %> (<%= numOfEmails %>)
		  </a>
		</caption>
		<tr>
			<td>
				<form id="EMAILS<%= WIZARD_NAME %>" name="EMAILS<%= WIZARD_NAME %>" enctype="multipart/form-data" accept-charset="UTF-8" method="POST" action="<%= WIZARD_NAME %>">
					<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
					<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
					<input type="hidden" name="DOCcommand" id="EMAILcommand" value="NA"/>
				
					<input name="<%= UPLOAD_EMAIL_FIELD_NAME %>" id="<%= UPLOAD_EMAIL_FIELD_NAME %>" size="5" class="fileDrop" title="drop files here" type="file" multiple="multiple" onChange="javascript:$('UploadEmails').style.visibility='visible' ; makeEmailList();" />
					<div id="emailList"></div>
					<script type="text/javascript">
						$('<%= UPLOAD_EMAIL_FIELD_NAME %>').style.height='75px';
					
						function makeEmailList() {
							$('<%= UPLOAD_EMAIL_FIELD_NAME %>').style.height='';
							var input = $("<%= UPLOAD_EMAIL_FIELD_NAME %>");
							var outerdiv = $("emailList");
							while (outerdiv.hasChildNodes()) {
								outerdiv.removeChild(outerdiv.firstChild);
							}
							for (var i = 0; i < input.files.length; i++) {
								var div = document.createElement("div");
								var cbtn = document.createElement("input");
								cbtn.type = "checkbox";
								cbtn.name = "filecb"+(i+1);
				        cbtn.id = "filecb"+(i+1);
				        cbtn.value = input.files[i].name;
				        cbtn.checked = true;
				        var text = document.createTextNode(input.files[i].name);
								div.appendChild(cbtn);
								div.appendChild(text);
								outerdiv.appendChild(div);
							}
							if(!outerdiv.hasChildNodes()) {
								outerdiv.innerHTML = '--';
								$('<%= UPLOAD_EMAIL_FIELD_NAME %>').style.height='75px';
							}
						}
					</script>
				</form>
			</td>
		</tr>
		</table>
				
	<div style="clear:both;height:3px;"></div>

	<form id="<%= WIZARD_NAME %>" name="<%= WIZARD_NAME %>" method="post" accept-charset="UTF-8" action="<%= WIZARD_NAME %>">
		<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
		<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
		<input type="hidden" name="command" id="command" value="NA"/>

		<input type="hidden" name="ACTIVITY_XRI" id="ACTIVITY_XRI" value="" />
		<input type="hidden" name="TRANSITION_XRI" id="TRANSITION_XRI" value="" />
		<input type="hidden" name="TITLE" id="TITLE" value="" />
		<input type="hidden" name="TEXT" id="TEXT" value="" />

		<INPUT type="Checkbox" name="showCompleteProcess" id="showCompleteProcess" <%= showCompleteProcess ? "checked" : "" %> tabindex="<%= tabIndex++ %>" value="showCompleteProcess" /> <%= app.getTexts().getShowDetailsTitle() %>&nbsp;&nbsp;
		<input type="submit" name="Reload" id="Reload" value="<%= app.getTexts().getReloadText() %>" tabindex="<%= tabIndex++ %>" />
		<input type="button" value="<%= app.getTexts().getCloseText() %>" tabindex="<%= tabIndex++ %>" onclick="javascript:location.href='<%= WIZARD_NAME + "?" + requestIdParam + "&" + xriParam + "&command=CANCEL" %>';" />

		<div style="clear:both;height:6px;"></div>

		<div class="col1DISABLED">
			<fieldset>
<%
				if (processNode != null) {
%>
						<legend><%= processNode.nodeActivity != null ? "#" + app.getHtmlEncoder().encode(new ObjectReference(processNode.nodeActivity, app).getTitle(), false) : "--" %></legend>
				  	<%= produceTable(processNode, showCompleteProcess, userView, pm, app) %>
<%
				} else {
%>
					<b>no process found</b>
<%
				}
%>
			</fieldset>
			<div>&nbsp;</div>
		</div>
		<br />
<!-- 
		<div class="buttons">
			<input type="submit" name="Setup" value="Setup" class="button" tabindex="<%= tabIndex++ %>"/>
			<input type="submit" name="Reset" value="Reset" class="button" onclick="javascript:getElementById('command').value=this.name;" />
			<input type="button" value="<%= app.getTexts().getCancelTitle() %>" tabindex="<%= tabIndex++ %>" onclick="javascript:location.href='<%= WIZARD_NAME + "?" + requestIdParam + "&" + xriParam + "&command=CANCEL" %>';" class="button" />
			<br>
			<br>
		</div>
-->
	</form>
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
