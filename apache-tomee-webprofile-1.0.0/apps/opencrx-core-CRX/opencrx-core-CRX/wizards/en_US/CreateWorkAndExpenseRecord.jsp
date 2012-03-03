<%@	page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/**
 * ====================================================================
 * Project:     openCRX/Core, http://www.opencrx.org/
 * Name:		$Id: CreateWorkAndExpenseRecord.jsp,v 1.70 2011/12/16 09:35:26 cmu Exp $
 * Description:	Create Work Record
 * Revision:	$Revision: 1.70 $
 * Owner:		CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:		$Date: 2011/12/16 09:35:26 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2009-2011, CRIXP Corp., Switzerland
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
java.math.*,
java.net.*,
java.text.*,
javax.xml.datatype.*,
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
org.opencrx.kernel.backend.*,
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.openmdx.base.exception.*,
org.openmdx.base.text.conversion.*
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

	public static int getDayOfWeek(
			String dateAsString,
			ApplicationContext app
		) {
			GregorianCalendar date = getDateAsCalendar(dateAsString, app);
			return date.get(date.DAY_OF_WEEK);
	}

	private static String decimalMinutesToHhMm(
		double decimalMinutes
	) {
		NumberFormat hhFormatter = new DecimalFormat("#,##0");
		NumberFormat mmFormatter = new DecimalFormat("#,#00");
		int hours = (int)(decimalMinutes / 60.0);
		int minutes = (int)java.lang.Math.rint(decimalMinutes % 60.0);
		if (minutes == 60) {
				hours += 1;
				minutes = 0;
		}
		return hhFormatter.format(hours) + ":" + mmFormatter.format(minutes);
	}

	public static String getUsername(
		javax.jdo.PersistenceManager pm,
		org.opencrx.kernel.home1.jmi1.Segment homeSegment,
		org.opencrx.kernel.activity1.jmi1.Resource resource
	) {
		//org.opencrx.kernel.home1.cci2.UserHomeQuery userHomeFilter = org.opencrx.kernel.utils.Utils.getHomePackage(pm).createUserHomeQuery();
		String userName = null;
		org.opencrx.kernel.account1.jmi1.Contact contact = null;
		try {
				contact = resource.getContact();
				for(
					Iterator i = homeSegment.getUserHome().iterator();
					i.hasNext() && userName == null && contact != null;
				) {
					try {
							org.opencrx.kernel.home1.jmi1.UserHome userHome = (org.opencrx.kernel.home1.jmi1.UserHome)i.next();
							if (userHome.getContact() != null && userHome.getContact().refMofId().compareTo(contact.refMofId()) == 0) {
									userName = ((new Path(userHome.refMofId())).getLastComponent()).toString();
							}
					} catch (Exception e) {}
				}
		} catch (Exception e) {}
		return userName;
	}

	public org.opencrx.security.realm1.jmi1.PrincipalGroup findPrincipalGroup(
		 String principalGroupName,
		 org.openmdx.security.realm1.jmi1.Realm realm,
		 javax.jdo.PersistenceManager pm
	) {
		try {
			org.opencrx.security.realm1.jmi1.PrincipalGroup principalGroup = (org.opencrx.security.realm1.jmi1.PrincipalGroup)org.opencrx.kernel.backend.SecureObject.getInstance().findPrincipal(
				principalGroupName,
				realm
			);
			return principalGroup;
		} catch (Exception e) {
			return null;
		}
	}
	
	public org.opencrx.kernel.activity1.jmi1.CalendarDay createOrUpdateCalendarDay(
			String name,
			String date, /* in format YYYYMMDD */
			org.opencrx.kernel.activity1.jmi1.Calendar calendar,
			org.opencrx.kernel.activity1.jmi1.CalendarDay calendarDay,
			org.opencrx.kernel.activity1.jmi1.Segment activitySegment,
			javax.jdo.PersistenceManager pm
	) {
			try {
				pm.currentTransaction().begin();
				if(calendarDay == null) {
					calendarDay = pm.newInstance(org.opencrx.kernel.activity1.jmi1.CalendarDay.class);
					calendarDay.refInitialize(false, false);
					calendarDay.setName(name);
					XMLGregorianCalendar cal = org.w3c.spi2.Datatypes.create(
							XMLGregorianCalendar.class,
							date
					);
					calendarDay.setDateOfDay(cal);
					calendar.addCalendarDay(
						false,
						org.opencrx.kernel.backend.Base.getInstance().getUidAsString(),
						calendarDay
					);
				}
				calendarDay.setName(name);
				pm.currentTransaction().commit();
			}
			catch(Exception e) {
				new ServiceException(e).log();
				try {
					pm.currentTransaction().rollback();
				} catch(Exception e0) {}
			}
			return calendarDay;
	}


%>
<%
	final boolean SHOW_ERRORS = false;
	final int MAX_ACTIVITY_SHOWN_INITIALLY = 50;
	final int MAX_ACTIVITY_SHOWN = 500;
	final int MAX_ACTIVITY_SORT_ORDER = 4;
	final String FORM_NAME = "CreateWorkAndExpenseRecord";
	final String WIZARD_NAME = FORM_NAME + ".jsp";
	final String SUBMIT_HANDLER = "javascript:$('command').value=this.name;";
	final String ONFOCUS_HANDLER = "javascript:$('lastFocusId').value=this.id;";
	final String CAUTION = "<img border='0' alt='' height='16px' src='../../images/caution.gif' />";
	final String PRIVATE_TOKEN = "PRIVATE";

	final boolean EXCLUDE_ACTIVITYTRACKER_TEMPLATES = true; // excludes ActivityTracker if ActivityTracker.userBoolean1 == true
	final String ACTIVITY_FILTER_SEGMENT = "Segment";
	final String ACTIVITY_FILTER_ANYGROUP = "AnyGroup";
	final String ACTIVITY_FILTER_TRACKER = "Tracker";
	final String ACTIVITY_FILTER_PROJECT = "Project";
	final String ACTIVITY_FILTER_CATEGORY = "Category";
	final String ACTIVITY_FILTER_MILESTONE = "Milestone";

	final String ACTIVITY_CLASS = "org:opencrx:kernel:activity1:Activity";
	final String ACTIVITYFILTERGLOBAL_CLASS = "org:opencrx:kernel:activity1:ActivityFilterGlobal";
	final String ACTIVITYFILTERGROUP_CLASS = "org:opencrx:kernel:activity1:ActivityFilterGroup";
	final String ACTIVITYSEGMENT_CLASS = "org:opencrx:kernel:activity1:Segment";
	final String ACTIVITYGROUPASSIGNMENT_CLASS = "org:opencrx:kernel:activity1:ActivityGroupAssignment";
	final String ACTIVITYTRACKER_CLASS = "org:opencrx:kernel:activity1:ActivityTracker";
	final String ACTIVITYCATEGORY_CLASS = "org:opencrx:kernel:activity1:ActivityCategory";
	final String ACTIVITYMILESTONE_CLASS = "org:opencrx:kernel:activity1:ActivityMilestone";
	final String DISABLED_FILTER_PROPERTY_CLASS = "org:opencrx:kernel:activity1:DisabledFilterProperty";
	final String RESOURCE_CLASS = "org:opencrx:kernel:activity1:Resource";
	final String CALENDARDAY_CLASS = "org:opencrx:kernel:activity1:CalendarDay";
	final String ACCOUNT_CLASS = "org:opencrx:kernel:account1:Account";
	final String CONTACT_CLASS = "org:opencrx:kernel:account1:Contact";
	final String GROUP_CLASS = "org:opencrx:kernel:account1:Group";
	final String WORKANDEXPENSERECORD_CLASS = "org:opencrx:kernel:activity1:WorkAndExpenseRecord";
	final int RECORDTYPE_WORK_MAX = 99; // <=99 --> WorkRecord, >= 100 --> ExpenseRecord
	final String[] UOM_NAMES = {
			"s", "min", "hour", "day",
			"m", "km", "mile", "feet", "inch",
			"kg",
			"Piece(s)", "Unit(s)"
	};

	final String featureRecordType = "workAndExpenseType";
	final String featureRecordTypeWork = "workAndExpenseTypeWorkOnly";
	final String featureRecordTypeExpense = "workAndExpenseTypeExpenseOnly";
	final String featureBillingCurrency = "currency";
	final String featurePaymentType = "paymenttype";

	final String contactTargetFinder = "org:opencrx:kernel:activity1:Resource:contact";

	final String errorStyle = "style='background-color:#FFF0CC;'";
	final String errorStyleInline = "background-color:#FFF0CC;";
	// Init
	request.setCharacterEncoding("UTF-8");
	ApplicationContext app = (ApplicationContext)session.getValue(WebKeys.APPLICATION_KEY);
	ViewsCache viewsCache = (ViewsCache)session.getValue(WebKeys.VIEW_CACHE_KEY_SHOW);
	String requestId =	request.getParameter(Action.PARAMETER_REQUEST_ID);
	String objectXri = request.getParameter(Action.PARAMETER_OBJECTXRI);
	String requestIdParam = Action.PARAMETER_REQUEST_ID + "=" + requestId;
	String xriParam = Action.PARAMETER_OBJECTXRI + "=" + objectXri;
	if(objectXri == null || app == null || viewsCache.getView(requestId) == null) {
		session.setAttribute(WIZARD_NAME, null);
		response.sendRedirect(
			request.getContextPath() + "/" + WebKeys.SERVLET_NAME
		);
		return;
	}
	javax.jdo.PersistenceManager pm = app.getNewPmData();
	Texts_1_0 texts = app.getTexts();
	org.openmdx.portal.servlet.Codes codes = app.getCodes();

	RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));
	String providerName = obj.refGetPath().get(2);
	String segmentName = obj.refGetPath().get(4);

	String errorMsg = "";

	// Format DateTimes
	TimeZone timezone = TimeZone.getTimeZone(app.getCurrentTimeZone());
	SimpleDateFormat dtf = new SimpleDateFormat("EEEE", app.getCurrentLocale()); dtf.setTimeZone(timezone);
	SimpleDateFormat monthFormat = new java.text.SimpleDateFormat("MMMM", app.getCurrentLocale()); monthFormat.setTimeZone(timezone);
	SimpleDateFormat dayInWeekFormat = new java.text.SimpleDateFormat("E", app.getCurrentLocale()); dayInWeekFormat.setTimeZone(timezone);
	SimpleDateFormat weekdayf = new SimpleDateFormat("EE", app.getCurrentLocale()); weekdayf.setTimeZone(timezone);
	SimpleDateFormat dateonlyf = new SimpleDateFormat("dd-MMM-yyyy", app.getCurrentLocale()); dateonlyf.setTimeZone(timezone);
	SimpleDateFormat datetimef = new SimpleDateFormat("dd-MMM-yyyy HH:mm", app.getCurrentLocale());	datetimef.setTimeZone(timezone);
	SimpleDateFormat datef = new SimpleDateFormat("EE d-MMMM-yyyy", app.getCurrentLocale()); datef.setTimeZone(timezone);
	SimpleDateFormat dtsortf = new SimpleDateFormat("yyyyMMddHHmmss", app.getCurrentLocale()); dtsortf.setTimeZone(timezone);
	SimpleDateFormat calendardayf = new SimpleDateFormat("yyyyMMdd", app.getCurrentLocale()); calendardayf.setTimeZone(timezone);
	NumberFormat formatter = new DecimalFormat("00000");
	NumberFormat quantityf = new DecimalFormat("0.000");
	NumberFormat ratesepf = new DecimalFormat("#,##0.00");
	NumberFormat formatter0 = new DecimalFormat("0");

	org.opencrx.kernel.activity1.jmi1.Activity1Package activityPkg = org.opencrx.kernel.utils.Utils.getActivityPackage(pm);
	org.opencrx.kernel.activity1.jmi1.Segment activitySegment = (org.opencrx.kernel.activity1.jmi1.Segment)pm.getObjectById(
			new Path("xri:@openmdx:org.opencrx.kernel.activity1/provider/" + providerName + "/segment/" + segmentName)
		);
		
	org.opencrx.kernel.uom1.jmi1.Uom uomPercent = null;
	try {
		uomPercent = (org.opencrx.kernel.uom1.jmi1.Uom)pm.getObjectById(
				new Path("xri://@openmdx*org.opencrx.kernel.uom1/provider/" + providerName + "/segment/Root/uom/Percent")
		);
	} catch (Exception e) {}


	// Dates and Times
	Map formValues = new HashMap();


	UserDefinedView userView = new UserDefinedView(
		pm.getObjectById(new Path(objectXri)),
		app,
		viewsCache.getView(requestId)
	);
	int tabIndex = 1000; // calendar

	boolean isFirstCall = request.getParameter("isFirstCall") == null; // used to properly initialize various options
	boolean mustReload = false;
	boolean creationFailed = false;

	String command = request.getParameter("command");
	//System.out.println("command=" + command);
	boolean actionNextMonth = "NextMonth".equals(command);
	boolean actionPrevMonth = "PrevMonth".equals(command);
	boolean actionNextYear = "NextYear".equals(command);
	boolean actionPrevYear = "PrevYear".equals(command);
	boolean actionSelectDate = command != null && command.startsWith("SelectDate.");
	boolean actionSelectDateP = command != null && command.startsWith("SelectDateP.");
	boolean actionSelectDateN = command != null && command.startsWith("SelectDateN.");
	boolean actionCancel = command != null && command.startsWith("cancel.");
	boolean actionAdd = command != null && command.startsWith("add.");
	boolean actionReload = command != null && command.startsWith("reload.");
	boolean actionEvictAndReload = command != null && command.startsWith("EVICT_RELOAD");

	if (actionReload & (request.getParameter("deleteWorkRecordXri") != null && request.getParameter("deleteWorkRecordXri").length() > 0)) {
		// delete WorkRecord
		try {
				RefObject_1_0 objToDelete = (RefObject_1_0)pm.getObjectById(new Path(request.getParameter("deleteWorkRecordXri")));
				pm.currentTransaction().begin();
				objToDelete.refDelete();
				pm.currentTransaction().commit();
		} catch (Exception e) {
				try {
						pm.currentTransaction().rollback();
				} catch (Exception er) {}
				new ServiceException(e).log();
		}
	}

	if (actionEvictAndReload) {
			app.resetPmData();
	}
	boolean isWorkRecord = ((request.getParameter("isExpenseRecord") == null) || (request.getParameter("isExpenseRecord").length() == 0));
	boolean isWorkRecordInPercent = isWorkRecord &&	((request.getParameter("isWorkRecordInPercent") != null) && (request.getParameter("isWorkRecordInPercent").length() > 0));
	boolean hasProjects = ((request.getParameter("hasProjects") != null) && (request.getParameter("hasProjects").length() > 0));
	

	String contactXri = null;
	String resourceXri = null;
	String activityFilter = null;
	String activityFilterXri = null;
	String activityXri = null;

	if (isFirstCall) {
		try {
			// try to derive initial settings from calling object
			if (obj instanceof org.opencrx.kernel.account1.jmi1.Contact) {
					// called from Contact
					contactXri = ((org.opencrx.kernel.account1.jmi1.Contact)obj).refMofId();
			} else if (obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityTracker) {
					// called from ActivityTracker
					activityFilterXri = ((org.opencrx.kernel.activity1.jmi1.ActivityTracker)obj).refMofId();
					activityFilter = ACTIVITY_FILTER_TRACKER;
			} else if (obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityCategory) {
				// called from ActivityCategory
				activityFilterXri = ((org.opencrx.kernel.activity1.jmi1.ActivityCategory)obj).refMofId();
				activityFilter = ACTIVITY_FILTER_CATEGORY;
			} else if (obj instanceof org.opencrx.kernel.activity1.jmi1.ActivityMilestone) {
				// called from ActivityMilestone
				activityFilterXri = ((org.opencrx.kernel.activity1.jmi1.ActivityMilestone)obj).refMofId();
				activityFilter = ACTIVITY_FILTER_MILESTONE;
			} else if ((obj instanceof org.opencrx.kernel.activity1.jmi1.Activity) || (obj instanceof org.opencrx.kernel.activity1.jmi1.ResourceAssignment)) {
					org.opencrx.kernel.activity1.jmi1.Activity activity = null;
					if (obj instanceof org.opencrx.kernel.activity1.jmi1.ResourceAssignment) {
							if (((org.opencrx.kernel.activity1.jmi1.ResourceAssignment)obj).getResource() != null) {
									resourceXri = ((org.opencrx.kernel.activity1.jmi1.ResourceAssignment)obj).getResource().refMofId();
							}
							activityXri = new Path(obj.refMofId()).getParent().getParent().toXri();
					} else {
							// called from Activity
							activityXri = ((org.opencrx.kernel.activity1.jmi1.Activity)obj).refMofId();
					}
					if (activityXri != null) {
							org.opencrx.kernel.activity1.jmi1.ActivityTracker tracker = null;
							org.opencrx.kernel.activity1.jmi1.ActivityCategory category = null;
							org.opencrx.kernel.activity1.jmi1.ActivityMilestone milestone = null;
							// hint: choose any of the assigned activity groups (preference: tracker > category > milestone), otherwise segment
							for(Iterator i = ((org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(new Path(activityXri))).getAssignedGroup().iterator(); i.hasNext(); ) {
									org.opencrx.kernel.activity1.jmi1.ActivityGroupAssignment ass = (org.opencrx.kernel.activity1.jmi1.ActivityGroupAssignment)i.next();
									if (ass.getActivityGroup() != null) {
											org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = ass.getActivityGroup();
											if (
													ag instanceof org.opencrx.kernel.activity1.jmi1.ActivityTracker &&
													(
															((org.opencrx.kernel.activity1.jmi1.ActivityTracker)ag).isDisabled() == null ||
															!((org.opencrx.kernel.activity1.jmi1.ActivityTracker)ag).isDisabled().booleanValue()
													)
											) {
													tracker = (org.opencrx.kernel.activity1.jmi1.ActivityTracker)ag;
											} else if (
													ag instanceof org.opencrx.kernel.activity1.jmi1.ActivityCategory &&
													(
															((org.opencrx.kernel.activity1.jmi1.ActivityCategory)ag).isDisabled() == null ||
															!((org.opencrx.kernel.activity1.jmi1.ActivityCategory)ag).isDisabled().booleanValue()
													)
											) {
													category = (org.opencrx.kernel.activity1.jmi1.ActivityCategory)ag;
											} else if (
													ag instanceof org.opencrx.kernel.activity1.jmi1.ActivityMilestone &&
													(
															((org.opencrx.kernel.activity1.jmi1.ActivityMilestone)ag).isDisabled() == null ||
															!((org.opencrx.kernel.activity1.jmi1.ActivityMilestone)ag).isDisabled().booleanValue()
													)
											) {
													milestone = (org.opencrx.kernel.activity1.jmi1.ActivityMilestone)ag;
											}
									}
									if (tracker != null) {
											activityFilterXri = tracker.refMofId();
											activityFilter = ACTIVITY_FILTER_TRACKER;
									} else if (category != null) {
											activityFilterXri = category.refMofId();
											activityFilter = ACTIVITY_FILTER_CATEGORY;
									} else if (milestone != null) {
										activityFilterXri = milestone.refMofId();
										activityFilter = ACTIVITY_FILTER_MILESTONE;
									} else {
										activityFilterXri = "";
										activityFilter = ACTIVITY_FILTER_SEGMENT;
									}
							}
					}
			} else if (obj instanceof org.opencrx.kernel.activity1.jmi1.Resource) {
				// called from Resource
				resourceXri = ((org.opencrx.kernel.activity1.jmi1.Resource)obj).refMofId();
				if (((org.opencrx.kernel.activity1.jmi1.Resource)obj).getContact() != null) {
						contactXri = ((org.opencrx.kernel.activity1.jmi1.Resource)obj).getContact().refMofId();
				}
			}
		} catch (Exception e) {
				new ServiceException(e).log();
		}
		if (activityFilter == null) {activityFilter = ACTIVITY_FILTER_TRACKER;}

		// determine wheter there are ActivityTrackers with userString0 != null
		org.opencrx.kernel.activity1.cci2.ActivityTrackerQuery trackerFilter = activityPkg.createActivityTrackerQuery();
		trackerFilter.forAllDisabled().isFalse();
		trackerFilter.thereExistsUserBoolean0().isTrue();
		hasProjects = !activitySegment.getActivityTracker(trackerFilter).isEmpty();
	}

	// Parameter contact
	if (contactXri == null) {contactXri = request.getParameter("contactXri");}
	org.opencrx.kernel.account1.jmi1.Contact contact = null;
	String contactXriTitle = request.getParameter("contactXri.Title") == null ? "" : request.getParameter("contactXri.Title");
	boolean showAllResources = false;
	boolean showAllResourcesOfContact = false;
	boolean isResourceChange = ((request.getParameter("isResourceChange") != null) && (request.getParameter("isResourceChange").length() > 0));
	boolean isContactChange = ((request.getParameter("isContactChange") != null) && (request.getParameter("isContactChange").length() > 0));
	boolean resetActivityXri = ((request.getParameter("resetActivityXri") != null) && (request.getParameter("resetActivityXri").length() > 0));
	try {
			if ((contactXri != null) && (contactXri.length() > 0)) {
					if (contactXri.compareTo("*") == 0) {
							showAllResources = true;
							if (!isResourceChange && (resourceXri != null && resourceXri.length() > 0)) {
									resourceXri = "*";
							}
					} else {
							contact = (org.opencrx.kernel.account1.jmi1.Contact)pm.getObjectById(new Path(contactXri));
					}
			} else if (obj instanceof org.opencrx.kernel.account1.jmi1.Contact) {
					contact = (org.opencrx.kernel.account1.jmi1.Contact)obj;
			} else {
					// default is current users Contact (as defined in current user's UserHome
					// get UserHome
					org.opencrx.kernel.home1.jmi1.UserHome myUserHome = org.opencrx.kernel.backend.UserHomes.getInstance().getUserHome(obj.refGetPath(), pm);
					if (myUserHome.getContact() != null) {
						contact = myUserHome.getContact();
					}
			}
	} catch (Exception e) {}

	org.opencrx.kernel.activity1.jmi1.Resource resource = null;
	if ((resourceXri == null) && (!isContactChange)) {
			resourceXri = request.getParameter("resourceXri");
			if ((resourceXri != null) && (resourceXri.length() > 0)) {
					if (resourceXri.compareTo("*") == 0) {
							showAllResourcesOfContact = true;
					} else if (isResourceChange) {
							try {
									resource = (org.opencrx.kernel.activity1.jmi1.Resource)pm.getObjectById(new Path(resourceXri));
									contact = resource.getContact();
									showAllResources = false;
							} catch (Exception e) {}
					}
			}
	}

	if (contact == null) {
			showAllResources = true;
			contactXri = "*";
			contactXriTitle = "*";
	} else {
			contactXri = contact.refMofId();
			contactXriTitle = app.getHtmlEncoder().encode(new ObjectReference(contact, app).getTitle(), false);
	}

	String projectMain = request.getParameter("projectMain") == null ? "" : request.getParameter("projectMain");

	if (activityFilterXri == null) {
			activityFilterXri = request.getParameter("activityFilterXri");
			if (activityFilterXri == null) {activityFilterXri = "";}
	}

	if (activityFilter == null) {
			activityFilter = request.getParameter("activityFilter");
			if (activityFilter == null) {activityFilter = "";}
	}

	org.opencrx.kernel.activity1.jmi1.ActivityGroup activityGroup = null;
	try {
		if ((activityFilterXri != null) && (activityFilterXri.length() > 0)) {
				activityGroup = (org.opencrx.kernel.activity1.jmi1.ActivityTracker)pm.getObjectById(new Path(activityFilterXri));
		}
	} catch (Exception e) {}

	if (activityXri == null) {activityXri = request.getParameter("activityXri");}
	String recordType	= request.getParameter("recordType")	== null ? Integer.toString(Activities.WorkRecordType.STANDARD.getValue()) : request.getParameter("recordType");	// Parameter recordType
	String name				= request.getParameter("name")				== null ? ""	: request.getParameter("name");				// Parameter name
	String description = request.getParameter("description")	== null ? ""	: request.getParameter("description"); // Parameter description
	String effortHH		= (request.getParameter("effortHH")		== null || request.getParameter("effortHH").length() == 0) ? "8" : request.getParameter("effortHH");		// Parameter effortHH
	String effortMM		= (request.getParameter("effortMM")		== null || request.getParameter("effortMM").length() == 0) ? "00": request.getParameter("effortMM");		// Parameter effortMM
	String quantPercent= (request.getParameter("quantPercent")== null || request.getParameter("quantPercent").length() == 0) ? "100" : request.getParameter("quantPercent");		// Parameter quantPercent
	String startedAtHH = (request.getParameter("startedAtHH") == null || request.getParameter("startedAtHH").length() == 0) ? "08": request.getParameter("startedAtHH"); // Parameter startedAtHH
	String startedAtMM = (request.getParameter("startedAtMM") == null || request.getParameter("startedAtMM").length() == 0) ? "00": request.getParameter("startedAtMM"); // Parameter startedAtMM
	String endedAtHH	 = request.getParameter("endedAtHH")		== null ? ""	: request.getParameter("endedAtHH");	 // Parameter endedAtHH
	String endedAtMM	 = request.getParameter("endedAtMM")		== null ? ""	: request.getParameter("endedAtMM");	 // Parameter endedAtMM
	String billingCurrency = request.getParameter("billingCurrency")	== null ? "756" : request.getParameter("billingCurrency");	// Parameter billingCurrency [default "756 - CHF"]
	String rate				= request.getParameter("rate")				== null ? ""	: request.getParameter("rate");				// Parameter rate
	String isBillable	= isFirstCall ? "isBillable" : request.getParameter("isBillable");
	String isReimbursable = isFirstCall ? "" : request.getParameter("isReimbursable");
	String makePrivate	= isFirstCall ? "" : request.getParameter("makePrivate");
	String isFullStartedAtDate	= isFirstCall ? "" : request.getParameter("isFullStartedAtDate");
	String paymentType = request.getParameter("paymentType")	== null ? "1" : request.getParameter("paymentType");	// Parameter paymentType [default "1 - Cash"]
	String uomXri			= request.getParameter("uomXri") != null ? request.getParameter("uomXri") : "";
	String quantity		= (request.getParameter("quantity")		== null || request.getParameter("quantity").length() == 0) ? "1" : request.getParameter("quantity");		// Parameter quantity
	String lastCreatedWorkRecordXri		 = request.getParameter("lastCreatedWorkRecordXri")		!= null ? request.getParameter("lastCreatedWorkRecordXri")		: "";
	String lastCreatedExpenseRecordXri	= request.getParameter("lastCreatedExpenseRecordXri") != null ? request.getParameter("lastCreatedExpenseRecordXri") : "";
	String lastFocusId	= request.getParameter("lastFocusId") != null ? request.getParameter("lastFocusId") : "";

	String filterActivityGroupName = request.getParameter("filterActivityGroupName") == null ? ""	: request.getParameter("filterActivityGroupName"); // Parameter filterActivityGroupName
	String filterActivityName = request.getParameter("filterActivityName") == null ? ""	: request.getParameter("filterActivityName"); // Parameter filterActivityName

	String excludeClosedActivities		 = isFirstCall ? "checked" : request.getParameter("excludeClosedActivities");
	String showActivityGroupNameFilter = isFirstCall ? "" : request.getParameter("showActivityGroupNameFilter");
	int activitySortOrder = 1;
	try {
			activitySortOrder = request.getParameter("activitySortOrder") != null ? Integer.parseInt(request.getParameter("activitySortOrder")) : 1;
	} catch (Exception e) {};
	String isFullMonth	= isFirstCall ? "" : request.getParameter("isFullMonth");

	String selectedDateStr = request.getParameter("selectedDateStr"); // // YYYYMMDD
	GregorianCalendar today = new GregorianCalendar(app.getCurrentLocale());
	today.setTimeZone(TimeZone.getTimeZone(app.getCurrentTimeZone()));
	String todayStr = getDateAsString(today);
	//System.out.println("todayStr = " + todayStr + " [time = " + today.getTime() + " tz  = " + today.getTimeZone().getDisplayName() + "]");

	if(selectedDateStr == null || selectedDateStr.length() != 8) {
		selectedDateStr = todayStr;
	}
	
	if(actionPrevMonth || actionSelectDateP) {
		GregorianCalendar date = getDateAsCalendar(selectedDateStr, app); //
		date.add(GregorianCalendar.MONTH, -1);
		selectedDateStr = getDateAsString(date);
	}
	if(actionNextMonth || actionSelectDateN) {
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
	// Select date
	// YYYYMMDD
	// 012345678
	Integer calendarYear = Integer.parseInt(selectedDateStr.substring(0,4));
	Integer calendarMonth = Integer.parseInt(selectedDateStr.substring(4,6))-1;
	int dayOfMonth = Integer.parseInt(selectedDateStr.substring(6,8));

	if(actionSelectDateP || actionSelectDate || actionSelectDateN) {
		dayOfMonth = Integer.valueOf(command.substring(command.indexOf(".") + 1));
		selectedDateStr = getDateAsString(calendarYear, calendarMonth+1, dayOfMonth);
	}

	GregorianCalendar calendar = new GregorianCalendar(app.getCurrentLocale());
	calendar.setTimeZone(TimeZone.getTimeZone(app.getCurrentTimeZone()));
	calendar.setMinimalDaysInFirstWeek(4); // this conforms to DIN 1355/ISO 8601
	calendar.set(GregorianCalendar.YEAR, calendarYear);
	calendar.set(GregorianCalendar.MONTH, calendarMonth);
	calendar.set(GregorianCalendar.DAY_OF_MONTH, 1);

	// Cancel
	if(actionCancel) {
		session.setAttribute(WIZARD_NAME, null);
		Action nextAction = new ObjectReference(obj, app).getSelectObjectAction();
		response.sendRedirect(
			request.getContextPath() + "/" + nextAction.getEncodedHRef()
		);
		return;
	}

	// try to parse startedAt
	GregorianCalendar startedAt = null;
	try {
			startedAt = getDateAsCalendar(selectedDateStr, app);

			int numValueMM = Integer.parseInt(startedAtMM);
			if (numValueMM < 0) {
					numValueMM = 0;
					startedAtMM = "00";
			} else if (numValueMM > 59) {
					numValueMM = 59;
					startedAtMM = "59";
			}
			startedAt.set(GregorianCalendar.MINUTE, numValueMM);

			int numValueHH = Integer.parseInt(startedAtHH);
			if (numValueHH < 0) {
					numValueHH = 0;
					startedAtHH = "00";
			} else if (numValueHH > 24) {
					numValueHH = 24;
					startedAtHH = "24";
			}
			if ((numValueHH == 24) && (numValueMM > 0)) {
					numValueHH = 23;
					startedAtHH = "23";
			}
			startedAt.set(GregorianCalendar.HOUR_OF_DAY, numValueHH);
	} catch (Exception e) {
			errorMsg += "started at is mandatory<br>";
			startedAt = null;
	}

	// try to parse endedAt
	GregorianCalendar endedAt = null;
	try {
			endedAt = getDateAsCalendar(selectedDateStr, app);

			int numValueMM = Integer.parseInt(endedAtMM);
			if (numValueMM < 0) {
					numValueMM = 0;
					endedAtMM = "00";
			} else if (numValueMM > 59) {
					numValueMM = 59;
					endedAtMM = "59";
			}
			endedAt.set(GregorianCalendar.MINUTE, numValueMM);

			int numValueHH = Integer.parseInt(endedAtHH);
			if (numValueHH < 0) {
					numValueHH = 0;
					endedAtHH = "00";
			} else if (numValueHH > 24) {
					numValueHH = 24;
					endedAtHH = "24";
			}
			if ((numValueHH == 24) && (numValueMM > 0)) {
					numValueHH = 23;
					endedAtHH = "23";
			}
			endedAt.set(GregorianCalendar.HOUR_OF_DAY, numValueHH);
	} catch (Exception e) {
			endedAt = null; // this is an optional attribute
			endedAtHH = "";
			endedAtMM = "";
	}

	// try to parse paraEffort
	Short paraEffortHH = null;
	Short paraEffortMM = null;
	try {
			short numValueMM = Short.parseShort(effortMM);
			if (numValueMM < 0) {
					numValueMM = 0;
					effortMM = "00";
			} else if (numValueMM > 59) {
					numValueMM = 59;
					effortMM = "59";
			}
			paraEffortMM = numValueMM;

			short numValueHH = Short.parseShort(effortHH);
			if (numValueHH < 0) {
					numValueHH = 0;
					effortHH = "00";
			}
			paraEffortHH = numValueHH;
	} catch (Exception e) {
			paraEffortHH = null;
			paraEffortMM = null;
			effortHH = "0";
			effortMM = "00";
	}

	// try to parse rate
	java.math.BigDecimal paraRate = null;
	try {
			paraRate = new java.math.BigDecimal(rate);
	} catch (Exception e) {
			paraRate = null;
			if (!isWorkRecord) {
					errorMsg += "rate is mandatory!<br>";
			}
	}

	// try to parse quantity
	java.math.BigDecimal paraQuantity = null;
	boolean quantityIsZero = false;
	try {
			paraQuantity = new java.math.BigDecimal(quantity);
			if (!isWorkRecord && paraQuantity.compareTo(java.math.BigDecimal.ZERO) == 0) {
				errorMsg += "quantity is 0!<br>";
				quantityIsZero = true;
			}
	} catch (Exception e) {
			paraQuantity = null;
	}

	// try to parse quantPercent
	boolean quantPercentageIsZero = false;
	Short paraQuantPercentage = null;
	try {
			short numValuePercentage = Short.parseShort(quantPercent);
			if (numValuePercentage <= 0) {
					numValuePercentage = 0;
					quantPercent = "0";
					quantPercentageIsZero = true;
			} else if (numValuePercentage > 100) {
					numValuePercentage = 100;
					quantPercent = "100";
			}
			paraQuantPercentage = numValuePercentage;
	} catch (Exception e) {
			paraQuantPercentage = null;
			quantPercent = "100";
	}

	// Add
	boolean canExecuteAdd = (activityXri != null) &&
													(resourceXri != null) &&
													(startedAt != null) &&
													(
														(
															(isWorkRecord && !isWorkRecordInPercent) &&
															(paraEffortHH != null) &&
															(paraEffortMM != null)
														)
														||
														(
															(isWorkRecord && isWorkRecordInPercent) &&
															(paraQuantPercentage != null) &&
															!quantPercentageIsZero
														)
														||
														(
															!isWorkRecord &&
															(paraRate != null) &&
															!quantityIsZero &&
															(uomXri != null) && (uomXri.length() > 0)
														)
													);
	if (canExecuteAdd && ((name == null) || (name.length() == 0))) {
			canExecuteAdd = false;
			creationFailed = true; // emulate creation failure to show warning sign next to add button
	}

	boolean createdWorkRecordInPercent = false;
	
	if(actionAdd && canExecuteAdd) {
			creationFailed = true;
			try {
					org.opencrx.kernel.activity1.jmi1.WorkAndExpenseRecord workAndExpenseRecord = null;
					if (isWorkRecord) {
							// add WorkRecord
							if (endedAt == null && !isWorkRecordInPercent) {
									// calculate as startedAt + paraEffort
									endedAt = (GregorianCalendar)startedAt.clone();
									endedAt.add(GregorianCalendar.HOUR_OF_DAY, paraEffortHH);
									endedAt.add(GregorianCalendar.MINUTE, paraEffortMM);
							}
							org.opencrx.kernel.activity1.jmi1.ActivityAddWorkRecordParams params = null;
							
							if (isWorkRecordInPercent) {
								createdWorkRecordInPercent = true;
								params = org.opencrx.kernel.utils.Utils.getActivityPackage(pm).createActivityAddWorkRecordParams(
										(short)0, // depotSelector
										((description != null) && (description.length() == 0) ? null : description),
										paraQuantPercentage,
										null,
										null,
										false,
										((name != null) && (name.length() == 0) ? null : name),
										null, // owningGroups
										null,
										new Short((short)0),
										Short.parseShort(recordType),
										(org.opencrx.kernel.activity1.jmi1.Resource)pm.getObjectById(new Path(resourceXri)),
										startedAt.getTime()
								);
							} else {
								params = org.opencrx.kernel.utils.Utils.getActivityPackage(pm).createActivityAddWorkRecordParams(
										(short)0, // depotSelector
										((description != null) && (description.length() == 0) ? null : description),
										paraEffortHH,
										paraEffortMM,
										(endedAt != null ? endedAt.getTime() : null),
										((isBillable != null) && (isBillable.length() > 0)),
										((name != null) && (name.length() == 0) ? null : name),
										null, // owningGroups
										paraRate,
										Short.parseShort(billingCurrency),
										Short.parseShort(recordType),
										(org.opencrx.kernel.activity1.jmi1.Resource)pm.getObjectById(new Path(resourceXri)),
										startedAt.getTime()
								);
							}
							pm.currentTransaction().begin();
							org.opencrx.kernel.activity1.jmi1.AddWorkAndExpenseRecordResult result = ((org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(new Path(activityXri))).addWorkRecord(params);
							pm.currentTransaction().commit();
							workAndExpenseRecord = (org.opencrx.kernel.activity1.jmi1.WorkAndExpenseRecord)pm.getObjectById(result.getWorkRecord().refGetPath());
							if (isWorkRecordInPercent) {
								pm.currentTransaction().begin();
								workAndExpenseRecord.setQuantityUom(uomPercent);
								workAndExpenseRecord.setEndedAt(null);
								pm.currentTransaction().commit();
							}
					} else {
							// add ExpenseRecord
							if (endedAt == null) {
									// set endedAt = startedAt
									endedAt = (GregorianCalendar)startedAt.clone();
							}
							org.opencrx.kernel.activity1.jmi1.ActivityAddExpenseRecordParams params = org.opencrx.kernel.utils.Utils.getActivityPackage(pm).createActivityAddExpenseRecordParams(
										(short)0, // depotSelector
										((description != null) && (description.length() == 0) ? null : description),
										(endedAt != null ? endedAt.getTime() : null),
										((isBillable != null) && (isBillable.length() > 0)),
										((isReimbursable != null) && (isReimbursable.length() > 0)),
										((name != null) && (name.length() == 0) ? null : name),
										null, // owningGroups
										Short.parseShort(paymentType),
										paraQuantity,
										(org.opencrx.kernel.uom1.jmi1.Uom)pm.getObjectById(new Path(uomXri)),
										paraRate,
										Short.parseShort(billingCurrency),
										Short.parseShort(recordType),
										(org.opencrx.kernel.activity1.jmi1.Resource)pm.getObjectById(new Path(resourceXri)),
										startedAt.getTime()
							);
							pm.currentTransaction().begin();
							org.opencrx.kernel.activity1.jmi1.AddWorkAndExpenseRecordResult result = ((org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(new Path(activityXri))).addExpenseRecord(params);
							pm.currentTransaction().commit();
							workAndExpenseRecord = (org.opencrx.kernel.activity1.jmi1.WorkAndExpenseRecord)pm.getObjectById(result.getWorkRecord().refGetPath());
					}
					lastCreatedWorkRecordXri = workAndExpenseRecord.refMofId();
					creationFailed = false;
					if (makePrivate != null && makePrivate.length() > 0) {
							List newOwningGroups = new ArrayList();
							org.opencrx.kernel.base.jmi1.BasePackage basePkg = org.opencrx.kernel.utils.Utils.getBasePackage(pm);
							// remove all OwningGroups that are not private
							for (
								Iterator i = workAndExpenseRecord.getOwningGroup().iterator();
								i.hasNext();
							) {
									org.opencrx.security.realm1.jmi1.PrincipalGroup currentPrincipalGroup =
											(org.opencrx.security.realm1.jmi1.PrincipalGroup)i.next();
									if (currentPrincipalGroup.getName() != null && (currentPrincipalGroup.getName().toUpperCase().indexOf(PRIVATE_TOKEN) >= 0)) {
											newOwningGroups.add(currentPrincipalGroup);
									}
							}

							// determine primary owning group of principal (if inferrable from Resource)
							String userName = null;
							org.opencrx.security.realm1.jmi1.PrincipalGroup resourcePrincipalGroup = null;
							try {
									org.opencrx.kernel.home1.jmi1.Segment homeSegment =
											(org.opencrx.kernel.home1.jmi1.Segment)pm.getObjectById(
												new Path("xri:@openmdx:org.opencrx.kernel.home1/provider/" + providerName + "/segment/" + segmentName)
											);
									userName = getUsername(pm, homeSegment, (org.opencrx.kernel.activity1.jmi1.Resource)pm.getObjectById(new Path(resourceXri)));
									org.openmdx.security.realm1.jmi1.Realm realm = org.opencrx.kernel.backend.SecureObject.getInstance().getRealm(
											pm,
											providerName,
											segmentName
										);
									if (userName != null) {
											resourcePrincipalGroup = findPrincipalGroup(userName + ".Group", realm, pm);
											if (resourcePrincipalGroup != null) {
												newOwningGroups.add(resourcePrincipalGroup);
											}
									}
							} catch (Exception e) {
									new ServiceException(e).log();
							}

							// set new OwningGroups
							pm.currentTransaction().begin();
							org.opencrx.kernel.base.jmi1.ModifyOwningGroupsParams replaceOwningGroupsParams = basePkg.createModifyOwningGroupsParams(
									newOwningGroups,
									(short)1 // recursive
								);
							workAndExpenseRecord.replaceOwningGroup(replaceOwningGroupsParams);
							pm.currentTransaction().commit();
					}
			} catch (Exception e) {
					createdWorkRecordInPercent = false;
					try {
							pm.currentTransaction().rollback();
					} catch (Exception er) {}
					errorMsg += "could not create Work / Expense Record<br>";
					new ServiceException(e).log();
			}
			//app.resetPmData();
	}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html dir="<%= texts.getDir() %>">
<head>
	<title>openCRX - Create Work/Expense Record</title>
	<meta name="label" content="Create Work/Expense Record">
	<meta name="toolTip" content="Create Work/Expense Record">
	<meta name="targetType" content="_self">
	<meta name="forClass" content="org:opencrx:kernel:activity1:Segment">
	<meta name="forClass" content="org:opencrx:kernel:activity1:Resource">
	<meta name="forClass" content="org:opencrx:kernel:activity1:ResourceAssignment">
	<meta name="forClass" content="org:opencrx:kernel:activity1:ActivityTracker">
	<meta name="forClass" content="org:opencrx:kernel:activity1:ActivityCategory">
	<meta name="forClass" content="org:opencrx:kernel:activity1:ActivityMilestone">
	<meta name="forClass" content="org:opencrx:kernel:activity1:Absence">
	<meta name="forClass" content="org:opencrx:kernel:activity1:EMail">
	<meta name="forClass" content="org:opencrx:kernel:activity1:Incident">
	<meta name="forClass" content="org:opencrx:kernel:activity1:Mailing">
	<meta name="forClass" content="org:opencrx:kernel:activity1:Meeting">
	<meta name="forClass" content="org:opencrx:kernel:activity1:SalesVisit">
	<meta name="forClass" content="org:opencrx:kernel:activity1:PhoneCall">
	<meta name="forClass" content="org:opencrx:kernel:activity1:Task">
	<meta name="forClass" content="org:opencrx:kernel:activity1:ExternalActivity">
	<meta name="forClass" content="org:opencrx:kernel:account1:Contact">
	<meta name="forClass" content="org:opencrx:kernel:home1:UserHome">
	<meta name="order" content="4998">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<link href="../../_style/colors.css" rel="stylesheet" type="text/css">
	<link href="../../_style/n2default.css" rel="stylesheet" type="text/css">
	<link href="../../_style/ssf.css" rel="stylesheet" type="text/css">
	<link rel='shortcut icon' href='../../images/favicon.ico' />
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

		function timeTick(hh_mm, upMins) {
			var right_now = new Date();
			var hrs = right_now.getHours();
			var mins = right_now.getMinutes();
			try {
				timeStr = hh_mm.split(":");
				hrsStr = timeStr[0];
				minsStr = timeStr[1];
			} catch (e) {}
			try {
				hrs = parseInt(hrsStr, 10);
			} catch (e) {}
			if (isNaN(hrs)) {hrs=12;}
			try {
				mins = parseInt(minsStr, 10);
				mins = parseInt(mins/15, 10)*15;
			} catch (e) {}
			if (isNaN(mins)) {mins=00;}
			mins = hrs*60 + mins + upMins;
			while (mins <			0) {mins += 24*60;}
			while (mins >= 24*60) {mins -= 24*60;}
			hrs = parseInt(mins/60, 10);
			if (hrs < 10) {
				hrsStr = "0" + hrs;
			} else {
				hrsStr = hrs;
			}
			mins -= hrs*60;
			if (mins < 10) {
				minsStr = "0" + mins;
			} else {
				minsStr = mins;
			}
			return hrsStr + ":" + minsStr;
		}

		function percentageTick(currentVal, upVal) {
			try {
				pVal = parseInt(currentVal, 10);
			} catch (e) {}
			if (isNaN(pVal)) {pVal=100;}
			if (upVal > 0) {
				if (pVal + upVal > 100) {
					pVal = 100;
				} else {
					pVal = pVal + upVal;
				}
			}
			if (upVal < 0) {
				if (pVal + upVal < 0) {
					pVal = 0;
				} else {
					pVal = pVal + upVal;
				}
			}
			return pVal;
		}

		var oldValue = "";
		function positiveDecimalsVerify(caller){
			var newValue = caller.value;
			var isOK = true;
			var i = 0;
			while ((isOK) && (i < newValue.length)) {
				var char = newValue.substring(i,i+1);
				if ((char!='.') && ((char<'0') || (char>'9'))) {isOK = false;}
				i++;
			}
			if (!isOK) {
				caller.value = oldValue;
			}
		}

	</script>

	<style type="text/css" media="all">
		fieldset{
			margin: 0px 10px 20px 0px;
			padding: 5px 0px 5px 15px;
			-moz-border-radius: 10px;
			-webkit-border-radius: 10px;
			border: 1.5px solid #DDD;
			background-color: #EEE;
		}
		.small{font-size:8pt;}
		#wizMonth {
			text-align:center;
			white-space:nowrap;
		}
		input.error{background-color:red;}
		#scheduleTable, .fieldGroup {
			border-collapse: collapse;
			border-spacing:0;
		}
		.fieldGroup TR TD {padding:2px 0px;}
		#scheduleTable td {
			vertical-align:top;
		}
		#scheduleTable TD.timelabel {
			background-color:#FFFE70;
			vertical-align:middle;
			border-top:1px solid #B3D7C3;
			border-bottom:1px solid #B3D7C3;
			border-left:1px solid #B3D7C3;
			white-space:nowrap;
			padding:5px;
		}
		#scheduleTable TD.time {
			background-color:#FFFE70;
			vertical-align:middle;
			border-top:1px solid #B3D7C3;
			border-right:1px solid #B3D7C3;
			border-bottom:1px solid #B3D7C3;
			white-space:nowrap;
			padding:5px;
			overflow:hidden;
		}
		TD.smallheader{border-bottom:1px solid black;padding:0px 8px 0px 0px;font-weight:bold;}
		TD.smallheaderR{border-bottom:1px solid black;padding:0px 16px 0px 0px;font-weight:bold;text-align:right;}
		TD.miniheader{font-size:7pt;}
		TD.padded{padding:0px 15px 0px 0px;}
		TD.padded_l{padding:0px 15px 0px 15px;text-align:left;}
		TD.padded_r{padding:0px 15px 0px 0px;text-align:right;}
		TR.centered TD {text-align:center;}
		TR.leftaligned TD {text-align:left;}
		TR.even TD {background-color:#EEEEFF;}
		TR.match TD {background-color:#FFFE70;}
		TR.created TD {background-color:#B4FF96;font-weight:bold;}
		TD.error {color:red;font-weight:bold;}
		input.outofmonth {
			background-color:#F3F3F3;
		}
		input.outofmonth:hover {
			background-color:#80FF00;
		}
		input.selectedday {
			background-color:#FFFE70;
		}
		input.selectedday:hover {
			background-color:#80FF00;
		}
		input.selectedweek {
			background-color:#9797FF;
		}
		input.selectedweek:hover {
			background-color:#80FF00;
		}
		input.bookable {
			background-color:#C1C1FF;
		}
		input.bookable:hover {
			background-color:#80FF00;
		}
		input.booked {
			background-color:#80FF00;
		}
		input.booked:hover {
			background-color:#FF9900;
		}
		input.disabled {
			background-color:transparent;
		}
		input.disabled:hover {
			background-color:transparent;
		}
		.hidden {
			display:none;
		}
		input.time {
			width: 20px;
			text-align:right;
			font-weight:bold;
		}
		input.percentage {
			width: 25px;
			text-align:right;
			font-weight:bold;
		}
		.timeButtonL {
			cursor:pointer;
			padding:0px 0px 2px 10px;
			vertical-align:bottom;
		}
		.timeButtonR {
			cursor:pointer;
			padding:0px 10px 2px 0px;
			vertical-align:bottom;
		}
		input.quantity {
			width: 50px;
			text-align:right;
			font-weight:bold;
		}
	</style>

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
				<div id="aPanel">
					<div id="inspector">
						<div class="inspTabPanel" style="z-index: 201;">
							<a class="<%= isWorkRecord && !isWorkRecordInPercent ? "selected" : "" %>" onclick="$('isExpenseRecord').value='';$('isWorkRecordInPercent').value='';										 $('reload.button').click();" href="#">Work Report</a>
							<a class="<%= isWorkRecordInPercent									? "selected" : "" %>" onclick="$('isExpenseRecord').value='';$('isWorkRecordInPercent').value='isWorkRecordInPercent';$('reload.button').click();" href="#">Work Report in %</a>
							<a class="<%= isWorkRecord													 ? "" : "selected" %>" onclick="$('isExpenseRecord').value='isExpenseRecord';$('isWorkRecordInPercent').value='';			$('reload.button').click();" href="#">Expense Report</a>
						</div>
						<div id="inspContent" class="inspContent" style="z-index: 200;">
							<div id="inspPanel0" class="selected" style="padding-top: 10px;">


				<form name="<%= FORM_NAME %>" accept-charset="UTF-8" method="POST" action="<%= WIZARD_NAME %>">
					<input type="hidden" name="command" id="command" value="none"/>
					<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
					<input type="hidden" name="<%= Action.PARAMETER_OBJECTXRI %>" value="<%= objectXri %>" />
					<input type="hidden" name="selectedDateStr" id="selectedDateStr" value="<%= selectedDateStr %>" />
					<input type="hidden" name="isExpenseRecord" id="isExpenseRecord" value="<%= isWorkRecord ? "" : "isExpenseRecord"	%>" />
					<input type="hidden" name="isWorkRecordInPercent" id="isWorkRecordInPercent" value="<%= !isWorkRecordInPercent ? "" : "isWorkRecordInPercent"	%>" />
					<input type="hidden" name="hasProjects" id="hasProjects" value="<%= hasProjects ? "hasProjects" : ""	%>" />
					<input type="hidden" name="isContactChange" id="isContactChange" value="" />
					<input type="hidden" name="isResourceChange" id="isResourceChange" value="" />
					<input type="hidden" name="resetActivityXri" id="resetActivityXri" value="" />
					<input type="hidden" name="activitySortOrder" id="activitySortOrder" value="<%= activitySortOrder %>" />
					<input type="checkbox" style="display:none;" id="isFirstCall" name="isFirstCall" checked="true" />
					<input type="hidden" name="deleteWorkRecordXri" id="deleteWorkRecordXri" value="" />
					<input type="hidden" name="lastCreatedWorkRecordXri" value="<%= lastCreatedWorkRecordXri %>" />
					<input type="hidden" name="lastCreatedExpenseRecordXri" value="<%= lastCreatedExpenseRecordXri %>" />
					<input type="hidden" name="lastFocusId" id="lastFocusId" value="<%= lastFocusId %>" />

					<input style="position:absolute;left:-500px;" type="submit" id="reload.button" name="reload.button" tabindex="<%= tabIndex++ %>" value="<%= app.getTexts().getReloadText() %>" onclick="<%= SUBMIT_HANDLER %>" />

					<table id="scheduleTable">
						<tr>
							<td style="width:240px;">
								<!--	Calendar -->
								<table>
									<tr><td>
										<div id="wizMonth" style="width:100%;">
											<table style="width:100%;">
												<tr>
													<td>
														<input id="Button.PrevYear" name="PrevYear" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&lt;&lt;" onclick="<%= SUBMIT_HANDLER %>" />
														<input id="Button.PrevMonth" name="PrevMonth" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&nbsp;&nbsp;&lt;&nbsp;"	onclick="<%= SUBMIT_HANDLER %>" />
													</td>
													<td style="width:100%;vertical-align:middle;">
														<span style="font-weight:bold;">&nbsp;<%= monthFormat.format(calendar.getTime()) + " " + calendarYear %>&nbsp;</span>
													</td>
													<td>
														<input id="Button.NextMonth" name="NextMonth" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&nbsp;&gt;&nbsp;&nbsp;" onclick="<%= SUBMIT_HANDLER %>" />
														<input id="Button.NextYear" name="NextYear" type="submit" tabindex="<%= tabIndex++ %>" class="abutton" value="&gt;&gt;" onclick="<%= SUBMIT_HANDLER %>" />
													</td>
												</tr>
											</table>
										</div>
									</td></tr>
									<tr><td>
										<table id="calWizard" cellspacing="1">
											<thead>
												<tr>
													<th style="text-align:center;padding:0px 10px;cursor:pointer;" title="today" onclick="javascript:$('selectedDateStr').value='<%= todayStr %>';$('reload.button').click();">#</th>
<%
													GregorianCalendar dayInWeekCalendar = (GregorianCalendar)calendar.clone();
													while(dayInWeekCalendar.get(GregorianCalendar.DAY_OF_WEEK) != dayInWeekCalendar.getFirstDayOfWeek()) {
														dayInWeekCalendar.add(GregorianCalendar.DAY_OF_MONTH, 1);
													}
													for(int i = 0; i < 7; i++) {
%>
														<th style="text-align:right;"><%= dayInWeekFormat.format(dayInWeekCalendar.getTime()) %>&nbsp;</th>
<%
														dayInWeekCalendar.add(GregorianCalendar.DAY_OF_MONTH, 1);
													}
%>
												</tr>
											</thead>
											<tbody>
<%
												int selectedWeekOfYear = -1;
												if (selectedDateStr != null) {
														selectedWeekOfYear = getDateAsCalendar(selectedDateStr, app).get(GregorianCalendar.WEEK_OF_YEAR);
												}
												GregorianCalendar calendarPrevMonth = new GregorianCalendar(app.getCurrentLocale());
												calendarPrevMonth.setTimeZone(TimeZone.getTimeZone(app.getCurrentTimeZone()));
												calendarPrevMonth.setMinimalDaysInFirstWeek(4); // this conforms to DIN 1355/ISO 8601
												calendarPrevMonth.set(GregorianCalendar.YEAR, calendarYear);
												calendarPrevMonth.set(GregorianCalendar.MONTH, calendarMonth);
												calendarPrevMonth.set(GregorianCalendar.DAY_OF_MONTH, 1);
												while (calendarPrevMonth.get(GregorianCalendar.DAY_OF_WEEK) != calendarPrevMonth.getFirstDayOfWeek()) {
														calendarPrevMonth.add(GregorianCalendar.DAY_OF_MONTH, -1);
												}
												while(calendar.get(GregorianCalendar.MONTH) == calendarMonth) {
%>
													<tr>
														<td style="text-align:right;font-size:6pt;vertical-align:middle;padding:0px 10px;"><%= calendar.get(GregorianCalendar.WEEK_OF_YEAR) %></td>
<%
														for(int i = 0; i < 7; i++) {
															dayOfMonth = calendar.get(GregorianCalendar.DAY_OF_MONTH);
															if(((i + calendar.getFirstDayOfWeek() - 1) % 7 + 1) != calendar.get(GregorianCalendar.DAY_OF_WEEK)) {
																int prevMonthDayOfMonth = calendarPrevMonth.get(GregorianCalendar.DAY_OF_MONTH);
																String cssClass = selectedWeekOfYear == calendarPrevMonth.get(GregorianCalendar.WEEK_OF_YEAR)
																	? "selectedweek"
																	: "outofmonth";
%>
																<td style="text-align:right;"><input id="SelectDateP.<%= prevMonthDayOfMonth %>.Button" tabindex="<%= tabIndex++ %>" name="SelectDateP.<%= prevMonthDayOfMonth %>" type="submit" class="abutton <%= cssClass %>" value="&nbsp;<%= prevMonthDayOfMonth < 10 ? "&nbsp; " : "" %><%= prevMonthDayOfMonth %>&nbsp;" onclick="<%= SUBMIT_HANDLER %>" /></td>
<%
																calendarPrevMonth.add(GregorianCalendar.DAY_OF_MONTH, 1);
															}
															else {
																String dateAsString = getDateAsString(
																	calendarYear,
																	calendarMonth+1,
																	dayOfMonth
																);
																String cssClass = (selectedDateStr != null) && (selectedDateStr.compareTo(dateAsString) == 0)
																	? (calendar.get(GregorianCalendar.MONTH) != calendarMonth ? "outofmonth" : "selectedday")
																	: (selectedWeekOfYear == calendar.get(GregorianCalendar.WEEK_OF_YEAR)
																			? "selectedweek"
																			: (calendar.get(GregorianCalendar.MONTH) != calendarMonth ? "outofmonth" : "bookable")
																		 );
																String buttonName = calendar.get(GregorianCalendar.MONTH) != calendarMonth
																	? "SelectDateN"
																	: "SelectDate";
%>
																<td style="text-align:right;"><input id="<%= buttonName %>.<%= dayOfMonth %>.Button" tabindex="<%= tabIndex++ %>" name="<%= buttonName %>.<%= dayOfMonth %>" type="submit" class="abutton <%= cssClass %>" value="&nbsp;<%= dayOfMonth < 10 ? "&nbsp; " : "" %><%= dayOfMonth %>&nbsp;" onclick="<%= SUBMIT_HANDLER %>" /></td>
<%
																calendar.add(GregorianCalendar.DAY_OF_MONTH, 1);
															}
														}
%>
													</tr>
<%
												}
%>
											</tbody>
										</table>
									</td></tr>
								</table>
							</td>
							<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
							<td style="width:100%;">
								<fieldset>
								<table class="fieldGroup">
									<tr>
										<td class="label"><span class="nw"><%= app.getLabel(CONTACT_CLASS) %>:</span></td>
<%
										tabIndex = 1;
										String lookupId = org.opencrx.kernel.backend.Accounts.getInstance().getUidAsString();
										Action findContactTargetObjectAction = Action.getFindObjectAction(contactTargetFinder, lookupId);
										String accountName = app.getLabel(CONTACT_CLASS);
%>
										<td>
											<div class="autocompleterMenu">
												<ul id="nav" class="nav" onmouseover="sfinit(this);" >
													<li><a href="#"><img border="0" alt="" src="../../images/autocomplete_select.png" /></a>
														<ul onclick="this.style.left='-999em';" onmouseout="this.style.left='';">
															<li class="selected"><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Contact)*filterByFeature*(fullName)*filterOperator*(IS_LIKE)*orderByFeature*(fullName)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(ACCOUNT_CLASS, "fullName", app.getCurrentLocaleAsIndex()) %></a></li>
															<li <%= userView.getFieldLabel(ACCOUNT_CLASS, "description", app.getCurrentLocaleAsIndex()) == null ? "style='display:none;" : "" %>><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Contact)*filterByFeature*(description)*filterOperator*(IS_LIKE)*orderByFeature*(description)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(ACCOUNT_CLASS, "description", app.getCurrentLocaleAsIndex()) %></a></li>
															<li <%= userView.getFieldLabel(ACCOUNT_CLASS, "aliasName", app.getCurrentLocaleAsIndex()) == null ? "style='display:none;" : "" %>><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Contact)*filterByFeature*(aliasName)*filterOperator*(IS_LIKE)*orderByFeature*(aliasName)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(ACCOUNT_CLASS, "aliasName", app.getCurrentLocaleAsIndex()) %></a></li>
															<li><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Contact)*filterByFeature*(firstName)*filterOperator*(IS_LIKE)*orderByFeature*(firstName)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(CONTACT_CLASS, "firstName", app.getCurrentLocaleAsIndex()) %></a></li>
															<li><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Contact)*filterByFeature*(middleName)*filterOperator*(IS_LIKE)*orderByFeature*(middleName)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(CONTACT_CLASS, "middleName", app.getCurrentLocaleAsIndex()) %></a></li>
															<li><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Contact)*filterByFeature*(lastName)*filterOperator*(IS_LIKE)*orderByFeature*(lastName)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(CONTACT_CLASS, "lastName", app.getCurrentLocaleAsIndex()) %></a></li>
															<li <%= userView.getFieldLabel(CONTACT_CLASS, "nickName", app.getCurrentLocaleAsIndex()) == null ? "style='display:none;" : "" %>><a href="#" onclick="javascript:navSelect(this);ac_addObject0.url= './'+getEncodedHRef(['../../ObjectInspectorServlet', 'event', '40', 'parameter', 'xri*(xri:@openmdx:org.opencrx.kernel.account1/provider/<%= providerName %>/segment/<%= segmentName %>)*referenceName*(account)*filterByType*(org:opencrx:kernel:account1:Contact)*filterByFeature*(nickName)*filterOperator*(IS_LIKE)*orderByFeature*(nickName)*position*(0)*size*(20)']);return false;"><span>&nbsp;&nbsp;&nbsp;</span><%= accountName %> / <%= userView.getFieldLabel(CONTACT_CLASS, "nickName", app.getCurrentLocaleAsIndex()) %></a></li>
														</ul>
													</li>
												</ul>
											</div>
											<div class="autocompleterInput"><input type="text" class="valueL mandatory valueAC <%= contact == null ? "inputError" : "" %>" id="contactXri.Title" name="contactXri.Title" tabindex="<%= tabIndex++ %>" value="<%= contactXriTitle != null ? contactXriTitle : "" %>" onfocus="<%= ONFOCUS_HANDLER %>" /></div>
											<input type="hidden" class="valueLLocked" id="contactXri" readonly="true" name="contactXri" value="<%= contactXri != null ? contactXri : "" %>" />
											<div class="autocomplete" id="contact.Update" style="display:none;z-index:500;"></div>
											<script type="text/javascript" language="javascript" charset="utf-8">
												function afterUpdateReload(titleField, selectedItem) {
														updateXriField(titleField, selectedItem);
														$('isContactChange').value="true";
														$('resetActivityXri').value='true';
														$('reload.button').click();
												}
												ac_addObject0 = new Ajax.Autocompleter(
													'contactXri.Title',
													'contact.Update',
													'../../ObjectInspectorServlet?event=40&parameter=xri*%28xri%3A%40openmdx%3Aorg.opencrx.kernel.account1%2Fprovider%2F<%= providerName %>%2Fsegment%2F<%= segmentName %>%29*referenceName*%28account%29*filterByType*%28org%3Aopencrx%3Akernel%3Aaccount1%3AContact%29*filterByFeature*%28fullName%29*filterOperator*%28IS_LIKE%29*orderByFeature*%28fullName%29*position*%280%29*size*%2820%29',
													{
														paramName: 'filtervalues',
														minChars: 0,
														afterUpdateElement: afterUpdateReload
													}
												);
											</script>
										</td>
										<td class="addon">
											<img class="popUpButton" border="0" alt="" src="../../images/closeInsp.gif" style="float:right;" onclick="javascript:$('contactXri').value='*';$('isContactChange').value='true';$('contactXri.Title').value='*';$('resetActivityXri').value='true';$('reload.button').click();" />
											<img class="popUpButton" border="0" align="bottom" alt="Click to open ObjectFinder" src="../../images/lookup.gif" onclick="OF.findObject('../../<%= findContactTargetObjectAction.getEncodedHRef() %>', $('contactXri.Title'), $('contactXri'), '<%= lookupId %>');$('isContactChange').value='true';" />
										</td>
									</tr>
									<tr>
										<td class="label">
											<span class="nw"><%= app.getLabel(RESOURCE_CLASS) %>:</span>
										</td>
										<td>
<%
											boolean noResourcesFound = false;
											org.opencrx.kernel.activity1.cci2.ResourceQuery resourceFilter = activityPkg.createResourceQuery();
											if (!showAllResources) {
													resourceFilter.thereExistsContact().equalTo(contact);
											}
											resourceFilter.forAllDisabled().isFalse();
											resourceFilter.orderByName().ascending();
											resourceFilter.orderByDescription().ascending();
											List resources = activitySegment.getResource(resourceFilter);
											if (resources.isEmpty()) {
													errorMsg += "no matching resource found!<br>";
													noResourcesFound = true;
													resourceXri = "";
%>
													<select id="resourceXri" name="resourceXri" class="valueL" <%= errorStyle %> tabindex="<%= tabIndex++ %>" onfocus="<%= ONFOCUS_HANDLER %>">
														<option value="">--</option>
													</select>
<%
											} else {
												if (resourceXri == null) {mustReload = true;}
%>
												<select id="resourceXri" name="resourceXri" class="valueL" tabindex="<%= tabIndex++ %>" onchange="javascript:$('isResourceChange').value='true';$('resetActivityXri').value='true';$('reload.button').click();" onfocus="<%= ONFOCUS_HANDLER %>">
<%
													for (
															Iterator i = resources.iterator();
															i.hasNext();
													) {
															org.opencrx.kernel.activity1.jmi1.Resource res = (org.opencrx.kernel.activity1.jmi1.Resource)i.next();
															String contactTitle = "--";
															try {
																	contactTitle = app.getHtmlEncoder().encode(new ObjectReference(res.getContact(), app).getTitle(), false);
															} catch (Exception e) {}
															if (((resourceXri == null) || (resourceXri.length() == 0)) && (!showAllResourcesOfContact)) {
																	resourceXri = res.refMofId();
															}
%>
															<option <%= (resourceXri != null) && (resourceXri.compareTo(res.refMofId()) == 0) ? "selected" : "" %> value="<%= res.refMofId() %>"><%= res.getName() != null ? app.getHtmlEncoder().encode(res.getName(), false) : contactTitle %><%= showAllResources ? " [" + contactTitle + "]" : "" %></option>
<%
													}
%>
												</select>
<%
											}
%>
											<input type="hidden" name="previousResourceXri" value="<%= resourceXri %>" />
										</td>
										<td class="addon">
												<%= noResourcesFound ? CAUTION : "" %>
										</td>
									</tr>

									<tr>
										<td class="label">
											<span class="nw"><%= app.getLabel(ACTIVITYFILTERGROUP_CLASS) %>:</span>
										</td>
										<td nowrap>
<%

											Map projectNames = new TreeMap();
											Iterator projectMainIterator = null;
											Iterator activityFilterIterator = null;
											Map orderedActivityGroups = new TreeMap();

											List activities = null;
											boolean openOnly = (excludeClosedActivities != null) && (excludeClosedActivities.length() > 0);
											org.opencrx.kernel.activity1.cci2.ActivityQuery activityQuery = activityPkg.createActivityQuery();
											activityQuery.forAllDisabled().isFalse();
											if (openOnly) {
												activityQuery.activityState().lessThan(
													new Short((short)20) // Status "not closed"
												);
											}
											switch (activitySortOrder) {
													case	0: activityQuery.orderByActivityNumber().ascending(); break;
													case	1: activityQuery.orderByActivityNumber().descending(); break;
													case	2: activityQuery.orderByName().ascending(); break;
													case	3: activityQuery.orderByName().descending(); break;
													default: activityQuery.orderByActivityNumber().descending(); break;
											}

											if (ACTIVITY_FILTER_SEGMENT.compareTo(activityFilter) == 0) {
													activities = activitySegment.getActivity(activityQuery);
													activityGroup = null; // ensure that all activities are shown
											} else {
													int gCounter = 0;
													if (ACTIVITY_FILTER_ANYGROUP.compareTo(activityFilter) == 0) {
															// get ActivityTrackers
															org.opencrx.kernel.activity1.cci2.ActivityTrackerQuery trackerFilter = activityPkg.createActivityTrackerQuery();
															trackerFilter.forAllDisabled().isFalse();
															for(Iterator i = activitySegment.getActivityTracker(trackerFilter).iterator(); i.hasNext(); ) {
																	org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)i.next();
																	if (
																			(showActivityGroupNameFilter == null) || (showActivityGroupNameFilter.length() == 0) ||
																			(ag.getName() == null) || (ag.getName().toUpperCase().indexOf(filterActivityGroupName.toUpperCase()) >= 0)
																	) {
																			orderedActivityGroups.put(
																					(ag.getName() != null ? ag.getName() : "_?") + "		" + gCounter++,
																					ag
																				);
																	}
															}
															// get ActivityCategories
															org.opencrx.kernel.activity1.cci2.ActivityCategoryQuery categoryFilter = activityPkg.createActivityCategoryQuery();
															categoryFilter.forAllDisabled().isFalse();
															for(Iterator i = activitySegment.getActivityCategory(categoryFilter).iterator(); i.hasNext(); ) {
																	org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)i.next();
																	if (
																			(showActivityGroupNameFilter == null) || (showActivityGroupNameFilter.length() == 0) ||
																			(ag.getName() == null) || (ag.getName().toUpperCase().indexOf(filterActivityGroupName.toUpperCase()) >= 0)
																	) {
																			orderedActivityGroups.put(
																					(ag.getName() != null ? ag.getName() : "_?") + "		" + gCounter++,
																					ag
																				);
																	}
															}
															// get ActivityMilestones
															org.opencrx.kernel.activity1.cci2.ActivityMilestoneQuery milestoneFilter = activityPkg.createActivityMilestoneQuery();
															milestoneFilter.forAllDisabled().isFalse();
															for(Iterator i = activitySegment.getActivityMilestone(milestoneFilter).iterator(); i.hasNext(); ) {
																	org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)i.next();
																	if (
																			(showActivityGroupNameFilter == null) || (showActivityGroupNameFilter.length() == 0) ||
																			(ag.getName() == null) || (ag.getName().toUpperCase().indexOf(filterActivityGroupName.toUpperCase()) >= 0)
																	) {
																			orderedActivityGroups.put(
																					(ag.getName() != null ? ag.getName() : "_?") + "		" + gCounter++,
																					ag
																				);
																	}
															}
															activityFilterIterator = orderedActivityGroups.values().iterator();
													} else if (ACTIVITY_FILTER_PROJECT.compareTo(activityFilter) == 0) {
															// get projects, i.e. ActivityTrackers with userString0 != null
															org.opencrx.kernel.activity1.cci2.ActivityTrackerQuery trackerFilter = activityPkg.createActivityTrackerQuery();
															trackerFilter.forAllDisabled().isFalse();
															trackerFilter.thereExistsUserBoolean0().isTrue();
															trackerFilter.orderByUserString0().ascending();
															for(Iterator i = activitySegment.getActivityTracker(trackerFilter).iterator(); i.hasNext(); ) {
																	org.opencrx.kernel.activity1.jmi1.ActivityTracker at = (org.opencrx.kernel.activity1.jmi1.ActivityTracker)i.next();
																	if ((at.getUserString1() == null) || (at.getUserString1().length() == 0)) {
																		if ((projectMain.length() == 0) && (at.getUserString0() != null)) {
																				// set initial value of projectName
																				projectMain = at.getUserString0().trim();
																		}
																		projectNames.put(
																				(at.getUserString0() != null ? at.getUserString0().trim() : "_?"),
																				at
																			);
																	}
															}
															projectMainIterator = projectNames.values().iterator(); // all distinct project names

															trackerFilter = activityPkg.createActivityTrackerQuery();
															trackerFilter.forAllDisabled().isFalse();
															trackerFilter.userString1().isNonNull();
															trackerFilter.thereExistsUserString0().equalTo(projectMain);
															for(Iterator i = activitySegment.getActivityTracker(trackerFilter).iterator(); i.hasNext(); ) {
																	org.opencrx.kernel.activity1.jmi1.ActivityTracker at = (org.opencrx.kernel.activity1.jmi1.ActivityTracker)i.next();
																	if ((at.getUserString1() != null) && (at.getUserString1().length() > 0)) {
																		if (
																				(showActivityGroupNameFilter == null) || (showActivityGroupNameFilter.length() == 0) ||
																				(at.getUserString1().toUpperCase().indexOf(filterActivityGroupName.toUpperCase()) >= 0)
																		) {
																				orderedActivityGroups.put(
																						(at.getUserString1() != null ? at.getUserString1().trim() : "_?") + "		" + gCounter++,
																						at
																					);
																		}
																	}
															}
															activityFilterIterator = orderedActivityGroups.values().iterator();
													} else if (ACTIVITY_FILTER_TRACKER.compareTo(activityFilter) == 0) {
															// get ActivityTrackers
															org.opencrx.kernel.activity1.cci2.ActivityTrackerQuery trackerFilter = activityPkg.createActivityTrackerQuery();
															trackerFilter.forAllDisabled().isFalse();
															for(Iterator i = activitySegment.getActivityTracker(trackerFilter).iterator(); i.hasNext(); ) {
																	org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)i.next();
																	if (
																			(showActivityGroupNameFilter == null) || (showActivityGroupNameFilter.length() == 0) ||
																			(ag.getName() == null) || (ag.getName().toUpperCase().indexOf(filterActivityGroupName.toUpperCase()) >= 0)
																	) {
																			orderedActivityGroups.put(
																					(ag.getName() != null ? ag.getName() : "_?") + "		" + gCounter++,
																					ag
																				);
																	}
															}
															activityFilterIterator = orderedActivityGroups.values().iterator();
													} else if (ACTIVITY_FILTER_CATEGORY.compareTo(activityFilter) == 0) {
															// get ActivityCategories
															org.opencrx.kernel.activity1.cci2.ActivityCategoryQuery categoryFilter = activityPkg.createActivityCategoryQuery();
															categoryFilter.forAllDisabled().isFalse();
															for(Iterator i = activitySegment.getActivityCategory(categoryFilter).iterator(); i.hasNext(); ) {
																	org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)i.next();
																	if (
																			(showActivityGroupNameFilter == null) || (showActivityGroupNameFilter.length() == 0) ||
																			(ag.getName() == null) || (ag.getName().toUpperCase().indexOf(filterActivityGroupName.toUpperCase()) >= 0)
																	) {
																			orderedActivityGroups.put(
																					(ag.getName() != null ? ag.getName() : "_?") + "		" + gCounter++,
																					ag
																				);
																	}
															}
															activityFilterIterator = orderedActivityGroups.values().iterator();
													} else if (ACTIVITY_FILTER_MILESTONE.compareTo(activityFilter) == 0) {
															// get ActivityMilestones
															org.opencrx.kernel.activity1.cci2.ActivityMilestoneQuery milestoneFilter = activityPkg.createActivityMilestoneQuery();
															milestoneFilter.forAllDisabled().isFalse();
															for(Iterator i = activitySegment.getActivityMilestone(milestoneFilter).iterator(); i.hasNext(); ) {
																	org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)i.next();
																	if (
																			(showActivityGroupNameFilter == null) || (showActivityGroupNameFilter.length() == 0) ||
																			(ag.getName() == null) || (ag.getName().toUpperCase().indexOf(filterActivityGroupName.toUpperCase()) >= 0)
																	) {
																			orderedActivityGroups.put(
																					(ag.getName() != null ? ag.getName() : "_?") + "		" + gCounter++,
																					ag
																				);
																	}
															}
															activityFilterIterator = orderedActivityGroups.values().iterator();
													}

													tabIndex += 10;
													if (ACTIVITY_FILTER_PROJECT.compareTo(activityFilter) != 0) {
															if (activityFilterIterator == null || !activityFilterIterator.hasNext()) {
																activityGroup = null; // reset potentially existing selection
																errorMsg += "no activity groups found!<br>";
%>
																<select class="valueL" style="width:50%;float:right;" id="activityFilterXri" name="activityFilterXri" <%= errorStyle %> tabindex="<%= tabIndex+5 %>" onfocus="<%= ONFOCUS_HANDLER %>">
																	<option value="">--</option>
																</select>
<%
															} else {
%>
																<select class="valueL" style="width:50%;float:right;" id="activityFilterXri" name="activityFilterXri" tabindex="<%= tabIndex+5 %>" onchange="javascript:$('resetActivityXri').value='true';$('reload.button').click();" onfocus="<%= ONFOCUS_HANDLER %>">
<%
																	boolean hasSelection = false;
																	org.opencrx.kernel.activity1.jmi1.ActivityGroup firstAg = null;
																	while (activityFilterIterator.hasNext()) {
																			org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)activityFilterIterator.next();
																			if (
																					!EXCLUDE_ACTIVITYTRACKER_TEMPLATES || !(ag instanceof org.opencrx.kernel.activity1.jmi1.ActivityTracker) ||
																					((((org.opencrx.kernel.activity1.jmi1.ActivityTracker)ag).isUserBoolean1() == null) || (!((org.opencrx.kernel.activity1.jmi1.ActivityTracker)ag).isUserBoolean1().booleanValue()))
																			) {
																					boolean selected = false;
																					if ((activityFilterXri != null) && (activityFilterXri.compareTo(ag.refMofId()) == 0)) {
																							activityGroup = ag;
																							selected = true;
																							hasSelection = true;
																					}
																					if (firstAg == null) {
																							firstAg = ag;
																					}
%>
																					<option <%= (activityFilterXri != null) && (activityFilterXri.compareTo(ag.refMofId()) == 0) ? "selected" : "" %> value="<%= ag.refMofId() %>"><%= app.getHtmlEncoder().encode(ag.getName(), false) %></option>
<%
																			}
																	}
																	if (!hasSelection) {
																			activityGroup = firstAg; // to ensure proper location of activities
																			activityFilterXri = firstAg.refMofId();
																	}
%>
																</select>
<%
															}
													}
											}
%>
											<select class="valueL" style="width:<%= ACTIVITY_FILTER_SEGMENT.compareTo(activityFilter) == 0 || ACTIVITY_FILTER_PROJECT.compareTo(activityFilter) == 0 ? "100" : "49" %>%;float:left;" id="activityFilter" name="activityFilter" tabindex="<%= tabIndex++ %>" onchange="javascript:$('resetActivityXri').value='true';$('reload.button').click();" onfocus="<%= ONFOCUS_HANDLER %>">
												<option <%= ACTIVITY_FILTER_SEGMENT.compareTo(activityFilter)	== 0 ? "selected" : "" %> value="<%= ACTIVITY_FILTER_SEGMENT %>"	>*</option>
												<option <%= ACTIVITY_FILTER_ANYGROUP.compareTo(activityFilter)== 0 ? "selected" : "" %> value="<%= ACTIVITY_FILTER_ANYGROUP %>" ><%= app.getLabel(ACTIVITYTRACKER_CLASS) %> / <%= app.getLabel(ACTIVITYCATEGORY_CLASS) %> / <%= app.getLabel(ACTIVITYMILESTONE_CLASS) %></option>
<%
												if (hasProjects) {
%>
														<option <%= ACTIVITY_FILTER_PROJECT.compareTo(activityFilter)	 == 0 ? "selected" : "" %> value="<%= ACTIVITY_FILTER_PROJECT %>"	><%= app.getLabel(ACTIVITYTRACKER_CLASS) %> [<%= userView.getFieldLabel(ACTIVITYTRACKER_CLASS, "userBoolean0", app.getCurrentLocaleAsIndex()) %>]</option>
<%
												}
%>
												<option <%= ACTIVITY_FILTER_TRACKER.compareTo(activityFilter)	 == 0 ? "selected" : "" %> value="<%= ACTIVITY_FILTER_TRACKER %>"	><%= app.getLabel(ACTIVITYTRACKER_CLASS) %></option>
												<option <%= ACTIVITY_FILTER_CATEGORY.compareTo(activityFilter)	== 0 ? "selected" : "" %> value="<%= ACTIVITY_FILTER_CATEGORY %>" ><%= app.getLabel(ACTIVITYCATEGORY_CLASS) %></option>
												<option <%= ACTIVITY_FILTER_MILESTONE.compareTo(activityFilter) == 0 ? "selected" : "" %> value="<%= ACTIVITY_FILTER_MILESTONE %>"><%= app.getLabel(ACTIVITYMILESTONE_CLASS) %></option>
											</select>
										</td>
										<td class="addon">
												<input type="checkbox" id="showActivityGroupNameFilter" name="showActivityGroupNameFilter" <%= (showActivityGroupNameFilter != null) && (showActivityGroupNameFilter.length() > 0) ? "checked" : "" %> tabindex="<%= tabIndex++ %>" value="showActivityGroupNameFilter" onchange="javascript:$('reload.button').click();" onfocus="<%= ONFOCUS_HANDLER %>" />
										</td>
									</tr>
<%
									tabIndex += 10;
									if (hasProjects) {
										boolean isProject = ACTIVITY_FILTER_PROJECT.compareTo(activityFilter) == 0;
%>
										<tr <%= isProject ? "" : "style='display:none;'" %>>
											<td class="label">
												<span class="nw"><%= userView.getFieldLabel(ACTIVITYTRACKER_CLASS, "userBoolean0", app.getCurrentLocaleAsIndex()) %> - <%= userView.getFieldLabel(ACTIVITYTRACKER_CLASS, "userString1", app.getCurrentLocaleAsIndex()) %>:</span>
											</td>
											<td nowrap>
<%
												if (activityFilterIterator == null || !activityFilterIterator.hasNext()) {
														if (isProject) {
																activityGroup = null; // reset potentially existing selection
																errorMsg += "no activity groups found!<br>";
															}
%>
														<select class="valueL" style="width:50%;float:right;" id="activityFilterXri" name="activityFilterXri" class="valueL" <%= errorStyle %> tabindex="<%= tabIndex+5 %>" onfocus="<%= ONFOCUS_HANDLER %>">
															<option value="">--</option>
														</select>
<%
												} else {
%>
														<select class="valueL" style="width:50%;float:right;" id="activityFilterXri" name="activityFilterXri" tabindex="<%= tabIndex+5 %>" onchange="javascript:$('resetActivityXri').value='true';$('reload.button').click();" onfocus="<%= ONFOCUS_HANDLER %>">
<%
														boolean hasSelection = false;
														org.opencrx.kernel.activity1.jmi1.ActivityGroup firstAg = null;
														while (activityFilterIterator.hasNext()) {
																	org.opencrx.kernel.activity1.jmi1.ActivityGroup ag = (org.opencrx.kernel.activity1.jmi1.ActivityGroup)activityFilterIterator.next();
																	if (
																			!EXCLUDE_ACTIVITYTRACKER_TEMPLATES || !(ag instanceof org.opencrx.kernel.activity1.jmi1.ActivityTracker) ||
																			((((org.opencrx.kernel.activity1.jmi1.ActivityTracker)ag).isUserBoolean1() == null) || (!((org.opencrx.kernel.activity1.jmi1.ActivityTracker)ag).isUserBoolean1().booleanValue()))
																	) {
																			boolean selected = false;
																			if ((activityFilterXri != null) && (activityFilterXri.compareTo(ag.refMofId()) == 0)) {
																					activityGroup = ag;
																					selected = true;
																					hasSelection = true;
																			}
																			if (firstAg == null) {
																					firstAg = ag;
																			}
%>
																		<option <%= (activityFilterXri != null) && (activityFilterXri.compareTo(ag.refMofId()) == 0) ? "selected" : "" %> value="<%= ag.refMofId() %>"><%= app.getHtmlEncoder().encode(ag.getName(), false) %></option>
<%
																	}
															}
															if (!hasSelection) {
																	activityGroup = firstAg; // to ensure proper location of activities
																	activityFilterXri = firstAg.refMofId();
															}
%>
														</select>
<%
												}

												if (projectMainIterator == null || !projectMainIterator.hasNext()) {
														if (isProject) {
															errorMsg += "no main topics!<br>";
														}
%>
														<select id="projectMain" name="projectMain" class="valueL" style="width:49%;float:left;<%= errorStyleInline %>" tabindex="<%= tabIndex++ %>" onfocus="<%= ONFOCUS_HANDLER %>">
															<option value="">--</option>
														</select>
<%
												} else {
%>
														<select class="valueL" style="width:49%;float:left;" id="projectMain" name="projectMain" tabindex="<%= tabIndex++ %>" onchange="javascript:$('resetActivityXri').value='true';$('reload.button').click();" onfocus="<%= ONFOCUS_HANDLER %>">
<%
															while (projectMainIterator.hasNext()) {
																org.opencrx.kernel.activity1.jmi1.ActivityTracker at = (org.opencrx.kernel.activity1.jmi1.ActivityTracker)projectMainIterator.next();
																if (at.getUserString0() != null) {
%>
																	<option <%= (projectMain != null) && (projectMain.compareTo(at.getUserString0().trim()) == 0) ? "selected" : "" %> value="<%= app.getHtmlEncoder().encode(at.getUserString0().trim(), false) %>"><%= app.getHtmlEncoder().encode(at.getUserString0().trim(), false) %></option>
<%
																}
															}
%>
														</select>
<%
												}
%>
											</td>
											<td class="addon"></td>
										</tr>
<%
									}
									tabIndex += 10;
%>
									<tr <%= (showActivityGroupNameFilter != null) && (showActivityGroupNameFilter.length() > 0) ? "" : "style='display:none;'" %>>
										<td class="label">
											<span class="nw"><%= app.getLabel(ACTIVITYFILTERGLOBAL_CLASS) %>:</span>
										</td>
										<td>
											<input type="<%= ACTIVITY_FILTER_SEGMENT.compareTo(activityFilter) == 0 ? "hidden" : "text" %>" class="valueL" name="filterActivityGroupName" id="filterActivityGroupName" title="<%= userView.getFieldLabel(ACTIVITY_CLASS, "name", app.getCurrentLocaleAsIndex()) %> <%= userView.getFieldLabel(ACTIVITYGROUPASSIGNMENT_CLASS, "activityGroup", app.getCurrentLocaleAsIndex()) %>" <%= ACTIVITY_FILTER_SEGMENT.compareTo(activityFilter) == 0 ? "" : "style='width:50%;float:right;'" %> tabindex="<%= tabIndex+5 %>" value="<%= app.getHtmlEncoder().encode(filterActivityGroupName, false) %>" onchange="javascript:$('resetActivityXri').value='true';$('reload.button').click();" onfocus="<%= ONFOCUS_HANDLER %>" />
											<input type="text" class="valueL" name="filterActivityName" id="filterActivityName" title="<%= userView.getFieldLabel(ACTIVITY_CLASS, "name", app.getCurrentLocaleAsIndex()) %>" <%= ACTIVITY_FILTER_SEGMENT.compareTo(activityFilter) == 0 ? "" : "style='width:49%;float:left;'" %> tabindex="<%= tabIndex++ %>" value="<%= app.getHtmlEncoder().encode(filterActivityName, false) %>" onchange="javascript:$('resetActivityXri').value='true';$('reload.button').click();" onfocus="<%= ONFOCUS_HANDLER %>" />
										</td>
										<td class="addon"></td>
									</tr>

									<tr>
										<td class="label">
											<div style="float:right;">
													<img class="timeButtonL" border="0" title=">" alt="" src="../../images/filter_down_star.gif" onclick="javascript:$('activitySortOrder').value = '<%= (activitySortOrder + 1) % MAX_ACTIVITY_SORT_ORDER %>';$('reload.button').click();" />
											</div>
											<span class="nw"><%= app.getLabel(ACTIVITYSEGMENT_CLASS) %>:</span>
										</td>
										<td>
<%
											tabIndex += 10;
											boolean noActivitiesFound = false;
											if (activityGroup != null) {
												activities = activityGroup.getFilteredActivity(activityQuery);
											}
											boolean hasActivitySelection = false;
											String firstActivityXri = null;
%>
											<select id="activityXri" name="activityXri" class="valueL" tabindex="<%= tabIndex++ %>" onchange="javascript:$('reload.button').click();" onfocus="<%= ONFOCUS_HANDLER %>">
<%
												if (activities == null || activities.isEmpty()) {
														if ((activityGroup != null) && (activityXri != null && "MAX".compareTo(activityXri) != 0)) {
																errorMsg += "no activities found!<br>";
																noActivitiesFound = true;
														}
%>
														<option value="">--</option>
<%
												}
												else {
													int activityCounter = 0;
													int maxToShow = MAX_ACTIVITY_SHOWN_INITIALLY;
													if (activityXri != null && "MAX".compareTo(activityXri) == 0) {
															maxToShow = MAX_ACTIVITY_SHOWN;
													};
													for (
															Iterator i = activities.iterator();
															i.hasNext() && (activityCounter < maxToShow);
															activityCounter++
													) {
															org.opencrx.kernel.activity1.jmi1.Activity activity = (org.opencrx.kernel.activity1.jmi1.Activity)i.next();
															boolean selected = (activityXri != null) && (activityXri.compareTo(activity.refMofId()) == 0);
															if (selected) {
																	hasActivitySelection = true;
															}
															if (
																	(showActivityGroupNameFilter != null) && (showActivityGroupNameFilter.length() > 0) &&
																	(activity.getName() != null) && (activity.getName().toUpperCase().indexOf(filterActivityName.toUpperCase()) == -1)
															) {
																	activityCounter--;
															} else {
																	if (firstActivityXri == null) {
																			firstActivityXri = activity.refMofId();
																	}
%>
																	<option <%= selected ? "selected" : "" %> value="<%= activity.refMofId() %>"><%= openOnly ? "" : (activity.getActivityState() < (short)20 ? "[&ensp;] " : "[X] ") %>#<%= activity.getActivityNumber() %>: <%= app.getHtmlEncoder().encode(activity.getName(), false) %></option>
<%
															}
													}
													if (activityCounter == 0) {
															errorMsg += "no activities found!<br>";
															noActivitiesFound = true;
%>
															<option value="">--</option>
<%
													}
													if (activityCounter >= maxToShow) {
%>
														<option value="MAX"><%= activityCounter < MAX_ACTIVITY_SHOWN ? "&mdash;&mdash;&gt;" : "..." %></option>
<%
													}
												}
												if (!hasActivitySelection && !resetActivityXri && (activityXri != null) && (activityXri.length() > 0) && !"MAX".equalsIgnoreCase(activityXri)) {
														// add another option to prevent loss of activity selection
														//System.out.println("activityXri = " + activityXri);
														hasActivitySelection = true;
														org.opencrx.kernel.activity1.jmi1.Activity activity = (org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(new Path(activityXri));
%>
														<option selected value="<%= activityXri %>"><%= openOnly ? "" : (activity.getActivityState() < (short)20 ? "[&ensp;] " : "[X] ") %>#<%= activity.getActivityNumber() %>: <%= app.getHtmlEncoder().encode(activity.getName(), false) %></option>
<%
												}
												if (!hasActivitySelection) {
														// set activityXri to first activity in drop down
														activityXri = firstActivityXri;
												}
%>
											</select>
										</td>
										<td class="addon">
												<input type="checkbox" id="excludeClosedActivities" name="excludeClosedActivities" title="Open Activities only" <%= (excludeClosedActivities != null) && (excludeClosedActivities.length() > 0) ? "checked" : "" %> tabindex="<%= tabIndex++ %>" value="excludeClosedActivities" onchange="javascript:$('reload.button').click();" onfocus="<%= ONFOCUS_HANDLER %>" />
												<%= noActivitiesFound ? CAUTION : "" %>
										</td>
									</tr>
								</table>
								</fieldset>

								<fieldset>
								<table class="fieldGroup">
									<tr>
										<td class="label">
											<span class="nw"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "recordType", app.getCurrentLocaleAsIndex()) %>:</span>
										</td>
										<td>
											<select class="valueL" name="recordType" id="recordType" tabindex="<%= tabIndex++ %>" <%= isWorkRecord ? "onchange='javascript:$(\"reload.button\").click();'" : "" %> onfocus="<%= ONFOCUS_HANDLER %>">
<%
												SortedMap recordType_longTextsC = codes.getLongText(isWorkRecord ? featureRecordTypeWork : featureRecordTypeExpense, app.getCurrentLocaleAsIndex(), true, false);

												if (recordType_longTextsC == null) {
%>
													<option value="0">N/A
<%
												}	else {
													Iterator options = recordType_longTextsC.entrySet().iterator();
													if (options.hasNext()) {options.next();} // skip N/A
													while (options.hasNext()) {
														Map.Entry option = (Map.Entry)options.next();
														short value = Short.parseShort((option.getKey()).toString());
														String selectedModifier = Short.parseShort(recordType) == value ? "selected" : "";
														if (!isWorkRecordInPercent || value == Activities.WorkRecordType.STANDARD.getValue()) {
%>
																<option <%= selectedModifier %> value="<%= value %>"><%= (String)(codes.getLongText(isWorkRecord ? featureRecordTypeWork : featureRecordTypeExpense, app.getCurrentLocaleAsIndex(), true, true).get(new Short(value))) %>
<%
														}
													}
												}
%>
											</select>
										</td>
										<td class="addon"></td>
									</tr>
<%
									if (isWorkRecordInPercent && activityXri != null && activityXri.length()>0) {
											try {
													name = ((org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(new Path(activityXri))).getName();
											} catch (Exception e) {}
									}
									if (name.length() == 0) {errorMsg += "name is mandatory!<br>";}
%>
									<tr>
										<td class="label">
											<span class="nw"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "name", app.getCurrentLocaleAsIndex()) %>:</span>
										</td>
										<td>
											<input type="text" class="valueL <%= isWorkRecordInPercent ? "" : "mandatory" %>" name="name" id="name" <%= isWorkRecordInPercent ? "readonly" : " " %> tabindex="<%= tabIndex++ %>" value="<%= app.getHtmlEncoder().encode(name, false) %>" <%= name.length() == 0 ? errorStyle : "" %> onfocus="<%= ONFOCUS_HANDLER %>" />
										</td>
										<td class="addon">
												<%= name.length() == 0 ? CAUTION : "" %>
										</td>
									</tr>

									<tr>
										<td class="label">
											<span class="nw"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "description", app.getCurrentLocaleAsIndex()) %>:</span>
										</td>
										<td>
											<input type="text" class="valueL" name="description" id="description" tabindex="<%= tabIndex++ %>" value="<%= app.getHtmlEncoder().encode(description, false) %>" onfocus="<%= ONFOCUS_HANDLER %>" />
										</td>
										<td class="addon"></td>
									</tr>
<%
									String previousRecordType = request.getParameter("previousRecordType") == null ? "" : request.getParameter("previousRecordType");
									String previousResourceXri = request.getParameter("previousResourceXri") == null ? "" : request.getParameter("previousResourceXri");
									boolean isRecordTypeChange = isFirstCall || recordType.compareTo(previousRecordType) != 0;
									if ((resourceXri != null) && (resourceXri.length() > 0) && (resourceXri.compareTo("*") != 0) && (resourceXri.compareTo(previousResourceXri) != 0)) {
											// resource changed, get default currency
											org.opencrx.kernel.activity1.jmi1.Resource res = (org.opencrx.kernel.activity1.jmi1.Resource)pm.getObjectById(new Path(resourceXri));
											if ((resourceXri != null) && (resourceXri.length() > 0) && (resourceXri.compareTo("*") != 0)) {
												try {
														billingCurrency = String.valueOf(res.getRateCurrency());
												} catch (Exception e) {}
											}
									}
									if (
											(isRecordTypeChange) ||
											(resourceXri.compareTo(previousResourceXri) != 0)
									) {
											// resource changed, get rate
											if ((resourceXri != null) && (resourceXri.length() > 0) && (resourceXri.compareTo("*") != 0)) {
												org.opencrx.kernel.activity1.jmi1.Resource res = (org.opencrx.kernel.activity1.jmi1.Resource)pm.getObjectById(new Path(resourceXri));
												try {
														if (recordType.compareTo(String.valueOf(Activities.WorkRecordType.STANDARD.getValue())) == 0) {
																rate = res.getStandardRate() != null ? quantityf.format(res.getStandardRate()) : "0.000";
														} else if (recordType.compareTo(String.valueOf(Activities.WorkRecordType.OVERTIME.getValue())) == 0) {
																rate = res.getOvertimeRate() != null ? quantityf.format(res.getOvertimeRate()) : "0.000";
														}
												} catch (Exception e) {}
											}
									}
%>
									<tr <%= isWorkRecordInPercent ? "style='display:none;'" : "" %>>
										<td class="label">
											<span class="nw"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "rate", app.getCurrentLocaleAsIndex()) %>:</span>
										</td>
										<td nowrap>
											<input type="text" <%= isWorkRecord ? "" : "class='mandatory'" %> style="font-weight:bold;width:47%;float:right;padding-top:2px;padding-right:2px;text-align:right;<%= !isWorkRecord && paraRate==null ? errorStyleInline: "" %>" name="rate" id="rate" tabindex="<%= tabIndex+5 %>" value="<%= rate %>"	onkeypress="javascript:oldValue=this.value;" onkeyup="javascript:positiveDecimalsVerify(this);" onchange="javascript:$('reload.button').click();" onfocus="<%= ONFOCUS_HANDLER %>" />
											<select class="valueL" style="width:49%;float:left;" id="billingCurrency" name="billingCurrency" tabindex="<%= tabIndex++ %>" onfocus="<%= ONFOCUS_HANDLER %>">
<%
												SortedMap billingCurrency_longTextsC = codes.getLongText(featureBillingCurrency, app.getCurrentLocaleAsIndex(), true, false);

												if (billingCurrency_longTextsC == null) {
%>
													<option value="0">N/A
<%
												}	else {
													for(Iterator options = billingCurrency_longTextsC.entrySet().iterator() ; options.hasNext(); ) {
														Map.Entry option = (Map.Entry)options.next();
														short value = Short.parseShort((option.getKey()).toString());
														String selectedModifier = Short.parseShort(billingCurrency) == value ? "selected" : "";
%>
														<option <%= selectedModifier %> value="<%= value %>"><%= (String)(codes.getLongText(featureBillingCurrency, app.getCurrentLocaleAsIndex(), true, true).get(new Short(value))) %>
<%
													}
												}
												tabIndex += 10;
%>
											</select>
											<input type="hidden" name="previousRecordType" value="<%= recordType %>" />
										</td>
										<td class="addon"></td>
									</tr>

									<tr <%= isWorkRecordInPercent ? "style='display:none;'" : "" %>>
										<td class="label">
											<span class="nw"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "isBillable", app.getCurrentLocaleAsIndex()) %>:</span>
										</td>
										<td>
											<input type="checkbox" id="isBillable" name="isBillable" <%= (isBillable != null) && (isBillable.length() > 0) ? "checked" : "" %> tabindex="<%= tabIndex++ %>" value="isBillable" onfocus="<%= ONFOCUS_HANDLER %>" />
										</td>
										<td class="addon"></td>
									</tr>

									<tr class="time">
										<td class="label timelabel">
											<span class="nw"><b><%= datef.format(getDateAsCalendar(selectedDateStr, app).getTime()) %></b>:</span>
										</td>
										<td class="time">
											<table>
												<tr class="centered" <%= isWorkRecordInPercent ? "style='display:none;'" : "" %>>
													<td><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "startedAt", app.getCurrentLocaleAsIndex()) %></td>
													<td></td>
													<td><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "endedAt", app.getCurrentLocaleAsIndex()) %></td>
													<td style="width:100%;">&nbsp;</td>
												</tr>
												<tr class="centered" <%= isWorkRecordInPercent ? "style='display:none;'" : "" %>>
													<td>
														<img class="timeButtonL" border="0" title="- 0:15" alt="" src="../../images/arrow_smallleft.gif" onclick="javascript:var hh_mm = timeTick($('startedAtHH').value + ':' + $('startedAtMM').value, -15);$('startedAtHH').value = hh_mm.split(':')[0];$('startedAtMM').value = hh_mm.split(':')[1];" /><input type="text" class="time" name="startedAtHH" id="startedAtHH" tabindex="<%= tabIndex++ %>" value="<%= startedAtHH %>" <%= startedAt == null ? errorStyle : "" %> onkeypress="javascript:oldValue=this.value;" onkeyup="javascript:positiveDecimalsVerify(this);" onfocus="<%= ONFOCUS_HANDLER %>" />:<input type="text" class="time" name="startedAtMM" id="startedAtMM"" tabindex="<%= tabIndex++ %>" value="<%= startedAtMM %>" <%= startedAt == null ? errorStyle : "" %> onkeypress="javascript:oldValue=this.value;" onkeyup="javascript:positiveDecimalsVerify(this);" onfocus="<%= ONFOCUS_HANDLER %>" /><img class="timeButtonR" border="0" title="+ 0:15" alt="" src="../../images/arrow_smallright.gif" onclick="javascript:var hh_mm = timeTick($('startedAtHH').value + ':' + $('startedAtMM').value, +15);$('startedAtHH').value = hh_mm.split(':')[0];$('startedAtMM').value = hh_mm.split(':')[1];" />
													</td>
													<td>&mdash;</td>
													<td>
														<img class="timeButtonL" border="0" title="- 0:15" alt="" src="../../images/arrow_smallleft.gif" onclick="javascript:var hh_mm = timeTick($('endedAtHH').value + ':' + $('endedAtMM').value, -15);$('endedAtHH').value = hh_mm.split(':')[0];$('endedAtMM').value = hh_mm.split(':')[1];" /><input type="text" class="time" name="endedAtHH" id="endedAtHH" tabindex="<%= tabIndex++ %>" value="<%= endedAtHH %>" onkeypress="javascript:oldValue=this.value;" onkeyup="javascript:positiveDecimalsVerify(this);" onfocus="<%= ONFOCUS_HANDLER %>" />:<input type="text" class="time" name="endedAtMM" id="endedAtMM"" tabindex="<%= tabIndex++ %>" value="<%= endedAtMM %>" onkeypress="javascript:oldValue=this.value;" onkeyup="javascript:positiveDecimalsVerify(this);" onfocus="<%= ONFOCUS_HANDLER %>" /><img class="timeButtonR" border="0" title="+ 0:15" alt="" src="../../images/arrow_smallright.gif" onclick="javascript:var hh_mm = timeTick($('endedAtHH').value + ':' + $('endedAtMM').value, +15);$('endedAtHH').value = hh_mm.split(':')[0];$('endedAtMM').value = hh_mm.split(':')[1];" />
													</td>
													<td></td>
												</tr>

												<!--	WorkRecord -->
												<tr class="centered" <%= isWorkRecord && !isWorkRecordInPercent ? "" : "style='display:none;'" %>>
													<td style="padding-top:5px;">hh:mm</td>
													<td></td>
													<td></td>
													<td></td>
												</tr>
												<tr class="centered" <%= isWorkRecord && !isWorkRecordInPercent ? "" : "style='display:none;'" %>>
													<td>
														<img class="timeButtonL" border="0" title="- 0:15" alt="" src="../../images/arrow_smallleft.gif" onclick="javascript:var hh_mm = timeTick($('effortHH').value + ':' + $('effortMM').value, -15);$('effortHH').value = hh_mm.split(':')[0];$('effortMM').value = hh_mm.split(':')[1];" /><input type="text" class="time" name="effortHH" id="effortHH" tabindex="<%= tabIndex++ %>" value="<%= effortHH %>" <%= paraEffortHH == null ? errorStyle : "" %> onkeypress="javascript:oldValue=this.value;" onkeyup="javascript:positiveDecimalsVerify(this);" onfocus="<%= ONFOCUS_HANDLER %>" />:<input type="text" class="time" name="effortMM" id="effortMM"" tabindex="<%= tabIndex++ %>" value="<%= effortMM %>" <%= paraEffortMM == null ? errorStyle : "" %> onkeypress="javascript:oldValue=this.value;" onkeyup="javascript:positiveDecimalsVerify(this);" onfocus="<%= ONFOCUS_HANDLER %>" /><img class="timeButtonR" border="0" title="+ 0:15" alt="" src="../../images/arrow_smallright.gif" onclick="javascript:var hh_mm = timeTick($('effortHH').value + ':' + $('effortMM').value, +15);$('effortHH').value = hh_mm.split(':')[0];$('effortMM').value = hh_mm.split(':')[1];" />
													</td>
													<td></td>
													<td></td>
													<td></td>
												</tr>
<%
												// WorkRecordInPercent special treatment
												
												org.opencrx.kernel.activity1.jmi1.Resource currentResource = null;
												org.opencrx.kernel.activity1.jmi1.Calendar cal = null;
												org.opencrx.kernel.activity1.jmi1.CalendarDay calDay = null;
												String calDayName = null;
												try {
													calDayName = calendardayf.format(getDateAsCalendar(selectedDateStr, app).getTime());
												} catch (Exception e) {}
												String calDayLoad = null;
												short defaultLoad = 100;
												
												boolean isCurrentUsersResource = false;
												if (isWorkRecordInPercent) {
													// try to get Default Calendar of Resource
													try {
														currentResource = (org.opencrx.kernel.activity1.jmi1.Resource)pm.getObjectById(new Path(resourceXri));
														if (currentResource != null) {
																if (currentResource.getCalendar() != null) {
																	cal = currentResource.getCalendar();

																	// get default load from WeekDay 
																	org.opencrx.kernel.activity1.cci2.WeekDayQuery weekDayQuery = (org.opencrx.kernel.activity1.cci2.WeekDayQuery)pm.newQuery(org.opencrx.kernel.activity1.jmi1.WeekDay.class);
																	weekDayQuery.dayOfWeek().equalTo(new Short((short)getDayOfWeek(selectedDateStr, app)));
																	Collection daysOfWeek = cal.getWeekDay(weekDayQuery);
																	if(!daysOfWeek.isEmpty()) {
																		org.opencrx.kernel.activity1.jmi1.WeekDay weekDay = (org.opencrx.kernel.activity1.jmi1.WeekDay)daysOfWeek.iterator().next();
																		if (weekDay.getWorkDurationHours() != null) {
																				defaultLoad = weekDay.getWorkDurationHours().shortValue();
																				if (defaultLoad < 0) {
																						defaultLoad = 0;
																				}
																				if (defaultLoad > 100) {
																						defaultLoad = 100;
																				}
																		}
																	}
																
																	// try to get CalendarDay
																	org.opencrx.kernel.activity1.cci2.CalendarDayQuery calendarDayQuery = (org.opencrx.kernel.activity1.cci2.CalendarDayQuery)pm.newQuery(org.opencrx.kernel.activity1.jmi1.CalendarDay.class);
																	calendarDayQuery.dateOfDay().equalTo(getDateAsCalendar(selectedDateStr, app).getTime());
																	Collection calendarDays = cal.getCalendarDay(calendarDayQuery);
																	if(!calendarDays.isEmpty()) {
																		calDay = (org.opencrx.kernel.activity1.jmi1.CalendarDay)calendarDays.iterator().next();
																		calDayName = calDay.getName();
																		try {
																				String[] calDayNameSplit = calDayName.split("@");
																				if (calDayNameSplit.length>=2) {
																						calDayName = calDayNameSplit[0];
																						calDayLoad = calDayNameSplit[1];
																				}
																		} catch (Exception e) {}
																	}
																}
																// default is current users Contact (as defined in current user's UserHome
																// get UserHome
																org.opencrx.kernel.home1.jmi1.UserHome myUserHome = org.opencrx.kernel.backend.UserHomes.getInstance().getUserHome(obj.refGetPath(), pm);
																if (
																		(myUserHome.getContact() != null) &&
																		(currentResource.getContact() != null) &&
																		(myUserHome.getContact().refMofId().compareTo(currentResource.getContact().refMofId()) == 0)
																) {
																	isCurrentUsersResource = true;
																}
																
																if (cal != null && calDay != null /*&& isCurrentUsersResource*/) {
																		String calendarDayName = null;
																		//System.out.println("UPDATE: " + request.getParameter("ACTION.updateCalendarDay"));
																		if (request.getParameter("load." + selectedDateStr) != null && request.getParameter("load." + selectedDateStr).length() > 0) {
																				calendarDayName = selectedDateStr + "@" + request.getParameter("load." + selectedDateStr);
																		} else {
																				if (request.getParameter("ACTION.updateCalendarDay") != null && request.getParameter("ACTION.updateCalendarDay").length() > 9) {
																						calendarDayName = request.getParameter("ACTION.updateCalendarDay");
																				}
																		}
	
																		if (calendarDayName != null && calendarDayName.compareTo(calDay.getName()) != 0) {
																			System.out.println(new java.util.Date() + "UPDATE: " + calendarDayName);
																			try {
																					calDay = createOrUpdateCalendarDay(
																							calendarDayName,
																							calendarDayName.substring(0,8),
																							cal,
																							calDay,
																							activitySegment,
																							pm
																					);
																			} catch (Exception e) {
																					new ServiceException(e).log();
																			}
																			String[] calDayNameSplit = calendarDayName.split("@");
																			if (calDayNameSplit.length>=2) {
																					calDayName = calDayNameSplit[0];
																					calDayLoad = calDayNameSplit[1];
																			}
																		}
																}
																if (cal != null && calDay == null /*&& isCurrentUsersResource*/) {
																		String calendarDayName = null;
																		if (request.getParameter("load." + selectedDateStr) != null && request.getParameter("load." + selectedDateStr).length() > 0) {
																				calendarDayName = selectedDateStr + "@" + request.getParameter("load." + selectedDateStr);
																		} else {
																				if (request.getParameter("ACTION.createCalendarDay") != null && request.getParameter("ACTION.createCalendarDay").length() > 9) {
																						calendarDayName = request.getParameter("ACTION.createCalendarDay");
																				}
																		}
																			
																		if (calendarDayName != null) {
																				System.out.println(new java.util.Date() + "CREATE: " + calendarDayName);
																				try {
																						calDay = createOrUpdateCalendarDay(
																								calendarDayName,
																								calendarDayName.substring(0,8),
																								cal,
																								null,
																								activitySegment,
																								pm
																						);
																				} catch (Exception e) {
																						new ServiceException(e).log();
																				}
																		}
																}
																if (cal != null && calDay == null && createdWorkRecordInPercent) {
																		// System.out.println("created default calendar day: " + calDayName + "@100");
																		try {
																				if (calDayName != null && calDayName.length() > 0) {
																						calDay = createOrUpdateCalendarDay(
																								calDayName + "@" + defaultLoad,
																								calDayName,
																								cal,
																								null,
																								activitySegment,
																								pm
																						);
																				}
																		} catch (Exception e) {
																				new ServiceException(e).log();
																		}
																}
														}
													} catch (Exception e) {}
												}
%>
												<!--	WorkRecordInPercent -->
												<tr <%= isWorkRecordInPercent ? "" : "style='display:none;'" %>>
													<td style="vertical-align:bottom;">
														<img class="timeButtonL" border="0" title="- 5%" alt="" src="../../images/arrow_smallleft.gif" onclick="javascript:$('quantPercent').value = percentageTick($('quantPercent').value, -5);" /><input type="text" class="percentage" name="quantPercent" id="quantPercent" tabindex="<%= tabIndex++ %>" value="<%= quantPercent %>" <%= quantPercent == null ? errorStyle : "" %> onkeypress="javascript:oldValue=this.value;" onkeyup="javascript:positiveDecimalsVerify(this);" onfocus="<%= ONFOCUS_HANDLER %>" />%<img class="timeButtonR" border="0" title="+ 5%" alt="" src="../../images/arrow_smallright.gif" onclick="javascript:$('quantPercent').value = percentageTick($('quantPercent').value, 5);" />
													</td>
													<td style="vertical-align:bottom;width:30px;">&nbsp;</td>
													<td style="vertical-align:bottom;padding-right:30px;">
															<%= userView.getFieldLabel(RESOURCE_CLASS, "calendar", app.getCurrentLocaleAsIndex()) %>:<br>
															<%= cal != null && cal.getName() != null ? cal.getName() : "--" %>
													</td>
													<td style="vertical-align:bottom;padding-right:30px;">
															<%= calDay != null && calDay.getName() != null ? app.getLabel(CALENDARDAY_CLASS) + ":  " + calDay.getName() : "Default Load: " + defaultLoad + "%" %><br>
<%
															if (cal != null && calDay != null && calDay.getName() != null) {
																	// change options
%>
																	<input type="hidden" name="currentCalendarDayXri" id="currentCalendarDayXri" value="<%= calDay.refMofId() %>" />
																	<INPUT type="submit" name="updateCalendarDay" tabindex="<%= tabIndex++ %>" value="0%"	 onmouseup="javascript:this.name='ACTION.'+this.name;this.value='<%= calDayName %>@0';"	   style="font-size:10px;font-weight:bold;width:4em;<%= calDayLoad != null && calDayLoad.compareTo("0") == 0 ? "border:2px black solid;" : "" %>" />
																	<INPUT type="submit" name="updateCalendarDay" tabindex="<%= tabIndex++ %>" value="25%"	onmouseup="javascript:this.name='ACTION.'+this.name;this.value='<%= calDayName %>@25';"	 style="font-size:10px;font-weight:bold;width:4em;<%= calDayLoad != null && calDayLoad.compareTo("25") == 0 ? "border:2px black solid;" : "" %>" />
																	<INPUT type="submit" name="updateCalendarDay" tabindex="<%= tabIndex++ %>" value="50%"	onmouseup="javascript:this.name='ACTION.'+this.name;this.value='<%= calDayName %>@50';"	 style="font-size:10px;font-weight:bold;width:4em;<%= calDayLoad != null && calDayLoad.compareTo("50") == 0 ? "border:2px black solid;" : "" %>" />
																	<INPUT type="submit" name="updateCalendarDay" tabindex="<%= tabIndex++ %>" value="75%"	onmouseup="javascript:this.name='ACTION.'+this.name;this.value='<%= calDayName %>@75';"	 style="font-size:10px;font-weight:bold;width:4em;<%= calDayLoad != null && calDayLoad.compareTo("75") == 0 ? "border:2px black solid;" : "" %>" />
																	<INPUT type="submit" name="updateCalendarDay" tabindex="<%= tabIndex++ %>" value="100%" onmouseup="javascript:this.name='ACTION.'+this.name;this.value='<%= calDayName %>@100';" style="font-size:10px;font-weight:bold;width:4em;<%= calDayLoad != null && calDayLoad.compareTo("100") == 0 ? "border:2px black solid;" : "" %>" />
<%
															} else if (cal != null /*&& isCurrentUsersResource*/) {
																	// create options
%>
																	<INPUT type="submit" name="createCalendarDay" tabindex="<%= tabIndex++ %>" value="0%"	 onmouseup="javascript:this.name='ACTION.'+this.name;this.value='<%= calDayName %>@0';"	   style="font-size:10px;font-weight:bold;width:4em;<%= defaultLoad ==   0 ? "border:2px black solid;" : "" %>" />
																	<INPUT type="submit" name="createCalendarDay" tabindex="<%= tabIndex++ %>" value="25%"	onmouseup="javascript:this.name='ACTION.'+this.name;this.value='<%= calDayName %>@25';"	 style="font-size:10px;font-weight:bold;width:4em;<%= defaultLoad ==  25 ? "border:2px black solid;" : "" %>" />
																	<INPUT type="submit" name="createCalendarDay" tabindex="<%= tabIndex++ %>" value="50%"	onmouseup="javascript:this.name='ACTION.'+this.name;this.value='<%= calDayName %>@50';"	 style="font-size:10px;font-weight:bold;width:4em;<%= defaultLoad ==  50 ? "border:2px black solid;" : "" %>" />
																	<INPUT type="submit" name="createCalendarDay" tabindex="<%= tabIndex++ %>" value="75%"	onmouseup="javascript:this.name='ACTION.'+this.name;this.value='<%= calDayName %>@75';"	 style="font-size:10px;font-weight:bold;width:4em;<%= defaultLoad ==  75 ? "border:2px black solid;" : "" %>" />
																	<INPUT type="submit" name="createCalendarDay" tabindex="<%= tabIndex++ %>" value="100%" onmouseup="javascript:this.name='ACTION.'+this.name;this.value='<%= calDayName %>@100';" style="font-size:10px;font-weight:bold;width:4em;<%= defaultLoad == 100 ? "border:2px black solid;" : "" %>" />

<%
															}
%>
													</td>
												</tr>


												<!--	ExpenseRecord -->
												<tr class="centered" <%= isWorkRecord ? "style='display:none;'" : "" %>>
													<td style="padding-top:5px;"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "quantity", app.getCurrentLocaleAsIndex()) %></td>
													<td></td>
													<td style="padding-top:5px;"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "quantityUom", app.getCurrentLocaleAsIndex()) %></td>
													<td></td>
												</tr>
												<tr class="centered" <%= isWorkRecord ? "style='display:none;'" : "" %>>
													<td>
														<input type="text" class="quantity" <%= quantityIsZero ? errorStyle : "" %> name="quantity" id="quantity" tabindex="<%= tabIndex++ %>" value="<%= quantity %>" <%= paraQuantity == null ? errorStyle : "" %> onkeypress="javascript:oldValue=this.value;" onkeyup="javascript:positiveDecimalsVerify(this);" onchange="javascript:$('reload.button').click();" onfocus="<%= ONFOCUS_HANDLER %>" />
													</td>
													<td></td>
													<td colspan="2">
<%
														boolean noUomsFound = false;
														org.opencrx.kernel.uom1.jmi1.Uom1Package uomPkg = org.opencrx.kernel.utils.Utils.getUomPackage(pm);
														org.opencrx.kernel.uom1.jmi1.Segment uomSegment = (org.opencrx.kernel.uom1.jmi1.Segment)pm.getObjectById(
																new Path("xri:@openmdx:org.opencrx.kernel.uom1/provider/" + providerName + "/segment/Root")
															);
														org.opencrx.kernel.uom1.cci2.UomQuery uomFilter = uomPkg.createUomQuery();
														uomFilter.name().elementOf(Arrays.asList(UOM_NAMES));
														uomFilter.orderByName().ascending();
														uomFilter.orderByDescription().ascending();
														List uoms = uomSegment.getUom(uomFilter);
														if (uoms.isEmpty()) {
																errorMsg += "no matching UOMs found!<br>";
																noUomsFound = true;
%>
																<select id="uomXri" name="uomXri" class="valueL" <%= errorStyle %> tabindex="<%= tabIndex++ %>" onfocus="<%= ONFOCUS_HANDLER %>">
																	<option value="">--</option>
																</select>
<%
														} else {
%>
															<select class="valueL" id="uomXri" name="uomXri" tabindex="<%= tabIndex++ %>" onfocus="<%= ONFOCUS_HANDLER %>">
<%
																for (
																		Iterator i = uoms.iterator();
																		i.hasNext();
																) {
																		org.opencrx.kernel.uom1.jmi1.Uom uom = (org.opencrx.kernel.uom1.jmi1.Uom)i.next();
%>
																		<option <%= (uomXri != null) && (uomXri.compareTo(uom.refMofId()) == 0) ? "selected" : "" %> value="<%= uom.refMofId() %>"><%= app.getHtmlEncoder().encode(uom.getName(), false) %> [<%= uom.getDescription() != null ? app.getHtmlEncoder().encode(uom.getDescription(), false) : "--" %>]</option>
<%
																}
															}
%>
														</select>

													</td>
												</tr>
												<tr class="centered" <%= isWorkRecord ? "style='display:none;'" : "" %>>
													<td style="padding-top:5px;"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "isReimbursable", app.getCurrentLocaleAsIndex()) %></td>
													<td></td>
													<td style="padding-top:5px;"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "paymentType", app.getCurrentLocaleAsIndex()) %></td>
													<td></td>
												</tr>
												<tr class="centered" <%= isWorkRecord ? "style='display:none;'" : "" %>>
													<td>
														<input type="checkbox" id="isReimbursable" name="isReimbursable" <%= (isReimbursable != null) && (isReimbursable.length() > 0) ? "checked" : "" %> tabindex="<%= tabIndex++ %>" value="isReimbursable" onfocus="<%= ONFOCUS_HANDLER %>" />
													</td>
													<td></td>
													<td colspan="2">
														<select class="valueL" id="paymentType" name="paymentType" tabindex="<%= tabIndex++ %>" onfocus="<%= ONFOCUS_HANDLER %>">
			<%
															SortedMap paymentType_longTextsC = codes.getLongText(featurePaymentType, app.getCurrentLocaleAsIndex(), true, false);

															if (paymentType_longTextsC == null) {
			%>
																<option value="0">N/A
			<%
															}	else {
																for(Iterator options = paymentType_longTextsC.entrySet().iterator() ; options.hasNext(); ) {
																	Map.Entry option = (Map.Entry)options.next();
																	short value = Short.parseShort((option.getKey()).toString());
																	String selectedModifier = Short.parseShort(paymentType) == value ? "selected" : "";
			%>
																	<option <%= selectedModifier %> value="<%= value %>"><%= (String)(codes.getLongText(featurePaymentType, app.getCurrentLocaleAsIndex(), true, true).get(new Short(value))) %>
			<%
																}
															}
			%>
														</select>
													</td>
												</tr>

											</table>

										</td>
										<td class="addon"></td>
									</tr>

								</table>
								</fieldset>

<%
								org.opencrx.kernel.activity1.jmi1.Activity selectedActivity = null;
								boolean showMakePrivate = false;
								boolean hasPrivateOwningGroup = false;
								boolean atLeastOnePrivateMatch = false; // true if current principal is member of at least one private group which is also an owning group of the selected activity
								List privateOwningGroups = new ArrayList();
								if (activityXri != null && activityXri.length() > 0) {
										selectedActivity = (org.opencrx.kernel.activity1.jmi1.Activity)pm.getObjectById(new Path(activityXri));
										for (
											Iterator i = selectedActivity.getOwningGroup().iterator();
											i.hasNext() && !showMakePrivate;
										) {
												org.opencrx.security.realm1.jmi1.PrincipalGroup currentPrincipalGroup =
														(org.opencrx.security.realm1.jmi1.PrincipalGroup)i.next();
												if (currentPrincipalGroup.getName() != null && (currentPrincipalGroup.getName().toUpperCase().indexOf(PRIVATE_TOKEN) >= 0)) {
														privateOwningGroups.add(currentPrincipalGroup);
														hasPrivateOwningGroup = true;
												}
										}
								}

								String groupNames = "";
								org.opencrx.kernel.home1.jmi1.UserHome myUserHome = null;
								try {
										// get UserHome
										myUserHome = org.opencrx.kernel.backend.UserHomes.getInstance().getUserHome(obj.refGetPath(), pm);
								} catch (Exception e) {
										new ServiceException(e).log();
								};
								org.openmdx.security.realm1.jmi1.Principal principal = null;
								try {
										org.openmdx.security.realm1.jmi1.Realm realm = org.opencrx.kernel.backend.SecureObject.getInstance().getRealm(
											pm,
											providerName,
											segmentName
										);
										principal = org.opencrx.kernel.backend.SecureObject.getInstance().findPrincipal(
											myUserHome.refGetPath().getBase(),
											realm
										);
										// check whether user is member of at least one private group which is also an owning group of the selected activity
										for (
											Iterator i = privateOwningGroups.iterator();
											i.hasNext();
										) {
												org.opencrx.security.realm1.jmi1.PrincipalGroup currentPrivateOwningGroup =
														(org.opencrx.security.realm1.jmi1.PrincipalGroup)i.next();
												if (groupNames.length() > 0) {groupNames += ", ";}
												groupNames += currentPrivateOwningGroup.getName();
												if (principal.getIsMemberOf().contains(currentPrivateOwningGroup)) {
														atLeastOnePrivateMatch = true;
												}
										}
								}
								catch (Exception e) {
										new ServiceException(e).log();
								};

								showMakePrivate = hasPrivateOwningGroup && atLeastOnePrivateMatch;
								if (!showMakePrivate) {
										// reset makePrivate
										makePrivate = "";
								}
%>
								<fieldset <%= showMakePrivate ? "" : "style='display:none;'" %>>
								<table class="fieldGroup">
									<tr>
										<td class="label" style="padding-top:5px;">
											<span class="nw"><strong><%= PRIVATE_TOKEN %></strong>:</span>
										</td>
										<td>
											<input type="checkbox" id="makePrivate" name="makePrivate" <%= (makePrivate != null) && (makePrivate.length() > 0) ? "checked" : "" %> tabindex="<%= tabIndex++ %>" value="makePrivate" onfocus="<%= ONFOCUS_HANDLER %>" />
											<%= groupNames %>
										</td>
										<td class="addon"></td>
									</tr>
								</table>
								</fieldset>
							</td>
						</tr>
						<tr>
							<td>
<%
								if (!canExecuteAdd || creationFailed || noActivitiesFound || noResourcesFound) {
								//System.out.println("creation failed");
%>
									<div style="float:right;" title="<%= errorMsg.replace("<br>", " - ") %>" >
										<%= CAUTION %>
									</div>
<%
								}
%>
								<div class="buttons">
									<input type="submit" id="EVICT_RELOAD" name="EVICT_RELOAD" tabindex="<%= tabIndex++ %>" value="<%= app.getTexts().getReloadText() %>" onclick="<%= SUBMIT_HANDLER %>" />
								</div>
							</td>
							<td></td>
							<td>
									<input type="submit" id="add.button" name="add.button" <%= noActivitiesFound || noResourcesFound ? "disabled" : "" %> tabindex="<%= tabIndex++ %>" value="<%= app.getTexts().getNewText() %>" onclick="<%= SUBMIT_HANDLER %>" />
									<input type="submit" id="cancel.button" name="cancel.button" tabindex="<%= tabIndex++ %>" value="<%= app.getTexts().getCloseText() %>" onclick="<%= SUBMIT_HANDLER %>" />
							</td>
						</tr>
					</table>
<%
					if (SHOW_ERRORS && errorMsg.length() > 0) {
%>
						<div style="background-color:red;color:white;border:1px solid black;padding:10px;font-weight:bold;margin-top:10px;">
							<%= errorMsg %>
						</div>
<%
					}
%>
					<br>

<%
					if ((resource == null) && (resourceXri != null) && (resourceXri.length() > 0) && (resourceXri.compareTo("*") != 0)) {
						try {
								resource = (org.opencrx.kernel.activity1.jmi1.Resource)pm.getObjectById(new Path(resourceXri));
								contact = resource.getContact();
								showAllResources = false;
						} catch (Exception e) {}
					}
					if ((contact != null) || (resource != null)) {
							Map workAndExpenseRecords = new TreeMap();
							org.opencrx.kernel.activity1.cci2.ResourceQuery resourceQuery = activityPkg.createResourceQuery();
							if (contact != null) {
									resourceQuery.thereExistsContact().equalTo(contact);
							}
							resourceQuery.forAllDisabled().isFalse();

							GregorianCalendar calendarBeginOfWeek = getDateAsCalendar(selectedDateStr, app);
							while (calendarBeginOfWeek.get(GregorianCalendar.DAY_OF_WEEK) != calendarBeginOfWeek.getFirstDayOfWeek()) {
									calendarBeginOfWeek.add(GregorianCalendar.DAY_OF_MONTH, -1);
							}
							GregorianCalendar calendarBeginOPeriod = getDateAsCalendar(selectedDateStr, app);
							if ((isFullMonth != null) && (isFullMonth.length() > 0)) {
									calendarBeginOPeriod.set(GregorianCalendar.DAY_OF_MONTH, 1);
							} else {
									calendarBeginOPeriod = (GregorianCalendar)calendarBeginOfWeek.clone();
							}
							java.util.Date beginOfPeriod = calendarBeginOPeriod.getTime();
							GregorianCalendar calendarEndOfPeriod = (GregorianCalendar)calendarBeginOPeriod.clone();
							if ((isFullMonth != null) && (isFullMonth.length() > 0)) {
									calendarEndOfPeriod.add(GregorianCalendar.MONTH, 1);
							} else {
									calendarEndOfPeriod.add(GregorianCalendar.DAY_OF_MONTH, 7);
							}
							calendarEndOfPeriod.add(GregorianCalendar.MILLISECOND, -1);
							java.util.Date endOfPeriod = calendarEndOfPeriod.getTime();

							org.opencrx.kernel.activity1.cci2.WorkAndExpenseRecordQuery workAndExpenseRecordFilter = activityPkg.createWorkAndExpenseRecordQuery();
							//workAndExpenseRecordFilter.forAllDisabled().isFalse();
							workAndExpenseRecordFilter.thereExistsStartedAt().between(beginOfPeriod, endOfPeriod);
							if (isWorkRecord) {
									if (isWorkRecordInPercent) {
											workAndExpenseRecordFilter.recordType().equalTo(new Short((short)1));
											if (uomPercent != null) {
													workAndExpenseRecordFilter.thereExistsQuantityUom().equalTo(uomPercent);
											}
									} else {
											workAndExpenseRecordFilter.recordType().between(new Short((short)1), new Short((short)RECORDTYPE_WORK_MAX));
											if (uomPercent != null) {
													workAndExpenseRecordFilter.forAllQuantityUom().notEqualTo(uomPercent);
											}
									}
							} else {
									workAndExpenseRecordFilter.recordType().greaterThan(new Short((short)RECORDTYPE_WORK_MAX));
							}
							double[] sumDays = new double[7];
							double[] sumDaysBillable = new double[7];
							for(int i = 0; i < sumDays.length; i++) {
								sumDays[i] = 0.0;
								sumDaysBillable[i] = 0.0;
							}
							int counter = 0;
							org.opencrx.kernel.activity1.jmi1.Resource res = null;
							Iterator r = null;
							if (contact != null) {
									// iterate through all resources of this contact
									r = activitySegment.getResource(resourceQuery).iterator();
									if (r.hasNext()) {
											res = (org.opencrx.kernel.activity1.jmi1.Resource)r.next();
									}
							} else {
									// process single resource only
									res = resource;
							}
							while (res != null) {
									for (
											Iterator w = res.getWorkReportEntry(workAndExpenseRecordFilter).iterator();
											w.hasNext();
											counter++
									) {
											org.opencrx.kernel.activity1.jmi1.WorkAndExpenseRecord workAndExpenseRecord = (org.opencrx.kernel.activity1.jmi1.WorkAndExpenseRecord)w.next();
											GregorianCalendar startedAtCal = new GregorianCalendar(app.getCurrentLocale());
											startedAtCal.setTimeZone(TimeZone.getTimeZone(app.getCurrentTimeZone()));
											startedAtCal.setMinimalDaysInFirstWeek(4); // this conforms to DIN 1355/ISO 8601
											String sortKey = org.opencrx.kernel.backend.Activities.getInstance().getUidAsString();
											try {
													if (workAndExpenseRecord.getStartedAt() == null) {
															sortKey = "yyyyMMddHHmmss";
															startedAtCal.setTime(beginOfPeriod);
													} else {
															sortKey = dtsortf.format(workAndExpenseRecord.getStartedAt());
															startedAtCal.setTime(workAndExpenseRecord.getStartedAt());
													}
													sortKey += workAndExpenseRecord.getActivity().getActivityNumber() + formatter.format(counter);
											} catch (Exception e) {};
											if (workAndExpenseRecord.getQuantity() != null) {
													sumDays[startedAtCal.get(GregorianCalendar.DAY_OF_WEEK) % 7] += workAndExpenseRecord.getQuantity().doubleValue();
													if (workAndExpenseRecord.isBillable() != null && workAndExpenseRecord.isBillable().booleanValue()) {
															sumDaysBillable[startedAtCal.get(GregorianCalendar.DAY_OF_WEEK) % 7] += workAndExpenseRecord.getQuantity().doubleValue();
													}
											}
											workAndExpenseRecords.put(sortKey, workAndExpenseRecord);
									}
									res = null;
									if ((r != null) && (r.hasNext())) {
											res = (org.opencrx.kernel.activity1.jmi1.Resource)r.next();
									}
							}

%>
							<hr>
							<h2 style="padding-left:5px;">
								<%= app.getLabel(WORKANDEXPENSERECORD_CLASS) %>
								<input type="checkbox" name="isFullMonth" <%= (isFullMonth != null) && (isFullMonth.length() > 0) ? "checked" : "" %> tabindex="<%= tabIndex++ %>" value="isFullMonth" onchange="javascript:$('reload.button').click();" />
								[<%= calendarBeginOPeriod != null ? datef.format(calendarBeginOPeriod.getTime()) : "--" %> &mdash; <%= calendarEndOfPeriod != null ? datef.format(calendarEndOfPeriod.getTime()) : "--" %>]
							</h2>

<%
							if (counter > 0) {
									boolean showFullStartedAtDate = (!isWorkRecordInPercent) && (isFullStartedAtDate != null) && (isFullStartedAtDate.length() > 0);
%>
									<table><tr><td style="padding-left:5px;">
									<table class="gridTable">
										<tr class="gridTableHeader">
											<td class="smallheaderR" colspan="2">
												<%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "startedAt", app.getCurrentLocaleAsIndex()) %>
												<input type="checkbox" name="isFullStartedAtDate" <%= showFullStartedAtDate ? "checked" : "" %> <%= isWorkRecordInPercent ? "style='display:none;'" : "" %> tabindex="<%= tabIndex++ %>" value="isFullStartedAtDate" onchange="javascript:$('reload.button').click();" />
											</td>
											<td class="smallheaderR <%= showFullStartedAtDate ? "" : "hidden" %>" colspan="2"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "endedAt", app.getCurrentLocaleAsIndex()) %></td>
											<td class="smallheaderR"><%= isWorkRecord ? (isWorkRecordInPercent ? "%" : "hh:mm") : userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "quantity", app.getCurrentLocaleAsIndex()) %></td>
											<td class="smallheaderR"><%= isWorkRecordInPercent ? "&sum;" : "" %></td>
<%
											if (!isWorkRecord) {
%>
												<td class="smallheader"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "quantityUom", app.getCurrentLocaleAsIndex()) %>&nbsp;</td>
<%
											}
											if (isWorkRecord && !isWorkRecordInPercent) {
%>
												<td class="smallheader">&nbsp;</td>
												<td class="smallheaderR" colspan="2"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "billableAmount", app.getCurrentLocaleAsIndex()) %></td>
												<td class="smallheaderR" title="<%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "isBillable", app.getCurrentLocaleAsIndex()) %>">$&nbsp;</td>
												<td class="smallheaderR" title="<%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "isReimbursable", app.getCurrentLocaleAsIndex()) %>">*&nbsp;</td>
<%
											}
%>
											<td class="smallheader"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "name", app.getCurrentLocaleAsIndex()) %>&nbsp;</td>
											<td class="smallheader"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "activity", app.getCurrentLocaleAsIndex()) %>&nbsp;</td>
											<td class="smallheader" <%= isWorkRecordInPercent ? "style='display:none;'" : "" %>><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "recordType", app.getCurrentLocaleAsIndex()) %>&nbsp;</td>
											<td class="smallheader"><%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "description", app.getCurrentLocaleAsIndex()) %>&nbsp;</td>
											<td class="smallheader">&nbsp;</td>
										</tr>
<%
										boolean isEvenRow = false;
										boolean isFirstRow = false;
										BigDecimal dailySum = BigDecimal.ZERO;
										String startedAtCurrent = "";
										String startedAtPrevious = "";
										int rowCounter = 0;
										for (
												Iterator w = workAndExpenseRecords.values().iterator();
												w.hasNext();
										) {
												org.opencrx.kernel.activity1.jmi1.WorkAndExpenseRecord workAndExpenseRecord = (org.opencrx.kernel.activity1.jmi1.WorkAndExpenseRecord)w.next();

												GregorianCalendar startedAtDate = new GregorianCalendar(app.getCurrentLocale());
												startedAtDate.setMinimalDaysInFirstWeek(4); // this conforms to DIN 1355/ISO 8601
												startedAtDate.setTime(workAndExpenseRecord.getStartedAt());
												startedAtCurrent = getDateAsString(startedAtDate);
												boolean matchWithFormStartedAt =
														startedAtCurrent.compareTo(selectedDateStr) == 0;
												GregorianCalendar creationDate = new GregorianCalendar(app.getCurrentLocale());
												creationDate.setTimeZone(TimeZone.getTimeZone(app.getCurrentTimeZone()));
												creationDate.setMinimalDaysInFirstWeek(4); // this conforms to DIN 1355/ISO 8601
												creationDate.setTime(workAndExpenseRecord.getCreatedAt());
												boolean matchWithFormJustCreated = workAndExpenseRecord.refMofId().compareTo((isWorkRecord ? lastCreatedWorkRecordXri : lastCreatedExpenseRecordXri)) == 0;

												org.opencrx.kernel.activity1.jmi1.Activity activity = workAndExpenseRecord.getActivity();
												String recordHref = "";
												Action action = new Action(
														SelectObjectAction.EVENT_ID,
														new Action.Parameter[]{
																new Action.Parameter(Action.PARAMETER_OBJECTXRI, workAndExpenseRecord.refMofId())
														},
														"",
														true // enabled
													);
												recordHref = "../../" + action.getEncodedHRef();
												String activityHref = "";
												if (activity != null) {
													action = new Action(
															SelectObjectAction.EVENT_ID,
															new Action.Parameter[]{
																	new Action.Parameter(Action.PARAMETER_OBJECTXRI, activity.refMofId())
															},
															"",
															true // enabled
														);
													activityHref = "../../" + action.getEncodedHRef();
												}

												boolean isDayBreak = false;
												if (isWorkRecordInPercent && startedAtCurrent.compareTo(startedAtPrevious) != 0) {
														// new day --> break and print sum
														isDayBreak = true;
														startedAtPrevious = startedAtCurrent;
														dailySum = BigDecimal.ZERO;
												}
												if (isFirstRow) {
														isDayBreak = false;
														isFirstRow = false;
												}
												double recordTotal = 0.0;
												boolean quantityError = false;
												try {
														if (workAndExpenseRecord.getQuantity() != null && workAndExpenseRecord.getRate() != null) {
																dailySum = dailySum.add(workAndExpenseRecord.getQuantity());
																recordTotal = workAndExpenseRecord.getQuantity().doubleValue() * workAndExpenseRecord.getRate().doubleValue();
														}
												} catch (Exception e) {
														quantityError = true;
												}
												if (workAndExpenseRecord.getBillingCurrency() == 0) {
														quantityError = true;
												}
												String currency = "N/A";
												try {
														currency = (String)(codes.getShortText(featureBillingCurrency, app.getCurrentLocaleAsIndex(), true, true).get(new Short(workAndExpenseRecord.getBillingCurrency())));
												} catch (Exception e) {}
%>
												<tr <%= matchWithFormJustCreated ? "class='created'" : (matchWithFormStartedAt ? "class='match'" : (isEvenRow ? "class='even'" : "")) %>>
													<td><a href='<%= recordHref %>' target='_blank'><%= workAndExpenseRecord.getStartedAt() != null ? weekdayf.format(workAndExpenseRecord.getStartedAt()) : "--" %>&nbsp;</a></td>
													<td class="padded_r"><a href='<%= recordHref %>' target='_blank'><%= workAndExpenseRecord.getStartedAt() != null ? (showFullStartedAtDate ? datetimef.format(workAndExpenseRecord.getStartedAt()) : dateonlyf.format(workAndExpenseRecord.getStartedAt())) : "--" %></a></td>
													<td <%= showFullStartedAtDate ? "" : "class='hidden'" %>><a href='<%= recordHref %>' target='_blank'><%= workAndExpenseRecord.getEndedAt() != null ? weekdayf.format(workAndExpenseRecord.getEndedAt()) : "--" %>&nbsp;</a></td>
													<td class="padded_r <%= showFullStartedAtDate ? "" : "hidden" %>"><a href='<%= recordHref %>' target='_blank'><%= workAndExpenseRecord.getEndedAt() != null ? datetimef.format(workAndExpenseRecord.getEndedAt()) : "--" %></a></td>
													<td class="padded_r"><a href='<%= recordHref %>' target='_blank'><%=	workAndExpenseRecord.getQuantity() == null ? "--" : (isWorkRecord ? (isWorkRecordInPercent ? formatter0.format(workAndExpenseRecord.getQuantity()) : decimalMinutesToHhMm(workAndExpenseRecord.getQuantity().doubleValue() * 60.0)) : quantityf.format(workAndExpenseRecord.getQuantity())) %></a></td>
<%
													if (isWorkRecordInPercent) {
%>
															<td class="padded_r <%= dailySum.doubleValue() == 100.0 ? "" : "error" %> " id="cumSum<%= rowCounter++ %>"><%= formatter0.format(dailySum.doubleValue()) %></td>
<%
													} else {
%>
															<td class="padded_r"></td>
<%
													}
													if (!isWorkRecord) {
%>
														<td class="padded"><a href='<%= recordHref %>' target='_blank'><%= workAndExpenseRecord.getQuantityUom() != null && workAndExpenseRecord.getQuantityUom().getName() != null ? app.getHtmlEncoder().encode(workAndExpenseRecord.getQuantityUom().getName(), false) : "?" %>&nbsp;</a></td>
<%
													}
													if (isWorkRecord && !isWorkRecordInPercent) {
%>
														<td class="padded_r"><a href='<%= recordHref %>' target='_blank'>[<%= workAndExpenseRecord.getRate() != null ? ratesepf.format(workAndExpenseRecord.getRate()) : "--" %>]&nbsp;</a></td>
														<td class="padded"	 <%= quantityError ? errorStyle : "" %>><a href='<%= recordHref %>' target='_blank'><%= currency %></a></td>
														<td class="padded_r" <%= quantityError ? errorStyle : "" %>><a href='<%= recordHref %>' target='_blank'><%= ratesepf.format(recordTotal) %></a></td>
														<td class="padded"><a href='<%= recordHref %>' target='_blank'><img src="../../images/<%= workAndExpenseRecord.isBillable() != null && workAndExpenseRecord.isBillable().booleanValue() ? "" : "not" %>checked_r.gif" /></a></td>
														<td class="padded"><a href='<%= recordHref %>' target='_blank'><img src="../../images/<%= workAndExpenseRecord.isReimbursable() != null && workAndExpenseRecord.isReimbursable().booleanValue() ? "" : "not" %>checked_r.gif" /></a></td>
<%
													}
%>
													<td class="padded"><a href='<%= recordHref %>' target='_blank'><%= app.getHtmlEncoder().encode(workAndExpenseRecord.getName(), false) %></a></td>
													<td class="padded"><a href='<%= activityHref %>' target='_blank'>#<%= app.getHtmlEncoder().encode(new ObjectReference(activity, app).getTitle(), false) %>&nbsp;</a></td>
													<td class="padded" <%= isWorkRecordInPercent ? "style='display:none;'" : "" %>><a href='<%= recordHref %>' target='_blank'><%= (String)(codes.getLongText(featureRecordType, app.getCurrentLocaleAsIndex(), true, true).get(new Short(workAndExpenseRecord.getRecordType()))) %></a></td>
													<td class="padded"><a href='<%= recordHref %>' target='_blank'><%= workAndExpenseRecord.getDescription() != null ? app.getHtmlEncoder().encode(workAndExpenseRecord.getDescription(), false) : "" %></a></td>
													<td class="padded">
														<img src="../../images/deletesmall.gif" style="cursor:pointer;" onclick="javascript:$('deleteWorkRecordXri').value='<%= app.getHtmlEncoder().encode(workAndExpenseRecord.refMofId(), false) %>'; $('reload.button').click();" />
<%
															if (!isDayBreak) {
%>
																	<script language="javascript" type="text/javascript">
																			try {
																					$('cumSum<%= rowCounter-2 %>').innerHTML = '';
																			} catch (e) {}
																	</script>
<%
															}
%>
													</td>
												</tr>
<%
												isEvenRow = !isEvenRow;
										}
%>
									</table>
									</td></tr></table>

<%
									if (isWorkRecord & !isWorkRecordInPercent) {
%>
										<table><tr><td style="padding-left:5px;">
										<table class="gridTable">
											<tr class="gridTableHeader">
<%
												int dayCounter = 0;
												for (int i = calendarBeginOfWeek.get(GregorianCalendar.DAY_OF_WEEK); dayCounter < 7; dayCounter++) {
%>
													<td class="smallheader"><%= weekdayf.format(calendarBeginOfWeek.getTime()) %></td>
<%
													calendarBeginOfWeek.add(GregorianCalendar.DAY_OF_MONTH, 1);
												}
%>
													<td class="smallheader">hh:mm&nbsp;&nbsp;</td>
													<td class="smallheaderR">&nbsp;</td>
											</tr>
											<tr>
<%
												double sumWeek = 0.0;
												dayCounter = 0;
												for(int i = calendarBeginOfWeek.getFirstDayOfWeek(); dayCounter < 7; dayCounter++) {
%>
													<td class="padded_r"><%= isWorkRecordInPercent ? formatter0.format(sumDays[i % 7])+"%" : decimalMinutesToHhMm(sumDays[i % 7] * 60.0) %></td>
<%
													sumWeek += sumDays[i % 7];
													i++;
												}
%>
													<td class="padded_r"><%= isWorkRecordInPercent ? "" : decimalMinutesToHhMm(sumWeek * 60.0) %></td>
													<td class="padded">&sum;</td>
											</tr>
											<tr>
<%
												double sumWeekBillable = 0.0;
												dayCounter = 0;
												for(int i = calendarBeginOfWeek.getFirstDayOfWeek(); dayCounter < 7; dayCounter++) {
%>
													<td class="padded_r"><%= decimalMinutesToHhMm(sumDaysBillable[i % 7] * 60.0) %></td>
<%
													sumWeekBillable += sumDaysBillable[i % 7];
													i++;
												}
%>
													<td class="padded_r"><%= decimalMinutesToHhMm(sumWeekBillable * 60.0) %></td>
													<td class="padded">&sum; (<%= userView.getFieldLabel(WORKANDEXPENSERECORD_CLASS, "isBillable", app.getCurrentLocaleAsIndex()) %>)</td>
											</tr>
										</table>
										</td></tr></table>
<%
									}
							}
					}
%>
				</form>
				<script language="javascript" type="text/javascript">
						function setFocus(id) {
							try {
								$(id).focus();
							} catch(e){}
						}
<%
						if (isFirstCall)									 { %>setFocus('contactXri.Title');	<% }
						else if (isContactChange)					{ %>setFocus('contactXri.Title');	<% }
						else if (isResourceChange)				 { %>setFocus('resourceXri');			 <% }
						else if (isResourceChange)				 { %>setFocus('resourceXri');			 <% }
						else if (isRecordTypeChange)			 { %>setFocus('recordType');				<% }
												else if (lastFocusId.length() > 0) { %>setFocus('<%= lastFocusId %>');<% }

%>
				</script>

							</div> <!-- inspPanel0 -->
						</div> <!-- inspContent -->
					</div> <!-- inspector -->
				</div> <!-- aPanel -->

			</div> <!-- content -->
		</div> <!-- content-wrap -->
	</div> <!-- wrap -->
</div> <!-- container -->
<%= mustReload ? "<script language='javascript' type='text/javascript'>$('reload.button').click();</script>" : "" %>
</body>
</html>
<%
if(pm != null) {
	pm.close();
}
%>
